---
title: 项目：植物照护台
description: 用温室照护流程统筹状态所有权、ChangeNotifier、InheritedNotifier、稳定 Key、撤销与两类动画。
part: 3
order: 7
kind: capstone
requires:
  - state.ownership
  - state.set-state
  - state.derived
  - state.lifecycle
  - runtime.mounted
  - runtime.side-effect
  - runtime.element-identity
  - runtime.keys
  - list.reorder
  - state.listenable
  - state.change-notifier
  - state.inherited
  - animation.implicit
  - animation.tween
  - animation.curve
  - animation.controller
  - animation.transition
  - animation.reduced-motion
provides:
  - project.plant-care-desk
project: plant-care-desk
status: verified
---

# 项目：植物照护台

这章一次讲完第三部分统筹项目。项目把状态所有权、通知传播、行内身份、撤销和动画放进同一条温室值班流程；后续章节不会再跨章拆解它。

需要回查单项机制时，可返回[状态所有权](/guide/part-03/01-state-ownership)、[生命周期](/guide/part-03/02-lifecycle-and-effects)、[Key 与重排](/guide/part-03/03-keys-and-reordering)、[通知与 inherited 依赖](/guide/part-03/04-listenable-inherited-notifier)、[隐式动画](/guide/part-03/05-implicit-animations)和[显式动画](/guide/part-03/06-explicit-animations)。本章关注它们在撤销与重排中的组合。

## 项目简报

植物照护台服务一轮固定的温室观测。值班员查看四份植物记录，按“全部 / 需要照护 / 状态稳定”筛选，记录一次浇水并观察湿度变化。浇水后列表按照护紧迫度重排，最近一次操作可以撤销。

必须完成：

- 保存四份源记录和当前筛选条件；
- 派生待照护计数与可见列表，不复制筛选结果；
- 浇水后更新湿度、观察文字与列表顺序；
- 保存一次完整撤销快照，恢复记录与操作前筛选；
- 植物卡片可独立展开观察，重排后展开状态不串位；
- 湿度条使用隐式动画，操作回执使用显式动画；
- reduced motion 下直接显示终态；
- 筛选、记录、撤销和状态消息对键盘与语义树可用；
- 320×720、768×900、1440×900 和 200% 文本下无 overflow。

视觉方向是“温室物候观测仪表台”：氧化绿仪表板、矿物白标签、铜色读数和朱红操作标记。植物没有被做成常见的生活方式卡片，页面更像值班人员用于交叉核对读数与记录的工作台。

## 先运行项目

项目路径：`examples/capstones/plant_care_desk`。

```powershell
flutter analyze
flutter test examples/capstones/plant_care_desk/test
cd examples/capstones/plant_care_desk
flutter run -d chrome
```

Web release 构建：

```powershell
flutter build web --release --base-href /flutter-tutorial/previews/plant-care-desk/
```

Chrome 集成测试由 `integration_test/plant_care_desk_test.dart` 驱动：切换到“需要照护”，给琴叶榕记录浇水，确认它离开筛选结果，再撤销并恢复记录。

## 状态图先于 Widget tree

项目把状态分成三层：

| 层 | 内容 | 所有者 |
| --- | --- | --- |
| 源状态 | 完整植物列表、筛选条件、一次撤销快照、回执文字 | `PlantCareController` |
| 派生值 | 可见植物、待照护数量、是否可撤销 | controller getter |
| 行内状态 | 某张卡是否展开 | `_PlantInstrumentState` |

湿度条与回执的动画进度属于各自动画 Widget，不进入业务 controller。controller 只表达“湿度已经从 24 变成 66”和“回执文字已更新”，不保存每帧宽度或 opacity。

完整控制器源码如下：

<<< ../../../examples/capstones/plant_care_desk/lib/src/plant_data.dart#change-notifier-controller{dart}

浇水先复制完整列表与筛选条件形成快照，再修改目标植物，最后按“仍需照护优先、湿度更低优先”排序。撤销直接恢复快照，不尝试反向推导每个字段。

项目只保存一层 undo。若需求扩展为多步撤销，应把快照改为有上限的历史栈，并明确筛选变化是否进入历史；当前任务不提前建立通用命令系统。

## Scope 只传播 controller

`PlantCareScope` 是 `InheritedNotifier<PlantCareController>` 的薄封装：

<<< ../../../examples/capstones/plant_care_desk/lib/src/plant_care_desk.dart#plant-care-scope{dart}

页面正常运行时创建 controller，并在离开时 dispose；测试可以注入已准备的数据对象，此时页面不拥有它：

<<< ../../../examples/capstones/plant_care_desk/lib/src/plant_care_desk.dart#controller-ownership{dart}

UI 调用 `PlantCareScope.of(context)` 后建立依赖。controller 通知时，读取过 scope 的区域重建并重新计算派生 getter。项目规模很小，没有再做 selector；若未来高频读数和大量卡片进入同一页面，应按变化频率拆 notifier 或使用第六部分的选择器机制。

## 稳定 Key 保护行内展开状态

列表会在浇水后重排。植物卡直接使用业务 ID：

<<< ../../../examples/capstones/plant_care_desk/lib/src/plant_care_desk.dart#keyed-plant-list{dart}

