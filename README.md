# Flutter 框架教程

一套面向已有 Dart 或其他编程语言基础读者的中文 Flutter 教程。正文按知识依赖排列，难点解释运行机制和排错方法；实践项目提供可运行、可测试的 Web 证据。

教程以 Flutter 3.47.0 和 Dart 3.13.0 为首版基线。首版八部分共 58 章，配有 8 个统筹项目和 5 个重点项目；正文与 13 个项目均已完成，并通过仓库当前定义的检查。production Pages 的首次验收状态单独记录在发布清单中。

## 内容入口

- [顺序学习路线](site/reference/roadmap.md)
- [知识索引](site/reference/knowledge-index.md)
- [实践项目状态](site/projects/index.md)
- [术语约定](site/reference/terminology.md)
- [发布清单](site/reference/release-checklist.md)
- [适用版本](site/reference/versions.md)
- [首版内容与验收规格](https://github.com/mardd123588/flutter-tutorial/issues/1)

公开正文位于 `site/`，统筹项目位于 `examples/capstones/`，重点项目位于 `examples/focus/`。内部研究和架构决定保存在 `docs/`，不会随站点发布。

## 本地检查

```powershell
flutter pub get
flutter analyze
pnpm install --frozen-lockfile
pnpm check
```

运行教程站：

```powershell
pnpm docs:dev
```

每个 Flutter 项目有自己的 README、测试和 Web 入口，可以单独打开。项目之间不共享业务代码或 UI 包。

## 许可

教程正文与原创图示采用 [CC BY 4.0](LICENSE-CONTENT.md)，代码采用 [BSD 3-Clause](LICENSE-CODE.md)。本项目不是 Google 官方教程；Flutter 和相关标志是 Google LLC 的商标。
