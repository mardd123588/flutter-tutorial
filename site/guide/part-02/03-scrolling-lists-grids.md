---
title: 滚动、列表与网格
description: 按内容规模选择 scroll view、lazy builder 与网格，并处理 viewport 和嵌套滚动边界。
part: 2
order: 3
kind: concept
requires:
  - layout.constraints
provides:
  - layout.scrollable
  - layout.lazy-list
  - layout.grid
status: verified
---

# 滚动、列表与网格

内容超过 viewport 后，问题不只是“能不能滚”。还要决定由谁滚、子级何时创建、空数据放在哪里，以及列表与页头是否共享同一段滚动位置。

## 先按内容规模选择入口

| 内容形态 | 常用入口 | 说明 |
| --- | --- | --- |
| 少量、异构内容，平时可能放得下 | `SingleChildScrollView` | 只有一个 child，通常包住 Column |
| 少量、已经构造好的同类项 | `ListView(children: ...)` | children 会先完整构造 |
| 大量或动态列表 | `ListView.builder` | 在 viewport 附近按需调用 builder |
| 规则网格 | `GridView.builder` | delegate 决定列数或单元格最大宽度 |
| 页头、列表、网格同轴滚动 | `CustomScrollView` | 用多个 sliver 组成一个滚动主体 |

`SingleChildScrollView > Column` 不适合装几千条记录，因为 Column 的 children 已经全部建立。builder 版本把创建工作推迟到需要显示和缓存附近时再做。

## builder 的合同

有限列表应提供 `itemCount`：

```dart
ListView.builder(
  itemCount: exhibits.length,
  itemBuilder: (context, index) {
    return ExhibitRow(exhibit: exhibits[index]);
  },
)
```

builder 不承诺“只创建屏幕内精确 N 项”。viewport 会保留缓存范围，具体创建数量受尺寸、滚动位置和配置影响。可靠的判断只有一个：它不会像显式 children 那样在开始时构造全部数据项。

不要靠 `itemBuilder` 返回 `null` 表示有限列表结束。显式 `itemCount` 能让滚动系统更准确地估算最大范围，也能保持 Scrollbar 长度稳定。

若列表项主轴尺寸确实固定，可以提供 `itemExtent` 或 `prototypeItem`，减少反复测量。会随说明文字和文本缩放改变高度的卡片不应硬写固定 extent。

## 空状态放在列表外

`itemCount == 0` 时，builder 不会执行。空状态应由页面的数据分支表达：

```dart
if (exhibits.isEmpty) {
  return const EmptyGallery();
}
return ListView.builder(
  itemCount: exhibits.length,
  itemBuilder: buildExhibit,
);
```

空状态至少说明发生了什么，并给出当前任务可用的恢复动作，例如“新建第一件展品”。不要让空白 viewport 迫使用户猜测页面是否加载失败。

## GridView 管固定规则，Wrap 管自然换行

`Wrap` 根据每个子级的真实尺寸换行，列数可能随文字变化。`GridView` 通过 delegate 建立稳定网格规则。

```dart
GridView.builder(
  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
    maxCrossAxisExtent: 280,
    mainAxisSpacing: 16,
    crossAxisSpacing: 16,
    childAspectRatio: 1.4,
  ),
  itemCount: exhibits.length,
  itemBuilder: (context, index) => ExhibitCard(exhibits[index]),
)
```

`SliverGridDelegateWithFixedCrossAxisCount` 固定列数；`SliverGridDelegateWithMaxCrossAxisExtent` 给出单元格交叉轴最大尺寸，由可用宽度推导列数。卡片高度若被 `childAspectRatio` 固定，要用长文本和 200% 文本缩放验证；必要时改用允许内容增长的布局。

## `shrinkWrap` 会改变尺寸策略

scroll view 默认在滚动轴扩到父级允许的最大尺寸。滚动轴无界时，`shrinkWrap: true` 会让它按内容估算自身尺寸，但滚动位置变化时可能重新计算尺寸，成本高于有限 viewport。

因此，`Column` 中的列表报无界高度时，先确认意图：

- 列表是页面主体：用 `Expanded` 给它有限 viewport。
- 页头和列表需要一起滚：改成一个 `CustomScrollView`。
- 内层列表很短、只作为外层内容的一部分：可以评估 `shrinkWrap`，同时关闭内层滚动，仍要测实际数据规模。

两个同轴 scrollable 嵌套会竞争手势和滚动范围。基础页面优先保留一个滚动主体；需要协调吸顶头部、Tab 与内层列表时，再使用 `NestedScrollView` 等专用结构。

## box 与 sliver 的连接处

`CustomScrollView.slivers` 只接受 sliver。普通 box 用 `SliverToBoxAdapter` 接入，列表和网格使用对应的 lazy sliver：

```dart
CustomScrollView(
  slivers: [
    const SliverToBoxAdapter(child: GalleryHeader()),
    SliverList.builder(
      itemCount: exhibits.length,
      itemBuilder: (context, index) => ExhibitRow(exhibits[index]),
    ),
  ],
)
```

第二部分只需要认识这个桥接关系。`RenderSliver` 协议、cache extent 调优和性能 trace 留到第七部分。

## 可验证任务

准备 1000 条带编号的数据，分别用 `Column(children: ...)` 和 `ListView.builder` 显示。记录首次构建时实际执行了多少次 item builder，并验证下列结果：

1. builder 版本没有一次建立全部 1000 项；不要把具体数量写进断言。
2. `itemCount: 0` 时显示带“新建”按钮的空状态。
3. 把页头和列表放进两个同轴滚动容器，观察问题后改成一个 `CustomScrollView`。
4. 在 320、768 和 1440 像素宽度下比较 Wrap 与 GridView 的列行为。

## 复习线索

- children 与 builder 的创建时机。
- viewport 需要滚动轴有限约束；`shrinkWrap` 不是默认修复。
- Wrap 根据内容换行，GridView 根据 delegate 建立网格。
- 普通 box 通过 `SliverToBoxAdapter` 进入 `CustomScrollView`。

## 参考资料

- [Scrolling](https://docs.flutter.dev/ui/layout/scrolling)（查阅：2026-08-30）
- [SingleChildScrollView class](https://api.flutter.dev/flutter/widgets/SingleChildScrollView-class.html)（查阅：2026-08-30）
- [ListView.builder](https://api.flutter.dev/flutter/widgets/ListView/ListView.builder.html)（查阅：2026-08-30）
- [GridView.builder](https://api.flutter.dev/flutter/widgets/GridView/GridView.builder.html)（查阅：2026-08-30）
- [ScrollView.shrinkWrap](https://api.flutter.dev/flutter/widgets/ScrollView/shrinkWrap.html)（查阅：2026-08-30）
- [Using slivers](https://docs.flutter.dev/ui/layout/scrolling/slivers)（查阅：2026-08-30）
- [CustomScrollView class](https://api.flutter.dev/flutter/widgets/CustomScrollView-class.html)（查阅：2026-08-30）