卡片内部保存 `_expanded`。琴叶榕从第一位移到后面时，`ValueKey('ficus-lyrata')` 让对应 Element 与 State 一起移动，鸟巢蕨不会接走它的展开状态。

测试先展开琴叶榕，再浇水触发重排，最后同时验证琴叶榕观察仍存在、鸟巢蕨观察没有被误展开：

<<< ../../../examples/capstones/plant_care_desk/test/plant_care_desk_test.dart#keyed-state-test{dart}

这个断言比检查名字顺序更接近真实风险。

## 两类动画各自服务一个结果

湿度条只需要跟随目标值，使用 `TweenAnimationBuilder<double>`：

<<< ../../../examples/capstones/plant_care_desk/lib/src/plant_care_desk.dart#implicit-moisture{dart}

操作回执需要每次 message 变化都主动从头播放，使用一个 controller 同时驱动淡入和轻微上移，并在 `didUpdateWidget` 中重启：

<<< ../../../examples/capstones/plant_care_desk/lib/src/plant_care_desk.dart#explicit-receipt{dart}

两者都读取 `MediaQuery.disableAnimationsOf(context)`。湿度条改为零时长，回执直接返回终态内容。状态文字和 live region 始终存在，运动不是理解结果的前提。

## 交互边界与恢复路径

筛选使用 ChoiceChip，点击后立即更新可见列表。给琴叶榕浇水后，它从“需要照护”结果消失；这不是删除，完整列表仍保留更新后的记录。空结果明确提示切换筛选或撤销。

撤销按钮只有存在快照时可用。回执放进 live region，让读屏用户在焦点仍停留于按钮时收到“琴叶榕已浇水”或“已撤销”的结果。每张植物卡还提供包含区域、当前湿度和目标湿度的语义 label。

键盘验收要走完整动作，不只确认控件能获得焦点：

1. Tab 到“需要照护”并用 Space 或 Enter 选择。
2. Tab 到琴叶榕“查看观察”，展开后继续到“记录浇水”。
3. 确认焦点不被重排困住，琴叶榕从当前结果离开。
4. 到“撤销上次照护”恢复记录，再检查展开状态仍属于琴叶榕。

## 测试覆盖状态时间线

项目现有证据：

- 单元测试：筛选不复制源列表，浇水重排并保存快照，撤销恢复筛选与湿度；
- Widget 测试：筛选—浇水—撤销、Key 身份、两类动画时间点、reduced motion、语义、320×720 与 200% 文本；
- Chrome 集成测试：完整 Web 应用中的一次照护与撤销；
- Web release 构建：使用 Pages 预览 base href。

动画测试精确推进起点、中点与终点；reduced motion 测试确认一次 pump 后已经到达目标：

<<< ../../../examples/capstones/plant_care_desk/test/plant_care_desk_test.dart#reduced-motion-test{dart}

浏览器人工检查仍负责焦点顺序、焦点可见性、实际对比度和三种目标宽度。自动化断言没有把这些检查合并成一句“可访问性通过”。

## 项目完成检查

- [ ] 能把源状态、派生值、行内状态和动画进度分别归给正确所有者。
- [ ] 能说明 controller 为什么不保存 visiblePlants 和每帧动画值。
- [ ] 能解释 `InheritedNotifier` 如何把 notifier 通知转成子树依赖更新。
- [ ] 外部注入 controller 时不 dispose，内部创建时按 State 生命周期释放。
- [ ] 重排后，卡片展开状态仍跟随业务 ID。
- [ ] 撤销恢复完整快照，不靠反向猜测刚才改了哪些字段。
- [ ] 隐式动画和显式动画都覆盖起点、中点、终点与 reduced motion。
- [ ] 用键盘完成筛选、查看、浇水和撤销，状态结果可由语义树读取。
- [ ] analyze、单元测试、Widget 测试、Chrome 集成测试和 Web release 构建全部通过。

## 复习线索

- 状态所有权与派生：03-01。
- 生命周期、配置替换与释放：03-02。
- Element 身份和稳定 Key：03-03。
- ChangeNotifier 与 inherited 传播：03-04。
- 隐式和显式动画：03-05～03-06。
- [项目源码](https://github.com/mardd123588/flutter-tutorial/tree/main/examples/capstones/plant_care_desk)

## 参考资料

- [Simple app state management](https://docs.flutter.dev/data-and-backend/state-mgmt/simple)（查阅：2026-08-30）
- [State API](https://api.flutter.dev/flutter/widgets/State-class.html)（查阅：2026-08-30）
- [ValueKey API](https://api.flutter.dev/flutter/foundation/ValueKey-class.html)（查阅：2026-08-30）
- [InheritedNotifier API](https://api.flutter.dev/flutter/widgets/InheritedNotifier-class.html)（查阅：2026-08-30）
- [ChangeNotifier API](https://api.flutter.dev/flutter/foundation/ChangeNotifier-class.html)（查阅：2026-08-30）
- [Implicit animations](https://docs.flutter.dev/ui/animations/implicit-animations)（查阅：2026-08-30）
- [AnimationController API](https://api.flutter.dev/flutter/animation/AnimationController-class.html)（查阅：2026-08-30）
- [MediaQueryData.disableAnimations API](https://api.flutter.dev/flutter/widgets/MediaQueryData/disableAnimations.html)（查阅：2026-08-30）
