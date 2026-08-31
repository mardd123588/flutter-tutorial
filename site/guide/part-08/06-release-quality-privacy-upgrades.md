---
title: 发布质量、隐私、许可与升级
description: 把自动检查、人工验收、隐私、许可和依赖迁移整理成可追溯发布记录，并为失败保留回退入口。
part: 8
order: 6
kind: concept
requires:
  - deployment.pages
  - ecosystem.upgrade-boundary
provides:
  - release.quality
  - release.privacy
  - release.license
  - release.migration
status: verified
---

# 发布质量、隐私、许可与升级

发布清单要回答“哪一个 commit 经过了哪些检查，由谁在什么环境确认”。一个绿色 workflow 只能覆盖已经自动化的断言。键盘流程、读屏体验、许可来源、隐私边界和平台权限仍要有对应证据。

## 先分配证据归属

| 风险 | 自动检查 | 人工或平台检查 |
| --- | --- | --- |
| 编译、lint、单元测试 / Widget 测试 | CI 命令与日志 | 失败时审查变更意图 |
| URL 查询、详情与恢复 | Widget 测试、覆盖对应任务的 Chrome 集成测试 | Back / Forward、刷新与非法 URL 实际流程 |
| 资产、MIME、发布子路径 | staging smoke | 真实生产地址抽查 |
| 键盘、Semantics、200% 文本 | Widget / Semantics 测试 | 键盘与读屏实际流程 |
| 性能 | 固定 profile workload | DevTools trace 与设备解释 |
| 隐私与第三方请求 | 构建扫描、阻断外网、网络断言 | 数据字段、用途与保留政策审查 |
| 许可与商标 | 文件存在、依赖清单 | 素材来源与条款适用性判断 |
| 原生权限和 plugin | Dart contract test | 真机、权限弹窗、宿主配置 |

自动测试覆盖 Semantics，不等于已经达到 WCAG 2.2 AA。它能固定控件名称、状态和 live region；阅读顺序、对比度、缩放后的任务完成和辅助技术组合仍需实际检查。

## 一份发布记录对应一个 commit

发布记录至少保存：

```text
commit SHA
Flutter / Dart / Node / pnpm 版本
13 个项目验证结果
VitePress build 与 Pages staging smoke
Chrome / ChromeDriver 版本
人工键盘、读屏、窄屏、200% 文本检查人和日期
已知限制
回滚 commit SHA 与重建命令
```

记录实际通过的项目和命令，避免写“全面验证”这类无法追溯的结论。人工项写检查人和日期，不用一个永久勾选框覆盖后续版本。

## 隐私从“不收集”开始

本站首版不加载 analytics、广告、评论、社交 SDK、远程搜索或第三方字体。学习进度与示例数据留在浏览器；读者主动打开 GitHub 链接时才离开站点。

构建产物中的 URL 扫描能发现已知远程地址，但不能单独判断运行时是否请求。Flutter loader 可能包含未启用 CDN 分支。发布检查要结合：

- 构建配置是否启用远程资源；
- 阻断外网后主流程是否可用；
- 浏览器网络记录是否出现非白名单请求；
- 应用是否把用户输入写进 URL、日志或第三方服务。

以后加入遥测前，先写 ADR，列出字段、目的、保留期限、访问者和退出方式。没有这些信息，不应先接 SDK 再补隐私说明。

## 内容、代码和素材分别记许可

本仓库使用两份许可：正文与原创图示为 CC BY 4.0，代码为 BSD 3-Clause。第三方字体、图标、图片、fixture 来源和生成素材还要逐项记录：

```text
作者 / 发布者
原始来源
许可名称与版本
是否修改
仓库中的使用位置
```

“网上可以下载”不是再分发许可。Package license 也要连同传递依赖检查。Flutter 名称与标志按官方品牌指南使用，页脚继续声明本站不是 Google 官方教程。

## 依赖更新先看四份证据

依赖 PR 保存：

1. manifest 与 lockfile diff；
2. `dart pub outdated`、`pnpm outdated` 报告；
3. GitHub dependency review 能识别到的生态变化；
4. 受影响项目或全量验证结果。

Dependency review 是补充证据。仓库结构、生态识别或 workspace 变化可能让它看不见某些依赖，不能据此省略 lockfile diff 和人工检查。

