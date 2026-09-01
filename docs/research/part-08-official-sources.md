# 第八部分官方资料研究：工程化、Web 发布与平台扩展

> 查阅日期：2026-08-31
> 教程基线：Flutter 3.47.0、Dart 3.13.0、Node.js 22 LTS、pnpm 10.34.5、VitePress 1.6.4
> 发布目标：GitHub Pages `/flutter-tutorial/`，Flutter Web 预览位于 `/flutter-tutorial/previews/<project-slug>/`
> 资料范围：Flutter / Dart 官方文档与源码、pnpm 与 VitePress 官方文档、GitHub Actions / Pages 官方文档与 action 源码、Chrome / Web 标准资料

这份笔记确定第八部分的知识边界、章节依赖、工程与发布方案，以及统筹项目“邻里资源交换站”的项目合同。项目和 workflow 已经实现，本文同时记录实现核对结果；教程正文另行编写。下文把工具、平台和规范规定写成“官方事实”，把仓库结构与教学取舍写成“课程决定”，把本仓库已经跑过的结果写成“实现证据”。

## 0. 本轮核对结论

以下结论会直接影响 `08-01` 至 `08-07` 的写法：

- **Pub workspace 需要改正旧表述。** workspace 统一依赖解析，但成员之间仍要声明依赖。只要依赖名与版本约束匹配 workspace 中的包，pub 会优先使用本地成员，不要求把依赖来源写成 `path`。Dart 3.11 起 `workspace` 还支持 glob，当前文档也允许 nested workspace；本仓库仍选择显式列出 13 个成员，且不建立成员间业务依赖。[Pub workspaces](https://dart.dev/tools/pub/workspaces)（查阅：2026-08-31）
- **受影响项目检测已经保留 rename 两端。** Git 的 `--name-status -z` 会为 rename / copy 提供状态和旧、新路径；`tool/ci/affected_projects.mjs` 现使用 `--name-status -z --find-renames`，`parseNameStatus()` 把两端都交给选择器。第 7 项 Node 回归测试固定了 `R100` 解析，`pnpm projects:check` 为 7/7 通过。[`git diff` format options](https://git-scm.com/docs/diff-options#Documentation/diff-options.txt---name-status)（查阅：2026-08-31）
- **“可复现”是锁定输入后的可重复验证，不是字节级复现。** Flutter、Dart、pnpm、VitePress 与 action commit 已固定；`node-version: 22` 仍会选择符合 22 的可用版本，`ubuntu-24.04` runner image 也会更新。正文应明确这一层级，不能写成 runner、浏览器和最终二进制永久不变。[setup-node versioning](https://github.com/actions/setup-node#basic) · [GitHub-hosted runner images](https://github.com/actions/runner-images#available-images)（查阅：2026-08-31）
- **Flutter 3.47.0 的 release 参数仍可用，但有版本边界。** `--base-href`、`--no-web-resources-cdn`、`--source-maps`、`--wasm` 与默认开启的 Wasm dry run 都在当前 CLI 中；`--pwa-strategy` 已隐藏并弃用，只能作为 3.47.0 的过渡参数。[Flutter `build_web.dart` 3.47.0](https://github.com/flutter/flutter/blob/3.47.0/packages/flutter_tools/lib/src/commands/build_web.dart) · [Flutter WebAssembly](https://docs.flutter.dev/platform-integration/web/wasm)（查阅：2026-08-31）
- **Pages 自动 smoke 的证据要按实际脚本写。** 当前 `release:smoke` 验证站点入口、manifest、13 个预览入口、声明的 Wasm / Worker 资源、HTTP 状态和 MIME；它没有启动真实浏览器、阻断外网或执行键盘流程。三档视口和控制台检查属于本轮人工浏览器验收，production URL、缓存更新和旧 Service Worker 仍要在首次 Pages 部署后确认。
- **GitHub dependency graph 对 pnpm 与 pub 的能力不同。** 官方表中 pnpm 支持静态传递依赖，pub 虽以 `pubspec.lock` 为推荐文件，但静态传递依赖、Dependabot graph job 与自动提交三列目前都标为不支持。本仓库也尚未加入 dependency review job；正文只能把它写成“仓库识别到对应依赖时的补充证据”。[Dependency graph supported package ecosystems](https://docs.github.com/en/code-security/reference/supply-chain-security/dependency-graph-supported-package-ecosystems)（查阅：2026-08-31）

## 1. 固定边界与已学前置

### 1.1 仓库决定不在本部分重选

**课程决定：** GitHub Issue #1 已固定第八部分为 7 章，顺序是 workspace 与配置、可复现 CI、Flutter Web release、GitHub Pages、平台扩展、发布质量与升级、统筹项目。`requires`、`provides` 和项目 slug 继续沿用该规格，不在研究阶段改名或换序。[首版规格 #1](https://github.com/mardd123588/flutter-tutorial/issues/1)（查阅：2026-08-31）

以下 ADR 继续生效：

- [ADR-0001](../adr/0001-web-baseline-for-cross-platform-tutorial.md)：普通 Flutter Web release 是所有项目的统一验收基线，Wasm 不是默认构建方式。
- [ADR-0002](../adr/0002-reproducible-project-data.md)：项目必须离线可复现，不把远程服务状态带入 CI。
- [ADR-0005](../adr/0005-independent-practice-projects.md)：项目之间不共享业务代码或 UI 包。
- [ADR-0010](../adr/0010-hash-urls-on-github-pages.md)：GitHub Pages 上保留 hash URL，不维护 path URL 的 404 回退。
- [ADR-0012](../adr/0012-web-integration-tests-use-webdriver.md)：浏览器关键流程使用 `integration_test`、`flutter drive -d web-server` 与 ChromeDriver。
- [ADR-0014](../adr/0014-pub-workspace-without-melos.md)：Dart 侧使用 pub workspace，Node 侧只有根包，不引入 Melos。
- [ADR-0015](../adr/0015-split-content-and-code-licenses.md)：内容使用 CC BY 4.0，代码使用 BSD 3-Clause，其他素材逐项记录许可。
- [ADR-0016](../adr/0016-accessible-tracking-free-public-site.md)：公开站点以 WCAG 2.2 AA 为目标，不加载追踪、广告、评论、社交组件或第三方字体。
- [ADR-0017](../adr/0017-project-previews-share-the-pages-artifact.md)：VitePress 与所有 Flutter Web 预览合并成一个 Pages artifact。

### 1.2 本部分只讲交付链路新增知识

读者进入第八部分前，已经学过应用架构、Riverpod、fixture Service、Drift、go_router、hash URL、响应式布局、可访问性、分层测试、ChromeDriver、Sliver 与 profile。第八部分不再从头解释这些概念，而是回答四个交付问题：

1. 同一仓库怎样固定 SDK、依赖、配置和工具输入；
2. CI 怎样从干净环境复现本地结果，并准确选择受影响项目；
3. Flutter Web 产物怎样从子路径加载、与教程站合并并发布到 GitHub Pages；
4. Web 验收能证明什么，平台插件、权限、原生代码和升级还需要哪些独立证据。

## 2. Workspace、依赖锁定与配置

### 2.1 pub workspace 的真实作用

**官方事实：** pub workspace 由根 `pubspec.yaml` 的 `workspace` 列表和成员包的 `resolution: workspace` 组成。整个 workspace 共享一次依赖解析、一个根 `pubspec.lock` 与一个根 `.dart_tool/package_config.json`。成员之间不会自动获得彼此的 API；需要像普通 package 一样声明依赖。若依赖指向另一个 workspace 成员，pub 会优先解析到本地成员，并检查本地版本是否满足约束，不要求把来源写成 `path`。workspace 支持从 Dart 3.6 开始，glob 需要 Dart 3.11 或更新版本；当前 pub 还支持 nested workspace，并禁止未登记的中间 `pubspec.yaml` 遮蔽根解析。[Pub workspaces](https://dart.dev/tools/pub/workspaces)（查阅：2026-08-31）

**课程决定：** 根 workspace 包含 13 个独立项目，并显式列出每个路径，不使用 glob 或 nested workspace。每个成员保留自己的 `pubspec.yaml`、`lib/`、`test/`、`integration_test/` 与 `web/`。workspace 只统一解析、lint 和仓库工具；13 个项目不声明成员间依赖，也不引入共享 domain、Repository、主题或组件包。

### 2.2 锁文件是输入，不是缓存

**官方事实：** `dart pub get --enforce-lockfile` 会在 `pubspec.lock` 不能精确满足 `pubspec.yaml`，或 hosted package 的内容 hash 改变时失败；Dart CLI 把它明确列为 CI 和生产部署用途。`dart pub get --offline` 只使用本地缓存，不能证明一个全新 runner 能取得依赖。[dart pub get](https://dart.dev/tools/pub/cmd/pub-get)（查阅：2026-08-31）

**官方事实：** pnpm 的 `--frozen-lockfile` 禁止安装过程修改锁文件，锁文件与 manifest 不一致时失败。GitHub `setup-node` 的 pnpm 缓存复用全局 package data，不缓存 `node_modules`；缓存键依赖 lockfile，恢复缓存后仍要运行安装命令。[pnpm install](https://pnpm.io/cli/install#--frozen-lockfile) · [actions/setup-node advanced usage](https://github.com/actions/setup-node/blob/main/docs/advanced-usage.md#caching-packages-data)（查阅：2026-08-31）

**课程决定：** `pubspec.lock`、`pnpm-lock.yaml`、根 `pubspec.yaml` 与 `package.json` 全部提交。干净安装固定使用：

```powershell
flutter pub get --enforce-lockfile
pnpm install --frozen-lockfile
```

缓存只缩短下载时间。CI 的正确性仍由锁文件、工具版本、安装命令和后续验证决定，不能把“命中缓存”写成“依赖可复现”。

### 2.3 依赖声明和资产必须归属清楚

**官方事实：** Dart package 只应把运行时直接使用的包放进 `dependencies`，把测试、生成和开发工具放进 `dev_dependencies`；pub 根据整个依赖图和版本约束选择一组兼容版本。Flutter 资产需要在项目 `pubspec.yaml` 的 `flutter.assets` 中声明，构建时才进入 asset bundle。[Package dependencies](https://dart.dev/tools/pub/dependencies) · [Adding assets and images](https://docs.flutter.dev/ui/assets/assets-and-images)（查阅：2026-08-31）

**课程决定：** 受影响项目计算必须识别三类输入：

- 项目私有输入：项目目录内的 Dart、测试、`pubspec.yaml`、`web/` 与资产；
- workspace 共享输入：根 `pubspec.yaml`、`pubspec.lock`、`analysis_options.yaml`、Flutter 版本与验证脚本；
- 站点输入：`site/`、`package.json`、`pnpm-lock.yaml` 与 `tool/site/`。

项目私有输入只触发对应项目；workspace 共享输入触发 13 个项目；发布、ChromeDriver 或 artifact 合并脚本变化同时触发站点和 13 个项目。

### 2.4 编译时配置不是秘密存储

**官方事实：** `--dart-define` 和 `--dart-define-from-file` 把值提供给 `String.fromEnvironment`、`bool.fromEnvironment` 与 `int.fromEnvironment`；Web 构建最终把应用交付给浏览器，用户能检查下载的代码、请求和静态资源。Flutter Web 官方安全说明明确提醒：不能在客户端应用中安全保存秘密。[Build and release a web app](https://docs.flutter.dev/deployment/web) · [Flutter web FAQ: security](https://docs.flutter.dev/platform-integration/web/faq#how-do-i-securely-store-my-apps-secrets)（查阅：2026-08-31）

**课程决定：** 编译时配置只放可公开值，例如 `APP_ENV=demo`、`CONTENT_VERSION=<commit-sha>`、功能开关和公开 API 根地址。token、私钥、服务账号和可写后端凭据不进入 `--dart-define`、`.env`、VitePress 配置、Pages artifact 或仓库。示例 `.env` 只能保存占位值，并明确不把它称作 Web 秘密方案。

**官方事实：** Flutter 3.47.0 还提供 `--web-define=<KEY=VALUE>`，用于替换 `web/index.html` 与 `web/flutter_bootstrap.js` 中的 `{{KEY}}` 模板变量；`--dart-define` 则进入 Dart 的编译时环境。两种值最终都进入浏览器可取得的产物，不能保存秘密。[Flutter `build_web.dart` 3.47.0](https://github.com/flutter/flutter/blob/3.47.0/packages/flutter_tools/lib/src/commands/build_web.dart) · [Flutter `flutter_command.dart` 3.47.0](https://github.com/flutter/flutter/blob/3.47.0/packages/flutter_tools/lib/src/runner/flutter_command.dart)（查阅：2026-08-31）

**课程决定：** “邻里资源交换站”只用 `--dart-define` 读取 `APP_ENV` 与 `CONTENT_VERSION`，不需要修改 Web 模板。正文简要说明 `--web-define` 的适用位置，避免把两套参数混成同一种配置入口。

## 3. 可复现 CI

### 3.1 CI 从固定输入开始

**官方事实：** GitHub Actions workflow 可以收紧 `GITHUB_TOKEN` 权限；GitHub 的安全加固指南建议第三方 action 固定到完整 commit SHA，因为 SHA 是不可变引用。缓存内容可能来自权限更低的分支，不能存凭据，也不能当作可信构建产物直接发布。[Security hardening for GitHub Actions](https://docs.github.com/en/actions/security-for-github-actions/security-guides/security-hardening-for-github-actions)（查阅：2026-08-31）

**课程决定：** workflow 固定 Flutter 3.47.0、Dart 3.13.0、pnpm 10.34.5 和 VitePress 1.6.4，并把 action 固定到已审核的完整 commit SHA；更新 SHA 走独立依赖 PR。当前 `node-version: 22` 固定的是 Node 主版本，不是补丁版本。默认权限从 `contents: read` 开始，只有 Pages deploy job 增加 `pages: write` 与 `id-token: write`。

**实现证据：** `verify.yml` 与 `pages.yml` 使用以下固定 action：

| Action | Commit SHA |
| --- | --- |
| `actions/checkout` | `11d5960a326750d5838078e36cf38b85af677262` |
| `actions/setup-node` | `49933ea5288caeca8642d1e84afbd3f7d6820020` |
| `subosito/flutter-action` | `1a449444c387b1966244ae4d4f8c696479add0b2` |
| `actions/upload-artifact` | `ea165f8d65b6e75b540449e92b4886f43607fa02` |
| `actions/configure-pages` | `983d7736d9b0ae728b81ab479565c72886d7745b` |
| `actions/upload-pages-artifact` | `56afc609e74202658d3ffba0e8f6dda462b719fa` |
| `actions/deploy-pages` | `d6db90164ac5ed86f2b6aed7e0febac5b3c0c03e` |

这些 SHA 固定 action 代码，不能固定 GitHub-hosted runner image、Chrome 安装版本或外部下载服务。正文把它们称为“受控输入”，不写成“所有环境字节一致”。

### 3.2 Pull request 与 main 的工作量不同

**课程决定：** Pull request 先运行仓库级内容和依赖检查，再按 git diff 计算受影响项目。项目 job 以矩阵并行，但同一项目内按下面顺序运行，前一步失败就停止：

```text
locked install
  → flutter analyze
  → unit / Widget tests
  → Chrome 关键流程
  → release Web build
  → 静态服务器子路径检查
```

`main`、手动发布与版本基线变化不走增量，固定验证 13 个项目。受影响项目算法只优化 PR 时间，不改变发布门槛。

**官方事实：** `git diff A...B` 比较 `merge-base(A, B)` 与 `B`；`--name-status -z` 使用 NUL 分隔路径，并为 rename / copy 记录旧、新路径。只读取 `--name-only` 不足以恢复 rename 的两端。[`git diff`](https://git-scm.com/docs/git-diff) · [`git diff` format options](https://git-scm.com/docs/diff-options#Documentation/diff-options.txt---name-status)（查阅：2026-08-31）

**实现证据：** `selectAffectedProjects()` 已覆盖项目私有输入、workspace 共享输入、站点输入、release / workflow 输入和未知 `examples/` 路径的保守全量回退。Git 读取层使用 `--name-status -z --find-renames`，`parseNameStatus()` 对 `R...` 与 `C...` 读取旧、新路径；7 项 Node 测试同时覆盖状态解析和选择结果。

### 3.3 并行必须隔离端口和浏览器状态

**官方事实：** Chrome for Testing 从 M115 起提供与 Chrome release 对齐的版本选择和 JSON endpoints；ChromeDriver 文档要求选择与 Chrome binary 兼容的版本。仅把 `chromedriver` 加入 `PATH` 不能保证版本匹配。[ChromeDriver version selection](https://developer.chrome.com/docs/chromedriver/downloads/version-selection) · [Chrome for Testing](https://googlechromelabs.github.io/chrome-for-testing/)（查阅：2026-08-31）

**课程决定：** 每个 Chrome job 记录 Chrome 与 ChromeDriver 的完整版本，并按 Chrome build 下载匹配的 ChromeDriver 后再启动测试。matrix 的每一项运行在独立 runner，可以重复使用 `4444` 与 `7357`；只有在同一 runner 内并行多个浏览器任务时，才必须分配不同端口、浏览器 profile、数据库和输出目录。端口仍由 job 显式传入，不在脚本里依赖“碰巧空闲”。

### 3.4 失败产物要能复现，而不是只留红叉

**课程决定：** 失败 artifact 至少保留：

- 项目 slug、commit SHA、Flutter / Dart / Chrome / ChromeDriver 版本；
- 实际命令、退出码和完整日志；
- Widget / integration 失败日志；需要截图或浏览器控制台时，另用真实浏览器验收补齐；
- release 加载失败的 URL、HTTP 状态、响应头和资源请求；
- 内容搜索失败的查询、实际前 5 与预期页面。

普通 CI 不用绝对帧时间作为唯一通过条件。性能回归需要固定 workload、profile trace 和人工解释，这一边界已在第七部分建立。

**实现核对：** 当前验证脚本会写入项目、commit、工具与浏览器版本、端口、命令、退出码、analyze / test / integration 日志和 ChromeDriver 日志。`flutter drive -d web-server` 不支持失败截图；脚本也没有单独导出浏览器 console、网络请求与 HTTP 响应头，正文不能把这些内容写成当前失败 artifact 已经具备。

## 4. Flutter Web release、子路径与 PWA 边界

### 4.1 release 构建只生成产物

**官方事实：** `flutter build web` 生成可部署到静态服务器的 `build/web`。本地验收要通过 HTTP server 提供该目录，不能双击 `index.html`；构建完成也不证明部署路径、MIME、缓存和深链接正确。[Build and release a web app](https://docs.flutter.dev/deployment/web)（查阅：2026-08-31）

**课程决定：** 所有项目先通过普通 JavaScript release：

```powershell
flutter build web --release `
  --pwa-strategy=none `
  --no-web-resources-cdn `
  --base-href /flutter-tutorial/previews/<project-slug>/
```

`--pwa-strategy=none` 是 3.47.0 的版本内过渡参数，完整边界见 4.7。构建后必须从相同子路径启动静态服务器，检查入口、hash 深链接、Back / Forward、刷新、字体、图片、Worker 与 Wasm（若项目使用）。

### 4.2 `base href` 影响所有相对 URL

**官方事实：** HTML `<base href>` 设置文档中相对 URL 的解析基准。Flutter 3.47.0 的 `--base-href` 会替换 Web 模板中的 `$FLUTTER_BASE_HREF`，并要求值以 `/` 开头和结尾。[MDN `<base>`](https://developer.mozilla.org/en-US/docs/Web/HTML/Reference/Elements/base) · [Flutter Web template](https://github.com/flutter/flutter/blob/3.47.0/packages/flutter_tools/templates/app/web/index.html.tmpl) · [Flutter `build_web.dart`](https://github.com/flutter/flutter/blob/3.47.0/packages/flutter_tools/lib/src/commands/build_web.dart)（查阅：2026-08-31）

**课程决定：** VitePress 的 `base` 固定为 `/flutter-tutorial/`；每个 Flutter 预览使用完整 `/flutter-tutorial/previews/<slug>/`。不得用相对 `./` 掩盖部署错误，也不得在 Dart 代码里手拼 Pages 仓库名。资源 URI 保持相对 base；跨项目链接由站点配置生成。

**官方事实：** VitePress 的 `base` 是站点部署根路径；部署到 `https://<user>.github.io/<repo>/` 时，官方部署指南要求把它设为 `/<repo>/`。VitePress 构建目录可以作为 Pages artifact 的一个静态目录上传。[VitePress site config: `base`](https://vitepress.dev/reference/site-config#base) · [VitePress: Deploying a VitePress Site](https://vitepress.dev/guide/deploy#github-pages)（查阅：2026-08-31）

### 4.3 Web engine 资源必须随 artifact 自托管

**官方事实：** Flutter 3.47.0 的 Web 构建默认启用 `--web-resources-cdn`。工具源码把 `--no-web-resources-cdn` 转成 `useLocalCanvasKit: true`，让 loader 使用构建产物中的 CanvasKit，而不是默认的 `https://www.gstatic.com/flutter-canvaskit/...`。[Flutter `flutter_command.dart` 3.47.0](https://github.com/flutter/flutter/blob/3.47.0/packages/flutter_tools/lib/src/runner/flutter_command.dart#L811)（查阅：2026-08-31）

**课程决定：** 所有公开预览的 release 命令都显式加入 `--no-web-resources-cdn`。这样断网 staging 才能验证完整产物，也与无第三方请求的站点合同一致。构建后的 loader 库仍可能包含未启用的 CDN 分支字符串，因此静态扫描不能只要看到 `gstatic.com` 就失败；还要检查 build config 的 `useLocalCanvasKit: true`，并以浏览器实际网络请求为最终证据。

### 4.4 hash URL 是 Pages 的部署合同

**官方事实：** 静态服务器只会返回真实存在的文件。客户端 path URL 刷新时，服务器必须配置 rewrite / fallback 才能回到应用入口；hash fragment 不会作为 HTTP 路径发送给服务器。[Flutter URL strategies](https://docs.flutter.dev/ui/navigation/url-strategies)（查阅：2026-08-31）

**课程决定：** Flutter 预览继续使用 hash URL，例如 `/flutter-tutorial/previews/neighborhood-exchange/#/listings/r-018`。第八部分说明 path URL 所需服务器能力，但不为 GitHub Pages 增加复制 `404.html`、JavaScript 重定向或自定义 rewrite。hash 深链接必须进入 Pages staging 验收。

### 4.5 source map 与公开调试信息

**官方事实：** Flutter 3.47.0 的 `flutter build web` 提供 `--source-maps`，浏览器可以用 source map 把压缩后的 JavaScript / Wasm 位置映射回 Dart 源码；该选项不是 release 运行所必需。[Flutter Web build command source](https://github.com/flutter/flutter/blob/3.47.0/packages/flutter_tools/lib/src/runner/flutter_command.dart)（查阅：2026-08-31）

**课程决定：** Pages 首版不发布 source map。需要诊断 release-only 问题时，在受限 CI job 生成并作为短期调试 artifact 保存，不合并进公开 Pages 目录。source map 不是秘密保护措施；真正的秘密本来就不应进入客户端。

### 4.6 Wasm 是测量后的选择

**官方事实：** `flutter build web --wasm` 会生成 WebAssembly 构建并保留 JavaScript fallback。Skwasm 的多线程渲染依赖浏览器能力和 cross-origin isolation，服务器需要正确设置 `Cross-Origin-Opener-Policy` 与 `Cross-Origin-Embedder-Policy`；包里的 Web 代码还必须通过 Wasm compatibility 检查。[Flutter WebAssembly](https://docs.flutter.dev/platform-integration/web/wasm) · [Flutter Web renderers](https://docs.flutter.dev/platform-integration/web/renderers)（查阅：2026-08-31）

**课程决定：** GitHub Pages 普通 JavaScript build 是发布基线。正文只用一个对照构建解释 `--wasm`、兼容性、响应头和测量方法，不承诺 Pages 当前部署能满足所有多线程条件，也不为 13 个项目维护双份 release。只有固定 workload 在目标浏览器上显示明确收益，且服务器响应头、包兼容和回退都通过，才考虑项目级启用。

**官方事实：** Flutter 3.47.0 在普通 JavaScript build 中默认执行 Wasm dry run；发现不兼容会打印非致命警告，真正的 `flutter build web --wasm` 才是 Wasm 产物的构建门槛。正文不要把 dry run 通过写成已经发布或实际运行了 Wasm。[Flutter WebAssembly](https://docs.flutter.dev/platform-integration/web/wasm) · [Flutter `build_web.dart` 3.47.0](https://github.com/flutter/flutter/blob/3.47.0/packages/flutter_tools/lib/src/commands/build_web.dart)（查阅：2026-08-31）

### 4.7 浏览器缓存不等于 PWA

**官方事实：** HTTP cache 按请求、响应头和验证器复用资源；Service Worker 则可以拦截 fetch 并实现独立缓存策略，两者生命周期和失效路径不同。[MDN HTTP caching](https://developer.mozilla.org/en-US/docs/Web/HTTP/Guides/Caching) · [Service Workers Level 1](https://www.w3.org/TR/service-workers/)（查阅：2026-08-31）

**官方事实：** Flutter 3.47.0 仍默认生成 `flutter_service_worker.js` 的 offline-first 实现，但 Flutter 工具已经把 `--pwa-strategy` 标为 deprecated，并计划移除默认 service worker；官方说明默认实现并不适合所有应用，也不是 Flutter Web 运行的必要条件。[Flutter issue #156910](https://github.com/flutter/flutter/issues/156910) · [Flutter `compile.dart` 3.47.0](https://github.com/flutter/flutter/blob/3.47.0/packages/flutter_tools/lib/src/web/compile.dart) · [Flutter service worker generator 3.47.0](https://github.com/flutter/flutter/blob/3.47.0/packages/flutter_tools/lib/src/web/file_generators/flutter_service_worker_js.dart)（查阅：2026-08-31）

**课程决定：** 首版明确不做 PWA、离线安装、后台同步或推送。Flutter 3.47.0 构建暂时显式使用隐藏且已弃用的 `--pwa-strategy=none`，并在 staging 验证没有有效的 offline-first worker 接管页面：

```powershell
flutter build web --release `
  --pwa-strategy=none `
  --base-href /flutter-tutorial/previews/<project-slug>/
```

这个参数是版本基线内的过渡措施。升级 Flutter 时必须先检查 #156910 和工具源码，再删除或替换；不能把已弃用参数永久写成通用建议。

**本地探针：** 2026-08-31 使用 Flutter 3.47.0 对“今日节奏板”执行上述构建，命令成功并打印弃用警告；产物中的 `flutter_service_worker.js` 为 0 字节，`flutter_bootstrap.js` 以 `_flutter.loader.load()` 启动，没有传入 Service Worker 注册配置。这只能证明当前 SDK 的构建结果，不能代替已有站点上旧 Worker 的注销检查，也不能外推到后续 Flutter 版本。

## 5. GitHub Pages artifact 与发布

### 5.1 Pages workflow 分成 build 与 deploy

**官方事实：** GitHub Pages 自定义 workflow 先构建静态文件，再用 `actions/upload-pages-artifact` 上传 Pages artifact，最后由 `actions/deploy-pages` 部署。deploy job 至少需要 `pages: write`、`id-token: write`，并建议使用 `github-pages` environment。[Using custom workflows with GitHub Pages](https://docs.github.com/en/pages/getting-started-with-github-pages/using-custom-workflows-with-github-pages) · [actions/deploy-pages](https://github.com/actions/deploy-pages)（查阅：2026-08-31）

**官方事实：** `actions/upload-pages-artifact` 接受一个静态目录，先把目录归档再上传名为 `github-pages` 的 artifact；本仓库固定的 action commit 把 `retention-days` 默认值设为 `1`。GitHub Pages 要求上传内容最终是一个 gzip 压缩的 tar，tar 小于 10 GB，且不能包含 symbolic link 或 hard link。Pages artifact 不是长期发布备份。[GitHub Pages custom workflows](https://docs.github.com/en/pages/getting-started-with-github-pages/using-custom-workflows-with-github-pages) · [pinned `actions/upload-pages-artifact` `action.yml`](https://github.com/actions/upload-pages-artifact/blob/56afc609e74202658d3ffba0e8f6dda462b719fa/action.yml)（查阅：2026-08-31）

**官方事实：** `workflow_run` 无论上游结论如何都会触发；后续 workflow 必须读取 `github.event.workflow_run.conclusion` 决定是否继续。它还可能获得前一 workflow 没有的 secrets 与 write token，因此不能直接运行不可信分支代码。[GitHub Actions: `workflow_run`](https://docs.github.com/en/actions/reference/workflows-and-actions/events-that-trigger-workflows#workflow_run)（查阅：2026-08-31）

**课程决定：** workflow 使用三个逻辑阶段：

```text
verify all
  → assemble staging directory
  → upload one Pages artifact
  → deploy github-pages environment
```

verify 未全部通过时不组装、不上传。deploy job 不重新构建，避免验证的内容与发布的内容来自两次不同解析。

**实现证据：** `pages.yml` 只接收成功的 `Verify`，同时检查 `head_branch == 'main'` 与 `head_repository.full_name == github.repository`，并精确 checkout `workflow_run.head_sha`。build job 没有写权限；deploy job 才获得 `pages: write` 与 `id-token: write`。

### 5.2 预览在上传前合并

**课程决定：** staging 目录固定为：

```text
staging/
├── index.html                    # VitePress 输出
├── guide/
├── projects/
├── reference/
└── previews/
    ├── daily-rhythm-board/
    ├── ...
    └── neighborhood-exchange/
```

VitePress 先构建到 staging 根；每个 Flutter 项目使用自己的 `--base-href` 构建，再复制到 `staging/previews/<slug>/`。合并脚本遇到重复目标、缺失 `index.html`、slug 不在项目矩阵或旧目录残留时失败。仓库不提交 staging 和 `build/web`。

### 5.3 staging 验收必须检查真实 HTTP 行为

**课程决定：** 上传前分三层验收，三层证据不能互相替代：

1. 内容检查运行 frontmatter、链接、region、搜索验收与 VitePress build；
2. `release:smoke` 从 staging 根启动静态服务器，检查站点入口、项目索引、release manifest、13 个预览入口、hash URL 对应的 HTTP 入口、声明的 `sqlite3.wasm` / Worker 资源、状态码与 MIME；
3. 浏览器验收检查 320×720、768×900、1440×900 的关键任务、控制台、键盘、200% 文本、reduced motion、Semantics 和非白名单第三方请求。

**实现证据：** 当前自动 `release:smoke` 已覆盖第 2 层，但没有启动浏览器或阻断外网。本轮已人工检查“邻里资源交换站”的三档视口和 console；键盘、网络阻断和完整 production smoke 不能冒充自动化结果。

Pages deploy 完成后还要运行较短的 production smoke test，验证 Pages 实际 URL、base path、缓存更新、旧 Service Worker 和 hash 深链接。staging 通过不能替代真实托管检查。

### 5.4 缓存与回滚

**课程决定：** 构建器生成带内容 hash 的资源名时允许长期复用；入口 HTML 和项目 manifest 不假设永久缓存。发布 smoke test 必须确认新 commit 的 `CONTENT_VERSION` 与入口引用一致，避免 HTML 和旧资源混用。

Pages artifact 默认只保留 1 天，因此回滚锚点是“上一个成功部署的 commit SHA”，不是某个长期存在的 artifact。回滚时从该 SHA 重新运行同一锁定 workflow，重新构建、验收和部署；失败发布不覆盖当前成功站点。若以后需要立即切换旧二进制，必须另设有访问控制、校验值与保留策略的 release artifact，这不属于首版。

## 6. 发布质量、隐私、许可与供应链

### 6.1 发布质量是多种证据的交集

**课程决定：** release checklist 分为六组，任何一组失败都不发布：

1. 内容：frontmatter、知识依赖、链接、源码 region、搜索验收；
2. 代码：analyze、unit、Widget、Chrome 关键流程；
3. Web：release、base path、hash URL、MIME、资源完整性；
4. 界面：响应式、键盘、Semantics、200% 文本、reduced motion；
5. 治理：隐私、许可、来源、商标、第三方请求；
6. 交付：单一 artifact、commit 标识、生产 smoke test、回滚锚点。

性能检查保留首屏资源大小、关键任务 trace 和浏览器控制台警告作为趋势证据，不在共享 runner 上用一个毫秒阈值决定发布。

### 6.2 可访问性不能只靠扫描器

**官方事实：** WCAG 2.2 的 AA 一致性要求同时满足 A 与 AA 成功准则；自动化工具只能发现可程序判断的部分，键盘顺序、可理解性、放大后的任务完成和读屏体验仍需要人工检查。[WCAG 2.2 conformance](https://www.w3.org/TR/WCAG22/#conformance-reqs)（查阅：2026-08-31）

**课程决定：** 自动测试负责可重复断言，发布清单另记录人工键盘、读屏、对比度、窄屏和 200% 文本检查的日期与检查人。Web 项目通过 Semantics 测试不能写成“已达到 WCAG 2.2 AA”。

### 6.3 无追踪是可检查的网络边界

**课程决定：** 站点和预览不加载 analytics、广告、评论、社交 SDK、第三方字体或远程搜索。章节进度留在浏览器；只有读者主动点击 GitHub 源码、Issue 或其他外链时才离站。发布检查报告构建产物中的已知远程 URL，结合启用配置判断是否可达，并在浏览器层断言主流程没有发出非白名单第三方请求；不能把 loader 中未启用的 CDN 分支字符串直接判成运行时请求。若以后加入遥测，必须另写 ADR，列出字段、目的、保留期限、访问者和退出方式。

### 6.4 内容、代码、素材和商标分开记录

**官方事实：** CC BY 4.0 允许分享和改编，但要求适当署名、提供许可链接并说明修改；BSD 3-Clause 要求源码与二进制分发保留版权、许可条件和免责声明。[CC BY 4.0](https://creativecommons.org/licenses/by/4.0/) · [BSD 3-Clause](https://opensource.org/license/bsd-3-clause)（查阅：2026-08-31）

**官方事实：** Flutter 品牌指南规定 Flutter 名称与标志的使用方式，并要求避免暗示未经授权的官方关系。[Flutter brand guidelines](https://flutter.dev/brand)（查阅：2026-08-31）

**课程决定：** 正文与原创图示归 `LICENSE-CONTENT.md`，代码归 `LICENSE-CODE.md`；字体、图标、图片、fixture 来源和生成素材逐项记录作者、来源、许可、修改和使用位置。项目只使用可随仓库再分发的本地素材。页脚持续声明本站非 Google 官方教程，并保留 Flutter 商标归属。

### 6.5 供应链检查不等于自动升级

**官方事实：** `dart pub outdated` 报告 current、upgradable、resolvable 与 latest，用来区分锁文件可升级项、约束限制和最新版本；`dart pub upgrade --dry-run` 可以预览解析结果。它们不会替项目判断破坏性行为。[dart pub outdated](https://dart.dev/tools/pub/cmd/pub-outdated) · [dart pub upgrade](https://dart.dev/tools/pub/cmd/pub-upgrade)（查阅：2026-08-31）

**官方事实：** GitHub dependency review action 比较 Pull request 前后的依赖变化，可以按漏洞严重度和 SPDX 许可策略失败；未知许可会报告，但默认不因此失败。它依赖 GitHub dependency graph 已识别到的变化。官方生态表中 pnpm 支持静态传递依赖；pub 由 Dart community 维护，但 `pubspec.lock` 对应的静态传递依赖、Dependabot graph job 与自动提交目前都标为不支持。[dependency-review-action](https://github.com/actions/dependency-review-action) · [Dependency graph supported package ecosystems](https://docs.github.com/en/code-security/reference/supply-chain-security/dependency-graph-supported-package-ecosystems)（查阅：2026-08-31）

**课程决定：** 依赖 PR 同时保留四类证据：manifest 与 lockfile diff、`pub outdated` / `pnpm outdated` 报告、GitHub dependency review（仓库识别到对应生态时）、完整项目验证。pub 依赖不能依赖当前 dependency graph 自动补齐，仍要审查 `pubspec.lock` 与许可清单。新增包还要人工核对发布者、源码仓库、支持平台、许可、维护状态、传递依赖和原生构建要求。工具发现更新只创建审查入口，不自动合并 major upgrade。

**实现核对：** 当前 workflow 尚未运行 `actions/dependency-review-action`。`08-06` 可以讲配置与能力边界，但项目验收只能引用 lockfile diff、人工许可检查和现有完整验证，不能写成 dependency review 已通过。

## 7. 平台插件、权限与原生扩展

### 7.1 先看支持矩阵，再看 API 名字

**官方事实：** Flutter package 可以是纯 Dart package，也可以是 plugin package；plugin 通过 `pubspec.yaml` 的 `flutter.plugin.platforms` 声明 Android、iOS、Web、Windows、macOS、Linux 等实现。federated plugin 把面向应用的 package、platform interface 和各平台实现拆开，endorsed implementation 可以由应用自动取得。[Developing packages & plugins](https://docs.flutter.dev/packages-and-plugins/developing-packages)（查阅：2026-08-31）

**课程决定：** 评估插件时记录“包宣称支持的平台”和“本教程实际验证的平台”两列。pub.dev 显示 Web 支持，只说明包提供 Web 实现；它不能证明权限、浏览器兼容、无障碍、隐私和业务行为已在本站项目中通过。

### 7.2 Service 接缝隔离平台差异

**官方事实：** platform channel 允许 Dart 通过命名 channel 与宿主平台代码交换消息；`MethodChannel` 的调用是异步的，消息由 codec 编码，宿主侧需要为相同 channel 名注册处理器。Flutter 官方示例分别提供 Android、iOS、Windows、Linux、macOS 的宿主实现；Web 特定互操作通常由 Web plugin 或 Dart JS interop 完成。[Writing custom platform-specific code](https://docs.flutter.dev/platform-integration/platform-channels) · [Developing plugin packages](https://docs.flutter.dev/packages-and-plugins/developing-packages#plugin)（查阅：2026-08-31）

**课程决定：** 业务层只依赖 `ResourceShareService` 一类 Dart 接口。Web 使用 fixture / 浏览器实现；原生实现可以调用 plugin 或 platform channel；不支持的平台返回明确 capability，不抛到 UI 才判断。条件导入只出现在基础设施边界，Widget 不散布 `kIsWeb` 与平台分支。

### 7.3 权限是运行时状态，不是一次布尔值

**官方事实：** 不同平台的插件接入会涉及各自的 manifest、entitlement、Info.plist 或浏览器能力，权限声明与请求入口不能跨平台照搬。应用生命周期变化后，先前权限与外部资源状态可能已经改变。Flutter 的 `AppLifecycleState` 不保证收到所有状态通知，例如进程被终止时可能没有最后回调。[Flutter camera cookbook](https://docs.flutter.dev/cookbook/plugins/picture-using-camera) · [`AppLifecycleState`](https://api.flutter.dev/flutter/dart-ui/AppLifecycleState.html)（查阅：2026-08-31）

**课程决定：** 正文用 capability → request → result → resume recheck 的状态机讲权限，不写一个永久 `bool hasPermission`。`denied`、`restricted`、`permanentlyDenied` 等名字是适配层可能定义的业务结果，不是 Flutter 保证所有平台都提供的统一枚举；平台不支持、浏览器策略阻止和用户取消也要分开呈现。平台扩展只给最小接口、测试替身和官方入口，不把未在真机验证的代码列入 Web 项目验收。

### 7.4 Web 通过不能外推到原生

**课程决定：** 第八部分明确使用三种证据标签：

- `Web verified`：在本仓库 Chrome 与 Pages staging 子路径通过；production Pages 另记部署证据；
- `contract tested`：Dart 接口和 fake 行为通过，但未运行宿主实现；
- `native verification required`：需要 Android / iOS / desktop 构建、权限、设备或商店环境。

“邻里资源交换站”只使用第一类；平台分享、原生通知、相机上传和系统日历只作为 Service 扩展示意，不进入项目依赖和验收。

## 8. 升级与迁移策略

### 8.1 升级先读取迁移信息

**官方事实：** Flutter 官方建议用 `flutter upgrade` 更新当前 channel，并通过 release notes 与 breaking changes 索引检查行为变化。breaking change 页面列出受影响版本、迁移方法和可用工具；`dart fix --dry-run` 预览 analyzer 提供的自动修复，`dart fix --apply` 才会写文件。[Upgrading Flutter](https://docs.flutter.dev/install/upgrade) · [Flutter breaking changes](https://docs.flutter.dev/release/breaking-changes) · [dart fix](https://dart.dev/tools/dart-fix)（查阅：2026-08-31）

**课程决定：** Flutter / Dart 基线升级单独开 PR，按下面顺序进行：

1. 记录旧版本、目标版本、release notes 与 breaking changes；
2. 更新本地 SDK，先运行 `dart fix --dry-run`，不直接批量应用；
3. 运行 `flutter pub get`，审查根 lockfile 与生成配置 diff；
4. 先修 analyzer 和 compile error，再运行 13 个项目完整测试；
5. 重新构建所有 Web 预览，检查 service worker、renderer、base path、Wasm 与浏览器行为；
6. 更新 `site/reference/versioning.md` 一类集中迁移页，不把版本差异散到每章；
7. 记录仍需原生验证的项目，不用 Web 结果代替。

### 8.2 包升级按风险拆批

**课程决定：** 包升级分为三类 PR：

- patch / minor 且无公开破坏性说明：可按同一生态小批更新；
- major、代码生成器、数据库、路由、状态管理：一个主包及其必要配套依赖一批；
- 构建、发布、ChromeDriver、GitHub Action：独立 PR，并重新跑 staging / Pages 合同。

一次迁移只改变一组可解释输入。若 lockfile 同时变化大量无关包，先缩小 upgrade 范围；不能在同一 PR 里顺带重构业务代码和刷新视觉设计。

## 9. `08-01` 至 `08-07` 固定章节边界

### 9.1 `08-01` Workspace、依赖与配置

**requires**

- `ecosystem.package-evaluation`
- `project.anatomy`

**provides**

- `engineering.pub-workspace`
- `engineering.dependencies`
- `engineering.config`

**正文范围**

- pub workspace 的根与成员合同；
- `pubspec.yaml`、`pubspec.lock`、`package.json`、`pnpm-lock.yaml` 的不同责任；
- direct / transitive / dev dependency、asset 与生成文件边界；
- `--enforce-lockfile`、`--frozen-lockfile`；
- 编译时公开配置与秘密的边界。

**不提前讲**

- 不写完整 GitHub Actions YAML；
- 不讲 Pages artifact；
- 不实现原生平台插件。

**实践证据**

- 把“邻里资源交换站”加入根 workspace；
- 从仓库根与项目目录运行解析，证明使用同一 lockfile；
- 故意制造 manifest / lockfile 不一致，让 locked install 可重复失败；
- 检查 Web 产物，说明 `--dart-define` 不是秘密。

### 9.2 `08-02` 可复现 CI

**requires**

- `test.integration-web`
- `engineering.pub-workspace`

**provides**

- `engineering.ci`
- `engineering.affected-projects`
- `engineering.reproducibility`

**正文范围**

- 固定工具版本、最小 token 权限、action SHA；
- 受影响项目算法与全量发布门槛；
- cache 与 lockfile 的不同作用；
- matrix、端口、浏览器 profile 与输出隔离；
- Chrome / ChromeDriver 匹配；
- 失败 artifact。

**不提前讲**

- 不部署 Pages；
- 不把 PR 增量验证写成发布门槛；
- 不用性能绝对值决定普通 CI。

**实践证据**

- 项目私有文件变化只选择一个项目；
- 根 lockfile、共享脚本或 Flutter 版本变化选择 13 个项目；
- matrix job 在独立 runner 上复用固定端口而不冲突；同一 runner 并行时另行分配端口和 profile；
- 失败 job 上传可定位证据。
- `--name-status -z --find-renames` 与状态解析测试证明跨项目 rename 的旧、新项目都被选择。

### 9.3 `08-03` Flutter Web release

**requires**

- `storage.web-boundary`
- `performance.frame-budget`

**provides**

- `web.release-build`
- `web.base-href`
- `web.wasm-boundary`

**正文范围**

- release 产物、HTTP 静态服务器与开发服务器的差别；
- `<base>`、相对资源、Web engine 资源自托管、hash URL 与刷新；
- source map 的诊断与发布边界；
- JavaScript 基线、`--wasm`、Skwasm、兼容性和响应头；
- HTTP cache、Service Worker 与首版不做 PWA 的原因。

**不提前讲**

- 不写 Pages deploy job；
- 不把 `--wasm` 当默认加速开关；
- 不把 `--pwa-strategy=none` 写成跨版本永久命令。

**实践证据**

- 从 `/flutter-tutorial/previews/neighborhood-exchange/` 加载 release；
- 检查 `useLocalCanvasKit: true`，并在断网时加载 CanvasKit；
- 错误 base href 产生可观察失败，再恢复；
- hash 深链接刷新仍进入同一资源；
- 普通与 Wasm dry run 记录兼容差异；
- 检查当前版本没有有效 offline-first worker。

### 9.4 `08-04` GitHub Pages 发布

**requires**

- `engineering.ci`
- `web.release-build`
- `navigation.url-state`

**provides**

- `deployment.pages`
- `deployment.preview-layout`
- `deployment.rollback`

**正文范围**

- build / upload / deploy job 与最小权限；
- VitePress 根和 Flutter 预览的单一 staging 目录；
- artifact 合并、防旧文件、防覆盖；
- staging 与 production smoke test；
- 缓存更新、部署标识和从 commit SHA 重建回滚；
- path URL、404 rewrite、自定义域名只讲边界。

**不提前讲**

- 不加入 PWA；
- 不维护 PR Pages preview；`deploy-pages` 的 `preview` 当前不是公共稳定能力；
- 不把默认 1 天 artifact 当长期备份。

**实践证据**

- 一个 artifact 同时包含教程和 13 个预览；
- 缺失或重复 slug 阻止上传；
- 内容工具检查搜索，staging HTTP smoke 检查预览、hash URL 入口和 MIME；第三方请求由浏览器层另查；
- 记录上一个成功 commit SHA 并演练重新部署。

### 9.5 `08-05` 平台插件、权限与平台通道

**requires**

- `ecosystem.package-evaluation`
- `architecture.service`

**provides**

- `platform.plugin`
- `platform.permission`
- `platform.channel`
- `platform.web-limit`

**正文范围**

- package / plugin / federated plugin 与平台支持矩阵；
- Dart Service 接缝、条件实现和 capability；
- MethodChannel 的异步消息模型与 codec；
- 权限请求、拒绝、resume recheck；
- `Web verified`、`contract tested`、`native verification required`。

**不提前讲**

- 不提供未经真机验证的完整相机、推送或后台任务项目；
- 不让 Widget 直接调用 channel；
- 不把 `kIsWeb` 散到业务代码。

**实践证据**

- 一个可替换 `ResourceShareService`；
- Web fake 与不支持实现的 contract test；
- 原生 extension 只列接口、平台声明、权限状态和后续官方入口。

### 9.6 `08-06` 发布质量、隐私、许可与升级

**requires**

- `deployment.pages`
- `ecosystem.upgrade-boundary`

**provides**

- `release.quality`
- `release.privacy`
- `release.license`
- `release.migration`

**正文范围**

- 发布 checklist 与证据归属；
- 性能、可访问性、隐私和第三方请求；
- 内容 / 代码 / 素材许可与 Flutter 商标；
- dependency review、action SHA 与 package 人工审查；
- Flutter / Dart / package / workflow 的拆批升级；
- `outdated`、`upgrade --dry-run`、`dart fix --dry-run` 和迁移记录。

**不提前讲**

- 不承诺自动扫描能证明 WCAG、隐私或许可完全合规；
- 不自动合并依赖更新；
- 不把大版本迁移和业务重构放进同一批。

**实践证据**

- 一份能追溯到 commit 和检查人的发布清单；
- 一次模拟依赖升级，包含 lockfile diff、迁移说明、回归和回退；
- 构建产物第三方 URL 与许可清单检查。
- dependency review 只在 GitHub dependency graph 确实识别到依赖时补充；当前 workflow 尚未接入该 action。

### 9.7 `08-07` 统筹项目：邻里资源交换站

**requires**

- 本部分全部 `provides`

**provides**

- `project.neighborhood-exchange`

`08-07` 先给项目简报，再完整解释项目的 workspace 接入、应用架构、URL、本地数据、测试、release、Pages 子路径、质量清单和扩展边界。前六章只引用完成各自任务所需的小片段，不跨章拆讲同一项目结构。

## 10. 统筹项目：邻里资源交换站

### 10.1 使用场景与原创方向

项目路径固定为：

```text
examples/capstones/neighborhood_exchange/
```

公开 slug 与预览路径固定为：

```text
neighborhood-exchange
/flutter-tutorial/previews/neighborhood-exchange/
```

读者扮演社区共享点的值班成员，查看邻里发布的可借用物品与可预约技能时段，按片区、类别和可用状态筛选；可以发布一条本地资源，复制 hash 深链接，并以固定本地身份认领一条资源。界面方向采用“社区公告卡 + 取用标签”，不沿用档案浏览器、排期台或官方 sample 的信息结构和视觉模板。

### 10.2 固定数据合同

项目自带 48 条确定性 fixture，覆盖 6 个片区与 6 类资源：

| 维度 | 固定值 |
| --- | --- |
| 片区 | 青禾里、石桥巷、南园、河埠头、松影街、望塔坊 |
| 类别 | 工具、园艺、厨房、阅读、活动物料、技能时段 |
| 状态 | `available`、`reserved`、`completed` |
| 交接方式 | 社区共享柜、值班台、当面约定 |

每条 `ExchangeListing` 至少包含：

```text
id
origin
title
description
category
neighborhood
handoffMethod
availableWindow
totalQuantity
remainingQuantity
ownerId
ownerDisplayName
completedAt
createdAt
updatedAt
```

`ExchangeClaim` 保存 `listingId`、`claimantId` 与 `claimedAt`，并以 `(listingId, claimantId)` 作为唯一键。`available`、`reserved`、`completed` 是展示与筛选状态：`completedAt` 非空时为 `completed`，否则 `remainingQuantity == 0` 时为 `reserved`，其余为 `available`；数据库不再保存一份可能与数量冲突的状态字段。

fixture ID 固定为 `r-001` 至 `r-048`，`origin` 为 `fixture`；本地发布记录使用 `local-` 前缀 ID，`origin` 为 `local`。固定当前身份为 `local-neighbor`，显示名“林澄”；时间通过 `Clock` 注入，fixture 基准时刻固定，不读取执行当天。初次打开由 fixture Service 导入 Drift；后续发布与认领写入本地数据库。测试每次使用隔离数据库，不能读取浏览器已有状态。

静态站点没有共享后端。fixture 随构建发布，同一版本的任意浏览器都能从 `r-...` 深链接恢复同一条基础记录；本地发布记录和认领结果只存在于当前浏览器的本地数据库。链接不能携带整条本地记录，也不能让另一浏览器看到当前浏览器的认领状态。

### 10.3 领域规则

1. 标题 trim 后不能为空，最长 40 个 Unicode grapheme；说明最长 240 个 grapheme；数量为 1–9。
2. 发布者必须选择片区、类别、交接方式与预设可用时段；项目不处理自由时区和跨日重复规则。
3. `available` 且剩余数量大于 0 的条目才能认领；不能认领 `local-neighbor` 自己发布的条目。
4. 一次认领固定取用一份；同一身份对同一条目重复提交命中唯一键并返回既有结果，不重复扣减。最后一份被认领后，派生状态变为 `reserved`。
5. `completed` 只用于 fixture 历史记录，首版不提供完成、取消、转赠和纠纷流程。
6. 本地实现按顺序执行事务，能验证规则和持久化；它不能模拟真实多用户同时认领。正文必须把这项限制写在结果旁边。

### 10.4 功能合同

#### 浏览与 URL

- 搜索标题、说明与发布者；
- 按片区、类别、状态筛选；
- 按最近发布、最早可取、标题排序；
- 列表 / 紧凑网格切换；
- URL 保存 `q`、`neighborhood`、`category`、`status`、`sort`、`view`；
- 详情使用 `#/listings/:id`；非法 ID 显示可恢复页面并保留筛选；
- Back / Forward、刷新和复制到新标签后恢复同一状态。
- fixture 条目提供可跨浏览器恢复的深链接；复制 `local-...` 条目链接前明确提示“这条记录只保存在当前浏览器”，另一浏览器没有对应数据时显示本地数据边界和“返回全部资源”操作；

#### 发布

- 独立发布页或窄屏全屏表单；
- 字段错误与控件关联，首次提交失败后焦点移到错误摘要；
- 发布成功写入 Drift，进入新条目详情，并通过 live region 报告结果；
- 发布结果明确标记“仅此浏览器可见”，不使用“已同步”“社区已收到”或实时库存一类措辞；
- `APP_ENV=demo` 与 `CONTENT_VERSION=<commit-sha>` 可以作为公开编译时配置显示在“关于此预览”，不包含秘密。

#### 认领

- 详情明确显示剩余数量、交接方式、时间和发布者；
- 认领前提供结果摘要，不用只有颜色的状态提示；
- 运行中禁用重复提交，失败保留上下文并提供重试；
- 成功后更新列表、详情和本地持久化，刷新页面仍能看到结果；
- 认领结果明确标记“仅此浏览器的演示状态”；fixture 链接在另一浏览器仍恢复基础 `available` 状态，不承诺共享认领；
- 自己发布、已认领、已完成和未知条目分别给出原因。

#### 数据状态

- fixture 导入中的 loading；
- fixture Service 失败与 retry；
- 无匹配结果与清除筛选；
- 数据库打开失败的可理解错误；
- 浏览器只能使用不可靠持久化实现时显示边界说明；
- URL 非法值归一化，不让页面崩溃。
- 新浏览器打开不存在的 `local-...` 深链接时显示本地记录说明，不把它和普通 404 混为一类。

### 10.5 架构合同

```text
View
  ↓ intent             ↑ immutable UI state
Riverpod ViewModel / query providers
  ↓ command / query    ↑ Result / stream
ExchangeRepository（单一事实来源）
  ├── FixtureExchangeService（首次种子）
  └── ExchangeDatabase（Drift Web）
```

- `ExchangeRepository` 负责 fixture 导入、查询、发布、认领事务与模型映射；
- `BrowseExchangeViewModel` 负责 URL query、筛选和显示状态；
- `PublishListingViewModel` 负责草稿、验证与提交 command；
- `ListingDetailsViewModel` 负责详情和认领 command；
- go_router 负责 hash URL 与非法详情恢复；
- Web 数据库显式携带与 Drift 版本匹配的 `sqlite3.wasm` 和 `drift_worker.js`；
- 测试用内存 database / fake Service 通过 provider override 注入；
- 平台分享使用 `ResourceShareService` 接口，Web 实现只复制公开 URL。原生 share plugin 不进入首版依赖。

### 10.6 响应式与可访问性合同

| 条件 | 布局合同 |
| --- | --- |
| 320×720 | 单列结果，筛选在 bottom sheet；详情与发布为独立页面；底部主要操作不遮挡内容。 |
| 768×900 | 顶部筛选摘要 + 可折叠筛选面板；列表与详情按可用宽度切换。 |
| 1440×900 | 左侧筛选 rail、中间结果、右侧详情；三栏各自有明确 landmark 与标题。 |

键盘可以完成搜索、筛选、切换视图、打开详情、发布、修复验证错误、认领和返回。所有交互都有可见焦点；筛选结果数量、发布结果、认领结果和错误通过 Semantics / live region 报告；卡片整体不吞掉内部按钮；200% 文本下不截断主要操作；reduced motion 时去掉非必要位移；RTL 下方向性图标和布局保持正确。

项目不维护 golden，状态矩阵中 Visual 为 `not-applicable`，原因是第八部分重点是工程、发布和平台边界，视觉布局由响应式 Widget 测试和实际浏览器检查覆盖。

### 10.7 自动测试合同

#### Unit / Repository

- 发布字段边界与 grapheme 计数；
- 不能认领自己的、非 `available`、数量为 0 的条目；
- 重复认领幂等；
- 最后一份认领后转为 `reserved`；
- fixture 只导入一次；
- 发布和认领事务刷新后仍在；
- 固定 clock、排序、筛选和非法 query 归一化；
- fixture / database 失败映射为稳定 Result。

#### Provider / Widget

- loading、成功、空、失败、retry；
- URL 恢复筛选、排序、view 与详情；
- fixture 深链接在空数据库恢复；本地记录链接在当前数据库恢复，在空数据库显示本地数据边界；
- 复制本地记录链接前的警告，以及认领结果“仅此浏览器”的 Semantics；
- 320 / 768 / 1440 布局无 overflow；
- 200% 文本、RTL、reduced motion；
- 发布错误摘要与焦点；
- 认领成功 / 失败 live region 与重复点击；
- 自己发布、已认领、非法详情的恢复动作。

#### Chrome 关键流程

当前 integration test 覆盖一条连续主流程：

1. 从固定 fixture 启动并发布一条本地资源；
2. 关闭应用与数据库，再从本地详情 URL 打开，确认记录仍在；
3. 打开 `r-001` 并认领；
4. 再次关闭应用与数据库，从 `r-001` 详情 URL 打开；
5. 确认“我已认领”状态仍在。

fixture 跨浏览器恢复、本地链接在空数据库中的边界说明、URL query、三档布局、200% 文本、RTL、reduced motion、发布错误焦点与复制本地链接警告由 Unit / Widget 测试覆盖。Back / Forward、全新浏览器 profile、窄屏纯键盘和网络阻断仍属于人工浏览器验收，不应写成 integration test 已覆盖。

Chrome / ChromeDriver 版本、端口和基础工具信息会写入失败 artifact；当前脚本没有记录独立 profile 路径、fixture clock 或数据库文件位置。

#### Release / Pages

```powershell
flutter build web --release `
  --pwa-strategy=none `
  --no-web-resources-cdn `
  --base-href /flutter-tutorial/previews/neighborhood-exchange/ `
  --dart-define=APP_ENV=demo `
  --dart-define=CONTENT_VERSION=<commit-sha>
```

构建后从实际子路径检查 `index.html`、JavaScript、本地 CanvasKit、字体、`sqlite3.wasm`、`drift_worker.js`、hash 深链接与刷新持久化；再合并进单一 Pages staging。升级 Flutter 后首先复核 `--pwa-strategy` 与 `--no-web-resources-cdn` 的工具行为，命令不能无条件复制到新版本。

**实现证据：** 项目当前有 26 项 Unit / Repository / Drift / Widget 测试和 1 条 Chrome integration 主流程；`flutter analyze`、`flutter test`、Chrome integration、独立 release、13 项目全量 release、Pages staging smoke 均已通过。三档实际浏览器检查没有 console error / warning。production Pages 尚未部署验收。

### 10.8 明确不做

- 不做账号、真实身份、云同步或远程后端；
- 不做真实多用户并发认领、锁库存或冲突仲裁；
- 不做聊天、支付、押金、评价、举报和审核后台；
- 不做精确住址、地图、定位和路线；
- 不做图片上传、相机、系统相册或文件扫描；
- 不做推送、后台任务、原生日历或系统分享插件；
- 不做 PWA、离线安装、后台同步或 Web push；
- 不做 path URL、Pages 404 重写、自定义域名或 PR Pages preview；
- 不把 fixture 人名、片区或资源写成真实个人与真实地址。

### 10.9 项目验收矩阵

这张表定义项目要提供的证据，不表示每一行都由同一个自动脚本完成。Unit / Widget / integration、release HTTP smoke 与人工浏览器验收要分别署名，正文引用时也要说清证据来源。

| 项目 | 通过条件 |
| --- | --- |
| Analyze | 根 workspace 与项目 `flutter analyze` 无 warning / error。 |
| Unit | 规则、事务、fixture、Repository 与 query 风险覆盖。 |
| Widget | 主要状态、URL、响应式、文本缩放、RTL、Semantics 与焦点覆盖。 |
| Integration | Chrome 完成发布、深链接、认领与刷新持久化。 |
| Release Web | 实际 base href 构建，静态服务器加载全部资源。 |
| Pages staging | 单一 artifact 中路径正确，搜索与 13 个预览 smoke test 通过。 |
| Keyboard | 不使用鼠标完成主流程。 |
| Semantics | 控件名称、状态、错误和动态结果可读。 |
| Responsive | 320×720、768×900、1440×900 无横向溢出或任务中断。 |
| Text scale | 200% 下主要信息和操作可用。 |
| Motion | reduced motion 下不保留非必要位移和循环。 |
| Privacy | staging 阻断外网后主流程可用，无非白名单第三方请求。 |
| License | 代码、正文、素材和依赖许可记录完整。 |
| Visual | `not-applicable`；本项目不维护 golden。 |

## 11. 顺序依赖检查

```text
08-01 workspace / lock / config
  └── 08-02 reproducible CI
        ├── 08-03 Web release / base / Wasm / PWA boundary
        │     └── 08-04 Pages artifact / staging / rollback
        │            └── 08-06 release governance / migration
        └── 08-05 plugin / permission / channel boundary
                     └── 08-06 native evidence and upgrade boundary

08-01 ... 08-06
  └── 08-07 neighborhood-exchange
```

`08-03` 需要 `08-02` 已固定工具和可复现输入；`08-04` 必须先有可从子路径运行的 release；`08-06` 要基于已经定义的 artifact 和平台证据做发布判断。`08-05` 放在 Pages 之后，是为了先完成 Web 可证明的交付，再说明哪些能力需要越过 Web 边界。统筹项目最后把两条线合并，但只验收 Web 实现。

## 12. 写作时必须避免的误讲

| 误讲 | 正确边界 |
| --- | --- |
| “用了 workspace 就共享代码” | workspace 共享解析与工具上下文；成员只有显式依赖才共享代码。 |
| “workspace 成员只能用 path dependency 互相依赖” | 声明普通依赖即可；匹配的本地 workspace 成员会优先参与解析，版本仍须满足约束。 |
| “提交 lockfile 就完全可复现” | 还要固定 SDK、工具、action、命令、平台和外部下载；locked install 负责尽早暴露漂移。 |
| “`node-version: 22` 固定了精确 Node 版本” | 它固定主版本；补丁版本与 runner image 仍会变化。 |
| “cache 保证依赖一致” | cache 只复用下载，lockfile 与 hash 校验决定解析输入。 |
| “`--name-only` 能完整处理跨项目 rename” | rename 选择需要 `--name-status -z` 的旧、新路径；本仓库已按这个格式解析。 |
| “`--dart-define` 能藏 API key” | Web 客户端值可被检查，不能承载秘密。 |
| “`flutter build web` 成功就发布成功” | 还要验证 base path、HTTP、MIME、hash 深链接、缓存、数据库和 Pages。 |
| “`--wasm` 一定更快” | 需要兼容性、响应头、fallback 和固定 workload 测量。 |
| “浏览器缓存就是 PWA” | HTTP cache 与 Service Worker 是不同机制；首版不做 PWA。 |
| “Flutter 默认 service worker 是长期推荐” | 3.47.0 仍生成，但工具已弃用并计划移除；课程只写版本内过渡。 |
| “Pages artifact 可以长期回滚” | upload action 默认保留 1 天；首版从成功 commit SHA 重建。 |
| “staging HTTP smoke 已验证浏览器任务和第三方请求” | 当前 smoke 只检查 HTTP 入口、声明资源与 MIME；浏览器、键盘和网络边界另验。 |
| “Semantics 测试通过就是 WCAG AA” | 自动测试只是证据之一，还需要人工键盘、读屏、对比度和任务检查。 |
| “pub.dev 显示平台支持就算验证过” | 包声明与本站实测分开记录。 |
| “权限申请一次后永久有效” | 权限和 capability 会变化，resume 后需要重查。 |
| “Web 测试通过就证明原生插件可用” | 原生宿主实现、权限和设备行为需要独立平台证据。 |
| “outdated 有新版就应自动升级” | 先读迁移资料，按风险拆批，审查 lockfile 并跑受影响项目。 |
| “dependency review 已覆盖 pub workspace” | 当前 pub dependency graph 能力有限，workflow 也未接入该 action；保留 lockfile 与人工许可审查。 |
| “邻里资源交换站验证了真实并发” | 项目只验证本地顺序事务和 UI 状态，不模拟服务器竞争。 |
| “复制链接后别人能看到我发布或认领的内容” | fixture 深链接可跨浏览器恢复；本地发布与认领只在当前浏览器，本地链接在其他浏览器显示边界说明。 |

## 13. 正文参考资料清单

### Dart 与 pnpm

- [Pub workspaces](https://dart.dev/tools/pub/workspaces)（查阅：2026-08-31）
- [dart pub get](https://dart.dev/tools/pub/cmd/pub-get)（查阅：2026-08-31）
- [Package dependencies](https://dart.dev/tools/pub/dependencies)（查阅：2026-08-31）
- [dart pub outdated](https://dart.dev/tools/pub/cmd/pub-outdated)（查阅：2026-08-31）
- [dart pub upgrade](https://dart.dev/tools/pub/cmd/pub-upgrade)（查阅：2026-08-31）
- [dart fix](https://dart.dev/tools/dart-fix)（查阅：2026-08-31）
- [pnpm install](https://pnpm.io/cli/install)（查阅：2026-08-31）

### Git 与 VitePress

- [`git diff`](https://git-scm.com/docs/git-diff)（查阅：2026-08-31）
- [`git diff` format options](https://git-scm.com/docs/diff-options)（查阅：2026-08-31）
- [VitePress site config: `base`](https://vitepress.dev/reference/site-config#base)（查阅：2026-08-31）
- [VitePress deployment guide](https://vitepress.dev/guide/deploy#github-pages)（查阅：2026-08-31）

### Flutter Web 与平台扩展

- [Build and release a web app](https://docs.flutter.dev/deployment/web)（查阅：2026-08-31）
- [Flutter WebAssembly](https://docs.flutter.dev/platform-integration/web/wasm)（查阅：2026-08-31）
- [Flutter Web renderers](https://docs.flutter.dev/platform-integration/web/renderers)（查阅：2026-08-31）
- [Flutter URL strategies](https://docs.flutter.dev/ui/navigation/url-strategies)（查阅：2026-08-31）
- [Flutter issue #156910: deprecate default service worker](https://github.com/flutter/flutter/issues/156910)（查阅：2026-08-31）
- [Flutter `build_web.dart` 3.47.0](https://github.com/flutter/flutter/blob/3.47.0/packages/flutter_tools/lib/src/commands/build_web.dart)（查阅：2026-08-31）
- [Flutter `flutter_command.dart` 3.47.0](https://github.com/flutter/flutter/blob/3.47.0/packages/flutter_tools/lib/src/runner/flutter_command.dart)（查阅：2026-08-31）
- [Flutter `compile.dart` 3.47.0](https://github.com/flutter/flutter/blob/3.47.0/packages/flutter_tools/lib/src/web/compile.dart)（查阅：2026-08-31）
- [Flutter service worker generator 3.47.0](https://github.com/flutter/flutter/blob/3.47.0/packages/flutter_tools/lib/src/web/file_generators/flutter_service_worker_js.dart)（查阅：2026-08-31）
- [Using packages](https://docs.flutter.dev/packages-and-plugins/using-packages)（查阅：2026-08-31）
- [Developing packages & plugins](https://docs.flutter.dev/packages-and-plugins/developing-packages)（查阅：2026-08-31）
- [Writing custom platform-specific code](https://docs.flutter.dev/platform-integration/platform-channels)（查阅：2026-08-31）
- [AppLifecycleState API](https://api.flutter.dev/flutter/dart-ui/AppLifecycleState.html)（查阅：2026-08-31）
- [Upgrading Flutter](https://docs.flutter.dev/install/upgrade)（查阅：2026-08-31）
- [Flutter breaking changes](https://docs.flutter.dev/release/breaking-changes)（查阅：2026-08-31）

### GitHub Actions 与 Pages

- [Using custom workflows with GitHub Pages](https://docs.github.com/en/pages/getting-started-with-github-pages/using-custom-workflows-with-github-pages)（查阅：2026-08-31）
- [GitHub Actions: `workflow_run`](https://docs.github.com/en/actions/reference/workflows-and-actions/events-that-trigger-workflows#workflow_run)（查阅：2026-08-31）
- [actions/upload-pages-artifact](https://github.com/actions/upload-pages-artifact)（查阅：2026-08-31）
- [pinned upload-pages-artifact `action.yml`](https://github.com/actions/upload-pages-artifact/blob/56afc609e74202658d3ffba0e8f6dda462b719fa/action.yml)（查阅：2026-08-31）
- [actions/deploy-pages](https://github.com/actions/deploy-pages)（查阅：2026-08-31）
- [actions/setup-node advanced usage](https://github.com/actions/setup-node/blob/main/docs/advanced-usage.md)（查阅：2026-08-31）
- [GitHub-hosted runner images](https://github.com/actions/runner-images)（查阅：2026-08-31）
- [Security hardening for GitHub Actions](https://docs.github.com/en/actions/security-for-github-actions/security-guides/security-hardening-for-github-actions)（查阅：2026-08-31）
- [dependency-review-action](https://github.com/actions/dependency-review-action)（查阅：2026-08-31）
- [Dependency graph supported package ecosystems](https://docs.github.com/en/code-security/reference/supply-chain-security/dependency-graph-supported-package-ecosystems)（查阅：2026-08-31）

### Web、可访问性与许可

- [MDN `<base>`](https://developer.mozilla.org/en-US/docs/Web/HTML/Reference/Elements/base)（查阅：2026-08-31）
- [MDN HTTP caching](https://developer.mozilla.org/en-US/docs/Web/HTTP/Guides/Caching)（查阅：2026-08-31）
- [Service Workers Level 1](https://www.w3.org/TR/service-workers/)（查阅：2026-08-31）
- [WCAG 2.2](https://www.w3.org/TR/WCAG22/)（查阅：2026-08-31）
- [ChromeDriver version selection](https://developer.chrome.com/docs/chromedriver/downloads/version-selection)（查阅：2026-08-31）
- [Chrome for Testing](https://googlechromelabs.github.io/chrome-for-testing/)（查阅：2026-08-31）
- [CC BY 4.0](https://creativecommons.org/licenses/by/4.0/)（查阅：2026-08-31）
- [BSD 3-Clause](https://opensource.org/license/bsd-3-clause)（查阅：2026-08-31）
- [Flutter brand guidelines](https://flutter.dev/brand)（查阅：2026-08-31）

## 14. 写作前的实现核对

### 已确认

1. `tool/projects.json` 是 13 个项目的唯一清单，受影响项目检测、独立构建、staging 合并和 smoke 共用它；重复 slug、路径和项目数量都有校验。
2. “邻里资源交换站”的 48 条 fixture、claim 幂等事务、Drift schema、URL query、本地数据边界与 `CONTENT_VERSION` 已实现并通过现有测试。
3. 受影响项目读取使用 `--name-status -z --find-renames`，7 项 Node 测试覆盖 rename 两端、共享输入、站点输入与未知项目回退。
4. ChromeDriver 安装脚本按 Chrome build 查询 Chrome for Testing 元数据，验证 job 记录完整版本和固定端口。
5. 两个 workflow 已固定 action SHA；PR 运行受影响项目，main 运行全量项目，Pages 只消费成功的同仓库 main Verify。
6. 13 个 release Web 构建、单一 Pages staging 合并、声明的 Wasm / Worker 资源和 MIME smoke 已通过；actionlint 也已通过。
7. Flutter 3.47.0 的 release 产物使用本地 CanvasKit，`flutter_service_worker.js` 为 0 字节；升级 SDK 时仍需重新检查。

### 正文必须保留的未决项

1. 首次 GitHub Pages 部署后检查 production URL、`sqlite3.wasm` / Worker / 字体的真实响应、缓存更新、旧 Service Worker 注销和 hash 深链接刷新。
2. 浏览器层补齐网络阻断、纯键盘与 Back / Forward 的可重复验收；当前 `release:smoke` 不包含这些检查。
3. 若接入 dependency review，先确认仓库 dependency graph 对 pnpm 和 pub 的实际快照，再决定 job 范围；pub 继续保留 lockfile diff 与人工许可清单。
4. 若课程要把 Node 也写成精确工具输入，把 `node-version: 22` 改成完整版本；否则明确它只是 Node 22 基线。
5. ADR-0017 已记录单一 Pages artifact 的架构决定，但尚未记录固定 action SHA、失败保留与按 commit SHA 重建的操作细节；这些内容先放教程与发布清单，若成为长期治理合同再补 ADR。
