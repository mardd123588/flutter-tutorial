---
name: 邻里资源交换站
description: 以值班公告板和可撕取用签组织浏览、发布与认领的本地优先交换工具。
colors:
  garden-ink: "#20352E"
  garden-ink-soft: "#3D5149"
  noticeboard: "#E5DDC7"
  civic-paper: "#FFF9E9"
  civic-paper-muted: "#F3EBD7"
  action-rust: "#A9422D"
  availability-green: "#3F684C"
  selection-green: "#DCE7CE"
  focus-gold: "#C18A2D"
  local-blue: "#315E66"
  rule-gray: "#7B7365"
  error-red: "#A52F2F"
  action-white: "#FFFFFF"
typography:
  display:
    fontFamily: "Georgia, system-ui, sans-serif"
    fontSize: "40px"
    fontWeight: 800
    lineHeight: 1.02
    letterSpacing: "-1.1px"
  headline:
    fontFamily: "Georgia, system-ui, sans-serif"
    fontSize: "29px"
    fontWeight: 800
    lineHeight: 1.08
    letterSpacing: "-0.5px"
  subheadline:
    fontFamily: "system-ui, sans-serif"
    fontSize: "23px"
    fontWeight: 800
    lineHeight: 1.12
  title:
    fontFamily: "system-ui, sans-serif"
    fontSize: "20px"
    fontWeight: 800
  body:
    fontFamily: "system-ui, sans-serif"
    fontSize: "16px"
    fontWeight: 400
    lineHeight: 1.48
  body-compact:
    fontFamily: "system-ui, sans-serif"
    fontSize: "14px"
    fontWeight: 400
    lineHeight: 1.45
  label:
    fontFamily: "system-ui, sans-serif"
    fontSize: "14px"
    fontWeight: 800
rounded:
  notice: "2px"
  label: "4px"
  control: "8px"
  ledger: "12px"
  panel: "14px"
  sheet: "16px"
spacing:
  micro: "8px"
  compact: "12px"
  field: "14px"
  gutter: "18px"
  panel: "24px"
  section: "38px"
components:
  action-primary:
    backgroundColor: "{colors.action-rust}"
    textColor: "{colors.action-white}"
    typography: "{typography.label}"
    rounded: "{rounded.control}"
    height: "48px"
  action-outline:
    backgroundColor: "transparent"
    textColor: "{colors.garden-ink}"
    typography: "{typography.label}"
    rounded: "{rounded.control}"
    height: "48px"
  text-field:
    backgroundColor: "{colors.civic-paper}"
    textColor: "{colors.garden-ink}"
    typography: "{typography.body}"
    rounded: "{rounded.control}"
  status-label:
    backgroundColor: "{colors.availability-green}"
    textColor: "{colors.action-white}"
    typography: "{typography.label}"
    rounded: "{rounded.label}"
    padding: "4px 8px"
  notice-card:
    backgroundColor: "{colors.civic-paper}"
    textColor: "{colors.garden-ink}"
    rounded: "{rounded.notice}"
  notice-card-selected:
    backgroundColor: "{colors.selection-green}"
    textColor: "{colors.garden-ink}"
    rounded: "{rounded.notice}"
  filter-ledger:
    backgroundColor: "{colors.garden-ink}"
    textColor: "{colors.civic-paper}"
    rounded: "{rounded.ledger}"
    padding: "18px"
  detail-sheet:
    backgroundColor: "{colors.civic-paper}"
    textColor: "{colors.garden-ink}"
    rounded: "{rounded.panel}"
    padding: "24px"
  service-header:
    backgroundColor: "{colors.garden-ink}"
    textColor: "{colors.civic-paper}"
    padding: "12px 18px"
---

# Design System: 邻里资源交换站

## Overview

**Creative North Star: "值班公告板与取用签"**

界面像一张正在值班的社区公告板，而不是商品市场或匿名后台。深色服务栏承载站点身份和筛选工作，暖色公告纸承载资源事实，绿色取用签把数量和可认领状态直接接在公告上。锈红色只推动发布与认领等关键动作。

系统优先保证任务扫描、数据边界和响应式重排。桌面把筛选、公告、详情同时摊开；中屏保留行内筛选；窄屏把筛选移入 bottom sheet，并把取用签转到公告下方。动效只解释详情替换，减少动画时立即归零。

**Key Characteristics:**

- 深花园墨色服务栏与暖米色公告纸形成稳定的工作区层级。
- 方正公告纸连接虚线取用签，状态与动作不脱离资源事实。
- 锈红负责关键动作，配额绿负责可用、选中与成功，金色负责焦点。
- 布局在明确断点重组，不把桌面三栏压成不可读的缩略版。
- 本地发布、认领和跨浏览器可恢复范围始终写在界面上。

