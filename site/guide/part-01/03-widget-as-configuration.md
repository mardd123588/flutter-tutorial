---
title: Widget 是配置
description: 理解 Widget 的不可变性、组合方式和 const 实例复用。
part: 1
order: 3
kind: concept
requires:
  - dart.flutter-expressions
provides:
  - ui.widget
  - ui.widget-tree
  - ui.composition
  - ui.const-widget
status: verified
---

# Widget 是配置

Widget 不保存屏幕像素，也不是浏览器 DOM 节点。它是一份不可变配置：使用什么类型、带哪些参数、下面还有哪些子 Widget。

## 三层对象先分清

Flutter 运行时会同时维护三类对象：

- **Widget**：不可变配置，创建便宜，可以频繁替换。
- **Element**：Widget 在树中的长期位置，负责连接配置、状态和依赖。
- **RenderObject**：参与布局、绘制和命中测试的对象。

现在只需要牢牢记住第一条。Element 与 RenderObject 会在第七部分系统解释；提前知道它们存在，是为了避免把 Widget 当成屏幕上的实体。

当 `build` 再次执行时，代码会创建一棵新的 Widget tree。Flutter 不会因此销毁整个界面。它会用类型和位置匹配已有 Element，再把变化传到真正需要更新的地方。

## 应用入口也是 Widget 组合

“今日节奏板”的入口没有特殊语法：

<<< ../../../examples/capstones/daily_rhythm_board/lib/src/rhythm_board.dart#app{dart}

`MaterialApp` 提供主题、导航和本地化等应用级能力。`home` 接收另一个 Widget，形成树的下一层。`DailyRhythmApp` 自己不绘制任何东西，它负责组合并传递配置。

## 为什么字段通常是 `final`

Widget 实例创建后不应修改：

```dart
class TimeLabel extends StatelessWidget {
  const TimeLabel({required this.time, super.key});

  final String time;

  @override
  Widget build(BuildContext context) {
    return Text(time);
  }
}
```

时间变化时，不是执行 `label.time = '14:00'`，而是创建新的 `TimeLabel(time: '14:00')`。Element 比较新旧 Widget 后，把新配置交给底层对象。

不可变配置让一次构建的输入明确，也让开发者工具和测试更容易描述“当前界面应该是什么”。

## 组合比继承更常用

Flutter 组件通常通过小 Widget 组合，而不是建立很深的继承树：

```dart
class TimeLabel extends StatelessWidget {
  const TimeLabel({required this.time, required this.title, super.key});

  final String time;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(width: 64, child: Text(time)),
        const SizedBox(width: 12),
        Expanded(child: Text(title)),
      ],
    );
  }
}
```

`Row`、`SizedBox`、`Expanded` 和 `Text` 各自只处理一件事。自定义 Widget 给这组组合起了业务名称，也把输入缩到 `time` 和 `title`。

### 什么时候该拆组件

下面三个信号比“build 行数超过多少”更可靠：

- 一段界面有清楚的业务名称；
- 它需要独立输入、回调或测试；
- 父组件读起来已经看不出页面的主要结构。

只为少写几层缩进而拆私有方法，常常会丢掉 Widget 自己的 context、Key 和 const 能力。能表达独立界面责任时，优先拆成 Widget。

## `const` 复用的是配置

同一位置连续拿到完全相同的 const Widget 实例时，Flutter 可以停止继续比较这棵子树的 Widget 配置。它不会让 RenderObject 消失，也不会绕过父级 build。

因此，`const` 的正确顺序是：

1. 先让组件边界和数据流清楚；
2. 构造器允许且参数确实是常量时，加上 `const`；
3. 不为追求 const 把动态数据移到错误位置。

## 错误案例：在 Widget 上保存可变列表

```dart
class BadSchedule extends StatelessWidget {
  BadSchedule({super.key});

  final entries = <String>[];

  @override
  Widget build(BuildContext context) {
    return Text('${entries.length}');
  }
}
```

按钮若直接修改 `entries`，Flutter 不知道何时该重新构建；父级重建并创建新的 `BadSchedule` 时，旧列表还可能直接丢失。可变状态应由 State 或专门状态对象拥有，第三部分会完整讨论。

## 可验证任务

从一个包含标题、日期、五个时段和说明的大 `build` 开始：

1. 拆出一个有业务名称的时段组件；
2. 只向它传显示所需的数据和回调；
3. 给不会变化的 Widget 添加 `const`；
4. 写一条 Widget 测试，确认时段的时间和标题都能找到。

## 复习线索

- Widget 是不可变配置；Element 才代表树中的长期位置。
- 重建 Widget tree 不等于重画整个屏幕。
- 组件边界服务命名、输入和测试，不服务缩进数量。
- `const` 优化配置复用，不替代正确的数据流。

## 参考资料

- [Flutter architectural overview](https://docs.flutter.dev/resources/architectural-overview)（查阅：2026-08-29）
- [Widget class](https://api.flutter.dev/flutter/widgets/Widget-class.html)（查阅：2026-08-29）
- [StatelessWidget class](https://api.flutter.dev/flutter/widgets/StatelessWidget-class.html)（查阅：2026-08-29）
