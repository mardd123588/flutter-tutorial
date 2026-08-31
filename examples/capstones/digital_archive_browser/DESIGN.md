---
name: 数字档案浏览器
description: 用现代数字阅览室组织固定馆藏、深链接、筛选与三项对照。
colors:
  ink: "#102A36"
  ink-soft: "#294653"
  reading-white: "#F7F3EA"
  paper: "#FFFCF5"
  cyan: "#2F7F8F"
  amber: "#C57A35"
  plum: "#72536F"
  rule: "#D4C9B9"
---

# Design System: 数字档案浏览器

## 视觉方向

界面采用“现代数字阅览室”。深墨蓝区域负责筛选和对照，暖白区域负责连续阅读；馆藏色只出现在缩略图和元数据，不用泛黄滤镜、文件夹拟物或电商式瀑布流。

## 布局

1050px 以上固定 292px 筛选栏，右侧是单一 `CustomScrollView`。更窄时筛选进入 bottom sheet，记录保持单列；600px 以上才真正渲染紧凑网格。查询摘要固定在结果顶部，年代标题与 lazy delegate 交替出现。

## 绘制

缩略图由 `ArchiveThumbnailPainter` 根据稳定 seed 与馆藏色生成。画布只承担无交互图形；题名、开放状态、按钮和可访问名称仍由 Widget 提供。`shouldRepaint` 只比较 seed 与 palette 输入。

## 可访问性

结果数量和三项上限错误使用 live region。第四条记录被拒绝后，焦点落到固定错误栏，并提供“移除最早一条”的恢复动作。200% 文本时卡片自然增高，窄屏不强行压缩为横排。

## 边界

- 不维护 golden；构图由三档尺寸、200% 文本和实际 Chrome 检查。
- 不连接网络，不使用第三方字体，120 条 fixture 保持确定。
- URL 是搜索与筛选的单一事实来源；对照栏只保存稳定记录 ID。
