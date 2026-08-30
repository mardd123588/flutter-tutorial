---
name: 社区工坊排期台
description: 以交通调度磁条板组织活动日、场馆、讲师和工坊排期。
colors:
  ink: "#131B1E"
  ink-soft: "#263238"
  dispatch-blue: "#17547A"
  dispatch-blue-deep: "#0D344E"
  enamel: "#F0E6D2"
  paper: "#FFFAEF"
  active-green: "#4FD18B"
  action-orange: "#F39A43"
  error-red: "#B43A32"
  steel: "#64757B"
  rule: "#9AA4A5"
typography:
  display:
    fontFamily: "Georgia, serif"
    fontSize: "42px"
    fontWeight: 800
    lineHeight: 0.98
    letterSpacing: "-1.2px"
  title:
    fontFamily: "system-ui, sans-serif"
    fontSize: "25px"
    fontWeight: 800
    lineHeight: 1.08
  body:
    fontFamily: "system-ui, sans-serif"
    fontSize: "16px"
    fontWeight: 400
    lineHeight: 1.45
rounded:
  control: "6px"
  panel: "8px"
spacing:
  xs: "6px"
  sm: "10px"
  md: "18px"
  lg: "24px"
components:
  primary-action:
    backgroundColor: "{colors.action-orange}"
    textColor: "{colors.ink}"
    rounded: "{rounded.control}"
    height: "48px"
  filter-desk:
    backgroundColor: "{colors.dispatch-blue-deep}"
    textColor: "{colors.paper}"
    rounded: "{rounded.panel}"
    padding: "16px"
  session-strip:
    backgroundColor: "{colors.active-green}"
    textColor: "{colors.ink}"
    rounded: "{rounded.control}"
  field:
    backgroundColor: "{colors.paper}"
    textColor: "{colors.ink}"
    rounded: "{rounded.control}"
    focusColor: "{colors.active-green}"
---

# Design System: 社区工坊排期台

## Overview

**Creative North Star: “交通调度磁条板”**

界面借用社区活动中心里常见的调度板：深色总控栏给出当前任务，蓝色工作面承载筛选，暖纸色网格按时间和场馆展开，绿色场次条像可以移动的排期磁条。橙色只留给新建、保存等明确动作。

用户先看有没有空档和冲突，再进入场次详情或编辑。宽屏排期墙强调并行关系，窄屏议程强调阅读顺序；数据、筛选语义和操作入口不随布局变化。

**Key Characteristics:**

- 深墨色总控栏、深蓝工作面、暖纸色排期区
- 绿色场次条和橙色主要动作，颜色职责固定
- 宽屏时间网格与窄屏分组议程共用同一份状态
- 错误集中说明，并提供能直接修正问题的入口

## Colors

### Primary

- **Dispatch Ink:** 页头、关键文字和高对比结构线。
- **Dispatch Blue / Deep Dispatch Blue:** 日期栏、筛选工作面和编辑页标题区。

### Secondary

- **Active Green:** 正常场次、当前状态、键盘焦点和筛选图标。
- **Action Orange:** 新建、保存等主要动作。

### Tertiary

- **Error Red:** 冲突摘要、错误边界和需要立即修正的信息。

### Neutral

- **Enamel / Paper:** 页面底色、时间网格、表单和详情面板。
- **Steel / Rule:** 次要文字、滚动条与网格分隔。

**The Signal Color Rule.** 绿色表示可用或当前状态，橙色表示下一步动作，红色只表示错误。普通说明不借用这三种颜色吸引注意力。

## Typography

**Display Font:** `Georgia`，平台衬线体回退  
**Body Font:** 平台系统无衬线体

大标题使用紧凑的厚重衬线体，像活动中心墙上的印刷排期标题。正文、字段和数据使用系统无衬线体，保证密集信息仍容易扫描。

### Hierarchy

- **Display**（800，42px，0.98）：应用名和页面主标题。
- **Title**（800，25px，1.08）：日期、场次名和冲突摘要。
- **Body**（400，16px，1.45）：说明、详情和表单内容。
- **Label**（800，14px）：字段名、时间和操作文字。

时间使用等宽数字特性，不把整段正文改成等宽字体。

## Layout

页面内容最大宽度为 1320px，外边距 18px。排期内容达到 980px 时使用时间网格：行表示时刻，列表示场馆，场次条按开始和结束分钟放置。低于 980px 时改为日期和时间分组的议程列表。

页头在 720px 以下上下排列。筛选区在 680px 以下把三个字段改为单列。编辑表单在 660px 以下改为单列；详情页的操作区在窄屏下换行，但保持返回、编辑和场次信息的阅读顺序。

320px 宽度和 200% 文本下允许内容自然增高，不依赖水平滚动，也不截断主要操作。

## Elevation & Depth

界面不使用阴影。深浅色块、1px 结构线、时间网格和间距负责分层。排期墙需要像固定在墙上的工作板，不使用玻璃、发光或漂浮卡片。

**The Board Surface Rule.** 总控栏、筛选工作面和排期区各自是一整块表面；不要把每段说明再包进同尺寸卡片。

## Shapes

字段和按钮使用 6px 圆角，主要面板使用 8px 圆角。圆角只用来缓和高密度工具界面，不把按钮、筛选或状态做成胶囊。

## Components

### Header Actions

- **Primary:** 橙色底、深墨色文字，用于“新建排期”和“保存排期”。
- **Secondary:** 深色底配浅色边框，用于“恢复演示数据”等可逆入口。
- **Touch Target:** 最小 48×48px；图标和文字一起说明动作。

### Filter Desk

筛选放在同一块深蓝工作面。活动日和场馆写入 URL，讲师保留为页面内临时筛选。字段在窄屏时整行展开，标签始终放在控件上方。

### Schedule Wall and Agenda

排期墙固定时间轴和场馆列，绿色场次条显示时间、工坊和讲师。议程列表改按日期和时间纵向排序，每一行保留场馆、讲师与人数，不把窄屏做成缩小版网格。

场次条和议程行都是进入详情的真实操作入口，需要完整的 hover、focus 与 Semantics 标签。

### Editor and Conflict Summary

编辑器先收集完整草稿，再调用 Repository 保存。冲突摘要一次列出容量、场馆和讲师问题，使用 live region 宣布，并在保存失败后获得焦点。可直接修正的冲突提供返回相关字段的按钮；错误不能只靠红色表达。

### Loading, Empty and Error States

首次加载失败、排期流失败、空筛选结果、未知场次和无效路由使用不同文案与恢复动作。恢复演示数据必须先确认，因为它会覆盖当前浏览器中的本地排期。

## Accessibility

- 结果数量和冲突摘要使用 live region。
- 场次入口、筛选状态和错误恢复动作都有可读名称。
- 保存冲突后把键盘焦点移到摘要，不让用户自己寻找错误。
- 焦点使用 3px 绿色边框；颜色之外仍有文字、结构和语义状态。
- 320×720 与 200% 文本是固定验收尺寸。

## Do's and Don'ts

### Do:

- **Do** 让宽屏与窄屏布局读取同一份筛选和排期状态。
- **Do** 保持时间、场馆、讲师和容量在详情、编辑与冲突说明中的称呼一致。
- **Do** 把冲突规则留在领域层，把持久化留在数据层。

### Don't:

- **Don't** 在 UI 中重复实现时间重叠和容量判断。
- **Don't** 用普通卡片网格替代时间关系，或把桌面排期墙直接压缩到手机。
- **Don't** 把绿色、橙色和红色当作无意义装饰。
