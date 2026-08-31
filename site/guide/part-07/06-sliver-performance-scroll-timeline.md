---
title: Sliver、性能分析与长卷时间轴
description: 理解 Sliver 滚动协议、帧预算和 profile 工具，并完整讲解重点项目“长卷时间轴”。
part: 7
order: 6
kind: focus-project
requires:
  - render.pipeline
  - layout.lazy-list
  - test.determinism
provides:
  - performance.frame-budget
  - performance.devtools
  - layout.sliver
  - performance.memory
  - project.scroll-timeline
project: scroll-timeline
status: verified
---

# Sliver、性能分析与长卷时间轴

普通 `ListView.builder` 已经能懒构建长列表。页面还要组合可折叠标题、pinned 目录、列表、网格和空状态时，`CustomScrollView` 与 Sliver 能让这些区域共享一个 viewport 和滚动位置。

长卷时间轴沿用[测试策略](/guide/part-07/01-test-strategy-unit)、[Widget 与 golden 测试](/guide/part-07/02-widget-semantics-golden)、[Chrome 集成测试](/guide/part-07/03-web-integration)、[三棵树](/guide/part-07/04-widget-element-renderobject)和[渲染流水线](/guide/part-07/05-rendering-pipeline)。本章新增 Sliver 协议与固定 workload 的 profile 证据。

本章先说明 Sliver 协议与 profile 方法，随后完整讲解重点项目“长卷时间轴”。项目不会延伸到下一章。

## 用现成 Sliver 组合页面

`CustomScrollView.slivers` 接收 Sliver 序列：

| 需求 | 组件 |
| --- | --- |
| 普通 box 区域 | `SliverToBoxAdapter` |
| 懒列表 | `SliverList` / `SliverFixedExtentList` |
| 懒网格 | `SliverGrid` |
| 固定或伸缩标题 | `SliverPersistentHeader` / `SliverAppBar` |
| 填满剩余空间 | `SliverFillRemaining` |
| 留白 | `SliverPadding` |

普通 `Container` 不能直接放进 `slivers`，需要 `SliverToBoxAdapter`。反过来，Sliver 也不能直接放在 `Column.children` 中；两套布局协议要通过 viewport 或 adapter 接起来。

## `SliverConstraints` 输入，`SliverGeometry` 输出

Box 协议用 constraints 和 size 交流。Sliver 要回答滚动相关问题，输入和输出更丰富：

```text
Viewport
  ├─ scrollOffset：该 sliver 已滚过多少
  ├─ remainingPaintExtent：本帧还可绘制多少
  ├─ crossAxisExtent：横轴空间
  ├─ cacheOrigin / remainingCacheExtent：提前布局范围
  ↓
RenderSliver
  ├─ scrollExtent：总滚动长度
  ├─ paintExtent：当前实际绘制长度
  ├─ layoutExtent：占用 viewport 的长度
  ├─ maxPaintExtent：最大绘制长度
  └─ cacheExtent：本次布局覆盖的缓存范围
```

`paintExtent` 不能超过 viewport 给出的 `remainingPaintExtent`。这里的 cache extent 是提前 layout / materialize 的滚动范围，不是图片缓存，也不是 raster cache。

## 固定 extent 能减少测量

`SliverList` 不知道未出现子项的主轴尺寸，会根据已经 materialize 的相邻子项继续布局，这称为 dead reckoning。选择组件时看数据形状：

- 每项高度固定：`SliverFixedExtentList`；
- 每项可用一个原型代表：`SliverPrototypeExtentList`；
- 内容自然增高：`SliverList.builder`；
- 二维固定规则：`SliverGrid`。

文本支持 200% 缩放时，事件卡片通常不能写死高度。此时可变 extent 是正确取舍，不要为了理论上的测量收益裁掉正文。

## 帧预算取决于刷新率

60Hz 屏幕每帧约 `16.7ms`，120Hz 约 `8.3ms`。这是调度预算，不是 Flutter 在所有设备上的固定通过线。性能判断还要说明目标设备、刷新率、renderer、窗口、数据规模和操作脚本。

平均值会隐藏少量长帧，至少查看分位数和最慢帧。内存也不能只看“当前占用”：持续滚动后应观察对象数量是否稳定、图片和 layer 是否可回收、返回页面后缓存是否符合生命周期设计。

## 用 profile 模式测同一 workload

性能调查固定顺序：

1. 写下 workload、fixture、窗口、设备和 renderer；
2. 关闭 tracing flags，记录 baseline；
3. 找出长帧发生在 build、layout、paint、raster 还是浏览器主线程；
4. 一次只打开一个诊断开关；
5. 修改后重跑相同 workload；
6. 保留前后 trace 和结论。

