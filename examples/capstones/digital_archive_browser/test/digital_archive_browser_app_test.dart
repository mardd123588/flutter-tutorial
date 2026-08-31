import 'package:digital_archive_browser/src/data/archive_repository.dart';
import 'package:digital_archive_browser/src/domain/archive_models.dart';
import 'package:digital_archive_browser/src/state/archive_providers.dart';
import 'package:digital_archive_browser/src/ui/archive_app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

void main() {
  testWidgets('restores URL state and writes search and view changes', (
    tester,
  ) async {
    final harness = await _pumpArchive(
      tester,
      initialLocation: '/archive?q=%E6%B2%B3%E5%B2%B8&view=grid',
    );

    final search = tester.widget<TextField>(
      find.byKey(const ValueKey('archive-search')),
    );
    expect(search.controller?.text, '河岸');
    expect(find.text('网格'), findsOneWidget);

    await tester.enterText(find.byKey(const ValueKey('archive-search')), '夜校');
    await tester.testTextInput.receiveAction(TextInputAction.search);
    await tester.pumpAndSettle();
    expect(
      harness.router.routeInformationProvider.value.uri.queryParameters['q'],
      '夜校',
    );

    await tester.tap(find.text('列表').last);
    await tester.pumpAndSettle();
    expect(
      harness.router.routeInformationProvider.value.uri.queryParameters['view'],
      isNull,
    );
    harness.dispose();
  });

  testWidgets('uses lazy slivers and preserves stable record identity', (
    tester,
  ) async {
    await _setSurface(tester, const Size(1440, 900));
    final harness = await _pumpArchive(tester);
    final last = fixtureArchiveRecords.last;

    expect(find.byKey(ValueKey(last.id)), findsNothing);
    await tester.scrollUntilVisible(
      find.byKey(ValueKey(last.id)),
      800,
      scrollable: _resultsScrollable(),
      maxScrolls: 40,
    );
    expect(find.byKey(ValueKey(last.id)), findsOneWidget);
    expect(tester.takeException(), isNull);
    harness.dispose();
  });

  testWidgets('announces and focuses the fourth-comparison rejection', (
    tester,
  ) async {
    await _setSurface(tester, const Size(1440, 900));
    final semantics = tester.ensureSemantics();
    final container = ProviderContainer(retry: noArchiveProviderRetry);
    addTearDown(container.dispose);
    final records = await container.read(archiveRecordsProvider.future);
    final knownIds = records.map((record) => record.id).toSet();
    for (final record in records.take(3)) {
      container
          .read(archiveComparisonProvider.notifier)
          .add(record.id, knownIds);
    }
    final harness = await _pumpArchive(tester, container: container);
    final fourth = records[3];
    await tester.scrollUntilVisible(
      find.byKey(ValueKey('compare-${fourth.id}')),
      500,
      scrollable: _resultsScrollable(),
      maxScrolls: 16,
    );
    await tester.tap(find.byKey(ValueKey('compare-${fourth.id}')));
    await tester.pump();

    final status = find.byKey(const ValueKey('comparison-limit-status'));
    expect(status, findsOneWidget);
    expect(tester.getSemantics(status).label, contains('最多放 3 条'));
    expect(
      FocusManager.instance.primaryFocus?.debugLabel,
      'comparison-limit-error',
    );
    expect(find.byKey(const ValueKey('comparison-recovery')), findsOneWidget);
    semantics.dispose();
    harness.dispose();
  });

  testWidgets('opens a stable detail link and explains a missing record', (
    tester,
  ) async {
    final harness = await _pumpArchive(
      tester,
      initialLocation: '/records/record-missing?q=%E6%B2%B3%E5%B2%B8',
    );

    expect(find.text('没有这条档案'), findsOneWidget);
    await tester.tap(find.text('返回档案列表'));
    await tester.pumpAndSettle();
    expect(
      harness.router.routeInformationProvider.value.uri.toString(),
      '/archive?q=%E6%B2%B3%E5%B2%B8',
    );
    harness.dispose();
  });

  testWidgets('shows loading failure and retries through the provider seam', (
    tester,
  ) async {
    final repository = _FlakyRepository();
    final harness = await _pumpArchive(tester, repository: repository);

    expect(find.text('档案暂时没有加载出来'), findsOneWidget);
    await tester.tap(find.text('重新加载'));
    await tester.pumpAndSettle();
    expect(find.text('找到 120 条记录'), findsOneWidget);
    harness.dispose();
  });

  testWidgets('completes the fixed browser profile workload', (tester) async {
    final harness = await _pumpArchive(tester);
    final scroll = find.byKey(const ValueKey('archive-results-scroll'));
    for (var index = 0; index < 3; index++) {
      await tester.fling(scroll, const Offset(0, -850), 2400);
      await tester.pumpAndSettle();
    }
    await tester.dragUntilVisible(
      find.byKey(const ValueKey('archive-view-toggle')),
      scroll,
      const Offset(0, 700),
    );
    await tester.tap(find.text('网格'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const ValueKey('archive-search')), '夜校');
    await tester.testTextInput.receiveAction(TextInputAction.search);
    await tester.pumpAndSettle();
    final detail = find.byKey(const ValueKey('open-record-001'));
    await tester.scrollUntilVisible(
      detail,
      420,
      scrollable: _resultsScrollable(),
    );
    await tester.tap(detail);
    await tester.pumpAndSettle();
    expect(
      harness.router.routeInformationProvider.value.uri.queryParameters['q'],
      '夜校',
    );
    expect(find.textContaining('河岸夜校合影'), findsWidgets);
    await tester.tap(find.byTooltip('返回结果'));
    await tester.pumpAndSettle();
    expect(harness.router.routeInformationProvider.value.uri.path, '/archive');
    harness.dispose();
  });

  for (final size in const [Size(320, 720), Size(768, 900), Size(1440, 900)]) {
    testWidgets('stays usable at ${size.width} by ${size.height}', (
      tester,
    ) async {
      await _setSurface(tester, size);
      final harness = await _pumpArchive(tester);

      if (size.width < 1050) {
        expect(find.byKey(const ValueKey('open-filter-sheet')), findsOneWidget);
      } else {
        expect(find.byKey(const ValueKey('open-filter-sheet')), findsNothing);
      }
      expect(find.byKey(const ValueKey('archive-search')), findsOneWidget);
      expect(tester.takeException(), isNull);
      harness.dispose();
    });
  }

  testWidgets('supports 200 percent text, RTL, and reduced motion', (
    tester,
  ) async {
    await _setSurface(tester, const Size(320, 720));
    final harness = await _pumpArchive(
      tester,
      mediaQueryData: const MediaQueryData(
        textScaler: TextScaler.linear(2),
        disableAnimations: true,
      ),
      textDirection: TextDirection.rtl,
    );

    expect(find.byKey(const ValueKey('archive-search')), findsOneWidget);
    expect(tester.takeException(), isNull);
    harness.dispose();
  });
}

