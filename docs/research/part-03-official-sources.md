# 第三部分官方资料研究：状态、生命周期与动画

> 查阅日期：2026-08-30
> 教程基线：Flutter 3.47.0、Dart 3.13.0
> 资料范围：Flutter / Dart 官方文档、API 文档，以及 Flutter 3.47.0 标签下的框架与测试源码

这份笔记用于确定第三部分的知识边界、章节顺序和项目验收方式，不直接充当教程正文。下文把框架合同写成“官方事实”，把状态建模和课程取舍写成“编排建议”，避免把本站方案说成 Flutter 的硬性规定。

## 1. 版本基线与本部分风险

- 仓库基线是 Flutter 3.47.0、Dart 3.13.0；本机 Flutter framework revision 为 `4cf2416426`。涉及 `State`、Key、`ReorderableListView`、动画控制器和测试时钟的版本敏感结论，以 `flutter/flutter` 的 `3.47.0` 标签源码为准。[Flutter 3.47.0 release notes](https://docs.flutter.dev/release/release-notes/release-notes-3.47.0) · [flutter/flutter 3.47.0](https://github.com/flutter/flutter/tree/3.47.0) · [Dart SDK 3.13.0](https://github.com/dart-lang/sdk/releases/tag/3.13.0)（查阅：2026-08-30）
- 3.47.0 的 `ReorderableListView.onReorder` 已弃用，应改用 `onReorderItem`。新回调已经把向后移动时的 `newIndex` 调整为删除旧项后的索引；旧教程常见的 `if (newIndex > oldIndex) newIndex -= 1` 不能原样保留，否则会多减一次。[ReorderableListView.onReorderItem API](https://api.flutter.dev/flutter/material/ReorderableListView/onReorderItem.html) · [reorderable_list.dart 3.47.0](https://github.com/flutter/flutter/blob/3.47.0/packages/flutter/lib/src/material/reorderable_list.dart#L66-L132)（查阅：2026-08-30）
- 第三部分只讲 Flutter SDK 的状态基础：`StatefulWidget`、`InheritedWidget`、`Listenable`、`ChangeNotifier` 和动画对象。provider、Riverpod、ViewModel、Repository 与完整单向数据流属于第六部分；这里要建立它们共同依赖的所有权、订阅和重建模型。[Simple app state management](https://docs.flutter.dev/data-and-backend/state-mgmt/simple) · [ADR 0009 对应的官方底层 API：InheritedWidget](https://api.flutter.dev/flutter/widgets/InheritedWidget-class.html) · [ChangeNotifier](https://api.flutter.dev/flutter/foundation/ChangeNotifier-class.html)（查阅：2026-08-30）

## 2. 状态所有权、派生状态与 `setState`

### 2.1 先判断谁需要状态，再决定放在哪里

- Flutter 官方把可管理的状态概括为“重建任意时刻 UI 所需的数据”，并区分临时状态与应用状态。临时状态通常能完整封装在一个 Widget 中，不要求跨会话保存；应用状态会被多个位置共享，或需要更长生命周期。官方同时强调这不是固定分类，同一个“当前标签页”会因产品要求不同而改变归属。[Ephemeral state and app state](https://docs.flutter.dev/data-and-backend/state-mgmt/ephemeral-vs-app)（查阅：2026-08-30）
- 官方的 lifting state up 原则是：状态放在所有使用者之上，由父级用新配置重建子级。课程可把它收敛为“放在最近的共同拥有者”：过低会迫使兄弟组件互相找实例，过高会扩大修改接口和重建范围。后半句是课程的设计判断，不是 Flutter 对目录层级的规定。[Simple app state management: Lifting state up](https://docs.flutter.dev/data-and-backend/state-mgmt/simple#lifting-state-up)（查阅：2026-08-30）
- 一个组件只负责显示值并通过回调报告意图时，值由父级拥有；纯内部且离开组件即可丢弃的展开、选择或动画进度，可以留在本地 `State`。是否需要持久化、是否被兄弟组件读取、是否需要由外部恢复，都是所有权上移的信号。[Ephemeral state and app state](https://docs.flutter.dev/data-and-backend/state-mgmt/ephemeral-vs-app) · [Add interactivity](https://docs.flutter.dev/ui/interactivity)（查阅：2026-08-30）

### 2.2 派生状态不要复制成第二份可变事实

- 官方购物车示例只存 `_items`，把 `totalPrice` 写成 getter，并向外暴露不可修改视图。这是派生状态的合适范例：能从源状态同步算出的值，在读取时计算，不另存一个需要手工同步的字段。[Simple app state management: ChangeNotifier](https://docs.flutter.dev/data-and-backend/state-mgmt/simple#changenotifier)（查阅：2026-08-30）
- “便宜且确定的派生值优先用 getter / 局部变量”属于本站编排建议。Flutter 不禁止缓存；计算昂贵时可以缓存，但缓存、失效条件和源状态必须由同一所有者管理，并测试每条失效路径。第三部分只使用列表筛选、计数和当前选项这类便宜派生值，不提前引入缓存层。
- 筛选后的列表、是否可提交、完成数量等都应从原始列表与当前筛选条件派生。若同时维护 `items`、`filteredItems` 和 `completedCount` 三份可变字段，一次操作就可能只更新其中两份；教程应把这种不同步做成可复现错误，而不是只给“单一事实来源”的口号。

### 2.3 `setState` 的真实边界

- `setState` 会立即、同步执行回调，随后对当前 `State` 对应的 Element 调用 `markNeedsBuild`。回调不能是 `async`；耗时或异步工作应放在回调外，拿到结果后再同步修改字段。[State.setState API](https://api.flutter.dev/flutter/widgets/State/setState.html) · [framework.dart 3.47.0](https://github.com/flutter/flutter/blob/3.47.0/packages/flutter/lib/src/widgets/framework.dart#L1058-L1221)（查阅：2026-08-30）
- `setState` 标记当前 `State` 对应的 Element 需要重建，不等于“只重建刚改变文字的那个 Widget”，也不等于“整个应用必然重建”。更新从这个 Element 开始，可能继续处理后代；未变化的配置仍可能被复用。更完整的 Widget—Element 更新路径留到第七部分。[State.setState API](https://api.flutter.dev/flutter/widgets/State/setState.html) · [Widget.canUpdate API](https://api.flutter.dev/flutter/widgets/Widget/canUpdate.html)（查阅：2026-08-30）
- 官方建议只在状态变化会实质改变 `build` 结果时调用 `setState`，并指出间接成本可能包括子树重建、布局与绘制。教程应比较“每一行各自拥有编辑状态”“列表页拥有列表顺序”“应用根部拥有所有鼠标 hover”三种范围，让读者用所有权和依赖判断，而不是把所有状态都上移。[State.setState API](https://api.flutter.dev/flutter/widgets/State/setState.html)（查阅：2026-08-30）

## 3. `State` 生命周期、副作用与 `mounted`

### 3.1 需要掌握的生命周期链

| 回调 / 属性 | 官方合同 | 本部分用法 |
| --- | --- | --- |
| `initState` | 每个 `State` 对象只调用一次；此时 `widget` 与 `context` 已可用，但不能在这里建立 inherited dependency。 | 创建 timer、controller，订阅构造参数传入的 `Listenable`。 |
| `didChangeDependencies` | 紧接 `initState` 调用；依赖的 `InheritedWidget` 变化后还会再调用。 | 读取并响应会变化的 inherited dependency。 |
| `didUpdateWidget` | 同一位置的新旧 Widget 具有相同 `runtimeType` 与 key 时调用，之后框架一定调用 `build`。 | 构造参数里的订阅对象变了，退订旧对象并订阅新对象；更新 controller 配置。 |
| `build` | 可能每帧调用；只根据当前配置、状态和依赖描述 UI。 | 不启动 timer、不注册 listener、不调用会重复执行的业务副作用。 |
| `deactivate` / `activate` | 暂时移出树后仍可能在同一帧重新插入。 | 一般不释放最终资源；理解 `GlobalKey` 移动子树。 |
| `dispose` | 永久移除后的终态；随后 `mounted == false`，不能再次挂载。 | 取消 timer、退订 listener、释放 controller。 |

以上顺序和边界来自 `State` API 与 3.47.0 源码。[State API](https://api.flutter.dev/flutter/widgets/State-class.html) · [framework.dart 3.47.0](https://github.com/flutter/flutter/blob/3.47.0/packages/flutter/lib/src/widgets/framework.dart#L916-L1367)（查阅：2026-08-30）

### 3.2 订阅必须覆盖配置替换

- Flutter 在 `State.initState` 文档中明确给出三段式订阅协议：`initState` 订阅；`didUpdateWidget` 在对象发生替换时退订旧对象、订阅新对象；`dispose` 退订。只写“初始化和释放”会漏掉父级换入新 `ChangeNotifier`、Stream 或 controller 的情况。[State.initState API](https://api.flutter.dev/flutter/widgets/State/initState.html) · [framework.dart 3.47.0](https://github.com/flutter/flutter/blob/3.47.0/packages/flutter/lib/src/widgets/framework.dart#L981-L1037)（查阅：2026-08-30）
- `didUpdateWidget` 后框架一定会调用 `build`，因此在此调用 `setState` 是多余的。若需要同步本地字段，可以直接赋值；随后的 `build` 会读取新值。[State.didUpdateWidget API](https://api.flutter.dev/flutter/widgets/State/didUpdateWidget.html)（查阅：2026-08-30）
- `dispose` 不是应用退出通知。官方明确说明进程可能被操作系统直接终止，框架没有机会遍历并释放整个树；需要持久化的数据不能等到 `dispose` 才保存。[State.dispose API](https://api.flutter.dev/flutter/widgets/State/dispose.html)（查阅：2026-08-30）

### 3.3 `mounted` 是使用资格，不是取消机制

- `State` 在 `initState` 之前已经 mounted，直到 `dispose` 后才变为 false；`dispose` 后调用 `setState` 是错误。`BuildContext.mounted` 也表示这个 context 当前是否仍挂载，一旦变为 false 就不会再变回 true。[State.mounted API](https://api.flutter.dev/flutter/widgets/State/mounted.html) · [BuildContext.mounted API](https://api.flutter.dev/flutter/widgets/BuildContext/mounted.html)（查阅：2026-08-30）
- 代码跨过 `await` 后再使用 `BuildContext`，需要检查与该 context 对应的 mounted 状态。Dart 官方 lint `use_build_context_synchronously` 还区分 `State.mounted` 与局部 `context.mounted`：检查必须守住实际被使用的对象，不能拿无关 context 的状态作保证。[use_build_context_synchronously](https://dart.dev/tools/linter-rules/use_build_context_synchronously)（查阅：2026-08-30）
- 官方对 `setState after dispose` 的首选修复是取消 timer、停止监听动画或断开持有 `State` 的引用；`if (!mounted) return` 只能阻止最后一次非法更新，不能停止后台工作和引用保留。[State.setState API](https://api.flutter.dev/flutter/widgets/State/setState.html) · [Timer.cancel API](https://api.dart.dev/dart-async/Timer/cancel.html)（查阅：2026-08-30）
- 03-02 的错误案例应同时覆盖两类问题：未取消 `Timer.periodic` 导致卸载后仍回调，以及异步间隙后使用失效 context。第四部分再处理请求竞态、旧结果和完整的异步 UI 状态；本章不借网络请求扩大范围。

## 4. Element 身份、Key 与列表重排

### 4.1 状态为什么会“留在位置上”

- Widget 只是配置；Widget 进入树后会膨胀为 Element。更新时，只有新旧 Widget 的 `runtimeType` 相同且 key 相等，旧 Element 才能接收新配置；两者都没有 key 时，同类型 Widget 会按所在位置匹配。[Widget.canUpdate API](https://api.flutter.dev/flutter/widgets/Widget/canUpdate.html) · [framework.dart 3.47.0](https://github.com/flutter/flutter/blob/3.47.0/packages/flutter/lib/src/widgets/framework.dart#L367-L385)（查阅：2026-08-30）
- 因此，无 key 的一组同类型 stateful 行发生重排时，行配置换了，原来的 `State` 仍可能留在索引位置。输入框文字、展开状态或 controller 就会看似“串到别人名下”。Key 的作用是让框架以业务身份匹配旧新配置，不是让列表排序本身生效。[Key API](https://api.flutter.dev/flutter/foundation/Key-class.html) · [ValueKey API](https://api.flutter.dev/flutter/foundation/ValueKey-class.html)（查阅：2026-08-30）
- Key 在同一父级的兄弟 Element 之间参与匹配。若把 key 放到行内部较深的 TextField，而列表直接子级仍无 key，外层 stateful 行仍可能按位置复用；重点项目应把稳定 key 放在被重排的顶层行 Widget 上。[Widget.key API](https://api.flutter.dev/flutter/widgets/Widget/key.html) · [Key API](https://api.flutter.dev/flutter/foundation/Key-class.html)（查阅：2026-08-30）

### 4.2 四种 Key 的边界

| Key | 相等规则 | 适合 | 不适合 |
| --- | --- | --- | --- |
| `ValueKey(id)` | value 的 `==` | 数据有稳定、同级唯一 ID 的列表项 | 用可变索引作身份 |
| `ObjectKey(model)` | `identical` 对象身份 | 模型实例本身稳定，且实例身份就是业务身份 | 每次重建都创建新模型对象 |
| `UniqueKey()` | 只与自身相等 | 刻意强制创建新身份 | 在 `build` 中为需保留状态的行重新创建 |
| `GlobalKey` | 全应用唯一 | 确实需要跨父级移动子树，或访问指定 `State` / `BuildContext` | 普通列表身份与方便调用子组件方法 |

这些相等规则来自 3.47.0 API 与源码。[ValueKey API](https://api.flutter.dev/flutter/foundation/ValueKey-class.html) · [ObjectKey API](https://api.flutter.dev/flutter/widgets/ObjectKey-class.html) · [UniqueKey API](https://api.flutter.dev/flutter/foundation/UniqueKey-class.html) · [GlobalKey API](https://api.flutter.dev/flutter/widgets/GlobalKey-class.html)（查阅：2026-08-30）

- `GlobalKey` 移动子树需要触发该 State 及后代的 `deactivate`，还会让依赖 `InheritedWidget` 的后代重建；每次 `build` 重建 GlobalKey 会直接丢弃旧子树状态，并可能中断进行中的手势。普通可排序列表应使用稳定 `ValueKey`，不靠 GlobalKey 修正身份。[GlobalKey API](https://api.flutter.dev/flutter/widgets/GlobalKey-class.html) · [framework.dart 3.47.0](https://github.com/flutter/flutter/blob/3.47.0/packages/flutter/lib/src/widgets/framework.dart#L113-L159)（查阅：2026-08-30）

### 4.3 `ReorderableListView` 的 3.47 边界

- `ReorderableListView` 要求每个列表项都有 key。3.47.0 应实现 `onReorderItem`；它收到的是已经适合执行 remove-then-insert 的目标索引，不再手工执行旧式 `newIndex -= 1`。[ReorderableListView API](https://api.flutter.dev/flutter/material/ReorderableListView-class.html) · [reorderable_list.dart 3.47.0](https://github.com/flutter/flutter/blob/3.47.0/packages/flutter/lib/src/material/reorderable_list.dart#L41-L132)（查阅：2026-08-30）
- 框架会为可重排行包装“移到开头 / 前一项 / 后一项 / 末尾”等 custom semantics actions；这有助于辅助技术操作，但不等于普通键盘用户已经有明确、可见的重排路径。重点项目仍应给出上移、下移按钮或快捷键，并共享同一个重排命令。[reorderable_list.dart 3.47.0 semantics source](https://github.com/flutter/flutter/blob/3.47.0/packages/flutter/lib/src/widgets/reorderable_list.dart#L1153-L1202)（查阅：2026-08-30）
- 测试不能只断言名字顺序变化。应先在某个成员行输入备注或改变行内状态，再通过拖动回调和键盘替代操作重排，最后按业务 ID 的 `ValueKey` 找到该行，验证备注仍属于原成员。[CommonFinders.byKey API](https://api.flutter.dev/flutter/flutter_test/CommonFinders/byKey.html)（查阅：2026-08-30）

## 5. `InheritedWidget`、`Listenable` 与 `ChangeNotifier`

### 5.1 三者解决不同问题

- `InheritedWidget` 负责把数据高效传给子树。后代通过 `dependOnInheritedWidgetOfExactType` 建立依赖；当新的 inherited widget 占据相同位置时，`updateShouldNotify(oldWidget)` 决定这些依赖者是否重建。[InheritedWidget API](https://api.flutter.dev/flutter/widgets/InheritedWidget-class.html) · [InheritedWidget.updateShouldNotify API](https://api.flutter.dev/flutter/widgets/InheritedWidget/updateShouldNotify.html)（查阅：2026-08-30）
- `Listenable` 是“可以注册无参数回调”的通知接口；`Animation`、`ValueNotifier` 和 `ChangeNotifier` 都能作为 Listenable。它负责发出“有变化”的信号，不负责把对象放进 Widget tree，也不携带变化 payload。[ChangeNotifier API](https://api.flutter.dev/flutter/foundation/ChangeNotifier-class.html) · [ListenableBuilder API](https://api.flutter.dev/flutter/widgets/ListenableBuilder-class.html)（查阅：2026-08-30）
- `ChangeNotifier` 是 Listenable 的可复用实现：添加监听器为 O(1)，移除监听器和分发通知为 O(N)。`notifyListeners` 会通知当前监听者；`dispose` 后对象不可继续使用，而且只有所有者能 dispose。[ChangeNotifier API](https://api.flutter.dev/flutter/foundation/ChangeNotifier-class.html) · [change_notifier.dart 3.47.0](https://github.com/flutter/flutter/blob/3.47.0/packages/flutter/lib/src/foundation/change_notifier.dart#L102-L414)（查阅：2026-08-30）

### 5.2 读取、订阅与拥有要分开

- 惯例是在 inherited 类型上提供 `of` 与 `maybeOf`。两者内部调用 `dependOnInheritedWidgetOfExactType`，并要求传入的 context 位于 inherited widget 之下；`of` 通常找不到时断言，`maybeOf` 返回 null。[InheritedWidget API](https://api.flutter.dev/flutter/widgets/InheritedWidget-class.html)（查阅：2026-08-30）
- 依赖 inherited 数据的初始化放在 `didChangeDependencies`，不能在 `initState` 调用 `dependOnInheritedWidgetOfExactType`。构建阶段直接调用 `of(context)` 最常见；需要一次性读取而不订阅时有 `getInheritedWidgetOfExactType`，但教程应先把“读取后自动重建”和“不建立依赖”明确区分。[BuildContext.dependOnInheritedWidgetOfExactType API](https://api.flutter.dev/flutter/widgets/BuildContext/dependOnInheritedWidgetOfExactType.html) · [State.initState API](https://api.flutter.dev/flutter/widgets/State/initState.html)（查阅：2026-08-30）
- `ListenableBuilder` 订阅现有 Listenable，并只重建 builder 返回的区域；不依赖通知的稳定子树可以放进 `child`，避免每次通知都重建。若 listenable 是 Animation，功能相同但使用 `AnimatedBuilder` 更能表达意图。[ListenableBuilder API](https://api.flutter.dev/flutter/widgets/ListenableBuilder-class.html) · [AnimatedBuilder API](https://api.flutter.dev/flutter/widgets/AnimatedBuilder-class.html)（查阅：2026-08-30）
- `InheritedNotifier` 把传播与通知组合起来：notifier 发出多次通知时，同一帧内会合并为一次依赖更新；notifier 实例替换时也能通知依赖者。它适合解释 provider 等方案省掉的底层样板，但第三部分只实现一个窄作用域封装。[InheritedNotifier API](https://api.flutter.dev/flutter/widgets/InheritedNotifier-class.html) · [inherited_notifier.dart 3.47.0](https://github.com/flutter/flutter/blob/3.47.0/packages/flutter/lib/src/widgets/inherited_notifier.dart#L10-L132)（查阅：2026-08-30）

### 5.3 本章比较方式

03-04 可用同一个“共享筛选条件”做两种实现：

1. 不可变筛选值由上层 `State` 拥有，用自定义 `InheritedWidget` 传播，`updateShouldNotify` 比较筛选值；
2. 一个由上层创建和释放的 `ChangeNotifier` 封装筛选值，局部界面用 `ListenableBuilder`，需要跨层读取时再通过 `InheritedNotifier` 暴露。

比较重点是所有者、订阅点、重建范围和测试接缝，不是宣称某一种 API 更“现代”。notifier 不在 `build` 中创建，消费者不 dispose 外部传入的 notifier；这与第二部分 controller / focus node 的所有权规则保持一致。[State.initState API](https://api.flutter.dev/flutter/widgets/State/initState.html) · [ChangeNotifier.dispose API](https://api.flutter.dev/flutter/foundation/ChangeNotifier/dispose.html)（查阅：2026-08-30）

## 6. 隐式动画

### 6.1 最小心智模型

- 隐式动画 Widget 自己管理 controller。调用方只提供目标属性、`duration`、`curve` 和可选 `onEnd`；目标变化后，内部 Tween 从当前动画值过渡到新目标，再把 controller 从 0 重新播放。初次构建只建立 Tween，不播放。[Implicit animations](https://docs.flutter.dev/ui/animations/implicit-animations) · [implicit_animations.dart 3.47.0](https://github.com/flutter/flutter/blob/3.47.0/packages/flutter/lib/src/widgets/implicit_animations.dart#L284-L557)（查阅：2026-08-30）
- `Tween<T>` 定义 `begin` 到 `end` 的插值；`Curve` / `CurvedAnimation` 改变 0～1 时间进度的映射。二者不能混写成“curve 决定颜色从什么值变到什么值”。[Animations API overview](https://docs.flutter.dev/ui/animations/overview#tweens) · [Tween API](https://api.flutter.dev/flutter/animation/Tween-class.html) · [CurvedAnimation API](https://api.flutter.dev/flutter/animation/CurvedAnimation-class.html)（查阅：2026-08-30）
- `AnimatedContainer` 只动画非 null 且该类支持插值的自身属性，child 及其后代不会自动跟着动画。中途再次改变目标时，新 Tween 的 begin 会取当前动画值，所以过渡连续，不会先跳回上一段起点。[AnimatedContainer API](https://api.flutter.dev/flutter/widgets/AnimatedContainer-class.html) · [implicit_animations.dart 3.47.0](https://github.com/flutter/flutter/blob/3.47.0/packages/flutter/lib/src/widgets/implicit_animations.dart#L395-L435)（查阅：2026-08-30）
- 只需要“状态变化后自动过渡到目标”时优先隐式动画；需要主动 `forward` / `reverse` / `stop`、多个阶段、进度联动或状态监听时再使用显式动画。这个选择减少 controller 生命周期代码，也让章节顺序从状态变化自然过渡到动画控制。[Implicit animations](https://docs.flutter.dev/ui/animations/implicit-animations) · [Animations tutorial](https://docs.flutter.dev/ui/animations/tutorial)（查阅：2026-08-30）

### 6.2 动画属性会决定流水线成本

- `AnimatedPositioned` 每帧会触发布局；若 child 大小不变、只改变位置，官方建议使用 `SlideTransition`，后者每帧只触发重绘。教程应把“动画是否流畅”拆成属性选择和重建范围，不在本部分提前讲完整渲染流水线。[AnimatedPositioned API](https://api.flutter.dev/flutter/widgets/AnimatedPositioned-class.html) · [SlideTransition API](https://api.flutter.dev/flutter/widgets/SlideTransition-class.html)（查阅：2026-08-30）
- `AnimatedBuilder.child` 可预构建不依赖动画的子树，再把它传回 builder。显式动画章节用这个边界说明“controller 每帧发通知”不等于“所有后代都必须重新构建”。[AnimatedBuilder API](https://api.flutter.dev/flutter/widgets/AnimatedBuilder-class.html)（查阅：2026-08-30）

### 6.3 reduced motion 不能只靠缩短时长

- `MediaQueryData.disableAnimations` 表示平台请求尽量禁用或减少动画。Flutter 的 `AnimationController` 默认使用 `AnimationBehavior.normal`，在该标志生效时把普通插值动画缩到原时长的 5%，通常只剩一帧；`preserve` 会保留原行为，主要用于滚动等不能直接跳到终点的交互。[MediaQueryData.disableAnimations API](https://api.flutter.dev/flutter/widgets/MediaQueryData/disableAnimations.html) · [AnimationBehavior API](https://api.flutter.dev/flutter/animation/AnimationBehavior.html) · [animation_controller.dart 3.47.0](https://github.com/flutter/flutter/blob/3.47.0/packages/flutter/lib/src/animation/animation_controller.dart#L41-L73)（查阅：2026-08-30）
- 框架自动缩时不是产品设计的全部。项目应显式读取 `MediaQuery.disableAnimationsOf(context)`：非必要位移与循环动画直接关闭，状态变化仍立即可见；必要反馈可以改用颜色、图标或无位移淡入。只有交互物理语义确实需要时才考虑 `AnimationBehavior.preserve`。[MediaQuery.disableAnimationsOf API](https://api.flutter.dev/flutter/widgets/MediaQuery/disableAnimationsOf.html) · [media_query.dart 3.47.0](https://github.com/flutter/flutter/blob/3.47.0/packages/flutter/lib/src/widgets/media_query.dart#L662-L693)（查阅：2026-08-30）
- 3.47.0 文档明确说明：手工覆盖 `MediaQueryData.disableAnimations` 可以测试自定义分支，但不会改变框架级 `AnimationController` 读取的 engine accessibility flag。若要测试 controller 自身的降速行为，应通过测试平台分发器设置 `FakeAccessibilityFeatures(disableAnimations: true)`；测试结束后清理覆盖值。[MediaQueryData.disableAnimations API](https://api.flutter.dev/flutter/widgets/MediaQueryData/disableAnimations.html) · [FakeAccessibilityFeatures API](https://api.flutter.dev/flutter/flutter_test/FakeAccessibilityFeatures-class.html)（查阅：2026-08-30）

## 7. 显式动画、`AnimationController` 与 Ticker

### 7.1 controller 的生命周期

- `AnimationController` 默认线性输出 0.0～1.0，并在每个显示帧生成新值。它需要 `TickerProvider` 作为 `vsync`；一个 `State` 只创建一个 controller 时用 `SingleTickerProviderStateMixin`，需要多个独立 controller 时才用 `TickerProviderStateMixin`。[AnimationController API](https://api.flutter.dev/flutter/animation/AnimationController-class.html) · [Animations API overview](https://docs.flutter.dev/ui/animations/overview#animationcontroller)（查阅：2026-08-30）
- 标准所有权模式是：在 `initState` 创建 controller，在 `didUpdateWidget` 同步会变化的 `duration` 等配置，在 `dispose` 中释放。对外只需读动画时传 `controller.view`，不要把可调用 `forward`、`stop` 的完整 controller 暴露给不拥有它的组件。[AnimationController API](https://api.flutter.dev/flutter/animation/AnimationController-class.html) · [animation_controller.dart 3.47.0](https://github.com/flutter/flutter/blob/3.47.0/packages/flutter/lib/src/animation/animation_controller.dart#L92-L230)（查阅：2026-08-30）
- `TickerMode` 禁用时，相关 Ticker 被 muted：时间仍在流逝，controller 可以被手工改值，但不会自行逐帧通知。它不是“暂停后从原值继续”的保证，不能替代停止、重置或业务层暂停设计。[AnimationController API](https://api.flutter.dev/flutter/animation/AnimationController-class.html) · [TickerMode API](https://api.flutter.dev/flutter/widgets/TickerMode-class.html)（查阅：2026-08-30）

### 7.2 取消与串行动画

- `forward`、`reverse` 等启动方法返回 `TickerFuture`。正常完成时 Future 完成；动画被取消时，普通 Future 不完成，而 `.orCancel` 以 `TickerCanceled` 结束。controller 的 `dispose` 会取消最近一次 TickerFuture，因此串行动画可以 `await ...orCancel` 并捕获 `TickerCanceled`，不必在每一步重复检查 `mounted`。[AnimationController API](https://api.flutter.dev/flutter/animation/AnimationController-class.html)（查阅：2026-08-30）
- 这一条只适用于由该 `State` 创建并在 `dispose` 释放的 controller。不能泛化成“所有 Future 都不必检查 mounted”；普通异步工作仍遵守 03-02 的取消与 context 检查规则。

### 7.3 transition、stagger 与更新范围

- Flutter 已提供 `FadeTransition`、`SlideTransition`、`SizeTransition` 等显式 transition；它们接收 Animation，比手写 listener + `setState` 更短。无法用现成 transition 表达的组合再使用 `AnimatedBuilder`。[Animations tutorial](https://docs.flutter.dev/ui/animations/tutorial)（查阅：2026-08-30）
- 一个 staggered animation 可以由一个 controller 驱动多个 Animation，每个属性用自己的 Tween，并通过 `Interval` 占据 0～1 时间轴的不同片段；片段可以顺序、重叠或留空。不要为同一段确定时间轴默认创建多个 controller。[Staggered animations](https://docs.flutter.dev/ui/animations/staggered-animations) · [Interval API](https://api.flutter.dev/flutter/animation/Interval-class.html)（查阅：2026-08-30）
- 植物照护台只需要一次有限的状态过渡，不做永久循环的装饰动画。显式动画可用一个 controller 编排“状态标记出现—卡片轻微位移—操作反馈结束”，reduced motion 时跳过位移并立即展示最终状态。

## 8. 测试这些行为

### 8.1 状态与生命周期

- `WidgetTester` 运行在 `FakeAsync` 区域，`pump(duration)` 会主动推进测试时钟，而不是现实中等待同样时长。timer 与动画测试应通过 pump 控制时间，保证快速、确定。[WidgetTester API](https://api.flutter.dev/flutter/flutter_test/WidgetTester-class.html) · [widget_tester.dart 3.47.0](https://github.com/flutter/flutter/blob/3.47.0/packages/flutter_test/lib/src/widget_tester.dart#L508-L655)（查阅：2026-08-30）
- timer 生命周期测试应先挂载组件并推进一次 tick，再用另一个 Widget 替换整棵待测子树触发 `dispose`，继续推进时间，验证回调不再改变可观察状态且 `tester.takeException()` 为空。不要只直接调用 `dispose` 方法；Widget 测试应让框架驱动生命周期。
- `ChangeNotifier` 的纯逻辑测试不需要 Widget 测试。可注册计数 listener，验证真实变化通知一次、无变化不通知、派生 getter 与源状态一致；Widget 测试再验证 `ListenableBuilder` 或 inherited 依赖者显示了新值。[Simple app state management: ChangeNotifier test](https://docs.flutter.dev/data-and-backend/state-mgmt/simple#changenotifier)（查阅：2026-08-30）

### 8.2 Key 与重排

- 重点项目测试要先制造“身份可见的本地状态”，再重排并按 `ValueKey(member.id)` 查找。只检查模型列表已重排，无法证明 Element 与 State 没有错配。[CommonFinders.byKey API](https://api.flutter.dev/flutter/flutter_test/CommonFinders/byKey.html) · [ValueKey API](https://api.flutter.dev/flutter/foundation/ValueKey-class.html)（查阅：2026-08-30）
- 至少覆盖向前、向后、首项、末项和无效边界；键盘上移 / 下移与拖动回调应调用同一个纯重排函数。这样既能验证 3.47 `onReorderItem` 索引语义，也不会把浏览器拖拽手势当作唯一验收路径。[ReorderableListView.onReorderItem API](https://api.flutter.dev/flutter/material/ReorderableListView/onReorderItem.html)（查阅：2026-08-30）

### 8.3 动画与 reduced motion

- 动画测试应断言起点、中间值和终点：触发状态变化后先 `pump()` 取得起点，再推进一半时长检查中间状态，最后推进剩余时间检查终点。它验证的是确定的时间—状态关系，不依赖真实等待。[WidgetTester.pump API](https://api.flutter.dev/flutter/flutter_test/WidgetTester/pump.html)（查阅：2026-08-30）
- `pumpAndSettle` 会持续 pump 到没有计划帧；无限动画会超时。官方建议知道每一帧为何需要时，精确 pump 所需帧数，以捕获动画晚一帧启动等回归。第三部分动画测试默认使用明确时长，不把 `pumpAndSettle` 当万能等待。[WidgetTester.pumpAndSettle API](https://api.flutter.dev/flutter/flutter_test/WidgetTester/pumpAndSettle.html) · [controller.dart 3.47.0](https://github.com/flutter/flutter/blob/3.47.0/packages/flutter_test/lib/src/controller.dart#L1531-L1560)（查阅：2026-08-30）
- reduced motion 测试分两层：用覆盖后的 `MediaQueryData.disableAnimations` 验证项目自定义分支不产生非必要位移或循环；需要验证 `AnimationController` 框架降速时，再设置 `tester.platformDispatcher.accessibilityFeaturesTestValue`。两类测试不能互相替代。[MediaQueryData.disableAnimations API](https://api.flutter.dev/flutter/widgets/MediaQueryData/disableAnimations.html) · [FakeAccessibilityFeatures API](https://api.flutter.dev/flutter/flutter_test/FakeAccessibilityFeatures-class.html)（查阅：2026-08-30）

## 9. 建议的七章顺序与深度

| 章节 | 主问题 | 讲透的内容 | 本章暂不展开 |
| --- | --- | --- | --- |
| 03-01 状态放在哪里 | 一个值由谁拥有，哪些值不该重复存 | 临时 / 应用状态的条件、最近共同拥有者、受控组件、派生状态、`setState` 标记范围 | Riverpod、ViewModel、持久化、异步状态 |
| 03-02 生命周期与副作用 | 资源何时创建、替换、取消和释放 | `initState` / `didChangeDependencies` / `didUpdateWidget` / `dispose`、三段式订阅、timer、mounted、context 异步间隙 | HTTP 竞态、应用前后台完整生命周期 |
| 03-03 Element 身份、Key 与重排 | 为什么重排后输入跑到另一行 | `Widget.canUpdate`、位置匹配、四类 Key、key 放置层级、3.47 `onReorderItem`；完成可排序值班板 | Widget—Element—RenderObject 全链路、GlobalKey 高级用法 |
| 03-04 Listenable、ChangeNotifier 与 InheritedWidget | 通知变化与跨层获取分别怎么做 | inherited dependency、`updateShouldNotify`、Listenable 订阅、notifier 所有权、`ListenableBuilder`、`InheritedNotifier` | provider、Riverpod、应用架构分层 |
| 03-05 隐式动画 | 状态变化如何自动过渡 | target、Tween、curve、duration、中断后的连续过渡、布局与绘制差异、reduced motion | 自定义 `ImplicitlyAnimatedWidget` 完整实现、物理动画 |
| 03-06 显式动画与过渡 | 何时需要主动控制时间轴 | controller / ticker 生命周期、transition、`AnimatedBuilder.child`、Interval stagger、取消、精确动画测试 | Hero、路由转场、自定义 Simulation、性能 trace |
| 03-07 统筹项目 | 能否把状态、身份、资源与动画放在正确边界 | 植物照护台完整任务与 Web 验收 | 新框架概念 |

这组顺序有四条依赖：

1. 先判断状态所有权，生命周期章节才知道哪个 `State` 应创建和释放资源。[Ephemeral state and app state](https://docs.flutter.dev/data-and-backend/state-mgmt/ephemeral-vs-app) · [State API](https://api.flutter.dev/flutter/widgets/State-class.html)（查阅：2026-08-30）
2. 先理解同一 State 如何在 Widget 配置更新之间存活，再解释 Key 改变匹配身份；否则 Key 容易被记成“列表必须加的字符串”。[Widget.canUpdate API](https://api.flutter.dev/flutter/widgets/Widget/canUpdate.html)（查阅：2026-08-30）
3. 先学会手工订阅和释放 Listenable，再引入内部拥有 controller 的隐式动画，读者能看懂它替自己管理了什么。[ListenableBuilder API](https://api.flutter.dev/flutter/widgets/ListenableBuilder-class.html) · [ImplicitlyAnimatedWidget API](https://api.flutter.dev/flutter/widgets/ImplicitlyAnimatedWidget-class.html)（查阅：2026-08-30）
4. 先用隐式动画建立 Tween、curve 与 target，再增加 controller、Ticker 和 stagger，避免第一段动画代码同时引入过多资源管理概念。[Implicit animations](https://docs.flutter.dev/ui/animations/implicit-animations) · [Animations tutorial](https://docs.flutter.dev/ui/animations/tutorial)（查阅：2026-08-30）

## 10. 两个项目的内容边界

### 10.1 重点项目：可排序值班板

项目集中证明 03-02 与 03-03：

- 每位成员拥有稳定业务 ID，列表顶层行使用 `ValueKey(member.id)`；
- 行内备注或交接状态保留在行的 State，用来显式观察重排后的身份；
- 列表顺序由上层页面拥有，拖动、上移和下移调用同一个纯重排函数；
- 使用 3.47 的 `onReorderItem`，不保留旧 `onReorder` 的索引减一逻辑；
- 短 timer 或临时订阅用于演示资源释放，但不引入网络、持久化或全局状态包；
- Widget 测试先修改行内状态，再重排并按 ID 验证归属；Chrome 关键流程同时覆盖拖动和无指针替代操作。

界面不能直接模仿官方 ReorderableListView 示例。可采用“轮值轨道 / 交接台”题材，显示时段、角色、交接备注和当前值守状态；拖动只是操作之一，主要学习证据是身份没有错位。

### 10.2 统筹项目：植物照护台

项目把本部分能力集中在一次本地任务流中：

- 植物、照护记录和筛选条件各有一个明确所有者；完成数量、逾期分组和可见列表按需派生；
- 本地 notifier 只覆盖多个后代共同需要的筛选或照护状态，页面不提前使用 Riverpod；
- 植物卡使用稳定 ID key，筛选、撤销和重新排序后状态仍对应同一植物；
- 一次有限的隐式状态过渡和一段可控显式反馈都由真实照护动作触发；controller、timer 与 listener 都随所有者释放；
- reduced motion 下取消非必要位移和循环，状态、图标与文本立即到达最终结果；
- 测试覆盖状态派生、notifier 通知、筛选后的身份、撤销、动画起中终点和 reduced motion 分支。

该项目只保存在内存中。记录持久化、网络同步、异步失败和离线恢复属于第四部分；不能为了凑“加载 / 错误”状态制造不存在的服务。动画也不承担唯一信息通道，照护完成与撤销必须有文本或语义状态。

## 11. 写作时必须避免的误讲

| 容易写成 | 应改成 |
| --- | --- |
| “临时状态只能用 `setState`，应用状态不能用” | 这是概念分类与常见选择，不是 API 禁令；归属取决于共享、恢复和生命周期要求。 |
| “所有状态都要尽量上移” | 放到所有真实使用者的最近共同拥有者，不把纯行内 hover 或动画进度抬到应用根部。 |
| “筛选结果也要存进 State，读取更快” | 便宜且确定的结果从源列表和筛选条件派生；缓存需要明确失效规则。 |
| “`setState` 会重建整个应用” | 它标记当前 State 对应 Element 需要重建，可能继续影响其子树。 |
| “`setState` 里可以直接 `await`” | 回调必须同步；异步工作在外部完成，再同步写入状态。 |
| “`mounted` 检查就解决了泄漏” | mounted 只判断能否使用 State / context；timer、listener 和动画仍应在 `dispose` 中取消。 |
| “`dispose` 一定会在应用退出时调用” | 进程可能直接终止；不能把它当作可靠持久化钩子。 |
| “State 跟着 Widget 对象移动” | Element 按 `runtimeType + key` 匹配配置；无 key 的同类型兄弟通常按位置匹配。 |
| “列表加任意 key 就不会错位” | key 必须稳定、同级唯一，并放在参与兄弟匹配的顶层行上。 |
| “`UniqueKey()` 最保险” | 每次重建生成新 key 会强制新身份，恰好破坏状态保留。 |
| “`GlobalKey` 是更强的 `ValueKey`” | 它全局唯一、可移动子树并访问 State，成本和约束都更高；普通列表不用。 |
| “旧版 `onReorder` 的 `newIndex -= 1` 是固定模板” | Flutter 3.47 使用 `onReorderItem`，目标索引已调整。 |
| “`InheritedWidget` 就是状态管理对象” | 它负责沿子树传播并登记依赖；可变通知由 Listenable / ChangeNotifier 等对象负责。 |
| “`notifyListeners` 会告诉监听者改了哪个字段” | 回调无参数，只表示对象可能变化；消费者重新读取所需属性。 |
| “用 `ListenableBuilder` 就自动管理 notifier 生命周期” | builder 管订阅；notifier 仍由创建它的所有者 dispose。 |
| “隐式动画会动画 child 里的所有变化” | 它只插值自身声明支持且非 null 的目标属性，child 后代不会自动动画。 |
| “Tween 和 Curve 都是缓动” | Tween 把进度映射成目标类型的值；Curve 改变时间进度。 |
| “TickerMode 关闭就是暂停动画” | ticker 被静音但时间继续流逝，重新启用后不保证从旧画面值续播。 |
| “系统减少动态效果时 controller 会完全不动” | 默认 `AnimationBehavior.normal` 把时长缩到 5%；项目仍需显式删除非必要位移和循环。 |
| “动画测试都用 `pumpAndSettle`” | 明确推进起点、中间值和终点；无限动画无法 settle，自动 settle 还可能隐藏多一帧回归。 |

这些更正分别对应 Flutter 的声明式状态、`State` 生命周期、Widget 更新匹配、通知机制和动画合同。[Start thinking declaratively](https://docs.flutter.dev/data-and-backend/state-mgmt/declarative) · [State API](https://api.flutter.dev/flutter/widgets/State-class.html) · [Widget.canUpdate API](https://api.flutter.dev/flutter/widgets/Widget/canUpdate.html) · [ChangeNotifier API](https://api.flutter.dev/flutter/foundation/ChangeNotifier-class.html) · [Animations API overview](https://docs.flutter.dev/ui/animations/overview)（查阅：2026-08-30）

## 12. 正文参考资料清单

章节页尾只列实际使用的来源，不必把本清单整段复制过去。

- [Flutter 3.47.0 release notes](https://docs.flutter.dev/release/release-notes/release-notes-3.47.0)（查阅：2026-08-30）
- [Start thinking declaratively](https://docs.flutter.dev/data-and-backend/state-mgmt/declarative)（查阅：2026-08-30）
- [Ephemeral state and app state](https://docs.flutter.dev/data-and-backend/state-mgmt/ephemeral-vs-app)（查阅：2026-08-30）
- [Simple app state management](https://docs.flutter.dev/data-and-backend/state-mgmt/simple)（查阅：2026-08-30）
- [Add interactivity](https://docs.flutter.dev/ui/interactivity)（查阅：2026-08-30）
- [State API](https://api.flutter.dev/flutter/widgets/State-class.html)（查阅：2026-08-30）
- [State.setState API](https://api.flutter.dev/flutter/widgets/State/setState.html)（查阅：2026-08-30）
- [State.mounted API](https://api.flutter.dev/flutter/widgets/State/mounted.html)（查阅：2026-08-30）
- [BuildContext.mounted API](https://api.flutter.dev/flutter/widgets/BuildContext/mounted.html)（查阅：2026-08-30）
- [use_build_context_synchronously](https://dart.dev/tools/linter-rules/use_build_context_synchronously)（查阅：2026-08-30）
- [Timer.cancel API](https://api.dart.dev/dart-async/Timer/cancel.html)（查阅：2026-08-30）
- [Widget.canUpdate API](https://api.flutter.dev/flutter/widgets/Widget/canUpdate.html)（查阅：2026-08-30）
- [Key API](https://api.flutter.dev/flutter/foundation/Key-class.html)（查阅：2026-08-30）
- [ValueKey API](https://api.flutter.dev/flutter/foundation/ValueKey-class.html)（查阅：2026-08-30）
- [ObjectKey API](https://api.flutter.dev/flutter/widgets/ObjectKey-class.html)（查阅：2026-08-30）
- [UniqueKey API](https://api.flutter.dev/flutter/foundation/UniqueKey-class.html)（查阅：2026-08-30）
- [GlobalKey API](https://api.flutter.dev/flutter/widgets/GlobalKey-class.html)（查阅：2026-08-30）
- [ReorderableListView API](https://api.flutter.dev/flutter/material/ReorderableListView-class.html)（查阅：2026-08-30）
- [ReorderableListView.onReorderItem API](https://api.flutter.dev/flutter/material/ReorderableListView/onReorderItem.html)（查阅：2026-08-30）
- [InheritedWidget API](https://api.flutter.dev/flutter/widgets/InheritedWidget-class.html)（查阅：2026-08-30）
- [BuildContext.dependOnInheritedWidgetOfExactType API](https://api.flutter.dev/flutter/widgets/BuildContext/dependOnInheritedWidgetOfExactType.html)（查阅：2026-08-30）
- [InheritedNotifier API](https://api.flutter.dev/flutter/widgets/InheritedNotifier-class.html)（查阅：2026-08-30）
- [ChangeNotifier API](https://api.flutter.dev/flutter/foundation/ChangeNotifier-class.html)（查阅：2026-08-30）
- [ListenableBuilder API](https://api.flutter.dev/flutter/widgets/ListenableBuilder-class.html)（查阅：2026-08-30）
- [Implicit animations](https://docs.flutter.dev/ui/animations/implicit-animations)（查阅：2026-08-30）
- [AnimatedContainer API](https://api.flutter.dev/flutter/widgets/AnimatedContainer-class.html)（查阅：2026-08-30）
- [AnimatedPositioned API](https://api.flutter.dev/flutter/widgets/AnimatedPositioned-class.html)（查阅：2026-08-30）
- [Animations API overview](https://docs.flutter.dev/ui/animations/overview)（查阅：2026-08-30）
- [Animations tutorial](https://docs.flutter.dev/ui/animations/tutorial)（查阅：2026-08-30）
- [AnimationController API](https://api.flutter.dev/flutter/animation/AnimationController-class.html)（查阅：2026-08-30）
- [AnimatedBuilder API](https://api.flutter.dev/flutter/widgets/AnimatedBuilder-class.html)（查阅：2026-08-30）
- [Tween API](https://api.flutter.dev/flutter/animation/Tween-class.html)（查阅：2026-08-30）
- [CurvedAnimation API](https://api.flutter.dev/flutter/animation/CurvedAnimation-class.html)（查阅：2026-08-30）
- [Staggered animations](https://docs.flutter.dev/ui/animations/staggered-animations)（查阅：2026-08-30）
- [MediaQueryData.disableAnimations API](https://api.flutter.dev/flutter/widgets/MediaQueryData/disableAnimations.html)（查阅：2026-08-30）
- [AnimationBehavior API](https://api.flutter.dev/flutter/animation/AnimationBehavior.html)（查阅：2026-08-30）
- [WidgetTester API](https://api.flutter.dev/flutter/flutter_test/WidgetTester-class.html)（查阅：2026-08-30）
- [WidgetTester.pumpAndSettle API](https://api.flutter.dev/flutter/flutter_test/WidgetTester/pumpAndSettle.html)（查阅：2026-08-30）
