# GitHub 首次 production 发布就绪核对

> 核对日期：2026-09-01
> 仓库：`mardd123588/flutter-tutorial`
> 本次只读取 GitHub API、GitHub CLI 与本地仓库，没有 push，也没有修改 GitHub 设置。

后续已完成首次 production 发布，结果见[首次 production 发布验收](../verification/production-release-acceptance.md)。本文保留发布前状态和决策依据。

## 结论

本地代码和 Pages artifact 已达到首次发布候选状态，远端尚未达到可部署状态。当前硬门槛有三项：远程仓库仍是 private、远端没有 `main` ref、GitHub Pages 尚未启用并选择 GitHub Actions 作为发布源。

| 检查项 | 状态 | 证据 |
| --- | --- | --- |
| 本地发布候选 | 已满足 | 本地 `main` 指向 `014ff82`；13 个项目、Web release 与 Pages staging 已通过，见 [`docs/verification/full-tutorial-review-round-3.md`](../verification/full-tutorial-review-round-3.md) |
| 仓库公开 | 未满足 | Repository API 返回 `private: true`、`visibility: private`；`gh repo view` 返回 `visibility: PRIVATE`。[Repository API](https://api.github.com/repos/mardd123588/flutter-tutorial) |
| 远程默认分支实体 | 未满足 | Repository API 保存的默认分支名称是 `main`，但仓库 `size: 0`；ref API 返回 `409 Git Repository is empty`，branch API 返回 404，`git ls-remote origin` 没有任何 ref。[Git refs API](https://docs.github.com/en/rest/git/refs#get-a-reference) · [Branches API](https://docs.github.com/en/rest/branches/branches#get-a-branch) |
| Actions 仓库权限 | 已满足 | `GET /actions/permissions` 返回 `enabled: true`、`allowed_actions: all`。[Actions permissions API](https://docs.github.com/en/rest/actions/permissions#get-github-actions-permissions-for-a-repository) |
| 远程 workflow 注册 | 未满足 | `GET /actions/workflows` 返回 `total_count: 0`，workflow runs 也是 0；远端为空，尚未读取本地两份 workflow。[Workflows API](https://docs.github.com/en/rest/actions/workflows#list-repository-workflows) |
| Pages 站点与发布源 | 未满足 | Repository API 返回 `has_pages: false`；`GET /repos/mardd123588/flutter-tutorial/pages` 返回 404，Pages build、deployment 与 `github-pages` environment 均不存在。[Pages API](https://docs.github.com/en/rest/pages/pages#get-a-github-pages-site) |
| 本地 Pages workflow 合同 | 已满足 | [`.github/workflows/pages.yml`](../../.github/workflows/pages.yml)上传单一 Pages artifact；部署 job 使用 `pages: write`、`id-token: write` 和 `github-pages` environment，符合 `deploy-pages` 官方合同。[deploy-pages README](https://github.com/actions/deploy-pages/blob/d6db90164ac5ed86f2b6aed7e0febac5b3c0c03e/README.md) |
| production Pages 与公开源码链接 | 首次部署后才能验证 | `https://mardd123588.github.io/flutter-tutorial/` 当前返回 404；生产 URL、缓存、13 个预览和匿名源码访问都没有线上证据 |

## 首次部署硬门槛

### 1. 先确定公开策略

教程正文包含仓库主页、issue 和 13 个项目源码链接。当前 private 仓库无法让匿名读者打开这些链接，因此“公开教程 + 可读源码”的目标要求把仓库改为 public。

GitHub Pages 在 GitHub Free 上只支持 public repository；Pro、Team 与 Enterprise 才支持从 private repository 发布。当前 API 响应没有提供账户 plan，不能证明 private Pages entitlement。即使账户支持 private Pages，源码链接仍不满足公开阅读合同。[GitHub Pages publishing source](https://docs.github.com/en/pages/getting-started-with-github-pages/configuring-a-publishing-source-for-your-github-pages-site)

### 2. 把发布候选推到远程 `main`

远端目前没有 commit、branch 或 workflow。首次 push 后要重新确认：

- `refs/heads/main` 存在，Repository API 的 `default_branch` 与实际 ref 都是 `main`；
- GitHub 已注册 `Verify` 和 `Publish Pages` 两个 workflow；
- 推送触发 `Verify`，且所有 required job 成功。

本地 [`verify.yml`](../../.github/workflows/verify.yml)监听 `main` push，并在普通 push 上用 `--all` 验证全部项目；这适合首次推送。

### 3. 在仓库 Pages 设置中选择 GitHub Actions

当前 Pages API 404，说明 Pages 站点尚未配置。本地 workflow 中的 `actions/configure-pages` 没有设置 `enablement: true`，使用的也是默认 `GITHUB_TOKEN`。该 action 的固定版本明确规定：`enablement` 默认是 `false`；未启用 Pages 时只会报告错误，不会创建站点。自动启用还要求 `GITHUB_TOKEN` 以外、具有 Pages 写权限的 token。[configure-pages action.yml](https://github.com/actions/configure-pages/blob/983d7736d9b0ae728b81ab479565c72886d7745b/action.yml) · [configure-pages api-client.js](https://github.com/actions/configure-pages/blob/983d7736d9b0ae728b81ab479565c72886d7745b/src/api-client.js)

因此首次部署前必须在 **Settings → Pages → Build and deployment → Source** 选择 **GitHub Actions**。本次没有代替仓库管理员执行该设置。[GitHub 官方配置步骤](https://docs.github.com/en/pages/getting-started-with-github-pages/configuring-a-publishing-source-for-your-github-pages-site#publishing-with-a-custom-github-actions-workflow)

### 4. 让 `Verify` 成功后触发 `Publish Pages`

[`pages.yml`](../../.github/workflows/pages.yml)使用 `workflow_run`，只接受同仓库、`main` 分支且结论为 success 的 `Verify`。GitHub 要求 `workflow_run` workflow 文件存在于默认分支；首次 push 同时建立默认分支和两份 workflow 后，这个前提才成立。[workflow_run](https://docs.github.com/en/actions/reference/workflows-and-actions/events-that-trigger-workflows#workflow_run)

推荐顺序：push `main` 后立即启用 Pages，再等待 `Verify`。如果 `Publish Pages` 已因 Pages 未启用而失败，启用后重跑该次 workflow，或重跑 `Verify` 产生新的 completed 事件；不需要改 artifact 代码。

## 已满足的本地发布合同

- VitePress `base` 是 `/flutter-tutorial/`，见 [`site/.vitepress/config.mts`](../../site/.vitepress/config.mts)。
- 13 个 Flutter 预览使用 `/flutter-tutorial/previews/<slug>/`，见 [`tool/release/build_project.mjs`](../../tool/release/build_project.mjs)。
- [`tool/release/assemble_pages.mjs`](../../tool/release/assemble_pages.mjs)把站点和 13 个预览合并为单一 artifact，并写入 commit SHA。
- [`tool/release/smoke_staging.mjs`](../../tool/release/smoke_staging.mjs)已验证入口、manifest、预览、Wasm、Worker 与 MIME；这仍是 staging 证据，不替代 production。
- Pages workflow checkout `Verify` 的 `head_sha`，再构建、上传和部署同一提交；Actions 均固定到 commit SHA。
- `deploy-pages` 所需的 artifact、job dependency、权限与 environment 都已声明。GitHub 会在首次 deployment 时自动创建不存在的 `github-pages` environment。[GitHub custom workflow](https://docs.github.com/en/pages/getting-started-with-github-pages/configuring-a-publishing-source-for-your-github-pages-site#creating-a-custom-github-actions-workflow-to-publish-your-site)

## 首次部署后才能验证

首次 `Publish Pages` 成功后，再把下面各项改为线上证据：

1. Pages API 返回 200，`build_type` 为 `workflow`，`html_url` 指向项目站点；Repository API 的 `has_pages` 为 true。
2. `Verify` 与 `Publish Pages` 对同一 commit SHA 都是 success；Pages deployment 和 `github-pages` environment 可由 API 查到。
3. `https://mardd123588.github.io/flutter-tutorial/`、项目索引、`release-manifest.json`、13 个预览入口与关键 hash URL 返回预期内容。
4. `release-manifest.json` 的 `contentVersion` 等于已发布 commit，且恰好列出 13 个预览。
5. Drift 的 `sqlite3.wasm` 与 Worker 使用正确 MIME；CanvasKit 没有转向第三方 CDN；`flutter_service_worker.js` 没有注册有效 offline-first Worker。
6. 匿名浏览器能打开仓库主页、issue 和 13 个项目源码链接。仓库仍为 private 时，本项必然不通过。
7. 保存 workflow run URL、deployment、artifact 标识和发布 commit；production 回滚只从已知通过的 commit 重新构建。

## 发布判定

当前判定为 **未就绪**，原因只在 GitHub 远端状态，不在本地 artifact：仓库未公开、远程 `main` 不存在、Pages 未启用。完成这三项后，让 `Verify` 与 `Publish Pages` 各成功一次，再执行 production 验收清单，才能把首次发布标为完成。
