# Flutter 教程生态主栈候选调查

> 查阅日期：2026-08-29  
> 适用基线：Flutter 3.47.0、Dart 3.13.0  
> 资料范围：Flutter / Dart 官方文档、pub.dev 包页与 API、包的官方文档和源码仓库。本文只整理候选与代价，不决定最终主方案。

## 先看结论边界

- 截至 2026-08-29，本轮候选的稳定版都能满足 Flutter 3.47 / Dart 3.13 的声明约束。`freezed 4.0.0` 的 Dart 下限正好是 3.13；`go_router 18.0.0` 要求 Flutter 3.44 以上。[freezed 4.0.0 元数据](https://pub.dev/api/packages/freezed/versions/4.0.0) · [go_router 元数据](https://pub.dev/api/packages/go_router)
- Web 不能只看“这个包是不是纯 Dart”。路由要验证浏览器历史与 GitHub Pages 子路径，HTTP 要受 CORS 约束，数据库还涉及 IndexedDB、Wasm、Worker 和响应头。[Flutter Router API](https://api.flutter.dev/flutter/widgets/Router-class.html) · [Dio 的 Web CORS 说明](https://github.com/cfug/dio/tree/main/dio#cross-origin-resource-sharing-on-web-cors) · [Drift Web 文档](https://drift.simonbinder.eu/platforms/web/)
- Flutter 官方架构指南不绑定状态管理包。官方案例采用 `ChangeNotifier`、`Listenable` 和 `provider`，同时明确说明 Riverpod、`flutter_bloc`、signals 或 Stream 都能遵守同一套分层规则。[Flutter 架构案例](https://docs.flutter.dev/app-architecture/case-study)
- 教学顺序不应等同于生产主方案。先讲 `InheritedWidget`、`Listenable`、`ChangeNotifier`、`Navigator`、`Router`、手写 JSON 和依赖注入的基本接缝，再引入第三方包，读者才知道它们省掉了什么。[InheritedWidget API](https://api.flutter.dev/flutter/widgets/InheritedWidget-class.html) · [ChangeNotifier API](https://api.flutter.dev/flutter/foundation/ChangeNotifier-class.html) · [Navigator API](https://api.flutter.dev/flutter/widgets/Navigator-class.html) · [Router API](https://api.flutter.dev/flutter/widgets/Router-class.html)

## 版本、约束与维护主体

表中的“查阅版本”取自 2026-08-29 的 pub.dev `latest` 元数据；Flutter SDK 自带能力跟随 3.47.0，不另设包版本。

| 领域 | 候选 | 查阅版本 | SDK 约束 | Web 与维护主体 |
| --- | --- | ---: | --- | --- |
| 状态 | Flutter SDK：`InheritedWidget` / `ChangeNotifier` | 3.47.0 SDK | Dart 3.13 | Flutter SDK 自带，Web 随 Flutter；由 Flutter 项目维护。[API](https://api.flutter.dev/flutter/foundation/ChangeNotifier-class.html) · [源码](https://github.com/flutter/flutter/tree/3.47.0/packages/flutter) |
| 状态 | `flutter_riverpod` / `riverpod` | 3.4.2 / 3.4.2 | Dart `^3.12.0`；Flutter `>=3.0.0` | verified publisher `dash-overflow.net`，仓库 `rrousselGit/riverpod`。核心 `riverpod` 的 pub.dev 元数据列出 Web；`flutter_riverpod` 当前元数据没有 Web 标签，见后文风险说明。[flutter_riverpod](https://pub.dev/api/packages/flutter_riverpod) · [riverpod](https://pub.dev/api/packages/riverpod) · [publisher](https://pub.dev/publishers/dash-overflow.net) |
| 状态 | `provider` | 6.1.5+1 | Dart `>=2.12.0 <4.0.0`；Flutter `>=1.16.0` | pub.dev 列出 Web；verified publisher `dash-overflow.net`，仓库 `rrousselGit/provider`。[元数据](https://pub.dev/api/packages/provider) · [平台标签](https://pub.dev/api/packages/provider/score) · [publisher](https://pub.dev/publishers/dash-overflow.net) |
| 状态 | `flutter_bloc` / `bloc` | 9.1.1 / 9.2.1 | Dart `>=2.14.0 <4.0.0` | `flutter_bloc` 的 pub.dev 元数据列出 Web；verified publisher `bloclibrary.dev`，仓库 `felangel/bloc`。[flutter_bloc](https://pub.dev/api/packages/flutter_bloc) · [bloc](https://pub.dev/api/packages/bloc) · [平台标签](https://pub.dev/api/packages/flutter_bloc/score) · [publisher](https://pub.dev/publishers/bloclibrary.dev) |
| 路由 | Flutter SDK：`Navigator` / `Router` | 3.47.0 SDK | Dart 3.13 | Flutter SDK 自带；`Router` 明确处理 Web URL 与浏览器前进、后退历史。[Router API](https://api.flutter.dev/flutter/widgets/Router-class.html) |
| 路由 | `go_router` | 18.0.0 | Dart `^3.12.0`；Flutter `>=3.44.0` | pub.dev 列出 Web；verified publisher `flutter.dev`，源码位于 Flutter 官方 `packages` 仓库。[元数据](https://pub.dev/api/packages/go_router) · [平台标签](https://pub.dev/api/packages/go_router/score) · [仓库](https://github.com/flutter/packages/tree/main/packages/go_router) |
| HTTP | `http` | 1.6.0 | Dart `^3.4.0` | pub.dev 列出 Web 和 Wasm；verified publisher `dart.dev`，仓库 `dart-lang/http`。[元数据](https://pub.dev/api/packages/http) · [平台标签](https://pub.dev/api/packages/http/score) · [publisher](https://pub.dev/publishers/dart.dev) |
| HTTP | `dio` | 5.11.0 | Dart `>=2.18.0 <4.0.0` | pub.dev 列出 Web 和 Wasm；verified publisher `flutter.cn`，仓库 `cfug/dio`。[元数据](https://pub.dev/api/packages/dio) · [平台标签](https://pub.dev/api/packages/dio/score) · [publisher](https://pub.dev/publishers/flutter.cn) |
| 模型 | 手写 `dart:convert` | Dart 3.13 SDK | Dart 3.13 | Dart SDK 自带，Web 可用；由 Dart 项目维护。[dart:convert](https://api.dart.dev/dart-convert/) |
| 模型 | `json_serializable` | 6.14.1 | Dart `^3.9.0` | 生成器在开发机运行；产物是普通 Dart。verified publisher `google.dev`，仓库 `google/json_serializable.dart`。[元数据](https://pub.dev/api/packages/json_serializable) · [仓库](https://github.com/google/json_serializable.dart/tree/master/json_serializable) · [publisher](https://pub.dev/publishers/google.dev) |
| 模型 | `freezed` / `freezed_annotation` | 4.0.0 / 3.1.0 | 生成器 Dart `>=3.13.0 <4.0.0`；annotation Dart `>=3.0.0 <4.0.0` | 生成器在开发机运行；运行时 annotation 元数据列出 Web。verified publisher `dash-overflow.net`，仓库 `rrousselGit/freezed`。[freezed 4.0.0](https://pub.dev/api/packages/freezed/versions/4.0.0) · [annotation](https://pub.dev/api/packages/freezed_annotation) · [annotation 平台标签](https://pub.dev/api/packages/freezed_annotation/score) |
| 持久化 | `shared_preferences` | 2.5.5 | Dart `^3.9.0`；Flutter `>=3.35.0` | pub.dev 列出 Web；verified publisher `flutter.dev`，源码位于 Flutter 官方 `packages` 仓库。[元数据](https://pub.dev/api/packages/shared_preferences) · [平台标签](https://pub.dev/api/packages/shared_preferences/score) · [仓库](https://github.com/flutter/packages/tree/main/packages/shared_preferences/shared_preferences) |
| 持久化 | `drift` / `drift_flutter` | 2.34.3 / 0.3.1 | Dart `>=3.10.0 <4.0.0` | pub.dev 列出 Web 和 Wasm；verified publisher `simonbinder.eu`，仓库 `simolus3/drift`。[drift](https://pub.dev/api/packages/drift) · [drift_flutter](https://pub.dev/api/packages/drift_flutter) · [平台标签](https://pub.dev/api/packages/drift/score) · [publisher](https://pub.dev/publishers/simonbinder.eu) |
| 持久化备选 | `hive_ce` / `hive_ce_flutter` | 2.19.3 / 2.3.4 | Dart `^3.4.0`；Flutter `>=3.27.0` | pub.dev 列出 Web 和 Wasm；verified publisher `iodesignteam.com`，仓库 `IO-Design-Team/hive_ce`。[hive_ce](https://pub.dev/api/packages/hive_ce) · [Flutter 适配](https://pub.dev/api/packages/hive_ce_flutter) · [平台标签](https://pub.dev/api/packages/hive_ce/score) |
| 持久化备选 | `sembast` / `sembast_web` | 3.8.9+1 / 2.4.5+1 | Dart `^3.12.0` | Web 实现基于 IndexedDB，支持 Flutter Web 的 JS 与 Wasm；verified publisher `tekartik.com`。[sembast](https://pub.dev/api/packages/sembast) · [sembast_web](https://pub.dev/api/packages/sembast_web) · [Web README](https://github.com/tekartik/sembast.dart/tree/master/sembast_web) |
| 测试 | `flutter_test` / `integration_test` | 3.47.0 SDK | 跟随 Flutter SDK | 两者通过 `sdk: flutter` 引入，不从 pub.dev 选择独立版本；由 Flutter 项目维护。[flutter_test pubspec](https://github.com/flutter/flutter/blob/3.47.0/packages/flutter_test/pubspec.yaml) · [integration_test pubspec](https://github.com/flutter/flutter/blob/3.47.0/packages/integration_test/pubspec.yaml) |
| 测试辅助 | `mocktail` | 1.0.5 | Dart `>=2.12.0 <4.0.0` | pub.dev 列出 Web 和 Wasm；verified publisher `felangel.dev`，仓库 `felangel/mocktail`。[元数据](https://pub.dev/api/packages/mocktail) · [平台标签](https://pub.dev/api/packages/mocktail/score) · [publisher](https://pub.dev/publishers/felangel.dev) |

## 1. 状态管理

### 可核对事实

#### Flutter SDK 基线

- `InheritedWidget` 用来把数据高效传给子树。消费者通过 `BuildContext.dependOnInheritedWidgetOfExactType` 建立依赖；`updateShouldNotify` 决定依赖者是否重建。[InheritedWidget API](https://api.flutter.dev/flutter/widgets/InheritedWidget-class.html)
- `ChangeNotifier` 实现 `Listenable`。添加监听器是 O(1)，移除监听器和发送通知是 O(N)；调用 `dispose` 后不能再使用。[ChangeNotifier API](https://api.flutter.dev/flutter/foundation/ChangeNotifier-class.html)
- Flutter 官方架构案例用 `ChangeNotifier` 和 `Listenable` 管理 UI 状态，再用 `provider` 注入依赖。案例也明确说，相同架构可换成 Riverpod、`flutter_bloc`、signals 或 Stream。[Flutter 架构案例](https://docs.flutter.dev/app-architecture/case-study)

#### provider

- `provider` 自己把定位写得很清楚：它是 `InheritedWidget` 的包装，补上资源创建与释放、懒加载、统一读取方式、`DevTools` 可见性，以及减少嵌套的 `MultiProvider`。[provider README](https://github.com/rrousselGit/provider/tree/master/packages/provider)
- `ChangeNotifierProvider` 只是 provider 的一种组合。provider 也能提供普通对象、Stream、Future 和代理依赖，不要求所有状态都继承 `ChangeNotifier`。[provider README](https://github.com/rrousselGit/provider/tree/master/packages/provider)

#### Riverpod

- Riverpod 把 provider 定义为可组合、可缓存的函数式声明；`Ref.watch` 建立依赖，`NotifierProvider`、`AsyncNotifierProvider` 和 `StreamNotifierProvider` 负责可修改状态。代码生成和 hooks 是可选包，不是使用 Riverpod 的前提。[Riverpod providers](https://riverpod.dev/docs/concepts2/providers) · [Riverpod getting started](https://riverpod.dev/docs/introduction/getting_started)
- Riverpod 内建异步数据的 loading / error / data 表达、缓存失效和 provider override，可在不启动 Widget tree 的容器中测试。[Riverpod README](https://github.com/rrousselGit/riverpod) · [Riverpod testing](https://riverpod.dev/docs/how_to/testing)
- 需要单独记录一个元数据异常：`riverpod 3.4.2` 的 pub.dev score 列出 Web 和 Wasm，`flutter_riverpod 3.4.2` 没有 Web 标签；后者的 pubspec 还把 `flutter_test` 列为普通依赖。现有一手资料不足以把这个标签差异解释成“运行时不支持 Web”，也不能直接忽略。[riverpod score](https://pub.dev/api/packages/riverpod/score) · [flutter_riverpod score](https://pub.dev/api/packages/flutter_riverpod/score) · [flutter_riverpod pubspec](https://github.com/rrousselGit/riverpod/blob/master/packages/flutter_riverpod/pubspec.yaml)

#### BLoC

- `bloc` 把自己定义为实现 BLoC 模式的可预测状态管理库，目标是分开展示层与业务逻辑。`flutter_bloc` 为 `Bloc` 和 `Cubit` 提供 `BlocProvider`、`BlocBuilder`、`BlocSelector`、`BlocListener` 等 Widget。[bloc README](https://github.com/felangel/bloc) · [flutter_bloc README](https://github.com/felangel/bloc/tree/master/packages/flutter_bloc)
- `Cubit` 通过方法直接发出新状态；`Bloc` 再增加事件到状态的转换。`BlocBuilder` 负责按状态重建，`BlocListener` 负责导航、对话框、SnackBar 等一次性副作用。[flutter_bloc README](https://github.com/felangel/bloc/tree/master/packages/flutter_bloc)
- BLoC 生态另有 `bloc_test 10.0.0`，可按输入事件、输出状态序列验证 bloc；它不是使用 `flutter_bloc` 的必需依赖。[bloc_test 元数据](https://pub.dev/api/packages/bloc_test) · [bloc_test README](https://github.com/felangel/bloc/tree/master/packages/bloc_test)

### 对本教程的设计启示

| 候选 | 教程里最适合承担的角色 | 主要代价 |
| --- | --- | --- |
| SDK 基线 | 解释状态所有权、依赖传播、通知与重建边界；所有第三方方案的共同前置。 | 手工处理生命周期、依赖注入、异步状态和重建粒度，规模一大就会出现重复代码。[InheritedWidget API](https://api.flutter.dev/flutter/widgets/InheritedWidget-class.html) · [ChangeNotifier API](https://api.flutter.dev/flutter/foundation/ChangeNotifier-class.html) |
| provider | 从 `InheritedWidget + ChangeNotifier` 平滑进入分层项目；官方架构案例可直接对照。 | `BuildContext` 查找、可变 notifier、异步状态建模仍需讲清；如果把所有对象都塞进 provider tree，依赖边界会变模糊。[provider README](https://github.com/rrousselGit/provider/tree/master/packages/provider) · [官方架构案例](https://docs.flutter.dev/app-architecture/case-study) |
| Riverpod | 适合统一异步状态、缓存失效、依赖替换和测试；可以把 Repository、Service 与 UI 状态放进同一套依赖图。 | `ProviderScope`、`Ref`、provider family、自动释放、override 和 notifier 体系形成新的心智模型；当前 `flutter_riverpod` Web 标签异常必须先做构建验证。[Riverpod providers](https://riverpod.dev/docs/concepts2/providers) · [平台元数据](https://pub.dev/api/packages/flutter_riverpod/score) |
| BLoC | 适合讲单向数据流、事件、不可变状态和副作用分离；`Cubit` 可作为较轻入口。 | 类和状态类型更多；如果所有点击都先造事件，短项目会被结构代码盖住。`Bloc` 与 `Cubit` 的使用边界也要单独说明。[flutter_bloc README](https://github.com/felangel/bloc/tree/master/packages/flutter_bloc) |

状态管理最终应比较“读者能否解释更新为什么发生、异步失败放在哪里、依赖如何替换、测试是否需要 Widget tree”，不能只比较样板代码行数。官方架构案例已经证明分层规则与具体状态库可以拆开决定。[Flutter 架构案例](https://docs.flutter.dev/app-architecture/case-study)

## 2. 路由

### 可核对事实

- `Navigator` 管理 Route 栈，同时提供 `push` / `pop` 的命令式 API 和 `Navigator.pages` 的声明式 API；嵌套 Navigator 可表示标签页、注册流程、结账流程等独立旅程。[Navigator API](https://api.flutter.dev/flutter/widgets/Navigator-class.html)
- `Router` 把平台 RouteInformation 解析成应用配置，再交给 `RouterDelegate` 构造页面。Web 上它负责让应用状态、URL 和浏览器历史保持一致。[Router API](https://api.flutter.dev/flutter/widgets/Router-class.html)
- Flutter 导航文档不建议大多数应用继续用 named routes；需要深链、Web URL 或复杂导航时，官方建议使用 `go_router` 之类的路由包，或直接使用 `Router`。[Flutter navigation](https://docs.flutter.dev/ui/navigation)
- `go_router` 建在 Router API 上，提供 URL pattern、深链、重定向、嵌套导航 `ShellRoute`、类型安全路由、错误页、状态恢复与 Web 专题。18.0.0 仍有单独的 breaking-change 迁移文档。[go_router README](https://github.com/flutter/packages/tree/main/packages/go_router) · [18.0.0 迁移](https://flutter.dev/go/go-router-v18-breaking-changes)
- `go_router` 官方路线图已把它标为 feature-complete，后续重点是缺陷修复和稳定性，不再以新增功能为主。[go_router roadmap](https://github.com/flutter/packages/tree/main/packages/go_router#roadmap)

### 对本教程的设计启示

- 前置章节先用 `Navigator.push` / `pop` 讲 Route 栈、返回值和生命周期，再用一小段 `Router` 解释 URL、应用状态与浏览器历史的关系。直接手写完整 `RouterDelegate` 不适合作为全站项目的重复基础设施。[Navigator API](https://api.flutter.dev/flutter/widgets/Navigator-class.html) · [Router API](https://api.flutter.dev/flutter/widgets/Router-class.html)
- `go_router` 适合进入生产主方案候选，因为它覆盖本教程需要的 Web URL、深链、重定向和嵌套路由。代价是版本迁移、路由级重定向与应用状态同步、GitHub Pages `base` 和刷新回退都要验收，不能只测应用内点击跳转。[go_router README](https://github.com/flutter/packages/tree/main/packages/go_router) · [Flutter Web URL strategy](https://docs.flutter.dev/ui/navigation/url-strategies)
- 身份状态或 onboarding 状态应来自 Repository / ViewModel，路由只读取并决定页面，不把会话数据的单一事实来源放进路由配置。这个分工来自官方“Repository 是数据源真相、ViewModel 处理 UI 逻辑”的边界。[Flutter 架构指南](https://docs.flutter.dev/app-architecture/guide)

## 3. HTTP

### 可核对事实

| 候选 | 能力 | Web 边界 |
| --- | --- | --- |
| `http` | Future 风格的多平台 HTTP API；可注入 `Client` 复用连接、包装 `BaseClient` 增加行为，并用 `MockClient` 测试，不必依赖全局顶层函数。[http README](https://github.com/dart-lang/http/tree/master/pkgs/http) | Web 使用浏览器实现，受浏览器网络与 CORS 规则限制；pub.dev 标为 Web / Wasm ready。[平台标签](https://pub.dev/api/packages/http/score) |
| Dio | 内建全局配置、interceptor、`FormData`、取消、上传下载、超时、adapter 和 transformer。[Dio README](https://github.com/cfug/dio/tree/main/dio) | 官方文档单列 Web CORS、下载文件名和进度限制；这些能力不能按原生端行为照搬。[Dio README](https://github.com/cfug/dio/tree/main/dio#cross-origin-resource-sharing-on-web-cors) |

### 对本教程的设计启示

- `http` 更适合首次讲“请求—状态码—JSON—错误—取消过期结果—测试替身”这条链，API 面小，`Client` 注入也正好对应 Service 的边界。[http README](https://github.com/dart-lang/http/tree/master/pkgs/http) · [Flutter 架构指南](https://docs.flutter.dev/app-architecture/guide)
- Dio 更适合需要统一鉴权、重试策略、取消、上传进度或多后端 adapter 的项目。它的代价不是只有一个依赖：interceptor 顺序、异常类型、全局配置和 Web 差异都会进入教程内容。[Dio README](https://github.com/cfug/dio/tree/main/dio)
- 两个包都不能解决公开 API 不稳定和 CORS。网络项目仍要把客户端注入 Service，并提供本地 fixture / fake Service；测试不访问在线服务。[Flutter mocking recipe](https://docs.flutter.dev/cookbook/testing/unit/mocking) · [Dio Web CORS](https://github.com/cfug/dio/tree/main/dio#cross-origin-resource-sharing-on-web-cors)

## 4. JSON 与不可变模型

### 可核对事实

#### 手写

- `jsonDecode` 返回动态结构，`jsonEncode` 处理可直接编码的值或调用对象的 `toJson`。字段读取、类型检查、缺失值、未知枚举和错误上下文要由应用代码处理。[dart:convert](https://api.dart.dev/dart-convert/)

#### json_serializable

- `@JsonSerializable` 为 `fromJson` / `toJson` 生成 `.g.dart`；`@JsonKey` 配置字段名、默认值和转换细节。生成动作通过 `dart run build_runner build` 完成。[json_serializable README](https://github.com/google/json_serializable.dart/tree/master/json_serializable)
- 它解决序列化，不负责自动把普通类改成完整的不可变 value object；相等性、`copyWith` 和 union 仍由模型本身或别的工具处理。[json_serializable README](https://github.com/google/json_serializable.dart/tree/master/json_serializable)

#### Freezed

- Freezed 是 data class、tagged union、嵌套模型和 cloning 的代码生成器，可生成不可变字段、值相等、`hashCode`、`toString` 与 `copyWith`；JSON 通常交给 `json_serializable`。[Freezed README](https://github.com/rrousselGit/freezed/tree/master/packages/freezed)
- Freezed 依赖 `build_runner` 工作流。2026-08-29 查阅的 `freezed 4.0.0` 把 Dart 3.13 设为最低版本，和本教程基线完全贴合。[Freezed README](https://github.com/rrousselGit/freezed/tree/master/packages/freezed) · [4.0.0 元数据](https://pub.dev/api/packages/freezed/versions/4.0.0)

### 对本教程的设计启示

| 方案 | 适合何时出现 | 主要代价 |
| --- | --- | --- |
| 手写 | 第一组网络与持久化示例。读者能看见运行时 JSON、领域模型和验证之间的边界。 | 字段多时重复；漏字段、强制转换和错误上下文都靠人工维护。[dart:convert](https://api.dart.dev/dart-convert/) |
| `json_serializable` | 模型增多、字段映射开始重复时。它只替换机械序列化，仍保留普通 Dart 类的可读性。 | 引入 annotation、part 文件和 build_runner；生成失败也成为必须会排查的工具链问题。[json_serializable README](https://github.com/google/json_serializable.dart/tree/master/json_serializable) |
| Freezed | 状态和领域模型确实需要值相等、`copyWith`、sealed union 时。 | 同时引入模型 DSL、生成文件与 `json_serializable` 组合；如果只为两个 DTO 使用，讲解成本高于收益。[Freezed README](https://github.com/rrousselGit/freezed/tree/master/packages/freezed) |

这三个候选不是互斥的一次选择。教程可以先手写一个小模型，再比较生成器；生产主方案是否把 Freezed 加进来，应由“不可变状态与 union 是否持续出现”决定，而不是因为它能少写几行。[Freezed README](https://github.com/rrousselGit/freezed/tree/master/packages/freezed)

## 5. 本地持久化

### 可核对事实

#### shared_preferences

- 它只保存基础类型的键值数据。写入可能异步持久化，官方明确说不能用于关键数据。[shared_preferences README](https://github.com/flutter/packages/tree/main/packages/shared_preferences/shared_preferences)
- 旧 `SharedPreferences` API 已标为将来弃用，新代码优先 `SharedPreferencesAsync` 或 `SharedPreferencesWithCache`。缓存 API 在多 isolate、多 engine 或原生侧修改数据时可能读到旧值。[shared_preferences README](https://github.com/flutter/packages/tree/main/packages/shared_preferences/shared_preferences)
- Flutter Web 的 endorsed implementation 自动加入依赖，当前实现写入浏览器 `localStorage`。[Web implementation README](https://github.com/flutter/packages/tree/main/packages/shared_preferences/shared_preferences_web) · [实现源码](https://github.com/flutter/packages/blob/main/packages/shared_preferences/shared_preferences_web/lib/shared_preferences_web.dart)

#### Drift

- Drift 是建立在 SQLite 上的响应式关系数据层，支持类型安全查询、SQL / Dart 两种查询方式、事务、迁移、join、批量操作和查询 Stream。[Drift README](https://github.com/simolus3/drift) · [Drift overview](https://drift.simonbinder.eu/)
- Web 端使用 SQLite Wasm，并在 OPFS 不可用时退回 IndexedDB / Shared Worker。项目要提供匹配版本的 `sqlite3.wasm` 和 `drift_worker.js`；Wasm 还要以 `application/wasm` 提供。[Drift Web 文档](https://drift.simonbinder.eu/platforms/web/)
- COOP / COEP 响应头能启用更快的存储实现，但 Drift 在没有这些响应头时也会回退。浏览器、隐私模式和多标签页能力仍有差异。[Drift Web 文档](https://drift.simonbinder.eu/platforms/web/)
- `drift_flutter` 提供按平台打开数据库的 `driftDatabase`，但 Web 资产仍需单独准备。[drift_flutter README](https://github.com/simolus3/drift/tree/develop/drift_flutter)

#### Web 备选

- Hive CE 是 IO Design Team 对 Hive v2 的社区延续版，不是原 Hive 的官方续版。它是纯 Dart 的 key-value / NoSQL 数据库，仓库列出浏览器、Flutter Web Wasm 和 adapter 代码生成；Web 实现使用 IndexedDB，但不走 isolate 实现，Web backend 也不支持 compaction。[Hive CE README](https://github.com/IO-Design-Team/hive_ce/tree/main/hive) · [Web backend](https://github.com/IO-Design-Team/hive_ce/blob/main/hive/lib/src/backend/js/backend_manager.dart) · [Web isolate implementation](https://github.com/IO-Design-Team/hive_ce/blob/main/hive/lib/src/isolate/isolated_hive_impl/impl/isolated_hive_impl_web.dart)
- Sembast 是文档型 NoSQL 存储；`sembast_web` 建在 IndexedDB 上，支持 Flutter Web JS / Wasm。它会把数据库载入内存，跨标签页事务可能重跑，因此事务必须幂等；调试时数据还受 origin 和端口隔离。[Sembast README](https://github.com/tekartik/sembast.dart/tree/master/sembast) · [Sembast Web README](https://github.com/tekartik/sembast.dart/tree/master/sembast_web)

### 对本教程的设计启示

| 数据形态 | 候选 | 要讲清的边界 |
| --- | --- | --- |
| 主题、排序、首次引导等少量偏好 | `shared_preferences` | 不是数据库，不存关键业务记录；首版应直接使用新的 Async 或 WithCache API。[README](https://github.com/flutter/packages/tree/main/packages/shared_preferences/shared_preferences) |
| 关系、筛选、排序、迁移、事务、响应式查询 | Drift | 教学收益高，但 Web 资产、Worker、Wasm MIME、响应头和 GitHub Pages 部署都进入验收范围。[Web 文档](https://drift.simonbinder.eu/platforms/web/) |
| 本地对象 / key-value，查询关系简单 | Hive CE | API 比关系数据库短，但 adapter、box 生命周期和模型迁移仍需设计；不能用 key-value 示例假装已经讲过关系建模。[Hive CE README](https://github.com/IO-Design-Team/hive_ce/tree/main/hive) |
| 文档记录、需要 IndexedDB 且不想带 SQLite Wasm | Sembast | 要接受全库入内存、动态 Map 记录和幂等事务约束；更适合中小数据集的教学项目。[Sembast Web README](https://github.com/tekartik/sembast.dart/tree/master/sembast_web) |

持久化不宜全站统一成一个包。偏好设置与结构化离线数据本来就是两种问题；需要决定的是统筹项目是否真有关系查询和迁移需求，再决定是否承担 Drift 的 Web 部署成本。[shared_preferences README](https://github.com/flutter/packages/tree/main/packages/shared_preferences/shared_preferences) · [Drift Web 文档](https://drift.simonbinder.eu/platforms/web/)

## 6. 测试辅助

### 可核对事实

- Flutter 把自动化测试分为单元、Widget 和集成测试。官方建议大量单元 / Widget 测试，再用足够的集成测试覆盖重要流程；集成测试置信度最高，也最慢、维护成本最高。[Flutter testing overview](https://docs.flutter.dev/testing/overview)
- `flutter_test` 提供 Widget 测试绑定、finder、matcher 和 `WidgetTester`；`integration_test` 复用 `flutter_test` 风格，在完整应用上运行。它们都跟随 Flutter SDK。[flutter_test pubspec](https://github.com/flutter/flutter/blob/3.47.0/packages/flutter_test/pubspec.yaml) · [integration_test 文档](https://docs.flutter.dev/testing/integration-tests)
- Web 集成测试的官方流程使用 ChromeDriver 与 `flutter drive -d chrome`；无头模式可用 `-d web-server`。[Flutter Web integration tests](https://docs.flutter.dev/testing/integration-tests#test-in-a-web-browser)
- Mocktail 用 null-safe API 提供 stub、verify 和 argument capture，不需要手写 mock 或代码生成。[Mocktail README](https://github.com/felangel/mocktail/tree/main/packages/mocktail)
- `http` 自带 `MockClient`；只测试 HTTP 请求和响应时，不一定需要通用 mock 框架。[http README](https://github.com/dart-lang/http/tree/master/pkgs/http)

### 对本教程的设计启示

- 基线只依赖 `flutter_test` 和 `integration_test`：纯函数与 ViewModel 做单元测试，界面状态与交互做 Widget 测试，每个真实项目保留少量 Chrome 关键流程。[Flutter testing overview](https://docs.flutter.dev/testing/overview)
- 优先写内存 Repository、fixture Service 和小型 fake。需要验证调用次数、异常分支或第三方接口很大时，再引入 Mocktail；这样读者先学测试边界，不先学 mock DSL。[Flutter mocking recipe](https://docs.flutter.dev/cookbook/testing/unit/mocking) · [Mocktail README](https://github.com/felangel/mocktail/tree/main/packages/mocktail)
- 如果最终采用 BLoC，`bloc_test` 可放在 BLoC 专题内，不应成为所有测试的共同依赖。[bloc_test README](https://github.com/felangel/bloc/tree/master/packages/bloc_test)
- Chrome 测试之外还要单独运行 `flutter analyze`、普通 `flutter test` 和 `flutter build web`。集成测试通过不能代替 release 构建，也不能证明移动端插件行为。[Flutter testing overview](https://docs.flutter.dev/testing/overview) · [Flutter Web deployment](https://docs.flutter.dev/deployment/web)

## 7. 与 Flutter 官方架构指南的组合方式

### 可核对事实

- 官方指南建议 UI 层由 View 与 ViewModel 组成，数据层由 Repository 与 Service 组成；复杂业务才加可选领域层。Repository 是模型数据的单一事实来源，Service 只包装外部 API、平台能力或本地数据源。[Flutter 架构指南](https://docs.flutter.dev/app-architecture/guide)
- 官方案例把 ViewModel 实现成 `ChangeNotifier`，通过 Command 表达异步动作，用 provider 做依赖注入。文档明确说这只是一个实现，可以换成 Riverpod、`flutter_bloc`、signals 或 Stream。[Flutter 架构案例](https://docs.flutter.dev/app-architecture/case-study)
- 官方 Result 模式把成功或失败放进返回类型，减少跨 Service、Repository、ViewModel 的隐式异常路径。[Flutter Result pattern](https://docs.flutter.dev/app-architecture/design-patterns/result)
- 官方 recommendations 强推荐 UI / data 分层、Repository、单向数据流、不可变模型、依赖注入和分层测试；`ChangeNotifier`、provider 与 domain layer 都带适用条件。该页还把 `go_router` 列为大多数应用的推荐，并提醒 Freezed / built_value 在模型很多时会增加构建时间。[Flutter architecture recommendations](https://docs.flutter.dev/app-architecture/recommendations)

### 候选如何落位

| 架构位置 | 可替换候选 | 保持不变的责任边界 |
| --- | --- | --- |
| View | Flutter Widget + `flutter_test` | 渲染不可变 UI 状态、转发用户动作，不直接解析 JSON 或访问数据库。[架构指南](https://docs.flutter.dev/app-architecture/guide) |
| ViewModel | `ChangeNotifier`、Riverpod Notifier、Cubit / Bloc | 组合 Repository 输出，形成页面状态和命令；不承担 HTTP adapter 或 SQL 细节。[架构指南](https://docs.flutter.dev/app-architecture/guide) · [架构案例](https://docs.flutter.dev/app-architecture/case-study) |
| Repository | 普通 Dart 类，由 provider / Riverpod / BlocProvider 等注入 | 作为领域数据的单一事实来源，处理缓存、刷新、重试和模型转换。[架构指南](https://docs.flutter.dev/app-architecture/guide) |
| Service | `http` 或 Dio；`shared_preferences`、Drift、Hive CE、Sembast | 只封装一种外部数据源或平台 API，返回 DTO / Result，不决定页面状态。[架构指南](https://docs.flutter.dev/app-architecture/guide) |
| 路由 | `Navigator` / `Router` 或 `go_router` | 根据应用状态选择页面和 URL，不成为会话数据或业务记录的存储位置。[Router API](https://api.flutter.dev/flutter/widgets/Router-class.html) · [架构指南](https://docs.flutter.dev/app-architecture/guide) |

这套映射允许教程先用 SDK 完成一个小型版本，再替换某一层的实现。替换前后的 Repository 接口、UI 状态和测试用例应尽量不变；这样第三方包展示的是具体收益，不会把项目改造成另一份无法对照的代码。[Flutter 架构案例](https://docs.flutter.dev/app-architecture/case-study)

## 8. 最终选型前要过的门槛

以下项目需要原型或实际构建结果，靠文档比较还不能决定：

1. **Riverpod Web 元数据**：用 Flutter 3.47 / Dart 3.13 创建最小 `flutter_riverpod 3.4.2` 应用，运行 analyze、Widget test、Chrome integration test 和 release Web build；记录 pub.dev Web 标签缺失是否影响主入口。[平台元数据](https://pub.dev/api/packages/flutter_riverpod/score) · [pubspec](https://github.com/rrousselGit/riverpod/blob/master/packages/flutter_riverpod/pubspec.yaml)
2. **状态管理教学成本**：用同一个异步列表页面分别做 provider、Riverpod、Cubit 三个短原型，只比较状态转移、错误恢复、依赖替换、测试代码和首次出现的新概念，不比较 UI。[provider](https://github.com/rrousselGit/provider/tree/master/packages/provider) · [Riverpod](https://riverpod.dev/docs/concepts2/providers) · [flutter_bloc](https://github.com/felangel/bloc/tree/master/packages/flutter_bloc)
3. **go_router 静态部署**：验证 `/flutter-tutorial/` 基路径、地址栏直达、刷新、浏览器前进后退、404 回退、重定向和 `ShellRoute`。应用内 `context.go` 成功不算完成 Web 路由验收。[go_router Web docs](https://pub.dev/documentation/go_router/latest/topics/Web-topic.html) · [Flutter URL strategy](https://docs.flutter.dev/ui/navigation/url-strategies)
4. **HTTP 主方案规模**：用相同 Service 接口实现一次 `http` 和 Dio，确认本教程的项目是否真的需要 interceptor、取消、上传进度或 custom adapter。没有这些需求时，Dio 的额外 API 只会增加篇幅。[http README](https://github.com/dart-lang/http/tree/master/pkgs/http) · [Dio README](https://github.com/cfug/dio/tree/main/dio)
5. **模型代码生成阈值**：选一个真实 DTO 和一个带多状态分支的 UI state，分别手写、使用 `json_serializable`、使用 Freezed；比较正文首次解释量、生成命令、失败排查和最终测试。[json_serializable](https://github.com/google/json_serializable.dart/tree/master/json_serializable) · [Freezed](https://github.com/rrousselGit/freezed/tree/master/packages/freezed)
6. **持久化部署成本**：若统筹项目需要 Drift，必须在 GitHub Pages 上验证 Wasm MIME、Worker 路径、无 COOP / COEP 时的回退、刷新后数据、隐私模式和多标签页；否则优先保留 `shared_preferences` 与一个 IndexedDB / key-value 备选的原型。[Drift Web 文档](https://drift.simonbinder.eu/platforms/web/) · [shared_preferences](https://github.com/flutter/packages/tree/main/packages/shared_preferences/shared_preferences) · [Sembast Web](https://github.com/tekartik/sembast.dart/tree/master/sembast_web)
7. **测试辅助边界**：先用 fake 和 `http.MockClient` 完成项目测试，再统计哪些测试确实需要通用 mock；只有这些用例进入 Mocktail 教学。[Flutter mocking recipe](https://docs.flutter.dev/cookbook/testing/unit/mocking) · [http README](https://github.com/dart-lang/http/tree/master/pkgs/http) · [Mocktail README](https://github.com/felangel/mocktail/tree/main/packages/mocktail)

## 调查给出的取舍，不是最终方案

- provider 与官方案例、SDK 原理的衔接最短；Riverpod 对异步、缓存和替换更完整；BLoC 的事件 / 状态边界最显式。三者的差异主要落在教学心智模型和项目规模，不在 Flutter 官方架构是否兼容。[Flutter 架构案例](https://docs.flutter.dev/app-architecture/case-study)
- `go_router` 覆盖教程需要的 Web 导航能力，但直接 `Navigator` / `Router` 仍要先讲，避免读者只会调用包 API。[Flutter navigation](https://docs.flutter.dev/ui/navigation) · [go_router README](https://github.com/flutter/packages/tree/main/packages/go_router)
- `http` 足够承担基础网络与可测试 Service；Dio 只有在项目持续使用 interceptor、取消、上传下载等能力时才抵得过额外篇幅。[http README](https://github.com/dart-lang/http/tree/master/pkgs/http) · [Dio README](https://github.com/cfug/dio/tree/main/dio)
- `json_serializable` 解决序列化，Freezed 再解决不可变 value object 和 union。两者可以组合，但不应在读者尚未手写过模型转换时一起出现。[json_serializable README](https://github.com/google/json_serializable.dart/tree/master/json_serializable) · [Freezed README](https://github.com/rrousselGit/freezed/tree/master/packages/freezed)
- `shared_preferences` 适合偏好，Drift 适合关系数据，Hive CE / Sembast 适合较简单的本地对象或文档数据。一个“主持久化包”无法抹平这些数据形态差异。[shared_preferences README](https://github.com/flutter/packages/tree/main/packages/shared_preferences/shared_preferences) · [Drift overview](https://drift.simonbinder.eu/) · [Hive CE README](https://github.com/IO-Design-Team/hive_ce/tree/main/hive) · [Sembast Web README](https://github.com/tekartik/sembast.dart/tree/master/sembast_web)
- 测试栈应以 Flutter SDK 为主，mock 是补充。Web 验收需要真正跑浏览器关键流程，同时保留更多便宜、稳定的单元和 Widget 测试。[Flutter testing overview](https://docs.flutter.dev/testing/overview) · [Flutter Web integration tests](https://docs.flutter.dev/testing/integration-tests#test-in-a-web-browser)
