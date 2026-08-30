import 'dart:async';

import 'package:city_event_radar/src/event.dart';
import 'package:city_event_radar/src/event_cache.dart';
import 'package:city_event_radar/src/event_fixture.dart';
import 'package:city_event_radar/src/event_local_store.dart';
import 'package:city_event_radar/src/event_preferences.dart';
import 'package:city_event_radar/src/event_radar_controller.dart';
import 'package:city_event_radar/src/event_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('writes the full successful response to cache', () async {
    final preferences = MemoryEventPreferences();
    final localStore = MemoryEventLocalStore();
    addTearDown(localStore.close);
    final controller = EventRadarController(
      service: ImmediateEventService(),
      preferences: preferences,
      localStore: localStore,
      now: () => testNow,
    );

    await controller.initialize();

    expect(controller.source, RadarSource.network);
    expect(controller.visibleEvents, hasLength(6));
    expect(localStore.cache?.savedAt, testNow);
    controller.dispose();
  });

  test('uses stale cache when the service is offline', () async {
    final preferences = MemoryEventPreferences();
    final localStore = MemoryEventLocalStore(
      cache: CachedEventFeed(
        rawJson: fixturePayload(),
        savedAt: testNow.subtract(const Duration(hours: 2)),
      ),
    );
    addTearDown(localStore.close);
    final controller = EventRadarController(
      service: FailingEventService(),
      preferences: preferences,
      localStore: localStore,
      now: () => testNow,
    );

    await controller.initialize();

    expect(controller.phase, RadarPhase.degraded);
    expect(controller.source, RadarSource.staleCache);
    expect(controller.warning, contains('过期缓存'));
    expect(controller.visibleEvents, isNotEmpty);
    controller.dispose();
  });

  test('a late search response cannot replace the newer result', () async {
    final service = ControlledEventService();
    final localStore = MemoryEventLocalStore();
    addTearDown(localStore.close);
    final controller = EventRadarController(
      service: service,
      preferences: MemoryEventPreferences(),
      localStore: localStore,
    );

    final oldSearch = controller.searchNow('夜');
    final newSearch = controller.searchNow('河');
    service.complete('河', fixturePayload(query: '河'));
    await newSearch;
    service.complete('夜', fixturePayload(query: '夜'));
    await oldSearch;

    expect(controller.visibleEvents.single.id, 'river-listening-walk');
    expect(controller.ignoredResponseCount, 1);
    controller.dispose();
  });
}

final testNow = DateTime.parse('2026-08-30T10:00:00+08:00');

class ImmediateEventService implements EventService {
  @override
  Future<EventFetch> fetch(String query) async {
    final payload = fixturePayload(query: query);
    return EventFetch(
      feed: bundledFixtureFeed().matching(query),
      rawJson: payload,
    );
  }
}

class FailingEventService implements EventService {
  @override
  Future<EventFetch> fetch(String query) {
    throw const EventServiceException('当前离线');
  }
}

class ControlledEventService implements EventService {
  final Map<String, Completer<EventFetch>> _requests = {};

  @override
  Future<EventFetch> fetch(String query) {
    final completer = Completer<EventFetch>();
    _requests[query] = completer;
    return completer.future;
  }

  void complete(String query, String payload) {
    _requests
        .remove(query)!
        .complete(
          EventFetch(
            feed: bundledFixtureFeed().matching(query),
            rawJson: payload,
          ),
        );
  }
}

class MemoryEventPreferences implements EventPreferenceStore {
  MemoryEventPreferences({this.preferences = const EventPreferences()});

  EventPreferences preferences;

  @override
  Future<EventPreferences> readPreferences() async => preferences;

  @override
  Future<void> writePreferences(EventPreferences value) async {
    preferences = value;
  }
}

class MemoryEventLocalStore implements EventLocalStore {
  MemoryEventLocalStore({this.cache});

  final _changes = StreamController<Set<String>>.broadcast();
  final Set<String> _ids = {};
  CachedEventFeed? cache;

  @override
  Future<CachedEventFeed?> readCache() async => cache;

  @override
  Future<void> writeCache(CachedEventFeed value) async => cache = value;

  @override
  Stream<Set<String>> watchSavedIds() async* {
    yield Set.unmodifiable(_ids);
    yield* _changes.stream;
  }

  @override
  Future<void> toggleSaved(CityEvent event) async {
    if (!_ids.add(event.id)) _ids.remove(event.id);
    _changes.add(Set.unmodifiable(_ids));
  }

  @override
  Future<void> close() => _changes.close();
}
