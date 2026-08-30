---
title: 显式动画与过渡
description: 管理 AnimationController、Ticker 和 Transition 生命周期，组合多条动画并尊重减少动画偏好。
part: 3
order: 6
kind: concept
requires:
  - state.lifecycle
  - animation.implicit
provides:
  - animation.controller
  - animation.transition
  - animation.reduced-motion
status: verified
---

# 显式动画与过渡

需要主动开始、反向、停止，或让多个属性共享一条时间轴时，使用 `AnimationController`。显式动画多出的能力来自一个有生命周期的资源：controller 会驱动帧更新，所以创建、触发、依赖变化和释放都要安排清楚。

## controller 是可控制的 0～1 时间轴

默认 `AnimationController` 在 `lowerBound` 到 `upperBound` 之间产生值，通常是 0～1。`duration` 决定 `forward()` 走完整段所需时间；`reverseDuration` 可以单独设置反向时间。

controller 需要 `TickerProvider`：

```dart
class _ReceiptState extends State<Receipt>
    with SingleTickerProviderStateMixin {
  late final AnimationController controller;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 360),
    )..forward();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}
```

Ticker 在屏幕刷新时通知 controller 计算新值；`vsync` 让不应活动的子树停止产生无意义帧。一个 State 只有一个 controller 时用 `SingleTickerProviderStateMixin`，多个 controller 才改用 `TickerProviderStateMixin`。

## 同一时间轴可以派生多条动画

controller 本身只是进度。Tween 把进度映射成具体类型，Curve 调整节奏：

```dart
final opacity = CurvedAnimation(
  parent: controller,
  curve: Curves.easeOut,
);

final offset = Tween<Offset>(
  begin: const Offset(0, 0.18),
  end: Offset.zero,
).animate(
  CurvedAnimation(parent: controller, curve: Curves.easeOutCubic),
);
```

`FadeTransition` 读取 opacity，`SlideTransition` 读取 Offset。两者不会要求业务层在每一帧调用 `setState`：

```dart
FadeTransition(
  opacity: opacity,
  child: SlideTransition(position: offset, child: receipt),
)
```

需要自定义构建时可用 `AnimatedBuilder`。不依赖动画的复杂子树放进 `child` 参数，builder 只包需要随值变化的那一层。

## 触发条件属于生命周期

植物项目的回执在首次出现时播放；父级传入新 message 后，同一个 State 继续存在，`didUpdateWidget` 比较旧新消息并从 0 重新播放：

<<< ../../../examples/capstones/plant_care_desk/lib/src/plant_care_desk.dart#explicit-receipt{dart}

这里不能只在 `initState` 播放。浇水和撤销都会更新 Widget 配置，但不会创建新的回执 State；漏掉 `didUpdateWidget` 后，第一条消息有动画，后续消息只会静态替换。

反过来，也不要在每次 `build` 调用 `forward(from: 0)`。父级任意重建都会重启动画，动画自己产生的帧又可能继续触发构建，结果无法稳定到终点。

若 controller 来自 `widget.controller`，则要使用第二章的三段式订阅协议；当前项目由回执 State 自己创建，因此只需 init、响应 message 更新和 dispose。

## 多阶段动画使用 Interval

多个属性需要依次发生时，可以共用一个 controller，并给每条曲线分配区间：

```dart
final panel = CurvedAnimation(
  parent: controller,
  curve: const Interval(0, 0.65, curve: Curves.easeOut),
);
final label = CurvedAnimation(
  parent: controller,
  curve: const Interval(0.45, 1, curve: Curves.easeOut),
);
```

这叫 staggered animation：0～65% 展开面板，45～100% 淡入文字，中间有重叠。不要为了“显式动画”给每个属性创建一个 controller；只有时间轴必须独立控制时才拆开。

## 减少动画时直接呈现结果

`AnimationController.animationBehavior` 会影响系统要求禁用动画时的控制器行为，但产品自己的运动语义仍要主动处理。植物项目读取 `MediaQuery.disableAnimationsOf(context)`：

- 湿度隐式动画时长变为 0；
- 回执 controller 直接设为 1；
- build 不再创建 `FadeTransition` 和 `SlideTransition`，直接返回内容。

这样状态消息、撤销和语义 live region 都保留，只有非必要运动消失。不要简单把所有动画改成 1ms；对敏感用户来说，快速位移仍是位移。

## 精确推进测试时间

显式动画也要测试起点、中间值和终点。触发新消息后一次 `pump()`，opacity 应回到 0；推进一半时位于 0～1；结束后为 1。项目测试与隐式动画放在同一命名区域，便于对照两种控制方式：

<<< ../../../examples/capstones/plant_care_desk/test/plant_care_desk_test.dart#animation-test{dart}

如果动画监听 `AnimationStatus` 并在终点反向，测试要精确推进计划中的周期，不要等待 settle。无限循环本来就没有“稳定帧”。

## 可验证任务

做一个保存回执，完成下面的控制：

1. 一个 controller 同时驱动淡入和轻微上移。
2. 首次挂载播放；父级替换消息时用 `didUpdateWidget` 重播；普通 build 不重播。
3. 使用 `Interval` 让图标先出现、文字稍后出现。
4. dispose 后不再有 ticker 或监听回调。
5. reduced motion 下直接显示终态，不创建位移过渡。
6. 测试 0%、50%、100% 三个进度，以及两条 Interval 在 30% 时的不同状态。

## 复习线索

- AnimationController 是需要 TickerProvider 和 dispose 的时间轴资源。
- Tween 映射类型，Curve 调整进度，Transition 消费 Animation。
- 新配置触发重播放在 `didUpdateWidget`，不能放进每次 build。
- 多阶段共享 controller + Interval；reduced motion 保留信息并去掉非必要运动。

## 参考资料

- [Animations overview](https://docs.flutter.dev/ui/animations/overview)（查阅：2026-08-30）
- [Animations tutorial](https://docs.flutter.dev/ui/animations/tutorial)（查阅：2026-08-30）
- [AnimationController API](https://api.flutter.dev/flutter/animation/AnimationController-class.html)（查阅：2026-08-30）
- [AnimatedBuilder API](https://api.flutter.dev/flutter/widgets/AnimatedBuilder-class.html)（查阅：2026-08-30）
- [FadeTransition API](https://api.flutter.dev/flutter/widgets/FadeTransition-class.html)（查阅：2026-08-30）
- [SlideTransition API](https://api.flutter.dev/flutter/widgets/SlideTransition-class.html)（查阅：2026-08-30）
- [Staggered animations](https://docs.flutter.dev/ui/animations/staggered-animations)（查阅：2026-08-30）
- [MediaQueryData.disableAnimations API](https://api.flutter.dev/flutter/widgets/MediaQueryData/disableAnimations.html)（查阅：2026-08-30）
