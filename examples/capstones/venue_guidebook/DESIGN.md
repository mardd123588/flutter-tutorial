---
name: 场馆导览册
description: 以折页式公共导视手册组织地点、楼层、路线和语言切换。
colors:
  cobalt: "#1238C7"
  cobalt-deep: "#08227F"
  chartreuse: "#D8FF3E"
  paper: "#F4EDCF"
  paper-bright: "#FFF9E7"
  ink: "#111827"
  muted-ink: "#4B5363"
  rule: "#B8B08F"
  error: "#B6322A"
typography:
  display:
    fontFamily: "serif"
    fontSize: "42px"
    fontWeight: 900
    lineHeight: 0.98
    letterSpacing: "-1.2px"
  title:
    fontFamily: "system-ui, sans-serif"
    fontSize: "25px"
    fontWeight: 900
    lineHeight: 1.05
  body:
    fontFamily: "system-ui, sans-serif"
    fontSize: "16px"
    fontWeight: 400
    lineHeight: 1.45
  index:
    fontFamily: "monospace"
    fontSize: "14px"
    fontWeight: 900
    lineHeight: 1.4
rounded:
  square: "0px"
spacing:
  xs: "8px"
  sm: "12px"
  md: "18px"
  lg: "22px"
components:
  primary-action:
    backgroundColor: "{colors.cobalt}"
    textColor: "#FFFFFF"
    rounded: "{rounded.square}"
    height: "48px"
  selected-filter:
    backgroundColor: "{colors.chartreuse}"
    textColor: "{colors.ink}"
    rounded: "{rounded.square}"
    height: "48px"
  search-field:
    backgroundColor: "{colors.paper-bright}"
    textColor: "{colors.ink}"
    rounded: "{rounded.square}"
    height: "48px"
  venue-row:
    backgroundColor: "{colors.paper-bright}"
    textColor: "{colors.ink}"
    rounded: "{rounded.square}"
    padding: "18px"
---

# Design System: 场馆导览册

## Overview

**Creative North Star: “折页式公共导视手册”**

界面像入口处可随手取用的导览册：钴蓝封面负责方向和导航，荧光黄绿标签标出当前楼层、筛选与日期，暖纸色承载需要细读的地点信息。建筑分隔线贯穿页面，列表使用清楚的编号与稳定顺序。

地点查找是页面的主要任务。搜索、楼层和标签放在同一块深蓝操作面上；结果紧接其后。详情页把楼层图和真实房间列表并排，窄屏时按同样的阅读顺序改为上下排列。

**Key Characteristics:**

- 钴蓝封面、暖纸目录和荧光黄绿索引标签
- 方角导航、筛选、地点行与房间行
- 建筑平面线条与折页分隔，不使用地图图钉墙
- 自绘图只做摘要，真实列表承担操作和语义

## Colors

钴蓝建立公共导视的识别度，暖纸色保证长文本易读，荧光黄绿只标出当前状态和需要先看的信息。

### Primary

- **Guide Cobalt**：页头、地点编号和主要动作。
- **Deep Directory Blue**：导航、搜索与筛选工作面、楼层图底场。

### Secondary

- **Fluorescent Floor Tab**：当前筛选、楼层标记、日期和焦点提示。

### Tertiary

- **Link Error Red**：无法恢复的 URL 与明确错误状态。

### Neutral

- **Directory Paper / Bright Directory Paper**：页面底色、地点行、房间行和说明面板。
- **Guide Ink / Muted Guide Ink**：标题、正文和次要说明。
- **Fold Rule**：纸面折线和结构分隔。

**The Fluorescent Tab Rule.** 黄绿色只表示当前选择、楼层编号、日期或键盘焦点，不填充普通说明面板。

## Typography

**Display Font:** 平台衬线体（`serif`）  
**Body Font:** 平台系统无衬线体（`system-ui, sans-serif`）  
**Label/Mono Font:** 平台等宽体（`monospace`）

**Character:** 大标题采用厚重衬线体，像公共文化场馆的印刷封面；正文保持干净，编号和楼层代码使用等宽体。

### Hierarchy

- **Display**（900，42px，0.98）：应用封面和顶层页面标题。
- **Title**（900，25px，1.05）：地点名、路线名与面板标题。
- **Body**（400，16px，1.45）：地点摘要、操作说明与错误恢复建议。
- **Index**（900，14px，1.4）：地点编号、楼层代码和数量。

**The Index Type Rule.** 等宽体只表示稳定编号、楼层、日期和数量，不用于正文说明。

## Layout

页面内容最大宽度为 1240px，外边距 18px。桌面端左侧使用 104px `NavigationRail`；900px 以下改用顶栏和 `NavigationDrawer`。地点详情在 980px 以上使用 6:4 双栏，以下先显示楼层图，再显示房间列表。

搜索、楼层和标签使用 `Wrap`。320px 宽度或 200% 文本下，控件向下换行，不依赖横向滚动。背景每 240px 绘制一条折页线，保持纸面方向感。

## Elevation & Depth

界面不使用阴影。层级由整块钴蓝、深蓝、纸色和间距表达；楼层图内部通过平面房间块、边界线和路线重叠建立局部深度。

**The Flat Guide Rule.** 面板、按钮、地点行和导航保持平面，不添加玻璃、发光或通用卡片投影。

## Shapes

按钮、输入、筛选、抽屉、地点行和错误面板全部使用方角。方形是楼层、房间和路线节点的统一标记；圆角胶囊不进入这个系统。

## Components

### Buttons

- **Shape:** 方角，最小高度 48px。
- **Primary:** 钴蓝底、白字，用于恢复链接和主要动作。
- **Hover / Focus:** hover 使用黄绿色浅层，焦点使用清楚的黄绿色提示。
- **Secondary:** 透明或深蓝底配 1px 边框；选中后改为黄绿色实心。

### Chips

- **Style:** 标签是方形小色块，楼层使用黄绿色与等宽字，属性使用墨色与白字。
- **State:** 筛选按钮同时使用文字、实心底和 Semantics `selected` 表达状态。

### Cards / Containers

- **Corner Style:** 方角。
- **Background:** 亮纸色与稍深纸色交替，帮助扫描长列表。
- **Shadow Strategy:** 无阴影。
- **Border:** 控件使用 1px 实线；内容行主要靠色块与间距分隔。
- **Internal Padding:** 18px 为主要面板和列表行内边距。

### Inputs / Fields

- **Style:** 亮纸色底、墨色文字、方角 1px 边框。
- **Focus:** 3px 黄绿色边框；快捷键提示在深蓝底上使用浅蓝白文字。
- **Error / Disabled:** 错误使用文字说明原因和恢复动作，不只变颜色。

### Navigation

宽屏使用深蓝 `NavigationRail`，窄屏使用同色顶栏和纸色 `NavigationDrawer`。当前目的地同时显示黄绿色指示、实心图标和文字；语言按钮固定使用黄绿色方块。

### Floor Plan and Room List

楼层图使用深蓝底、纸色边界、钴蓝房间块和黄绿色路线。图形只暴露一条 `image` 语义摘要。房间行可聚焦、可选择，选中结果在列表内显示并由 live region 宣布。

## Do's and Don'ts

### Do:

- **Do** 在每个断点保留同一目的地、URL 和任务顺序。
- **Do** 让楼层图摘要与房间列表使用相同的房间名称和楼层。
- **Do** 同时用文字、形状和语义状态说明当前选择。

### Don't:

- **Don't** 用地图图钉、圆角卡片或指标网格替代导览目录。
- **Don't** 让黄绿色成为普通装饰底色。
- **Don't** 把自绘楼层图变成唯一操作入口。
