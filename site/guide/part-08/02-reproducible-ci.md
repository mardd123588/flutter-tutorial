---
title: 可复现 CI 与受影响项目
description: 从固定版本、锁文件和明确输入构建 GitHub Actions 验证链，并用可测试规则选择 Pull Request 受影响的 Flutter 项目。
part: 8
order: 2
kind: concept
requires:
  - test.integration-web
  - engineering.pub-workspace
provides:
  - engineering.ci
  - engineering.affected-projects
  - engineering.reproducibility
status: verified
---

# 可复现 CI 与受影响项目

CI 的价值是让同一组输入在干净环境里得到同一类结果。这里的“可复现”指锁定课程依赖和验证步骤，不承诺两次构建得到字节完全相同的产物。它需要固定工具版本、使用锁文件安装、记录实际命令，并把失败证据留给下一次排查。缓存和并行只缩短等待时间。

## 先列出会改变结果的输入

本仓库把变化分成三类：

| 输入 | 验证范围 |
| --- | --- |
| 项目目录内的 Dart、测试、资产、`web/`、成员 `pubspec.yaml` | 当前项目 |
| 根 `pubspec.yaml`、`pubspec.lock`、lint、CI 与 release 工具 | 13 个项目 |
| `site/`、`package.json`、`pnpm-lock.yaml`、站点工具 | VitePress 站点 |

未知的新 `examples/` 路径按全量处理。保守多跑一些，比漏掉一个尚未登记的项目安全。

Pull Request 可以按 diff 缩小项目矩阵；`main` 和发布固定跑 13 个项目。增量验证只优化反馈速度，不降低发布门槛。

## 重命名要保留两侧路径

受影响项目选择器接收规范化路径，再判断路径属于哪个项目。Git 读取层使用：

```text
git diff --name-status -z --find-renames <base>...<head>
```

`-z` 用 NUL 分隔字段，文件名中的空格和换行不会破坏解析。`R100` 或 `C...` 记录携带旧、新两条路径，两侧都要交给选择器。只读 `--name-only` 可能丢掉重命名前的项目，使跨目录移动漏跑源项目。

选择器本身保持纯函数：

```js
export function selectAffectedProjects(changedPaths, projects) {
  const normalized = changedPaths.map(normalizeGitPath).filter(Boolean);
  const full = normalized.some((path) =>
    allProjectInputs.includes(path) ||
    allProjectPrefixes.some((prefix) => path.startsWith(prefix)) ||
    (path.startsWith('examples/') &&
      !projects.some((project) => isWithin(path, project.path)))
  );

  const affected = full
    ? projects
    : projects.filter((project) =>
        normalized.some((path) => isWithin(path, project.path))
      );
  return { full, projects: affected };
}
```

纯函数让测试直接覆盖项目私有变化、根 lockfile、workflow、站点文件、未知项目和跨项目重命名。本仓库当前有 7 项 Node 测试固定这些规则。

## Workflow 固定版本和权限

GitHub Actions 的默认权限从 `contents: read` 开始。验证 job 不需要写仓库、Pages 或 OIDC token。第三方 action 使用完整 commit SHA，例如：

```yaml
permissions:
  contents: read

steps:
  - uses: actions/checkout@11d5960a326750d5838078e36cf38b85af677262
  - uses: actions/setup-node@49933ea5288caeca8642d1e84afbd3f7d6820020
    with:
      node-version: 22
  - uses: subosito/flutter-action@1a449444c387b1966244ae4d4f8c696479add0b2
    with:
      flutter-version: 3.47.0
      channel: stable
```

完整 SHA 是不可变引用，但仍要审查来源和更新 diff。版本更新放在独立依赖 PR 中，不在修业务功能时顺便换 action、Flutter 和 Node。

这份 workflow 的固定程度也有边界：`node-version: 22` 只固定 Node 主版本，`ubuntu-24.04` 的 runner image 会继续更新。Flutter、Dart、pnpm、VitePress、锁文件和 action commit 已固定；若发布要求精确 Node 补丁版本或受控系统镜像，还要把这些输入单独固定并记录。

## 项目矩阵隔离执行环境

`scope` job 先检查站点并输出 JSON matrix。`projects` job 再为每个 slug 启动独立 runner：

