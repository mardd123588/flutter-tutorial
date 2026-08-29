import 'package:daily_rhythm_board/src/rhythm_board.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void expectHorizontallyInside(
  WidgetTester tester,
  Finder finder, {
  Rect? container,
}) {
  final rect = tester.getRect(finder);
  final bounds = container ?? (Offset.zero & tester.view.physicalSize);

  expect(rect.left, greaterThanOrEqualTo(bounds.left));
  expect(rect.right, lessThanOrEqualTo(bounds.right));
}

void expectInside(WidgetTester tester, Finder finder, Rect container) {
  final rect = tester.getRect(finder);
  const tolerance = 1.0;

  expect(rect.left, greaterThanOrEqualTo(container.left - tolerance));
  expect(rect.top, greaterThanOrEqualTo(container.top - tolerance));
  expect(rect.right, lessThanOrEqualTo(container.right + tolerance));
  expect(rect.bottom, lessThanOrEqualTo(container.bottom + tolerance));
}

void main() {
  testWidgets('selecting an entry updates the sundial and detail', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(const DailyRhythmApp());

    expect(find.text('第一段专注'), findsOneWidget);

    final afternoonButton = find.widgetWithText(OutlinedButton, '午后专注');
    await tester.ensureVisible(afternoonButton);
    await tester.tap(afternoonButton);
    await tester.pump();

    expect(find.text('14:00 · 午后专注'), findsOneWidget);
    expect(find.text('把范围压到一个可交付结果，结束前留五分钟记录下一步。'), findsOneWidget);
    await tester.drag(
      find.byType(SingleChildScrollView),
      const Offset(0, 1000),
    );
    await tester.pump();
    expect(find.bySemanticsLabel('日晷指向14:00，午后专注'), findsOneWidget);
    semantics.dispose();
  });

  testWidgets('the main flow stays inside a narrow viewport', (tester) async {
    tester.view.physicalSize = const Size(320, 720);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(const DailyRhythmApp());
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);

    final sundial = find.bySemanticsLabel('日晷指向09:00，第一段专注');
    final sundialRect = tester.getRect(sundial);
    expectHorizontallyInside(tester, sundial);
    for (final label in ['日光', '停顿', '07:00', '19:00']) {
      expectHorizontallyInside(
        tester,
        find.text(label),
        container: sundialRect,
      );
    }

    final face = find.byWidgetPredicate(
      (widget) => widget is Stack && widget.alignment == Alignment.bottomCenter,
      description: 'sundial drawing area',
    );
    expect(face, findsOneWidget);
    final faceRect = tester.getRect(face);

    final needle = find.byWidgetPredicate(
      (widget) =>
          widget is SizedBox && widget.width == 4 && widget.child is ColoredBox,
      description: 'sundial needle',
    );
    expect(needle, findsOneWidget);
    expectInside(tester, needle, faceRect);

    final ticks = find.byWidgetPredicate(
      (widget) =>
          widget is SizedBox && widget.width == 2 && widget.child is Align,
      description: 'sundial ticks',
    );
    expect(ticks, findsNWidgets(9));
    for (var index = 0; index < 9; index++) {
      expectInside(tester, ticks.at(index), faceRect);
    }

    for (final title in ['晨间校准', '第一段专注', '离屏走动', '午后专注', '收整桌面']) {
      final button = find.widgetWithText(OutlinedButton, title);
      await tester.ensureVisible(button);
      await tester.pump();
      expectHorizontallyInside(tester, button);
    }

    final detail = find.text('09:00 · 第一段专注');
    await tester.ensureVisible(detail);
    await tester.pump();
    expectHorizontallyInside(tester, detail);
    semantics.dispose();
  });

  testWidgets('the main flow remains usable at 200 percent text scale', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 720);
    tester.view.devicePixelRatio = 1;
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

    await tester.pumpWidget(const DailyRhythmApp());
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    for (final title in ['晨间校准', '第一段专注', '离屏走动', '午后专注', '收整桌面']) {
      final button = find.widgetWithText(OutlinedButton, title);
      await tester.ensureVisible(button);
      await tester.pump();
      expectHorizontallyInside(tester, button);
      expect(tester.takeException(), isNull);
    }

    final detail = find.text('09:00 · 第一段专注');
    await tester.ensureVisible(detail);
    await tester.pump();
    expectHorizontallyInside(tester, detail);
    expect(tester.takeException(), isNull);
  });

  testWidgets('reader can select an afternoon rhythm with the keyboard', (
    tester,
  ) async {
    await tester.pumpWidget(const DailyRhythmApp());
    await tester.pumpAndSettle();

    for (var index = 0; index < 4; index++) {
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
    }
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pump();

    expect(find.text('14:00 · 午后专注'), findsOneWidget);
  });
}
