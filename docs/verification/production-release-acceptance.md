# 首次 production 发布验收

> 验收日期：2026-09-01
> 发布提交：`6dd4fb2049a3f34041d538f2c0c422f505dd4771`
> 站点：<https://mardd123588.github.io/flutter-tutorial/>

## 结论

首次 production 发布通过。远程仓库已公开，`main`、GitHub Actions Pages、`github-pages` environment、验证 workflow、发布 workflow 和线上产物都指向同一提交。教程入口、13 个 Flutter Web 预览、Drift 资源、hash 深链接和浏览器历史已在线验收。

## 远程配置

| 检查项 | 结果 |
| --- | --- |
| 仓库 | `mardd123588/flutter-tutorial` 为 public，默认分支为 `main` |
| Pages | `build_type: workflow`，HTTPS 强制开启，`has_pages: true` |
| production URL | `https://mardd123588.github.io/flutter-tutorial/` |
| environment | `github-pages`，只允许配置的分支策略部署 |
| 发布 SHA | `6dd4fb2049a3f34041d538f2c0c422f505dd4771` |

## 首轮 CI 暴露的问题

首次 push 对提交 `9f5657b` 运行 [Verify #33457778735](https://github.com/mardd123588/flutter-tutorial/actions/runs/33457778735)。10 个项目通过，`ticket-layout-studio`、`scroll-timeline` 和 `venue-guidebook` 的 5 张 golden 在 Ubuntu 上失败，像素差异为 `0.43%`、`1.58%`、`3.17%`、`0.65%`、`0.96%`。对应功能测试全部通过。

这些基准图原先在 Windows 生成。提交 `6dd4fb2` 保留 Windows 基准，并补充 Flutter 3.47.0 在 Linux 生成的基准；测试按运行平台选择文件。三组测试随后在 Windows 与 WSL Linux 都通过。CI 也开始上传项目的 `test/failures`，后续 golden 失败会保存 expected、actual 和 diff。

## GitHub Actions 结果

| 对象 | 标识 | 结果 |
| --- | --- | --- |
| Verify | [run 33458966163](https://github.com/mardd123588/flutter-tutorial/actions/runs/33458966163) | `scope`、13 个项目和 `complete` 共 15/15 success |
| Publish Pages | [run 33459221627](https://github.com/mardd123588/flutter-tutorial/actions/runs/33459221627) | `build` 与 `deploy` success |
| Pages artifact | `9782756821` | 名称 `github-pages`，186,685,589 bytes，未过期 |
| deployment | `6192881687` | environment `github-pages`，SHA 与发布提交一致 |
| deployment status | `17598216721` | `success`，environment URL 指向 production 站点 |

Pages build 完成 VitePress、13 个 Flutter release、artifact 合并和 staging smoke 后才进入 deploy。上传的 artifact 与 Verify 通过的提交一致。

## 线上 HTTP 验收

自动检查共发出 48 个 production 请求，覆盖：

- 教程入口、项目索引和 `release-manifest.json`；
- 13 个预览入口、`flutter_bootstrap.js` 和 `flutter_service_worker.js`；
- 3 个 Drift 项目的 `sqlite3.wasm` 与 `drift_worker.js`。

`release-manifest.json` 恰好列出 13 个预览，`contentVersion` 等于发布 SHA。每个 bootstrap 都包含 `useLocalCanvasKit: true`；13 个 `flutter_service_worker.js` 都是 0 bytes。Wasm 返回 `application/wasm`，Worker 返回 `application/javascript`。匿名请求仓库主页返回 200。

抽查响应头如下：

| 资源 | 状态 | MIME | Cache-Control |
| --- | --- | --- | --- |
| 站点入口 | 200 | `text/html; charset=utf-8` | `max-age=600` |
| release manifest | 200 | `application/json; charset=utf-8` | `max-age=600` |
| 空 Service Worker | 200 | `application/javascript; charset=utf-8` | `max-age=600` |
| `sqlite3.wasm` | 200 | `application/wasm` | `max-age=600` |
| `drift_worker.js` | 200 | `application/javascript; charset=utf-8` | `max-age=600` |

这是首次部署，没有旧 production Service Worker 可供注销。当前产物使用 0-byte Service Worker；缓存更新与旧 Worker 清理仍要在下一次 production 更新时再次检查。

## 真实浏览器验收

Codex 内置 Chromium 直接访问 production URL，得到以下结果：

- 教程首页标题、主标题和四个顶层导航正常；进入项目页后，Back 与 Forward 返回正确 URL；
- `neighborhood-exchange/#/listings/r-001` 可直达并在 reload 后保留，Back 返回该详情，Forward 回到应用规范化后的 `#/exchange`；
- 320×720、768×900、1440×900 三档视口都没有横向溢出；
- VitePress 首页在 320×720 下的文档宽度不超过浏览器 viewport；
- 页面和 Flutter 预览均未记录 console error 或 warning。

## 后续事项

本次 run 有一条非阻塞注记：部分固定 SHA 的 GitHub Action 仍声明 Node.js 20，GitHub runner 已强制改用 Node.js 24。当前 workflow 通过，但后续应更新这些 action 的固定 SHA，避免兼容窗口关闭后才处理。

以后每次 production 发布仍要重新保存 Verify run、Publish Pages run、artifact、deployment、发布 SHA 与线上 smoke 结果，不能沿用本次证据。
