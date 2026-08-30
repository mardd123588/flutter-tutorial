---
name: 植物照护台
description: 用温室仪表把共享状态、照护动作与可撤销反馈放在同一张工作板上。
colors:
  forest: "#23352D"
  forest-deep: "#14221C"
  verdigris: "#3F7162"
  verdigris-dark: "#294D42"
  fog: "#E8E7DC"
  mineral: "#F5F0DF"
  ink: "#18201C"
  copper: "#C08345"
  copper-dark: "#74431F"
  vermilion: "#C84D36"
  quiet: "#66726A"
typography:
  display:
    fontFamily: "serif"
    fontSize: "40px"
    fontWeight: 900
    lineHeight: 0.96
    letterSpacing: "-1.2px"
  title:
    fontFamily: "serif"
    fontSize: "25px"
    fontWeight: 900
    lineHeight: 1
  body:
    fontFamily: "system-ui, sans-serif"
    fontSize: "15px"
    fontWeight: 400
    lineHeight: 1.5
  measurement:
    fontFamily: "monospace"
    fontSize: "12px"
    fontWeight: 800
    lineHeight: 1.4
rounded:
  square: "0px"
spacing:
  xs: "8px"
  sm: "12px"
  md: "16px"
  lg: "20px"
  xl: "28px"
components:
  button-care:
    backgroundColor: "{colors.vermilion}"
    textColor: "#FFFFFF"
    rounded: "{rounded.square}"
    padding: "10px 16px"
  button-secondary:
    backgroundColor: "{colors.mineral}"
    textColor: "{colors.forest}"
    rounded: "{rounded.square}"
    padding: "10px 16px"
  chip-selected:
    backgroundColor: "{colors.mineral}"
    textColor: "{colors.ink}"
    rounded: "{rounded.square}"
    padding: "8px 12px"
---

# Design System: 植物照护台

## Overview

**Creative North Star: "The Conservatory Phenology Board"**

界面是一张温室值班员会反复读取和维护的仪表板。氧化绿金属固定植物记录，矿物白标签承载文字，雾面玻璃表盘把湿度、目标刻度与铜针放在同一读数面上。

状态变化必须可读。朱红检修戳指出待照护项，铜针动画表示读数过渡，操作回执只说明本次变化与撤销结果。

**Key Characteristics:**

- 氧化金属、雾面玻璃、铜针和矿物标签构成真实仪器层次。
- 湿度同时通过表盘、目标标记和滑动刻度读取。
- 朱红只用于照护动作与检修状态。

## Colors

冷暗森林绿负责工作环境，矿物白保证读数清楚，铜色和朱红分别表示机械读数与照护动作。

### Primary

- **Verdigris Plate**：温室面板与仪器外框。
- **Vermilion Service**：待照护检修戳与“记录浇水”。

### Secondary

- **Copper Needle**：指针、目标刻度、紧固件和状态值。

### Neutral

- **Deep Forest**：页面底场。
- **Mineral Label**：植物记录、回执与表盘标签。
- **Instrument Ink**：纸面标题、数值和说明。

**The Service Color Rule.** 朱红只表示需要动作、已执行动作或检修标记。

## Typography

**Display Font:** `serif`
**Body Font:** 平台系统字体
**Label/Mono Font:** `monospace`

**Character:** 衬线标题像温室铭牌，系统字体负责说明和操作，等宽字只表示区域、读数、API 与计数。

### Hierarchy

- **Display**：项目名。
- **Title**：植物名、工作台与回执标题。
- **Body**：操作说明、观察记录和回执。
- **Measurement**：湿度、目标、区域和框架 API。

**The Instrument Label Rule.** 等宽字只进入测量与系统标签，不替代正文。

## Layout

页面在 1050px 以上使用弹性照护台加 330px 操作回执栏；更窄时顺序堆叠。植物仪表在 650px 以上按身份、表盘、控制三栏排布，更窄时改成单列。页面边距在窄屏为 14px，其余为 28px。

## Elevation & Depth

界面不用通用卡片阴影。氧化金属位于底层，矿物标签嵌在金属框内，表盘再以铜环、雾面玻璃、刻度和凝露点建立局部深度。铜制滑块保留一处小而明确的投影。

**The Instrument Stack Rule.** 金属、标签、玻璃、指针必须按仪器装配顺序出现，不能退化成进度条加白卡片。

## Shapes

仪器、按钮、筛选片和回执都保持方角。圆形只属于湿度表盘、螺栓和检修戳，不作为容器默认形状。

## Components

### Buttons

- **Shape:** 方角。
- **Primary:** 朱红底，用于“记录浇水”。
- **Secondary:** 矿物白或透明描边，用于查看观察与撤销。
- **Focus:** 铜色或深绿焦点边，保持可见。

### Chips

- **Style:** 方角筛选片，选中时使用矿物白底。
- **State:** 未选中为深森林底，边框保持氧化绿或铜色。

### Cards / Containers

- **Instrument Frame:** 氧化绿金属包住矿物标签，左侧服务条表示照护状态。
- **Action Register:** 深绿账册线条与铜色装订边承载共享状态反馈。
- **Status Rail:** 标题、说明和一行教学数据计数，不使用独立指标卡。

### Moisture Dial

表盘含 20 个刻度、5 格主刻度、朱红目标标记、铜针、雾面玻璃和滑动刻度。`TweenAnimationBuilder` 同时驱动指针与滑块，减少动画时直接显示终态。

### Care Receipt

矿物纸回执带朱红检修戳。`AnimationController` 只控制本次回执的淡入与位移，不给整页添加装饰动画。

## Do's and Don'ts

### Do:

- **Do** 让每个视觉状态都能回指湿度、目标或照护动作。
- **Do** 同时保留表盘读数与文本语义。
- **Do** 在 320px 与 200% 字号下按标题、筛选、仪表、回执顺序阅读。

### Don't:

- **Don't** 用通用水平进度条替代表盘。
- **Don't** 把状态栏改成两张大数字指标卡。
- **Don't** 引入外部温室照片、纹理图片或第三方字体。
