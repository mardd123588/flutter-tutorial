import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:sortable_duty_board/src/sortable_duty_board.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('a handoff note follows its member through reordering', (
    tester,
  ) async {
    await tester.pumpWidget(const SortableDutyBoardApp());
    await tester.enterText(find.byKey(const ValueKey('note-a01')), '钥匙留在北侧抽屉');
    await tester.ensureVisible(find.byKey(const ValueKey('move-down-a01')));
    await tester.tap(find.byKey(const ValueKey('move-down-a01')));
    await tester.pumpAndSettle();

    final note = tester.widget<TextField>(
      find.byKey(const ValueKey('note-a01')),
    );
    expect(note.controller?.text, '钥匙留在北侧抽屉');
    expect(find.textContaining('安岚已移到第 2 位'), findsOneWidget);
  });
}
