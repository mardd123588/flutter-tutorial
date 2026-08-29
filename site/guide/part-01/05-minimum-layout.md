---
title: 够用的基础布局
description: 用 box、Row、Column、Wrap、Padding 和 Expanded 组成第一批页面。
part: 1
order: 5
kind: concept
requires:
  - ui.composition
provides:
  - layout.box
  - layout.row-column
  - layout.spacing
status: verified
---

# 够用的基础布局

Flutter 布局的完整规则是“父级传约束，子级选择尺寸，父级决定位置”。这一章先学会组成普通页面；第二部分会用调试实验把约束算法讲透。

## 大多数 Widget 都在处理 box

`Padding` 给 child 周围留空间，`Align` 决定 child 在可用区域的位置，`SizedBox` 提供明确尺寸或间隔，`DecoratedBox` 绘制背景与边框。它们不负责业务状态，只改变一个矩形区域的约束、尺寸或绘制。

```dart
DecoratedBox(
  decoration: BoxDecoration(
    color: colors.surface,
    border: Border.all(color: colors.outline),
  ),
  child: const Padding(
    padding: EdgeInsets.all(20),
    child: Text('09:00 · 第一段专注'),
  ),
)
```

间距由 `Padding` 表达，视觉由 `DecoratedBox` 表达，内容仍是 `Text`。把三种责任塞进一个自定义绘制对象，只会让后续测试和适配更难。

## Row 与 Column 负责一个方向

`Row` 沿水平方向排列，`Column` 沿垂直方向排列。`mainAxisAlignment` 控制主轴，`crossAxisAlignment` 控制交叉轴。

```dart
Row(
  crossAxisAlignment: CrossAxisAlignment.center,
  children: [
    const SizedBox(width: 64, child: Text('09:00')),
    const SizedBox(width: 12),
    Expanded(child: Text(entry.title)),
    Text('${entry.durationMinutes} 分'),
  ],
)
```

`Expanded` 让标题占用 Row 分配后剩余的宽度。没有它时，三个文本会按自身理想宽度排列，窄屏上更容易溢出。

### Expanded 只能放在 Flex 子树中

`Expanded` 依赖 `Row`、`Column` 或 `Flex` 提供的布局数据。把它直接放进 `Padding`、`Stack` 或 `ListView` 会出现 `Incorrect use of ParentDataWidget`。错误信息里的 ParentData 说明：某个子 Widget 只在特定父布局协议中有意义。

## Wrap 处理“不知道是否放得下”

`Row` 默认只有一行。日期标签、操作按钮或筛选项可能在窄屏换行，用 `Wrap` 更合适：

```dart
Wrap(
  spacing: 12,
  runSpacing: 12,
  children: actions,
)
```

`spacing` 是同一行元素间距，`runSpacing` 是换行后的行间距。不要通过测量字符串长度猜是否换行，实际宽度还会受字体、语言和文本缩放影响。

## 列表项保持一个稳定骨架

“今日节奏板”的时段列表使用固定时间列、状态线、可伸缩标题和时长：

<<< ../../../examples/capstones/daily_rhythm_board/lib/src/rhythm_board.dart#rhythm-list{dart}

这一段第一次出现 `for` 生成多个 Widget，语义与上一章的集合 `for` 相同。每项的内部布局在 `_RhythmEntryButton` 中，列表本身只负责顺序和间距。

## 窄屏适配为什么提前出现

示例项目使用 `LayoutBuilder` 在宽屏显示两列、窄屏改为上下排列。`LayoutBuilder` 会把父级约束交给 builder；当前只把它当作“根据可用宽度选择两种组合”的工具。断点和响应式设计会在第五部分系统讲解。

这属于贯穿质量：读者还没完整学习响应式，但示例不能先养成只适配桌面的习惯。

## 错误案例：Column 里的无限高度

`Column` 放进滚动区域后，垂直方向可能没有有限上限。此时再给内部列表使用 `Expanded`，就会出现“非零 flex 但高度约束无界”的错误。

修复前先问：谁负责滚动？普通页面通常只保留一个主要滚动容器；内部内容按实际高度展开，或使用能获得有限高度的布局结构。不要连续添加 `shrinkWrap: true` 直到错误消失，它可能把惰性列表变成一次性构建全部内容。

## 可验证任务

实现一条时段记录，要求：

- 时间列固定宽度；
- 标题占用剩余空间；
- 时长靠右；
- 320 像素宽度下不出现黄色 overflow 条纹；
- 文本放大后，操作按钮用 Wrap 换行。

再故意把 `Expanded` 移到 `Padding` 外面，阅读完整错误并指出协议不匹配的位置。

## 复习线索

- Padding、Align、SizedBox 和 DecoratedBox 分别处理不同的 box 责任。
- Row 与 Column 只负责一个主方向。
- Expanded 依赖 Flex 协议，不是通用“占满剩余空间”。
- Wrap 让真实约束决定换行，不猜字符串宽度。

## 参考资料

- [Understanding constraints](https://docs.flutter.dev/ui/layout/constraints)（查阅：2026-08-29）
- [Layouts in Flutter](https://docs.flutter.dev/ui/layout)（查阅：2026-08-29）
- [Row class](https://api.flutter.dev/flutter/widgets/Row-class.html)（查阅：2026-08-29）
- [Wrap class](https://api.flutter.dev/flutter/widgets/Wrap-class.html)（查阅：2026-08-29）
