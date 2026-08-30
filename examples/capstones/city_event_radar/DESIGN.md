---
name: 城市活动雷达
description: 用夜班市政调度图呈现活动来源、缓存时间、筛选和本地收藏。
colors:
  night: "#102326"
  night-deep: "#081416"
  survey: "#9FC7B5"
  cyan: "#68B7C4"
  sodium: "#E39A36"
  paper: "#F1E8CF"
  paper-muted: "#D8CFB8"
  ink: "#182120"
  danger: "#C94A3D"
  danger-ink: "#8F2F27"
  warning-text: "#FFFFFF"
  night-hint: "#B9C7C2"
  paper-quiet: "#46504D"
  ledger-label: "#4B5552"
  dispatch-paper: "#F8F1DE"
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
  event-title:
    fontFamily: "serif"
    fontSize: "22px"
    fontWeight: 900
    lineHeight: 1.1
  body:
    fontFamily: "system-ui, sans-serif"
    fontSize: "16px"
    fontWeight: 400
    lineHeight: 1.45
  telemetry:
    fontFamily: "monospace"
    fontSize: "14px"
    fontWeight: 900
    lineHeight: 1.45
rounded:
  square: "0px"
spacing:
  xs: "7px"
  sm: "10px"
  md: "14px"
  lg: "16px"
  xl: "20px"
components:
  search-field:
    backgroundColor: "{colors.night-deep}"
    textColor: "{colors.paper}"
    rounded: "{rounded.square}"
    padding: "14px 16px"
    height: "50px"
  district-button:
    backgroundColor: "{colors.night-deep}"
    textColor: "{colors.paper}"
    rounded: "{rounded.square}"
    padding: "12px 16px"
    height: "48px"
    width: "72px"
  district-button-selected:
    backgroundColor: "{colors.sodium}"
    textColor: "{colors.ink}"
    rounded: "{rounded.square}"
    padding: "12px 16px"
    height: "48px"
    width: "72px"
  saved-filter:
    backgroundColor: "{colors.night-deep}"
    textColor: "{colors.paper}"
    rounded: "{rounded.square}"
    padding: "12px 14px"
    height: "48px"
  refresh-button:
    backgroundColor: "{colors.ink}"
    textColor: "{colors.paper}"
    rounded: "{rounded.square}"
    padding: "12px 16px"
    height: "48px"
  event-row:
    backgroundColor: "{colors.dispatch-paper}"
    textColor: "{colors.ink}"
    rounded: "{rounded.square}"
    padding: "14px"
  warning-notice:
    backgroundColor: "{colors.danger}"
    textColor: "{colors.warning-text}"
    rounded: "{rounded.square}"
    padding: "14px"
---

# Design System: 城市活动雷达

## Overview

**Creative North Star: "夜班市政调度图"**

界面把活动列表组织成一张夜班值守用的城市图。沥青色扫描面承载活动信号，测绘绿页头说明任务，钠灯橙标出当前筛选、收藏和雷达信号，纸色值班簿记录数据来源。

数据来源必须和活动本身一样容易找到。窄屏先显示来源与更新时间摘要，再进入扫描面；完整值班簿随后提供数量、忽略响应和刷新操作。

**Key Characteristics:**

- 沥青黑底场、测绘绿页头和纸色调度单
- 青色扫描范围、测绘绿分区线与钠灯橙信号
- 数据来源、新鲜度和本地收藏始终可见
- 方角控件与纸面清单，不使用地图图钉墙或指标卡网格

## Colors

夜色负责工作环境，纸色负责长文本与来源账目。测绘绿、青色和钠灯橙分别表示页头、扫描结构与活动信号。

### Primary

- **Night / Night Deep**：页面底场、控制台和扫描面。
- **Survey**：页头和雷达分区线。

### Secondary

- **Cyan**：输入边框、搜索图标和雷达范围线。
- **Sodium**：选中筛选、活动信号、收藏状态和焦点。

### Neutral and Status