移动端和桌面端可用 Flutter DevTools Performance view 查看 Flutter Frames、UI thread 与 raster thread。Flutter Web profile 不能连接该视图，应使用 Chrome DevTools Performance panel；Web 的 long task、JS、布局与 renderer 事件也在这里观察。

Impeller 是 iOS 和 Android 的默认渲染路径，Web 使用 CanvasKit 或 Skwasm，shader 与缓存行为不同。不能把移动端的 shader warm-up 建议直接当成 Web 修复方案。

## 项目简报：长卷时间轴

地方档案馆要发布“河岸修复六十年”长卷。读者浏览 6 个阶段、72 条固定事件，按 4 类主题筛选，并从目录跳到某个阶段。连续视觉由 Canvas 补充，文字、按钮和语义仍由普通 Widget 承担。

项目路径与预览路径：

```text
examples/focus/scroll_timeline/
/flutter-tutorial/previews/scroll-timeline/
```

功能合同：

- `CustomScrollView` 组合 hero、筛选、pinned 目录、阶段标题与 lazy 列表；
- 窄屏单列，宽屏左侧固定目录、右侧时间轴；
- 多选主题，清空选择时恢复 72 条事件；
- 目录跳转后焦点落到阶段标题；
- painter 只画脊线和滚动进度；
- 320×720、768×900、1440×900、200% 文本和 reduced motion 可用；
- 维护宽屏首屏和窄屏中段两张 golden。

项目不做网络、数据库、编辑、缩放、自定义 RenderSliver、shader 或水平时间轴。

## 固定数据先保证顺序

72 条事件由固定阶段和标题表生成，排序使用年份、同年序号、稳定 ID：

<<< ../../../examples/focus/scroll_timeline/lib/src/timeline_data.dart#timeline-fixture-filter{dart}

筛选只从已排序序列中保留条目，因此多选主题不会改变原顺序。空集合代表“全部主题”，避免再维护一个与集合状态可能冲突的布尔值。

Riverpod 只保存选择并派生结果：

<<< ../../../examples/focus/scroll_timeline/lib/src/timeline_providers.dart#timeline-provider-graph{dart}

`selectedTopicsProvider` 是源状态，`filteredTimelineProvider` 是派生状态。事件 fixture 不复制进 notifier，筛选结果也不允许 Widget 回写。

## 一个 viewport 组合全部滚动区域

项目按阶段分组，再把每个阶段写成一个 header 和一个 `SliverList.builder`：

<<< ../../../examples/focus/scroll_timeline/lib/src/timeline_page.dart#timeline-sliver-composition{dart}

这里有三点值得保留：

1. hero、筛选和 footer 用 adapter 进入 Sliver 序列；
2. 窄屏目录用 `SliverPersistentHeader(pinned: true)`；
3. 空筛选结果用 `SliverFillRemaining`，不会再创建 6 个空列表。

事件摘要支持文本缩放，卡片高度不固定，所以使用 `SliverList.builder`。Delegate 已默认处理子项 repaint boundary，项目没有再给每行叠一层边界。

## 目录跳转同时处理滚动和焦点

每个阶段标题有 `GlobalKey` 和 `FocusNode`。目录动作先滚到目标，再把焦点交给标题：

<<< ../../../examples/focus/scroll_timeline/lib/src/timeline_page.dart#timeline-directory-focus{dart}

`Scrollable.ensureVisible` 使用现有滚动协议定位目标。系统要求减少动画时，duration 变为零；否则用 420ms 过渡。`mounted` 检查保护等待后的 Element 边界。

只滚动不移动焦点，键盘与屏幕阅读器用户仍停在目录按钮上；只移动焦点又可能让目标被 pinned header 遮住。两步都属于导航合同。

## 滚动进度不触发整页 `setState`

时间轴 painter 直接监听 `ScrollController`：

<<< ../../../examples/focus/scroll_timeline/lib/src/timeline_painter.dart#timeline-progress-painter{dart}

`super(repaint: controller)` 让滚动通知进入 paint，不要求页面为每个 offset build。`shouldRepaint` 只比较 controller 身份；同一 controller 的 offset 变化由 Listenable 通知。

Painter 只画线和圆点。事件年份、标题、主题、摘要与阶段 header 都是普通 Widget，并有独立 Semantics。画布没有吞掉可访问内容，也没有自行处理命中测试。

## 自动测试固定结构与用户合同

首帧测试确认最后一条事件尚未 materialize：

