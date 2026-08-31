---
title: 主题、资源与第一条测试
description: 建立 Material 3 主题，声明本地资源，并用 Widget 测试验证界面。
part: 1
order: 6
kind: concept
requires:
  - layout.box
  - ui.const-widget
provides:
  - theme.material3
  - asset.bundle
  - state.ephemeral-basic
  - test.widget-smoke
status: verified
---

# 主题、资源与第一条测试

页面能运行还不够。颜色和文字需要统一入口，本地资源需要由构建系统声明，最小交互也要有自动化证据。

## 主题是上层依赖

`MaterialApp.theme` 放入 `ThemeData`，下层通过 `Theme.of(context)` 读取：

<<< ../../../examples/capstones/daily_rhythm_board/lib/src/rhythm_board.dart#app{dart}

`ColorScheme.fromSeed` 生成一组具有角色含义的颜色，如 primary、surface 和 error。真实项目通常还会补充自己的设计令牌；不要让业务组件到处出现没有名称的十六进制颜色。

“今日节奏板”把沙色纸张、墨色、陶土色、日光色和水色放在文件顶部。首版项目规模小，这组私有常量足够；当主题需要深色模式、多个页面或动态切换时，再收进 `ThemeExtension` 或专门主题对象。

### 组件优先读取语义角色

```dart
final colors = Theme.of(context).colorScheme;

Text(
  '保存失败',
  style: TextStyle(color: colors.error),
)
```

`colors.error` 表达用途，`Colors.red` 只表达色相。主题切换或品牌调整时，语义角色更容易保持一致。

## 资源必须写进 pubspec

图片、JSON、字体等文件只有在 `pubspec.yaml` 声明后，才会进入 Flutter asset bundle：

```yaml
flutter:
  assets:
    - assets/images/sun-mark.png
    - assets/data/rhythm.json
```

YAML 缩进属于配置语义。`assets` 必须位于 `flutter` 下；路径相对 `pubspec.yaml`。声明目录时，新文件会随目录纳入，但仍要避免把源设计稿、超大原图或私密数据一起打包。

界面中使用：

```dart
Image.asset(
  'assets/images/sun-mark.png',
  width: 48,
  height: 48,
  semanticLabel: '日晷标记',
)
```

装饰图片应排除语义，承载信息的图片应提供 `semanticLabel`。图片缺失通常在运行时暴露，因此测试至少要泵出使用该资源的 Widget。

## 最小局部状态先够用

项目允许读者选择一个时段，页面只保存选中索引：

<<< ../../../examples/capstones/daily_rhythm_board/lib/src/rhythm_board.dart#local-state{dart}

`StatefulWidget` 的配置仍然不可变，可变字段放在对应 `State` 中。`setState` 先执行回调里的同步修改，再标记这个 State 需要重新构建。

这里不展开状态所有权、生命周期和重建范围。当前边界很窄：一个页面内的短期选择，离开页面后不需要保留。第三部分会用错误案例重新审视这段代码。

## 第一条 Widget 测试验证用户能看到什么

Widget 测试在测试环境中构建界面，通过 finder 找到 Widget，再模拟操作：

```dart
testWidgets('selecting an entry updates the detail', (tester) async {
  await tester.pumpWidget(const DailyRhythmApp());

  final button = find.widgetWithText(OutlinedButton, '午后专注');
  await tester.ensureVisible(button);
  await tester.tap(button);
  await tester.pump();

  expect(find.text('14:00 · 午后专注'), findsOneWidget);
});
```

`pumpWidget` 建立测试树，`tap` 发送交互，`pump` 让状态修改后的重建发生。测试不应该直接读取 `_selectedIndex`；它验证用户可观察的结果。

### 为什么不使用真实等待

Widget 测试控制一套虚拟时钟。需要推进动画时用 `pump(duration)`，等待所有已安排帧完成时用 `pumpAndSettle()`。`Future.delayed` 或系统 sleep 会让测试慢且不稳定。

### 找得到不等于点得到

finder 会在整棵测试树中找 Widget，即使它在滚动区域外。对屏幕外按钮直接 `tap` 会得到 hit-test 警告。先 `ensureVisible`，测试才能接近真实用户操作。

## 可验证任务

给时段按钮增加一个选中状态，并写测试覆盖：

- 默认选中第一段专注；
- 点击午后专注后，详情文字更新；
- 语义树能读出当前日晷对应的时间和标题；

这里先把语义树理解为辅助技术读取的控件描述；角色、状态和变化通知会在[手势、焦点、键盘与语义](/guide/part-02/06-gestures-focus-keyboard-semantics)中解释。
- 320×720 视口中的日晷、按钮和说明没有越出可用宽度。

## 复习线索

- ThemeData 是上层依赖，组件读取颜色角色而不是散落色值。
- 资源路径相对 pubspec，声明后才进入 asset bundle。
- `setState` 适合当前页面的最小临时状态，完整边界留到第三部分。
- Widget 测试验证可观察行为，滚动区域外的控件要先进入视口。

## 参考资料

- [Material 3 in Flutter](https://docs.flutter.dev/ui/design/material)（查阅：2026-08-29）
- [Use a custom font](https://docs.flutter.dev/cookbook/design/fonts)（查阅：2026-08-29）
- [Adding assets and images](https://docs.flutter.dev/ui/assets/assets-and-images)（查阅：2026-08-29）
- [Introduction to widget testing](https://docs.flutter.dev/cookbook/testing/widget/introduction)（查阅：2026-08-29）
