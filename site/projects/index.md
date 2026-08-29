---
title: 实践项目
description: 8 个统筹项目和 5 个重点项目的实现与测试状态。
---

# 实践项目

每个项目都是独立 Flutter 应用，不共享业务代码或 UI 包。正式项目需要通过 analyze、单元测试、Widget 测试、Chrome 集成测试和 release Web 构建；键盘、语义、响应式、文本缩放与减少动画还要单独验收。

## 项目进度

| 项目 | 类型 | 章节 | 实现状态 |
| --- | --- | --- | --- |
| 今日节奏板 | 统筹 | 01-07 | `passing` |
| 票券排版器 | 重点 | 02-02 | `not-started` |
| 小型展览编辑器 | 统筹 | 02-07 | `not-started` |
| 可排序值班板 | 重点 | 03-03 | `not-started` |
| 植物照护台 | 统筹 | 03-07 | `not-started` |
| 即时书目检索 | 重点 | 04-04 | `not-started` |
| 城市活动雷达 | 统筹 | 04-08 | `not-started` |
| 路线分享卡 | 重点 | 05-03 | `not-started` |
| 场馆导览册 | 统筹 | 05-07 | `not-started` |
| 社区工坊排期台 | 统筹 | 06-08 | `not-started` |
| 长卷时间轴 | 重点 | 07-06 | `not-started` |
| 数字档案浏览器 | 统筹 | 07-07 | `not-started` |
| 邻里资源交换站 | 统筹 | 08-07 | `not-started` |

`passing` 表示项目已有可运行实现，且当前适用的发布检查全部通过。当前只有今日节奏板达到这个状态。

## 今日节奏板验收状态

| Analyze | Unit | Widget | Integration | Release Web | Keyboard | Semantics | Responsive | Text scale | Motion | Visual |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| `passing` | `passing` | `passing` | `passing` | `passing` | `passing` | `passing` | `passing` | `passing` | `not-applicable` | `not-applicable` |

`Motion` 为 `not-applicable`：这个项目没有补间、循环或依赖位移的过渡，选择结果立即更新。`Visual` 为 `not-applicable`：首版规格只要求票券排版器、场馆导览册和长卷时间轴维护确定性 golden。其余 12 个项目的验收列目前均为 `not-started`。

完整项目任务、风险和浏览器关键流程见 [首版规格 #1](https://github.com/mardd123588/flutter-tutorial/issues/1)。
