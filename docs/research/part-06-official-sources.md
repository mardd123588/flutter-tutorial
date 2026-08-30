# 第六部分官方资料研究：应用架构与生态主方案

> 查阅日期：2026-08-30
> 教程基线：Flutter 3.47.0、Dart 3.13.0
> 依赖基线：`flutter_riverpod 3.4.2`、`riverpod 3.4.2`；按需使用 `riverpod_annotation 4.0.6`、`riverpod_generator 4.0.8`、`build_runner 2.16.0`
> 资料范围：Flutter / Dart 官方文档与 API、Riverpod 官方文档与仓库、pub.dev 与 Dart Pub 官方规范

这份笔记只确定第六部分的知识边界、章节依赖、主方案和项目合同，不写教程正文，也不预先创建示例项目。下文把 SDK、包和规范规定写成“官方事实”，把章节拆分、迁移顺序和项目功能写成“课程决定”。

## 1. 固定边界与版本基线

### 1.1 仓库里的决定不再重选

- GitHub Issue #1 已固定第六部分为 8 章，顺序是复杂度信号、应用分层、Result 与命令、Riverpod 基础、异步组合、依赖替换、代码生成与包选择、统筹项目。本研究只细化边界，不改变章数、顺序和 `requires` / `provides`。[首版规格 #1](https://github.com/mardd123588/flutter-tutorial/issues/1)（查阅：2026-08-30）
- [ADR-0006](../adr/0006-progressive-application-architecture.md) 固定采用 View、ViewModel、Repository、Service 与单向数据流，只在复杂业务确有需要时增加 domain 层；不能给小例子预装完整 Clean Architecture。
- [ADR-0009](../adr/0009-riverpod-as-production-state-stack.md) 固定 Riverpod 3 为状态主方案。SDK 状态基础已经在第三部分讲过；第六部分不再平行维护 provider、BLoC、signals 或 hooks 教程。
- [ADR-0004](../adr/0004-tested-source-drives-code-snippets.md) 与 [ADR-0005](../adr/0005-independent-practice-projects.md) 继续生效：正文项目片段来自已测试源码；“社区工坊排期台”不共享其他项目的业务代码或 UI 包。

### 1.2 Riverpod 当前稳定线

