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
| 票券排版器 | 重点 | 02-02 | `passing` |
| 小型展览编辑器 | 统筹 | 02-07 | `passing` |
| 可排序值班板 | 重点 | 03-03 | `passing` |
| 植物照护台 | 统筹 | 03-07 | `passing` |
| 即时书目检索 | 重点 | 04-04 | `passing` |
| 城市活动雷达 | 统筹 | 04-08 | `passing` |
| 路线分享卡 | 重点 | 05-03 | `passing` |
| 场馆导览册 | 统筹 | 05-07 | `passing` |
| 社区工坊排期台 | 统筹 | 06-08 | `passing` |
| 长卷时间轴 | 重点 | 07-06 | `not-started` |
| 数字档案浏览器 | 统筹 | 07-07 | `not-started` |
| 邻里资源交换站 | 统筹 | 08-07 | `not-started` |

`passing` 表示项目已有可运行实现，且当前适用的发布检查全部通过。当前完成到第六部分，共有十个项目达到这个状态。

## 今日节奏板验收状态

| Analyze | Unit | Widget | Integration | Release Web | Keyboard | Semantics | Responsive | Text scale | Motion | Visual |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| `passing` | `passing` | `passing` | `passing` | `passing` | `passing` | `passing` | `passing` | `passing` | `not-applicable` | `not-applicable` |

`Motion` 为 `not-applicable`：这个项目没有补间、循环或依赖位移的过渡，选择结果立即更新。`Visual` 为 `not-applicable`：首版规格只要求票券排版器、场馆导览册和长卷时间轴维护确定性 golden。

## 票券排版器验收状态

| Analyze | Unit | Widget | Integration | Release Web | Keyboard | Semantics | Responsive | Text scale | Motion | Visual |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| `passing` | `passing` | `passing` | `passing` | `passing` | `passing` | `passing` | `passing` | `passing` | `not-applicable` | `passing` |

Unit 与 Widget 共 6 项；Chrome 关键流程验证票面预设切换。浏览器检查覆盖 320×720、768×900、1440×900，键盘可用 Tab 和 Enter 切换票面；320×720 的 Widget 测试同时使用 200% 文本缩放。项目维护标准票的确定性 golden。

## 小型展览编辑器验收状态

| Analyze | Unit | Widget | Integration | Release Web | Keyboard | Semantics | Responsive | Text scale | Motion | Visual |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| `passing` | `passing` | `passing` | `passing` | `passing` | `passing` | `passing` | `passing` | `passing` | `not-applicable` | `not-applicable` |

Unit 与 Widget 共 9 项；Chrome 关键流程先复现年份错误，再修正并新增展品。浏览器检查覆盖 320×720、768×900、1440×900，并实际验证筛选、Ctrl+N、Ctrl+S、焦点和错误状态。语义测试覆盖选中展品的 button / selected flags 与状态 live region。`Motion` 为 `not-applicable`：项目没有补间或循环动画。`Visual` 为 `not-applicable`：首版规格不要求该项目维护 golden。

## 可排序值班板验收状态

| Analyze | Unit | Widget | Integration | Release Web | Keyboard | Semantics | Responsive | Text scale | Motion | Visual |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| `passing` | `passing` | `passing` | `passing` | `passing` | `passing` | `passing` | `passing` | `passing` | `not-applicable` | `not-applicable` |

Unit 与 Widget 共 7 项；Chrome 关键流程验证备注跟随同一成员完成重排。浏览器检查覆盖 320×720、768×900、1440×900，并实际验证拖动替代按钮、边界禁用与状态回执。`Motion` 为 `not-applicable`：重排由框架提供交互反馈，项目没有自定义补间或循环动画。`Visual` 为 `not-applicable`：首版规格不要求该项目维护 golden。

## 植物照护台验收状态

| Analyze | Unit | Widget | Integration | Release Web | Keyboard | Semantics | Responsive | Text scale | Motion | Visual |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| `passing` | `passing` | `passing` | `passing` | `passing` | `passing` | `passing` | `passing` | `passing` | `passing` | `not-applicable` |

