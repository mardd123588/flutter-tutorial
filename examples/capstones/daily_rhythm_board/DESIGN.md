---
name: 今日节奏板
description: 以日晷记录一天五个节奏落点的 Flutter 示例项目。
colors:
  sand: "#f4e9d1"
  paper: "#fff9ed"
  botanical-ink: "#22352c"
  muted-ink: "#526158"
  terracotta: "#c95436"
  sun-brass: "#d99b18"
  water-blue: "#54767a"
typography:
  display:
    fontFamily: "sans-serif"
    fontSize: "54px"
    fontWeight: 700
    lineHeight: 1.02
    letterSpacing: "-2.2px"
  headline:
    fontFamily: "sans-serif"
    fontSize: "27px"
    fontWeight: 700
    lineHeight: 1.15
    letterSpacing: "-0.7px"
  body:
    fontFamily: "sans-serif"
    fontSize: "17px"
    fontWeight: 400
    lineHeight: 1.65
spacing:
  xs: "12px"
  sm: "18px"
  md: "28px"
  lg: "42px"
  page: "56px"
components:
  rhythm-selected:
    backgroundColor: "{colors.botanical-ink}"
    textColor: "{colors.paper}"
    rounded: "0"
    padding: "16px 18px"
  date-stamp:
    backgroundColor: "{colors.botanical-ink}"
    textColor: "{colors.paper}"
    rounded: "0"
    padding: "12px 18px"
---

# Design System: 今日节奏板

## Overview

**Creative North Star: “日晷记录页”**

界面像一张放在桌面的日照记录：大面积沙纸托住半圆日晷，五个时间落点排列在旁边，选择动作直接改变影针和底部说明。它是第一部分统筹项目的独立视觉系统，不向其他项目输出主题或组件。

**Key Characteristics:**

- 半圆日晷是唯一主图形。
- 方正的信息条代替通用圆角卡片。
- 植物墨承担选中状态，黄铜、陶土和水蓝区分时间性质。
- 宽屏双栏，980px 以下按任务顺序改为单栏。

## Colors

沙色和纸色提供安静底面，植物墨承担正文和选中状态。三个强调色都来自日照、土壤和停顿的题材，不用于随机装饰。

**The One Selection Rule.** 同一时刻只有一个节奏条使用实心植物墨；其他条保持纸面和细边界。

## Typography

所有文字使用平台无衬线字族，不打包字体。大标题紧凑，正文保持较高行距，时间数字使用制表数字避免选择时跳动。

- **Display**（700，54px，1.02）：页面标题；窄屏由 Flutter 文本布局自然换行。
- **Headline**（700，27px，1.15）：列表和选中详情标题。
- **Body**（400，17px，1.65）：任务说明和提示。
- **Label**（700，15px）：日期、时间和节奏条标题。

## Layout

页面内容最大宽度为 1380px。980px 及以上使用 11:8 双栏，日晷与列表间距 42px；更窄时依次显示标题、日晷、列表和选中说明，页面水平留白缩为 20px。日晷使用固定 1.18 宽高比，不能靠截断图形来适配窄屏。

## Elevation & Depth

只有日晷纸面使用 `Offset(0, 18)`、`blurRadius 38` 的柔和阴影。列表、日期印章和选中说明依靠色面与边线分层，不重复加阴影。

## Shapes

日期、节奏条和底部说明都是直角矩形。日晷上缘使用半圆轮廓，圆只出现在轴点和刻度关系中。不要把普通内容包装成圆角卡片或胶囊。

## Components

### Sundial Panel

纸色面板包含图例、半圆轨道、刻度、影针和 07:00—19:00 边界。整个图形向语义树暴露为一张带当前时间和标题的图片，内部绘制细节不重复朗读。

### Rhythm Rows

每行是完整按钮。默认状态使用纸面、细边界和对应强调色；选中状态切换为植物墨底与纸色文字。键盘焦点、语义选中状态和点击结果必须一致。

### Date Stamp

日期印章使用植物墨实心面，只显示固定示例日期，不读取系统当天时间，保证测试和截图可复现。

### Selected Entry

底部实心信息条重复当前时间与标题，并给出一句行动提示。窄屏允许内容换行，不设置固定高度。

## Do's and Don'ts

### Do:

- **Do** 让日晷影针、选中行和底部说明由同一个 `RhythmEntry` 驱动。
- **Do** 保持日期、时区和五条数据固定，确保测试可复现。
- **Do** 在 320、768、1440 宽度和 200% 文本缩放下检查任务完整性。

### Don't:

- **Don't** 加入待办勾选、统计环或生产力仪表盘组件。
- **Don't** 为其他项目复用这组配色、日晷组件或节奏条样式。
- **Don't** 用动画掩盖选择结果；影针变化必须在减少动画时仍清楚。
