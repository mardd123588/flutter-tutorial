---
title: 可复用组件的接口
description: 用数据、回调、slot 和主题令牌建立稳定、可测试的组件边界。
part: 2
order: 4
kind: concept
requires:
  - ui.composition
  - theme.material3
provides:
  - component.api
  - component.slot
  - theme.tokens
status: verified
---

# 可复用组件的接口

重复界面不难抽成 Widget，难的是决定调用方应该知道什么。好的组件接口保留业务语义，把 `Row`、间距、边框和内部状态留在组件内部。

## 数据描述显示什么，回调描述发生了什么

一个受控组件通常接收当前数据和事件回调：

<<< ../../../examples/capstones/micro_gallery_editor/lib/src/gallery_editor.dart#exhibit-label-api{dart}

调用方传入 `Exhibit`、是否选中和 `onTap`。组件负责内部排版、点击反馈和选中样式；它不直接修改展品列表，也不要求调用方传进某个内部 `Row`。

常见接口可以按这个方向命名：

```dart
const ExhibitLabel({
  required Exhibit exhibit,
  required bool selected,
  required VoidCallback onPressed,
  super.key,
});
```

- 数据参数回答“显示什么”。
- `VoidCallback` 表示事件不携带数据。
- `ValueChanged<T>` 表示事件带回一个新值。
- 可空回调若代表 disabled，要和 Flutter 按钮的习惯保持一致，并在组件合同中写清楚。

不要把 `BuildContext` 作为普通参数向下传。子组件已经有自己的 context；若它需要主题或本地化，应从自己的树位置读取。

## 状态放在最小共同拥有者

多个组件需要共享“当前选中展品”时，由它们上方最近的共同父级持有。父级把 `selected` 向下传，把 `onPressed` 接回来，再更新状态。

组件可以保留纯内部的瞬时状态，例如 hover 高亮或展开动画进度。会影响其他组件、需要保存或需要由父级控制的状态应上移。第三部分会进一步讨论状态所有权；这里先用调用接口判断边界。

一个实用检查是：父级能否从参数和回调看懂用户流程？如果只能看到 `onTap: () => panelState = 3`、`isBlue: true`，接口还停留在内部实现；`onSelectExhibit`、`selected` 更接近页面语义。

## slot 允许注入内容，不泄漏布局

当调用方需要提供一段界面时，用 Widget 参数形成 slot：

```dart
class SectionFrame extends StatelessWidget {
  const SectionFrame({
    required this.title,
    required this.child,
    this.actions = const [],
    super.key,
  });

  final String title;
  final Widget child;
  final List<Widget> actions;

  // build 仍由 SectionFrame 决定标题、操作区和正文的排列。
}
```

`child`、`leading`、`actions` 和 builder 都是常见 slot。调用方提供内容，组件保留间距、语义顺序和主题边界。

若每个调用处都要传入十几个零散 Widget 才能拼出正常界面，组件很可能没有稳定语义。此时应缩小职责，或给几个明确的业务变体，而不是继续扩展“万能卡片”。

## 默认值只给自然默认

`actions = const []` 有清楚含义：没有额外操作。展品标题没有自然默认，应该 `required`。会改变业务行为的回调也不应藏在无声默认中。

构造器保持命名参数，`key` 放前或沿用项目惯例，`child` / `children` 通常放在最后，调用处更接近 Flutter 自带组件的阅读方式。

## 视觉参数先回到主题令牌

颜色、文字、间距和形状若在多个组件重复出现，先问它们是否属于同一个视觉角色：

- Material 角色使用 `ColorScheme` 和 `TextTheme`。
- 项目自有、需要随主题变化的角色使用 `ThemeExtension`。
- 只在一个局部出现的差异，可以保留为组件私有常量。

不要把 `backgroundColor`、`borderColor`、`titleSize`、`cornerRadius` 全部暴露成构造参数。那会让每个调用处重新设计一遍组件，主题也失去统一入口。

`ThemeExtension` 适合“展墙金属色”“票券扫描色”这类标准 `ColorScheme` 没有的项目角色。它需要实现 `copyWith` 与 `lerp`，这样主题切换和动画才能得到完整值。当前章节先建立令牌边界，主题切换在第五部分展开。

## 资源所有权也属于接口

组件自己创建 `TextEditingController`、`FocusNode` 或 `AnimationController`，就负责在 `dispose` 中释放。若这些对象由构造器传入，调用方拥有生命周期，组件不能私自 dispose。

这条规则应从接口一眼看出。一个同时支持“内部创建”和“外部传入”的组件，需要明确两种路径如何互斥，以及数据更新时谁负责同步；基础组件没有这种需求时，不要提前增加双重所有权。

## 测试组件合同，不锁死内部布局

组件测试优先验证：

- 数据是否显示；
- selected、disabled、error 等状态是否可观察；
- 触发操作后回调是否收到正确数据；
- 语义名称和角色是否存在；
- 长文本与文本缩放下是否仍可用。

除非内部几何就是组件合同，不要断言第几个 `Padding` 等于多少。否则把 `Row` 换成 `Wrap` 也会破坏测试，即使用户看到的行为完全相同。

## 可验证任务

从两段复制粘贴的展品卡开始，完成一次重构：

1. 先列出稳定数据、用户事件和主题角色。
2. 把内部颜色、Padding 和 Row 留在组件中，不作为参数暴露。
3. 为可选操作设计一个 `actions` slot。
4. 写 Widget 测试，验证标题、选中语义和选择回调。
5. 把内部 Row 改成 Wrap，确认合同测试不需要修改。

## 复习线索

- 数据参数、事件回调和 slot 的分工。
- 受控组件与最小共同状态所有者。
- `ColorScheme`、`TextTheme`、`ThemeExtension` 的令牌边界。
- 内部创建的资源由组件释放，外部传入的资源由调用方释放。

## 参考资料

- [Flutter architectural overview](https://docs.flutter.dev/resources/architectural-overview)（查阅：2026-08-30）
- [StatelessWidget class](https://api.flutter.dev/flutter/widgets/StatelessWidget-class.html)（查阅：2026-08-30）
- [Add interactivity to your Flutter app](https://docs.flutter.dev/ui/interactivity)（查阅：2026-08-30）
- [Use themes to share colors and font styles](https://docs.flutter.dev/cookbook/design/themes)（查阅：2026-08-30）
- [ThemeExtension class](https://api.flutter.dev/flutter/material/ThemeExtension-class.html)（查阅：2026-08-30）

