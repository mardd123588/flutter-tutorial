---
name: 小型展览编辑器
description: 以可移动展签轨道为视觉原型的策展工作台。
colors:
  deep-blue: "#0A1E4B"
  wall-blue: "#153A8A"
  label-paper: "#F3E9D0"
  field-paper: "#FFFBF1"
  brass: "#D8B55B"
  coral: "#FF6F61"
  ink: "#172039"
  quiet-ink: "#596078"
  status-paper: "#FFD5CD"
typography:
  display:
    fontFamily: "system-ui, sans-serif"
    fontSize: "36px"
    fontWeight: 800
    lineHeight: 1
    letterSpacing: "-1.2px"
  headline:
    fontFamily: "system-ui, sans-serif"
    fontSize: "27px"
    fontWeight: 800
    lineHeight: 1.1
    letterSpacing: "-0.6px"
  title:
    fontFamily: "system-ui, sans-serif"
    fontSize: "22px"
    fontWeight: 800
    lineHeight: 1.05
  body:
    fontFamily: "system-ui, sans-serif"
    fontSize: "16px"
    fontWeight: 400
    lineHeight: 1.5
rounded:
  square: "0px"
spacing:
  xs: "8px"
  sm: "14px"
  md: "18px"
  lg: "22px"
  xl: "28px"
components:
  button-save:
    backgroundColor: "{colors.coral}"
    textColor: "{colors.ink}"
    rounded: "{rounded.square}"
    padding: "12px 18px"
  input:
    backgroundColor: "{colors.field-paper}"
    textColor: "{colors.ink}"
    rounded: "{rounded.square}"
    padding: "14px"
  exhibit-label:
    backgroundColor: "{colors.label-paper}"
    textColor: "{colors.ink}"
    rounded: "{rounded.square}"
    padding: "14px 16px 18px"
---

# Design System: 小型展览编辑器

## Overview

**Creative North Star: "可移动展签轨道"**

界面像一面正在布展的蓝色展墙。纸色展签可以被选择、筛选和重新编排，右侧编辑台则像策展人的登记簿。黄铜分隔提供展陈秩序，珊瑚色只用于当前选择和主要提交动作。

这是工作界面，视觉辨识度不能妨碍输入。字段、焦点、错误和 disabled 状态沿用 Material 交互合同，同时保持方角纸张与展墙色域。

**Key Characteristics:**

- 深蓝展墙、纸色展签和黄铜分隔
- 方角输入与纸张边缘
- 珊瑚色表示当前选择或提交动作
- 展墙和编辑台按可用宽度并排或顺排

## Colors

调色来自展墙、标签纸、金属挂轨和校对标记，不使用无来源的装饰色。

### Primary

- **展墙蓝**：展品区域和主要按钮。
- **深蓝背景**：整页工作区与展墙外的留白。

### Secondary

- **珊瑚校对色**：保存按钮、选中展签边框和输入 selection。
- **黄铜挂轨色**：分隔线、未选按钮边框和展墙结构。

### Neutral

- **展签纸**：展品卡与编辑台。
- **字段纸**：输入框内部，和展签纸保持轻微层次差。
- **主墨色**：标题、正文和操作文字。
- **安静墨色**：年份、艺术家和辅助说明。
- **状态纸**：保存、删除与验证状态消息。

**The Coral Proof Rule.** 珊瑚色只表示选中、提交或需要修正的状态，不作背景铺色。

## Typography

项目使用平台系统字体。页面标题、展墙标题和展品标题通过字重和尺寸形成层次；字段与正文保持常规字重，避免让工作台变成海报。

### Hierarchy

- **Display**：应用名称。
- **Headline**：编辑台和展墙区标题。
- **Title**：展品名称。
- **Body**：说明、字段内容和状态消息。

## Layout

980 像素以上使用展墙与 420 像素编辑台双栏，展墙获得剩余空间；以下改为上下排列。外层只有一个滚动主体。

展签按真实内容使用 Wrap，宽度在同一面展墙中保留轻微差异。字段不写固定高度，多行说明允许增长。筛选框位于展墙标题和展签之间，始终先于结果出现。

## Elevation & Depth

系统使用色块、边框和纸张叠放建立层级，不使用投影。选中展签通过较粗珊瑚边框表现，输入焦点交给 Material 的可见描边。

**The Flat Wall Rule.** 展墙上的纸张保持平贴；层级来自选择状态，不来自卡片阴影。

## Shapes

展墙、展签、输入、按钮和状态消息都使用方角。细边框表达纸张和登记表，黄铜水平线表达挂轨。

## Components

### Buttons

- 保存使用珊瑚实心底；新建使用透明深蓝底和黄铜边框。
- 删除按钮在没有选中展品时保持 disabled，不隐藏。
- 文案同时给出动作和快捷键，但不依赖快捷键才能完成任务。

### Inputs

- 字段使用字段纸背景、方角边框和显式 label。
- 首次新建保持干净；第一次提交失败后才随输入更新错误。
- 错误文字说明具体规则，页面状态说明提交未完成。

### Exhibit Labels

- 纸色底、主墨色文字和紧凑的编号—年份头部。
- 选中状态使用珊瑚粗边框，并在语义树中暴露 selected。
- 不写固定高度，长标题和文本缩放可以增加高度。

### Status Message

- 状态纸承载新增、保存、删除和验证结果。
- 作为 live region 播报，文字保持短促且可恢复。

## Do's and Don'ts

### Do:

- **Do** 让筛选、选择和编辑在同一视口关系中清楚可见。
- **Do** 同时验证鼠标、Tab、Enter 和 Ctrl/Cmd 快捷键。
- **Do** 在 320、768、1440 宽度和 200% 文本缩放下检查字段与展签。

### Don't:

- **Don't** 用阴影、圆角和渐变把展签改成通用卡片。
- **Don't** 在新建动作后立刻显示整表错误。
- **Don't** 让 hover 成为唯一可见的可操作提示。