- `riverpod` 与 `flutter_riverpod` 当前稳定版均为 3.4.2，发布于 2026-07-28。`riverpod 3.4.2` 要求 Dart `^3.12.0`；`flutter_riverpod 3.4.2` 要求 Flutter `>=3.0.0`，并精确依赖 `riverpod 3.4.2`。Flutter 3.47 / Dart 3.13 满足约束。[riverpod 3.4.2](https://pub.dev/packages/riverpod/versions/3.4.2) · [flutter_riverpod 3.4.2](https://pub.dev/packages/flutter_riverpod/versions/3.4.2) · [3.4.2 pubspec](https://github.com/rrousselGit/riverpod/blob/3104958b1364b041be6c1d637880d5d3756ddceb/packages/riverpod/pubspec.yaml)（查阅：2026-08-30）
- Riverpod 3 已把 `StateProvider`、`StateNotifierProvider` 与 `ChangeNotifierProvider` 移到 `legacy.dart`。这些 API 尚未删除，但官方明确引导新代码使用 `Notifier` API；本部分不把 legacy provider 当作主线。[Riverpod 3 migration](https://riverpod.dev/docs/3.0_migration)（查阅：2026-08-30）
- Riverpod 3 的 `Ref` 不再带泛型，`ProviderRef`、`FutureProviderRef` 等子类已经移除；`AutoDisposeNotifier`、`FamilyNotifier` 等复制接口也已移除。auto-dispose 与 family 功能仍存在，只是改用统一接口和 provider 构造参数表达。[Riverpod 3 migration](https://riverpod.dev/docs/3.0_migration)（查阅：2026-08-30）

正文和项目固定使用 Riverpod 3.4.2 语法。搜索资料时若看到 `StateNotifierProvider`、带泛型的 `Ref`、`AutoDisposeAsyncNotifier` 或 `FamilyAsyncNotifier`，先按 3.0 迁移文档核对，不直接搬入正文。

## 2. 应用架构解决什么问题

### 2.1 官方建议的稳定骨架

- Flutter 官方把关注点分离视为应用架构的首要原则：应用至少分成 UI 层与 data 层，复杂客户端业务才增加可选 logic / domain 层；层内再按功能拆分。[Common architecture concepts](https://docs.flutter.dev/app-architecture/concepts) · [Architecture recommendations](https://docs.flutter.dev/app-architecture/recommendations)（查阅：2026-08-30）
- UI 层显示数据、接收用户输入；data 层管理数据库、平台插件或远程 API 等数据源。相邻层通过明确输入输出通信，UI 不应直接知道 Service 的存在。[Common architecture concepts](https://docs.flutter.dev/app-architecture/concepts)（查阅：2026-08-30）
- 单一事实来源要求一种可修改数据只有一个负责写入的地方。官方通常把某类模型数据的单一事实来源放在 Repository；派生值通过 getter、组合或转换得到，不再保存第二份需同步更新的字段。[Common architecture concepts](https://docs.flutter.dev/app-architecture/concepts)（查阅：2026-08-30）
- 单向数据流中，状态从 data 层流向 UI，用户事件沿相反方向交给逻辑与 data 层处理；数据修改仍发生在单一事实来源。Flutter 的声明式 UI 再根据不可变状态重建。[Common architecture concepts](https://docs.flutter.dev/app-architecture/concepts)（查阅：2026-08-30）
- 官方架构指南明确说这些是适用于多数应用的指导原则，不是不可调整的硬规则。课程应根据项目复杂度逐层增加结构，而不是用目录数量证明“架构完整”。[Guide to app architecture](https://docs.flutter.dev/app-architecture/guide)（查阅：2026-08-30）

课程使用下面这条依赖方向：

```text
View
  ↓ 用户意图      ↑ 不可变 UI state
ViewModel
  ↓ 数据操作      ↑ domain model / Result
[可选 domain policy / use-case]
  ↓
Repository（单一事实来源）
  ↓
Service（单一外部数据源适配）
```

Riverpod provider 负责创建、组合、缓存和替换这些对象，不另算一个业务层。`AsyncValue` 描述 provider 的异步执行状态，也不取代 Repository 的单一事实来源。

### 2.2 何时值得分层

以下是课程用于判断复杂度的信号，不是 Flutter 强制规则：

1. 一个 Widget 同时解析输入、访问 I/O、处理错误、改缓存并拼显示文本；
2. 同一份业务数据在页面状态对象、ViewModel 和数据库各有可写副本；
3. 两个以上页面需要相同数据或相同写入规则；
4. 保存、刷新、删除等动作各自有运行中、失败、重试和重复点击边界；
5. 为测试一条业务规则，必须启动完整 Widget 树或真实数据库；
6. 替换 fixture、内存实现与真实实现时，要改调用方代码；
7. 一个 ViewModel 需要组合多个 Repository，且组合规则被多个 ViewModel 重复使用。

只有局部开关、输入框草稿或一次性动画时，`StatefulWidget`、`ValueNotifier` 或小型 `ChangeNotifier` 仍足够。出现前五类信号后，先提取责任和依赖接缝；只有第七类信号持续出现，才考虑 domain use-case。

### 2.3 渐进迁移顺序

课程中的迁移必须保留可运行基线，每一步都能单独测试：

1. 先为现有页面补最小行为测试，记录加载、空、成功、失败和提交结果；
2. 标出页面里的 UI state、业务数据、派生数据、I/O 和一次性副作用；
3. 把 HTTP、数据库或平台调用提到 Service，并用构造函数接收依赖；
4. 把缓存、重试、模型转换和写入规则提到 Repository，确定单一事实来源；
5. 把页面所需的排序、组合、命令状态提到 ViewModel；
6. 对可预期失败引入 Result，对异步动作引入明确的 command 状态；
7. 先用普通构造函数完成对象图，再用 Riverpod provider 接管创建与生命周期；
8. 只把确有共享、异步组合或替换收益的状态迁到 `Notifier` / `AsyncNotifier`；
9. 参数缓存和页面离开后的资源释放确有需要时，再加入 family 与 auto-dispose；
10. 测量到无关重建后才用 `select`，项目已有生成链路且 family 声明确实重复时才用代码生成。

不得一次性把目录、模型、状态包、错误类型和测试全部重写。迁移前后的用户行为、Repository 接口或 View state 至少保住其中两个稳定点，才能判断哪一步造成回归。

## 3. View、ViewModel、Repository 与 Service

### 3.1 View 与 ViewModel

- Flutter 官方把 View 定义为组成一个功能的 Widget 集合，不要求“一页一个 Widget”。View 接收渲染所需数据并把用户事件转交给 ViewModel；允许保留简单显隐、动画、布局和路由逻辑，不放业务数据逻辑。[Guide to app architecture: UI layer](https://docs.flutter.dev/app-architecture/guide#ui-layer)（查阅：2026-08-30）
- ViewModel 把 Repository 数据转换成适合 View 的 UI state，负责筛选、排序、聚合和页面状态，并向 View 暴露 command。官方建议一个 View 与一个 ViewModel 对应，这里的 View 是一个 Widget 组合，不是每个叶子 Widget。[Guide to app architecture: View models](https://docs.flutter.dev/app-architecture/guide#view-models)（查阅：2026-08-30）
- 官方强烈建议 UI / data 分层、View / ViewModel、Repository 和不在 Widget 中放业务逻辑；`ChangeNotifier` / `Listenable` 只是条件性选择，因为状态管理实现不止一种。[Architecture recommendation data](https://github.com/flutter/website/blob/main/sites/docs/src/data/architectureRecommendations.yml)（查阅：2026-08-30）

课程把 Riverpod 的 `Notifier` / `AsyncNotifier` 当作 ViewModel 的一种实现。类名仍按业务职责命名为 `ScheduleBoardViewModel`、`WorkshopEditorViewModel` 等，不把所有对象都命名为 `SomethingProvider`，也不让 Widget 直接调用 Repository。

### 3.2 Repository 与 Service

- Repository 是模型数据的单一事实来源，负责从 Service 取得原始数据并转换成 domain model；缓存、错误处理、重试、刷新和轮询等数据策略也属于 Repository。[Guide to app architecture: Repositories](https://docs.flutter.dev/app-architecture/guide#repositories)（查阅：2026-08-30）
- Repository 与 ViewModel 可以多对多，但 Repository 不应互相依赖。需要组合多个 Repository 的规则先放 ViewModel；规则复杂、复用或挤占多个 ViewModel 时才提取到可选 domain 层。[Guide to app architecture: Repositories](https://docs.flutter.dev/app-architecture/guide#repositories) · [Optional domain layer](https://docs.flutter.dev/app-architecture/guide#optional-domain-layer)（查阅：2026-08-30）
- Service 位于最低层，用来隔离一种外部数据源，通常暴露 `Future` 或 `Stream`。官方指南要求 Service 不持有应用状态，并建议每个数据源一个 Service；平台 API、REST endpoint 和本地文件都属于这类边界。[Guide to app architecture: Services](https://docs.flutter.dev/app-architecture/guide#services)（查阅：2026-08-30）
- 可选 domain use-case 适合三类情况：需要合并多个 Repository、逻辑明显复杂、同一逻辑被多个 ViewModel 复用。多数 CRUD 功能不需要额外 domain 层。[Guide to app architecture: Optional domain layer](https://docs.flutter.dev/app-architecture/guide#optional-domain-layer)（查阅：2026-08-30）

课程用责任而不是文件名判层：

| 代码 | 放置位置 | 不应承担 |
| --- | --- | --- |
| 根据宽度选择 rail / drawer、显示错误文本 | View | SQL、JSON、冲突规则 |
| 组合排期、管理筛选和保存动作状态 | ViewModel | 直接打开 Drift、拼 SQL |
| 判断两个时间段是否冲突 | domain policy 或纯函数 | 显示 SnackBar、读 BuildContext |
| 维护排期单一事实来源、事务、缓存与错误映射 | Repository | 布局、焦点、路由 |
| 包装 Drift 查询或平台 API | Service | 决定页面 loading / empty 文案 |

### 3.3 依赖注入先从构造函数开始

- Flutter 架构案例用构造函数把 Service 传给 Repository、把 Repository 传给 ViewModel。依赖注入解决“对象在哪里创建并如何接线”，不等于必须使用某个容器包。[Communicating between layers](https://docs.flutter.dev/app-architecture/case-study/dependency-injection)（查阅：2026-08-30）
- 官方案例用 `package:provider` 完成接线，但同一架构指南明确把状态管理实现视为可替换选择。仓库已经通过 ADR 选择 Riverpod，因此只复用构造函数边界和依赖方向，不复制 provider 实现。[Dependency injection case study](https://docs.flutter.dev/app-architecture/case-study/dependency-injection) · [Architecture recommendation data](https://github.com/flutter/website/blob/main/sites/docs/src/data/architectureRecommendations.yml)（查阅：2026-08-30）
- 官方测试案例中，ViewModel 单元测试只替换 Repository，Repository 单元测试只替换 Service；View Widget 测试复用相同 fake。清晰输入输出让每层能单独测试，也能组合测试。[Testing each layer](https://docs.flutter.dev/app-architecture/case-study/testing)（查阅：2026-08-30）

课程先展示普通 Dart 构造函数和接口，再用 `Provider` 声明对象图。这样即使将来替换 Riverpod，Repository 与 Service 的 API 也不需要跟着改。

## 4. SDK notifier 的适用边界

### 4.1 `ValueNotifier`

- `ValueNotifier<T>` 保存一个值；只有新值与旧值按 `==` 比较不相等时才通知监听者。原地修改 `ValueNotifier<List<int>>` 的现有 List 不会触发通知，因此官方建议它配合不可变数据使用。[ValueNotifier 3.47.0 source](https://github.com/flutter/flutter/blob/3.47.0/packages/flutter/lib/src/foundation/change_notifier.dart#L539-L592)（查阅：2026-08-30）
- `ValueListenableBuilder` 可在值变化时重建局部 Widget，并把不依赖值的子树放进 `child` 以避免重复构建。[ValueListenableBuilder](https://api.flutter.dev/flutter/widgets/ValueListenableBuilder-class.html)（查阅：2026-08-30）

课程只在一个不可变值、一个明确所有者和一个很小的订阅面同时成立时使用 `ValueNotifier`。复合可写状态、依赖组合、异步缓存和测试替换不再硬塞进单值容器。

### 4.2 `ChangeNotifier`

- `ChangeNotifier` 实现 `Listenable`，添加监听者是 O(1)，移除和分发通知是 O(N)。它只发出“发生变化”的通知，不携带变更字段。[ChangeNotifier 3.47.0 source](https://github.com/flutter/flutter/blob/3.47.0/packages/flutter/lib/src/foundation/change_notifier.dart#L104-L141)（查阅：2026-08-30）
- notifier 由所有者调用 `dispose()`；释放后对象不可再使用，继续 `addListener` 会在调试期抛错。`dispose` 本身不通知监听者。[ChangeNotifier.dispose](https://api.flutter.dev/flutter/foundation/ChangeNotifier/dispose.html)（查阅：2026-08-30）
- Flutter 官方仍把 `ChangeNotifier` / `Listenable` 作为方便的 SDK 方案，但在架构建议里标为 conditional，因为状态管理选择取决于项目。它适合小型 ViewModel、SDK 对接和已有代码迁移，不是所有生产状态的强制实现。[Architecture recommendation data](https://github.com/flutter/website/blob/main/sites/docs/src/data/architectureRecommendations.yml)（查阅：2026-08-30）

06-02 与 06-03 可以继续用已学过的 `ChangeNotifier` 说明分层和命令，因为读者能看清对象所有权。06-04 再把同一功能迁到 Riverpod，比较的是创建、依赖、生命周期、局部订阅和测试替换，不把 `ChangeNotifier` 描述成错误方案。

## 5. Result、错误类型与命令

### 5.1 Result 处理可预期失败

- Dart 方法可以抛出任何非 null 对象，调用方不需要在类型签名中声明或捕获异常。Dart 区分 `Exception` 与 `Error` 的使用意图：Exception 通常表示可处理问题，Error 通常表示程序缺陷。[Dart error handling](https://dart.dev/language/error-handling) · [Exception](https://api.dart.dev/dart-core/Exception-class.html) · [Error](https://api.dart.dev/dart-core/Error-class.html)（查阅：2026-08-30）
- Flutter 官方 Result pattern 用 sealed `Result<T>` 把返回值包装为 `Ok<T>` 或 `Error<T>`，迫使调用方通过模式匹配处理成功和失败，减少跨 Service、Repository、ViewModel 的隐式异常路径。[Error handling with Result objects](https://docs.flutter.dev/app-architecture/design-patterns/result)（查阅：2026-08-30）
- 官方示例在 Service 边界捕获 HTTP 与解析 Exception，再返回 Result；Repository 可以组合多个 Result，ViewModel 最终把结果转换成 UI state。[Error handling with Result objects](https://docs.flutter.dev/app-architecture/design-patterns/result)（查阅：2026-08-30）

课程把错误分成三类：

| 类型 | 表达方式 | 例子 |
| --- | --- | --- |
| 可预期业务失败 | sealed failure + `Result` | 时间冲突、场馆容量不足、记录不存在 |
| 可恢复基础设施失败 | Repository 映射后的 `Result` | 数据库暂时不可用、写入失败 |
| 程序缺陷 / 不变量破坏 | Error、assert 或未捕获异常 | 不可达分支、错误类型转换 |

错误对象保存稳定类别与诊断上下文，不直接保存面向用户的中文句子。View 根据错误类别生成文案、焦点和恢复动作；日志与测试仍能判断原始类别。不要 `catch (Object)` 后把所有失败都改成“请重试”。

### 5.2 `AsyncValue` 与 Result 不重复

`Result` 表达一次业务操作的成功或可预期失败；`AsyncValue` 表达 provider 当前的异步加载、旧值、刷新和异常状态。Repository 返回 `Result<DomainModel>` 后，ViewModel 仍可用 `AsyncValue` 管理加载过程。冲突不应伪装成 provider 崩溃，编程错误也不应被普通业务 Result 吞掉。

### 5.3 Command 把动作状态收在一起

- Flutter 官方 Command pattern 把异步动作、`running` 与最近一次 Result 放在一个对象中，使 View 只调用 command，不知道 Repository 实现。官方示例在 command 已运行时直接返回，避免重复点击并发启动同一动作。[Command pattern](https://docs.flutter.dev/app-architecture/design-patterns/command)（查阅：2026-08-30）
- Command 完成后通过 Result 区分成功与失败，并要求消费方清理一次性结果；它不自动取消底层工作，也不负责跨多个 command 的全局串行化。[Command pattern](https://docs.flutter.dev/app-architecture/design-patterns/command)（查阅：2026-08-30）

06-03 先用普通 Dart / `ChangeNotifier` Command 讲清“动作、运行状态、结果、消费”四件事。迁到 Riverpod 后，公开 Notifier 方法承担 command 入口，状态对象仍显式记录 `idle / running / succeeded / failed`；本部分不使用仍标为 experimental 的 Riverpod Mutations。[Riverpod mutations](https://riverpod.dev/docs/concepts2/mutations)（查阅：2026-08-30）

## 6. Riverpod 3 的核心模型

### 6.1 Provider 与状态容器

- Riverpod provider 是不可变声明，近似带缓存的函数；状态不存放在顶层 provider 变量里，而在 `ProviderContainer` 中。Flutter 的 `ProviderScope` 创建并向 Widget 树暴露容器，因此应用根部需要一个 scope。[Providers](https://riverpod.dev/docs/concepts2/providers) · [ProviderContainers / ProviderScopes](https://riverpod.dev/docs/concepts2/containers)（查阅：2026-08-30）
- `ProviderScope` 可配置 `overrides`、`observers` 与 `retry`。嵌套 scope 能只覆盖子树，但官方把 scoping 视为高级、通常不推荐的能力；课程主线只用根 scope 和测试 / 环境 override。[ProviderScope 3.4.2](https://pub.dev/documentation/flutter_riverpod/3.4.2/flutter_riverpod/ProviderScope-class.html) · [ProviderContainers / ProviderScopes](https://riverpod.dev/docs/concepts2/containers)（查阅：2026-08-30）
- 每个测试创建独立 container 就会得到独立 provider 状态；这也是顶层 provider 声明不等于全局可变单例的原因。[ProviderContainers / ProviderScopes](https://riverpod.dev/docs/concepts2/containers)（查阅：2026-08-30）

### 6.2 `watch`、`read` 与 `listen`

- `ref.watch` 建立声明式依赖，是 Widget 与 provider 组合时的默认选择；被观察状态变化后，消费者或依赖 provider 重新计算。[Refs](https://riverpod.dev/docs/concepts2/refs)（查阅：2026-08-30）
- `ref.read` 适合按钮等事件回调中读取当前值或调用 notifier 方法。官方明确反对用 `read` 逃避重建；需要收窄更新时先测量，再用 `select`。[Refs](https://riverpod.dev/docs/concepts2/refs)（查阅：2026-08-30）
- `ref.listen` 用于对状态变化执行对话框、导航或日志等副作用；Widget 的 `build` 中可安全使用 `WidgetRef.listen`，在 `initState` 等 build 外位置则用 `listenManual`。[Refs](https://riverpod.dev/docs/concepts2/refs)（查阅：2026-08-30）

View 使用 `watch` 渲染状态、在回调里用 `read(provider.notifier)` 发送意图、用 `listen` 消费一次性消息。ViewModel 不接收 `BuildContext`，也不直接显示 SnackBar 或执行导航。

### 6.3 provider 类型按返回值与可写性选择

- Riverpod 3 把 provider 分成同步 / Future / Stream 与只读 / 可修改两组：`Provider`、`FutureProvider`、`StreamProvider` 对外只读；`NotifierProvider`、`AsyncNotifierProvider`、`StreamNotifierProvider` 通过 Notifier 的公开方法修改状态。[Providers](https://riverpod.dev/docs/concepts2/providers)（查阅：2026-08-30）
- `Notifier<T>.build()` 同步返回初始 `T`；`AsyncNotifier<T>.build()` 返回 `FutureOr<T>`，provider 对外暴露 `AsyncValue<T>`。用户事件通过 `ref.read(provider.notifier).method()` 调用公开方法。[Notifier 3.4.2](https://pub.dev/documentation/riverpod/3.4.2/riverpod/Notifier-class.html) · [AsyncNotifier 3.4.2](https://pub.dev/documentation/riverpod/3.4.2/riverpod/AsyncNotifier-class.html)（查阅：2026-08-30）
- Notifier 的初始化逻辑放在 `build()`，不放构造函数。依赖变化时 `build()` 可重新执行，但 notifier 实例不会因此重建；family 的构造函数只保存参数。[Providers](https://riverpod.dev/docs/concepts2/providers) · [Family](https://riverpod.dev/docs/concepts2/family)（查阅：2026-08-30）

课程映射固定为：

| 需求 | 主方案 |
| --- | --- |
| Service、Repository、配置与纯派生值 | `Provider` |
| 只读 Future / Stream 组合 | `FutureProvider` / `StreamProvider` |
| 同步可变 View state | `NotifierProvider` |
| 有异步初始化并接受用户动作 | `AsyncNotifierProvider` |

`StateProvider`、`StateNotifierProvider`、`ChangeNotifierProvider` 只在迁移框中出现，不作为新功能示例。

## 7. 异步状态、缓存与依赖图

### 7.1 `AsyncValue` 不只是三选一

- `AsyncNotifier.build()` 抛出的对象或失败 Future 会被 provider 捕获并转成 `AsyncError`。`AsyncValue` 是 sealed class，核心实现为 `AsyncData`、`AsyncError` 与 `AsyncLoading`。[AsyncNotifier 3.4.2 source](https://github.com/rrousselGit/riverpod/blob/3104958b1364b041be6c1d637880d5d3756ddceb/packages/riverpod/lib/src/providers/async_notifier/orphan.dart) · [AsyncValue 3.4.2](https://pub.dev/documentation/riverpod/3.4.2/riverpod/AsyncValue-class.html)（查阅：2026-08-30）
- `AsyncValue` 可同时携带旧值与 loading / error 标志。刷新失败时不一定需要清空旧列表；正文应检查 `hasValue`、`hasError`、`isLoading` 等组合，而不是假定运行时类型永远互斥。[AsyncValue 3.4.2 source](https://github.com/rrousselGit/riverpod/blob/3104958b1364b041be6c1d637880d5d3756ddceb/packages/riverpod/lib/src/core/async_value.dart)（查阅：2026-08-30）
- `AsyncValue.guard` 可把一次可能失败的 Future 转成 data / error；`AsyncNotifier.build()` 已自动捕获初始化失败，不需要再套一层 guard。[AsyncValue.guard 3.4.2 source](https://github.com/rrousselGit/riverpod/blob/3104958b1364b041be6c1d637880d5d3756ddceb/packages/riverpod/lib/src/core/async_value.dart)（查阅：2026-08-30）

项目必须区分首次加载、保留旧数据的刷新、空结果、首次失败和保留旧数据的刷新失败。预计内的冲突或验证失败仍走 Result，不依赖 `AsyncError` 承载。

### 7.2 Riverpod 3 默认自动重试

- Riverpod 3 默认重试 provider 初始化失败，最多 10 次，退避从 200ms 增至 6.4 秒；默认不重试 `Error` 与 `ProviderException`。provider 或根 `ProviderScope` / `ProviderContainer` 都能定制，回调返回 `null` 表示停止。[Automatic retry](https://riverpod.dev/docs/concepts2/retry)（查阅：2026-08-30）
- 通过 `read` / `watch` 或 `.future` 重新抛出的 provider 失败会包装成 `ProviderException`，`AsyncValue.error` 仍保留原始错误。异常断言应明确测试的是哪一层。[Riverpod 3 migration](https://riverpod.dev/docs/3.0_migration)（查阅：2026-08-30）

06-05 必须让重试策略显式可见。测试不能因为默认重试多执行若干次而偶发失败；本地数据库操作也不应无条件套网络式重试。

### 7.3 family 是参数到独立状态的映射

- family 为每组参数创建独立 provider 状态，可视为参数到缓存值的 Map。参数必须有稳定的 `==` 与 `hashCode`；每次新建且按身份比较的可变 List 不适合作为 key。[Family](https://riverpod.dev/docs/concepts2/family)（查阅：2026-08-30）
- Riverpod 3 移除的是 `FamilyNotifier` 等专用基类，不是 family 功能。手写 class-based family 使用普通 `Notifier` / `AsyncNotifier`，构造函数接收参数，`build()` 不再接参数。[Riverpod 3 migration](https://riverpod.dev/docs/3.0_migration) · [Family](https://riverpod.dev/docs/concepts2/family)（查阅：2026-08-30）
- 3.2 起 class-based family 的 `family.overrideWith` 已弃用，3.4.2 源码提供 `overrideWith2`；functional family 仍使用 `overrideWith((ref, arg) => ...)`。正文若演示 class family override，必须按 3.4.2 API 写。[family.dart 3.4.2](https://github.com/rrousselGit/riverpod/blob/3104958b1364b041be6c1d637880d5d3756ddceb/packages/riverpod/lib/src/core/family.dart) · [Riverpod 3.2.0 changelog](https://github.com/rrousselGit/riverpod/blob/3104958b1364b041be6c1d637880d5d3756ddceb/packages/riverpod/CHANGELOG.md#320)（查阅：2026-08-30）

### 7.4 auto-dispose 是所有权策略

- 手写 provider 默认不自动处置，通过 `isAutoDispose: true` 开启；生成 provider 默认自动处置，通过 `@Riverpod(keepAlive: true)` 关闭。带参数的 provider 建议开启 auto-dispose，否则每组参数都可能长期保留状态。[Automatic disposal](https://riverpod.dev/docs/concepts2/auto_dispose) · [About code generation](https://riverpod.dev/docs/concepts/about_code_generation)（查阅：2026-08-30）
- 最后一个监听者离开时先触发 `ref.onCancel`；一个 frame 后仍无监听者才销毁并触发 `ref.onDispose`，监听者期间返回会触发 `ref.onResume`。provider 因依赖重算时，无论是否 auto-dispose，旧状态都会销毁。[Automatic disposal](https://riverpod.dev/docs/concepts2/auto_dispose)（查阅：2026-08-30）
- `ref.onDispose` 用来关闭 StreamController、Timer 或可取消请求，回调中不应修改其他 provider。`ref.keepAlive()` 可以让成功结果继续保留，返回的 link 可恢复自动处置。[Automatic disposal](https://riverpod.dev/docs/concepts2/auto_dispose)（查阅：2026-08-30）
- 异步间隙后继续写状态前检查 `ref.mounted`。若底层任务支持取消，仍应在 `onDispose` 中取消；`mounted` 只能阻止任务结束后的后续写入。[Ref.mounted 3.4.2](https://pub.dev/documentation/riverpod/3.4.2/riverpod/Ref/mounted.html) · [Ref source 3.4.2](https://github.com/rrousselGit/riverpod/blob/3104958b1364b041be6c1d637880d5d3756ddceb/packages/riverpod/lib/src/core/ref.dart)（查阅：2026-08-30）

### 7.5 失效与选择器

- `ref.invalidate(provider)` 销毁当前状态：仍有监听者时重新创建，无监听者时完全移除。`ref.refresh` 等价于 invalidate 后立即 read；family 可以只失效一组参数，也可以失效全部参数。[Refs](https://riverpod.dev/docs/concepts2/refs) · [Automatic disposal](https://riverpod.dev/docs/concepts2/auto_dispose)（查阅：2026-08-30）
- `select` 只在选出的不可变结果变化时通知消费者；选择可变 List 后原地修改不会触发更新。`selectAsync` 对异步 provider 发出的数据做选择并返回 Future。[Reducing rebuilds](https://riverpod.dev/docs/how_to/select)（查阅：2026-08-30）
- Riverpod 官方要求先测量再使用 `select`，因为它增加代码复杂度并给每次读取带来少量成本。不得把每个 `watch` 都机械改成 `select`。[Reducing rebuilds](https://riverpod.dev/docs/how_to/select)（查阅：2026-08-30）

## 8. Override 与测试替换

- 所有 provider 都能通过 `ProviderScope` 或 `ProviderContainer` 的 `overrides` 替换。普通 provider 使用 `overrideWith` / `overrideWithValue`；测试优先替换 Repository 或 Service provider，不 mock Notifier。[Provider overrides](https://riverpod.dev/docs/concepts2/overrides) · [Testing](https://riverpod.dev/docs/how_to/testing)（查阅：2026-08-30）
- Riverpod 单元测试每例创建新的 `ProviderContainer.test()`；它在测试结束后自动释放。auto-dispose provider 若只 `read` 后等待，状态可能中途销毁，应用 `container.listen` 保持订阅；异步结果可等待 `provider.future`。[Testing](https://riverpod.dev/docs/how_to/testing) · [ProviderContainer.test 3.4.2](https://pub.dev/documentation/riverpod/3.4.2/riverpod/ProviderContainer/ProviderContainer.test.html)（查阅：2026-08-30）
- Widget 测试根部放 `ProviderScope`，可通过 `tester.container()` 取得当前容器。官方不建议 mock Notifier；Notifier 依赖的 Repository 才是稳定替换面。[Testing](https://riverpod.dev/docs/how_to/testing)（查阅：2026-08-30）
- Flutter 官方架构测试建议 ViewModel 测试替换 Repository、Repository 测试替换 Service，并为 View 写 Widget 测试。Riverpod override 是接线方式，不改变分层测试边界。[Testing each layer](https://docs.flutter.dev/app-architecture/case-study/testing)（查阅：2026-08-30）

06-06 只系统讲 provider / ViewModel 的纯状态测试、Repository fake 和 Widget override。测试策略、mock 取舍、golden、浏览器驱动和失败留证仍留到第七部分；项目可以继续执行仓库既有验收命令，但不提前展开工具原理。

## 9. 代码生成与包选择

### 9.1 Riverpod codegen 的真实收益与成本

- Riverpod 代码生成完全可选。官方列出的收益包括按函数返回类型选择 provider、family 支持任意数量与形式的参数、stateful hot reload 和额外调试元数据；成本是增加生成步骤与构建时间。[About code generation](https://riverpod.dev/docs/concepts/about_code_generation)（查阅：2026-08-30）
- 官方在“Should I use code generation?”中的实际建议是：项目已经因 Freezed、`json_serializable` 等使用生成链路时再采用，不要只为 Riverpod 新增生成工具。教程已在第四部分讲过 `build_runner`；“社区工坊排期台”也会因 Drift 在自己的 `pubspec.yaml` 中使用生成链路，但仍只给一处多参数 family 使用 Riverpod codegen。[About code generation](https://riverpod.dev/docs/concepts/about_code_generation)（查阅：2026-08-30）
- 生成 provider 默认 auto-dispose，`@Riverpod(keepAlive: true)` 才改为长期保留；函数 / class 参数自动形成 family，参数仍要保持稳定相等性。[About code generation](https://riverpod.dev/docs/concepts/about_code_generation)（查阅：2026-08-30）

当前稳定依赖如下：

| 包 | 稳定版 | SDK 下限 / 角色 |
| --- | --- | --- |
| `flutter_riverpod` | 3.4.2 | Dart `^3.12.0`、Flutter `>=3.0.0`；Flutter 运行时 |
| `riverpod_annotation` | 4.0.6 | Dart `^3.12.0`；annotation 运行时依赖 |
| `riverpod_generator` | 4.0.8 | Dart `^3.12.0`；dev dependency，精确依赖 annotation 4.0.6 与 Riverpod 3.4.2 |
| `build_runner` | 2.16.0 | Dart `^3.11.0`；dev dependency |

版本与 pubspec 来源：[flutter_riverpod 3.4.2](https://pub.dev/packages/flutter_riverpod/versions/3.4.2) · [riverpod_annotation 4.0.6](https://pub.dev/packages/riverpod_annotation/versions/4.0.6) · [riverpod_generator 4.0.8](https://pub.dev/packages/riverpod_generator/versions/4.0.8) · [build_runner 2.16.0](https://pub.dev/packages/build_runner/versions/2.16.0)（查阅：2026-08-30）

annotation / generator 的 4.x 与 runtime 的 Riverpod 3.4.2 是当前官方组合，不应为了“版本号看起来一致”擅自降级。Riverpod 仓库使用 MIT 许可证。[Riverpod LICENSE](https://github.com/rrousselGit/riverpod/blob/master/LICENSE)（查阅：2026-08-30）

### 9.2 包选择检查表

pub.dev 排名不直接替开发决策：

- Pub 的 version solver 会合并整张依赖图的约束，选择满足约束的较新版本；应用应提交 `pubspec.lock`，让不同环境使用同一组具体版本。[Package versioning](https://dart.dev/tools/pub/versioning)（查阅：2026-08-30）
- `dart pub outdated` 区分 Current、Upgradable、Resolvable 与 Latest；升级后仍要重新测试。Latest 不等于当前依赖图可以解析的版本。[dart pub outdated](https://dart.dev/tools/pub/cmd/pub-outdated)（查阅：2026-08-30）
- pub.dev 的下载量只可视为流行度指标，会受本地缓存、传递依赖和 CI 下载影响；Pub points 衡量文件规范、文档、平台支持、静态分析和依赖新鲜度等维度，评分模型本身会变化。[Package scores and pub points](https://pub.dev/help/scoring)（查阅：2026-08-30）
- pub.dev 会通过传递 import graph 和 pubspec / plugin 声明检测平台支持；页面上的平台标签仍不能代替目标项目的 release build 与真实浏览器验收。[Publishing packages: Detect supported platforms](https://dart.dev/tools/pub/publishing#detect-supported-platforms) · [Package scores: Platform support](https://pub.dev/help/scoring#platform-support)（查阅：2026-08-30）
- 发布包应包含 `LICENSE`，Dart 官方建议使用 OSI 批准许可证；升级评估还应阅读 `CHANGELOG.md` 的迁移说明。[Package layout](https://dart.dev/tools/pub/package-layout#license)（查阅：2026-08-30）

06-07 固定使用下面的评估顺序：

| 检查项 | 要回答的问题 | 证据 |
| --- | --- | --- |
| 问题匹配 | SDK 是否已经够用？包解决的是持续复杂度还是两行样板？ | 最小对照实现 |
| 版本兼容 | SDK 约束、Current / Resolvable / Latest 是否匹配？ | pubspec、`flutter pub outdated`、changelog |
| 平台 | Web 是否被声明并真正通过 release build 与浏览器流程？ | pub.dev、官方仓库、项目验收 |
| 许可证 | 许可证能否与仓库 BSD 3-Clause 代码共同分发？ | 包归档与仓库 `LICENSE` |
| 维护性 | 最新稳定版、迁移文档、仓库状态、问题追踪是否仍可用？ | pub.dev、changelog、官方仓库 |
| 退出成本 | 能否藏在 Repository / Service / provider 接缝后替换？ | 接口、fake、生成代码范围 |
| 教学成本 | 首次出现要增加多少 API、命令与失败排查？ | 章节知识依赖 |

点赞、下载量、Pub points 或“Flutter Favorite”都只能提供线索，不能单独决定采用。升级一次只跨一个可解释边界，读取 changelog，重新生成代码，再运行 analyze、相关单元 / Widget 测试、浏览器关键流程和 release Web build。

## 10. 06-01 至 06-08 固定章节边界

章节顺序和概念 ID 来自 GitHub Issue #1，不调整。[首版规格 #1](https://github.com/mardd123588/flutter-tutorial/issues/1)（查阅：2026-08-30）

| ID | 固定标题与范围 | requires | provides | 实践证据 |
| --- | --- | --- | --- | --- |
| 06-01 | **复杂度从哪里出现**：状态所有权、单一事实来源、单向数据流和功能边界。 | `state.ownership`、`data.service`、`navigation.router` | `architecture.complexity-signals`、`architecture.ssot`、`architecture.udf` | 从混合页面中标出状态、I/O 和显示责任。 |
| 06-02 | **View、ViewModel、Repository、Service**：逐层引入，复杂业务才增加 domain 层。 | `architecture.udf`、`data.service` | `architecture.view`、`architecture.viewmodel`、`architecture.repository`、`architecture.service` | 把活动页面分层，保持 UI 测试不变。 |
| 06-03 | **Result、错误与命令**：显式成功失败、可重试动作、并发命令和 UI 消息。 | `architecture.viewmodel`、`error.network` | `architecture.result`、`architecture.command`、`error.presentation` | 覆盖保存成功、冲突、重试和重复点击。 |
| 06-04 | **Riverpod 3 基础**：ProviderContainer、ref、scope、Notifier 与 SDK 方案的对应关系。 | `state.inherited`、`state.change-notifier`、`architecture.udf` | `riverpod.provider`、`riverpod.ref`、`riverpod.notifier`、`riverpod.scope` | 将一个 ChangeNotifier 功能等价迁移到 Riverpod。 |
| 06-05 | **异步状态、缓存失效与组合**：AsyncNotifier、family、autoDispose、刷新和依赖图。 | `riverpod.provider`、`async.ui-state`、`data.cache` | `riverpod.async-notifier`、`riverpod.family`、`riverpod.invalidation`、`riverpod.disposal` | 处理筛选参数变化、刷新和旧缓存。 |
| 06-06 | **依赖替换与 Riverpod 测试**：override、fake、ProviderContainer 和 Widget 边界。 | `riverpod.scope`、`architecture.repository`、`test.widget-smoke` | `riverpod.override`、`test.provider-container`、`test.fake-repository` | 同一功能完成纯状态和 Widget 两层测试。 |
| 06-07 | **代码生成、包选择与升级边界**：Riverpod codegen 按收益使用，比较维护成本和 API 稳定性。 | `tool.build-runner`、`riverpod.provider` | `riverpod.codegen-boundary`、`ecosystem.package-evaluation`、`ecosystem.upgrade-boundary` | 为一个重复明显的 family 使用生成器，其余保留手写。 |
| 06-08 | **统筹项目：社区工坊排期台**：分层、Riverpod、冲突检查、离线存储和测试集中复习。 | 本部分全部 `provides` | `project.community-workshop-scheduler` | 独立项目及完整 Web 验收。 |

### 10.1 `06-01` 复杂度从哪里出现

重点：

- 用同一份“混合页面”逐项标出局部 UI state、业务 state、派生 state、I/O、副作用与显示责任；
- 解释单一事实来源和单向数据流如何减少同步问题；
- 给出渐进迁移顺序和停止条件，小功能不分层也是有效决定；
- 区分框架内部 Widget / Element / RenderObject 架构与本部分的应用架构。

禁止提前出现：正式 ViewModel / Repository 目录模板、Result 实现、Riverpod API、代码生成、统筹项目源码。

### 10.2 `06-02` View、ViewModel、Repository、Service

重点：

- 用普通构造函数完成对象接线，逐层移动责任，并保持原 Widget 测试行为；
- 讲清 Repository 是数据策略与单一事实来源，Service 只是外部数据源适配；
- 用 `ChangeNotifier` 实现当前 ViewModel，让读者把架构职责与状态包分开；
- 用三条官方条件判断是否需要 domain use-case。

禁止提前出现：Riverpod、Result / Command 完整实现、family、override、项目冲突规则。

### 10.3 `06-03` Result、错误与命令

重点：

- 用 sealed Result 与 typed failure 区分预期业务失败、基础设施失败和程序缺陷；
- 保存动作覆盖运行中、成功、冲突、可重试失败、重复点击和结果消费；
- View 负责把错误映射为可理解文案、焦点与恢复动作；
- 说明两个不同 command 可以并行，同一 command 的防重复不等于取消或全局串行。

禁止提前出现：Riverpod `AsyncValue`、Mutations、Repository override、统筹项目源码。

### 10.4 `06-04` Riverpod 3 基础

重点：

- 从 `InheritedWidget`、`ChangeNotifier` 的所有者 / 订阅 / 释放问题映射到 `ProviderScope`、container 与 `Ref`；
- 只讲 `Provider`、`NotifierProvider`、`ConsumerWidget`、`watch / read / listen`；
- 把同一小功能等价迁移，保持状态类型和测试断言不变；
- 明确 provider 是声明，container 才保存状态，Notifier 作为 ViewModel 实现。

禁止提前出现：`AsyncNotifier`、family、auto-dispose、override、codegen、hooks、legacy provider。

### 10.5 `06-05` 异步状态、缓存失效与组合

重点：

- `AsyncNotifier` 的初始化与用户动作、`AsyncValue` 的旧值 + loading / error 组合；
- Riverpod 3 默认自动重试及可测试配置；
- family 参数身份、参数化缓存、auto-dispose 生命周期和资源释放；
- `watch` 组成依赖图，`invalidate / refresh` 表达数据失效；
- `select / selectAsync` 只在测量后收窄订阅。

禁止提前出现：测试 override 细节、codegen 语法、Riverpod experimental offline persistence / Mutations、统筹项目解析。

### 10.6 `06-06` 依赖替换与 Riverpod 测试

重点：

- Repository provider 是主要替换接缝；fake 保留输入输出，不复制实现；
- `ProviderContainer.test()` 每例隔离、`listen` 保活 auto-dispose、`.future` 等异步结果；
- Widget 根 scope 的 overrides 与 `tester.container()`；
- 测试 ViewModel、Repository 和 View 的边界，不 mock Notifier。

禁止提前出现：完整测试策略、mock 框架比较、golden 原理、WebDriver 原理、项目解析。

### 10.7 `06-07` 代码生成、包选择与升级边界

重点：

- 对照一份手写 family 与生成 family，说明参数能力、默认 auto-dispose、生成命令与失败排查；
- 只给一处重复明显、多参数且已进入 build_runner 链路的 provider 使用生成器；
- 用 Riverpod 本身走完版本、平台、许可证、维护性、退出成本和 Web 验收检查表；
- 解释 Current / Resolvable / Latest，升级后重跑项目质量门槛。

禁止提前出现：Pub workspace 与 CI 编排（第八部分）、依赖供应链专题、为所有 provider 生成代码、平行实现 BLoC / provider / signals。

### 10.8 `06-08` 统筹项目

本章集中给出项目简报、架构图、关键源码 region、测试证据和取舍。06-01 至 06-07 使用独立小例子，不跨章拆解“社区工坊排期台”。

## 11. 统筹项目：社区工坊排期台

### 11.1 使用场景

社区活动中心的协调员要为一个固定周末安排两天工坊。系统完全本地运行，fixture Service 提供确定性的工坊、场馆、讲师与初始排期，Drift 保存协调员调整后的排期；协调员可以查看、筛选、新建和编辑排期。保存前必须一次列出全部冲突，刷新页面后排期仍在。

项目路径、ID 与预览路径固定为：

```text
examples/capstones/community_workshop_scheduler/
project: community-workshop-scheduler
/flutter-tutorial/previews/community-workshop-scheduler/
```

预览继续使用 ADR-0010 / ADR-0017 的 hash URL 和独立 base href。

### 11.2 领域模型与规则

固定 fixture 包含 2 个活动日、3 个场馆、5 位讲师、8 个工坊与 10 条初始排期。最小实体：

- `Workshop`：稳定 ID、标题、分类与简短说明；
- `Venue`：稳定 ID、名称、容量与无障碍设施标签；
- `Instructor`：稳定 ID、姓名与介绍；
- `ScheduleEntry`：稳定 ID、工坊 ID、讲师 ID、场馆 ID、活动日 ID、开始 / 结束分钟与预计人数；
- `ScheduleQuery`：活动日、场馆和讲师筛选，值不可变且有稳定 equality。

活动日使用 fixture 中的稳定 ID 和显示标签，时间保存为当天的分钟数，不做时区换算。两个活动日都只允许安排 `09:00–18:00`，表单按 30 分钟步长输入。

固定规则：

1. 时间段采用半开区间 `[start, end)`；一个场次的结束时间等于下一个场次的开始时间时不冲突；
2. 活动日不在固定两天内、`start >= end`、开始早于 `09:00` 或结束晚于 `18:00` 均为验证失败；
3. 同一场馆的时间段不能重叠；
4. 同一讲师的时间段不能重叠；
5. 预计人数不能超过场馆容量；
6. 编辑场次时冲突查询排除自身 ID；
7. 保存一次返回全部冲突，不让用户逐条试错；
8. 工坊、场馆或讲师 ID 不存在时返回稳定的验证 failure；
9. 冲突、验证和存储失败使用不同 failure 类型，UI 不解析异常字符串。

冲突检测是纯 domain policy：它同时用于新建、编辑和单元测试，值得从 ViewModel 提取；项目不为每个动作再建一层 use-case。

### 11.3 功能范围

- 两天排期主页：宽屏按场馆显示时间列，窄屏按活动日与时间分组为可操作列表；布局变化不改变数据和 URL；
- 活动日、场馆和讲师筛选；活动日与场馆进入 query，刷新和 Back / Forward 后可恢复；
- 场次详情深链接 `#/sessions/:sessionId`，非法或不存在 ID 有独立错误状态；
- 新建 / 编辑表单：工坊、讲师、场馆、活动日、开始、结束和预计人数；
- 保存前显示所有冲突，每条冲突指出对象、时间和跳转到已有场次的动作；
- 保存与重试都有明确运行状态，同一保存动作不能重复提交；
- `WorkshopCatalogService` 提供只读的两个活动日、固定工坊、场馆、讲师与初始排期；Drift 只保存排期记录和 seed 标记，首次打开只 seed 一次；fixture、测试时钟和数据库名保持确定性；
- 提供“恢复演示数据”动作，明确说明会覆盖本地项目数据并要求确认；
- 键盘可完成筛选、新建、修复冲突、保存和返回；冲突不只靠颜色表达；
- 320×720、768×900、1440×900 与 200% 文本下保持主要任务；减少动画时直接到终态；
- 界面按 Operate 模式组织，首屏先呈现两天排期、当前筛选和明确的新建入口。具体视觉世界在项目实现前单独定稿；不得复制 Flutter Compass、Todo 或日历官方示例，也不得退化成通用后台模板。

### 11.4 架构合同

本项目沿用第四部分已经验证的 `drift 2.34.3` 与 `drift_flutter 0.3.1`，不在引入 Riverpod codegen 的同一步升级数据库栈。Web 资产继续使用同一 Drift release 的 `sqlite3.wasm` 与 `drift_worker.js`。[drift 2.34.3](https://pub.dev/packages/drift/versions/2.34.3) · [drift_flutter 0.3.1](https://pub.dev/packages/drift_flutter/versions/0.3.1) · [Drift Web](https://drift.simonbinder.eu/platforms/web/)（查阅：2026-08-30）

```text
ScheduleBoardView / WorkshopEditorView
  ↓ intent                     ↑ immutable view state
ScheduleBoardViewModel / WorkshopEditorViewModel
  ↓                            ↑ Result
ScheduleRepository（抽象接口，排期单一事实来源）
  ├─ ScheduleConflictPolicy（纯 Dart）
  ├─ WorkshopCatalogService → deterministic fixture
  └─ ScheduleStorageService → Drift Web
```

Riverpod 对象图：

- 手写 `Provider` 创建 fixture catalog service、Drift storage service 与 Repository；
- Repository 组合固定目录与本地排期，Repository provider 是测试时的主要 override seam；
- 一个手写 `NotifierProvider` 管理编辑草稿、校验结果和保存 Command 状态；
- 一个 `AsyncNotifier` 管理目录加载、排期组合、首次失败和重试；
- 只给返回 Drift 排期流的“活动日 + 场馆 + 讲师”多参数 family 使用 codegen，三个命名参数在主页、详情返回和测试中反复使用；其他 provider 保持手写；
- 生成 family 内部构造不可变 `ScheduleQuery`，默认 auto-dispose；离开页面后关闭 Drift 查询订阅；
- Drift 查询流负责把成功写入推给当前排期，不再额外 invalidate 同一数据；加载失败后的重试才 invalidate 对应 provider；
- expected failure 使用 Result，provider 未预期异常才进入 `AsyncError`；根 scope 的 retry 策略显式配置并测试；
- `select` 不是交付要求。只有重建测量证明页头计数等消费者受无关字段影响时才加入，并在测试中固定选中值为不可变类型；
- URL 是活动日 / 场馆筛选的单一事实来源，Drift / Repository 是排期的单一事实来源，表单草稿只属于编辑 ViewModel；不得在三处维护可写副本。

### 11.5 明确不做

- 不做账号、云同步、多人实时编辑、服务端冲突合并或权限系统；
- 不做报名、支付、参与者个人信息、候补名单或通知；
- 不做删除、重复日程、跨时区、外部日历导入导出或原生系统日历插件；
- 不把拖拽设为唯一排期方式；首版表单和键盘操作是完整路径；
- 不引入网络 API；“离线”表示本地 Drift 为正式数据源，不表示离线同步；
- 不使用 experimental Riverpod offline persistence 或 Mutations，数据库迁移仍由 Drift 管理。[Offline persistence (experimental)](https://riverpod.dev/docs/concepts2/offline) · [Mutations (experimental)](https://riverpod.dev/docs/concepts2/mutations)（查阅：2026-08-30）
- 不使用 hooks、legacy providers、BLoC、Freezed 或通用 mock 包；除唯一生成 family 外不扩大 codegen；
- 不建立完整 Clean Architecture / DDD 目录，也不为每个动作创建 use-case；
- 不与前五个统筹项目共享业务模型、主题组件、数据库或 provider 封装。

### 11.6 单元与 provider 测试合同

纯 Dart 规则至少覆盖：

1. 场馆时间重叠、讲师时间重叠、两者同时冲突；
2. 结束时间等于下一场开始时间时允许保存；
3. 零时长、反向时长、容量超限与编辑排除自身；
4. 一次返回多条冲突且顺序确定；
5. Repository 把 fixture / 数据库异常映射为稳定 failure，不泄漏底层错误文本；
6. Command / ViewModel 防止同一保存动作重复启动，失败后允许重试；
7. 保存成功后 Drift 查询流更新，恢复演示数据后回到固定 10 条初始排期。

Riverpod 测试至少覆盖：

1. 每例使用 `ProviderContainer.test()`，Repository provider 替换为 fake；
2. `ScheduleQuery` 的不同参数组合拥有独立状态；
3. auto-dispose family 在失去监听后释放，测试等待期间用 `listen` 保活；
4. Drift 写入更新当前查询流，不靠冗余 invalidate；加载重试只 invalidate 失败的 provider；
5. 首次加载、保留旧数据刷新、刷新失败和空结果都能观察；
6. retry 次数与终止条件确定，不依赖真实计时等待；
7. 未预期异步完成前 provider 已 dispose 时，不继续写状态。

### 11.7 Widget 与浏览器合同

Widget 测试至少覆盖：

- loading、empty、data、首次失败、旧数据 + 刷新失败；
- 冲突列表包含对象、时间、错误摘要和修复动作，焦点移到摘要；
- 连续点击保存只启动一次；保存完成后表单和排期同步；
- fake Repository 通过根 `ProviderScope` override 注入，Widget 不知道具体实现；
- 320×720、768×900、1440×900 无横向溢出；
- 200% 文本、键盘焦点顺序、Semantics、减少动画模式；
- 恢复演示数据确认和非法深链接。

Chrome 关键流程固定为：

1. 从两天排期筛选某个活动日与场馆，打开深链接详情后使用 Back / Forward；
2. 只用键盘新建一个同时发生场馆、讲师和容量冲突的排期，确认保存被阻止且全部冲突一次出现；
3. 修改时间、场馆或预计人数后保存，列表与详情同步；
4. 刷新页面，确认新排期仍在且 query 未丢；
5. release Web 从 `/flutter-tutorial/previews/community-workshop-scheduler/` 加载，hash 深链接可直接打开和刷新。

首版项目矩阵把 `Visual` 记为 `not-applicable`，因此本项目不维护 golden；原因是第六部分的风险在架构、状态和规则，不在像素稳定性。该状态不免除实际浏览器截图、三种尺寸、200% 文本与人工视觉检查。

所有数据库与 fixture 在测试开始时显式重置。Widget 测试通过不代替真实 Drift Web 持久化；release build 成功也不代替 Back / Forward、刷新、键盘与语义验收。

## 12. 全部分验收矩阵

| 维度 | 自动检查 | 浏览器 / 人工检查 |
| --- | --- | --- |
| 架构 | 层依赖、Repository / Service / ViewModel 单测 | 从功能改动追踪到唯一写入点 |
| Result / command | 成功、冲突、失败、重试、重复提交 | 错误可理解，焦点到错误摘要，恢复动作可用 |
| Riverpod | container 隔离、override、family、invalidate、dispose、retry | 页面离开 / 返回后缓存和刷新符合产品语义 |
| 响应式 | 320×720、768×900、1440×900 Widget tests | 窄宽布局任务连续，筛选和编辑不丢 |
| 可访问性 | Semantics、焦点、200% 文本、减少动画 | 全程键盘完成，冲突不只靠颜色 |
| 数据 | fixture + Drift 写入、流更新、异常映射、测试 seed | 刷新持久化与恢复演示数据 |
| 导航 | path / query、非法 ID、Back / Forward Widget tests | 直接粘贴、硬刷新、复制新标签 |
| 发布 | analyze、unit / Widget、Chrome drive、release Web build | 实际子路径和 hash 深链接验收 |

## 13. 写作时必须避免的误讲

| 不准确说法 | 应改为 |
| --- | --- |
| “项目大了就上 Clean Architecture” | 先看状态、I/O、复用和测试信号；UI / data 两层通常够用，domain 层按三类复杂度条件增加。 |
| “一个页面一个 ViewModel，所以每个 Widget 都有 ViewModel” | View 是一个功能的 Widget 组合，ViewModel 对应 View，不对应每个叶子 Widget。 |
| “Service 就是 Repository 的另一种叫法” | Service 适配单一外部数据源；Repository 决定缓存、转换、刷新和单一事实来源。 |
| “Repository 可以互相调用，方便复用” | 跨 Repository 组合放 ViewModel 或确有必要的 domain use-case。 |
| “依赖注入就是 Riverpod” | 构造函数与接口先定义依赖方向；Riverpod 负责创建、生命周期和替换。 |
| “ValueNotifier 里的 List 改了会自动通知” | 只有 `value = newValue` 且 `newValue != oldValue` 才通知，原地改可变对象不会。 |
| “ChangeNotifier 已经过时” | Flutter 仍支持并条件性推荐；本教程按复杂度把生产状态迁到 Riverpod。 |
| “Result 可以把所有异常都变成错误文案” | Result 处理预期业务与可恢复失败；Error 和不变量破坏不能被普通失败吞掉。 |
| “AsyncValue 已经有 Error，所以不需要 Result” | AsyncValue 表达执行状态，Result 表达业务操作成功或预期失败，两者边界不同。 |
| “Command 防重复就等于取消” | 它阻止同一动作再次启动，不会自动终止正在运行的底层工作。 |
| “顶层 provider 是全局可变单例” | provider 是不可变声明，状态保存在 ProviderContainer / ProviderScope。 |
| “按钮里都用 watch” | 渲染依赖用 watch；事件回调通常用 read 调 notifier；副作用用 listen。 |
| “用 read 可以减少重建” | read 会失去订阅；先 watch，测量后才用 select。 |
| “Riverpod 3 的 family 已删除” | 删除的是 FamilyNotifier 等专用基类，family 参数化 provider 仍存在。 |
| “autoDispose 一离开就同步销毁” | 最后监听者离开后等待一个 frame；期间恢复监听会触发 resume。 |
| “refresh 是清空全部缓存” | refresh 等于 invalidate 当前实例后立即 read；family 的单实例与全部实例要区分。 |
| “AsyncNotifier 失败只执行一次” | Riverpod 3 默认自动重试，次数和终止条件必须显式理解和测试。 |
| “生成 provider 默认永久保留” | Riverpod codegen 默认 auto-dispose，`keepAlive: true` 才关闭。 |
| “Riverpod 3.4.2 的配套生成器也应是 3.x” | 当前 annotation 4.0.6、generator 4.0.8 精确配合 runtime 3.4.2。 |
| “下载量最高就是最稳的包” | 下载量只是流行度线索；还要核对版本、平台、许可证、维护与实际构建。 |
| “pub.dev 标了 Web 就证明项目能上 Web” | 平台标签来自声明和静态分析，仍需 release build 与真实浏览器流程。 |
| “离线排期用 Riverpod offline persistence” | 该功能仍是 experimental；项目沿用 Drift 与 Repository，迁移策略归数据库。 |

## 14. 正文参考资料清单

章节页尾只列实际使用的来源，不把本清单整段复制过去。

- [Common architecture concepts](https://docs.flutter.dev/app-architecture/concepts)（查阅：2026-08-30）
- [Guide to app architecture](https://docs.flutter.dev/app-architecture/guide)（查阅：2026-08-30）
- [Architecture recommendations](https://docs.flutter.dev/app-architecture/recommendations)（查阅：2026-08-30）
- [Architecture recommendation data](https://github.com/flutter/website/blob/main/sites/docs/src/data/architectureRecommendations.yml)（查阅：2026-08-30）
- [Communicating between layers](https://docs.flutter.dev/app-architecture/case-study/dependency-injection)（查阅：2026-08-30）
- [Testing each layer](https://docs.flutter.dev/app-architecture/case-study/testing)（查阅：2026-08-30）
- [Error handling with Result objects](https://docs.flutter.dev/app-architecture/design-patterns/result)（查阅：2026-08-30）
- [Command pattern](https://docs.flutter.dev/app-architecture/design-patterns/command)（查阅：2026-08-30）
- [Dart error handling](https://dart.dev/language/error-handling)（查阅：2026-08-30）
- [ChangeNotifier](https://api.flutter.dev/flutter/foundation/ChangeNotifier-class.html)（查阅：2026-08-30）
- [ValueNotifier](https://api.flutter.dev/flutter/foundation/ValueNotifier-class.html)（查阅：2026-08-30）
- [flutter_riverpod 3.4.2](https://pub.dev/packages/flutter_riverpod/versions/3.4.2)（查阅：2026-08-30）
- [riverpod 3.4.2](https://pub.dev/packages/riverpod/versions/3.4.2)（查阅：2026-08-30）
- [Riverpod providers](https://riverpod.dev/docs/concepts2/providers)（查阅：2026-08-30）
- [ProviderContainers / ProviderScopes](https://riverpod.dev/docs/concepts2/containers)（查阅：2026-08-30）
- [Riverpod refs](https://riverpod.dev/docs/concepts2/refs)（查阅：2026-08-30）
- [Riverpod family](https://riverpod.dev/docs/concepts2/family)（查阅：2026-08-30）
- [Riverpod automatic disposal](https://riverpod.dev/docs/concepts2/auto_dispose)（查阅：2026-08-30）
- [Riverpod automatic retry](https://riverpod.dev/docs/concepts2/retry)（查阅：2026-08-30）
- [Provider overrides](https://riverpod.dev/docs/concepts2/overrides)（查阅：2026-08-30）
- [Riverpod testing](https://riverpod.dev/docs/how_to/testing)（查阅：2026-08-30）
- [Reducing rebuilds with select](https://riverpod.dev/docs/how_to/select)（查阅：2026-08-30）
- [Riverpod 3 migration](https://riverpod.dev/docs/3.0_migration)（查阅：2026-08-30）
- [About Riverpod code generation](https://riverpod.dev/docs/concepts/about_code_generation)（查阅：2026-08-30）
- [Riverpod offline persistence (experimental)](https://riverpod.dev/docs/concepts2/offline)（查阅：2026-08-30）
- [Riverpod mutations (experimental)](https://riverpod.dev/docs/concepts2/mutations)（查阅：2026-08-30）
- [Dart package dependencies](https://dart.dev/tools/pub/dependencies)（查阅：2026-08-30）
- [Package versioning](https://dart.dev/tools/pub/versioning)（查阅：2026-08-30）
- [dart pub outdated](https://dart.dev/tools/pub/cmd/pub-outdated)（查阅：2026-08-30）
- [Package layout](https://dart.dev/tools/pub/package-layout)（查阅：2026-08-30）
- [Publishing packages](https://dart.dev/tools/pub/publishing)（查阅：2026-08-30）
- [Package scores and pub points](https://pub.dev/help/scoring)（查阅：2026-08-30）

## 15. 进入实现前仍需验证

下列问题不改变章节和项目合同，但必须在写正文前用正式项目源码确认：

1. 在当前 pub workspace 中解析 `flutter_riverpod 3.4.2`、annotation 4.0.6、generator 4.0.8 与 build_runner 2.16.0，编译一个多参数 generated family，并通过 analyze、Widget test 和 release Web build；现有[栈探针](./stack-probe-results.md)只证明 Riverpod runtime 3.4.2 可构建，没有覆盖这组生成器。
2. 用 Repository fake 固定项目的 retry 策略。无网络的本地数据库读取是否完全关闭自动重试，还是只对明确的暂时性错误保留有限重试，要由可重复测试决定，不能沿用默认 10 次而不说明。
3. 用 320、768、1440 宽度原型确定排期列何时切换为分组列表。章节只固定“内容开始拥挤时切换”，不预先把某个像素值解释成设备分类。
4. 在独立 base href 下重跑 Drift Web：首次 seed 一次、新建 / 编辑后的刷新持久化、测试数据库隔离、hash 详情深链和恢复演示数据确认。第四部分的通过记录不能代替新项目验收。
