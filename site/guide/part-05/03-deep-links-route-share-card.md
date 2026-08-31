---
title: 深链接与路线分享卡
description: 把稳定资源、可选视图和错误边界写进 URL，并完成可复制、可恢复的路线分享卡。
part: 5
order: 3
kind: focus-project
requires:
  - navigation.router
  - navigation.url-state
  - navigation.go-router
provides:
  - navigation.deep-link
  - navigation.url-validation
  - deployment.hash-url
  - project.route-share-card
project: route-share-card
status: verified
---

# 深链接与路线分享卡

深链接让应用从一个 URL 直接恢复到具体内容。能打开一个地址只是起点；可分享链接还要经得住刷新、新标签、非法参数、Back / Forward 和部署子路径。

路线分享卡建立在[页面栈](/guide/part-05/01-navigator-page-stack)和[Router、URL 与 go_router](/guide/part-05/02-router-url-go-router)之上。本章只新增可分享 URL 合同、参数校验与部署边界。

本章用“路线分享卡”完成这套合同。项目只有三条本地路线，不接地图、定位、网络、账号或数据库，问题集中在 URL 本身。

## 先定义 URL 合同

项目采用下面的地址：

```text
/routes/museum-loop?mode=quiet&start=北门%20服务台
        └ routeId ┘ └ mode ┘ └──── start ────┘
```

- `routeId` 是稳定资源身份；
- `mode` 是 `balanced | quiet | fast`；
- `start` 是可选起点，最多 24 个 Unicode 字符；
- 默认 mode 和默认起点不写入 canonical URL；
- 链接只凭 URL 与固定路线数据恢复，不读取 `extra`。

路线标题可以改文案，`museum-loop` 仍保持不变。稳定 ID 不等于永远不能迁移；若必须改，要同时设计旧地址 redirect 和废弃期。

## Uri 负责编码，不手拼字符串

中文、空格、`/` 和 `%` 都有 URI 语义。编码时交给 `Uri`：

<<< ../../../examples/focus/route_share_card/lib/src/route_url_codec.dart#route-url-codec{dart}

`Uri(path: ..., queryParameters: ...)` 会处理 query 编码。解析后再做领域验证：参数是否受支持、是否重复、枚举是否合法、字符串是否为空或过长、资源是否存在。

“能 parse”只说明文本符合 URI 语法，不代表它满足应用合同。

## 重复参数不能被悄悄覆盖

`uri.queryParameters` 每个 key 只给一个值，无法看出 `?mode=quiet&mode=fast`。项目先检查 `queryParametersAll`：

```dart
for (final entry in uri.queryParametersAll.entries) {
  if (entry.value.length != 1) {
    return InvalidRouteLink(
      RouteLinkIssue.duplicateParameter,
      parameter: entry.key,
    );
  }
}
```

默认值、忽略还是报错都可以成为产品决定，但必须明确。这里选择报错，因为两个互相冲突的模式没有可靠解释。

项目也拒绝未知 query。这样拼写错误 `?mdoe=quiet` 不会被当成默认模式悄悄打开。

## 错误类型对应修复动作

路线分享卡区分七类链接问题：

| 问题 | 示例 | 页面动作 |
| --- | --- | --- |
| 路径结构不匹配 | `/other/museum-loop` | 返回路线列表 |
| 路线不存在 | `/routes/missing` | 重新选择稳定路线 |
| 参数重复 | `mode=quiet&mode=fast` | 删除重复值 |
| 参数未知 | `view=map` | 删除未知参数 |
| mode 非法 | `mode=slow` | 改为三个允许值之一 |
| start 为空 | `start=` | 删除参数，使用默认入口 |
| start 过长 | 超过 24 字符 | 缩短名称 |

完全未匹配的 `/not-a-route` 由 `errorBuilder` 处理；已经匹配详情 pattern 的业务错误由 codec 返回。页面显示标题、原因、原始地址摘要和安全返回动作，不把堆栈交给用户。

## 路由只消费解析结果

GoRouter 配置没有把验证散在 Widget 中：

<<< ../../../examples/focus/route_share_card/lib/src/route_share_card_app.dart#route-share-router{dart}

`ValidRouteLink` 才能构造详情页，`InvalidRouteLink` 进入领域错误页。`ValueKey(state.uri.toString())` 让 query 变化时详情页用新参数重建；本地输入 controller 也随 canonical URI 保持一致。

用户修改 mode 或提交起点后，项目调用 codec 重新编码，再 `context.go(uri.toString())`。页面和地址共用同一个 `RoutePreference`，不会出现控件显示 quiet、URL 仍是 fast 的双重事实。

## 复制完整 URL

项目使用 hash 路由，分享地址由部署 origin、base path 和当前内部 URI 组成：

```dart
String defaultShareUrlBuilder(Uri location) {
  return Uri.base.replace(fragment: location.toString()).toString();
}
```

复制成功后，按钮旁保留文字状态，并用 `Semantics(liveRegion: true)` 宣布。仅弹一个短暂 SnackBar，键盘或屏幕阅读器用户可能来不及确认，也无法再次查看。

剪贴板通过接口注入，Widget 测试使用内存实现。测试不用真的读写系统剪贴板。

## Hash 与 Path 解决不同部署问题

Flutter Web 默认使用 hash URL：

