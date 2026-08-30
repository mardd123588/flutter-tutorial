---
title: Router、URL 与 go_router
description: 分清平台地址、路由配置与 Navigator 页面栈，并用 go_router 建立可解释的 URL。
part: 5
order: 2
kind: concept
requires:
  - navigation.navigator-stack
  - navigation.pop-scope
provides:
  - navigation.router
  - navigation.url-state
  - navigation.go-router
  - navigation.shell-route
status: verified
---

# Router、URL 与 go_router

命令式 Navigator 擅长“从这里打开下一页”。Web、桌面和移动端深链接还要求应用回答另一组问题：当前 URL 对应哪些页面？地址变化时怎样重组页面？浏览器 Back 到来时怎样更新配置？

Flutter 的 Router API 处理平台路由信息与应用配置，Navigator 继续负责展示 Page / Route。Router 没有取代 Navigator。

## 三层各管一件事

```text
浏览器地址栏 / 平台深链接
          ↕ RouteInformation（Uri）
        Router
          ↕ 应用路由配置
      Navigator
          ↕ Page / Route 栈
         界面
```

- `RouteInformationProvider` 接收和报告平台地址；
- `RouteInformationParser` 在 URI 与应用配置之间转换；
- `RouterDelegate` 根据配置构造 Navigator，并处理返回；
- `Navigator` 把最终 Page / Route 显示出来。

手写这组接口适合框架、特殊状态机或路由库作者。普通应用更适合用 `go_router` 把 path pattern、解析和页面构造集中起来。

## 最小 GoRouter

```dart
final router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const VenueListPage(),
    ),
    GoRoute(
      path: '/venues/:venueId',
      builder: (context, state) {
        final venueId = state.pathParameters['venueId']!;
        final floor = int.tryParse(
          state.uri.queryParameters['floor'] ?? '',
        );
        return VenuePage(venueId: venueId, floor: floor);
      },
    ),
  ],
  errorBuilder: (context, state) => ErrorPage(error: state.error),
);
```

应用入口改用 `MaterialApp.router(routerConfig: router)`。`state.pathParameters` 读取 path 占位符，`state.uri.queryParameters` 读取 query。新 API 直接使用 `RouteInformation.uri`；旧代码里的 `location` 已弃用。

## path、query 与 extra

用 URL 表达可恢复事实：

```text
/venues/materials-hall?floor=2&tag=quiet
         └──── path ────┘ └──── query ────┘
```

- path 表示资源身份和层级，例如 `venueId`；
- query 表示可选视图，例如楼层、筛选和排序；
- `extra` 是进程内附加数据，不在 URL 中。

`extra` 可以减少一次本地查找，但不能成为可分享页面的唯一数据源。刷新或把链接粘贴到新标签后，内存对象可能不存在。

## go 与 push 的语义不同

```dart
context.go('/venues/materials-hall?floor=2');
context.push('/venues/materials-hall?floor=2');
```

`go` 按新地址重新匹配并组织页面栈，适合顶层目的地和 canonical URL。`push` 在当前匹配之上增加页面，适合临时详情或仍希望保留当前页的流程。

它们都不等同于一句“替换浏览器历史”或“增加浏览器历史”。Web 的 Back / Forward 遍历访问历史，Navigator 操作当前页面栈；Router 会在两者之间报告和恢复 URI。最终行为还受路由结构与 Router 的 URI 报告语义影响，必须在浏览器中验收。

## redirect 只决定地址

```dart
final router = GoRouter(
  redirect: (context, state) {
    if (state.uri.path == '/venues/') return '/venues';
    return null;
  },
  routes: routes,
);
```

顶层 redirect 每次导航前执行，路由级 redirect 在对应路由即将显示时执行。返回 `null` 表示不跳转。redirect 可以异步，但仍应只做地址决策；不要在里面弹离开确认 dialog。

重定向要避免循环。登录回跳一类场景还要用 `Uri` 编码原始目标。`initialLocation` 只在平台没有提供深链接时决定起点，不应覆盖用户打开的有效 URL。

## onExit 处理离开边界

`GoRoute.onExit` 在路由将要离开时返回 `bool`：

```dart
GoRoute(
  path: '/draft',
  builder: (context, state) => const DraftPage(),
  onExit: (context, state) async {
    return await showDialog<bool>(
          context: context,
          builder: buildLeaveDialog,
        ) ??
        false;
  },
)
```

