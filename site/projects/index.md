---
title: 实践项目
description: 8 个统筹项目和 5 个重点项目的实现与测试状态。
---

# 实践项目

每个项目都是独立 Flutter 应用，不共享业务代码或 UI 包。正式项目需要通过 analyze、单元测试、Widget 测试、Chrome 集成测试和 Web release 构建；键盘、语义、响应式、文本缩放与减少动画还要单独验收。

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
| 长卷时间轴 | 重点 | 07-06 | `passing` |
| 数字档案浏览器 | 统筹 | 07-07 | `passing` |
| 邻里资源交换站 | 统筹 | 08-07 | `passing` |

`passing` 表示项目已有可运行实现，且当前适用的发布检查全部通过。13 个项目都达到这个状态，八个部分的正文也已全部接入学习路线。

## 今日节奏板验收状态

| 分析 | 单元测试 | Widget 测试 | Chrome 集成测试 | Web release 构建 | 键盘 | 语义 | 响应式 | 文本缩放 | 减少动画 | 视觉 |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| `passing` | `passing` | `passing` | `passing` | `passing` | `passing` | `passing` | `passing` | `passing` | `not-applicable` | `not-applicable` |

“减少动画”为 `not-applicable`：这个项目没有补间、循环或依赖位移的过渡，选择结果立即更新。“视觉”为 `not-applicable`：首版规格只要求票券排版器、场馆导览册和长卷时间轴维护确定性 golden。

## 票券排版器验收状态

| 分析 | 单元测试 | Widget 测试 | Chrome 集成测试 | Web release 构建 | 键盘 | 语义 | 响应式 | 文本缩放 | 减少动画 | 视觉 |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| `passing` | `passing` | `passing` | `passing` | `passing` | `passing` | `passing` | `passing` | `passing` | `not-applicable` | `passing` |

单元测试与 Widget 测试共 6 项；Chrome 集成测试验证票面预设切换。浏览器检查覆盖 320×720、768×900、1440×900，键盘可用 Tab 和 Enter 切换票面；320×720 的 Widget 测试同时使用 200% 文本缩放。项目维护标准票的确定性 golden。

## 小型展览编辑器验收状态

| 分析 | 单元测试 | Widget 测试 | Chrome 集成测试 | Web release 构建 | 键盘 | 语义 | 响应式 | 文本缩放 | 减少动画 | 视觉 |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| `passing` | `passing` | `passing` | `passing` | `passing` | `passing` | `passing` | `passing` | `passing` | `not-applicable` | `not-applicable` |

单元测试与 Widget 测试共 9 项；Chrome 集成测试先复现年份错误，再修正并新增展品。浏览器检查覆盖 320×720、768×900、1440×900，并实际验证筛选、Ctrl+N、Ctrl+S、焦点和错误状态。语义测试覆盖选中展品的 button / selected flags 与状态 live region。“减少动画”为 `not-applicable`：项目没有补间或循环动画。“视觉”为 `not-applicable`：首版规格不要求该项目维护 golden。

## 可排序值班板验收状态

| 分析 | 单元测试 | Widget 测试 | Chrome 集成测试 | Web release 构建 | 键盘 | 语义 | 响应式 | 文本缩放 | 减少动画 | 视觉 |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| `passing` | `passing` | `passing` | `passing` | `passing` | `passing` | `passing` | `passing` | `passing` | `not-applicable` | `not-applicable` |

单元测试与 Widget 测试共 7 项；Chrome 集成测试验证备注跟随同一成员完成重排。浏览器检查覆盖 320×720、768×900、1440×900，并实际验证拖动替代按钮、边界禁用与状态回执。“减少动画”为 `not-applicable`：重排由框架提供交互反馈，项目没有自定义补间或循环动画。“视觉”为 `not-applicable`：首版规格不要求该项目维护 golden。

## 植物照护台验收状态

