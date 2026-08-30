---
name: 即时书目检索
description: 用编辑部校样与请求登记簿呈现防抖、竞态和旧结果保留。
colors:
  paper: "#F2EBDD"
  paper-bright: "#FFFBF2"
  ink: "#1C211F"
  quiet-ink: "#4F5753"
  proof-red: "#B9362B"
  pencil-blue: "#285C7C"
  signal-gold: "#D6A739"
  rule: "#B9B1A3"
  proof-grid: "#313735"
  field-hint: "#676D69"
  register-label: "#D9E5EB"
  register-note: "#E4EDF2"
typography:
  display:
    fontFamily: "serif"
    fontSize: "36px"
    fontWeight: 900
    lineHeight: 0.98
    letterSpacing: "-1.2px"
  section-title:
    fontFamily: "serif"
    fontSize: "28px"
    fontWeight: 900
    lineHeight: 1.1
  record-title:
    fontFamily: "serif"
    fontSize: "22px"
    fontWeight: 900
    lineHeight: 1.1
  body:
    fontFamily: "system-ui, sans-serif"
    fontSize: "16px"
    fontWeight: 400
    lineHeight: 1.45
  register:
    fontFamily: "monospace"
    fontSize: "14px"
    fontWeight: 900
    lineHeight: 1.5
  stamp-label:
    fontFamily: "monospace"
    fontSize: "11px"
    fontWeight: 800
    lineHeight: 1.2
rounded:
  square: "0px"
spacing:
  xs: "6px"
  sm: "10px"
  md: "14px"
  lg: "18px"
  xl: "26px"
components:
  button-race:
    backgroundColor: "{colors.ink}"
    textColor: "{colors.paper-bright}"
    rounded: "{rounded.square}"
    padding: "12px 16px"
    height: "48px"
  button-shortcut:
    backgroundColor: "{colors.paper}"
    textColor: "{colors.ink}"
    rounded: "{rounded.square}"
    padding: "12px 16px"
    height: "48px"
  search-field:
    backgroundColor: "{colors.paper-bright}"
    textColor: "{colors.ink}"
    rounded: "{rounded.square}"
    padding: "14px 16px"
    height: "50px"
  proof-message:
    backgroundColor: "{colors.paper}"
    textColor: "{colors.ink}"
    rounded: "{rounded.square}"
    padding: "18px"
  book-proof-row:
    backgroundColor: "{colors.paper}"
    textColor: "{colors.ink}"
    rounded: "{rounded.square}"
    padding: "16px"
  request-stamp:
    backgroundColor: "{colors.pencil-blue}"
    textColor: "{colors.paper-bright}"
    rounded: "{rounded.square}"
    padding: "10px 12px"
---

# Design System: 即时书目检索

## Overview

**Creative North Star: "编辑部校样请求队列"**

界面把每次搜索当作一份带编号的校样请求。暖纸色承载已接纳的结果，蓝色登记簿记录查询状态，朱红色标出需要处理的动作和退回状态。

用户首先读取检索校样，再核对请求登记簿。窄屏也保持这个顺序，让竞态演示的结果先于诊断数据出现。

**Key Characteristics:**

- 方角纸面、细规则线和校对印章
- 朱红页头、暖色校样与蓝色登记簿
- 等宽字只表示请求编号、状态和书目元数据
- 金色只出现在状态边框、选区和异常计数下划线

## Colors

暖纸色负责内容阅读，墨色构成背景和结构线。朱红、蓝铅笔和金色各有固定职责，不互相替代。

### Primary

- **Proof Red**：页头、焦点边框、重试按钮和退回印章。
- **Pencil Blue**：请求登记簿、书目元数据和结果计数。

### Secondary

- **Signal Gold**：状态边框、文本选区和被忽略响应的下划线。

### Neutral

- **Paper / Paper Bright**：输入区、校样正文、结果行和高亮纸面。
- **Ink / Quiet Ink**：背景、主文字、边框和说明文字。
- **Rule / Proof Grid**：纸面分隔线和底场网格。

**The Gold Mark Rule.** 金色只用于边框、选区和下划线，不作小号文字或大面积填色。

## Typography

标题使用平台衬线字体，正文使用系统字体，编号和状态使用等宽字体。项目不加载第三方字体。

### Hierarchy

- **Display**：应用名称，只在朱红页头出现一次。
- **Section Title**：检索校样和请求登记簿标题。
- **Record Title**：书名与状态消息标题。
- **Body**：说明、检索反馈和书目摘要。
- **Register / Stamp Label**：请求状态、编号、作者、年份和架位。

**The Proof Type Rule.** 等宽字只进入编号、状态与元数据；中文说明和书目摘要保持正文排版。

## Layout

内容最大宽度为 1240px，页面四周保留 18px，底部额外留出 36px。页头和操作区使用 Wrap，让标题、状态章、按钮与 fixture 说明按内容换行。

900px 以上使用 7:3 双栏，检索校样在左、请求登记簿在右；以下改为单列，并固定为校样在前、登记簿在后。书目行在 520px 以下把蓝色元数据块移到摘要下方。

## Elevation & Depth

深色网格是固定底场。朱红页头使用向下 10px 的柔和阴影，主校样纸使用向下 12px 的更宽阴影；操作区、登记簿、结果行和按钮保持平面。

**The Two Sheet Rule.** 只有页头与主校样纸可以离开底场，其余层级由色块、边框和间距区分。

## Shapes

所有容器、输入框和按钮使用方角。细边框、横向规则线与轻微旋转的校对印章提供形状变化，不使用圆角卡片、胶囊按钮或装饰性渐变。

## Components

### Search Field

- 亮纸色底、墨色一像素边框和蓝色搜索图标。
- 聚焦后边框切为 3px 朱红色；清空按钮保留可读 tooltip。

### Race and Shortcut Buttons

- 竞态演示使用墨色实心按钮，空结果和失败入口使用墨色描边按钮。
- 所有按钮高度至少 48px，并允许在窄屏换行。

### Result Proof

- 亮纸色主面板承载 idle、loading、success、empty 与 failure。
- 状态切换使用 240ms `easeOutCubic`；减少动画时直接显示终态。
- 加载新查询时保留旧结果，状态文字说明正在请求的查询与已结算查询。

### Book Proof Row

- 暖纸色行由规则线包围，书名使用衬线标题，摘要使用弱墨色正文。
- 蓝色元数据块使用纸白文字，不能改成低对比的蓝底小号灰字。

### Request Register and Stamp

- 蓝色登记簿列出当前查询、已结算查询、忽略的旧响应和阶段。
- 状态章使用纸白文字；金色只画边框，异常计数只加金色下划线。

## Do's and Don'ts

### Do:

- **Do** 让主结果在所有宽度下先于请求登记簿。
- **Do** 同时显示当前查询、已结算查询和被忽略响应数。
- **Do** 在 320、768、1440 宽度、键盘操作和减少动画模式下检查五种状态。

### Don't:

- **Don't** 用圆角搜索卡片和结果网格替代校样与登记簿。
- **Don't** 用新响应之外的旧请求覆盖当前结果。
- **Don't** 把金色用于小号文字，或把蓝色元数据文字改成低对比灰色。
