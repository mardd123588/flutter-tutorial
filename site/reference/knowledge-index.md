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