| 分析 | 单元测试 | Widget 测试 | Chrome 集成测试 | Web release 构建 | 键盘 | 语义 | 响应式 | 文本缩放 | 减少动画 | 视觉 |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| `passing` | `passing` | `passing` | `passing` | `passing` | `passing` | `passing` | `passing` | `passing` | `passing` | `not-applicable` |

单元测试与 Widget 测试共 10 项；Chrome 集成测试完成筛选、浇水和撤销。浏览器检查覆盖 320×720、768×900、1440×900，语义测试覆盖植物读数与 live region；动画测试精确推进起点、中点和终点，并验证 reduced motion 直接呈现终态。“视觉”为 `not-applicable`：首版规格不要求该项目维护 golden。

## 即时书目检索验收状态

| 分析 | 单元测试 | Widget 测试 | Chrome 集成测试 | Web release 构建 | 键盘 | 语义 | 响应式 | 文本缩放 | 减少动画 | 视觉 |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| `passing` | `passing` | `passing` | `passing` | `passing` | `passing` | `passing` | `passing` | `passing` | `passing` | `not-applicable` |

单元测试与 Widget 测试共 11 项；Chrome 集成测试验证慢请求不能覆盖较新的查询。浏览器检查覆盖 320×720、768×900、1440×900，Widget 测试另行覆盖 320px 与 200% 文本缩放。结果区使用 240ms `AnimatedSwitcher`，系统要求减少动画时切换为零时长。“视觉”为 `not-applicable`：首版规格不要求该项目维护 golden。

## 城市活动雷达验收状态

| 分析 | 单元测试 | Widget 测试 | Chrome 集成测试 | Web release 构建 | 键盘 | 语义 | 响应式 | 文本缩放 | 减少动画 | 视觉 |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| `passing` | `passing` | `passing` | `passing` | `passing` | `passing` | `passing` | `passing` | `passing` | `passing` | `not-applicable` |

单元测试与 Widget 测试共 14 项；Chrome 集成测试完成搜索、收藏，并在断网后读取 Drift 中的完整 feed 缓存。浏览器检查覆盖 320×720、768×900、1440×900；Drift Web 的 Wasm 与 Worker 随 Web release 产物构建。720ms 雷达入场动画在系统要求减少动画时切换为零时长。“视觉”为 `not-applicable`：首版规格不要求该项目维护 golden。

## 路线分享卡验收状态

| 分析 | 单元测试 | Widget 测试 | Chrome 集成测试 | Web release 构建 | 键盘 | 语义 | 响应式 | 文本缩放 | 减少动画 | 视觉 |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| `passing` | `passing` | `passing` | `passing` | `passing` | `passing` | `passing` | `passing` | `passing` | `passing` | `not-applicable` |

单元测试与 Widget 测试共 10 项；Chrome 集成测试打开路线并把偏好写入 URL。浏览器检查覆盖深链接直达、刷新、Back、Forward、复制到新标签，以及 Unicode、重复参数和非法枚举。320×720、200% 文本与减少动画有独立 Widget 测试。“视觉”为 `not-applicable`：首版规格不要求该项目维护 golden。

## 场馆导览册验收状态

| 分析 | 单元测试 | Widget 测试 | Chrome 集成测试 | Web release 构建 | 键盘 | 语义 | 响应式 | 文本缩放 | 减少动画 | 视觉 |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| `passing` | `passing` | `passing` | `passing` | `passing` | `passing` | `passing` | `passing` | `passing` | `passing` | `passing` |

单元测试、Widget 测试与 golden 测试共 18 项；Chrome 集成测试完成搜索、地点详情、楼层切换和语言切换。测试覆盖 320×720、768×900、1440×900、200% 文本、RTL 测试壳、减少动画、URL 错误分支和两张确定性 golden；真实浏览器另行检查直达、刷新、Back、Forward 与键盘输入边界。

## 社区工坊排期台验收状态

