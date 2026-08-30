import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sortable_duty_board/src/sortable_duty_board.dart';

void main() {
  // #region identity-reorder-test
  testWidgets('keeps a member note and checkbox state after reordering', (
    tester,
  ) async {
    await tester.pumpWidget(const SortableDutyBoardApp());

    await tester.enterText(find.byKey(const ValueKey('note-a01')), '钥匙留在北侧抽屉');
    await tester.ensureVisible(find.byType(Checkbox).first);
    await tester.tap(find.byType(Checkbox).first);
    await tester.ensureVisible(find.byKey(const ValueKey('move-down-a01')));
    await tester.tap(find.byKey(const ValueKey('move-down-a01')));
    await tester.pumpAndSettle();

    final note = tester.widget<TextField>(
      find.byKey(const ValueKey('note-a01')),
    );
    final checkbox = tester.widget<Checkbox>(find.byType(Checkbox).at(1));
    expect(note.controller?.text, '钥匙留在北侧抽屉');
    expect(checkbox.value, isTrue);
    expect(find.textContaining('安岚已移到第 2 位'), findsOneWidget);
  });
  // #endregion identity-reorder-test

  testWidgets('disables movement beyond the list boundaries', (tester) async {
    await tester.pumpWidget(const SortableDutyBoardApp());

    final firstUp = tester.widget<OutlinedButton>(
      find.byKey(const ValueKey('move-up-a01')),
    );
    final lastDown = tester.widget<FilledButton>(
      find.byKey(const ValueKey('move-down-d19')),
    );

    expect(firstUp.onPressed, isNull);
    expect(lastDown.onPressed, isNull);
  });

  testWidgets('exposes named rows and movement controls to semantics', (
    tester,
  ) async {
    final semanticsHandle = tester.ensureSemantics();
    await tester.pumpWidget(const SortableDutyBoardApp());

    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is Semantics && widget.properties.label == '安岚，主值班，第 1 位',
      ),
      findsOneWidget,
    );
    expect(find.byTooltip('拖动 安岚'), findsOneWidget);
    semanticsHandle.dispose();
  });

  testWidgets('fits a 320 by 720 viewport at 200 percent text scale', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 720);
    tester.view.devicePixelRatio = 1;
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(tester.view.reset);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

    await tester.pumpWidget(const SortableDutyBoardApp());
    await tester.pumpAndSettle();

    expect(find.text('可排序\n值班板'), findsOneWidget);
    expect(find.byKey(const ValueKey('note-a01')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
