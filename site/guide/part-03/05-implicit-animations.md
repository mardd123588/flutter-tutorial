---
title: 隐式动画
description: 用目标值、Tween、Curve 和 duration 建立隐式动画模型，并测试中途值与减少动画分支。
part: 3
order: 5
kind: concept
requires:
  - state.set-state
  - layout.constraints
provides:
  - animation.implicit
  - animation.tween
  - animation.curve
status: verified
---

# 隐式动画

隐式动画适合“状态已经变了，界面平滑到新目标”这类任务。调用方只提供目标值、时长和曲线，Widget 在内部管理 controller。它减少生命周期代码，但仍要弄清插值对象、时间进度和布局成本。

## 四个量不要混在一起

一次隐式动画至少包含：

- 起点：当前正在显示的值；
- 终点：新的目标属性；
- `Tween<T>`：如何在起点与终点之间插值；
- `Curve`：如何把线性的 0～1 时间进度重新映射。

Tween 决定“24% 到 66% 之间是什么值”，Curve 决定“前半段走了多少进度”。`Curves.easeOutCubic` 会前快后慢，却不会改变终点。

隐式动画 Widget 首次构建时建立目标，之后目标变化才开始过渡。若动画进行到一半又收到新目标，它会从当前显示值继续，不会跳回上一段起点。

## 先用专用隐式 Widget

常用入口按变化类型选择：

| 变化 | Widget |
| --- | --- |
| 尺寸、内外边距、颜色、装饰、对齐 | `AnimatedContainer` |
| 透明度 | `AnimatedOpacity` |
| Stack 中的位置与尺寸 | `AnimatedPositioned` |
| 两个 Widget 间切换 | `AnimatedSwitcher` |
| 自定义数值或对象插值 | `TweenAnimationBuilder<T>` |

`AnimatedContainer` 只动画自己支持插值的属性，不会自动让 child 内部的任意值产生动画。湿度条需要把 0～1 数值映射成宽度比例，因此项目使用 `TweenAnimationBuilder<double>`：

<<< ../../../examples/capstones/plant_care_desk/lib/src/plant_care_desk.dart#implicit-moisture{dart}

`FractionallySizedBox.widthFactor` 读取动画值，文字直接显示最新湿度。读数先更新，条形再追到目标，用户能同时知道结果和变化方向。

## 动画哪个属性会影响成本

动画不是只看 Widget 名称，还要看每帧改变什么：

- 尺寸、padding、约束和 `AnimatedPositioned` 通常触发布局；
- 颜色、阴影等通常触发绘制；
- `FadeTransition`、`SlideTransition` 这类过渡可避免每帧重新计算业务 Widget 配置。

若 child 大小不变、只是移动，官方建议优先 `SlideTransition` 而不是 `AnimatedPositioned`，因为后者每帧会重新布局。完整渲染流水线与性能 trace 留到第七部分，本章先学会把“动什么属性”写清楚。

动画也不应补偿信息架构。按钮结果不明确、状态不可撤销时，加一段弹跳不会让流程更可靠。

## reduced motion 是功能分支

`MediaQuery.disableAnimationsOf(context)` 反映当前环境是否要求减少或关闭动画。项目对湿度条使用零时长，让它直接显示终态：

```dart
duration: disableAnimations
    ? Duration.zero
    : const Duration(milliseconds: 480),
```

减少动画不等于所有变化都必须消失。颜色、文字和状态仍应清楚更新；需要取消的是非必要位移、缩放、闪烁和循环。若动画承载顺序信息，可改成较弱的淡入或直接显示终态，并保证信息不依赖运动才能理解。

## 测试控制的是虚拟时间

Widget 测试不等待真实 480ms。触发状态变化后：

1. `pump()` 处理新状态，断言动画起点；
2. `pump(const Duration(milliseconds: 240))` 推进一半，断言中间值位于两端之间；
3. 推进到结束，断言终点。

项目同时测试隐式湿度和下一章的显式回执：

<<< ../../../examples/capstones/plant_care_desk/test/plant_care_desk_test.dart#animation-test{dart}

不要只使用 `pumpAndSettle()` 后断言终点。那只能证明最终值正确，无法发现动画从错误起点开始、曲线没生效或晚一帧启动。无限循环动画还会让 `pumpAndSettle` 超时。

reduced motion 单独覆盖：

<<< ../../../examples/capstones/plant_care_desk/test/plant_care_desk_test.dart#reduced-motion-test{dart}

这条测试通过平台可访问性特征生成 `MediaQueryData.disableAnimations`，验证自定义分支在一次 pump 后已经到终态。

## 可验证任务

做一个可调目标值的温度条：

1. 用 `TweenAnimationBuilder<double>` 把当前值映射到 0～1 宽度。
2. 切换线性、ease-in 和 ease-out 曲线，记录一半时长时的数值差异，终点必须相同。
3. 在动画中途再次修改目标，确认它从当前显示值继续。
4. 用 Widget 测试分别断言起点、中间值和终点。
5. 设置 `disableAnimations`，一次 pump 后必须显示终态，文字信息仍完整。

## 复习线索

- 隐式动画由调用方提供目标，Widget 内部管理 controller。
- Tween 决定值如何插值，Curve 决定时间进度如何映射。
- 动画尺寸和位置可能触发布局；只移动固定 child 时考虑 Transition。
- 动画测试要看起点、中点、终点，reduced motion 另走终态分支。

## 参考资料

- [Implicit animations](https://docs.flutter.dev/ui/animations/implicit-animations)（查阅：2026-08-30）
- [AnimatedContainer API](https://api.flutter.dev/flutter/widgets/AnimatedContainer-class.html)（查阅：2026-08-30）
- [TweenAnimationBuilder API](https://api.flutter.dev/flutter/widgets/TweenAnimationBuilder-class.html)（查阅：2026-08-30）
- [Tween API](https://api.flutter.dev/flutter/animation/Tween-class.html)（查阅：2026-08-30）
- [CurvedAnimation API](https://api.flutter.dev/flutter/animation/CurvedAnimation-class.html)（查阅：2026-08-30）
- [AnimatedPositioned API](https://api.flutter.dev/flutter/widgets/AnimatedPositioned-class.html)（查阅：2026-08-30）
- [WidgetTester.pump API](https://api.flutter.dev/flutter/flutter_test/WidgetTester/pump.html)（查阅：2026-08-30）