## Colors

深绿墨、社区纸和公告板底色构成大面积基底；锈红、配额绿、焦点金和本地蓝只承担明确语义。

### Primary

- **深花园墨** (#20352E): 用于页头、值班筛选簿和中屏筛选条，建立稳定的服务栏。
- **配额绿** (#3F684C): 用于可认领状态、取用签和成功反馈。
- **选中浅绿** (#DCE7CE): 用于当前公告和本地数据说明，不与主行动争夺注意力。

### Secondary

- **行动锈红** (#A9422D): 用于发布、认领和需要立即确认的主动作。

### Tertiary

- **焦点金** (#C18A2D): 用于键盘焦点、已认领状态和选择反馈。
- **本地蓝** (#315E66): 只标记“仅此浏览器”的来源边界。
- **错误红** (#A52F2F): 只用于字段错误、失败摘要和不可恢复的失败反馈。

### Neutral

- **公告板米色** (#E5DDC7): 作为应用背景，像公告纸下方的软木或桌面。
- **社区纸** (#FFF9E9): 作为资源公告、详情和表单的主要内容面。
- **静音社区纸** (#F3EBD7): 作为结果桌、不可认领取用签和次级分区。
- **柔和花园墨** (#3D5149): 承担次级正文和类别标签。
- **规则灰** (#7B7365): 承担分隔线、边线和穿孔线。
- **行动白** (#FFFFFF): 为深色服务栏、锈红按钮、状态签和取用签提供高对比文字。

### Named Rules

**The Ink Rail Rule.** 深花园墨只形成页头、筛选簿和筛选条等服务栏；资源正文与详情继续落在社区纸上。

**The Rust Means Action Rule.** 行动锈红只标记发布、认领和确认，不用于装饰、状态标签或大面积背景。

## Typography

**Display Font:** Georgia (with platform fallback for Chinese glyphs)

**Body Font:** system-ui, sans-serif

**Label/Mono Font:** system-ui, sans-serif

**Character:** 英文、数字和可覆盖字形由 Georgia 提供公告栏标题的厚重感；中文按平台字库回退，正文保持直接、紧凑和高对比。项目不下载字体文件，也不打包第三方字体。

### Hierarchy

- **Display** (800, 40px, 1.02): 用于发布页、边界说明页等独立任务页主标题。
- **Headline** (800, 29px, 1.08): 用于浏览页问题句和资源详情标题。
- **Subheadline** (800, 23px, 1.12): 用于筛选簿、状态面板和次级任务标题。
- **Title** (800, 20px): 用于站名、公告标题和主要信息组。
- **Body** (400, 16px, 1.48): 用于资源说明、数据边界和表单帮助。
- **Compact Body** (400, 14px, 1.45): 用于卡片摘要和次级说明。
- **Label** (800, 14px): 用于按钮、状态、剩余数量和事实名称。

### Named Rules

**The Local Fallback Is a Constraint Rule.** 中文平台字体回退是“不加载远程字体，也不打包第三方字体”的交付约束，不是任意更换展示字体的视觉许可；必须在 320、768 和 1440 宽度检查换行与截断。

## Layout

宽屏从 1100px 起使用三栏工作台：左栏值班筛选簿固定 270px，中栏弹性伸缩，右栏取用详情固定 390px；应用外边距为 18px，栏间距为 16px。选中资源后，详情在右栏原位替换，不覆盖列表。

700–1099px 使用单栏结果桌，并在搜索框下保留深色行内筛选条。700px 以下把筛选收进 bottom sheet；页头在 640px 以下分成身份行和动作行。资源卡在 420px 以下把取用签从右侧移到底部；紧凑网格在可用宽度达到 560px 时变成两列。发布表单在内容宽度达到 720px 时分为两列，发布容器最大 920px，独立详情最大 720px。

间距围绕 8、12、14、18、24 和 38px 组织：8px 处理标签和行内关系，12–18px 处理卡片与字段，24px 处理独立纸面内边距，38px 处理长分隔。文本放大超过 150% 时，浏览区改用完整页面滚动，避免固定工作台裁切内容。

## Elevation & Depth

系统以纸面色差为主、低海拔阴影为辅。普通公告使用 Material elevation 2，选中公告升到 elevation 6；独立详情使用 elevation 3，嵌入桌面的详情保持平面。阴影统一使用深花园墨的透明版本，不使用硬偏移阴影或无来源光晕。

### Shadow Vocabulary

- **公告纸静置:** Material elevation 2，阴影色为深花园墨 24% 透明度；用于可点击公告。
- **公告纸选中:** Material elevation 6，沿用同一阴影色；与选中浅绿一起说明当前详情来源。
- **独立详情:** Material elevation 3，阴影色为深花园墨 18% 透明度；仅在详情脱离三栏工作台时出现。

### Named Rules

**The Paper First Rule.** 先用公告板、静音纸和社区纸的色差分层；只有可点击公告、当前选中项和独立详情获得低海拔阴影。

## Shapes

公告纸接近直角，只保留 2px 的防锯齿圆角；状态签为 4px，按钮和输入为 8px，值班簿与结果桌为 12px，独立表单与详情纸为 14px，bottom sheet 顶部为 16px。圆角随容器层级增加，但不把公告卡做成胶囊或通用圆角瓷砖。

资源卡与取用签通过 5px 虚线、5px 间隔的穿孔连接。宽屏和常规列表使用垂直穿孔，窄屏与网格使用水平穿孔；穿孔只表达公告与取用动作的从属关系。

## Components

### Buttons

- **Shape:** 所有按钮至少 48px 高，使用 8px 圆角和 800 字重。
- **Primary:** 行动锈红底配白字，用于发布、认领和明确确认。
- **Outlined:** 透明底配深花园墨 1.2px 边线，用于取消、复制链接和恢复演示数据。
- **Hover / Focus:** hover 使用配额绿的轻透明覆盖；键盘焦点使用焦点金反馈，不能只改变文字颜色。

### Status Labels and Chips

- **Status Labels:** 4px 圆角、4px × 8px 内边距；可认领为配额绿，已预留为锈红，已完成为规则灰。
- **Local Boundary:** 本地来源使用本地蓝，并直接写“仅此浏览器”。
- **Category:** 类别使用柔和墨色；详情页可使用浅色 Chip，但不能替代资源状态。

### Notice Cards

- **Paper:** 社区纸、2px 圆角、静置 elevation 2；主体内边距通常为 18px。
- **Claim Slip:** 配额绿表示可认领，焦点金表示当前用户已认领，静音纸表示不可认领。
- **Selected:** 选中公告切换为选中浅绿并升至 elevation 6，详情必须与该选中态同步。
- **Responsive:** 420px 以下和网格视图把取用签放到底部，其余列表放在右侧。

### Inputs / Fields

- **Style:** 社区纸填充、8px 圆角、规则灰边线。
- **Focus:** 焦点金 3px 边线；错误为错误红 2px，错误且聚焦时增至 3px。
- **Form Rhythm:** 字段通常以 14px 间距排列，错误摘要和本地数据说明使用单独的浅色信息面。

### Filter Ledger

桌面值班筛选簿使用深花园墨、12px 圆角和 18px 内边距，按片区、类别、状态、排序排列。中屏保留相同深色材料但改为横向筛选条；窄屏使用 16px 顶圆角 bottom sheet。三种形态共享同一筛选状态。

### Navigation

页头使用深花园墨和 12px × 18px 内边距，站点标记、名称、预览边界与发布动作保持可见。640px 以下允许动作换到第二行，不通过隐藏站点身份换取空间。

### Detail Sheet

详情纸以 24px 内边距组织状态、标题、说明、事实列表、本地边界和动作。宽屏嵌入右栏时保持平面；独立路由限制在 720px 并使用 elevation 3。详情切换为 220ms 的淡入与 4% 水平滑入，系统请求减少动画时改为 0ms。

## Do's and Don'ts

### Do:

- **Do** 把筛选和导航放在深色服务栏，把资源事实和表单放在暖色纸面。
- **Do** 让公告、取用签、剩余数量和选中详情保持可追溯关系。
- **Do** 保持按钮至少 48px 高，并让输入焦点以 3px 焦点金边线清楚可见。
- **Do** 在 420、640、700、720 和 1100px 的实现断点检查重排，并覆盖 200% 文本与减少动画设置。
- **Do** 直接说明哪些数据可跨浏览器恢复、哪些只保存在当前浏览器。

### Don't:

- **Don't** 把公告改成脱离交接信息的商品瓷砖、等尺寸市场卡片或匿名 dashboard 卡。
- **Don't** 把行动锈红用于装饰性大底色，或用颜色代替“仅此浏览器”等边界文字。
- **Don't** 给所有容器相同的大圆角、胶囊轮廓或硬偏移阴影。
- **Don't** 在没有公告与取用关系的组件上复用穿孔线。
- **Don't** 加载远程字体或打包第三方字体来强行统一中文字形。
