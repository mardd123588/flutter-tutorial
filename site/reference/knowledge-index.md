---
title: 知识索引
description: 按概念查找首次讲解、复习章节、项目和常见错误。
---

# 知识索引

概念 ID 来自各章的 `provides`。顺序学习时按章节前进；复习时可从这里直接回到概念第一次完整讲解的位置。

## 第一部分

| 概念 ID | 首次讲解 |
| --- | --- |
| `toolchain.flutter`、`project.anatomy`、`workflow.hot-reload` | [把 Flutter 跑起来](/guide/part-01/01-toolchain) |
| `dart.flutter-expressions`、`dart.const`、`dart.callbacks` | [Flutter 代码里的 Dart](/guide/part-01/02-dart-in-flutter) |
| `ui.widget`、`ui.widget-tree`、`ui.composition`、`ui.const-widget` | [Widget 是配置](/guide/part-01/03-widget-as-configuration) |
| `runtime.build`、`runtime.build-context`、`runtime.inherited-dependency` | [`build` 与 `BuildContext`](/guide/part-01/04-build-and-context) |
| `layout.box`、`layout.row-column`、`layout.spacing` | [够用的基础布局](/guide/part-01/05-minimum-layout) |
| `theme.material3`、`asset.bundle`、`state.ephemeral-basic`、`test.widget-smoke` | [主题、资源与第一条测试](/guide/part-01/06-theme-assets-test) |
| `project.daily-rhythm-board` | [项目：今日节奏板](/guide/part-01/07-daily-rhythm-board) |

## 第二部分

| 概念 ID | 首次讲解 | 复习或错误入口 |
| --- | --- | --- |
| `layout.constraints`、`layout.size-choice`、`layout.overflow-diagnosis` | [约束如何决定尺寸](/guide/part-02/01-constraints) | 三类布局错误与诊断顺序 |
| `layout.flex`、`layout.wrap`、`layout.stack` | [Flex、Wrap、Stack 的选择](/guide/part-02/02-flex-wrap-stack) | 票券排版器、ParentData、Stack 边外命中 |
| `layout.scrollable`、`layout.lazy-list`、`layout.grid` | [滚动、列表与网格](/guide/part-02/03-scrolling-lists-grids) | viewport、`shrinkWrap`、box/sliver 桥接 |
| `component.api`、`component.slot`、`theme.tokens` | [可复用组件的接口](/guide/part-02/04-component-interfaces) | 受控组件、资源所有权、合同测试 |
| `input.text`、`input.form`、`input.validation`、`state.local-basic` | [文本输入、表单与验证](/guide/part-02/05-text-input-and-forms) | controller 生命周期、同步 validator |
| `input.gesture`、`input.focus`、`input.keyboard`、`a11y.semantics-basic` | [手势、焦点、键盘与语义](/guide/part-02/06-gestures-focus-keyboard-semantics) | gesture arena、Shortcuts/Actions、live region |
| `project.micro-gallery-editor` | [项目：小型展览编辑器](/guide/part-02/07-micro-gallery-editor) | 筛选、新增、验证、保存、删除完整流程 |

## 第三部分

| 概念 ID | 首次讲解 | 复习或错误入口 |
| --- | --- | --- |
| `state.ownership`、`state.set-state`、`state.derived` | [状态放在哪里](/guide/part-03/01-state-ownership) | 最近共同拥有者、源状态与派生值、`setState` 范围 |
| `state.lifecycle`、`runtime.mounted`、`runtime.side-effect` | [生命周期与副作用](/guide/part-03/02-lifecycle-and-effects) | 三段式订阅、异步后的 context、取消与释放 |
| `runtime.element-identity`、`runtime.keys`、`list.reorder` | [Element 身份、Key 与重排](/guide/part-03/03-keys-and-reordering) | 可排序值班板、行内状态串位、3.47 `onReorderItem` |
| `state.listenable`、`state.change-notifier`、`state.inherited` | [Listenable、ChangeNotifier 与 InheritedWidget](/guide/part-03/04-listenable-inherited-notifier) | 通知、传播、所有权和 `InheritedNotifier` |
| `animation.implicit`、`animation.tween`、`animation.curve` | [隐式动画](/guide/part-03/05-implicit-animations) | 起点、中点、终点和属性成本 |
| `animation.controller`、`animation.transition`、`animation.reduced-motion` | [显式动画与过渡](/guide/part-03/06-explicit-animations) | Ticker、`didUpdateWidget`、Interval、减少动画 |
| `project.plant-care-desk` | [项目：植物照护台](/guide/part-03/07-plant-care-desk) | 筛选、浇水、重排、撤销和两类动画完整流程 |

## 第四部分

| 概念 ID | 首次讲解 | 复习或错误入口 |
| --- | --- | --- |
| `async.ui-state`、`async.future-builder`、`async.stream-builder`、`async.stale-result` | [把 Future 与 Stream 变成界面状态](/guide/part-04/01-async-ui-state) | 一次结果与持续事件、Builder 创建时机、过期结果身份 |
| `data.http-client`、`data.service`、`error.network`、`test.http-client` | [HTTP Service 与错误边界](/guide/part-04/02-http-service) | Client 注入、状态码、超时、传输错误、CORS 与 MockClient 边界 |
| `data.json`、`model.immutable`、`error.decode` | [手写 JSON 模型](/guide/part-04/03-hand-written-json) | 容器检查、缺失与 null、未知字段、条目定位 |
| `async.debounce`、`async.race`、`async.cancellation-boundary` | [防抖、竞态与即时书目检索](/guide/part-04/04-search-race) | Timer 取消、generation、保留旧结果、可控完成顺序 |
| `codegen.json-serializable`、`tool.build-runner` | [json_serializable 与生成代码](/guide/part-04/05-json-serializable) | annotation、part 文件、默认宽松映射与手写 envelope |
| `storage.preferences`、`data.cache`、`offline.fallback` | [偏好、缓存与离线回退](/guide/part-04/06-preferences-cache-offline) | SharedPreferencesAsync、三类缓存、freshness 与回退来源 |
| `storage.relational`、`storage.drift`、`storage.migration`、`storage.web-boundary` | [关系数据、Drift 与迁移](/guide/part-04/07-drift-relational-data) | 事务、查询 Stream、v1→v2、Wasm、Worker 与 MIME |
| `project.city-event-radar` | [项目：城市活动雷达](/guide/part-04/08-city-event-radar) | HTTP、搜索竞态、偏好、缓存、离线回退和收藏关系完整流程 |
