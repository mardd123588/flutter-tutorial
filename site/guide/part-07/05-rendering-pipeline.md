---
title: 渲染流水线与自绘边界
description: 区分 build、layout、compositing、paint 与 semantics，正确使用 CustomPainter、Listenable 和 RepaintBoundary。
part: 7
order: 5
kind: concept
requires:
  - internals.widget-element-renderobject
  - layout.constraints
provides:
  - render.pipeline
  - render.repaint-boundary
  - debug.layout-paint
status: verified
---

# 渲染流水线与自绘边界

界面更新不只有 build 和 paint。Widget / Element 先更新配置，RenderObject 流水线再按需要处理 layout、compositing bits、paint 和 semantics。每个阶段有自己的脏标记和传播边界，诊断时不能混成“整页重绘”。

## 一帧里的主要阶段

```text
事件 / 动画 / 异步完成
        ↓
build：更新 Widget 与 Element
        ↓
layout：constraints 向下，size 向上，父级定位子级
        ↓
compositing bits：决定 layer 需求
        ↓
paint：记录绘制命令
        ↓
composite / raster：组合 layer 并栅格化
        ↓
semantics：更新辅助技术使用的树
```

`PipelineOwner` 维护脏 RenderObject 并 flush 各阶段。某次 build 只改颜色，通常无需重新 layout；文本长度变化可能让 RenderParagraph 需要 layout；焦点或 label 变化可能只更新 semantics。

## 三种脏标记影响不同

| 调用 | 表示 | 传播方向 |
| --- | --- | --- |
| `markNeedsLayout()` | 几何可能变化 | 向 relayout boundary 传播 |
| `markNeedsPaint()` | 像素可能变化 | 向最近 repaint boundary 传播 |
| `markNeedsSemanticsUpdate()` | 辅助技术合同变化 | 通知 semantics owner 更新 |

布局仍遵守第二部分的约束模型：父级传 `Constraints`，子级选择 `Size`，父级再决定 Offset。Relayout boundary 能阻止无关祖先重复布局，但 intrinsic 测量、复杂 baseline 或需要先看所有子项的布局可能增加 pass。

## `CustomPainter` 画连续几何

年代尺、曲线、装饰和大量连续几何适合 Canvas。按钮、正文、表单与主要语义仍使用普通 Widget。

```dart
class YearScalePainter extends CustomPainter {
  const YearScalePainter({required this.progress});

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final track = Paint()..color = const Color(0xFFB7AEA0);
    final active = Paint()..color = const Color(0xFF2F6F7A);
    canvas.drawLine(Offset.zero, Offset(size.width, 0), track);
    canvas.drawLine(Offset.zero, Offset(size.width * progress, 0), active);
  }

  @override
  bool shouldRepaint(YearScalePainter oldDelegate) =>
      oldDelegate.progress != progress;
}
```

绘制要留在传入的 `Size` 内；需要裁剪时显式 `clipRect`，改变 Canvas 状态时成对使用 `save()` / `restore()`。`saveLayer()` 会建立离屏缓冲，只在 blend mode 正确性需要时使用，并用 trace 验证成本。

## `repaint: Listenable` 绕开 build

动画或滚动只改变绘制参数时，可以把 `Listenable` 传给 painter：

```dart
class CursorPainter extends CustomPainter {
  CursorPainter(this.animation) : super(repaint: animation);

  final Animation<double> animation;

  @override
  void paint(Canvas canvas, Size size) {
    final x = size.width * animation.value;
    canvas.drawCircle(Offset(x, size.height / 2), 6, Paint());
  }

  @override
  bool shouldRepaint(CursorPainter oldDelegate) =>
      oldDelegate.animation != animation;
}
```

Listenable 发通知时，`RenderCustomPaint` 可以直接请求 paint，不必先让父 Widget `setState`。这减少的是 build 路径，不保证 paint 本身便宜。

`shouldRepaint` 比较新旧 delegate。返回 `false` 只允许框架跳过“delegate 更新”引起的重绘；size 改变、祖先或后代重绘时，`paint` 仍可能执行。

## 自绘语义不会从像素里自动出现

Canvas 上的线和矩形没有业务名称。若自绘内容本身可交互或承载信息，优先叠加普通 Widget；确实需要 painter 提供语义时，实现 `semanticsBuilder`，返回带 rect、label 和 TextDirection 的 `CustomPainterSemantics`。

年代尺可以让普通 `Slider` 或按钮负责输入，painter 只画轨道；屏幕阅读器因此得到标准 action，测试也不用自己模拟 Canvas 命中。

## `RepaintBoundary` 隔离 paint，不是通用加速器

`RepaintBoundary` 让子树拥有独立 layer。边界一侧频繁变化、另一侧静态且绘制昂贵时，隔离可能减少工作；两侧总是一起变化时，只会增加 layer、合成和可能的 raster cache 成本。

列表 delegate 通常已经给子项添加 repaint boundary。不要在每张卡片和缩略图外再套多层边界。判断步骤是：

1. 用 repaint rainbow 或 Track paints 找到变化范围；
2. 定义固定 workload；
3. 在合理边界加或移除 `RepaintBoundary`；
4. 用 profile trace 比较相同操作；
5. 没有改善就撤回。

## 调试开关一次只回答一个问题

| 开关 | 回答 |
| --- | --- |
| `debugPaintSizeEnabled` | constraints、padding、baseline 是否符合预期 |
| `debugRepaintRainbowEnabled` | 哪些区域反复 paint |
| `debugProfileBuildsEnabledUserWidgets` | 哪些用户 Widget 在 build |
| `debugProfileLayoutsEnabled` | 哪些 RenderObject 在 layout |
| `debugProfilePaintsEnabled` | 哪些 RenderObject 在 paint |

开关会改变输出和 tracing 成本。先无 flag 记录 baseline，再只打开一个相关 flag 诊断；不要同时全开后比较绝对帧时间。

## 可验证任务

实现一条可更新的“馆藏年代尺”：普通按钮切换年代，`CustomPainter` 画轨道与进度，按钮和当前年代用 Widget / Semantics 表达。要求：

1. `shouldRepaint` 只比较实际绘制输入；
2. 写测试证明相同输入不要求重绘、变化输入要求重绘；
3. 用 repaint rainbow 观察按钮区域与轨道区域；
4. 分别开启 build 和 paint tracing，解释两份记录的差别；
5. 不把按钮和文字画进 Canvas。

## 复习线索

- build、layout、paint、composite、semantics 是不同阶段。
- 颜色变化不一定触发布局，文字和尺寸变化可能触发。
- `repaint: Listenable` 可以让绘制更新绕开 Widget build。
- `shouldRepaint: false` 不保证 `paint` 永不执行。
- Canvas 不自动提供业务语义。
- `RepaintBoundary` 要靠变化不对称和 profile 证据证明收益。

## 参考资料

- [`PipelineOwner`](https://api.flutter.dev/flutter/rendering/PipelineOwner-class.html)（查阅：2026-08-31）
- [`CustomPainter`](https://api.flutter.dev/flutter/rendering/CustomPainter-class.html)（查阅：2026-08-31）
- [`CustomPaint`](https://api.flutter.dev/flutter/widgets/CustomPaint-class.html)（查阅：2026-08-31）
- [`RepaintBoundary`](https://api.flutter.dev/flutter/widgets/RepaintBoundary-class.html)（查阅：2026-08-31）
- [Performance best practices](https://docs.flutter.dev/perf/best-practices)（查阅：2026-08-31）

