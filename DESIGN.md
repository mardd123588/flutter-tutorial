---
name: Flutter 框架教程
description: 以套色校样册组织学习路线和技术正文的中文教程站点。
colors:
  paper: "#f2ebdd"
  paper-light: "#f8f3e9"
  navy-ink: "#183b56"
  vermillion-ink: "#d94b3d"
  teal-ink: "#167a7c"
  gold-ink: "#b77908"
  body-ink: "#172c3d"
  muted-ink: "#405564"
typography:
  display:
    fontFamily: "Noto Serif CJK SC, Source Han Serif SC, Songti SC, serif"
    fontSize: "clamp(3.1rem, 6.2vw, 5.8rem)"
    fontWeight: 780
    lineHeight: 1.04
    letterSpacing: "-0.035em"
  body:
    fontFamily: "Noto Sans CJK SC, Source Han Sans SC, Microsoft YaHei, system-ui, sans-serif"
    fontSize: "17px"
    fontWeight: 400
    lineHeight: 1.82
  label:
    fontFamily: "Cascadia Code, SFMono-Regular, Consolas, monospace"
    fontSize: "0.78rem"
    fontWeight: 700
    lineHeight: 1.4
rounded:
  code: "4px"
  block: "14px"
spacing:
  xs: "5px"
  sm: "14px"
  md: "28px"
  lg: "38px"
  section: "76px"
components:
  action-solid:
    backgroundColor: "{colors.vermillion-ink}"
    textColor: "{colors.paper-light}"
    rounded: "0"
    padding: "8px 12px"
  action-outline:
    backgroundColor: "transparent"
    textColor: "{colors.navy-ink}"
    rounded: "0"
    padding: "0 20px"
  route-sheet:
    backgroundColor: "{colors.paper-light}"
    textColor: "{colors.navy-ink}"
    rounded: "0"
    padding: "10px 22px"
---

# Design System: Flutter 框架教程

## Overview

**Creative North Star: “套色校样册”**

站点把知识依赖表现为正在校准的印刷层：暖纸负责长时间阅读，navy 承担正文，vermillion、teal 和 gold 标出路线与关系。首页可以有明显的套色动作，正文页必须安静，让代码、错误现象和章节前置比装饰更醒目。

教程站点和 Flutter 示例项目不共享视觉令牌。每个示例项目应有独立题材、信息结构和项目级 `DESIGN.md`，不能把本站的纸页样式复制过去。

**Key Characteristics:**

- 暖纸底、四色专墨、套准标记和少量网点。
- 首页承担路线表达，正文保持 65–75ch 的阅读宽度。
- 实心墨只用于可操作元素或明确选中状态。
- 不加载远程字体，也不打包第三方字体。

## Colors

navy 是主要阅读墨色，vermillion 是首要行动色，teal 与 gold 只负责区分知识层或路线。纸色始终占据最大面积。

**The Solid Ink Rule.** 实心色块必须可点击或表示当前选中状态；版本、统计和说明文字使用细线、文字或套准标记。

**The Quiet Page Rule.** 正文页不同时使用三种强调色。单页的强调色由内容决定，而不是为了维持首页的四色密度。

## Typography

展示标题使用平台提供的中文衬线字族，正文使用平台无衬线字族，概念 ID、版本和数值使用等宽字族。站点不下载字体文件；不同系统的字形和换行差异属于已接受的隐私与性能取舍。

- **Display**（780，响应式，1.04）：只用于首页主标题和少量章节主标题，最大不超过 5.8rem。
- **Headline**（760，1.08–1.1）：用于章节层级和纸页标题。
- **Body**（400，17px，1.82）：用于正文，段落和列表不超过 72ch。
- **Label**（700，0.72–0.78rem）：用于版本、概念 ID 和项目状态，保留制表数字。

**The Local Type Rule.** 不为视觉一致性引入远程或打包字体。若平台缺少首选字族，允许回退，但必须在 390、768 和 1440 宽度检查换行。

## Layout

首页在宽屏使用“左侧声明、右侧八张路线纸页”的双栏结构；1100px 以下改为单栏，640px 以下缩小留白并让行动按钮占满可用宽度。所有网格轨道都使用可收缩的 `minmax(0, 1fr)`，容器和子项同时设置 `min-width: 0`，避免中文标题把页面撑出视口。

正文容器最大宽度为 780px。章节标题上方的间距大于下方间距；元数据、代码和正文之间按 14、28、38px 的节奏分组。

## Elevation & Depth

纸页和代码块使用向下偏移的柔和阴影，表达纸张离开桌面的高度。普通正文、导航和说明区保持平面，不用无偏移光晕。

- **Route sheet:** `0 16px 38px rgba(23, 44, 61, 0.12)`，仅用于首页路线纸页。
- **Code block:** `0 12px 28px rgba(23, 44, 61, 0.08)`，用于区分可运行源码与正文。
- **Registration sample:** `0 22px 56px rgba(23, 44, 61, 0.12)`，只用于解释套色关系的示例。

## Shapes

路线纸页、按钮和元数据印章保持直角。代码块使用 14px 圆角，行内代码使用 4px 圆角。圆形只表示套准点或图形中的测量标记，不作为通用卡片装饰。

## Components

### Route Sheets

八张纸页都是真实链接。第一张展示当前可学内容和“从第一章开始”，其余纸页显示完整部分名称、规划章数并链接到路线说明。键盘焦点与 hover 使用同一抬升关系；触摸端不依赖 hover 才能看到文字。

### Actions

首要行动使用 vermillion 实心直角块，次要行动使用 navy 细边框。所有行动至少 48px 高，`:focus-visible` 使用 gold 轮廓，文字直接说明动作。

### Lesson Metadata

章节开头固定显示种类、`requires` 和 `provides`。概念 ID 使用等宽字体，内容来自 frontmatter，不在组件里维护第二份数据。

### Navigation

导航使用接近纸色的不透明背景和细分隔线。移动端保留站名、搜索和菜单入口；不能通过隐藏站名来解决宽度问题。

## Do's and Don'ts

### Do:

- **Do** 让知识依赖、版本和项目状态来自真实数据，并明确区分当前内容与首版规划。
- **Do** 在首页纸页或关系示例中使用克制的网点和套准偏移。
- **Do** 同时检查 390、768、1440 宽度、键盘焦点和减少动画设置。
- **Do** 保持正文页面安静，让代码和错误信息成为主要视觉证据。

### Don't:

- **Don't** 用实心 navy 包装不可操作的版本或统计信息。
- **Don't** 把八部分重新做成同尺寸图标卡片网格。
- **Don't** 加载远程字体、分析脚本、社交组件或装饰性 emoji。
- **Don't** 把某个 Flutter 项目的配色或组件提升为所有项目共享的 UI 包。
