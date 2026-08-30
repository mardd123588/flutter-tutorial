---
title: Flex、Wrap、Stack 的选择
description: 分清一维空间分配、自动换行与局部重叠，并用票券排版器验证三种布局。
part: 2
order: 2
kind: focus-project
requires:
  - layout.constraints
provides:
  - layout.flex
  - layout.wrap
  - layout.stack
project: ticket-layout-studio
status: verified
---

# Flex、Wrap、Stack 的选择

先看内容关系，再选布局：一条主轴上的空间分配交给 Flex；数量受控、放不下就换行的内容交给 Wrap；确实需要重叠的局部交给 Stack。三者可以组合，但职责不要混在一起。

## Flex 先放普通子级，再分剩余空间

`Row` 和 `Column` 都是 `Flex`。它们布局时，先处理 flex factor 为 0 的子级，再计算主轴剩余空间，然后按 factor 分给 `Expanded` 或 `Flexible` 子级。

```dart
Row(
  children: const [
    SizedBox(width: 80, child: Text('票号')),
    Expanded(flex: 2, child: Text('滨岸馆 → 北码头')),
    Expanded(child: Text('GATE 04')),
  ],
)
```

两个 `Expanded` 分的是固定票号占位之后的剩余宽度，比例为 2:1。它们不会按文本原始宽度放大，也不会把整行总宽度切成三份。

`Expanded` 等价于 tight 的 `Flexible`：子级必须用完获配空间。`Flexible` 默认是 loose fit，子级最多使用获配空间，可以更小。两者仍然要求 Flex 的主轴有可计算的剩余空间。

`mainAxisAlignment` 只处理 Flex 布局完成后仍未使用的空间。若 `Expanded` 已用完剩余空间，`spaceBetween` 没有额外空间可分，界面看起来就不会变化。

::: warning `Expanded` 有父级协议
`Expanded` 必须位于 `Row`、`Column` 或 `Flex` 的后代路径上，中间不能隔着其他 RenderObjectWidget。`Incorrect use of ParentDataWidget` 表示这条父级协议被破坏了。
:::

## Wrap 根据真实尺寸建立多行

`Wrap` 逐个布局子级，当前 run 放不下时开始下一行或下一列。`spacing` 控制同一 run 的间距，`runSpacing` 控制 run 之间的间距。

票券标签由真实文字、字体和文本缩放共同决定宽度：

<<< ../../../examples/focus/ticket_layout_studio/lib/src/ticket_layout_studio.dart#wrap-tags{dart}

这里不按字符数判断换行，也不按手机型号写分支。中文、英文和 200% 文本都交给同一套约束计算。

Wrap 适合少量标签、筛选条件和操作按钮。它会布局所有子级，没有 lazy 构建，也不保证固定列数。需要稳定网格或大量数据时，下一章使用 `GridView`。

## Stack 只负责重叠

`Stack` 先布局非 positioned 子级，再布局 `Positioned` 子级。非 positioned 子级和父约束决定 Stack 的主要尺寸；角标这类 positioned 子级不会把父级撑大。

票券排版器把主票面放在正常约束流中，只让闸口牌越过票面上边缘：

<<< ../../../examples/focus/ticket_layout_studio/lib/src/ticket_layout_studio.dart#layout-switch{dart}

`clipBehavior: Clip.none` 允许角标画到 Stack 边界外，却不会扩大 Stack 的命中测试区域。边外部分可能看得见但点不到。需要交互的浮层应让可点击区域留在父级 bounds 内，或调整父级尺寸，不能只关闭裁剪。

整页绝对定位通常会让长文本、文本缩放和窄屏适配变得困难。Stack 留给徽标、角标、局部叠层和确有重叠关系的图形。

## 票券排版器如何组合三种布局

项目路径：`examples/focus/ticket_layout_studio`。它提供窄票、标准票和宽票三个预设，不提前引入尚未学习的表单输入。

票面宽度先受当前舞台约束限制：

<<< ../../../examples/focus/ticket_layout_studio/lib/src/ticket_data.dart#constraint-policy{dart}

`clamp` 保证目标宽度不会超过父级实际可用宽度。票面内部再根据最终宽度选择横向或纵向票根：横向使用 `Row + Expanded`，窄版改成 `Column`；标签一直由 Wrap 排版；闸口牌才使用 Stack。

舞台用自己的 `LayoutBuilder` 读取局部宽度，不依赖浏览器窗口值：

<<< ../../../examples/focus/ticket_layout_studio/lib/src/ticket_layout_studio.dart#constraint-stage{dart}

运行项目：

```powershell
flutter test examples/focus/ticket_layout_studio/test
cd examples/focus/ticket_layout_studio
flutter run -d chrome
```

项目维护一张确定性 golden。它用于发现排版回归，不负责证明键盘、语义或所有屏幕尺寸都正确：

<<< ../../../examples/focus/ticket_layout_studio/test/ticket_layout_studio_test.dart#golden-test{dart}

窄屏另有行为测试，防止“桌面 golden 没变化”掩盖移动宽度 overflow：

<<< ../../../examples/focus/ticket_layout_studio/test/ticket_layout_studio_test.dart#narrow-layout-test{dart}

## 项目完成检查

- [ ] 能说明 `Expanded(flex: 2)` 分配的是哪一段剩余空间。
- [ ] 能把一个放不下的操作组改成 Wrap，并在 200% 文本缩放下验证。
- [ ] 能指出票面中哪些子级决定 Stack 尺寸，哪些只是定位。
- [ ] 能解释为什么 `Clip.none` 不会扩大可点击范围。
- [ ] 能修改 430 像素切换条件，并用测试记录横向票根与纵向票根的边界。
- [ ] analyze、Unit、Widget、golden、Chrome 关键流程和 release Web build 全部通过。

## 复习线索

- Flex：普通子级先布局，非零 flex 子级按 factor 分剩余空间。
- Wrap：按真实子级尺寸换 run，不是 lazy 网格。
- Stack：positioned 子级不负责撑开父级；绘制边界和命中边界要分开看。
- [项目源码](https://github.com/mardd123588/flutter-tutorial/tree/main/examples/focus/ticket_layout_studio)

## 参考资料

- [Flex class](https://api.flutter.dev/flutter/widgets/Flex-class.html)（查阅：2026-08-30）
- [Expanded class](https://api.flutter.dev/flutter/widgets/Expanded-class.html)（查阅：2026-08-30）
- [Flexible class](https://api.flutter.dev/flutter/widgets/Flexible-class.html)（查阅：2026-08-30）
- [Wrap class](https://api.flutter.dev/flutter/widgets/Wrap-class.html)（查阅：2026-08-30）
- [Stack class](https://api.flutter.dev/flutter/widgets/Stack-class.html)（查阅：2026-08-30）
- [Positioned class](https://api.flutter.dev/flutter/widgets/Positioned-class.html)（查阅：2026-08-30）