当前 workflow 尚未接入 `actions/dependency-review-action`。GitHub dependency graph 对 pnpm 能提供较完整的静态依赖信息，对 pub 的传递依赖与自动提交能力仍有限；因此本仓库当前依赖审查以 manifest / lockfile diff、`outdated` 报告、许可检查和项目验证为准。以后接入 dependency review 时，也只能把它作为仓库实际识别到的依赖变化证据。

新增包还要检查发布者、源码仓库、支持平台、许可、维护状态、传递依赖和原生构建要求。Package 更新工具可以创建审查入口，不自动批准 major upgrade。

## Flutter 与业务变更分批

Flutter / Dart 基线升级使用独立 PR：

```powershell
flutter --version
dart pub outdated
dart pub upgrade --dry-run
dart fix --dry-run
```

建议顺序：

1. 更新 SDK 与工具版本声明；
2. locked install，保存解析 diff；
3. 运行 analyze 和 `dart fix --dry-run`，人工决定迁移；
4. 重新生成代码，检查 generator diff；
5. 跑 13 个项目的单元测试、Widget 测试、Chrome 集成测试和 Web release 构建；
6. 重组 Pages staging，检查弃用参数与产物结构；
7. 记录破坏性变化、人工修改和回退 SHA。

业务重构不要混进同一 PR。否则失败时难以区分是 SDK 行为改变、依赖迁移还是功能代码导致。

`--pwa-strategy=none` 是本仓库特别需要复核的版本边界。Flutter 升级后，先查看工具帮助、变更记录和生成产物；参数移除时更新构建与 Service Worker 验收，不能为了保留旧命令而固定过时 SDK。

## Action SHA 也属于依赖

Workflow 中的 action 会执行代码，并能读取 job 获得的权限。完整 SHA 固定了内容版本，更新时仍要审查：

- 上游仓库和发布说明；
- 旧、新 SHA 的 diff；
- action 输入、Node runtime 和权限变化；
- fork Pull Request 与 secret 边界；
- 验证和 Pages workflow 的回归结果。

Action 更新与 Flutter / Node 大版本升级分开，失败时更容易定位。

## 可验证任务

为当前仓库填写一份发布记录，引用真实 commit、命令和 artifact 路径。至少包含自动验证、键盘、Semantics、三档宽度、200% 文本、外部请求、许可和回滚 SHA。

再选择一个小版本依赖做模拟升级：保存 `outdated`、dry run、manifest / lockfile diff、受影响项目和回退方式。不要提交升级；任务重点是形成可审查证据。

## 复习线索

- 自动化、人工检查和真机验证各自证明不同风险。
- 发布记录必须绑定 commit、环境、检查人、限制和回滚入口。
- URL 扫描只能发现线索，真实网络行为仍要运行时验证。
- 内容、代码、素材、依赖和商标有不同许可责任。
- SDK、package、action 与业务重构分批升级。
- Dry run 提供迁移预览，不替代测试和产物验收。

## 参考资料

- [WCAG 2.2](https://www.w3.org/TR/WCAG22/)（查阅：2026-08-31）
- [Privacy on the web](https://developer.mozilla.org/en-US/docs/Web/Privacy)（查阅：2026-08-31）
- [CC BY 4.0](https://creativecommons.org/licenses/by/4.0/)（查阅：2026-08-31）
- [BSD 3-Clause License](https://opensource.org/license/bsd-3-clause)（查阅：2026-08-31）
- [Flutter brand guidelines](https://flutter.dev/brand)（查阅：2026-08-31）
- [`dart pub outdated`](https://dart.dev/tools/pub/cmd/pub-outdated)（查阅：2026-08-31）
- [`dart pub upgrade`](https://dart.dev/tools/pub/cmd/pub-upgrade)（查阅：2026-08-31）
- [`dart fix`](https://dart.dev/tools/dart-fix)（查阅：2026-08-31）
- [GitHub dependency review](https://docs.github.com/en/code-security/concepts/supply-chain-security/dependency-review)（查阅：2026-09-01）
- [Security hardening for GitHub Actions](https://docs.github.com/en/actions/security-for-github-actions/security-guides/security-hardening-for-github-actions)（查阅：2026-08-31）
