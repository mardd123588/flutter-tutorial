import 'package:city_event_radar/src/city_event_radar_app.dart';
import 'package:city_event_radar/src/event_database.dart';
import 'package:city_event_radar/src/event_preferences.dart';
import 'package:city_event_radar/src/event_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('searches, saves, and falls back to persisted local data', (
    tester,
  ) async {
    final database = EventDatabase.defaults();
    await database.delete(database.savedEventTags).go();
    await database.delete(database.savedEvents).go();
    await database.delete(database.eventCaches).go();
    final client = FixtureEventClient();

    await tester.pumpWidget(
      CityEventRadarApp(
        service: HttpEventService(client: client),
        preferences: SharedPreferencesEventStore(),
        localStore: database,
        networkControl: client,
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const ValueKey('event-search-field')),
      '河',
    );
    await tester.pump(const Duration(milliseconds: 700));
    expect(find.text('河岸听觉散步'), findsOneWidget);

    final saveButton = find.byKey(
      const ValueKey('save-river-listening-walk'),
    );
    await tester.ensureVisible(saveButton);
    await tester.pump();
    final savedIdsFuture = database
        .watchSavedIds()
        .firstWhere((ids) => ids.contains('river-listening-walk'))
        .timeout(const Duration(seconds: 5));
    await tester.tap(saveButton);
    final savedIds = await savedIdsFuture;
    await tester.pump();
    expect(
      savedIds,
      contains('river-listening-walk'),
    );

    final networkSwitch = find.byKey(const ValueKey('network-switch'));
    await tester.ensureVisible(networkSwitch);
    await tester.pump();
    await tester.tap(networkSwitch);
    await tester.pump(const Duration(milliseconds: 700));
    expect(find.byKey(const ValueKey('fallback-notice')), findsOneWidget);
    expect(find.text('河岸听觉散步'), findsOneWidget);

    await database.close();
  });
}
