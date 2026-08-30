---
name: 路线分享卡
description: 以防水骑行路线清单组织可分享路线、站点和偏好。
colors:
  asphalt: "#171B1D"
  asphalt-light: "#272D30"
  sheet: "#F2E9CC"
  sheet-bright: "#FFF9E8"
  ink: "#171B1D"
  muted-ink: "#4B514F"
  safety-yellow: "#F2D229"
  cobalt: "#1747D1"
  error-red: "#B7352B"
typography:
  display:
    fontFamily: "system-ui, sans-serif"
    fontSize: "40px"
    fontWeight: 900
    lineHeight: 0.98
    letterSpacing: "-1.3px"
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
  telemetry:
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
  selected-mode:
    backgroundColor: "{colors.safety-yellow}"
    textColor: "{colors.ink}"
    rounded: "{rounded.square}"
    height: "48px"
  cue-sheet:
    backgroundColor: "{colors.sheet-bright}"
    textColor: "{colors.ink}"
    rounded: "{rounded.square}"
    padding: "20px"
---

# Design System: 路线分享卡

## Overview

**Creative North Star: “防水骑行路线清单”**

界面借用骑行活动的防水 cue sheet：安全黄负责发车与当前选择，沥青黑是使用环境，钴蓝路线把站点连成可执行顺序。每个操作都对应 URL 中的一段事实。

路线列表不是通用卡片网格，而是三条编号清单。详情页把路线示意、站点序列和偏好面板放在同一张工作面上，复制反馈留在原位置，不弹出只靠时间消失的提示。

**Key Characteristics:**

- 安全黄发车单、沥青工作面和钴蓝路线。
- 方角按钮、编号站点和折页式内容节奏。
- 路线图只作摘要，真实站点列表承担阅读和操作。
- 280ms 路线切换；减少动画时直接显示终态。

## Colors

- **Asphalt**：页面底场；细横线只表现道路标记。
- **Sheet / Sheet Bright**：路线清单和长文本。
- **Safety Yellow**：页头、当前起点、选中模式和键盘焦点。
- **Cobalt**：路线、自绘站点连接、主要操作和稳定 ID。
- **Error Red**：只用于无法恢复链接的明确错误。

**The Safety Rule.** 黄色只表示当前选择、起点或必须先读的发车信息，不拿来填充普通说明。

## Typography

标题使用高字重系统无衬线体，距离、时长、站点数量、模式 ID 和路线 ID 使用等宽体。项目不加载第三方字体。

等宽体只服务稳定标识与测量信息。中文说明保持普通系统字体，不写成设备面板式大写标签。

- **Display**（900，40px，0.98）：只用于路线目录页标题。
- **Title**（900，25px，1.05）：用于路线名和面板标题。
- **Body**（400，16px，1.45）：用于说明、错误和路线摘要。
- **Telemetry**（900，14px，1.4）：用于路线 ID、模式、距离和站点数。

**The Telemetry Rule.** 等宽体只表示稳定 ID、枚举和测量值，不用于中文说明。

## Layout

内容最大宽度 1240px。详情页在 940px 以上使用 7:3 双栏，路线清单在左、偏好在右；以下先显示偏好，再显示结果，方便用户修改后立即检查。

路线列表在 680px 以下把自绘路线移到文字下方。所有控制使用 Wrap 或可滚动页面，在 320×720 与 200% 文本下不依赖横向滚动。

## Elevation & Depth

界面不用阴影。安全黄、沥青黑、钴蓝和纸色按整块表面分层；网格、路线和站点标记只在 cue sheet 内部重叠。

**The Flat Sheet Rule.** 页面层级靠色块、间距和一像素分隔线表达，不给按钮、面板或路线纸叠加投影。

## Shapes

按钮、输入框、面板、编号和错误通知全部使用方角。路线允许平滑曲线，站点始终使用方形标记；圆形不作为通用容器。

## Components

### Route Manifest Row

每行显示编号、路线说明、时长、距离、站点数和自绘路线。整行可点击，键盘焦点与 hover 使用同一黄色提示。

### Preference Panel

模式使用方角按钮，选中项是黄色实心。起点既可从路线内选择，也可输入中文或带空格的名称；提交后才写入 URL，非法输入在字段旁说明修复方法。

### Cue Sheet

自绘路线只提供视觉摘要，并有单独语义标签。可操作和可朗读信息由下面的真实站点列表承担。切换模式时路线只做一次 280ms 替换；系统请求减少动画时改为零时长。

### Link Error

错误页区分不存在的路线、非法枚举、重复参数、未知参数、空起点、超长起点和完全未匹配地址。每种错误都说明原因和修复动作，并提供返回路线列表的安全入口。

## Do's and Don'ts

### Do:

- **Do** 让安全黄只表示当前选择、起点和先读信息。
- **Do** 用标题、说明和动作表达错误，颜色只作辅助。
- **Do** 保持路线图与站点列表的蓝线、方形标记和编号关系。

### Don't:

- **Don't** 把路线清单改成圆角卡片、指标卡或地图图钉墙。
- **Don't** 给方角面板叠加阴影、渐变或发光边缘。
- **Don't** 让自绘路线代替可聚焦、可朗读的真实站点列表。