- **Paper / Dispatch Paper**：值班簿、来源摘要和活动调度行。
- **Ink / Paper Quiet**：纸面标题、正文与说明。
- **Danger**：离线回退通知的实心底色。
- **Danger Ink**：纸面上的警示计数、标签和信号总数。

**The Paper Danger Rule.** 红色实心通知使用白字；纸面上的 danger 文本使用 Danger Ink，不能直接复用 Fallback Red。

## Typography

标题使用平台衬线字体，操作和说明使用系统字体，来源、时间、信号值与日期使用等宽字体。项目不加载第三方字体。

### Hierarchy

- **Display**：应用名称，只在测绘绿页头出现一次。
- **Section Title**：城市扫描面、数据值班簿和活动调度单。
- **Event Title**：活动名称。
- **Body**：任务说明、场地信息、活动摘要和错误消息。
- **Telemetry**：来源、更新时间、日期、信号值、标签与计数。

**The Dispatch Type Rule.** 等宽字只表示来源、时间、日期、信号、标签和计数，不用于活动摘要或故障说明。

## Layout

内容最大宽度为 1320px，页面四周保留 16px，底部额外留出 36px。页头、筛选器和图例使用 Wrap，文本增大或宽度不足时自然换行。

980px 以上使用 7:3 双栏，扫描面在左、数据值班簿在右；以下改为来源摘要、扫描面、完整值班簿的顺序。活动调度单始终位于扫描区域之后。

活动行在 640px 以上横向排列日期、详情和收藏操作；以下先并排日期与收藏按钮，再显示活动详情。

## Elevation & Depth

界面不使用通用阴影。夜色面板、纸面账簿和调度行靠实心色块与间距分层；雷达内部使用半透明扫描扇区、同心圆、道路线和信号外环建立局部深度。

**The Flat Atlas Rule.** 页面容器保持平面，透明度与重叠只用于雷达数据层，不能扩散成发光卡片或玻璃面板。

## Shapes

输入框、筛选按钮、收藏按钮、值班簿和活动行均使用方角。圆形只属于网络开关的机械部件、雷达环与活动信号，不作为页面容器的默认轮廓。

## Components

### Network Switch and Fallback Notice

- 网络开关放在深夜色块中，在线轨道使用钠灯橙，离线轨道使用通知红。
- 回退通知使用通知红实心底与白色文字，并通过 live region 宣布状态变化。

### Search and Filters

- 搜索框使用夜深色底、青色边框和图标，聚焦后切为 3px 钠灯橙边框。
- 分区按钮和收藏筛选至少 48px 高；选中状态使用钠灯橙实心底和墨色文字。

### Radar Scan

- 四个同心环、十字范围线和一条城市路径构成稳定底图。
- 数据变化时扫描扇区在 720ms 内展开，活动信号同步出现；减少动画时直接显示终态。
- 图例同时用颜色块和文字解释信号、范围与分区线。

### Provenance Summary and Dispatch Ledger

- 980px 以下的纸色摘要先显示来源与更新时间，不复制其他指标。
- 完整值班簿列出来源、更新时间、可见活动、本地收藏和忽略响应，并提供刷新按钮。

### Event Dispatch Row

- 日期块使用夜色底与纸色等宽字，活动详情使用衬线标题和系统正文。
- 信号值使用钠灯橙底，标签与纸面警示使用 Danger Ink。
- 收藏按钮保持 48px 触控尺寸；已收藏使用钠灯橙底，未收藏使用夜色底。

## Do's and Don'ts

### Do:

- **Do** 在任何宽度下都让来源与更新时间先于扫描面或与扫描面同时可见。
- **Do** 让离线回退、缓存年龄、筛选和本地收藏保持可区分。
- **Do** 在 320、768、1440 宽度、键盘操作和减少动画模式下检查在线、离线与空结果。

### Don't:

- **Don't** 用地图图钉壁纸或指标卡网格替代调度图与值班簿。
- **Don't** 用颜色作为来源、收藏或故障状态的唯一提示。
- **Don't** 在纸面上直接复用 Fallback Red 作为小号 danger 文本。
