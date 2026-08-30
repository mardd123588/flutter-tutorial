import 'dart:async';

import 'package:flutter/foundation.dart';

import 'event.dart';
import 'event_cache.dart';
import 'event_feed.dart';
import 'event_fixture.dart';
import 'event_local_store.dart';
import 'event_preferences.dart';
import 'event_service.dart';

enum RadarPhase { loading, ready, empty, degraded }

enum RadarSource { network, freshCache, staleCache, bundledFixture }

class EventRadarController extends ChangeNotifier {
  EventRadarController({
    required this.service,
    required this.preferences,
    required this.localStore,
    this.freshFor = const Duration(minutes: 20),
    this.debounceDuration = const Duration(milliseconds: 320),
    DateTime Function()? now,
  }) : _now = now ?? DateTime.now;

  final EventService service;
  final EventPreferenceStore preferences;
  final EventLocalStore localStore;
  final DateTime Function() _now;
  final Duration freshFor;
  final Duration debounceDuration;

  StreamSubscription<Set<String>>? _savedSubscription;
  Timer? _debounce;
  CachedEventFeed? _cache;
  List<CityEvent> _events = const [];
  int _issuedRequest = 0;
  int _activeRequest = 0;
  bool _disposed = false;

  RadarPhase phase = RadarPhase.loading;
  RadarSource source = RadarSource.bundledFixture;
  String query = '';
  String district = '全部';
  bool savedOnly = false;
  Set<String> savedIds = const {};
  String? warning;
  DateTime? dataTimestamp;
  int ignoredResponseCount = 0;

  List<CityEvent> get visibleEvents {
    return _events
        .where((event) {
          final inDistrict = district == '全部' || event.district == district;
          final saved = !savedOnly || savedIds.contains(event.id);
          return inDistrict && saved;
        })
        .toList(growable: false);
  }

  Future<void> initialize() async {
    _savedSubscription = localStore.watchSavedIds().listen((ids) {
      savedIds = ids;
      if (!_disposed) notifyListeners();
    });

    final storedPreferences = await preferences.readPreferences();
    district = storedPreferences.district;
    savedOnly = storedPreferences.savedOnly;
    _cache = await localStore.readCache();

    final cached = _readCachedFeed();
    if (cached != null && _cacheIsFresh) {
      _events = cached.events;
      dataTimestamp = _cache!.savedAt;
      source = RadarSource.freshCache;
      phase = RadarPhase.loading;
      notifyListeners();
    }
    await _request(query, allowFallback: true);
  }

  void updateQuery(String value) {
    query = value.trim();
    _debounce?.cancel();
    phase = RadarPhase.loading;
    warning = null;
    notifyListeners();
    _debounce = Timer(
      debounceDuration,
      () => _request(query, allowFallback: true),
    );
  }

  Future<void> searchNow(String value) async {
    query = value.trim();
    _debounce?.cancel();
    await _request(query, allowFallback: true);
  }

  Future<void> refresh() => _request(query, allowFallback: true);

  void setDistrict(String value) {
    district = value;
    _savePreferences();
    _updatePhaseFromVisibleEvents();
    notifyListeners();
  }

  void setSavedOnly(bool value) {
    savedOnly = value;
    _savePreferences();
    _updatePhaseFromVisibleEvents();
    notifyListeners();
  }

  Future<void> toggleSaved(CityEvent event) => localStore.toggleSaved(event);

  String get freshnessLabel {
    final timestamp = dataTimestamp;
    if (timestamp == null) return '没有缓存时间';
    final age = _now().difference(timestamp);
    if (age.isNegative || age < const Duration(minutes: 1)) return '刚刚更新';
    if (age < const Duration(hours: 1)) return '${age.inMinutes} 分钟前';
    return '${age.inHours} 小时前';
  }

  Future<void> _request(
    String requestedQuery, {
    required bool allowFallback,
  }) async {
    final request = ++_issuedRequest;
    _activeRequest = request;
    phase = RadarPhase.loading;
    warning = null;
    notifyListeners();

    try {
      final result = await service.fetch(requestedQuery);
      if (request != _activeRequest || _disposed) {
        if (!_disposed) {
          ignoredResponseCount += 1;
          notifyListeners();
        }
        return;
      }
      _events = result.feed.events;
      source = RadarSource.network;
      dataTimestamp = _now();
      if (requestedQuery.isEmpty) {
        _cache = CachedEventFeed(
          rawJson: result.rawJson,
          savedAt: dataTimestamp!,
        );
        await localStore.writeCache(_cache!);
      }
      _updatePhaseFromVisibleEvents();
    } on EventServiceException catch (error) {
      if (request != _activeRequest || _disposed) {
        if (!_disposed) {
          ignoredResponseCount += 1;
          notifyListeners();
        }
        return;
      }
      if (!allowFallback) rethrow;
      _applyFallback(requestedQuery, error.message);
    }

    if (!_disposed) notifyListeners();
  }

  // #region cache-fallback
  void _applyFallback(String requestedQuery, String reason) {
    final cached = _readCachedFeed();
    if (cached != null) {
      _events = cached.matching(requestedQuery).events;
      dataTimestamp = _cache!.savedAt;
      source = _cacheIsFresh ? RadarSource.freshCache : RadarSource.staleCache;
      warning = '$reason；已改用${_cacheIsFresh ? '新鲜' : '过期'}缓存。';
    } else {
      final fixture = bundledFixtureFeed().matching(requestedQuery);
      _events = fixture.events;
      dataTimestamp = fixture.generatedAt;
      source = RadarSource.bundledFixture;
      warning = '$reason；已改用内置教学 fixture。';
    }
    phase = RadarPhase.degraded;
  }
  // #endregion cache-fallback

  EventFeed? _readCachedFeed() {
    final cache = _cache;
    if (cache == null) return null;
    try {
      return EventFeed.fromJsonString(cache.rawJson);
    } on FormatException {
      return null;
    }
  }

  bool get _cacheIsFresh {
    final cache = _cache;
    if (cache == null) return false;
    return _now().difference(cache.savedAt) <= freshFor;
  }

  void _updatePhaseFromVisibleEvents() {
    if (phase == RadarPhase.degraded) return;
    phase = visibleEvents.isEmpty ? RadarPhase.empty : RadarPhase.ready;
  }

  void _savePreferences() {
    unawaited(
      preferences.writePreferences(
        EventPreferences(district: district, savedOnly: savedOnly),
      ),
    );
  }

  @override
  void dispose() {
    _disposed = true;
    _debounce?.cancel();
    _savedSubscription?.cancel();
    super.dispose();
  }
}
