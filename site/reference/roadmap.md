---
title: 学习路线
description: 首版 58 章的八部分结构与当前完成状态。
---

# 学习路线

首版 58 章已经完成正文与项目实现，按八个部分组织。

| 部分 | 章节 | 当前状态 | 统筹项目 |
| --- | ---: | --- | --- |
| [01 · 起步与 Flutter 所需 Dart](#part-01) | 7 | `verified` | 今日节奏板 |
| [02 · 组件、布局与输入](#part-02) | 7 | `verified` | 小型展览编辑器 |
| [03 · 状态、生命周期与动画](#part-03) | 7 | `verified` | 植物照护台 |
| [04 · 异步、网络与本地数据](#part-04) | 8 | `verified` | 城市活动雷达 |
| [05 · 导航、自适应、可访问性与国际化](#part-05) | 7 | `verified` | 场馆导览册 |
| [06 · 应用架构与生态主方案](#part-06) | 8 | `verified` | 社区工坊排期台 |
| [07 · 测试、调试、渲染与性能](#part-07) | 7 | `verified` | 数字档案浏览器 |
| [08 · 工程化、Web 发布与平台扩展](#part-08) | 7 | `verified` | 邻里资源交换站 |

## 第一部分：起步与 Flutter 所需 Dart {#part-01}

建立工具链、项目结构、Flutter 语境中的 Dart、Widget、`build`、`BuildContext`、基础布局、主题、资源和第一条 Widget 测试。

[从第一章开始](/guide/part-01/01-toolchain) · [查看今日节奏板](/guide/part-01/07-daily-rhythm-board)

## 第二部分：组件、布局与输入 {#part-02}

解释约束传递、常用布局、滚动、表单、焦点、键盘和可复用组件边界。重点项目是票券排版器，统筹项目是小型展览编辑器。

[从约束开始](/guide/part-02/01-constraints) · [查看票券排版器](/guide/part-02/02-flex-wrap-stack) · [查看小型展览编辑器](/guide/part-02/07-micro-gallery-editor)

## 第三部分：状态、生命周期与动画 {#part-03}

讨论状态所有权、生命周期、Key、列表身份、`InheritedWidget`、`ChangeNotifier` 与动画资源释放。重点项目是可排序值班板，统筹项目是植物照护台。

[从状态所有权开始](/guide/part-03/01-state-ownership) · [查看可排序值班板](/guide/part-03/03-keys-and-reordering) · [查看植物照护台](/guide/part-03/07-plant-care-desk)

## 第四部分：异步、网络与本地数据 {#part-04}

覆盖 Future、Stream、异步 UI 状态、HTTP、JSON、错误恢复、缓存和 Drift Web。重点项目是即时书目检索，统筹项目是城市活动雷达。

[从异步 UI 状态开始](/guide/part-04/01-async-ui-state) · [查看即时书目检索](/guide/part-04/04-search-race) · [查看城市活动雷达](/guide/part-04/08-city-event-radar)

## 第五部分：导航、自适应、可访问性与国际化 {#part-05}

覆盖 Router、URL 状态、深链接、响应式导航、键盘、语义、文本缩放和国际化。重点项目是路线分享卡，统筹项目是场馆导览册。

[从页面栈开始](/guide/part-05/01-navigator-page-stack) · [查看路线分享卡](/guide/part-05/03-deep-links-route-share-card) · [查看场馆导览册](/guide/part-05/07-venue-guidebook)

## 第六部分：应用架构与生态主方案 {#part-06}

从复杂度信号出发，引入 ViewModel、Repository、Service、Result、Riverpod 3、依赖替换和包选择。统筹项目是社区工坊排期台。

[从复杂度信号开始](/guide/part-06/01-complexity-signals) · [查看 Riverpod 3 基础](/guide/part-06/04-riverpod-basics) · [查看社区工坊排期台](/guide/part-06/08-community-workshop-scheduler)

## 第七部分：测试、调试、渲染与性能 {#part-07}

覆盖测试策略、Widget 与语义测试、Web 集成测试、Widget—Element—RenderObject、渲染流水线、Sliver 和性能分析。重点项目是长卷时间轴，统筹项目是数字档案浏览器。

[从测试策略开始](/guide/part-07/01-test-strategy-unit) · [查看长卷时间轴](/guide/part-07/06-sliver-performance-scroll-timeline) · [查看数字档案浏览器](/guide/part-07/07-digital-archive-browser)

## 第八部分：工程化、Web 发布与平台扩展 {#part-08}

覆盖 workspace、可复现 CI、Flutter Web release、GitHub Pages、平台插件边界、隐私、许可与升级。统筹项目是邻里资源交换站。

[从 Workspace 开始](/guide/part-08/01-workspace-dependencies-config) · [查看 Flutter Web release](/guide/part-08/03-flutter-web-release) · [查看邻里资源交换站](/guide/part-08/07-neighborhood-exchange)
