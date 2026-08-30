---
name: 可排序值班板
description: 把稳定身份与行内状态放进一张可操作的活字装版台。
colors:
  stone: "#2E322E"
  stone-deep: "#171A18"
  zinc: "#C9C8BF"
  zinc-light: "#E2E0D7"
  zinc-dark: "#686B65"
  proof-paper: "#F2EBD9"
  ink: "#1A1D1A"
  oxide: "#A43C2B"
  proof-blue: "#2C6670"
typography:
  display:
    fontFamily: "serif"
    fontSize: "36px"
    fontWeight: 900
    lineHeight: 0.94
    letterSpacing: "-1.1px"
  title:
    fontFamily: "serif"
    fontSize: "24px"
    fontWeight: 900
    lineHeight: 1
  body:
    fontFamily: "system-ui, sans-serif"
    fontSize: "16px"
    fontWeight: 400
    lineHeight: 1.55
  measurement:
    fontFamily: "monospace"
    fontSize: "11px"
    fontWeight: 800
    lineHeight: 1.4
    letterSpacing: "1.2px"
rounded:
  square: "0px"
spacing:
  xs: "8px"
  sm: "12px"
  md: "16px"
  lg: "24px"
  xl: "28px"
components:
  button-primary:
    backgroundColor: "{colors.proof-blue}"
    textColor: "#FFFFFF"
    rounded: "{rounded.square}"
    padding: "10px 16px"
  button-mark:
    backgroundColor: "{colors.oxide}"
    textColor: "#FFFFFF"
    rounded: "{rounded.square}"
    padding: "10px 12px"
  input-proof:
    backgroundColor: "#F8F3E6"
    textColor: "{colors.ink}"
    rounded: "{rounded.square}"
    padding: "12px"
---

# Design System: 可排序值班板

## Overview

**Creative North Star: "The Movable-Type Dispatch Galley"**

界面是一张仍在工作的活字装版台。深色石台承接页面，锌制装版框固定列表，成员资料落在校样纸上；排序改变的是字条位置，不是字条里的身份与状态。

视觉信息必须帮助读者看见列表身份。金属框表示可移动单元，校样纸承载可编辑内容，氧化红只标记套准、确认和教学边界。

**Key Characteristics:**

- 深色石台与浅色校样纸形成明确读写层。
- 方角、金属沟槽和紧固件保持装版台的机械感。
- 姓名用衬线标题字，API 与序号只在测量角色中使用等宽字。

## Colors

石墨黑、锌灰和纸白构成主体，氧化红与校样蓝只承担操作和标记。

### Primary

- **Oxide Mark**：用于套准标记、确认状态和教学数据提示。
- **Proof Blue**：用于主要移动操作与输入焦点。

### Neutral

- **Composing Stone**：页面底场与装版台暗面。
- **Zinc Slug**：装版框、字条外壳和金属沟槽。
- **Proof Paper**：说明、姓名、备注与交接状态的读写面。
- **Press Ink**：纸面正文与序号字模。

**The Sparse Mark Rule.** 氧化红只标记状态或定位，不铺成大面积背景。

## Typography

**Display Font:** `serif`
**Body Font:** 平台系统字体
**Label/Mono Font:** `monospace`

**Character:** 衬线字负责活字样张的标题感，系统字体保证表单可读性，等宽字只用于 API、计数和序号。

### Hierarchy

- **Display**：两行项目名，只在说明栏出现。
- **Title**：成员姓名与装版标题。
- **Body**：原理说明、状态回执和输入内容。
- **Measurement**：`ValueKey(member.id)`、序号和英文标签。

**The Measurement Only Rule.** 等宽字不装饰正文，只表示代码、计数或装版标号。

## Layout

页面在 980px 以上使用 310px 说明栏加弹性装版区；更窄时顺序堆叠。字条在 690px 以上按身份、备注、控制三栏排布，更窄时改成单列。页面边距在窄屏为 14px，其余为 28px。

## Elevation & Depth

深度来自材质分层，不靠卡片阴影。石台、锌框、纸张按真实装版顺序叠放，金属渐变、沟槽、划痕和紧固件负责区分层级；标题只保留一处柔和压印阴影。

**The Assembly Order Rule.** 石台、金属、纸张的层级不能颠倒，也不要给纸张补通用悬浮卡片阴影。

## Shapes

所有交互面与容器保持方角。金属框用直线导轨和螺钉收边，纸面用套准十字而不是圆角装饰。

## Components

### Buttons

- **Shape:** 方角。
- **Primary:** 校样蓝底，用于“下移”。
- **Secondary:** 纸面描边，用于“上移”。
- **Focus:** 使用校样蓝焦点边，不用外发光。

### Cards / Containers

- **Zinc Slug:** 锌制外壳包住一张校样纸，左侧状态条在确认后变为氧化红。
- **Proof Sheet:** 纸纤维横线与套准十字只服务材料识别。
- **Composing Galley:** 金属导轨、划痕和四角紧固件构成列表外框。

### Inputs / Fields

- **Style:** 暖纸底、锌灰边框、方角。
- **Focus:** 2px 校样蓝边框。

### Movable Duty Slug

稳定 `ValueKey` 对应完整字条。拖动把整块金属字条移位，备注和确认状态始终留在同一块纸面上。

## Do's and Don'ts

### Do:

- **Do** 让材质层级对应组件所有权与列表身份。
- **Do** 把氧化红留给状态、定位和教学边界。
- **Do** 在 320px 与 200% 字号下保持单列读写顺序。

### Don't:

- **Don't** 把成员行改回通用圆角任务卡。
- **Don't** 用等宽字包装所有正文。
- **Don't** 引入外部纸纹图片或第三方字体。
