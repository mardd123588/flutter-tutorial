---
title: Widget、语义与视觉测试
description: 用 WidgetTester 控制帧与输入，验证 Finder、滚动、Semantics 合同和受控环境中的 golden 边界。
part: 7
order: 2
kind: concept
requires:
  - test.widget-smoke
  - a11y.semantics
provides:
  - test.widget
  - test.semantics
  - test.golden-boundary
status: verified
---

# Widget、语义与视觉测试

Widget 测试运行完整的 Widget 生命周期，但使用受控的测试环境。它擅长验证布局分支、输入、焦点、Semantics 和有限动画；不能替代浏览器历史、真实 Web 资产或平台界面。

## `WidgetTester` 是一套控制循环

每个 `testWidgets` 获得独立的 `WidgetTester`。`pumpWidget` 挂载根 Widget 并推进一帧；点击、输入和拖动只发送事件，状态改变后仍要明确推进时间。

```dart
testWidgets('筛选后显示结果数量', (tester) async {
  await tester.pumpWidget(const MaterialApp(home: ArchiveFilterBar()));

  await tester.tap(find.text('公开'));
  await tester.pump();

  expect(find.text('12 条记录'), findsOneWidget);
});
```

这个结构同时固定三件事：初始树、用户动作、动作后的帧。若组件包含一个 240ms 过渡，可以精确检查中点和终点：

```dart
await tester.tap(find.text('展开'));
await tester.pump();
await tester.pump(const Duration(milliseconds: 120));
expect(tester.getSize(find.byKey(const ValueKey('panel'))).height, inExclusiveRange(0, 240));
await tester.pump(const Duration(milliseconds: 120));
```

精确 `pump` 能发现动画晚一帧启动或时长变化。`pumpAndSettle()` 会每次推进一段时间，直到没有 scheduled frame；它至少 pump 一次并返回次数。持续动画、未停止的 ticker 或反复调度帧会超时，所以不能把它当作所有交互后的固定结尾。

## Finder 只看已经存在的 Element

`find.text`、`find.byKey`、`find.byType` 负责定位，Matcher 负责数量和内容。数量通过后，还要继续断言可用状态与结果：

```dart
final button = find.byKey(const ValueKey('apply-filter'));
expect(button, findsOneWidget);
expect(tester.widget<FilledButton>(button).onPressed, isNotNull);
```

Finder 默认跳过 offstage 子树和非当前 Route。`skipOffstage: false` 只能包含已经存在的 offstage Element，不能凭空创建 lazy 列表远端条目。

```dart
expect(find.byKey(const ValueKey('record-120')), findsNothing);
await tester.scrollUntilVisible(
  find.byKey(const ValueKey('record-120')),
  500,
  scrollable: find.byType(Scrollable).first,
);
expect(find.byKey(const ValueKey('record-120')), findsOneWidget);
```

这个测试同时验证了滚动和 lazy materialization。若只是把 `ListView.builder` 换成一次创建全部 child 的 `Column`，末项会在滚动前出现，测试会立即失败。

## Semantics 测试断言用户可感知合同

Semantics 测试关心 label、role、state、action 和阅读顺序，不固定自动分配的 node ID，也不快照整棵树。

```dart
final semantics = tester.ensureSemantics();
addTearDown(semantics.dispose);

final badge = find.byKey(const ValueKey('access-badge'));
expect(
  tester.getSemantics(badge),
  matchesSemantics(
    label: '开放状态：预约查阅',
    isEnabled: true,
  ),
);
```

`MergeSemantics` 可能把子节点合入祖先。此时 `getSemantics` 得到的是合并后的节点，测试应按组件最终暴露的合同断言，不要倒推内部 Widget 数量。

错误反馈至少要验证：

- 错误说明对辅助技术可见；
- 动态错误使用 live region；
- 焦点移动到错误摘要或首个错误字段；
- 有明确恢复动作；
- 键盘可以执行恢复动作。

`simulatedAccessibilityTraversal` 可以检查测试环境中的顺序和 action，但滚动边界与平台辅助技术仍有差异，发布前还需要真实浏览器抽查。

## Golden 比较像素，不证明功能

`matchesGoldenFile` 捕获 Finder 最近的 `RepaintBoundary`，再与 master PNG 做像素比较。它适合稳定构图、颜色、间距和自绘结果，不适合取代交互、状态或 Semantics 测试。

```dart
await expectLater(
  find.byKey(const ValueKey('archive-status-badge')),
  matchesGoldenFile('goldens/archive_status_badge.png'),
);
```

Golden 的输入也属于测试合同：

| 输入 | 固定方式 |
| --- | --- |
| viewport / DPR | 设置 `tester.view.physicalSize` 与 `devicePixelRatio` |
| fixture | 使用稳定 ID、顺序和数量 |
| locale / 方向 | 显式设置 locale 与 `TextDirection` |
| 文本缩放 | 显式设置 `TextScaler` |
| 动画 | 推进到确定时刻或关闭动画 |
| 字体 / SDK / OS | 在固定环境生成和比较 |

默认测试字体 Ahem 不呈现真实中文形态；自定义字体又可能随 OS、Flutter 版本和渲染器产生差异。本仓库让 golden 固定构图，中文实际字形另由 Chrome 截图检查。

更新基准使用：

```bash
flutter test --update-goldens
```

命令只负责重写图片。更新前必须查看 diff，确认变化来自批准的界面修改，而不是字体、DPR、环境或未归零的动画。

## 测试要清理自己改过的环境

```dart
tester.view.physicalSize = const Size(320, 720);
tester.view.devicePixelRatio = 1;
addTearDown(tester.view.resetPhysicalSize);
addTearDown(tester.view.resetDevicePixelRatio);
```

同样需要释放 `FocusNode`、controller、ProviderContainer、router 和 Semantics handle。测试之间共享 binding，但不应共享业务缓存或可写容器。

## 可验证任务

为“档案筛选条”写三条 Widget 测试：

1. 选择“预约”后结果数变化，按钮保持可用；
2. lazy 列表的最后一项滚动前不存在，滚动后出现；
3. “馆藏状态徽记”在固定 320×720、DPR 1 的环境中生成 golden，并用 Semantics 断言状态说明。

至少一条交互使用精确 `pump`，不要把所有动作都接到 `pumpAndSettle()`。

## 复习线索

- 交互方法发送输入，`pump` 才推进测试时间和帧。
- Finder 只能找到已经 materialize 的 Element。
- Semantics 测试关注 label、role、state、action 与顺序。
- Golden 固定像素边界；功能、URL 和辅助技术仍要单独验证。
- viewport、DPR、fixture、locale、文本缩放、动画、字体和 SDK 都会影响结果。

## 参考资料

- [An introduction to widget testing](https://docs.flutter.dev/cookbook/testing/widget/introduction)（查阅：2026-08-31）
- [Find widgets](https://docs.flutter.dev/cookbook/testing/widget/finders)（查阅：2026-08-31）
- [Handle scrolling](https://docs.flutter.dev/cookbook/testing/widget/scrolling)（查阅：2026-08-31）
- [`WidgetTester.pumpAndSettle`](https://api.flutter.dev/flutter/flutter_test/WidgetTester/pumpAndSettle.html)（查阅：2026-08-31）
- [`matchesSemantics`](https://api.flutter.dev/flutter/flutter_test/matchesSemantics.html)（查阅：2026-08-31）
- [`matchesGoldenFile`](https://api.flutter.dev/flutter/flutter_test/matchesGoldenFile.html)（查阅：2026-08-31）

