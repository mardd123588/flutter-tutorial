---
title: Flutter 代码里的 Dart
description: 复习 const、命名参数、回调和集合元素在 Widget tree 中的作用。
part: 1
order: 2
kind: concept
requires:
  - toolchain.flutter
provides:
  - dart.flutter-expressions
  - dart.const
  - dart.callbacks
status: verified
---

# Flutter 代码里的 Dart

你不需要重学 Dart。这里补四类在 Flutter 代码里密集出现、又会直接影响 Widget tree 的写法：`const`、命名参数、回调和集合元素。

## `const` 表示可以在编译期确定

```dart
const Text('今日节奏板')
```

`Text` 的构造器允许创建常量实例，参数也都是常量，因此整个对象能在编译期创建。Flutter 可以复用同一个 Widget 实例，少做一部分对象创建和子树比较。

`const` 不是“这个 Widget 永远不重建”。父组件仍可能再次执行 `build`，只是遇到同一个常量 Widget 实例时，框架更容易确认这部分配置没有变化。

下面的代码不能是 `const`，因为 `title` 到运行时才知道：

```dart
Widget buildTitle(String title) {
  return Text(title);
}
```

不要为了增加 `const` 而把本应变化的数据写死。能由编译器确认时使用，不能确认时保留普通构造。

## 命名参数让树形代码可读

Flutter 构造器大量使用命名参数：

```dart
Padding(
  padding: const EdgeInsets.all(16),
  child: Text(title),
)
```

阅读时先找 `child` 或 `children`，它们决定 Widget tree 的结构；`padding`、`alignment`、`style` 等参数描述当前节点的配置。

自定义组件也应把必需输入写成 `required`：

```dart
class RhythmLabel extends StatelessWidget {
  const RhythmLabel({
    required this.time,
    required this.title,
    super.key,
  });

  final String time;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Text('$time · $title');
  }
}
```

`super.key` 把参数直接转交给父类构造器。Key 的行为会在第三部分解释；现在只要保留这个常见入口。

## 回调把动作交回拥有者

组件可以显示数据，但不一定拥有修改数据的权力。回调负责把动作传出去：

```dart
class RhythmButton extends StatelessWidget {
  const RhythmButton({
    required this.title,
    required this.onPressed,
    super.key,
  });

  final String title;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      child: Text(title),
    );
  }
}
```

`VoidCallback` 等价于 `void Function()`。按钮只知道“被按下时调用它”，至于选中哪个时段、是否写入存储，由外层决定。

需要参数时，常见类型是 `ValueChanged<T>`：

```dart
final ValueChanged<int> onSelected;

onPressed: () => onSelected(index),
```

匿名函数 `() => onSelected(index)` 延迟执行。若写成 `onPressed: onSelected(index)`，你传入的是函数调用结果，代码会在构建时执行。

## 集合元素直接描述界面条件

Widget 的 `children` 是普通 Dart 集合，可以使用 `if`、`for` 和展开运算符：

```dart
Column(
  children: [
    const Text('今日安排'),
    if (showHint) const Text('先完成最重要的一项'),
    for (final entry in entries) Text(entry.title),
    ...extraActions,
  ],
)
```

这段代码没有“向 Column 添加子节点”的步骤。每次构建都会根据当前数据产生一份新的 children 列表，Flutter 再比较新旧配置。

### 常见误读

```dart
children: entries.map((entry) => Text(entry.title))
```

`map` 返回 `Iterable<Widget>`，而许多 `children` 参数需要 `List<Widget>`。API 要求列表时补 `.toList()`；使用集合 `for` 往往更直接，也少一层嵌套。

## 可验证任务

把下面的命令式描述改成一个 Widget 列表：

- 固定显示标题；
- `showBreak` 为 true 时显示休息提示；
- 为每个 `RhythmEntry` 显示时间和标题；
- 最后展开一组外部传入的操作按钮。

完成后解释每个元素是在构建时立即求值，还是等用户操作后才调用。

## 复习线索

- `const` 依赖编译期常量，不等于永不重建。
- 命名参数描述配置，`child` 与 `children` 暴露树结构。
- 回调传递动作，不把状态修改硬塞进显示组件。
- 集合 `if`、`for` 和 `...` 让界面条件留在一份声明里。

## 参考资料

- [Dart constructors](https://dart.dev/language/constructors)（查阅：2026-08-29）
- [Dart functions](https://dart.dev/language/functions)（查阅：2026-08-29）
- [Dart collection operators](https://dart.dev/language/collections)（查阅：2026-08-29）
- [Flutter Widget class](https://api.flutter.dev/flutter/widgets/Widget-class.html)（查阅：2026-08-29）
