---
title: Flutter Web release 构建与子路径
description: 构建可从真实子路径加载的 Flutter Web release 产物，处理 base href、本地 CanvasKit、hash URL、Wasm 与 Service Worker 边界。
part: 8
order: 3
kind: concept
requires:
  - storage.web-boundary
  - performance.frame-budget
provides:
  - web.release-build
  - web.base-href
  - web.wasm-boundary
status: verified
---

# Flutter Web release 构建与子路径

`flutter build web` 只负责生成静态产物。用户能否打开页面，还取决于部署子路径、资源 URL、MIME、浏览器缓存、Worker 和路由策略。Web release 验收必须通过 HTTP server 从最终子路径加载，不能双击 `index.html`，也不能只看构建命令退出码。

## 独立构建命令写出部署合同

本仓库为每个项目生成独立 Web release 产物：

```powershell
flutter build web --release `
  --pwa-strategy=none `
  --no-web-resources-cdn `
  --base-href /flutter-tutorial/previews/neighborhood-exchange/ `
  --dart-define=APP_ENV=demo `
  --dart-define=CONTENT_VERSION=<commit-sha>
```

三个参数需要分别理解：

| 参数 | 当前仓库用途 |
| --- | --- |
| `--base-href` | 让入口和相对资源从项目预览子路径解析 |
| `--no-web-resources-cdn` | 把 CanvasKit 等 Web engine 资源放进本地产物 |
| `--pwa-strategy=none` | 在 Flutter 3.47.0 中关闭默认 offline-first Service Worker |

`--pwa-strategy` 已被 Flutter 标为弃用。这里记录的是 3.47.0 的过渡做法，升级 SDK 时要重新检查工具行为，不能把它当作长期通用命令。

## `<base>` 决定相对 URL 从哪里解析

Flutter Web 模板包含：

```html
<base href="$FLUTTER_BASE_HREF">
```

构建工具把占位符替换成 `--base-href`。浏览器随后用 `<base>` 解析脚本、资源和相对导航 URL。值必须以 `/` 开头和结尾：

```html
<base href="/flutter-tutorial/previews/neighborhood-exchange/">
```

错误地写成 `/` 时，浏览器会向站点根请求 `flutter_bootstrap.js`；写成别的项目 slug 时，可能加载到错误版本的同名文件。开发服务器在 `/` 能运行，不能证明 GitHub Pages 子路径正确。

构建脚本会读取 `build/web/index.html`，精确检查预期 `<base>`。这比只检查文件存在多证明了一层部署事实。

## Web engine 资源随 artifact 自托管

Flutter 3.47.0 默认可能从 Google 托管位置加载 CanvasKit。本站不加载第三方字体、追踪或运行时 engine CDN，因此 release 显式使用 `--no-web-resources-cdn`。

工具在构建配置中写入：

```json
{"useLocalCanvasKit": true}
```

发布检查同时验证：

- `flutter_bootstrap.js` 包含本地 CanvasKit 配置；
- 断开外部网络后主流程仍能启动；
- 浏览器没有向未允许的第三方域名发送请求。

Loader 源码里可能保留未启用 CDN 分支字符串。静态搜索到 `gstatic.com` 只能说明代码里有这个分支，不能证明运行时发出了请求；要结合启用配置和浏览器网络记录判断。

## Hash URL 适合没有 rewrite 的 Pages

浏览器发请求时不会把 `#` 后的 fragment 交给服务器：

```text
HTTP 请求：/flutter-tutorial/previews/neighborhood-exchange/
客户端路由：#/listings/r-001
```

所以刷新详情页仍请求真实存在的预览目录，再由 go_router 恢复详情。Path URL `/listings/r-001` 刷新时要求服务器把未知路径 rewrite 到 `index.html`；GitHub Pages 没有为本项目配置这项能力。

Hash URL 解决服务器入口问题，应用仍要验证 query、非法 ID、Back / Forward 和本地记录边界。

## Wasm 要连同运行条件测量

`flutter build web --wasm` 会生成 Wasm 构建并保留 JavaScript fallback。它不是“再加一个参数就更快”：