```text
https://example.com/app/#/routes/museum-loop?mode=quiet
```

fragment 不随 HTTP 请求发送到服务器。刷新时服务器仍请求 `/app/` 的 `index.html`，内部路由交给 Flutter。

Path 策略会得到 `/app/routes/museum-loop`，地址更接近普通网站，但服务器必须把未知应用路径 rewrite 到 `index.html`。`flutter run` 的开发服务器已提供 fallback，不能证明生产托管也支持。

GitHub Pages 没有项目级任意路径 rewrite。本仓库按 ADR-0010 使用 hash，不采用复制 `404.html` 的 workaround。

## base href 必须包含完整子路径

VitePress 部署在 `/flutter-tutorial/`，路线分享卡再放进预览子目录。构建命令是：

```powershell
flutter build web --release --base-href /flutter-tutorial/previews/route-share-card/
```

`base href` 负责脚本、CanvasKit 和其他静态资源相对路径；hash 内的 `/routes/...` 由应用 Router 处理。两者不能混成一个 path。

## 项目结构与交互

路线目录显示三张编号清单。详情页包含路线摘要、真实站点列表、mode 选择、起点输入和复制动作。自绘路线只帮助扫视，站点名称仍由普通 Widget 和 Semantics 提供。

页面在 940px 以上使用双栏，窄屏先显示偏好再显示结果；320×720 与 200% 文本下允许控件换行。路线切换使用 280ms `AnimatedSwitcher`，`disableAnimations` 为 true 时改成 `Duration.zero`。

这部分是项目的辅助质量边界，响应式与可访问性会在后续章节系统讲解。

## 测试 URL，而不只测页面文字

Unicode 与空格必须 round-trip：

<<< ../../../examples/focus/route_share_card/test/route_url_codec_test.dart#unicode-url-round-trip{dart}

非法地址按错误类别逐项测试：

<<< ../../../examples/focus/route_share_card/test/route_url_codec_test.dart#illegal-url-classes{dart}

Widget 测试还会断言：

- 点击路线后 Router URI 变为 `/routes/museum-loop`；
- mode 变化写入 query；
- 直接以深链接启动时不依赖 `extra`；
- 复制的是完整部署 URL；
- 320×720、200% 文本和减少动画边界可用。

Chrome 集成测试覆盖打开路线与修改偏好。地址栏粘贴、硬刷新、Back、Forward 和新标签复制仍需针对 Web release 产物的真实 HTTP 子路径补验；Widget 测试不能证明托管合同。

## 运行与验收

项目路径：`examples/focus/route_share_card`。

```powershell
flutter analyze examples/focus/route_share_card
flutter test examples/focus/route_share_card/test
cd examples/focus/route_share_card
flutter run -d chrome
```

Chrome 集成测试需要 ChromeDriver 监听 4444 端口：

```powershell
flutter drive -d web-server --browser-name=chrome --driver=test_driver/integration_test.dart --target=integration_test/route_share_card_test.dart
```

Web release 构建后，从下面的深链接开始检查：

```text
/flutter-tutorial/previews/route-share-card/#/routes/museum-loop?mode=quiet
```

依次刷新、切到 fast、按 Back、按 Forward、复制到新标签，再手工输入非法 mode。每一步都核对地址和可见状态。

## 项目完成检查

- [ ] path 只保存稳定路线 ID，query 只保存可选偏好。
- [ ] 默认值从 canonical URL 省略，但解析时能恢复。
- [ ] Unicode、空格、重复参数、未知参数和长度边界都有测试。
- [ ] 未知路线与完全未匹配地址显示不同原因和修复动作。
- [ ] 新标签只凭 URL 和本地数据恢复，不依赖 `extra`。
- [ ] 复制成功有持续可见文字和 live region。
- [ ] Chrome 中通过直达、刷新、Back、Forward 与实际子路径检查。

## 复习线索

- URI 语法解析之后还有参数与资源的领域验证。
- `queryParametersAll` 才能识别重复 query。
- hash 让服务器忽略客户端路由；`base href` 决定静态资源根路径。
- 可分享链接必须能在新浏览器上下文里独立恢复。
- [项目源码](https://github.com/mardd123588/flutter-tutorial/tree/main/examples/focus/route_share_card)

## 参考资料

- [Flutter deep linking](https://docs.flutter.dev/ui/navigation/deep-linking)（查阅：2026-08-30）
- [Flutter URL strategies](https://docs.flutter.dev/ui/navigation/url-strategies)（查阅：2026-08-30）
- [Dart Uri API](https://api.dart.dev/dart-core/Uri-class.html)（查阅：2026-08-30）
- [go_router 18.0.0 navigation](https://github.com/flutter/packages/blob/go_router-v18.0.0/packages/go_router/doc/navigation.md)（查阅：2026-08-30）
- [Build and release a Flutter Web app](https://docs.flutter.dev/deployment/web)（查阅：2026-08-30）
- [What is GitHub Pages](https://docs.github.com/en/pages/getting-started-with-github-pages/what-is-github-pages)（查阅：2026-08-30）
- [GitHub Pages custom 404](https://docs.github.com/en/pages/getting-started-with-github-pages/creating-a-custom-404-page-for-your-github-pages-site)（查阅：2026-08-30）
