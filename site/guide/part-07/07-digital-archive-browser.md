---
title: 项目：数字档案浏览器
description: 统筹测试策略、URL 状态、Riverpod、mixed sliver、自绘缩略图、可访问错误与 Web profile 证据。
part: 7
order: 7
kind: capstone
requires:
  - test.strategy
  - test.unit
  - test.determinism
  - test.widget
  - test.semantics
  - test.golden-boundary
  - test.integration-web
  - test.webdriver
  - test.failure-artifact
  - internals.widget-element-renderobject
  - internals.update-matching
  - debug.rebuild
  - render.pipeline
  - render.repaint-boundary
  - debug.layout-paint
  - performance.frame-budget
  - performance.devtools
  - layout.sliver
  - performance.memory
  - project.scroll-timeline
provides:
  - project.digital-archive-browser
project: digital-archive-browser
status: verified
---

# 项目：数字档案浏览器

数字档案浏览器把第七部分的测试策略、浏览器流程、三棵树、渲染流水线、Sliver 和 profile 方法放进一个独立 Flutter Web 应用。研究者可以在 120 条虚构档案中搜索、筛选、切换列表与网格、打开稳定深链接，并把最多三条记录放入对照栏。

本章完整讲解项目。它不连接网络或数据库，不再引入新的架构方案；Riverpod 沿用第六部分的对象图与替换接缝。

## 项目简报

### 数据合同

固定 fixture 包含：

- 120 条记录；
- 6 个馆藏；
- 8 个年代段；
- 4 种开放状态；
- 稳定记录 ID、缩略图 seed 与排序 tie-breaker。

搜索匹配题名和人物，先折叠空白并做大小写归一。排序最后总用稳定 ID 打破平局。缩略图由 seed 生成，不请求远程图片。

### 功能要求

- Hash URL 保存搜索、年代、馆藏、开放状态、排序和 view mode；
- 宽屏使用 filter rail，窄屏使用 filter sheet；
- 结果区用 pinned 查询摘要、年代分组、lazy list / grid；
- `#/records/:recordId` 支持直达、刷新、Back / Forward 与新标签；
- 最多三条记录进入对照，第四条有 live region、焦点和恢复动作；
- loading、error、retry、empty 和非法详情都有独立状态；
- 320×720、768×900、1440×900、200% 文本、RTL 测试壳与 reduced motion 可用；
- release Web 从 `/flutter-tutorial/previews/digital-archive-browser/` 加载。

项目不做账号、上传、OCR、服务端搜索、数据库、收藏持久化、协作标注、真实版权判断、原件播放器、自定义 RenderObject 或 renderer 迁移。`Visual` 为 `not-applicable`，因此不维护 golden；三档尺寸和实际 Chrome 视觉检查仍然保留。

## 先用风险表分配证据

| 风险 | 自动证据 | 浏览器 / 人工证据 |
| --- | --- | --- |
| URL parse / encode、非法参数 | unit | 刷新、新标签、Back / Forward |
| 多筛选交集、排序、对照上限 | unit / provider | 主旅程中的代表分支 |
| loading、retry、empty、非法详情 | widget | 主流程不重复所有分支 |
| lazy materialization、列表 / 网格身份 | widget | 连续滚动与 profile trace |
| 第四条拒绝的提示和焦点 | Semantics / widget | 键盘实际操作 |
| 自绘缩略图 | painter unit / widget | 三档 Chrome 截图 |
| URL、资产、release base href | Chrome integration / build | 实际预览路径 |
| build / raster 分布 | profile workload | Chrome Performance trace |

这个矩阵决定测试位置。Integration 不重复每个非法参数；profile 不承担业务正确性；截图不证明焦点和 URL。

## URL 是查询的单一事实来源

`ArchiveQuery` 把六个字段集中在不可变值对象中：

<<< ../../../examples/capstones/digital_archive_browser/lib/src/domain/archive_query.dart#archive-url-query{dart}

`queryParametersAll` 让解析器看见重复参数。`_single` 只接受恰好一个值，因此非法或重复参数会稳定回退。默认排序和列表模式不写入 URL，使规范化地址更短：

```text
/archive?q=河岸&era=era-1990s&collection=maps&access=open&sort=title&view=grid
```

搜索更新后，页面调用 `context.go(query.toUri().toString())`；重新 build 时再从 Route URI 得到查询。输入框 controller 只负责编辑体验，`didUpdateWidget` 会在浏览器历史改变 URL 后同步文本，它不是第二个可写查询来源。

往返测试固定每个 URL 字段：

<<< ../../../examples/capstones/digital_archive_browser/test/archive_query_test.dart#archive-query-round-trip-test{dart}

