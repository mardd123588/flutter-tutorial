# 第五部分官方资料研究：导航、适应、可访问性与国际化

> 查阅日期：2026-08-30
> 教程基线：Flutter 3.47.0、Dart 3.13.0
> 依赖基线：`go_router 18.0.0`、`flutter_localizations`（Flutter SDK）、`intl 0.20.3`
> 资料范围：Flutter / Dart 官方文档与 API、`go_router` 官方仓库、GitHub Pages 官方文档、WCAG 2.2 规范

这份笔记只确定第五部分的知识边界、章节依赖、项目范围和验收方式，不直接充当教程正文。下文把 SDK、包、平台和规范规定写成“官方事实”，把章节拆分、URL 设计和项目功能写成“课程建议”。

## 1. 版本基线与仓库约束

- `go_router 18.0.0` 最低要求 Flutter 3.44、Dart 3.12，当前基线可直接使用。18.0.0 主要迁移到 `material_ui` / `cupertino_ui`，本部分只使用稳定的导航接口，不追逐内部实现。[go_router 18.0.0](https://pub.dev/packages/go_router/versions/18.0.0) · [18.0.0 CHANGELOG](https://github.com/flutter/packages/blob/go_router-v18.0.0/packages/go_router/CHANGELOG.md)（查阅：2026-08-30）
- Flutter 3.47.0 的 `flutter_localizations` 依赖 `intl ^0.20.3`。示例不另行锁定旧版 `intl`，避免依赖求解冲突。[flutter_localizations pubspec](https://github.com/flutter/flutter/blob/3.47.0/packages/flutter_localizations/pubspec.yaml) · [intl 0.20.3](https://pub.dev/packages/intl/versions/0.20.3)（查阅：2026-08-30）
- 新内容使用 `PopScope`，不再教已弃用且不支持 Android Predictive Back 的 `WillPopScope`；`RouteInformation` 直接使用 `uri`，不再使用已弃用的 `location`。[PopScope](https://api.flutter.dev/flutter/widgets/PopScope-class.html) · [WillPopScope](https://api.flutter.dev/flutter/widgets/WillPopScope-class.html) · [RouteInformation](https://api.flutter.dev/flutter/widgets/RouteInformation-class.html)（查阅：2026-08-30）
- Flutter Web 默认使用 hash URL。Path 策略要求服务器把未知路径重写到 `index.html`；GitHub Pages 是静态托管，只提供静态文件与自定义 `404.html`，没有项目级 SPA rewrite 配置。[Flutter URL strategies](https://docs.flutter.dev/ui/navigation/url-strategies) · [What is GitHub Pages](https://docs.github.com/en/pages/getting-started-with-github-pages/what-is-github-pages) · [Custom 404 page](https://docs.github.com/en/pages/getting-started-with-github-pages/creating-a-custom-404-page-for-your-github-pages-site)（查阅：2026-08-30）

仓库已有两个决定，本部分不得自行改写：

1. [ADR-0010](../adr/0010-hash-urls-on-github-pages.md)：GitHub Pages 上继续使用 hash URL，只有将来具备并愿意维护 SPA fallback 时才考虑 path URL。
2. [ADR-0017](../adr/0017-project-previews-share-the-pages-artifact.md)：VitePress 位于 `/flutter-tutorial/`；每个 Flutter Web 项目独立构建到 `/flutter-tutorial/previews/<project-slug>/`，项目内部继续使用 hash URL；预览产物与站点产物在发布阶段合并，仓库不提交生成后的 Web 文件。

因此两个项目固定使用各自的 base href：

```text
/flutter-tutorial/previews/route-share-card/
/flutter-tutorial/previews/venue-guidebook/
```

项目内部路由位于 `#/...` 之后。上述 slug 是第五部分的课程命名建议；若后续 issue 固定了别的 slug，只统一替换 slug，不改变“独立 base href + hash URL”的部署合同。

## 2. `Navigator`：页面栈、结果与离开确认

### 2.1 `push` / `pop` 是带类型的 Route 合同

- `Navigator` 管理后进先出的 `Route` 栈。`Navigator.push<T>` 返回 `Future<T?>`；被压入的路由退出时，`Navigator.pop(context, result)` 用 `result` 完成这个 Future。`Route<T>`、`push<T>` 和 `pop<T>` 的结果类型应保持一致。[Navigator](https://api.flutter.dev/flutter/widgets/Navigator-class.html) · [Navigator.push](https://api.flutter.dev/flutter/widgets/Navigator/push.html) · [Navigator.pop](https://api.flutter.dev/flutter/widgets/Navigator/pop.html)（查阅：2026-08-30）
- 用户通过系统返回、AppBar 返回或其他没有显式结果的路径退出时，调用方通常得到 `null`。页面结果必须建模为可空值，或在调用方明确处理取消。[Return data from a screen](https://docs.flutter.dev/cookbook/navigation/returning-data)（查阅：2026-08-30）
- `Navigator.of(context)` 默认找到最近的 Navigator。应用存在 `ShellRoute`、嵌套 Navigator 或根级对话框时，必须说明页面压入、弹出的是哪一个栈；需要根栈时显式使用 `rootNavigator: true` 或根 `navigatorKey`。[Navigator](https://api.flutter.dev/flutter/widgets/Navigator-class.html) · [showDialog](https://api.flutter.dev/flutter/material/showDialog.html)（查阅：2026-08-30）
- `Navigator.maybePop()` 返回“这次返回请求是否已被处理”，不等于“路由一定弹出”：`RoutePopDisposition.doNotPop` 时仍返回 `true`，只有 `bubble` 才返回 `false`。[Navigator.maybePop](https://api.flutter.dev/flutter/widgets/Navigator/maybePop.html)（查阅：2026-08-30）
- `await Navigator.push(...)` 之后若还要使用原页面的 `BuildContext`，先检查 `context.mounted`；等待期间调用方可能已经离开树。[BuildContext.mounted](https://api.flutter.dev/flutter/widgets/BuildContext/mounted.html)（查阅：2026-08-30）

课程先用“选择地点并回传地点 ID”说明带类型结果，再用取消得到 `null`。不要把 `pop` 只解释成“返回上一页”，也不要让结果退化为 `dynamic`。

### 2.2 Dialog 仍是一条 Route

- `showDialog<T>` 返回 `Future<T?>`，可用 `Navigator.pop(context, result)` 回传选择。`barrierDismissible` 默认是 `true`，只决定点击遮罩能否关闭，不代表系统返回也被禁用。[showDialog](https://api.flutter.dev/flutter/material/showDialog.html)（查阅：2026-08-30）
- 对话框 `builder` 收到的上下文与调用 `showDialog` 的位置不共享同一个上下文。对话框需要局部可变状态时，用独立 `StatefulWidget` 或 `StatefulBuilder`。[showDialog](https://api.flutter.dev/flutter/material/showDialog.html)（查阅：2026-08-30）
- `showDialog` 的 `useRootNavigator` 默认为 `true`。嵌套 Navigator 中关闭根级对话框时，可能需要 `Navigator.of(context, rootNavigator: true).pop(result)`。[showDialog](https://api.flutter.dev/flutter/material/showDialog.html)（查阅：2026-08-30）

本节只用 dialog 处理短暂选择或确认。需要地址栏可表达、刷新后仍存在的内容，应建成页面路由，不能藏在 dialog 中。

### 2.3 `PopScope` 与 Router 离开拦截不是一回事

- `PopScope.canPop` 必须在返回手势发生前表达当前能否退出；`onPopInvokedWithResult` 是返回尝试结束后的通知，通过 `didPop` 说明是否成功，不能返回布尔值去撤销已经发生的 pop。[PopScope](https://api.flutter.dev/flutter/widgets/PopScope-class.html) · [Android predictive back migration](https://docs.flutter.dev/release/breaking-changes/android-predictive-back)（查阅：2026-08-30）
- `canPop: false` 时，Android 的返回尝试仍会回调且 `didPop == false`；使用 Cupertino 路由过渡时，iOS 侧滑可能根本不被识别，因而没有回调。教程不能把两个平台讲成完全相同。[PopScope](https://api.flutter.dev/flutter/widgets/PopScope-class.html)（查阅：2026-08-30）
- Router 生成的 page-backed route 不能只靠 `PopScope` 阻止声明式路由变化。`go_router` 的 `GoRoute.onExit` 才是对应边界：返回或异步完成为 `true` 才允许退出，为 `false` 则中止。[Flutter navigation and routing](https://docs.flutter.dev/ui/navigation) · [GoRoute.onExit 18.0.0](https://pub.dev/documentation/go_router/18.0.0/go_router/GoRoute/onExit.html)（查阅：2026-08-30）

命令式编辑页的确认流程是：先以 `canPop: false` 阻止退出，在 `didPop == false` 时询问，确认后再主动退出。不得在回调里无条件二次 `pop`。声明式 `GoRoute` 页面则使用 `onExit`，不混用两套机制。

### 2.4 状态恢复只恢复已注册、可序列化的状态

- Navigator 需要有效的 `restorationScopeId` 才能恢复路由历史。page-based 路由还要提供 `Page.restorationId`；普通 `push` / `pushNamed` 加入的路由不会自动恢复。[Navigator state restoration](https://api.flutter.dev/flutter/widgets/Navigator-class.html)（查阅：2026-08-30）
- 可恢复命令式导航使用 `restorablePush` / `restorablePushNamed`。`restorablePush` 的 route builder 必须是带 `@pragma('vm:entry-point')` 的静态函数，arguments 只能使用 `StandardMessageCodec` 可序列化的值。[Navigator.restorablePush](https://api.flutter.dev/flutter/widgets/Navigator/restorablePush.html)（查阅：2026-08-30）
- `restorablePush` 返回不透明的路由 ID，不是页面结果；需要跨恢复周期接收结果时使用 `RestorableRouteFuture`。[Navigator.restorablePush](https://api.flutter.dev/flutter/widgets/Navigator/restorablePush.html) · [RestorableRouteFuture](https://api.flutter.dev/flutter/widgets/RestorableRouteFuture-class.html)（查阅：2026-08-30）
- `showDialog` 本身不会启用状态恢复。可恢复 Material 对话框要用 `Navigator.restorablePush` 配合 `DialogRoute`，并配置应用的 restoration scope。[showDialog state restoration](https://api.flutter.dev/flutter/material/showDialog.html)（查阅：2026-08-30）

状态恢复不是通用持久化，也不代替深链接。第五部分只讲清接口与边界；两个项目的可分享状态仍以 URL 为准，不为演示 restoration 增加额外业务复杂度。

## 3. Router、`RouteInformation` 与浏览器历史

### 3.1 Router 负责协调，Navigator 负责展示

用下面这条链路解释 Router，不先陷入自定义 delegate 的样板代码：

```text
平台 URL / 深链接
→ RouteInformationProvider
→ RouteInformationParser
→ 路由配置 T
→ RouterDelegate
→ Navigator.pages
```

- `Router` 接收初始路由、新深链接和系统返回请求，把 `RouteInformation` 解析为配置，再让 `RouterDelegate` 构建导航界面。`BackButtonDispatcher` 负责分派返回请求；Navigator 仍负责展示 Page / Route 栈。[Router](https://api.flutter.dev/flutter/widgets/Router-class.html) · [RouteInformationParser](https://api.flutter.dev/flutter/widgets/RouteInformationParser-class.html) · [RouterDelegate](https://api.flutter.dev/flutter/widgets/RouterDelegate-class.html)（查阅：2026-08-30）
- `RouteInformation` 包含 `uri` 与可选 `state`，双向流动于平台、provider 与 Router 之间。复制 URL 只复制 URI，不会复制 browser history 条目里的 `state`。[RouteInformation](https://api.flutter.dev/flutter/widgets/RouteInformation-class.html)（查阅：2026-08-30）
- `PlatformRouteInformationProvider` 会通过 `SystemNavigator.routeInformationUpdated` 把应用路由变化报告给平台，并使用多条目的浏览器历史模式。[PlatformRouteInformationProvider](https://api.flutter.dev/flutter/widgets/PlatformRouteInformationProvider-class.html)（查阅：2026-08-30）

05-02 只手写一个很小的配置类型和解析示意，用来理解职责；生产示例直接使用 `go_router`。不要重复造一套完整 Router 框架。

### 3.2 浏览器历史不是 Navigator 栈的同义词

- Web 上新的 URI 与当前 URI 不同时，Router 默认新建浏览器历史条目；URI 相同时默认替换当前条目。`Router.navigate` 可强制新增条目，`Router.neglect` 可强制替换条目。[Router URL updates](https://api.flutter.dev/flutter/widgets/Router-class.html)（查阅：2026-08-30）
- 浏览器 Back / Forward 遍历访问时间线，不等于 `Navigator.pop`。Flutter 官方特别说明：先从 Navigator 弹出页面，再按浏览器 Back，旧历史位置可能把刚弹出的页面重新压回栈。[Flutter navigation web support](https://docs.flutter.dev/ui/navigation)（查阅：2026-08-30）
- 多个 Router 中通常只让最顶层 Router 负责 URL；否则同一个地址栏会接收多个路由树的报告。[Router](https://api.flutter.dev/flutter/widgets/Router-class.html)（查阅：2026-08-30）

课程为每一种会改变 URL 的交互先定义产品语义：打开地点详情应新增历史；同一详情页里不值得回看的临时 UI 状态不应机械地新增历史。验收必须覆盖连续 Back、Forward、刷新和直接粘贴，不能只看地址栏是否变化。

## 4. `go_router 18.0.0`

### 4.1 `go`、`push` 与返回值

- `context.go()` 前往目标 URL，并按目标路由重新组成页面栈；`context.push()` 做命令式压栈，`push<T>` / `pop(result)` 支持返回结果。[go_router navigation 18.0.0](https://github.com/flutter/packages/blob/go_router-v18.0.0/packages/go_router/doc/navigation.md)（查阅：2026-08-30）
- 官方文档明确提示 `push()` 与浏览器历史存在已知问题。Web 主导航优先使用 URL 驱动的 `go()`；`push()` 留给确实需要临时栈与返回值的短流程。[go_router navigation 18.0.0](https://github.com/flutter/packages/blob/go_router-v18.0.0/packages/go_router/doc/navigation.md)（查阅：2026-08-30）
- 直接调用 `Navigator.push` 仍能显示页面，但这类页面不可深链；父 GoRoute 被移除或下一次 `go()` 重组页面栈时，pageless 路由也会被移除。[go_router navigation 18.0.0](https://github.com/flutter/packages/blob/go_router-v18.0.0/packages/go_router/doc/navigation.md)（查阅：2026-08-30）

本部分的主页面全部可由 URL 重建。临时地点选择可演示一次 `push<T>` / `pop<T>`；路线详情、场馆详情和筛选状态不使用命令式 push 隐藏。

### 4.2 参数与 URL 构造

- 路径参数用 `:name` 声明，从 `state.pathParameters` 读取；查询参数从 `state.uri.queryParameters` 读取。两者都是字符串，数字、枚举、日期、允许值和业务范围都要由应用验证。[go_router configuration 18.0.0](https://github.com/flutter/packages/blob/go_router-v18.0.0/packages/go_router/doc/configuration.md)（查阅：2026-08-30）
- 18.0.0 匹配器会解码 path parameter，命名地址构建会编码 path parameter，并通过 `Uri` 生成查询串。应用仍应使用 `Uri(path: ..., queryParameters: ...)` 构造地址，不手拼 `?`、`&` 与百分号编码。[go_router match.dart 18.0.0](https://github.com/flutter/packages/blob/go_router-v18.0.0/packages/go_router/lib/src/match.dart) · [go_router navigation 18.0.0](https://github.com/flutter/packages/blob/go_router-v18.0.0/packages/go_router/doc/navigation.md) · [Dart Uri](https://api.dart.dev/dart-core/Uri-class.html)（查阅：2026-08-30）
- 查询键可能重复。只需要单值时读 `queryParameters`；需要保留全部值时读 `queryParametersAll`，不能悄悄丢掉重复值。[Uri.queryParametersAll](https://api.dart.dev/dart-core/Uri/queryParametersAll.html)（查阅：2026-08-30）
- `Uri.tryParse` 只能判断输入能否构造成 URI，不能证明地址符合应用业务。数值可用 `int.tryParse` 等安全解析，再检查范围与资源是否存在。[Uri.tryParse](https://api.dart.dev/dart-core/Uri/tryParse.html) · [int.tryParse](https://api.dart.dev/dart-core/int/tryParse.html)（查阅：2026-08-30）
- `extra` 不属于 URL。它写入浏览器历史时需要序列化；复杂对象没有 `extraCodec` 时可能丢失，直接粘贴 URL 到新标签时也不会存在。[go_router navigation 18.0.0](https://github.com/flutter/packages/blob/go_router-v18.0.0/packages/go_router/doc/navigation.md)（查阅：2026-08-30）

课程统一采用：path 表达资源身份，query 表达可选筛选、排序和视图，`extra` 只放可缺失的进程内优化数据。复制链接后必须只凭 URL 和稳定数据源恢复同一视图。

### 4.3 redirect、离开确认与循环

- 顶层 `GoRouter.redirect` 在每次导航前执行；路由级 `GoRoute.redirect` 在即将显示对应路由时执行。返回 `null` 或原地址表示不跳转。[go_router redirection 18.0.0](https://github.com/flutter/packages/blob/go_router-v18.0.0/packages/go_router/doc/redirection.md)（查阅：2026-08-30）
- redirect 可以同步或异步返回新地址，但它的职责是地址决策。离开确认使用 `GoRoute.onExit`，不要在 redirect 中弹对话框。[GoRouterRedirect 18.0.0](https://pub.dev/documentation/go_router/18.0.0/go_router/GoRouterRedirect.html) · [GoRoute.onExit 18.0.0](https://pub.dev/documentation/go_router/18.0.0/go_router/GoRoute/onExit.html)（查阅：2026-08-30）
- 默认最多连续重定向 5 次，超过限制进入错误处理。登录或引导跳转必须避免自身循环，并用 `Uri` 编码原始目标地址。[go_router redirection 18.0.0](https://github.com/flutter/packages/blob/go_router-v18.0.0/packages/go_router/doc/redirection.md)（查阅：2026-08-30）
- `initialLocation` 只应在平台没有提供深链接时决定初始位置，不能覆盖用户粘贴进来的有效地址。[go_router configuration 18.0.0](https://github.com/flutter/packages/blob/go_router-v18.0.0/packages/go_router/doc/configuration.md)（查阅：2026-08-30）

第五部分不引入登录系统。redirect 只演示规范化地址和缺少必要参数时的安全回退，避免为了展示 API 增造权限状态。

### 4.4 `ShellRoute` 与错误页

- `ShellRoute` 创建额外 Navigator，`builder` 的 `child` 是内部 Navigator 当前匹配的内容，适合持续显示导航栏或应用外壳。需要让详情页盖住整个外壳时，为该路由指定根 `parentNavigatorKey`。[ShellRoute 18.0.0](https://pub.dev/documentation/go_router/18.0.0/go_router/ShellRoute-class.html) · [go_router configuration 18.0.0](https://github.com/flutter/packages/blob/go_router-v18.0.0/packages/go_router/doc/configuration.md)（查阅：2026-08-30）
- 普通 `ShellRoute` 不会为每个标签保留独立导航栈。确实需要多分支独立 Navigator 与状态保留时才使用 `StatefulShellRoute`。[go_router configuration 18.0.0](https://github.com/flutter/packages/blob/go_router-v18.0.0/packages/go_router/doc/configuration.md)（查阅：2026-08-30）
- 无法匹配的地址会产生 `GoException`，可用 `onException`、`errorBuilder` 或 `errorPageBuilder` 处理；18.0.0 的构造器要求三者最多选一种。配置错误和断言属于 `GoError` / assertion，应修代码，不能伪装成用户 404。[go_router error handling 18.0.0](https://github.com/flutter/packages/blob/go_router-v18.0.0/packages/go_router/doc/error-handling.md) · [router.dart 18.0.0](https://github.com/flutter/packages/blob/go_router-v18.0.0/packages/go_router/lib/src/router.dart)（查阅：2026-08-30）
- 语法能匹配但业务非法的地址，如不存在的场馆 ID、负数楼层或未知排序值，不会自动成为 `GoException`。应用必须在参数解析与数据查找边界给出领域化结果。[go_router configuration 18.0.0](https://github.com/flutter/packages/blob/go_router-v18.0.0/packages/go_router/doc/configuration.md)（查阅：2026-08-30）

路线分享卡不需要 Shell；场馆导览册使用一个 `ShellRoute` 承载顶层导航，不引入 `StatefulShellRoute`。错误界面同时提供可理解的原因、回到安全入口的动作和原始 URL 的必要摘要，不显示堆栈。

## 5. 深链接、Hash URL 与 GitHub Pages

### 5.1 Hash 与 Path 的真实边界

- Flutter Web 默认 hash URL，例如 `example.com/#/venues/atrium`。hash fragment 由客户端处理，不会随 HTTP 请求发给服务器，因此刷新时服务器仍只请求 Flutter 应用入口。[Flutter URL strategies](https://docs.flutter.dev/ui/navigation/url-strategies) · [RFC 9110 URI fragment](https://www.rfc-editor.org/rfc/rfc9110.html#section-4.2.5)（查阅：2026-08-30）
- Path 策略使用 `usePathUrlStrategy()`，必须在 `runApp()` 前调用；生产服务器还必须把未知应用路径重写到 `index.html`。本地 `flutter run -d chrome` 已处理 fallback，不能据此推断生产部署正确。[Flutter URL strategies](https://docs.flutter.dev/ui/navigation/url-strategies)（查阅：2026-08-30）
- 部署到非根目录时，`web/index.html` 的 `<base href>` 必须与应用实际基路径一致。GitHub Pages 项目站默认位于 `/<repository>/`，预览再放入子目录时要使用完整项目路径。[Flutter URL strategies](https://docs.flutter.dev/ui/navigation/url-strategies) · [GitHub Pages site types](https://docs.github.com/en/pages/getting-started-with-github-pages/what-is-github-pages#types-of-github-pages-sites)（查阅：2026-08-30）
- GitHub Pages 没有 Flutter Path 策略所需的任意路径 rewrite。把 Flutter 产物复制为 `404.html` 是社区 workaround，不是 Pages 官方 rewrite；本教程不采用。[What is GitHub Pages](https://docs.github.com/en/pages/getting-started-with-github-pages/what-is-github-pages) · [Custom 404 page](https://docs.github.com/en/pages/getting-started-with-github-pages/creating-a-custom-404-page-for-your-github-pages-site)（查阅：2026-08-30）

本仓库的实际链接形态固定为：

```text
https://mardd123588.github.io/flutter-tutorial/previews/route-share-card/#/routes/museum-loop?mode=quiet
https://mardd123588.github.io/flutter-tutorial/previews/venue-guidebook/#/venues/atrium?floor=2
```

### 5.2 可复制链接的最低合同

一个链接只有同时满足下列条件，才算“可分享”：

1. 新标签直接粘贴后到达同一资源和视图；
2. 硬刷新后不依赖前一个进程内对象；
3. Back / Forward 的顺序符合用户刚才的导航；
4. 中文、空格、`/`、`%` 等字符经 `Uri` 正确编码；
5. query 缺失、重复、未知、越界时有明确默认值或错误结果；
6. 资源不存在与路由根本不匹配分开处理；
7. URL 复制到另一个浏览器上下文后，不依赖 `extra` 仍可恢复。

这七条是课程验收合同，不是 Flutter 自动保证。Flutter Web 本身无需额外注册深链接；启动或运行中收到 URL 时，Router 会按路由配置重组页面栈。[Flutter deep linking](https://docs.flutter.dev/ui/navigation/deep-linking)（查阅：2026-08-30）

## 6. 响应式布局：约束先于设备名称

### 6.1 `MediaQuery` 与 `LayoutBuilder` 解决不同问题

- `MediaQuery.sizeOf(context)` 读取整个应用窗口大小；`LayoutBuilder` 的 builder 获得父级传给当前位置的 `BoxConstraints`。页面级外壳可看窗口，局部卡片、侧栏和内容区要看自身约束。[MediaQuery](https://api.flutter.dev/flutter/widgets/MediaQuery-class.html) · [LayoutBuilder](https://api.flutter.dev/flutter/widgets/LayoutBuilder-class.html)（查阅：2026-08-30）
- 优先使用 `MediaQuery.sizeOf`、`paddingOf`、`textScalerOf`、`disableAnimationsOf` 等特定 accessor。`MediaQuery.of` 依赖整个 `MediaQueryData`，任一字段变化都可能让调用处重建。[MediaQuery](https://api.flutter.dev/flutter/widgets/MediaQuery-class.html)（查阅：2026-08-30）
- Flutter 官方不建议按“手机 / 平板”名称或 orientation 硬编码布局。窗口可缩放、多窗口和折叠形态都会破坏这种假设；断点应放在内容开始拥挤、关键任务失去连续性的宽度。[Adaptive and responsive general approach](https://docs.flutter.dev/ui/adaptive-responsive/general) · [Adaptive best practices](https://docs.flutter.dev/ui/adaptive-responsive/best-practices)（查阅：2026-08-30）

第五部分仍以 600 logical px 作为起始探测值，但最终断点由真实中文标题、200% 文本和操作区是否拥挤决定。不能把 600 写成所有页面通用真理。

### 6.2 导航组件随可用空间变化

- `NavigationRail` 用于宽视口，通常放在 `Row` 的开头或末尾，承载少量主目的地。[NavigationRail](https://api.flutter.dev/flutter/material/NavigationRail-class.html)（查阅：2026-08-30）
- `NavigationDrawer` 是 Material 3 的主导航容器，窄屏时可由 `Scaffold.drawer` 打开。[NavigationDrawer](https://api.flutter.dev/flutter/material/NavigationDrawer-class.html)（查阅：2026-08-30）

场馆导览册保持相同的路由目的地集合：窄屏用 drawer，宽屏用 rail。切换布局不能重置当前路径、筛选、焦点目标或语言。不要为了桌面版另建一套路由树。

### 6.3 200% 文本也是布局输入

- WCAG 2.2 的 Resize Text 要求文本放大到 200% 时仍不丢内容和功能；Reflow 要求在 320 CSS px 宽的等效视口下，通常不需要双向滚动。[WCAG 2.2 Resize Text](https://www.w3.org/WAI/WCAG22/Understanding/resize-text.html) · [WCAG 2.2 Reflow](https://www.w3.org/WAI/WCAG22/Understanding/reflow.html)（查阅：2026-08-30）

项目不通过全局限制 `textScaler` 来“修复”溢出。允许标题换行、按钮增高、工具栏改为流式排列，必要时把次要动作移入菜单，但不能隐藏核心任务。

## 7. 指针、键盘与平台适应

### 7.1 Hover 只能增强，不能成为入口

- 桌面和 Web 需要考虑鼠标 hover、主次点击、滚轮、键盘 Tab 与快捷键；Flutter 官方建议优先使用已有 Material 控件，因为它们已带有大量焦点、hover 和键盘行为。自定义控件可用 `FocusableActionDetector` 组合焦点、快捷键与鼠标状态。[Adaptive input](https://docs.flutter.dev/ui/adaptive-responsive/input) · [FocusableActionDetector](https://api.flutter.dev/flutter/widgets/FocusableActionDetector-class.html)（查阅：2026-08-30）
- `MouseRegion` 负责指针进入、悬停和离开；`GestureDetector` / `InkWell` 负责可操作手势。只在 hover 时显示的说明或动作，触屏与键盘用户无法可靠取得。[MouseRegion](https://api.flutter.dev/flutter/widgets/MouseRegion-class.html) · [Adaptive input](https://docs.flutter.dev/ui/adaptive-responsive/input)（查阅：2026-08-30）

项目允许 hover 提供预览和强调，但每个动作必须有可点击、可聚焦且带可见名称的入口。路线卡的主要动作不能藏在卡片右上角 hover overlay 中。

### 7.2 键盘操作沿焦点树工作

- `Shortcuts` 把按键组合映射为 `Intent`，`Actions` 再把 `Intent` 映射为 `Action`。快捷键只在对应树拥有焦点时触发，比直接监听全局硬件键盘更容易控制作用域。[Shortcuts](https://api.flutter.dev/flutter/widgets/Shortcuts-class.html) · [Actions](https://api.flutter.dev/flutter/widgets/Actions-class.html)（查阅：2026-08-30）
- 默认焦点遍历使用 `ReadingOrderTraversalPolicy`，顺序依赖 `Directionality` 与几何位置。`FocusTraversalGroup` 用来隔离局部策略，不是要求给所有控件手工编号。[FocusTraversalGroup](https://api.flutter.dev/flutter/widgets/FocusTraversalGroup-class.html) · [ReadingOrderTraversalPolicy](https://api.flutter.dev/flutter/widgets/ReadingOrderTraversalPolicy-class.html)（查阅：2026-08-30）

场馆导览册至少提供 `/` 聚焦搜索、Escape 清除临时面板，且快捷键不抢占文本输入。Tab 顺序按视觉阅读顺序自然得到；只有布局重排造成歧义时才建立局部 traversal group。

### 7.3 Material / Cupertino 适应到行为层

- `showAdaptiveDialog` 在 iOS / macOS 使用 Cupertino dialog，在其他平台使用 Material dialog；不同分支的默认 barrier dismiss 行为也不同。[showAdaptiveDialog](https://api.flutter.dev/flutter/material/showAdaptiveDialog.html)（查阅：2026-08-30）
- `Switch.adaptive` 根据 `ThemeData.platform` 选择 Cupertino 或 Material 表现。组件做视觉与交互适应时读取 `Theme.of(context).platform`；只有确实调用平台系统 API 时才直接判断实际目标平台。[Switch.adaptive](https://api.flutter.dev/flutter/material/Switch/Switch.adaptive.html) · [ThemeData.platform](https://api.flutter.dev/flutter/material/ThemeData/platform.html) · [defaultTargetPlatform](https://api.flutter.dev/flutter/foundation/defaultTargetPlatform.html)（查阅：2026-08-30）

项目不追求把整个 Material 应用伪装成原生 iOS。只对返回、dialog、switch 等有明确平台惯例的行为做适应，同时保持信息结构和路由合同一致。

## 8. 可访问性作为功能

### 8.1 Semantics 优先继承，不要重复播报

- `Semantics` 向辅助技术、搜索和语义分析提供控件含义、状态与动作。内置 Material 控件已有语义，只有自定义绘制、组合控件或上下文不足时才补充。[Semantics](https://api.flutter.dev/flutter/widgets/Semantics-class.html) · [Flutter accessibility](https://docs.flutter.dev/ui/accessibility-and-internationalization/accessibility)（查阅：2026-08-30）
- Flutter 的 accessibility release checklist 建议可点击目标至少 48×48 logical px，并要求在 Android TalkBack 与 iOS VoiceOver 上检查可操作性。[Flutter accessibility](https://docs.flutter.dev/ui/accessibility-and-internationalization/accessibility)（查阅：2026-08-30）

路线图、楼层示意和自绘装饰必须区分：装饰图排除语义；表达路线或场馆状态的图给出简短摘要；具体地点仍由可聚焦列表承担操作。不要给已有文字标签的按钮再添加重复 label。

### 8.2 焦点必须可见、顺序可预测

- WCAG 2.2 要求键盘焦点指示可见，且不能被作者创建的内容完全遮挡。[WCAG 2.2 Focus Visible](https://www.w3.org/WAI/WCAG22/Understanding/focus-visible.html) · [WCAG 2.2 Focus Not Obscured](https://www.w3.org/WAI/WCAG22/Understanding/focus-not-obscured-minimum.html)（查阅：2026-08-30）
- `FocusTraversalGroup` 可为局部区域指定 traversal policy；默认 reading order 会结合 `Directionality`，因此 RTL 切换也必须重新检查 Tab 顺序。[FocusTraversalGroup](https://api.flutter.dev/flutter/widgets/FocusTraversalGroup-class.html) · [ReadingOrderTraversalPolicy](https://api.flutter.dev/flutter/widgets/ReadingOrderTraversalPolicy-class.html)（查阅：2026-08-30）

验收时从地址栏外进入应用，完整用 Tab / Shift+Tab / Enter / Space / Escape 完成主要任务。drawer、dialog 或错误页打开后，焦点不能落到被遮挡内容；关闭后应回到合理触发点。

### 8.3 对比度、颜色与错误提示

- WCAG 2.2 AA 要求普通文本至少 4.5:1，大文本至少 3:1。状态不能只靠颜色区分。[WCAG 2.2 Contrast Minimum](https://www.w3.org/WAI/WCAG22/Understanding/contrast-minimum.html) · [WCAG 2.2 Use of Color](https://www.w3.org/WAI/WCAG22/Understanding/use-of-color.html)（查阅：2026-08-30）
- 自动检测到输入错误时，应以文本指出出错项；已知修复建议时还应给出建议，除非会损害安全或目的。[WCAG 2.2 Error Identification](https://www.w3.org/WAI/WCAG22/Understanding/error-identification.html) · [WCAG 2.2 Error Suggestion](https://www.w3.org/WAI/WCAG22/Understanding/error-suggestion.html)（查阅：2026-08-30）

非法 URL、无结果和表单错误分开写。错误界面同时使用标题、说明与动作，不只把边框染红；字段错误紧邻字段并进入语义树，页面级错误提供安全返回路径。

### 8.4 减少动画不是统一关掉所有过渡

- `MediaQueryData.disableAnimations` 表示平台请求尽量禁用或减少动画。`MediaQuery.disableAnimationsOf(context)` 可只依赖这一字段；自定义显式动画需要自行跳过或缩短。[MediaQueryData.disableAnimations](https://api.flutter.dev/flutter/widgets/MediaQueryData/disableAnimations.html) · [MediaQuery.disableAnimationsOf](https://api.flutter.dev/flutter/widgets/MediaQuery/disableAnimationsOf.html)（查阅：2026-08-30）
- Flutter API 说明该标志在不同平台上的底层来源并不完全相同；不能把它写成“所有平台动画偏好的唯一来源”。[MediaQueryData.disableAnimations](https://api.flutter.dev/flutter/widgets/MediaQueryData/disableAnimations.html)（查阅：2026-08-30）

两个项目在 `disableAnimations == true` 时把装饰性入场和路线绘制动画改为零时长或静态终态；焦点反馈、加载状态和操作结果仍要即时可见。

## 9. 国际化、格式化与 RTL

### 9.1 `gen_l10n` 与 ARB 是正文主线

- Flutter 官方流程是在 `pubspec.yaml` 设置 `flutter: generate: true`，在项目根目录添加 `l10n.yaml`，再由 `flutter gen-l10n` 或 Flutter 构建流程生成本地化类。常用配置包括 `arb-dir: lib/l10n`、`template-arb-file: app_en.arb`、`output-localization-file: app_localizations.dart`。[Flutter internationalization](https://docs.flutter.dev/ui/accessibility-and-internationalization/internationalization)（查阅：2026-08-30）
- 应用把 `AppLocalizations.delegate` 加入 `localizationsDelegates`，并可直接使用生成类的 `supportedLocales`。`GlobalWidgetsLocalizations.delegate` 提供默认文本方向等 Widgets 本地化能力。[Flutter internationalization](https://docs.flutter.dev/ui/accessibility-and-internationalization/internationalization)（查阅：2026-08-30）
- ARB placeholder 名必须是合法 Dart identifier，并可在 `@message.placeholders` 中声明 `type`、`example` 和 `format`。日期、数字与货币格式也可由 placeholder metadata 指定。[Flutter internationalization](https://docs.flutter.dev/ui/accessibility-and-internationalization/internationalization)（查阅：2026-08-30）
- 复数使用 ICU message syntax；只有 `other` 分支是必需的，不同语言的复数规则不同，不能在 UI 里手写 `count == 1` 代替本地化规则。[Flutter internationalization](https://docs.flutter.dev/ui/accessibility-and-internationalization/internationalization)（查阅：2026-08-30）

05-06 用中英文展示普通消息、一个带地点名的 placeholder 和一个计数复数。不要同时引入性别、select 嵌套与远程翻译平台。

### 9.2 `intl` 格式化显示，不改变业务值

- `intl` 提供消息、复数、日期、数字和双向文本能力。`DateFormat` 与 `NumberFormat` 都接受 locale；未显式提供时会使用 `Intl.defaultLocale`。[intl 0.20.3 README](https://github.com/dart-lang/i18n/blob/intl-v0.20.3/pkgs/intl/README.md) · [DateFormat 0.20.3](https://pub.dev/documentation/intl/0.20.3/intl/DateFormat-class.html) · [NumberFormat 0.20.3](https://pub.dev/documentation/intl/0.20.3/intl/NumberFormat-class.html)（查阅：2026-08-30）
- `DateFormat` 的 skeleton 会按 locale 选择合适排列；`NumberFormat.decimalPattern`、`percentPattern`、`currency` 等会应用对应的分组、十进制和货币规则。[DateFormat 0.20.3](https://pub.dev/documentation/intl/0.20.3/intl/DateFormat-class.html) · [NumberFormat 0.20.3](https://pub.dev/documentation/intl/0.20.3/intl/NumberFormat-class.html)（查阅：2026-08-30）

业务层继续保存稳定的 `DateTime`、数值、地点 ID 与枚举；只在展示边界格式化。路由 path 不使用翻译后的标题，避免切换语言后资源身份改变。

### 9.3 `Locale` 与 RTL

- `Locale.fromSubtags` 可显式提供 `languageCode`、`scriptCode` 和 `countryCode`，比只用语言与地区的构造器更适合需要区分脚本的语言。[Locale.fromSubtags](https://api.flutter.dev/flutter/dart-ui/Locale/Locale.fromSubtags.html)（查阅：2026-08-30）
- `Directionality` 向子树提供 `TextDirection`。`EdgeInsetsDirectional`、`AlignmentDirectional`、`PositionedDirectional` 等会按当前方向解析 start / end，适合可镜像布局。[Directionality](https://api.flutter.dev/flutter/widgets/Directionality-class.html) · [EdgeInsetsDirectional](https://api.flutter.dev/flutter/painting/EdgeInsetsDirectional-class.html) · [AlignmentDirectional](https://api.flutter.dev/flutter/painting/AlignmentDirectional-class.html)（查阅：2026-08-30）
- Flutter 的 Widgets 本地化 delegate 会为支持的 locale 提供默认文本方向；应用仍要检查自定义绘制、非方向性 padding、箭头和路线示意是否符合语义。并非所有图标都应镜像。[Flutter internationalization](https://docs.flutter.dev/ui/accessibility-and-internationalization/internationalization) · [Directionality](https://api.flutter.dev/flutter/widgets/Directionality-class.html)（查阅：2026-08-30）

当前项目正式提供 `zh` 与 `en`，它们都是 LTR；为检验方向性布局，测试额外包一层 RTL `Directionality`，但不冒充已经提供完整阿拉伯语翻译。语言切换只改变 locale 和显示文本，保留当前 path、query 与选中地点。

## 10. Web 构建与深链接测试边界

- `flutter build web` 的产物位于 `build/web`；部署验证必须通过 HTTP 服务器进行，不能双击 `index.html`。[Build and release a web app](https://docs.flutter.dev/deployment/web)（查阅：2026-08-30）
- Flutter Web 集成测试可使用 `flutter drive -d web-server --browser-name=chrome`，并由 WebDriver 驱动浏览器。它适合验证完整用户流程；地址栏直接粘贴、硬刷新与 Back / Forward 仍要在真实浏览器会话中补验。[Flutter integration tests in a web browser](https://docs.flutter.dev/testing/integration-tests#test-in-a-web-browser)（查阅：2026-08-30）
- Widget 测试可通过受控路由配置验证参数解析、错误页和布局分支，但不能证明 GitHub Pages 的 base href、静态资源路径与刷新行为正确。部署合同必须用 release 构建和 HTTP 路径验证。[Flutter URL strategies](https://docs.flutter.dev/ui/navigation/url-strategies) · [Build and release a web app](https://docs.flutter.dev/deployment/web)（查阅：2026-08-30）

每个项目至少有三层测试：

1. 单元测试：URL 编码、参数解析、非法值、默认值、locale 无关的稳定 ID；
2. Widget / integration test：页面跳转、返回结果、redirect、错误页、键盘主流程、响应式与可访问性；
3. release Web 验收：使用项目自己的 `--base-href`，从实际子路径打开 hash 深链，再测试刷新、Back、Forward 与复制到新标签。

## 11. 固定的七章顺序与边界

章节顺序来自仓库 Issue #1，不调整：

### 05-01 Navigator 与页面栈

讲 `Route` 栈、`push<T>` / `pop<T>`、返回结果、`context.mounted`、dialog、嵌套 Navigator、`PopScope`，最后说明状态恢复边界。例子只使用 `Navigator + MaterialPageRoute`，不提前出现 `go_router`。

本章不展开自定义 Router、URL 策略、ShellRoute 或本地化。完成标准是能写一个带返回值的短流程，并正确处理取消与离开确认。

### 05-02 Router、URL 与 `go_router`

先用一张数据流图解释 Router / RouteInformation / Navigator 的关系，再配置 `GoRouter`，讲 `go` / `push`、path / query、redirect、`onExit`、ShellRoute 与错误页。手写 Router 只保留原理片段，不做完整应用。

本章使用极小的地点数据，不开始路线分享卡。完成标准是能解释 URL、页面栈与浏览器历史为何不是同一个结构。

### 05-03 深链接与路线分享卡

集中讲 URL 编码、非法 URL、稳定资源身份、可复制链接、hash / path 边界、子路径 base href，并在本章内完整讲完路线分享卡。项目不跨章拆解。

本章不引入响应式导航、国际化、数据库、网络或登录。完成标准是直达深链接、修改路线、复制并重新打开仍得到同一视图。

### 05-04 响应式与平台适应

讲 `LayoutBuilder` / `MediaQuery`、内容驱动断点、NavigationDrawer / NavigationRail、指针与键盘输入、Material / Cupertino 适应。例子使用独立的场馆列表壳，不引用场馆导览册源码。

本章不深入 Semantics、ARB 或完整项目。完成标准是在三种验收尺寸和 200% 文本下保留同一任务与路由。

### 05-05 可访问性作为功能

讲 Semantics、焦点顺序、Shortcuts / Actions、键盘闭环、200% 文本、对比度、错误识别和 `disableAnimations`。用小型独立验收场景展示，不提前解析统筹项目。

本章不把可访问性缩成“加 label”，也不新增状态管理框架。完成标准是仅用键盘完成主任务，并在语义、焦点、文本缩放和减少动画四项检查中通过。

### 05-06 国际化与本地化

讲 `flutter_localizations`、`gen_l10n`、ARB、placeholder、plural、`intl`、Locale、Directionality 与方向性布局。示例只做一个可切换中英文的地点摘要页。

本章不把翻译后的标题写入路由，不引入远程翻译平台。完成标准是切换语言后 path / query 不变，日期、数字和复数按 locale 显示。

### 05-07 统筹项目：场馆导览册

只在本章完整讲解场馆导览册，把前六章的路由、深链接、响应式、输入、可访问性与本地化整合起来。前面章节不分段预告或解析同一项目，避免阅读割裂。

完成标准是键盘完成地点查找，中英文切换后保持当前路由；全部项目级验收在本章收口。

## 12. 重点项目：路线分享卡

### 12.1 功能范围

路线分享卡是 05-03 的独立真实项目，使用项目内固定的场馆与路线数据：

- 主页列出三条风格不同的参观路线；
- 详情地址为 `/routes/:routeId`，`mode`、`start` 等可选视图放 query；
- 用户可修改路线偏好，URL 随有效选择更新；
- 一键复制当前完整链接，并提供复制成功的非颜色提示；
- 新标签打开链接后，仅凭 URL 与本地稳定数据恢复同一路线；
- 未匹配地址、未知路线、非法 mode、重复或越界 query 分别给出可理解结果；
- 支持浏览器 Back / Forward，刷新详情不回到首页；
- 视觉上使用路线票卡、站点序列和轻量自绘路径，不仿照 Flutter 官方示例。

### 12.2 明确不做

- 不接地图、定位、网络、登录、收藏或数据库；
- 不把完整路线对象放进 `extra`；
- 不使用 ShellRoute、国际化或跨项目共享业务 / UI 包；
- 不把 path 策略的 404 workaround 包装成正式方案。

### 12.3 可验证建议

1. `#/routes/museum-loop?mode=quiet` 可直达、刷新和复制；
2. 改成 `mode=fast` 后产生符合历史语义的新地址，Back 能回到上一偏好；
3. 中文或带空格的自定义起点通过 `Uri` 编码后可往返；
4. `mode=unknown` 给出修复建议，不崩溃；
5. `/routes/missing` 显示资源不存在，完全未匹配的路径显示通用错误页；
6. 新标签没有 `extra` 时仍恢复卡片；
7. release 构建使用 `/flutter-tutorial/previews/route-share-card/` base href。

## 13. 统筹项目：场馆导览册

### 13.1 功能范围

场馆导览册使用完全独立的本地数据和界面：

- 顶层有“地点”“路线”“关于”三个目的地，由 `ShellRoute` 保持应用外壳；
- 窄屏使用 NavigationDrawer，宽屏使用 NavigationRail，目的地和 URL 不变；
- 地点详情地址为 `/venues/:venueId`，楼层与当前标签使用 query；
- 搜索支持键盘聚焦、清空、无结果与错误提示；
- `/` 聚焦搜索，Escape 关闭临时层；快捷键只在合适焦点域生效；
- 自绘楼层示意提供语义摘要，具体地点由可聚焦列表操作；
- 支持中英文，切换后保留当前 path、query、选中地点与焦点上下文；
- 日期、开放时段摘要、数量和复数通过生成的本地化与 `intl` 显示；
- 200% 文本、RTL 测试壳和减少动画模式不丢任务；
- 视觉使用现代导览册、索引标签和建筑平面语言，不复刻官方 Gallery 或导航示例。

### 13.2 明确不做

- 不引入地图 SDK、室内定位、网络、数据库、账号或推送；
- 不使用 `StatefulShellRoute`，三个目的地不需要各自保存深层导航栈；
- 不声称只有中英文就完成全球化；RTL 只做布局健壮性测试；
- 不与路线分享卡共享业务模型、主题组件或路由包封装；
- 不跨 05-04、05-05、05-06 分段讲解本项目。

### 13.3 可验证建议

1. 只用键盘从首页聚焦搜索、输入关键词、进入地点详情并返回；
2. 中英文切换前后 `routerState.uri` 保持同一路径和 query；
3. 320×720、768×900、1440×900 下导航组件正确切换且无横向溢出；
4. 200% 文本下标题、搜索、列表、错误和 drawer / rail 仍可操作；
5. Semantics 检查地点项、选中状态、搜索结果数量、错误和自绘示意摘要；
6. `disableAnimations` 时路线与面板直接到终态；
7. 直接打开 `#/venues/atrium?floor=2`、刷新、Back / Forward 都保持正确；
8. release 构建使用 `/flutter-tutorial/previews/venue-guidebook/` base href。

## 14. 全部分项目验收矩阵

| 维度 | 自动检查 | 浏览器 / 人工检查 |
| --- | --- | --- |
| 导航 | path / query 解析、返回结果、redirect、错误分支 | Back、Forward、刷新、直接粘贴、新标签复制 |
| 尺寸 | 320×720、768×900、1440×900 widget tests | 三个尺寸下检查内容顺序、drawer / rail 与焦点 |
| 文本 | 200% 文本下无 overflow、核心控件可见 | 中文长标题、英文长词、dialog 与错误页 |
| 键盘 | Tab、Shift+Tab、Enter、Space、Escape、项目快捷键 | 从头到尾不碰鼠标完成主任务 |
| 语义 | 关键节点 label、state、action 与 live region | 浏览器语义树，必要时补 TalkBack / VoiceOver |
| 颜色 | 关键文本对比度静态检查 | hover、focus、error、disabled 各状态不只靠颜色 |
| 动画 | `disableAnimations` 下零时长或静态终态 | 减少动画时无装饰性移动，状态反馈仍清楚 |
| 本地化 | zh / en 文案、placeholder、plural、格式化 | 切换 locale 后 URL 与任务不丢，RTL 测试壳不破版 |
| 发布 | `flutter build web --release --base-href ...` | 从实际子路径打开 hash 深链并硬刷新 |

所有项目都必须通过 Web 平台测试并达到预期效果。Widget 测试通过不代替 release Web 子路径验收；release build 成功也不代替真实浏览器的历史、刷新、键盘和语义检查。

## 15. 写作时必须避免的误讲

| 不准确说法 | 应改为 |
| --- | --- |
| “`pop` 就是返回上一页” | `pop<T>` 完成当前 Route，也可把结果交给 `push<T>` 返回的 Future。 |
| “`barrierDismissible: false` 就禁止离开 dialog” | 它只控制点击遮罩，系统返回与路由恢复另有边界。 |
| “在 `onPopInvokedWithResult` 返回 false” | 该回调是事后通知；命令式栈提前设 `canPop`，GoRoute 用 `onExit`。 |
| “状态恢复会保存整个应用” | 只恢复已注册且可序列化的 navigation / restoration 状态。 |
| “Router 取代 Navigator” | Router 管平台路由信息与配置，Navigator 展示 Page / Route。 |
| “浏览器 Back 就是 `Navigator.pop`” | 一个遍历访问历史，一个操作当前路由栈，二者可能重新组合。 |
| “`context.go` 等于 replace 当前历史” | `go` 按 URL 重组页面栈；浏览器条目还受 Router 的 URI 报告语义影响。 |
| “`extra` 可以做可分享页面状态” | `extra` 不在 URL 中，新标签和刷新不能把它当事实来源。 |
| “URL 能 parse 就合法” | 还要验证路由匹配、类型、范围、枚举和资源存在性。 |
| “Path URL 比 Hash 专业，直接打开即可” | Path 需要服务器 fallback；GitHub Pages 首版按 ADR 固定 hash。 |
| “600px 以下是手机布局” | 断点是内容开始拥挤的宽度，不是设备分类。 |
| “横屏就用桌面布局” | 应看实际窗口与局部约束。 |
| “Hover 里有按钮就够了” | Hover 只能增强，触屏和键盘必须有等价入口。 |
| “所有 iOS 页面都换成 Cupertino” | 只对有明确平台惯例的组件和行为做适应。 |
| “加几个 Semantics label 就完成无障碍” | 还要处理焦点、键盘、缩放、对比度、错误和减少动画。 |
| “颜色变红已经提示错误” | 错误需有文本识别、对应字段和可执行修复建议。 |
| “限制 text scale 可以防止溢出” | 应让布局容纳 200% 文本，不全局压低用户设置。 |
| “`disableAnimations` 代表所有平台的全部动画偏好” | 它是 Flutter 暴露的重要信号，但底层平台来源并不完全一致。 |
| “中文一个、英文多个，用 `count == 1` 就够了” | 使用 ICU plural，由 locale 的复数规则选择分支。 |
| “翻译标题也应该翻译 URL” | path 使用稳定 ID，语言变化不改变资源身份。 |
| “RTL 就把所有东西水平翻转” | 使用 Directional 几何；图标和图形是否镜像按语义决定。 |
| “本地 `flutter run` 刷新成功，Pages 也会成功” | 开发服务器有 fallback；Pages 必须按实际 base href 与 hash 深链验收。 |

## 16. 正文参考资料清单

章节页尾只列实际使用的来源，不把本清单整段复制过去。

- [Flutter navigation and routing](https://docs.flutter.dev/ui/navigation)（查阅：2026-08-30）
- [Flutter deep linking](https://docs.flutter.dev/ui/navigation/deep-linking)（查阅：2026-08-30）
- [Flutter URL strategies](https://docs.flutter.dev/ui/navigation/url-strategies)（查阅：2026-08-30）
- [Navigator](https://api.flutter.dev/flutter/widgets/Navigator-class.html)（查阅：2026-08-30）
- [Navigator.push](https://api.flutter.dev/flutter/widgets/Navigator/push.html)（查阅：2026-08-30）
- [Navigator.pop](https://api.flutter.dev/flutter/widgets/Navigator/pop.html)（查阅：2026-08-30）
- [Navigator.maybePop](https://api.flutter.dev/flutter/widgets/Navigator/maybePop.html)（查阅：2026-08-30）
- [Navigator.restorablePush](https://api.flutter.dev/flutter/widgets/Navigator/restorablePush.html)（查阅：2026-08-30）
- [RestorableRouteFuture](https://api.flutter.dev/flutter/widgets/RestorableRouteFuture-class.html)（查阅：2026-08-30）
- [PopScope](https://api.flutter.dev/flutter/widgets/PopScope-class.html)（查阅：2026-08-30）
- [showDialog](https://api.flutter.dev/flutter/material/showDialog.html)（查阅：2026-08-30）
- [Router](https://api.flutter.dev/flutter/widgets/Router-class.html)（查阅：2026-08-30）
- [RouteInformation](https://api.flutter.dev/flutter/widgets/RouteInformation-class.html)（查阅：2026-08-30）
- [RouteInformationParser](https://api.flutter.dev/flutter/widgets/RouteInformationParser-class.html)（查阅：2026-08-30）
- [RouterDelegate](https://api.flutter.dev/flutter/widgets/RouterDelegate-class.html)（查阅：2026-08-30）
- [PlatformRouteInformationProvider](https://api.flutter.dev/flutter/widgets/PlatformRouteInformationProvider-class.html)（查阅：2026-08-30）
- [go_router 18.0.0](https://pub.dev/packages/go_router/versions/18.0.0)（查阅：2026-08-30）
- [go_router configuration 18.0.0](https://github.com/flutter/packages/blob/go_router-v18.0.0/packages/go_router/doc/configuration.md)（查阅：2026-08-30）
- [go_router navigation 18.0.0](https://github.com/flutter/packages/blob/go_router-v18.0.0/packages/go_router/doc/navigation.md)（查阅：2026-08-30）
- [go_router redirection 18.0.0](https://github.com/flutter/packages/blob/go_router-v18.0.0/packages/go_router/doc/redirection.md)（查阅：2026-08-30）
- [go_router error handling 18.0.0](https://github.com/flutter/packages/blob/go_router-v18.0.0/packages/go_router/doc/error-handling.md)（查阅：2026-08-30）
- [ShellRoute 18.0.0](https://pub.dev/documentation/go_router/18.0.0/go_router/ShellRoute-class.html)（查阅：2026-08-30）
- [GoRoute.onExit 18.0.0](https://pub.dev/documentation/go_router/18.0.0/go_router/GoRoute/onExit.html)（查阅：2026-08-30）
- [Dart Uri](https://api.dart.dev/dart-core/Uri-class.html)（查阅：2026-08-30）
- [Adaptive and responsive design](https://docs.flutter.dev/ui/adaptive-responsive)（查阅：2026-08-30）
- [Adaptive input](https://docs.flutter.dev/ui/adaptive-responsive/input)（查阅：2026-08-30）
- [LayoutBuilder](https://api.flutter.dev/flutter/widgets/LayoutBuilder-class.html)（查阅：2026-08-30）
- [MediaQuery](https://api.flutter.dev/flutter/widgets/MediaQuery-class.html)（查阅：2026-08-30）
- [NavigationRail](https://api.flutter.dev/flutter/material/NavigationRail-class.html)（查阅：2026-08-30）
- [NavigationDrawer](https://api.flutter.dev/flutter/material/NavigationDrawer-class.html)（查阅：2026-08-30）
- [showAdaptiveDialog](https://api.flutter.dev/flutter/material/showAdaptiveDialog.html)（查阅：2026-08-30）
- [FocusableActionDetector](https://api.flutter.dev/flutter/widgets/FocusableActionDetector-class.html)（查阅：2026-08-30）
- [Flutter accessibility](https://docs.flutter.dev/ui/accessibility-and-internationalization/accessibility)（查阅：2026-08-30）
- [Semantics](https://api.flutter.dev/flutter/widgets/Semantics-class.html)（查阅：2026-08-30）
- [FocusTraversalGroup](https://api.flutter.dev/flutter/widgets/FocusTraversalGroup-class.html)（查阅：2026-08-30）
- [Shortcuts](https://api.flutter.dev/flutter/widgets/Shortcuts-class.html)（查阅：2026-08-30）
- [Actions](https://api.flutter.dev/flutter/widgets/Actions-class.html)（查阅：2026-08-30）
- [MediaQueryData.disableAnimations](https://api.flutter.dev/flutter/widgets/MediaQueryData/disableAnimations.html)（查阅：2026-08-30）
- [WCAG 2.2](https://www.w3.org/TR/WCAG22/)（查阅：2026-08-30）
- [Flutter internationalization](https://docs.flutter.dev/ui/accessibility-and-internationalization/internationalization)（查阅：2026-08-30）
- [intl 0.20.3](https://pub.dev/packages/intl/versions/0.20.3)（查阅：2026-08-30）
- [DateFormat 0.20.3](https://pub.dev/documentation/intl/0.20.3/intl/DateFormat-class.html)（查阅：2026-08-30）
- [NumberFormat 0.20.3](https://pub.dev/documentation/intl/0.20.3/intl/NumberFormat-class.html)（查阅：2026-08-30）
- [Locale.fromSubtags](https://api.flutter.dev/flutter/dart-ui/Locale/Locale.fromSubtags.html)（查阅：2026-08-30）
- [Directionality](https://api.flutter.dev/flutter/widgets/Directionality-class.html)（查阅：2026-08-30）
- [EdgeInsetsDirectional](https://api.flutter.dev/flutter/painting/EdgeInsetsDirectional-class.html)（查阅：2026-08-30）
- [Build and release a web app](https://docs.flutter.dev/deployment/web)（查阅：2026-08-30）
- [Flutter Web integration tests](https://docs.flutter.dev/testing/integration-tests#test-in-a-web-browser)（查阅：2026-08-30）
- [What is GitHub Pages](https://docs.github.com/en/pages/getting-started-with-github-pages/what-is-github-pages)（查阅：2026-08-30）
- [Custom GitHub Pages 404](https://docs.github.com/en/pages/getting-started-with-github-pages/creating-a-custom-404-page-for-your-github-pages-site)（查阅：2026-08-30）
