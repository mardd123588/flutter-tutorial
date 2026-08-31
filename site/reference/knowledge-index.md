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

## 第五部分

| 概念 ID | 首次讲解 | 复习或错误入口 |
| --- | --- | --- |
| `navigation.navigator-stack`、`navigation.route-result`、`navigation.pop-scope` | [Navigator 与页面栈](/guide/part-05/01-navigator-page-stack) | push/pop 返回值、异步 context、嵌套栈、dialog 与离开确认 |
| `navigation.router`、`navigation.url-state`、`navigation.go-router`、`navigation.shell-route` | [Router、URL 与 go_router](/guide/part-05/02-router-url-go-router) | Router 与 Navigator 分工、go/push、redirect、onExit、ShellRoute 与错误页 |
| `navigation.deep-link`、`navigation.url-validation`、`deployment.hash-url`、`project.route-share-card` | [深链接与路线分享卡](/guide/part-05/03-deep-links-route-share-card) | 稳定 ID、Uri 编码、非法参数、hash、base href 与新标签恢复 |
| `layout.responsive`、`layout.content-breakpoint`、`navigation.adaptive-shell`、`input.adaptive` | [响应式与平台适配](/guide/part-05/04-responsive-adaptive) | LayoutBuilder、MediaQuery、Drawer/Rail、hover、键盘与平台惯例 |
| `a11y.semantics`、`a11y.keyboard-flow`、`a11y.text-scale`、`a11y.error-feedback`、`a11y.motion-preference` | [可访问性作为功能](/guide/part-05/05-accessibility-as-feature) | 语义分工、完整键盘流程、200% 文本、对比度、错误与减少动画 |
| `i18n.gen-l10n`、`i18n.arb`、`i18n.format`、`i18n.locale`、`i18n.directionality` | [国际化与本地化](/guide/part-05/06-internationalization-localization) | ARB placeholder/plural、intl、稳定路由与 RTL 测试边界 |
| `project.venue-guidebook` | [项目：场馆导览册](/guide/part-05/07-venue-guidebook) | ShellRoute、深链接、响应式导航、键盘、语义、本地化与 golden 完整流程 |

## 第六部分

| 概念 ID | 首次讲解 | 复习或错误入口 |
| --- | --- | --- |
| `architecture.complexity-signals`、`architecture.ssot`、`architecture.udf` | [复杂度从哪里出现](/guide/part-06/01-complexity-signals) | 分层信号、单一事实来源、状态—事件—更新—渲染 |
| `architecture.view`、`architecture.viewmodel`、`architecture.repository`、`architecture.service` | [View、ViewModel、Repository、Service](/guide/part-06/02-application-layers) | 普通构造函数注入、层间依赖、domain 层启用条件 |
| `architecture.result`、`architecture.command`、`error.presentation` | [Result、错误与命令](/guide/part-06/03-result-command-errors) | sealed 结果、命令状态、错误文案、焦点与恢复动作 |
| `riverpod.provider`、`riverpod.ref`、`riverpod.notifier`、`riverpod.scope` | [Riverpod 3 基础](/guide/part-06/04-riverpod-basics) | container 所有权、watch/read/listen、局部状态边界 |
| `riverpod.async-notifier`、`riverpod.family`、`riverpod.invalidation`、`riverpod.disposal` | [异步状态、缓存失效与组合](/guide/part-06/05-riverpod-async-cache) | AsyncValue、参数身份、自动释放、invalidate 与 refresh |
| `riverpod.override`、`test.provider-container`、`test.fake-repository` | [依赖替换与 Riverpod 测试](/guide/part-06/06-riverpod-testing) | Repository override、auto-dispose 保活、family 参数隔离 |
| `riverpod.codegen-boundary`、`ecosystem.package-evaluation`、`ecosystem.upgrade-boundary` | [代码生成、包选择与升级边界](/guide/part-06/07-codegen-package-upgrades) | generated provider 默认生命周期、包评估、锁版本与升级验证 |
| `project.community-workshop-scheduler` | [项目：社区工坊排期台](/guide/part-06/08-community-workshop-scheduler) | 冲突 policy、Riverpod 对象图、Drift、URL、响应式与 Web 测试完整流程 |