<<< ../../../examples/focus/scroll_timeline/test/scroll_timeline_app_test.dart#timeline-lazy-test{dart}

这比统计 build 次数更稳定。只要远端事件在首帧不存在、滚动后出现，lazy 合同就成立。

Semantics 测试固定阶段 header flag 和事件的可感知 label：

<<< ../../../examples/focus/scroll_timeline/test/scroll_timeline_app_test.dart#timeline-semantics-test{dart}

两张 golden 固定 viewport、DPR、fixture 和滚动位置：

<<< ../../../examples/focus/scroll_timeline/test/scroll_timeline_app_test.dart#timeline-golden-tests{dart}

Golden 只验证受控环境中的构图。中文真实字形、键盘筛选和浏览器滚动仍由 Chrome 检查。

## Chrome profile 使用固定长滚动

集成测试把“选择主题并往返滚动”包在同一个 performance workload 中：

<<< ../../../examples/focus/scroll_timeline/integration_test/scroll_timeline_test.dart#timeline-profile-workload{dart}

本次 profile Web 记录使用固定 fixture 与同一滚动脚本：

| 指标 | 结果 |
| --- | --- |
| 采样帧 | 595 |
| build p90 | `1.199ms` |
| raster p90 | `1.5ms` |

这些数字是当前环境的证据，不是跨设备 CI 门槛。结构性门槛由自动测试固定：首帧不创建全部 72 项、主旅程无异常、筛选和跳转完成。若以后调整 `RepaintBoundary`，应在同一浏览器、窗口、renderer 和 workload 下比较前后 trace。

## 运行与构建

```bash
cd examples/focus/scroll_timeline
flutter analyze
flutter test
flutter drive --driver=test_driver/integration_test.dart --target=integration_test/scroll_timeline_test.dart -d web-server --browser-name=chrome --profile
flutter build web --release --base-href /flutter-tutorial/previews/scroll-timeline/
```

ChromeDriver 需要先启动并与当前 Chrome build 匹配。Web release 构建完成后，实际打开独立子路径，检查宽屏、窄屏、键盘、200% 文本和 reduced motion。

## 项目完成检查

- [ ] fixture 保持 6 个阶段、72 条事件、4 类主题，排序有稳定 ID tie-breaker。
- [ ] 远端事件首帧不存在，滚动后才 materialize。
- [ ] 窄屏 pinned 目录与宽屏固定目录不改变筛选状态。
- [ ] 目录跳转后阶段标题获得焦点。
- [ ] painter 监听 scroll controller，不用滚动 `setState` 重建页面。
- [ ] 事件文字、操作和语义不进入 Canvas。
- [ ] 320×720、768×900、1440×900、200% 文本、reduced motion 通过。
- [ ] 两张 golden、Chrome 集成测试、profile workload 和 Web release 构建通过。

## 复习线索

- Sliver 是 viewport 的滚动布局协议，不是一类动画 Widget。
- cache extent 表示提前布局范围，不是像素缓存。
- 可变高度长列表用 lazy builder；固定高度再考虑 fixed extent。
- 性能测量要固定 workload，并区分 debug、profile、release。
- Web profile 使用 Chrome DevTools，移动端和桌面端使用 Flutter DevTools Performance view。
- “长卷时间轴”用 Sliver 管内容，用 painter 管连续几何，用 Widget 管文字、输入和语义。
- [项目源码](https://github.com/mardd123588/flutter-tutorial/tree/main/examples/focus/scroll_timeline)

## 参考资料

- [Using slivers](https://docs.flutter.dev/ui/layout/scrolling/slivers)（查阅：2026-08-31）
- [`CustomScrollView`](https://api.flutter.dev/flutter/widgets/CustomScrollView-class.html)（查阅：2026-08-31）
- [`SliverConstraints`](https://api.flutter.dev/flutter/rendering/SliverConstraints-class.html)（查阅：2026-08-31）
- [`SliverGeometry`](https://api.flutter.dev/flutter/rendering/SliverGeometry-class.html)（查阅：2026-08-31）
- [`SliverList`](https://api.flutter.dev/flutter/widgets/SliverList-class.html)（查阅：2026-08-31）
- [Flutter performance profiling](https://docs.flutter.dev/perf/ui-performance)（查阅：2026-08-31）
- [Use the Performance view](https://docs.flutter.dev/tools/devtools/performance)（查阅：2026-08-31）
- [Debug performance for web apps](https://docs.flutter.dev/perf/web-performance)（查阅：2026-08-31）
- [Impeller rendering engine](https://docs.flutter.dev/perf/impeller)（查阅：2026-08-31）