| 分析 | 单元测试 | Widget 测试 | Chrome 集成测试 | Web release 构建 | 键盘 | 语义 | 响应式 | 文本缩放 | 减少动画 | 视觉 |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| `passing` | `passing` | `passing` | `passing` | `passing` | `passing` | `passing` | `passing` | `passing` | `not-applicable` | `not-applicable` |

单元测试与 Widget 测试共 25 项；Chrome 集成测试覆盖筛选、详情、三类冲突、修正保存与 Drift 持久化。测试覆盖 320×720、768×900、1440×900 和 200% 文本，冲突摘要另有焦点与 Semantics 断言。“减少动画”为 `not-applicable`：项目没有自定义补间或循环动画。“视觉”为 `not-applicable`：首版规格不要求该项目维护 golden。

## 长卷时间轴验收状态

| 分析 | 单元测试 | Widget 测试 | Chrome 集成测试 | Web release 构建 | 键盘 | 语义 | 响应式 | 文本缩放 | 减少动画 | 视觉 |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| `passing` | `passing` | `passing` | `passing` | `passing` | `passing` | `passing` | `passing` | `passing` | `passing` | `passing` |

单元测试、Widget 测试与 golden 测试共 11 项；Chrome profile 流程覆盖主题筛选和长卷往返滚动。测试固定 6 个阶段、72 条事件、4 类主题，覆盖 lazy materialization、目录跳转后的焦点、Semantics、320×720、768×900、1440×900、200% 文本、reduced motion 与两张确定性 golden。Profile 基线记录 595 帧，build p90 为 `1.199ms`，raster p90 为 `1.5ms`。

## 数字档案浏览器验收状态

| 分析 | 单元测试 | Widget 测试 | Chrome 集成测试 | Web release 构建 | 键盘 | 语义 | 响应式 | 文本缩放 | 减少动画 | 视觉 |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| `passing` | `passing` | `passing` | `passing` | `passing` | `passing` | `passing` | `passing` | `passing` | `passing` | `not-applicable` |

单元测试、provider 测试与 Widget 测试共 16 项；Chrome profile 流程覆盖滚动、网格、Unicode 查询、详情返回和三项对照。测试固定 120 条记录、URL 往返、lazy materialization、loading / error / retry / empty、第四条拒绝的 live region 与焦点，以及 320×720、768×900、1440×900、200% 文本、RTL 和 reduced motion。Profile 基线记录 165 帧，build p90 为 `5.801ms`，raster p90 为 `3.801ms`。“视觉”为 `not-applicable`：本项目不维护 golden，但已完成三档尺寸和实际 Chrome 视觉检查。

## 邻里资源交换站验收状态

| 分析 | 单元测试 | Widget 测试 | Chrome 集成测试 | Web release 构建 | 键盘 | 语义 | 响应式 | 文本缩放 | 减少动画 | 视觉 |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| `passing` | `passing` | `passing` | `passing` | `passing` | `passing` | `passing` | `passing` | `passing` | `passing` | `not-applicable` |

单元测试、Repository 测试、Drift 测试与 Widget 测试共 26 项；Chrome 集成测试覆盖发布本地资源、重开浏览器数据库、认领 fixture 和持久化。测试固定 48 条资源、6 个片区和 6 个类别，覆盖 URL 归一化、幂等认领、loading / empty / error / retry、发布错误焦点、认领 live region、320×720、768×900、1440×900、200% 文本、RTL 和 reduced motion。独立 Web release 构建使用 `/flutter-tutorial/previews/neighborhood-exchange/`，并与其余 12 个预览和 VitePress 合并后通过 staging smoke。详情签只在宽屏打开时执行一次短过渡，reduced motion 下时长为零。“视觉”为 `not-applicable`：本项目不维护 golden，但已完成三档实际浏览器检查。

完整项目任务、风险和浏览器关键流程见 [首版规格 #1](https://github.com/mardd123588/flutter-tutorial/issues/1)。
