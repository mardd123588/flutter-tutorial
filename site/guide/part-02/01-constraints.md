---
title: 约束如何决定尺寸
description: 用父约束、子尺寸和父级定位解释尺寸失效、overflow 与 unbounded 错误。
part: 2
order: 1
kind: concept
requires:
  - layout.box
  - runtime.build-context
provides:
  - layout.constraints
  - layout.size-choice
  - layout.overflow-diagnosis
status: verified
---

# 约束如何决定尺寸

给 `Container` 写了 `width: 300`，最终宽度却铺满窗口；给 `Column` 里的列表加 `Expanded`，应用又直接报错。两种现象都要从父级传入的约束开始查，不能只盯着当前 Widget 的参数。

## 一次 box 布局发生三件事

Flutter 的 box 布局可以压成一句话：父级向下传约束，子级在约束内向上报告尺寸，父级再决定子级的位置。

`BoxConstraints` 在两个轴上各给一组范围：

```text
minWidth  <= width  <= maxWidth
minHeight <= height <= maxHeight
```

子级可以表达偏好，例如 `SizedBox(width: 300)`，但最终宽度必须落在父级给出的范围内。若父级给出 `minWidth == maxWidth == 600`，子级只能是 600；若范围是 0～600，子级才有机会选择 300。

父级还掌握位置。子级会知道自己的尺寸，却不知道自己最后位于屏幕的哪个坐标。`Align`、`Row`、`Stack` 等父级在拿到子级尺寸后再放置它们。

## tight、loose、bounded 分开判断

这几个词描述的不是同一件事，而且要按轴判断。

| 术语 | 判断 | 含义 |
| --- | --- | --- |
| tight | `min == max` | 这一轴只有一个合法尺寸 |
| loose | `min == 0` | 这一轴允许子级缩小到 0 |
| bounded | `max` 有限 | 这一轴存在有限上限 |
| unbounded | `max` 为无穷 | 这一轴没有有限上限 |

loose 不等于 unbounded。宽度范围 0～600 既 loose 又 bounded；宽度范围 0～∞ 才是 loose 且 unbounded。看到错误里的 `unbounded height` 时，只能推出高度上限无穷，不能顺手假定宽度也无界。

## 用 `LayoutBuilder` 看当前这一层

`LayoutBuilder` 把父级交给当前位置的约束传进 builder。它适合回答“这里实际有多宽”，不适合读取整个屏幕再猜当前组件能用多少空间。

```dart
LayoutBuilder(
  builder: (context, constraints) {
    final compact = constraints.maxWidth < 480;
    return compact ? const CompactPanel() : const WidePanel();
  },
)
```

断点来自组件的可用宽度。侧栏、分屏和嵌套面板都可能让组件宽度小于窗口宽度，所以这里不用 `MediaQuery.sizeOf(context).width` 代替局部约束。

## 三类错误要分开处理

### 有限空间里的 overflow

`A RenderFlex overflowed by 42 pixels` 表示 `Row` 或 `Column` 已经拿到有限空间，但子级总需求超过了它。黄色黑色条纹标出发生溢出的边。

以 `Row` 中的长文本为例：非 flex 子级会先按自身偏好布局，文本可能拿不到有限宽度。把文本放进 `Expanded`，是让 Flex 明确分配剩余宽度；如果内容不该被压缩，则应改成 `Wrap`、滚动或上下排列。

### 无界主轴里的 flex

`RenderFlex children have non-zero flex but incoming height constraints are unbounded` 常见于：

```text
SingleChildScrollView
└─ Column
   └─ Expanded
```

滚动区域允许内容在滚动轴继续增长，`Column` 因此没有有限高度；`Expanded` 又要求填满“剩余高度”。这个剩余量不存在。修复时要决定谁负责滚动、谁应有有限高度，而不是机械地把 `Expanded` 换成 `Flexible`。

### 无界高度里的 viewport

`Vertical viewport was given unbounded height` 表示 `ListView` 这类 viewport 想扩到可用的最大高度，上层却没有给出有限高度。在普通页面的 `Column` 中，列表若是主体，通常把列表放进 `Expanded`；若页头和列表需要一起滚动，第三章会把它们改成一个统一的滚动主体。

## 固定诊断顺序

遇到布局错误时按下面的顺序查：

1. 先确定出错轴：水平还是垂直。
2. 找到最先出现异常的 RenderFlex 或 viewport，不从最外层页面猜。
3. 判断这一轴的上限是否有限。
4. 列出固定尺寸、非 flex 子级、长文本和滚动容器。
5. 根据内容意图选择压缩、换行、滚动或重组。
6. 用窄屏和 200% 文本再测一次，避免只修当前字符串。

`shrinkWrap: true`、`Expanded` 和 `SingleChildScrollView` 都不是通用修复。每次添加它们前，都应能说清它改变了哪一层的尺寸协议。

## 可验证任务

建立一个约束探针页面，完成三次实验：

1. 外层给 600 像素 tight 宽度，内层请求 300，记录最终宽度；再把外层改成 0～600 的 loose 约束。
2. 在 320 像素宽的 `Row` 中放一段长文本，先复现 overflow，再用 `Expanded` 修复。
3. 复现 `SingleChildScrollView > Column > Expanded` 的无界主轴错误，去掉错误结构，并写一句话说明最终由谁负责滚动。

完成标准不是“错误消失”，而是能说出每次修改改变了哪一层约束。

## 复习线索

- `BoxConstraints` 的四个值，以及 tight、loose、bounded、unbounded 的区别。
- `A RenderFlex overflowed`、`non-zero flex ... unbounded`、`Vertical viewport was given unbounded height` 对应三类问题。
- `LayoutBuilder` 读取当前组件的父约束，不读取抽象的“设备宽度”。

## 参考资料

- [Understanding constraints](https://docs.flutter.dev/ui/layout/constraints)（查阅：2026-08-30）
- [BoxConstraints class](https://api.flutter.dev/flutter/rendering/BoxConstraints-class.html)（查阅：2026-08-30）
- [LayoutBuilder class](https://api.flutter.dev/flutter/widgets/LayoutBuilder-class.html)（查阅：2026-08-30）
- [SingleChildScrollView class](https://api.flutter.dev/flutter/widgets/SingleChildScrollView-class.html)（查阅：2026-08-30）

