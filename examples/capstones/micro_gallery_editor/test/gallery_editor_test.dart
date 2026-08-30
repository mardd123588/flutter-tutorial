import 'dart:ui' show Tristate;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:micro_gallery_editor/src/gallery_editor.dart';

void main() {
  // #region validation-test
  testWidgets('shows field errors before saving a blank exhibit', (
    tester,
  ) async {
    await tester.pumpWidget(const MicroGalleryEditorApp());

    await tester.tap(find.text('新建 · Ctrl+N'));
    await tester.pump();
    await tester.ensureVisible(find.text('保存展签'));
    await tester.tap(find.text('保存展签'));
    await tester.pump();

    expect(find.text('标题不能为空'), findsOneWidget);
    expect(find.text('艺术家不能为空'), findsOneWidget);
    expect(find.text('年份不能为空'), findsOneWidget);
    expect(find.text('请先修正表单中的问题'), findsOneWidget);
  });
  // #endregion validation-test

  // #region new-exhibit-test
  testWidgets('adds an exhibit from valid form data', (tester) async {
    await tester.pumpWidget(const MicroGalleryEditorApp());
    await tester.tap(find.text('新建 · Ctrl+N'));
    await tester.pump();

    await tester.enterText(find.byKey(const Key('title-field')), '晨线标本');
    await tester.enterText(find.byKey(const Key('artist-field')), '陈弦');
    await tester.enterText(find.byKey(const Key('year-field')), '2026');
    await tester.enterText(find.byKey(const Key('medium-field')), '玻璃与光');
    await tester.enterText(
      find.byKey(const Key('note-field')),
      '记录清晨第一束光穿过不同厚度玻璃后的边缘。',
    );
    await tester.ensureVisible(find.text('保存展签'));
    await tester.tap(find.text('保存展签'));
    await tester.pump();

    expect(find.text('已新增“晨线标本”'), findsOneWidget);
    expect(find.text('4 件展品'), findsOneWidget);
  });
  // #endregion new-exhibit-test

  testWidgets('filters exhibit labels by title, artist, or medium', (
    tester,
  ) async {
    await tester.pumpWidget(const MicroGalleryEditorApp());

    await tester.enterText(find.byKey(const Key('filter-field')), '织物');
    await tester.pump();

    expect(find.text('1 件匹配'), findsOneWidget);
    expect(find.text('未寄出的地图'), findsOneWidget);
    expect(find.text('低声部'), findsNothing);
  });

  testWidgets('exposes selected exhibit and live status semantics', (
    tester,
  ) async {
    final semanticsHandle = tester.ensureSemantics();
    await tester.pumpWidget(const MicroGalleryEditorApp());

    final exhibit = tester.getSemantics(
      find.byWidgetPredicate(
        (widget) =>
            widget is Semantics &&
            widget.properties.label == '展品 潮汐练习，林岚，2024 年',
      ),
    );
    final status = tester.getSemantics(
      find.byWidgetPredicate(
        (widget) => widget is Semantics && widget.properties.liveRegion == true,
      ),
    );

    expect(exhibit.flagsCollection.isButton, isTrue);
    expect(exhibit.flagsCollection.isSelected, Tristate.isTrue);
    expect(status.flagsCollection.isLiveRegion, isTrue);
    semanticsHandle.dispose();
  });

  // #region keyboard-test
  testWidgets('Ctrl+N starts a new exhibit', (tester) async {
    await tester.pumpWidget(const MicroGalleryEditorApp());
    await tester.ensureVisible(find.byKey(const Key('title-field')));
    await tester.tap(find.byKey(const Key('title-field')));

    await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
    await tester.sendKeyEvent(LogicalKeyboardKey.keyN);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
    await tester.pump();

    expect(find.text('正在新建展品'), findsOneWidget);
    expect(find.text('标题不能为空'), findsNothing);
  });
  // #endregion keyboard-test

  // #region responsive-test
  testWidgets('fits a 320 by 720 viewport at 200 percent text scale', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 720);
    tester.view.devicePixelRatio = 1;
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(tester.view.reset);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

    await tester.pumpWidget(const MicroGalleryEditorApp());
    await tester.pumpAndSettle();

    expect(find.text('小型展览编辑器'), findsOneWidget);
    expect(find.text('潮汐练习'), findsWidgets);
    expect(tester.takeException(), isNull);
  });
  // #endregion responsive-test
}