同一测试文件另查非法和重复参数，防止解析器悄悄采用“第一个赢”或“最后一个赢”。

## Riverpod 组合 Repository、查询与对照栏

项目的 provider 图保持紧凑：

<<< ../../../examples/capstones/digital_archive_browser/lib/src/state/archive_providers.dart#archive-provider-graph{dart}

职责如下：

```text
ArchiveRepository provider
        ↓
archiveRecordsProvider ──→ AsyncValue<List<ArchiveRecord>>
        ↓                         ↑
filteredArchiveProvider(query) ← ArchiveQuery from URL

archiveComparisonProvider → stable record IDs, maximum 3
```

Repository provider 是测试 override seam。`archiveQueryProvider` 由 URI 参数化，`filteredArchiveProvider` 组合异步记录和不可变查询。Widget 不保存第二份结果列表。

对照栏的纯规则只保存 ID：

<<< ../../../examples/capstones/digital_archive_browser/lib/src/domain/archive_models.dart#archive-comparison-rule{dart}

它区分 `added`、`duplicate`、`missing` 和 `limitReached`。三项上限可以用纯单元测试覆盖；Widget 层只负责把 `limitReached` 变成可感知反馈。

## 宽窄屏共享同一结果身份

1050px 以上显示 292px filter rail；更窄时筛选进入 bottom sheet。600px 以下即使 URL 请求 grid，也使用单列布局，URL 值仍保留，窗口变宽后会恢复网格。

结果区是一个 mixed-sliver 结构：

<<< ../../../examples/capstones/digital_archive_browser/lib/src/ui/archive_browser_page.dart#archive-mixed-slivers{dart}

结构按顺序包含：

1. 搜索与窄屏筛选入口；
2. pinned 查询摘要；
3. 空状态，或按年代交替出现的 header 与 lazy delegate；
4. 底部留白。

列表和网格读取同一 `records` 序列，并用记录 ID 作为稳定 Key。切换 view mode 不重新排序，也不把记录复制进另一份状态。

卡片在 200% 文本下自然增高。网格使用固定 `mainAxisExtent`，只在至少 600px 宽时启用；窄屏强制单列，避免为保持网格而压缩可读性。

Lazy 测试先确认第 120 条尚不存在，再滚动到目标：

<<< ../../../examples/capstones/digital_archive_browser/test/digital_archive_browser_app_test.dart#archive-lazy-test{dart}

这条测试还固定稳定 record identity。若有人改成 `SingleChildScrollView + Column` 一次创建 120 项，首个断言会失败。

## 缩略图只画无交互图形

每条记录的 seed 与馆藏序号决定背景、线段和色块：

<<< ../../../examples/capstones/digital_archive_browser/lib/src/ui/archive_thumbnail_painter.dart#archive-thumbnail-painter{dart}

`shouldRepaint` 只比较 `seed` 和 `collectionIndex`。题名、开放状态、人物、详情按钮和对照按钮仍是 Widget；可访问名称不依赖 Canvas。

项目没有为每张卡片再包手写 `RepaintBoundary`。Sliver delegate 已提供默认边界，当前 profile 也没有证明缩略图需要额外独立 layer。以后若要调整，必须用同一 workload 保存前后 trace。

## 第四条对照必须可恢复

达到三项上限后，页面显示固定错误栏：

<<< ../../../examples/capstones/digital_archive_browser/lib/src/ui/archive_browser_page.dart#archive-comparison-feedback{dart}

错误栏有四个合同：

- 文案说明最多三条；
- `liveRegion: true` 宣布动态变化；
- FocusNode 让键盘焦点落到错误栏；
- “移除最早一条”提供立即可用的恢复动作。

对应测试不只找文字：

<<< ../../../examples/capstones/digital_archive_browser/test/digital_archive_browser_app_test.dart#archive-comparison-semantics-test{dart}

它先通过 provider 加入三条记录，再点击第四条，断言 Semantics label、实际 primary focus 和恢复按钮。纯规则与用户反馈因此各在合适层级得到证据。

## Loading、失败与非法详情走独立分支

`archiveRecordsProvider` 发布 `AsyncValue`。页面分别渲染 loading、error 和 data，重试只 invalidate 记录 provider。测试用首次失败、第二次成功的 fake Repository 验证恢复，不依赖网络。

详情路由收到不存在的稳定 ID 时显示“没有这条档案”，并保留原 query 的返回地址。错误不是跳回首页，也不把底层异常文案直接显示给读者。

空筛选结果使用 `SliverFillRemaining`，提供“查看全部 120 条”的恢复动作。清空动作写回默认 `ArchiveQuery`，URL 和界面同时恢复。

## Chrome 旅程与 profile workload 共用确定性输入

Integration test 完成以下操作：

