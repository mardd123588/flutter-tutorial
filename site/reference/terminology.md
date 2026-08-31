---
title: 术语约定
description: 教程中 Flutter、测试、数据与布局术语的统一写法。
---

# 术语约定

正文保留 Flutter 和生态中的正式名称，不为了中文顺口而改写类型名。首次出现的术语由对应章节解释，这里只负责统一写法和检索入口。

## 框架与生态名称

| 写法 | 说明 |
| --- | --- |
| `Widget`、`Element`、`RenderObject` | 指 Flutter 三类运行时对象；不翻译成“组件、元素、渲染对象”后混用 |
| `BuildContext` | 指 Element 在 Widget API 中的句柄；代码类型名保持原样 |
| `Riverpod`、`Drift`、`go_router` | 使用项目或包的正式拼写 |
| `Semantics` | 指 Flutter 语义系统或对应 Widget；泛指能力时写“语义” |
| `Sliver` | 指 sliver 协议和组件族；不与普通滚动列表互换 |

## 测试与发布

正文统一使用“单元测试”“Widget 测试”“Chrome 集成测试”“golden 测试”和“Web release 构建”。`integration_test`、`flutter drive`、`flutter test` 等包名与命令保持代码写法。

“Chrome 集成测试”只表示真实 Chrome 中由 WebDriver 驱动的关键流程。它不自动证明所有 URL、键盘、视觉、权限或生产托管边界已经通过。Web release 构建也只证明产物生成；实际子路径、资源 MIME 和交互仍需单独验收。

## 数据与布局

- 泛指固定测试数据时写小写 `fixture`；`FixtureWorkshopCatalogService` 等类名保持源码拼写。
- “响应式布局”表示界面依据可用空间重排；“平台适配”表示输入方式、平台惯例和能力边界的处理。
- “本地”必须说明范围：进程内、当前浏览器数据库、设备或仓库 fixture 不是同一层边界。
- `fake`、`mock`、`stub` 只在需要区分测试替身职责时使用，不互相代换。

版本号和依赖边界见[适用版本](/reference/versions)，上线前检查项见[发布清单](/reference/release-checklist)。