Future<_ArchiveHarness> _pumpArchive(
  WidgetTester tester, {
  String initialLocation = '/archive',
  ProviderContainer? container,
  ArchiveRepository? repository,
  MediaQueryData? mediaQueryData,
  TextDirection? textDirection,
}) async {
  final router = createArchiveRouter(initialLocation: initialLocation);
  Widget app = DigitalArchiveBrowserApp(router: router);
  if (mediaQueryData != null || textDirection != null) {
    app = MediaQuery(
      data: mediaQueryData ?? const MediaQueryData(),
      child: Directionality(
        textDirection: textDirection ?? TextDirection.ltr,
        child: app,
      ),
    );
  }
  await tester.pumpWidget(
    container == null
        ? ProviderScope(
            retry: noArchiveProviderRetry,
            overrides: [
              if (repository != null)
                archiveRepositoryProvider.overrideWithValue(repository),
            ],
            child: app,
          )
        : UncontrolledProviderScope(container: container, child: app),
  );
  await tester.pumpAndSettle();
  return _ArchiveHarness(router);
}

Finder _resultsScrollable() => find
    .descendant(
      of: find.byKey(const ValueKey('archive-results-scroll')),
      matching: find.byType(Scrollable),
    )
    .first;

Future<void> _setSurface(WidgetTester tester, Size size) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

class _ArchiveHarness {
  const _ArchiveHarness(this.router);

  final GoRouter router;

  void dispose() => router.dispose();
}

class _FlakyRepository implements ArchiveRepository {
  var attempts = 0;

  @override
  Future<List<ArchiveRecord>> fetchRecords() async {
    attempts++;
    if (attempts == 1) throw const ArchiveLoadException();
    return fixtureArchiveRecords;
  }
}
