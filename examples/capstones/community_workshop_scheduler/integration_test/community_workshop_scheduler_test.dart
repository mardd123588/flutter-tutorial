import 'package:community_workshop_scheduler/src/data/schedule_database.dart';
import 'package:community_workshop_scheduler/src/data/workshop_catalog_service.dart';
import 'package:community_workshop_scheduler/src/state/schedule_providers.dart';
import 'package:community_workshop_scheduler/src/ui/community_workshop_scheduler_app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('resolves conflicts and keeps the saved schedule after reopen', (
    tester,
  ) async {
    var database = ScheduleDatabase.defaults();
    await database.restoreEntries(fixtureWorkshopCatalog.initialSchedule);
    var router = createWorkshopSchedulerRouter(
      initialLocation: '/schedule?day=day-sat&venue=venue-forge',
    );
    await _pumpApp(tester, database: database, router: router);

    final viewportWidth =
        tester.view.physicalSize.width / tester.view.devicePixelRatio;
    final firstSession = viewportWidth >= 1016
        ? find.byKey(const ValueKey('session-strip-session-01'))
        : find.byKey(const ValueKey('agenda-session-session-01'));
    await tester.scrollUntilVisible(
      firstSession,
      420,
      scrollable: _mainScrollable(),
    );
    await tester.tap(firstSession);
    await tester.pumpAndSettle();
    expect(find.text('植物染社区地图'), findsWidgets);
    await tester.tap(find.byTooltip('返回排期台'));
    await tester.pumpAndSettle();
    expect(
      router.routeInformationProvider.value.uri.toString(),
      '/schedule?day=day-sat&venue=venue-forge',
    );

    await tester.scrollUntilVisible(
      find.byKey(const ValueKey('create-session')),
      -420,
      scrollable: _mainScrollable(),
    );
    await tester.tap(find.byKey(const ValueKey('create-session')));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const ValueKey('expected-attendees-field')),
      '30',
    );
    await tester.scrollUntilVisible(
      find.byKey(const ValueKey('save-session')),
      360,
      scrollable: _mainScrollable(),
    );
    await tester.tap(find.byKey(const ValueKey('save-session')));
    await tester.pumpAndSettle();
    expect(find.text('场馆时段重叠'), findsOneWidget);
    expect(find.text('讲师时段重叠'), findsOneWidget);
    expect(find.text('预计人数超过场馆容量'), findsOneWidget);

    await _selectDropdown(tester, key: 'venue-field', option: '共享大厅 · 64 人');
    await _selectDropdown(tester, key: 'start-time-field', option: '15:00');
    await _selectDropdown(tester, key: 'end-time-field', option: '16:00');
    await tester.scrollUntilVisible(
      find.byKey(const ValueKey('save-session')),
      360,
      scrollable: _mainScrollable(),
    );
    await tester.tap(find.byKey(const ValueKey('save-session')));
    await tester.pumpAndSettle();

    expect(find.text('预计 30 人'), findsOneWidget);
    final savedUri = router.routeInformationProvider.value.uri;
    expect(savedUri.path, startsWith('/sessions/session-local-'));

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();
    router.dispose();
    await database.close();

    database = ScheduleDatabase.defaults();
    router = createWorkshopSchedulerRouter(
      initialLocation: '/schedule?day=day-sat&venue=venue-hall',
    );
    await _pumpApp(tester, database: database, router: router);
    await tester.scrollUntilVisible(
      find.text('植物染社区地图'),
      420,
      scrollable: _mainScrollable(),
    );
    expect(find.text('植物染社区地图'), findsOneWidget);

    router.dispose();
    await database.close();
  });
}

Future<void> _pumpApp(
  WidgetTester tester, {
  required ScheduleDatabase database,
  required GoRouter router,
}) async {
  await tester.pumpWidget(
    ProviderScope(
      retry: noProviderRetry,
      overrides: [scheduleStorageServiceProvider.overrideWithValue(database)],
      child: CommunityWorkshopSchedulerApp(router: router),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> _selectDropdown(
  WidgetTester tester, {
  required String key,
  required String option,
}) async {
  await tester.scrollUntilVisible(
    find.byKey(ValueKey(key)),
    -260,
    scrollable: _mainScrollable(),
  );
  await tester.tap(find.byKey(ValueKey(key)));
  await tester.pumpAndSettle();
  await tester.tap(find.text(option).last);
  await tester.pumpAndSettle();
}

Finder _mainScrollable() {
  return find.descendant(
    of: find.byType(CustomScrollView),
    matching: find.byType(Scrollable),
  ).first;
}
