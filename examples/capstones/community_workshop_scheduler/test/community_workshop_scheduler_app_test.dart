import 'package:community_workshop_scheduler/src/data/schedule_repository.dart';
import 'package:community_workshop_scheduler/src/data/workshop_catalog_service.dart';
import 'package:community_workshop_scheduler/src/domain/schedule_models.dart';
import 'package:community_workshop_scheduler/src/state/schedule_providers.dart';
import 'package:community_workshop_scheduler/src/ui/community_workshop_scheduler_app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

void main() {
  testWidgets('switches one schedule between wall and agenda layouts', (
    tester,
  ) async {
    await _setSurface(tester, const Size(1440, 900));
    final wide = await _pumpScheduler(tester);
    expect(find.byKey(const ValueKey('wide-schedule-wall')), findsOneWidget);
    expect(find.byKey(const ValueKey('compact-schedule-agenda')), findsNothing);
    wide.dispose();

    await _setSurface(tester, const Size(320, 720));
    final compact = await _pumpScheduler(tester);
    expect(find.byKey(const ValueKey('wide-schedule-wall')), findsNothing);
    expect(
      find.byKey(const ValueKey('compact-schedule-agenda')),
      findsOneWidget,
    );
    expect(find.text('植物染社区地图'), findsOneWidget);
    compact.dispose();
  });

  testWidgets('shows every save conflict and focuses the summary', (
    tester,
  ) async {
    final repository = ConflictScheduleRepository();
    final harness = await _pumpScheduler(
      tester,
      repository: repository,
      initialLocation: '/new',
    );

    await tester.enterText(
      find.byKey(const ValueKey('expected-attendees-field')),
      '30',
    );
    await tester.tap(find.byKey(const ValueKey('save-session')));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('conflict-summary')), findsOneWidget);
    expect(find.text('场馆时段重叠'), findsOneWidget);
    expect(find.text('讲师时段重叠'), findsOneWidget);
    expect(find.text('预计人数超过场馆容量'), findsOneWidget);
    final summaryFocus = tester.widget<Focus>(
      find.byKey(const ValueKey('conflict-summary-focus')),
    );
    expect(summaryFocus.focusNode?.hasFocus, isTrue);
    expect(repository.saveCalls, 1);
    harness.dispose();
  });

  testWidgets('explains an unknown session deep link', (tester) async {
    final harness = await _pumpScheduler(
      tester,
      initialLocation: '/sessions/not-here',
    );

    expect(find.text('找不到这个场次'), findsOneWidget);
    expect(find.textContaining('not-here'), findsOneWidget);
    harness.dispose();
  });

  testWidgets('renders loading failures and empty results as distinct states', (
    tester,
  ) async {
    final failed = await _pumpScheduler(
      tester,
      repository: InitialFailureScheduleRepository(),
    );
    expect(find.byKey(const ValueKey('retry-initial-load')), findsOneWidget);
    failed.dispose();

    final empty = await _pumpScheduler(
      tester,
      repository: EmptyScheduleRepository(),
    );
    expect(find.byKey(const ValueKey('empty-schedule')), findsOneWidget);
    empty.dispose();

    final streamFailed = await _pumpScheduler(
      tester,
      repository: StreamFailureScheduleRepository(),
    );
    expect(
      find.byKey(const ValueKey('schedule-stream-failure')),
      findsOneWidget,
    );
    streamFailed.dispose();
  });

  for (final size in const [Size(320, 720), Size(768, 900), Size(1440, 900)]) {
    testWidgets(
      'keeps the main task at ${size.width.toInt()} by ${size.height.toInt()}',
      (tester) async {
        await _setSurface(tester, size);
        final harness = await _pumpScheduler(tester);

        expect(find.byKey(const ValueKey('create-session')), findsOneWidget);
        expect(find.byKey(const ValueKey('day-filter')), findsOneWidget);
        expect(tester.takeException(), isNull);
        harness.dispose();
      },
    );
  }

  testWidgets('keeps the compact task at 200 percent text', (tester) async {
    await _setSurface(tester, const Size(320, 720));
    final harness = await _pumpScheduler(
      tester,
      mediaQueryData: const MediaQueryData(textScaler: TextScaler.linear(2)),
    );

    await tester.scrollUntilVisible(
      find.byKey(const ValueKey('compact-schedule-agenda')),
      420,
    );
    expect(
      find.byKey(const ValueKey('compact-schedule-agenda')),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
    harness.dispose();
  });

  testWidgets('announces the visible result count', (tester) async {
    final semantics = tester.ensureSemantics();
    final harness = await _pumpScheduler(tester);

    final result = tester.getSemantics(
      find.byKey(const ValueKey('schedule-result-status')),
    );
    expect(result.label, contains('当前显示 10 个场次'));
    harness.dispose();
    semantics.dispose();
  });

  testWidgets('restores day and venue from URL and writes filter changes', (
    tester,
  ) async {
    final harness = await _pumpScheduler(
      tester,
      initialLocation: '/schedule?day=day-sat&venue=venue-forge',
    );

    expect(
      tester
          .getSemantics(find.byKey(const ValueKey('schedule-result-status')))
          .label,
      contains('当前显示 2 个场次'),
    );
    await tester.tap(find.byKey(const ValueKey('day-filter')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('周日 · 9月13日').last);
    await tester.pumpAndSettle();

    expect(
      harness.router.routeInformationProvider.value.uri.toString(),
      '/schedule?day=day-sun&venue=venue-forge',
    );
    expect(find.text('微型木作：窗边搁架'), findsOneWidget);
    harness.dispose();
  });
}

Future<void> _setSurface(WidgetTester tester, Size size) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

Future<_SchedulerHarness> _pumpScheduler(
  WidgetTester tester, {
  FixtureScheduleRepository? repository,
  String initialLocation = '/schedule',
  MediaQueryData? mediaQueryData,
}) async {
  final resolvedRepository = repository ?? FixtureScheduleRepository();
  final router = createWorkshopSchedulerRouter(
    initialLocation: initialLocation,
  );
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        scheduleRepositoryProvider.overrideWithValue(resolvedRepository),
      ],
      child: MediaQuery(
        data: mediaQueryData ?? const MediaQueryData(),
        child: CommunityWorkshopSchedulerApp(router: router),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return _SchedulerHarness(router: router);
}

class _SchedulerHarness {
  const _SchedulerHarness({required this.router});

  final GoRouter router;

  void dispose() {
    router.dispose();
  }
}

class FixtureScheduleRepository implements ScheduleRepository {
  var saveCalls = 0;

  @override
  Future<ScheduleResult<ScheduleEntry>> findEntry(String id) async {
    final entry = fixtureWorkshopCatalog.initialSchedule
        .where((value) => value.id == id)
        .firstOrNull;
    return entry == null
        ? ScheduleFailureResult(ScheduleNotFoundFailure(id))
        : ScheduleSuccess(entry);
  }

  @override
  Future<ScheduleResult<WorkshopCatalog>> loadCatalog() async {
    return ScheduleSuccess(fixtureWorkshopCatalog);
  }

  @override
  Future<ScheduleResult<void>> restoreDemoData() async {
    return const ScheduleSuccess(null);
  }

  @override
  Future<ScheduleResult<ScheduleEntry>> save(ScheduleEntry entry) async {
    saveCalls += 1;
    return ScheduleSuccess(entry);
  }

  @override
  Stream<ScheduleResult<List<ScheduleEntry>>> watchSchedule(
    ScheduleQuery query,
  ) {
    return Stream.value(
      ScheduleSuccess(
        fixtureWorkshopCatalog.initialSchedule
            .where(query.matches)
            .toList(growable: false),
      ),
    );
  }
}

class ConflictScheduleRepository extends FixtureScheduleRepository {
  @override
  Future<ScheduleResult<ScheduleEntry>> save(ScheduleEntry entry) async {
    saveCalls += 1;
    return const ScheduleFailureResult(
      ScheduleConflictFailure([
        ScheduleConflict(kind: ScheduleConflictKind.capacityExceeded),
        ScheduleConflict(
          kind: ScheduleConflictKind.venueOverlap,
          relatedEntryId: 'session-01',
        ),
        ScheduleConflict(
          kind: ScheduleConflictKind.instructorOverlap,
          relatedEntryId: 'session-01',
        ),
      ]),
    );
  }
}

class InitialFailureScheduleRepository extends FixtureScheduleRepository {
  @override
  Future<ScheduleResult<WorkshopCatalog>> loadCatalog() async {
    return const ScheduleFailureResult(ScheduleStorageFailure());
  }
}

class EmptyScheduleRepository extends FixtureScheduleRepository {
  @override
  Stream<ScheduleResult<List<ScheduleEntry>>> watchSchedule(
    ScheduleQuery query,
  ) {
    return Stream.value(const ScheduleSuccess([]));
  }
}

class StreamFailureScheduleRepository extends FixtureScheduleRepository {
  @override
  Stream<ScheduleResult<List<ScheduleEntry>>> watchSchedule(
    ScheduleQuery query,
  ) {
    return Stream.value(const ScheduleFailureResult(ScheduleStorageFailure()));
  }
}
