---
name: 票券排版器
description: 以行李路由标签为视觉原型的约束与排版实验台。
colors:
  scanner-blue: "#0D2B4A"
  route-blue: "#1646A0"
  signal-yellow: "#F4C64E"
  ticket-paper: "#F7F0DD"
  ink: "#111820"
  muted-ink: "#44505A"
typography:
  display:
    fontFamily: "system-ui, sans-serif"
    fontSize: "36px"
    fontWeight: 800
    lineHeight: 1
    letterSpacing: "-1.2px"
  title:
    fontFamily: "system-ui, sans-serif"
    fontSize: "26px"
    fontWeight: 900
    lineHeight: 1.05
    letterSpacing: "-0.7px"
  body:
    fontFamily: "system-ui, sans-serif"
    fontSize: "16px"
    fontWeight: 400
    lineHeight: 1.55
  label:
    fontFamily: "system-ui, sans-serif"
    fontSize: "12px"
    fontWeight: 800
    lineHeight: 1.2
    letterSpacing: "1.4px"
rounded:
  square: "0px"
spacing:
  xs: "8px"
  sm: "12px"
  md: "18px"
  lg: "24px"
  xl: "32px"
components:
  format-button:
    backgroundColor: "{colors.scanner-blue}"
    textColor: "{colors.ticket-paper}"
    rounded: "{rounded.square}"
    padding: "14px 16px"
  format-button-selected:
    backgroundColor: "{colors.signal-yellow}"
    textColor: "{colors.ink}"
    rounded: "{rounded.square}"
    padding: "14px 16px"
  ticket-tag:
    backgroundColor: "{colors.ticket-paper}"
    textColor: "{colors.ink}"
    rounded: "{rounded.square}"
    padding: "6px 9px"
---

# Design System: 票券排版器

## Overview

**Creative North Star: "行李路由标签"**

界面借用交通票据、分拣标签和闸口标牌的视觉语言。深蓝舞台提供高对比工作区，纸色票面保留印刷品的密度，黄色只用于规则说明和当前选项。

布局变化本身就是内容。宽度切换后，票根、标签和闸口牌要像同一张票据在重新排版，不能退回通用响应式卡片。

**Key Characteristics:**

- 方角、细边框和印刷标签感
- 深蓝工作台与暖色票纸
- 黄色只表示当前选择或布局规则
- 局部角标越界，主体仍留在正常约束流

## Colors

颜色分成工作台、票纸、路线标识和警示信号四组，所有角色都能在交通票据中找到对应物。

### Primary

- **路线蓝**：用于闸口牌和票号等路线识别信息。

### Secondary

- **信号黄**：用于选中按钮和布局规则面板，不作大面积装饰。

### Neutral

- **扫描台蓝**：应用背景和票面舞台。
- **票纸**：票面主体和标签底色。
- **主墨色**：正文、边框和路由条。
- **弱墨色**：日期、说明和穿孔线。

**The Signal Rule.** 实心黄色只表示当前选项或必须先读的布局规则。

## Typography

所有文字使用平台系统字体，不下载或打包第三方字体。标题依靠高字重、紧凑行高和少量负字距建立票据标题感；小标签使用较宽字距区分测量信息。

### Hierarchy

- **Display**：应用名称，只在页头出现一次。
- **Title**：票面路线和规则标题。
- **Body**：说明文字，允许在窄屏自然换行。
- **Label**：票号、闸口、座位和测量标签。

**The Printed Label Rule.** 大写与宽字距只用于短标签，不用于中文正文。

## Layout

页面在 980 像素以上使用规则面板与票面舞台双栏，以下改为上下排列。票面目标宽度由预设给出，但最终宽度必须服从局部父约束。

票面在 430 像素以上使用横向票根，以下改为纵向票根。标签始终按真实内容使用 Wrap；三个预设按钮也允许换行。

## Elevation & Depth

工作台和规则面板保持平面。票面使用一层向下偏移的柔和阴影，表现纸张离开扫描台；不在按钮、标签和面板上叠加阴影。

**The One Sheet Rule.** 同一屏只有票面可以被抬起，其余层级由色块和间距区分。

## Shapes

所有控件和容器使用方角。穿孔、细边框和条码形成票据结构；不加入圆角胶囊或软卡片轮廓。

## Components

### Format Buttons

- 未选中使用透明深蓝底与浅蓝边框。
- 选中使用信号黄实心底和主墨色文字。
- 键盘焦点必须可见，Enter 或 Space 与点击结果一致。

### Ticket Tags

- 纸色底、主墨色一像素边框和紧凑内边距。
- 数量保持受控；放不下时换行，不缩小文字。

### Ticket Surface

- 主信息区和票根由 Flex 或 Column 组合。
- 闸口牌是唯一允许越过票面边界的视觉元素。
- positioned 元素不能承担当下可点击任务。

## Do's and Don'ts

### Do:

- **Do** 让真实约束决定票面宽度、票根方向和标签换行。
- **Do** 用窄票、标准票和宽票验证同一套视觉语言。
- **Do** 在 320、768、1440 宽度和 200% 文本缩放下检查完整信息。

### Don't:

- **Don't** 用整页 Stack 代替正常布局。
- **Don't** 把黄色用于不可操作的普通装饰。
- **Don't** 用圆角卡片、渐变或发光效果软化票据结构。