## 第七部分

| 概念 ID | 首次讲解 | 复习或错误入口 |
| --- | --- | --- |
| `test.strategy`、`test.unit`、`test.determinism` | [测试策略与单元测试](/guide/part-07/01-test-strategy-unit) | 风险表、arrange—act—assert、固定时钟、fake / mock / 真实依赖 |
| `test.widget`、`test.semantics`、`test.golden-boundary` | [Widget、语义与视觉测试](/guide/part-07/02-widget-semantics-golden) | 精确 pump、lazy finder、用户可感知合同、golden 环境 |
| `test.integration-web`、`test.webdriver`、`test.failure-artifact` | [Web 浏览器关键流程](/guide/part-07/03-web-integration) | ChromeDriver、URL 恢复、Web release 子路径与失败证据包 |
| `internals.widget-element-renderobject`、`internals.update-matching`、`debug.rebuild` | [Widget、Element、RenderObject](/guide/part-07/04-widget-element-renderobject) | 三棵树、canUpdate、build mode、Inspector 与 build tracing |
| `render.pipeline`、`render.repaint-boundary`、`debug.layout-paint` | [渲染流水线与自绘边界](/guide/part-07/05-rendering-pipeline) | layout / paint / semantics、CustomPainter、Listenable、边界成本 |
| `performance.frame-budget`、`performance.devtools`、`layout.sliver`、`performance.memory`、`project.scroll-timeline` | [Sliver、性能分析与长卷时间轴](/guide/part-07/06-sliver-performance-scroll-timeline) | SliverConstraints / Geometry、lazy、profile workload、golden 与长卷完整流程 |
| `project.digital-archive-browser` | [项目：数字档案浏览器](/guide/part-07/07-digital-archive-browser) | 风险表、URL、Riverpod、mixed sliver、自绘、对照错误与 Web profile |

## 第八部分

| 概念 ID | 首次讲解 | 复习或错误入口 |
| --- | --- | --- |
| `engineering.pub-workspace`、`engineering.dependencies`、`engineering.config` | [Workspace、依赖与配置](/guide/part-08/01-workspace-dependencies-config) | 根与成员合同、manifest / lockfile / cache、公开编译时配置 |
| `engineering.ci`、`engineering.affected-projects`、`engineering.reproducibility` | [可复现 CI 与受影响项目](/guide/part-08/02-reproducible-ci) | Git rename 两侧路径、matrix 隔离、ChromeDriver 与失败 artifact |
| `web.release-build`、`web.base-href`、`web.wasm-boundary` | [Flutter Web release 构建与子路径](/guide/part-08/03-flutter-web-release) | base href、本地 CanvasKit、hash URL、Wasm、PWA 与 source map 边界 |
| `deployment.pages`、`deployment.preview-layout`、`deployment.rollback` | [GitHub Pages artifact 与发布](/guide/part-08/04-github-pages-publishing) | 单一 staging、最小权限、smoke、内容版本与 commit 回滚 |
| `platform.plugin`、`platform.permission`、`platform.channel`、`platform.web-limit` | [平台插件、权限与平台通道](/guide/part-08/05-platform-plugins-permissions-channels) | Service 接缝、federated plugin、MethodChannel、权限状态与证据标签 |
| `release.quality`、`release.privacy`、`release.license`、`release.migration` | [发布质量、隐私、许可与升级](/guide/part-08/06-release-quality-privacy-upgrades) | 自动 / 人工证据、第三方请求、许可、依赖与 SDK 分批升级 |
| `project.neighborhood-exchange` | [项目：邻里资源交换站](/guide/part-08/07-neighborhood-exchange) | fixture、Drift 幂等、Riverpod、URL、响应式、CI、Web release 构建与 Pages 完整流程 |
