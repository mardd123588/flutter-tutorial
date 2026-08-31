---
title: build 与 BuildContext
description: 理解构建时机、context 的树中位置和向上查找依赖的边界。
part: 1
order: 4
kind: concept
requires:
  - ui.widget-tree
provides:
  - runtime.build
  - runtime.build-context
  - runtime.inherited-dependency
status: verified
---

# `build` 与 `BuildContext`

`build` 回答的是：“给定当前配置、状态和上层依赖，这个位置现在应当返回什么 Widget？”它可以执行很多次，也不承诺只在你调用 `setState` 后执行。

## `build` 必须可以重复执行

窗口尺寸变化、主题变化、上层状态更新、路由切换和开发期 hot reload 都可能触发构建。安全的 `build` 有两个特征：

- 相同输入得到等价的 Widget 配置；
- 不在构建过程中发请求、写数据库、启动 timer 或修改外部状态。

下面的写法会在每次构建时重新请求：

```dart
@override
Widget build(BuildContext context) {
  loadSchedule();
  return const ScheduleView();
}
```

请求属于副作用。它需要放在生命周期、用户动作或状态层中，并明确处理重复、取消和错误。第三、四部分会分别处理生命周期和异步状态。

## Context 是一个 Element 的访问句柄

每个 `build` 参数里的 `BuildContext` 都对应当前 Widget 在 Element tree 中的位置。它不是全局应用对象，也不是随便换一个都等价的参数。

`Theme.of(context)` 会从这个位置向祖先查找最近的 Theme 数据：

<<< ../../../examples/capstones/daily_rhythm_board/lib/src/rhythm_board.dart#day-header{dart}

`_DayHeader` 不接收颜色和字号参数，而是通过自己的 context 读取上层 `MaterialApp` 提供的主题。这样主题发生变化时，依赖它的 Element 会收到更新。

同类 API 还有 `MediaQuery.of(context)`、`Navigator.of(context)` 和 `Scaffold.of(context)`。它们都在问“从这个位置往上，最近的对应祖先是谁”。

## 为什么 context 可能在错误位置

下面的代码试图用创建 `Scaffold` 的同一个 build context 打开 drawer：

```dart
Widget build(BuildContext context) {
  return Scaffold(
    drawer: const Drawer(),
    body: TextButton(
      onPressed: () {
        Scaffold.of(context).openDrawer();
      },
      child: const Text('打开菜单'),
    ),
  );
}
```

这里的 `context` 属于当前 Widget，它位于新 `Scaffold` 之上。查找只能向祖先走，不能看见刚返回的子树。

把需要新位置的部分拆成 Widget，通常是最清楚的修复：

```dart
class OpenDrawerButton extends StatelessWidget {
  const OpenDrawerButton({super.key});

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () {
        Scaffold.of(context).openDrawer();
      },
      child: const Text('打开菜单'),
    );
  }
}
```

`OpenDrawerButton` 的 context 位于 `Scaffold.body` 下面，向上可以找到 Scaffold。`Builder` 也能创建一个更低的 context，但独立组件往往同时改善命名和测试。

## 不要长期保存 context

context 代表一个会挂载、移动或卸载的树位置。把它放进全局变量或长生命周期的数据服务，会把界面生命周期泄漏到不该知道 Widget tree 的代码。

异步等待后使用 context 也要确认位置仍然挂载：

```dart
await save();
if (!context.mounted) return;
Navigator.of(context).pop();
```

这里先把 `pop` 理解为关闭当前页面。生命周期与 `mounted` 会在第三部分解释，页面栈会在[第五部分](/guide/part-05/01-navigator-page-stack)完整展开。

## 错误案例怎么判断

看到 `Scaffold.of() called with a context that does not contain a Scaffold`、`Navigator operation requested with a context that does not include a Navigator` 一类错误时，先画出发生调用的位置和目标祖先。重点不是“延迟一帧再试”，而是这个 context 在树上是否位于目标对象下面。

## 可验证任务

构造一个带 drawer 的 `Scaffold`，在同一 build context 中调用 `Scaffold.of(context).openDrawer()`，确认错误。然后分别用两种方式修复：

- 拆出 `OpenDrawerButton`；
- 使用 `Builder` 创建新的 context。

比较两种写法在命名、复用和测试上的差异。

## 复习线索

- `build` 可以频繁执行，里面不放副作用。
- BuildContext 代表 Element tree 中的具体位置。
- `of(context)` 通常从当前位置向祖先查找依赖。
- context 错误先看树位置，不靠延迟执行掩盖。

## 参考资料

- [BuildContext class](https://api.flutter.dev/flutter/widgets/BuildContext-class.html)（查阅：2026-08-29）
- [StatelessWidget.build](https://api.flutter.dev/flutter/widgets/StatelessWidget/build.html)（查阅：2026-08-29）
- [InheritedWidget class](https://api.flutter.dev/flutter/widgets/InheritedWidget-class.html)（查阅：2026-08-29）
- [Scaffold.of](https://api.flutter.dev/flutter/material/Scaffold/of.html)（查阅：2026-08-30）