Unit 与 Widget 共 10 项；Chrome 关键流程完成筛选、浇水和撤销。浏览器检查覆盖 320×720、768×900、1440×900，语义测试覆盖植物读数与 live region；动画测试精确推进起点、中点和终点，并验证 reduced motion 直接呈现终态。`Visual` 为 `not-applicable`：首版规格不要求该项目维护 golden。

## 即时书目检索验收状态

| Analyze | Unit | Widget | Integration | Release Web | Keyboard | Semantics | Responsive | Text scale | Motion | Visual |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| `passing` | `passing` | `passing` | `passing` | `passing` | `passing` | `passing` | `passing` | `passing` | `passing` | `not-applicable` |

Unit 与 Widget 共 11 项；Chrome 关键流程验证慢请求不能覆盖较新的查询。浏览器检查覆盖 320×720、768×900、1440×900，Widget 测试另行覆盖 320px 与 200% 文本缩放。结果区使用 240ms `AnimatedSwitcher`，系统要求减少动画时切换为零时长。`Visual` 为 `not-applicable`：首版规格不要求该项目维护 golden。

## 城市活动雷达验收状态

| Analyze | Unit | Widget | Integration | Release Web | Keyboard | Semantics | Responsive | Text scale | Motion | Visual |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| `passing` | `passing` | `passing` | `passing` | `passing` | `passing` | `passing` | `passing` | `passing` | `passing` | `not-applicable` |

Unit 与 Widget 共 14 项；Chrome 关键流程完成搜索、收藏，并在断网后读取 Drift 中的完整 feed 缓存。浏览器检查覆盖 320×720、768×900、1440×900；Drift Web 的 Wasm 与 Worker 随 release 产物构建。720ms 雷达入场动画在系统要求减少动画时切换为零时长。`Visual` 为 `not-applicable`：首版规格不要求该项目维护 golden。

## 路线分享卡验收状态

| Analyze | Unit | Widget | Integration | Release Web | Keyboard | Semantics | Responsive | Text scale | Motion | Visual |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| `passing` | `passing` | `passing` | `passing` | `passing` | `passing` | `passing` | `passing` | `passing` | `passing` | `not-applicable` |

Unit 与 Widget 共 10 项；Chrome 关键流程打开路线并把偏好写入 URL。浏览器检查覆盖深链接直达、刷新、Back、Forward、复制到新标签，以及 Unicode、重复参数和非法枚举。320×720、200% 文本与减少动画有独立 Widget 测试。`Visual` 为 `not-applicable`：首版规格不要求该项目维护 golden。

## 场馆导览册验收状态

| Analyze | Unit | Widget | Integration | Release Web | Keyboard | Semantics | Responsive | Text scale | Motion | Visual |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| `passing` | `passing` | `passing` | `passing` | `passing` | `passing` | `passing` | `passing` | `passing` | `passing` | `passing` |

Unit 与 Widget / golden 共 18 项；Chrome 关键流程完成搜索、地点详情、楼层切换和语言切换。测试覆盖 320×720、768×900、1440×900、200% 文本、RTL 测试壳、减少动画、URL 错误分支和两张 deterministic golden；真实浏览器另行检查直达、刷新、Back、Forward 与键盘输入边界。

## 社区工坊排期台验收状态

| Analyze | Unit | Widget | Integration | Release Web | Keyboard | Semantics | Responsive | Text scale | Motion | Visual |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| `passing` | `passing` | `passing` | `passing` | `passing` | `passing` | `passing` | `passing` | `passing` | `not-applicable` | `not-applicable` |

Unit 与 Widget 共 25 项；Chrome 关键流程覆盖筛选、详情、三类冲突、修正保存与 Drift 持久化。测试覆盖 320×720、768×900、1440×900 和 200% 文本，冲突摘要另有焦点与 Semantics 断言。`Motion` 为 `not-applicable`：项目没有自定义补间或循环动画。`Visual` 为 `not-applicable`：首版规格不要求该项目维护 golden。

其余 3 个项目的验收列目前均为 `not-started`。

完整项目任务、风险和浏览器关键流程见 [首版规格 #1](https://github.com/mardd123588/flutter-tutorial/issues/1)。
