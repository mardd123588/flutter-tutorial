---
title: GitHub Pages artifact 与发布
description: 把 VitePress 和 13 个 Flutter Web 预览合并成单一 Pages artifact，在部署前验证路径、MIME、版本与回滚入口。
part: 8
order: 4
kind: concept
requires:
  - engineering.ci
  - web.release-build
  - navigation.url-state
provides:
  - deployment.pages
  - deployment.preview-layout
  - deployment.rollback
status: verified
---

# GitHub Pages artifact 与发布

GitHub Pages 自定义 workflow 分两段：build job 生成并上传静态 artifact，deploy job 取得 Pages 权限并部署。本站还要把 VitePress 和 13 个 Flutter Web release 产物放进同一目录，上传前先把它当成最终网站验收。

## 一个 staging 目录对应一个站点

目标目录固定为：

```text
build/pages-staging/
├── index.html
├── guide/
├── projects/
├── release-manifest.json
└── previews/
    ├── daily-rhythm-board/
    ├── ...
    └── neighborhood-exchange/
```

组装脚本先删除旧 staging，再复制本次 VitePress `dist`。随后读取 `tool/projects.json`，逐个验证 release，并复制到 `previews/<slug>/`。目标目录若已存在，复制直接失败；重复 slug 不会静默覆盖另一个项目。

删除动作只允许指向仓库内固定的 `build/pages-staging`。脚本先用 `path.relative` 检查路径，避免一个错误参数把更大的目录当成 staging 清空。

## Manifest 记录内容版本和入口

组装完成后写入：

```json
{
  "contentVersion": "<commit-sha>",
  "previews": [
    {
      "slug": "neighborhood-exchange",
      "path": "/flutter-tutorial/previews/neighborhood-exchange/"
    }
  ]
}
```

Manifest 不写当前时间，避免同一个 commit 因构建时钟产生无意义差异。`contentVersion` 来自 `GITHUB_SHA`，本地构建则为 `working-tree`。

回滚的可靠入口是上一个成功 commit SHA：检出该 commit，按同一锁文件和 workflow 重新构建、组装、smoke，再部署。Pages artifact 默认保留时间很短，不能当长期备份。

## Build job 不直接部署

Pages workflow 只接受 `main` 上成功的 `Verify`：

```yaml
on:
  workflow_run:
    workflows: [Verify]
    types: [completed]
    branches: [main]

jobs:
  build:
    if: >-
      github.event.workflow_run.conclusion == 'success' &&
      github.event.workflow_run.head_branch == 'main' &&
      github.event.workflow_run.head_repository.full_name == github.repository
```

`head_repository` 检查避免把 fork 上的同名 workflow 当成本站发布来源。Checkout 精确使用 `workflow_run.head_sha`，后续站点、预览和 manifest 都来自同一个 commit。

Build job 只要 `contents: read` 和 `pages: read`。它完成 locked install、VitePress build、13 个独立 Flutter build、staging 组装与 smoke，然后上传单一 Pages artifact：

```yaml
- uses: actions/upload-pages-artifact@56afc609e74202658d3ffba0e8f6dda462b719fa
  with:
    path: build/pages-staging
    retention-days: 1
```

## Deploy job 才取得写权限

```yaml
deploy:
  needs: build
  permissions:
    pages: write
    id-token: write
  environment:
    name: github-pages
    url: ${{ steps.deployment.outputs.page_url }}
```

Build 脚本不持有部署权限；deploy job 不重新构建。权限和产物责任分开后，失败位置更清楚：构建错误不会进入部署，部署 job 也不能临时改变网站内容。

## Smoke test 从真实 base 提供文件

`pnpm release:smoke` 启动临时 HTTP server，把 staging 映射到 `/flutter-tutorial/`。它检查：

- 站点首页、项目索引和 release manifest；
- 13 个预览入口；
- 每个预览的 hash 深链接入口；
- Drift 项目的 `sqlite3.wasm` 与 `drift_worker.js`；
- HTML、JavaScript、JSON、CSS、SVG、PNG 与 Wasm 的 MIME。

Hash fragment 不会传给服务器，所以 smoke 对 `#/listings/r-001` 的 HTTP 请求仍落在预览目录。静态 smoke 只能负责入口和资产；筛选参数、详情恢复、Back / Forward 与非法 ID 还要分别用 Widget、Chrome 或人工浏览器流程验证。

发布前还要补浏览器层检查：搜索是否返回预期章节、控制台是否干净、外部网络是否被请求、Back / Forward 是否恢复、200% 文本和键盘主流程是否可用。单个 HTTP `200` 不能代替这些证据。

当前 `release:smoke` 只验证 HTTP 状态、入口、声明资源与 MIME，不启动真实浏览器。本轮人工检查已覆盖三档视口和控制台；production Pages URL、缓存更新、旧 Service Worker 注销与线上 hash 深链接，要等首次部署后再确认。

## Path URL、404 与自定义域名留在服务器边界

GitHub Pages 可以使用自定义域名，但 DNS、HTTPS、缓存和回滚步骤都需要额外运维证据。Path URL 还要解决未知路径 rewrite；复制 `index.html` 为 `404.html` 或脚本重定向会引入新的错误与缓存路径。

首版保留仓库子路径和 hash URL，不做自定义域名、PR Pages preview 或 404 workaround。以后改变托管方式时，先写 ADR，再更新路由、base、缓存、smoke 和回滚合同。

## 可验证任务

确认 13 个 release 已存在后运行：

```powershell
pnpm docs:build
pnpm release:stage
pnpm release:smoke
```

打开 `build/pages-staging/release-manifest.json`，核对预览数量、slug、路径和 `contentVersion`。随机选择一个普通项目和一个 Drift 项目，检查它们的入口、hash 深链接、Wasm / Worker 与 CanvasKit。

然后故意把一个复制目标改成已有 slug，在临时分支验证组装失败。恢复脚本后再运行 smoke。写下回滚时需要的 commit SHA、locked install、全量构建、staging 和 deploy 顺序。

## 复习线索

- Pages build 生成 artifact，deploy 只部署已经上传的内容。
- VitePress 和全部预览先合并到一个干净 staging 目录。
- Manifest 用 commit SHA 标记内容，不加入构建时间噪声。
- Smoke test 检查静态入口与 MIME，Chrome 集成测试检查应用恢复和交互。
- 上一个成功 commit 才是可长期重建的回滚入口。

## 参考资料

- [Using custom workflows with GitHub Pages](https://docs.github.com/en/pages/getting-started-with-github-pages/using-custom-workflows-with-github-pages)（查阅：2026-08-31）
- [`actions/configure-pages`](https://github.com/actions/configure-pages)（查阅：2026-08-31）
- [`actions/upload-pages-artifact`](https://github.com/actions/upload-pages-artifact)（查阅：2026-08-31）
- [`actions/deploy-pages`](https://github.com/actions/deploy-pages)（查阅：2026-08-31）
- [VitePress: Deploy Your VitePress Site](https://vitepress.dev/guide/deploy)（查阅：2026-08-31）
- [GitHub Pages: Managing a custom domain](https://docs.github.com/en/pages/configuring-a-custom-domain-for-your-github-pages-site/managing-a-custom-domain-for-your-github-pages-site)（查阅：2026-08-31）
