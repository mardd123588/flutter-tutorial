import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:scroll_timeline/src/scroll_timeline_app.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('filters, jumps, and records a long-scroll profile', (
    tester,
  ) async {
    await tester.pumpWidget(const ProviderScope(child: ScrollTimelineApp()));
    await tester.pumpAndSettle();

    expect(find.text('河岸修复六十年'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('topic-ecology')));
    await tester.pumpAndSettle();
    expect(find.text('已选 1 个主题'), findsOneWidget);

    final timeline = find.byKey(const ValueKey('timeline-scroll'));
    await binding.watchPerformance(() async {
      for (var index = 0; index < 8; index++) {
        await tester.fling(timeline, const Offset(0, -760), 2200);
        await tester.pumpAndSettle();
      }
      for (var index = 0; index < 8; index++) {
        await tester.fling(timeline, const Offset(0, 760), 2200);
        await tester.pumpAndSettle();
      }
    }, reportKey: 'long_scroll');

    expect(find.text('河岸修复六十年'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
