---
title: Listenable、ChangeNotifier 与 InheritedWidget
description: 分开理解变化通知、子树传播与对象所有权，并用 InheritedNotifier 组合一个窄作用域状态入口。
part: 3
order: 4
kind: concept
requires:
  - state.ownership
  - runtime.inherited-dependency
provides:
  - state.listenable
  - state.change-notifier
  - state.inherited
status: verified
---

# Listenable、ChangeNotifier 与 InheritedWidget

这三个 API 经常一起出现，却解决不同问题。`Listenable` 发出变化信号，`ChangeNotifier` 管理可变状态和监听器，`InheritedWidget` 把数据放进 Widget tree。把它们混成一个“状态管理方案”，就会看不清谁创建对象、谁订阅、谁负责重建、谁最终释放。

## 先把三个职责拆开

| API | 负责 | 不负责 |
| --- | --- | --- |
| `Listenable` | 注册和移除无参数回调，通知“发生变化” | 保存什么状态、变化了哪个字段、放进哪棵树 |
| `ChangeNotifier` | 提供 Listenable 的通用实现，允许子类调用 `notifyListeners()` | 自动缩小重建范围、自动释放、业务不可变性 |
| `InheritedWidget` | 让后代按 BuildContext 建立依赖并在更新时重建 | 监听任意可变对象、决定对象所有权 |

`Animation`、`ValueNotifier` 和 `ChangeNotifier` 都实现 Listenable。监听回调没有 payload，消费者收到通知后重新读取当前值。

## `ChangeNotifier` 把写操作收进一个对象

植物照护台只保存源状态：完整植物列表、当前筛选和一次撤销快照；计数和可见列表按需派生：

<<< ../../../examples/capstones/plant_care_desk/lib/src/plant_data.dart#change-notifier-controller{dart}

修改方法先检查输入和无变化分支，完成一致的字段更新后再调用一次 `notifyListeners()`。不要每改一个字段就通知一次，否则消费者可能看到半完成状态，也会产生多余重建。

`ChangeNotifier.addListener` 是 O(1)，移除和分发为 O(N)。这不表示它不能用于常规页面，而是提醒我们不要把几千个无关消费者和高频变化塞进一个巨型 notifier。

只有所有者调用 `dispose`。消费者可以读取、调用公开动作或临时监听，不能因为“页面不用了”就销毁外部共享对象。

## `ListenableBuilder` 负责局部订阅

已有 Listenable 时，可以只重建一个区域：

```dart
ListenableBuilder(
  listenable: controller,
  child: const ExpensiveLegend(),
  builder: (context, child) {
    return Column(
      children: [
        Text('${controller.needsCareCount} 项待照护'),
        child!,
      ],
    );
  },
)
```

`child` 在 builder 外建立，不依赖通知的稳定子树可直接复用。它不是必须优化项；只有实际重建区域较大或更新频繁时才值得拆。

`ListenableBuilder` 订阅对象，却不把它传播给任意深度的后代。层级很浅时，显式传参更清楚；许多后代需要同一对象时，再使用 inherited 传播。

## inherited 依赖由 context 建立

`InheritedWidget` 后代调用 `dependOnInheritedWidgetOfExactType` 后，当前 Element 记录对该 inherited Element 的依赖。父级用新配置更新 inherited widget 时，`updateShouldNotify(oldWidget)` 决定依赖者是否重建。

常见封装提供 `of` 和 `maybeOf`：

```dart
static SettingsScope of(BuildContext context) {
  final scope = context
      .dependOnInheritedWidgetOfExactType<SettingsScope>();
  assert(scope != null, 'SettingsScope not found');
  return scope!;
}
```

这个 context 必须位于 scope 之下。调用 `of` 表示“读取并订阅”；只做一次不建立依赖的查询可以使用 `getInheritedWidgetOfExactType`，但要能解释为什么后续更新不应重建当前 Widget。

由于 `of` 会建立依赖，State 初始化时放在 `didChangeDependencies`，不能放在 `initState`。在 `build` 中直接读取最简单，也最容易让依赖范围保持可见。

## `InheritedNotifier` 组合传播与通知

普通 InheritedWidget 依赖自身配置被替换；`ChangeNotifier` 则在同一对象内部发通知。`InheritedNotifier` 把两者接起来：notifier 通知后，依赖这个 scope 的后代在该帧更新。

植物项目的封装很窄：

<<< ../../../examples/capstones/plant_care_desk/lib/src/plant_care_desk.dart#plant-care-scope{dart}

`PlantCareScope.of(context)` 返回同一个 controller，并建立依赖。调用方不需要手工注册 listener，控制器也不依赖 BuildContext。

页面决定 controller 的所有权。外部测试若注入 controller，页面只使用不释放；正常运行时页面自己创建，就在 `dispose` 中销毁：

<<< ../../../examples/capstones/plant_care_desk/lib/src/plant_care_desk.dart#controller-ownership{dart}

这个可选注入点同时解决测试替换和资源所有权，不需要服务定位器。

## 选择最浅的工具

按当前共享范围选择：

1. 一个 State 内部：字段 + `setState`。
2. 父子之间：值和回调显式传参。
3. 只重建一处 Listenable 消费区：`ListenableBuilder`。
4. 同一子树多处读取同一对象：窄作用域 `InheritedWidget` 或 `InheritedNotifier`。

本章不引入 provider、Riverpod、ViewModel 或 Repository。它们会减少样板、增加选择器和依赖替换能力，但底层仍要回答所有者、订阅点和释放时机。第六部分再根据应用复杂度引入完整架构。

## 可验证任务

建立一个 `ChangeNotifier` 计量表，保存两项源数据并提供一个派生 getter：

1. 无变化的方法不调用 `notifyListeners`；真实变化只通知一次。
2. 单元测试直接注册 listener，记录通知次数并验证派生值始终与源状态一致。
3. 先用 `ListenableBuilder` 重建一个读数，再改为 `InheritedNotifier` 让两个不同深度的后代读取。
4. 给 controller 增加外部注入入口，测试外部对象不会被页面 dispose，内部对象会释放。
5. 故意在 `build` 中创建 notifier，观察状态被重置后移回 State 生命周期。

## 复习线索

- Listenable 只发变化信号；ChangeNotifier 提供实现；InheritedWidget 负责树内依赖传播。
- `notifyListeners` 放在一次一致状态修改的末尾，无变化不通知。
- `of(context)` 读取并订阅，依赖范围由调用位置决定。
- 创建者负责 dispose；消费者不销毁外部对象。

## 参考资料

- [Listenable API](https://api.flutter.dev/flutter/foundation/Listenable-class.html)（查阅：2026-08-30）
- [ChangeNotifier API](https://api.flutter.dev/flutter/foundation/ChangeNotifier-class.html)（查阅：2026-08-30）
- [ListenableBuilder API](https://api.flutter.dev/flutter/widgets/ListenableBuilder-class.html)（查阅：2026-08-30）
- [InheritedWidget API](https://api.flutter.dev/flutter/widgets/InheritedWidget-class.html)（查阅：2026-08-30）
- [BuildContext.dependOnInheritedWidgetOfExactType API](https://api.flutter.dev/flutter/widgets/BuildContext/dependOnInheritedWidgetOfExactType.html)（查阅：2026-08-30）
- [InheritedNotifier API](https://api.flutter.dev/flutter/widgets/InheritedNotifier-class.html)（查阅：2026-08-30）
