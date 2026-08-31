import 'package:digital_archive_browser/src/data/archive_repository.dart';
import 'package:digital_archive_browser/src/state/archive_providers.dart';
import 'package:digital_archive_browser/src/ui/archive_app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  // #region archive-profile-journey
  testWidgets(
    'restores URL, compares records, and profiles the archive journey',
    (tester) async {
      final router = createArchiveRouter(initialLocation: '/archive');
      addTearDown(router.dispose);
      await tester.pumpWidget(
        ProviderScope(
          retry: noArchiveProviderRetry,
          child: DigitalArchiveBrowserApp(router: router),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('找到 120 条记录'), findsOneWidget);
      final scroll = find.byKey(const ValueKey('archive-results-scroll'));
      await binding.watchPerformance(() async {
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
        await tester.enterText(
          find.byKey(const ValueKey('archive-search')),
          '夜校',
        );
        router.go('/archive?q=%E5%A4%9C%E6%A0%A1&view=grid');
        await tester.pumpAndSettle();
        final firstDetail = find.byKey(const ValueKey('open-record-001'));
        await tester.scrollUntilVisible(
          firstDetail,
          420,
          scrollable: find
              .descendant(of: scroll, matching: find.byType(Scrollable))
              .first,
        );
        await tester.tap(firstDetail);
        await tester.pumpAndSettle();
        expect(find.textContaining('河岸夜校合影'), findsWidgets);
        await tester.tap(find.byTooltip('返回结果'));
        await tester.pumpAndSettle();
      }, reportKey: 'archive_journey');
      binding.reportData!['checkpoint'] = 'profile-complete';
      binding.reportData!['returned_uri'] = router
          .routeInformationProvider
          .value
          .uri
          .toString();

      expect(
        router.routeInformationProvider.value.uri.queryParameters['q'],
        '夜校',
      );
      router.go('/archive?view=grid');
      await tester.pumpAndSettle();
      binding.reportData!['checkpoint'] = 'query-reset';

      var comparisonCount = 0;
      for (final record in fixtureArchiveRecords.take(3)) {
        final button = find.byKey(ValueKey('compare-${record.id}'));
        await tester.scrollUntilVisible(
          button,
          420,
          scrollable: find
              .descendant(of: scroll, matching: find.byType(Scrollable))
              .first,
        );
        if (tester.getCenter(button).dy > 440) {
          await tester.drag(scroll, const Offset(0, -180));
          await tester.pumpAndSettle();
        }
        await tester.tap(button);
        await tester.pumpAndSettle();
        comparisonCount++;
        binding.reportData!['checkpoint'] = 'comparison-$comparisonCount';
        expect(find.text('对照栏 $comparisonCount/3'), findsOneWidget);
      }
      expect(find.text('对照栏 3/3'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
  // #endregion archive-profile-journey
}
