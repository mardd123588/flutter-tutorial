import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:micro_gallery_editor/src/gallery_editor.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('creates a new exhibit and places it on the wall', (
    tester,
  ) async {
    await tester.pumpWidget(const MicroGalleryEditorApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('新建 · Ctrl+N'));
    await tester.pump();
    await tester.enterText(find.byKey(const Key('title-field')), '晨线标本');
    await tester.enterText(find.byKey(const Key('artist-field')), '陈弦');
    await tester.enterText(find.byKey(const Key('year-field')), '二〇二六');
    await tester.enterText(find.byKey(const Key('medium-field')), '玻璃与光');
    await tester.enterText(
      find.byKey(const Key('note-field')),
      '记录清晨第一束光穿过不同厚度玻璃后的边缘。',
    );
    await tester.ensureVisible(find.text('保存展签'));
    await tester.tap(find.text('保存展签'));
    await tester.pump();

    expect(find.text('年份需为 1000—2099 的四位数字'), findsOneWidget);
    expect(find.text('请先修正表单中的问题'), findsOneWidget);

    await tester.enterText(find.byKey(const Key('year-field')), '2026');
    await tester.ensureVisible(find.text('保存展签'));
    await tester.tap(find.text('保存展签'));
    await tester.pumpAndSettle();

    expect(find.text('已新增“晨线标本”'), findsOneWidget);
    expect(find.text('4 件展品'), findsOneWidget);
  });
}
