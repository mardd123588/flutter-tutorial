---
name: 长卷时间轴
description: 以档案修复桌组织六十年河岸记录、阶段目录与阅读进度。
colors:
  charcoal: "#202725"
  charcoal-soft: "#37423E"
  paper: "#F4EBDD"
  paper-bright: "#FFFAF1"
  mineral-blue: "#1E6675"
  mineral-blue-deep: "#16434D"
  copper: "#B76035"
  moss: "#5D7258"
  rule: "#B9AC98"
rounded:
  control: "8px"
  era: "12px"
spacing:
  xs: "8px"
  sm: "12px"
  md: "22px"
  lg: "34px"
components:
  archive-rail:
    backgroundColor: "{colors.charcoal}"
    textColor: "{colors.paper-bright}"
    rounded: "0"
  era-header:
    backgroundColor: "{colors.mineral-blue-deep}"
    textColor: "{colors.paper-bright}"
    rounded: "{rounded.era}"
  event-row:
    backgroundColor: "transparent"
    textColor: "{colors.charcoal}"
    rounded: "0"
---

# Design System: 长卷时间轴

## Overview

视觉方向是“档案修复桌”。深炭色目录像工作台边缘，矿物蓝标记阶段，铜色表示当前阅读位置，事件始终落在一张连续暖纸上。项目不把 72 条记录拆成同尺寸卡片。

Impeccable 抽签中的深度分层、轨道式导航和大字裁切都不适合作为主世界：前两者会削弱中文长文阅读，后者会把时间顺序变成横向操作。保留的工艺要求是目录层级必须一眼可读，当前状态必须有固定标记，窄屏只减少并列信息，不缩小文字。

## Layout

980px 以上使用 286px 固定目录与单一滚动长卷。更窄时目录进入 pinned 横向栏，主题筛选留在长卷开头。事件行不设固定高度，320px 与 200% 文本允许自然增高。

## Color And Type

纸色占据主要面积。矿物蓝只用于阶段，铜色只用于阅读进度、焦点和主要恢复动作，四类主题使用固定色点。仓库禁止第三方字体，因此界面使用平台衬线回退作为展示字、平台无衬线作为正文；golden 只验证受控测试字体下的构图，实际字形另由 Chrome 截图检查。

## Components

- Archive Rail：主题筛选和六阶段目录，宽屏固定，窄屏变成 pinned 目录。
- Era Header：阶段年份、名称和摘要共用一块矿物蓝表面。
- Event Row：年份、主题点、题名和摘要沿一条连续分隔线排列。
- Reading Spine：`ScrollController` 直接驱动 `CustomPainter`，滚动不触发整页 `setState`。

## Accessibility

目录按钮可键盘操作，跳转后焦点落到阶段标题。CustomPainter 不承载文字或操作；事件年份、题名、主题和摘要由 Widget 与 Semantics 提供。减少动画时目录跳转和焦点反馈直接到终态。

## Do's and Don'ts

- 保持事件顺序、主题称呼和年份在目录、筛选与测试中一致。
- 只有 profile 证明绘制变化不对称时才增加手工 `RepaintBoundary`。
- 不做仿旧噪点、卷轴边框、横向自由缩放或逐项悬浮卡片。
