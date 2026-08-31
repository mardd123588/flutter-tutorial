# 全教程外部来源与版本事实审计（第二轮）

> 审计日期：2026-09-01
> 范围：`site/**/*.md`、`docs/**/*.md`、根 lockfile、CI workflow 与 Flutter Web 发布脚本。
> 来源优先级：Flutter / Dart 官方源码与文档、pub.dev、包的官方仓库、Node.js、pnpm、VitePress、Vue 与 GitHub 官方资料。

## 检查口径

- 教程站包含 274 个唯一 HTTP(S) URL；全仓库 Markdown 包含 657 个唯一 URL 字面量。
- 先并发请求链接，再对非 2xx 结果改用 GET 复核。限流、站点防爬、网络超时和 `HEAD` 不支持不直接记为死链。
- `example.com`、`https://<user>.github.io/<repo>/`、CanvasKit CDN 前缀和未部署的 Pages 预览属于示例值，不按参考资料死链处理。
- 版本事实同时比对 `pubspec.lock`、`pnpm-lock.yaml`、`package.json`、GitHub Actions 与本机 Flutter 3.47.0 工具源码；“当前最新版”另查 2026-09-01 的 registry 元数据。

## 确定问题

### 1. 三条正文参考链接已经失效

| 位置 | 现状 | 建议替换 |
| --- | --- | --- |
| `site/guide/part-08/05-platform-plugins-permissions-channels.md` | Apple 旧路径返回 404 | 改为 [Requesting authorization to capture and save media](https://developer.apple.com/documentation/avfoundation/requesting-authorization-to-capture-and-save-media) |
| `site/guide/part-08/06-release-quality-privacy-upgrades.md` | GitHub Docs 旧信息架构路径返回 404 | 改为 [Dependency review](https://docs.github.com/en/code-security/concepts/supply-chain-security/dependency-review)，并同步改链接标题 |
| `site/guide/part-06/06-riverpod-testing.md` | `Override-class.html` 返回 404；Riverpod 3.4.2 的 `Override` 是内部实现，并未作为 `riverpod` 库的公开 API 生成文档 | 改为 [Provider overrides](https://riverpod.dev/docs/concepts2/overrides)，标题不要再写“3.4.2 API” |

Riverpod 的公开测试入口仍是 `ProviderContainer` 与各 provider 的 `overrideWith...` 方法；正文讲法不必改，只需换参考入口。[Riverpod testing](https://riverpod.dev/docs/how_to/testing) · [Riverpod 3.4.2 源码](https://github.com/rrousselGit/riverpod/blob/3104958b1364b041be6c1d637880d5d3756ddceb/packages/riverpod/lib/src/core/override.dart)

### 2. 项目源码链接目前对读者不可用

教程有 13 条 `github.com/mardd123588/flutter-tutorial/tree/main/examples/...` 项目源码链接，另有 1 条 issue 链接。它们的本地路径都存在，但远程仓库当前为 private 且没有可读取的 `main` 内容，匿名请求均返回 404。

这不是章节路径拼错，属于发布前置条件：首次公开发布前，需要把目标提交推到 `main`，确认仓库可由匿名用户读取，再逐条验收 13 个源码目录和 issue。若仓库继续保持 private，公开教程不应保留这些“项目源码”链接。

### 3. 早期生态调查使用了会漂移的“latest”来源

`docs/research/ecosystem-stack-survey.md` 记录的是 2026-08-29 的调查快照，其中 `freezed 4.0.0` 当时被写作“当前稳定版”，链接却指向浮动的 `https://pub.dev/api/packages/freezed`。2026-09-01 该端点已经返回 `freezed 4.0.1`，读者会看到来源与正文数字不一致。[freezed 当前元数据](https://pub.dev/api/packages/freezed) · [freezed 4.0.0 快照](https://pub.dev/api/packages/freezed/versions/4.0.0)

建议把表头和相关句子明确为“2026-08-29 查阅版本”，并把涉及精确版本的 `freezed` 来源固定到 4.0.0。该包没有进入教程主依赖，不能据此升级根 lockfile。

## 版本核对结果

根 `pubspec.lock`、`site/reference/versions.md` 与 pub.dev 当前稳定元数据一致：

| 依赖 | 锁定版本 | 官方来源 |
| --- | ---: | --- |
| `go_router` | 18.0.0 | [pub.dev](https://pub.dev/packages/go_router/versions/18.0.0) |
| `flutter_riverpod` | 3.4.2 | [pub.dev](https://pub.dev/packages/flutter_riverpod/versions/3.4.2) |
| `riverpod_annotation` | 4.0.6 | [pub.dev](https://pub.dev/packages/riverpod_annotation/versions/4.0.6) |
| `riverpod_generator` | 4.0.8 | [pub.dev](https://pub.dev/packages/riverpod_generator/versions/4.0.8) |
| `drift` / `drift_flutter` | 2.34.3 / 0.3.1 | [drift](https://pub.dev/packages/drift/versions/2.34.3) · [drift_flutter](https://pub.dev/packages/drift_flutter/versions/0.3.1) |
| `http` | 1.6.0 | [pub.dev](https://pub.dev/packages/http/versions/1.6.0) |
| `json_annotation` / `json_serializable` | 4.12.0 / 6.14.1 | [json_annotation](https://pub.dev/packages/json_annotation/versions/4.12.0) · [json_serializable](https://pub.dev/packages/json_serializable/versions/6.14.1) |
| `shared_preferences` | 2.5.5 | [pub.dev](https://pub.dev/packages/shared_preferences/versions/2.5.5) |
| `intl` / `characters` | 0.20.3 / 1.4.1 | [intl](https://pub.dev/packages/intl/versions/0.20.3) · [characters](https://pub.dev/packages/characters/versions/1.4.1) |

工具链也一致：

- 本机 `flutter --version` 为 Flutter 3.47.0、Dart 3.13.0；两份 workflow 均固定 Flutter 3.47.0。[Flutter 3.47.0](https://github.com/flutter/flutter/tree/3.47.0)
- CI 使用 Node.js 22 主版本，`package.json` 接受 `>=22 <27`。正文已经说明这不是精确补丁锁定；Node 22 仍在官方 LTS 生命周期内。[Node.js releases](https://nodejs.org/en/about/previous-releases)
- `packageManager`、本机与教程版本表均为 pnpm 10.34.5；`pnpm-lock.yaml` 使用该工具可读的 lockfile 9 格式。[pnpm 10.34.5](https://github.com/pnpm/pnpm/releases/tag/v10.34.5)
- `package.json` 与 `pnpm-lock.yaml` 都锁定 VitePress 1.6.4、Vue 3.5.42。VitePress 2 仍是 alpha，教程继续使用 1.6.4 稳定线没有冲突。[VitePress 1.6.4](https://github.com/vuejs/vitepress/releases/tag/v1.6.4) · [Vue 3.5.42](https://github.com/vuejs/core/releases/tag/v3.5.42) · [VitePress releases](https://github.com/vuejs/vitepress/releases)

Flutter 3.47.0 的工具源码也支持正文使用的发布参数：`--web-define`、`--no-web-resources-cdn`、默认 Wasm dry run，以及隐藏且已弃用的 `--pwa-strategy`。`--pwa-strategy=none` 会生成 0 字节 `flutter_service_worker.js`；正文已经把它限定为 3.47.0 的过渡做法。[build_web.dart 3.47.0](https://github.com/flutter/flutter/blob/3.47.0/packages/flutter_tools/lib/src/commands/build_web.dart) · [compile.dart 3.47.0](https://github.com/flutter/flutter/blob/3.47.0/packages/flutter_tools/lib/src/web/compile.dart) · [Service Worker 生成器 3.47.0](https://github.com/flutter/flutter/blob/3.47.0/packages/flutter_tools/lib/src/web/file_generators/flutter_service_worker_js.dart)

## 易漂移但暂不必改的链接

- 教程正文有 123 处 `api.flutter.dev` / `api.dart.dev` 引用。它们当前可访问，也适合读者查 API；但页面会随 stable SDK 更新，不能作为历史源码快照。涉及 3.47.0 内部实现、弃用参数或精确行号的事实，应继续使用 Flutter 3.47.0 tag 或 commit 链接。
- 研究底稿有 61 处指向 GitHub `main` / `master` 的链接。用于项目主页、维护主体或持续更新文档时可以保留；用于精确版本行为时应换成 tag 或 commit。不要批量把所有主页链接固定到旧提交。
- Android permissions、ChromeDriver version selection 与 `flutter.dev/go/go-router-v18-breaking-changes` 在本次网络环境中超时，没有出现 404 或内容迁移证据。本轮不把它们判为死链；发布 CI 若增加自动外链检查，应允许重试并区分超时与确定的 4xx。

## 修正顺序

1. 替换 3 条确定失效的官方参考链接。
2. 把 `freezed 4.0.0` 的调查来源固定到版本快照，并把“当前稳定版”改成带日期的历史口径。
3. 首次公开发布后验收 13 个源码链接、issue 与 Pages 预览；仓库保持 private 时则删除公开读者无法访问的入口。
4. 保留版本表现有锁定值，不做依赖升级。