- 从 120 条结果开始；
- 连续滚动三段；
- 切换紧凑网格；
- 输入“夜校”；
- 打开详情并返回；
- 加入三条对照记录。

源码把前半段包进 `watchPerformance`：

<<< ../../../examples/capstones/digital_archive_browser/integration_test/digital_archive_browser_test.dart#archive-profile-journey{dart}

本次基线环境为 Flutter 3.47.0、Dart 3.13.0、Chrome / ChromeDriver 151.0.7922.174、JavaScript 默认 CanvasKit：

| 指标 | 结果 |
| --- | --- |
| 采样帧 | 165 |
| build p90 / p99 | `5.801ms` / `33.5ms` |
| raster p90 / p99 | `3.801ms` / `9.5ms` |
| 超过框架预算 | build 4 帧，raster 2 帧 |

Workload 同时包含滚动、视图切换和路由，不能仅凭离群帧断言缩略图 painter 是原因。当前证据能说明主要帧分布和结构性 lazy 合同已记录；进一步优化前，要在 Chrome Performance trace 中定位具体阶段。

普通 CI 不用这组绝对毫秒数判定通过。跨机器、浏览器版本和 renderer 的帧耗时不可直接比较。

## 自动验收覆盖什么

项目共有 16 项测试，覆盖：

- fixture 数量与维度；
- URL 往返、非法和重复参数；
- 多筛选交集、排序 tie-breaker、对照规则；
- Repository override 与 provider 参数隔离；
- loading、失败、retry、lazy、详情错误；
- 第四条拒绝的 live region、焦点和恢复；
- 320×720、768×900、1440×900；
- 200% 文本、RTL 测试壳、reduced motion；
- 固定浏览器 profile workload。

`Visual` 为 `not-applicable`，所以没有 golden。实际 Chrome 已检查 1440×900 与 320×720；这不改变 golden 与视觉检查的职责边界。

## 运行与发布

```bash
cd examples/capstones/digital_archive_browser
flutter analyze
flutter test
flutter drive --driver=test_driver/integration_test.dart --target=integration_test/digital_archive_browser_test.dart -d web-server --browser-name=chrome --profile
flutter build web --release --base-href /flutter-tutorial/previews/digital-archive-browser/
```

ChromeDriver 先在 4444 端口启动，并与 Chrome 主版本匹配。构建后打开：

```text
/flutter-tutorial/previews/digital-archive-browser/#/archive
```

再检查筛选后的 URL、详情直达、刷新、Back / Forward、新标签、对照上限和 release 资产。

## 项目完成检查

- [ ] fixture 保持 120 条记录、6 个馆藏、8 个年代、4 种开放状态。
- [ ] URL 是查询单一事实来源，非法和重复参数稳定归一化。
- [ ] Repository 可以 override，provider family 参数互不污染。
- [ ] 列表与网格共用结果序列、稳定 ID 和 lazy delegate。
- [ ] 缩略图 painter 只处理无交互图形，Semantics 由 Widget 提供。
- [ ] 第四条对照显示 live region，焦点到错误栏，并提供恢复动作。
- [ ] loading、error、retry、empty、非法详情可测试且可恢复。
- [ ] 三档尺寸、200% 文本、RTL、reduced motion、Chrome 主流程通过。
- [ ] Profile 环境、workload、摘要和相对比较方法已经记录。
- [ ] Release Web 能从独立 base href 加载并恢复 hash URL。

## 复习线索

- 风险表决定 unit、provider、widget、Semantics、Chrome、profile 的分工。
- URL 保存可分享查询；对照栏只保存稳定 ID。
- Mixed sliver 让 header、列表、网格和空状态共享 viewport。
- Painter 管像素，Widget 管交互、文字和语义。
- Lazy materialization 用“远端项滚动前不存在”固定，比统计 build 次数更稳。
- Profile 数字必须连同环境和 workload 解读，离群帧还需要 trace 定位。

## 参考资料

- [Testing Flutter apps](https://docs.flutter.dev/testing/overview)（查阅：2026-08-31）
- [Check app functionality with an integration test](https://docs.flutter.dev/testing/integration-tests)（查阅：2026-08-31）
- [`CustomPainter`](https://api.flutter.dev/flutter/rendering/CustomPainter-class.html)（查阅：2026-08-31）
- [Using slivers](https://docs.flutter.dev/ui/layout/scrolling/slivers)（查阅：2026-08-31）
- [Performance best practices](https://docs.flutter.dev/perf/best-practices)（查阅：2026-08-31）
- [Debug performance for web apps](https://docs.flutter.dev/perf/web-performance)（查阅：2026-08-31）
- [`Semantics`](https://api.flutter.dev/flutter/widgets/Semantics-class.html)（查阅：2026-08-31）