- 依赖包的 Web 代码必须通过 Wasm compatibility 检查；
- Skwasm 多线程渲染依赖浏览器能力和 cross-origin isolation；
- 服务器通常要正确发送 COOP / COEP 响应头；
- 性能结论要使用相同浏览器、数据和 workload 比较。

Flutter 3.47.0 的普通 JavaScript build 默认还会执行一次 Wasm dry run，用非致命警告报告不兼容代码。Dry run 通过只说明兼容性检查没有发现问题；只有显式运行 `flutter build web --wasm` 才会生成 Wasm 发布产物。

GitHub Pages 的首版基线继续使用普通 JavaScript release。只有目标服务器、响应头、依赖兼容、fallback 和固定 workload 都有证据时，才为单个项目评估 Wasm。

## HTTP cache 与 Service Worker 分开看

HTTP cache 按 URL、缓存响应头和验证器复用资源。Service Worker 可以拦截 `fetch`，维护另一套缓存与更新生命周期。浏览器“第二次打开更快”不能证明应用已经是 PWA。

本教程首版不做安装、离线启动、后台同步、推送或 Web app manifest 体验。Flutter 3.47.0 使用 `--pwa-strategy=none` 后，构建脚本检查 `flutter_service_worker.js` 为 0 字节；还要在已有部署上确认旧 Worker 没有继续控制页面。

入口 HTML 与带内容 hash 的静态资源缓存策略也不同。入口需要及时指向新资源；内容 hash 文件可以长期复用。`release-manifest.json` 记录 commit，帮助确认页面和预览来自同一版本。

## Source map 是诊断材料

`--source-maps` 可以让浏览器把压缩后的 JavaScript / Wasm 位置映射回 Dart 源码。它不影响应用正常启动，也不能保护秘密。

公开 Pages 首版不上传 source map。需要诊断 release-only 问题时，在受限 CI job 生成，并作为短期失败 artifact 保存。客户端中不应出现的凭据，无论有没有 source map 都不该被构建进去。

## 可验证任务

构建邻里资源交换站：

```powershell
pnpm release:build:exchange
```

检查 `build/web/index.html`、`flutter_bootstrap.js`、`flutter_service_worker.js`、`canvaskit/`、`sqlite3.wasm` 和 `drift_worker.js`。随后从 `/flutter-tutorial/previews/neighborhood-exchange/` 提供静态服务，验证：

1. 列表入口能打开；
2. `#/listings/r-001` 刷新后仍是同一详情；
3. Back / Forward 恢复页面；
4. 断开外网后 engine、Wasm 与 Worker 仍能加载；
5. 临时使用错误 base href 时，失败请求能在网络面板中定位。

恢复正确构建后再结束，不要把故意损坏的产物带进 Pages staging。

## 复习线索

- `flutter build web` 生成产物，HTTP 子路径验收证明部署合同。
- `<base>` 影响脚本、资源和相对 URL 的解析位置。
- Engine 自托管要同时看构建配置和真实网络请求。
- Hash fragment 不进入 HTTP 路径，适合没有 rewrite 的静态托管。
- Wasm 取决于依赖、浏览器、响应头、fallback 和 workload。
- HTTP cache、Service Worker 和 PWA 是三层不同问题。

## 参考资料

- [Build and release a web app](https://docs.flutter.dev/deployment/web)（查阅：2026-08-31）
- [Flutter URL strategies](https://docs.flutter.dev/ui/navigation/url-strategies)（查阅：2026-08-31）
- [Flutter WebAssembly](https://docs.flutter.dev/platform-integration/web/wasm)（查阅：2026-08-31）
- [Flutter Web renderers](https://docs.flutter.dev/platform-integration/web/renderers)（查阅：2026-08-31）
- [MDN: `<base>`](https://developer.mozilla.org/en-US/docs/Web/HTML/Reference/Elements/base)（查阅：2026-08-31）
- [MDN: HTTP caching](https://developer.mozilla.org/en-US/docs/Web/HTTP/Guides/Caching)（查阅：2026-08-31）
- [Service Workers Level 1](https://www.w3.org/TR/service-workers/)（查阅：2026-08-31）
- [Flutter issue #156910: remove default service worker](https://github.com/flutter/flutter/issues/156910)（查阅：2026-08-31）