返回 `false` 取消这次离开。命令式 Navigator 页面可用上一章的 `PopScope`；go_router 路由则优先在 `onExit` 表达路由级合同。

## ShellRoute 保留共同外壳

三个顶层页面共用导航时，可以让 `ShellRoute` 创建内层 Navigator：

```dart
ShellRoute(
  builder: (context, state, child) {
    return AppShell(uri: state.uri, child: child);
  },
  routes: [
    GoRoute(path: '/venues', builder: buildVenues),
    GoRoute(path: '/routes', builder: buildRoutes),
    GoRoute(path: '/about', builder: buildAbout),
  ],
)
```

`child` 是内层 Navigator 当前匹配的内容。普通 `ShellRoute` 不会自动为每个目的地保存一套独立深层栈。确实需要各标签独立 Navigator 与状态恢复时才考虑 `StatefulShellRoute`。

某个详情页要覆盖整个外壳，可为它指定根 `parentNavigatorKey`。这会改变页面属于哪一层 Navigator，要同时检查返回键、dialog 和转场。

## 路由错误与业务错误分开

完全没有 route pattern 能匹配时，go_router 产生 `GoException`，可用 `errorBuilder`、`errorPageBuilder` 或 `onException` 处理，三者最多选择一种。

`/venues/missing` 可能已经匹配 `/venues/:venueId`，只是数据里没有这个 ID；`floor=two` 也只是参数业务非法。这两类不是框架匹配错误，页面构造边界必须自行验证并给出修复动作。

配置断言和 `GoError` 表示代码错误，不要把堆栈包装成用户 404。

## 可验证任务

用三条固定地点数据完成一个最小路由壳：

- `/venues` 显示列表；
- `/venues/:venueId?floor=2` 显示详情；
- `/` redirect 到 `/venues`；
- `/venues/missing` 显示“地点不存在”；
- `/anything-else` 进入通用错误页；
- `ShellRoute` 在地点、路线、关于页保留同一导航。

测试同时断言 Router 当前 `uri` 和可见页面。只断言某段文字出现，无法证明 URL 已正确更新。

## 常见误区

- 把 Router 说成 Navigator 的替代品。
- 把翻译后的地点标题放进 path，导致换语言就换资源地址。
- 用 `extra` 保存刷新后仍必须存在的数据。
- 在 redirect 里弹确认框或做页面副作用。
- 把未知资源、非法 query 与完全未匹配地址显示成同一种错误。
- 为三个简单目的地直接使用 `StatefulShellRoute`。

## 复习线索

- Router 在平台 URI 与应用配置之间协调，Navigator 展示最终页面栈。
- path 保存稳定身份，query 保存可选视图，`extra` 只能是可缺失优化。
- `go` 重组匹配，`push` 增加页面；浏览器历史仍需实际验证。
- `ShellRoute` 提供共同外壳，不等于多分支独立栈。

## 参考资料

- [Flutter navigation and routing](https://docs.flutter.dev/ui/navigation)（查阅：2026-08-30）
- [Router API](https://api.flutter.dev/flutter/widgets/Router-class.html)（查阅：2026-08-30）
- [RouteInformation API](https://api.flutter.dev/flutter/widgets/RouteInformation-class.html)（查阅：2026-08-30）
- [go_router 18.0.0 configuration](https://github.com/flutter/packages/blob/go_router-v18.0.0/packages/go_router/doc/configuration.md)（查阅：2026-08-30）
- [go_router 18.0.0 navigation](https://github.com/flutter/packages/blob/go_router-v18.0.0/packages/go_router/doc/navigation.md)（查阅：2026-08-30）
- [go_router 18.0.0 redirection](https://github.com/flutter/packages/blob/go_router-v18.0.0/packages/go_router/doc/redirection.md)（查阅：2026-08-30）
- [ShellRoute 18.0.0 API](https://pub.dev/documentation/go_router/18.0.0/go_router/ShellRoute-class.html)（查阅：2026-08-30）
- [GoRoute.onExit 18.0.0 API](https://pub.dev/documentation/go_router/18.0.0/go_router/GoRoute/onExit.html)（查阅：2026-08-30）