```yaml
strategy:
  fail-fast: false
  matrix: ${{ fromJSON(needs.scope.outputs.matrix) }}

steps:
  - name: Resolve locked Flutter workspace
    run: flutter pub get --enforce-lockfile
  - name: Install matching ChromeDriver
    run: node tool/ci/install_chromedriver.mjs
  - name: Verify ${{ matrix.slug }}
    run: node tool/ci/verify_project.mjs --project "${{ matrix.slug }}" --integration --build
```

每个 matrix 项都在单独虚拟机中，因此它们可以使用相同的 4444 和 7357 端口；进程、浏览器 profile、数据库和输出目录不会跨 runner 共享。若在同一 runner 内并行多个浏览器任务，端口和 profile 就必须显式区分。

单个项目按 `analyze → test → Chrome integration → release build` 执行。便宜检查先失败，能减少无意义的浏览器启动和构建。

## ChromeDriver 要匹配 Chrome build

Chrome for Testing 为 M115 及后续版本提供 build 对应的下载元数据。脚本先读取 Chrome 完整版本，取前三段 build，再下载同 build 的 ChromeDriver：

```text
Chrome 151.0.7922.174
        └──── build ────┘
ChromeDriver 151.0.7922.174
```

只把任意 `chromedriver` 放进 `PATH` 不够。版本不兼容时，测试会在进入 Flutter 应用之前失败。

## 失败 artifact 保存复现入口

验证脚本把环境和每一步输出写进 `build/ci-logs/<slug>/`：

- commit、项目 slug、Flutter、Dart、Chrome 与 ChromeDriver 版本；
- driver 与 Web 端口；
- analyze、test、integration 的完整命令、输出和退出码；
- ChromeDriver 日志与失败截图；
- release 构建失败信息。

只有失败时上传该目录，保留 7 天。Artifact 用于诊断，不是可信发布输入；Pages workflow 会从已经验证的 commit 重新构建。

当前脚本没有单独导出浏览器 console、网络请求或 HTTP 响应头。需要排查这三类问题时，应增加对应采集步骤，不能把 ChromeDriver 日志和命令输出当成这些证据。

## 可验证任务

运行选择器测试：

```powershell
pnpm projects:check
```

再为下面六类变化写出期望矩阵：项目私有 Dart 文件、跨项目重命名、根 `pubspec.lock`、`tool/release/`、纯站点章节、未登记的新项目。用 `node tool/ci/affected_projects.mjs --base <sha> --head <sha>` 检查真实 diff 输出。

最后打开 `.github/workflows/verify.yml`，标出每个 job 的 token 权限、工具版本、锁文件安装、浏览器隔离方式和失败 artifact。任何一项只能从“当前 runner 恰好如此”推断出来，都还没有成为可复现合同。

## 复习线索

- 可复现输入包括工具版本、manifest、lockfile、脚本、环境和 fixture。
- PR 可以按受影响项目增量验证，`main` 与发布仍跑全量。
- 重命名读取要保留旧、新两条路径。
- Matrix runner 天然隔离进程；同一 runner 内并行仍要分端口和 profile。
- Cache 加速下载，失败 artifact 帮助复现，两者都不是发布产物。

## 参考资料

- [Security hardening for GitHub Actions](https://docs.github.com/en/actions/security-for-github-actions/security-guides/security-hardening-for-github-actions)（查阅：2026-08-31）
- [Using a matrix for your jobs](https://docs.github.com/en/actions/using-jobs/using-a-matrix-for-your-jobs)（查阅：2026-08-31）
- [Caching dependencies to speed up workflows](https://docs.github.com/en/actions/using-workflows/caching-dependencies-to-speed-up-workflows)（查阅：2026-08-31）
- [Store and share data with workflow artifacts](https://docs.github.com/en/actions/using-workflows/storing-workflow-data-as-artifacts)（查阅：2026-08-31）
- [ChromeDriver version selection](https://developer.chrome.com/docs/chromedriver/downloads/version-selection)（查阅：2026-08-31）
- [Chrome for Testing](https://googlechromelabs.github.io/chrome-for-testing/)（查阅：2026-08-31）
