import 'dart:async';

import 'package:city_event_radar/src/city_event_radar_app.dart';
import 'package:city_event_radar/src/event.dart';
import 'package:city_event_radar/src/event_cache.dart';
import 'package:city_event_radar/src/event_fixture.dart';
import 'package:city_event_radar/src/event_local_store.dart';
import 'package:city_event_radar/src/event_preferences.dart';
import 'package:city_event_radar/src/event_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('filters a district and records a local favorite', (
    tester,
  ) async {
    final localStore = TestEventLocalStore();
    addTearDown(localStore.close);
    await tester.pumpWidget(
      CityEventRadarApp(
        service: TestEventService(),
        preferences: TestPreferences(),
        localStore: localStore,
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('district-东岸')));
    await tester.pump();
    expect(find.text('河岸听觉散步'), findsOneWidget);
    expect(find.text('夜间双色印刷实验室'), findsNothing);

    final saveButton = find.byKey(const ValueKey('save-river-listening-walk'));
    await tester.ensureVisible(saveButton);
    await tester.pump();
    await tester.tap(saveButton);
    await tester.pump();
    expect(localStore.ids, contains('river-listening-walk'));
  });

  testWidgets('shows the fixture fallback when the network is unavailable', (
    tester,
  ) async {
    final localStore = TestEventLocalStore();
    addTearDown(localStore.close);
    await tester.pumpWidget(
      CityEventRadarApp(
        service: OfflineEventService(),
        preferences: TestPreferences(),
        localStore: localStore,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('fallback-notice')), findsOneWidget);
    expect(find.textContaining('内置教学 fixture'), findsOneWidget);
    expect(find.text('河岸听觉散步'), findsOneWidget);
  });

  testWidgets('stays usable at 320px and 200% text scale', (tester) async {
    tester.view.physicalSize = const Size(640, 1440);
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final localStore = TestEventLocalStore();
    addTearDown(localStore.close);

    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(textScaler: TextScaler.linear(2)),
        child: CityEventRadarApp(
          service: TestEventService(),
          preferences: TestPreferences(),
          localStore: localStore,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.byKey(const ValueKey('event-search-field')), findsOneWidget);
  });

  testWidgets('disables radar motion when animations are disabled', (
    tester,
  ) async {
    final localStore = TestEventLocalStore();
    addTearDown(localStore.close);

    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(disableAnimations: true),
        child: CityEventRadarApp(
          service: TestEventService(),
          preferences: TestPreferences(),
          localStore: localStore,
        ),
      ),
    );
    await tester.pumpAndSettle();

    final animation = tester.widget<TweenAnimationBuilder<double>>(
      find.byType(TweenAnimationBuilder<double>),
    );
    expect(animation.duration, Duration.zero);
  });
}

class TestEventService implements EventService {
  @override
  Future<EventFetch> fetch(String query) async {
    final payload = fixturePayload(query: query);
    return EventFetch(
      feed: bundledFixtureFeed().matching(query),
      rawJson: payload,
    );
  }
}

class OfflineEventService implements EventService {
  @override
  Future<EventFetch> fetch(String query) {
    throw const EventServiceException('当前离线');
  }
}

class TestPreferences implements EventPreferenceStore {
  EventPreferences value = const EventPreferences();

  @override
  Future<EventPreferences> readPreferences() async => value;

  @override
  Future<void> writePreferences(EventPreferences value) async {
    this.value = value;
  }
}

class TestEventLocalStore implements EventLocalStore {
  final changes = StreamController<Set<String>>.broadcast();
  final Set<String> ids = {};
  CachedEventFeed? cache;

  @override
  Future<CachedEventFeed?> readCache() async => cache;

  @override
  Future<void> writeCache(CachedEventFeed value) async => cache = value;

  @override
  Stream<Set<String>> watchSavedIds() async* {
    yield Set.unmodifiable(ids);
    yield* changes.stream;
  }

  @override
  Future<void> toggleSaved(CityEvent event) async {
    if (!ids.add(event.id)) ids.remove(event.id);
    changes.add(Set.unmodifiable(ids));
  }

  @override
  Future<void> close() => changes.close();
}
