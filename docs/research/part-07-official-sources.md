# 第七部分官方资料研究：测试、调试、渲染与性能

查阅日期：2026-08-31

## 1. 固定边界与版本基线

### 1.1 本部分解决的问题

前六部分已经让读者能完成状态、数据、导航、可访问性和应用架构。本部分不再扩展业务能力，而是建立三类工程判断：

1. 一个风险应该落在哪一层测试，失败时留下什么证据；
2. Widget、Element、RenderObject 如何协作，代码改动会触发 build、layout 还是 paint；
3. 如何用 profile 证据定位滚动和绘制问题，而不是凭“少写 Widget”“多加 `const`”或某个固定毫秒数猜性能。

官方测试概览把自动化测试分为 unit、widget、integration：unit 面向函数、方法或类；widget 在简化的 UI 环境里验证一个 Widget 的布局与交互；integration 在真实设备或模拟环境中验证完整应用或较大功能。官方建议通常保留较多 unit / widget 测试，再用足够的 integration 测试覆盖重要用例；这是一组速度、依赖、维护成本和信心的权衡，不是要求每个项目满足固定比例。[Testing Flutter apps](https://docs.flutter.dev/testing/overview)（查阅：2026-08-31）

### 1.2 工具链基线

仓库当前固定使用：

```text
Flutter 3.47.0 stable · framework 4cf2416426
Dart 3.13.0
DevTools 2.60.0
```

`flutter_test`、`integration_test` 和 framework API 以这份 SDK 为准。Flutter 官网多数概念页页脚仍标注“反映 Flutter 3.44.7”，因此 API 名称、弃用信息和 Web 工具行为还需与本地 3.47.0 源码交叉核对。[Flutter SDK archive](https://docs.flutter.dev/install/archive) · [Flutter 3.47.0 framework source](https://github.com/flutter/flutter/tree/4cf2416426)（查阅：2026-08-31）

项目仍只要求 Web 平台通过。这里必须把两类结论分开：

- correctness、可访问性、路由与真实浏览器流程由 Chrome 验收；
- Flutter DevTools 的 Flutter Frames、UI / raster thread 图只适用于 mobile / desktop。Flutter Web 在 profile mode 下把 timeline events 暴露给 Chrome DevTools Performance panel，DevTools 不能连接 profile Web 应用。[Use the Performance view](https://docs.flutter.dev/tools/devtools/performance) · [Debug performance for web apps](https://docs.flutter.dev/perf/web-performance) · [Flutter build modes](https://docs.flutter.dev/testing/build-modes)（查阅：2026-08-31）

### 1.3 已学前置

正文可以直接依赖下列概念，不重复展开：

- Dart 函数、类、sealed 类型、异常、Future / Stream；
- Widget、`build`、`BuildContext`、约束、滚动与 `CustomScrollView` 的使用层认识；
- 状态所有权、Key、生命周期、隐式 / 显式动画；
- Repository fake、Riverpod override、`ProviderContainer.test()`；
- 键盘、Semantics、文本缩放、响应式布局、hash URL 和 Chrome 集成流程；
- `flutter analyze`、`flutter test`、release Web build。

第二部分只介绍了 box / sliver 桥接，第七部分才解释 `SliverConstraints` / `SliverGeometry` 协议、lazy materialization、cache extent 和滚动性能。第三部分已经讲过 Element 身份与 Key，第七部分在此基础上补齐 Widget—Element—RenderObject 三棵树，不重新教学 Key。

## 2. 风险驱动的测试组合

### 2.1 “测试金字塔”是启发，不是配额

官方表格给出的稳定方向是：unit 依赖少、快、维护成本低，但端到端信心较低；integration 信心最高，同时慢、依赖多、维护成本高；widget 处在两者之间。正文应把它解释为“用最低成本覆盖目标风险”，不能写成 70/20/10 一类无来源配额。[Testing Flutter apps](https://docs.flutter.dev/testing/overview)（查阅：2026-08-31）

建议先写风险表，再选择测试层：

| 风险 | 首选证据 | 不足时再补 |
| --- | --- | --- |
| 排序、过滤、冲突规则、解析 | unit | Repository / provider 测试 |
| ViewModel 状态迁移、错误恢复 | unit / provider | Widget 状态测试 |
| 布局分支、用户输入、焦点、Semantics | Widget | Chrome 关键流程 |
| 字体、颜色、间距、绘制结果 | 确定性 golden | 人工浏览器截图 |
| URL、Back / Forward、刷新、真实 Web 资产 | Chrome integration | 手工新标签 / 硬刷新 |
| 滚动卡顿、长任务、异常重绘 | profile trace | 定向 build / layout / paint tracing |

测试层按风险定，不按文件名定。同一个 Repository 的纯映射规则可以是 unit test；真正连接 Drift Web 的刷新持久化属于浏览器流程。Widget test 能跑完整 Widget 生命周期，却不等于真实浏览器、原生平台 UI 或发布环境。[Testing Flutter apps](https://docs.flutter.dev/testing/overview) · [Plugins in Flutter tests](https://docs.flutter.dev/testing/plugins-in-tests)（查阅：2026-08-31）

### 2.2 fake、mock 与真实依赖

本教程继续优先手写 fake：它实现稳定接口，保存输入并返回可控结果，适合 Repository、时钟和目录 Service。只有测试真正需要逐次调用规则、参数匹配或异常脚本时才引入 mock；不能为了“单元测试都要 mock”把普通值对象和纯函数包成 mock。Flutter 官方架构测试案例同样通过 fake Repository 隔离 ViewModel，并明确每层应测试自己的职责。[Testing each layer](https://docs.flutter.dev/app-architecture/case-study/testing)（查阅：2026-08-31）

真实依赖只放在需要证明集成边界的测试中。若一条测试同时访问真实数据库、真实时钟、浏览器历史和渲染，失败后很难知道是哪一层坏了；这不是“更接近用户”就自动更好。

### 2.3 稳定测试先控制输入

以下输入必须显式固定：

- fixture、ID、排序 tie-breaker 和时钟；
- locale、text direction、主题、窗口尺寸、text scale、device pixel ratio；
- 动画推进时长、异步完成顺序和错误脚本；
- Web 数据库名、初始数据、URL 和浏览器起始状态。

测试不能依赖当前日期、随机数、网络、机器字体或“异步应该已经结束”。一条回归测试应把先前失败的可观察行为写进名称与断言；代码覆盖率只能说明代码执行过，不能说明风险已经被验证。

## 3. Widget 测试的控制循环

### 3.1 `testWidgets` 与 `WidgetTester`

`testWidgets` 为每例创建新的 `WidgetTester`，3.47.0 默认 `semanticsEnabled: true`，测试结束后自动释放该 Semantics handle。`pumpWidget` 挂载根 Widget、调度 frame 并执行一次 pump；再次 `pumpWidget` 会强制重建整棵树，即使根 Widget 对象与上次相同。[testWidgets API](https://api.flutter.dev/flutter/flutter_test/testWidgets.html) · [WidgetTester.pumpWidget API](https://api.flutter.dev/flutter/flutter_test/WidgetTester/pumpWidget.html) · [3.47.0 widget_tester.dart](https://github.com/flutter/flutter/blob/4cf2416426/packages/flutter_test/lib/src/widget_tester.dart)（查阅：2026-08-31）

正文使用固定循环：

```text
Arrange fixture / fake / viewport
→ pumpWidget
→ find 可操作对象
→ tap / enterText / drag / sendKeyEvent
→ 精确 pump
→ expect 可观察结果
```

`WidgetTester` 的交互方法只发送输入。测试环境不会因为状态变化自动替读者推进所有 frame；输入后要根据产品行为明确 pump 哪个时刻。[Tap, drag, and enter text](https://docs.flutter.dev/cookbook/testing/widget/tap-drag)（查阅：2026-08-31）

### 3.2 Finder 与 Matcher

Finder 负责定位候选，Matcher 负责表达期望数量或属性。优先顺序不是死规则，但应按用户可观察合同选择：

1. 可见文本、语义 label / identifier、tooltip；
2. 稳定业务 Key；
3. Widget 类型或祖先 / 后代关系；
4. 最后才是私有实现类、children 下标或坐标。

`find.text`、`find.byKey` 等 Finder 默认 `skipOffstage: true`，会跳过 `Offstage` 子树和非当前 Route；这不表示 lazy 列表远端条目已经构建。若目标尚未 materialize，应使用 `scrollUntilVisible` 驱动滚动，不要把 `skipOffstage: false` 当作创建远端 Element 的开关。[CommonFinders API](https://api.flutter.dev/flutter/flutter_test/CommonFinders-class.html) · [Handle scrolling](https://docs.flutter.dev/cookbook/testing/widget/scrolling) · [3.47.0 finders.dart](https://github.com/flutter/flutter/blob/4cf2416426/packages/flutter_test/lib/src/finders.dart)（查阅：2026-08-31）

`findsOneWidget`、`findsNothing`、`findsNWidgets` 只断言数量。若风险是按钮是否 disabled、字段错误文案是否与控件关联、语义 action 是否存在，应继续断言对应属性或 Semantics，不能停在“页面上有一个保存文本”。

### 3.3 `pump` 与 `pumpAndSettle`

`pump(duration)` 在 fake async 环境推进时间并触发一帧。动画测试应明确检查起点、中点、终点：这样既固定时长，也能发现动画迟一帧开始或提前结束。[WidgetTester.pump API](https://api.flutter.dev/flutter/flutter_test/WidgetTester/pump.html)（查阅：2026-08-31）

3.47.0 的 `pumpAndSettle` 每 100ms pump 一次，直到不再有 scheduled frame；它至少 pump 一次，返回实际 pump 次数，默认十分钟超时。持续动画、未停止的 ticker 或反复调度 frame 会导致超时；benchmark frame policy 下根本不能使用。官方 API 也建议在测试能预期 frame 数时检查返回值，因为多一帧本身可能是回归。[WidgetTester.pumpAndSettle API](https://api.flutter.dev/flutter/flutter_test/WidgetTester/pumpAndSettle.html) · [3.47.0 widget_tester.dart](https://github.com/flutter/flutter/blob/4cf2416426/packages/flutter_test/lib/src/widget_tester.dart#L692)（查阅：2026-08-31）

正文规则：

- 已知动画时长、debounce、timer：优先精确 `pump`；
- 等待有限、不关心中间帧的过渡：可以 `pumpAndSettle`，并解释为何会 settle；
- 持续 spinner / progress / ticker：等待某个状态或手动推进，不调用 `pumpAndSettle`；
- 真实 I/O：通过 fake 控制完成，只有必须逃离 fake async 时才谨慎使用 `runAsync`。

## 4. Semantics、golden 与 Web 集成证据

### 4.1 Semantics 测试断言用户可感知合同

`SemanticsController.find` 会从 Finder 对应的 RenderObject 向上寻找语义节点；若节点被 `MergeSemantics` 或父级合并，拿到的是合并后的祖先数据。`matchesSemantics` 中未提供的 label / hint / value 等字段不参与比较，但布尔 flag 和 action 默认都按 `false` 比较。3.47.0 文档更推荐直接使用 `CommonFinders.semantics` 搜索 Semantics tree，以避开 Widget Finder 与合并节点的边界。[SemanticsController API](https://api.flutter.dev/flutter/flutter_test/SemanticsController-class.html) · [matchesSemantics API](https://api.flutter.dev/flutter/flutter_test/matchesSemantics.html)（查阅：2026-08-31）

稳定断言应覆盖：

- label、value、role / button / link、enabled / selected / checked；
- tap、increase、decrease、scroll 等可用 action；
- live region、错误摘要和关键遍历顺序；
- custom painting 是否提供了等价的文本或语义节点。

不要固定自动分配的 `SemanticsNode.id`，也不要为了一个按钮快照整棵 Semantics dump。`simulatedAccessibilityTraversal` 适合检查顺序、可用性和交互，但 SDK 明确说明平台在滚动列表最后可见项等边界可能不同；真实浏览器屏幕阅读器仍需要人工抽查。[SemanticsController.simulatedAccessibilityTraversal API](https://api.flutter.dev/flutter/flutter_test/SemanticsController/simulatedAccessibilityTraversal.html)（查阅：2026-08-31）

### 4.2 Golden 是像素回归，不是功能测试

`matchesGoldenFile` 把当前图像与 master PNG 比较；`flutter test` 默认的 `LocalFileComparator` 做解码后的逐像素精确比较，`flutter test --update-goldens` 会更新基准。Finder 必须只匹配一个 Widget，捕获范围是最近的 `RepaintBoundary` 祖先。[matchesGoldenFile API](https://api.flutter.dev/flutter/flutter_test/matchesGoldenFile.html) · [GoldenFileComparator API](https://api.flutter.dev/flutter/flutter_test/GoldenFileComparator-class.html)（查阅：2026-08-31）

Golden 稳定合同：

- 固定 Flutter 版本、操作系统 / comparator、字体文件、locale、directionality、theme、viewport、DPR、text scale；
- fixture 与时钟确定，图片预解码，动画推进到明确状态；
- 用专属 `RepaintBoundary` 截取有视觉合同的区域，不给整个应用无差别截图；
- 更新 golden 前人工查看 diff，不能把 `--update-goldens` 当作修复命令。

Flutter API 明确提示自定义字体可能跨平台或跨 Flutter 版本产生不同像素；默认测试字体 Ahem 只画方块。仓库不引入第三方字体，因此中文 golden 只在同一受控环境验证构图，实际中文形态另由 Chrome 截图检查。[matchesGoldenFile custom fonts](https://api.flutter.dev/flutter/flutter_test/matchesGoldenFile.html)（查阅：2026-08-31）

3.47.0 的 Chrome golden 已支持 Finder，CanvasKit / Skwasm 通过最近 `RepaintBoundary` 的 layer 生成截图，但 `ui.Image` 直接 capture 在 Web 仍不支持。首版继续沿用仓库现有 host `flutter test` golden 流程，不同时切换 comparator 和 renderer；Chrome 用于真实交互，不作为两套 golden 基准。[3.47.0 _matchers_web.dart](https://github.com/flutter/flutter/blob/4cf2416426/packages/flutter_test/lib/src/_matchers_web.dart)（查阅：2026-08-31）

### 4.3 Integration test 只保留关键旅程

`integration_test` 使用与 widget test 相似的 `flutter_test` API，但运行完整应用。Web 官方流程需要匹配浏览器的 ChromeDriver，并通过 `flutter drive --driver=... --target=... -d web-server --browser-name=chrome` 驱动；它验证 URL、Back / Forward、刷新、真实 Web 资产和浏览器输入边界，不能被 release build 成功替代。[Check app functionality with an integration test](https://docs.flutter.dev/testing/integration-tests) · [integration_test source](https://github.com/flutter/flutter/tree/4cf2416426/packages/integration_test)（查阅：2026-08-31）

Integration test 不复制所有 unit / widget 分支。每个项目保留一条主旅程，必要时补一条恢复旅程；失败时保存命令、浏览器日志、URL 和截图。`integration_test` 不能操作原生系统权限弹窗、通知和 platform view，因此以后涉及这些边界时要换工具或人工验收，不能扩大本部分结论。[Testing Flutter apps](https://docs.flutter.dev/testing/overview)（查阅：2026-08-31）

## 5. 调试模式、断言、日志与 DevTools

### 5.1 build mode 决定可观察能力

官方模式边界：

| 模式 | 用途 | 关键边界 |
| --- | --- | --- |
| debug | 开发、断点、hot reload | assertions / service extensions 开启；性能不代表发布 |
| profile | 性能测量 | 保留 tracing 和部分 service extensions；接近 release 优化 |
| release | 发布 | assertions、调试信息和 service extensions 关闭 |

Web profile 使用 dart2js、保留 tree shaking 且不 minify；DevTools 不能连接，改用 Chrome DevTools。Web release 才 minify，不能在 debug 看到顺滑就宣称发布性能通过。[Flutter build modes](https://docs.flutter.dev/testing/build-modes)（查阅：2026-08-31）

Dart `assert` 只在开发期间生效，生产代码不能依赖它验证用户输入、网络响应或维持业务不变量。用户可恢复错误用 Result / validation；只有开发者不变量才使用 assert。[Dart assert](https://dart.dev/language/error-handling#assert)（查阅：2026-08-31）

### 5.2 先留下最小可复现证据

调试顺序固定为：

1. 写清实际结果、预期结果、最小操作和环境；
2. 用测试或稳定 fixture 复现；
3. 读取第一条相关异常和 stack trace；
4. 在状态边界记录结构化上下文，而不是到处 `print`；
5. 用断点、Inspector 或 timeline 验证一个假设；
6. 修复后保留最小回归测试。

`debugPrint` 适合开发期控制台信息，`dart:developer` 的 `log` 支持 name、level、error、stackTrace 和 sequenceNumber，并可进入调试工具；`debugger()` 只有调试器连接且条件成立时才请求断点。日志不得写 token、个人资料或完整业务对象。[3.47.0 debugPrint source](https://github.com/flutter/flutter/blob/4cf2416426/packages/flutter/lib/src/foundation/print.dart#L50) · [developer.log API](https://api.dart.dev/dart-developer/log.html) · [developer.debugger API](https://api.dart.dev/dart-developer/debugger.html)（查阅：2026-08-31）

### 5.3 Inspector 回答树与布局问题

Flutter Inspector 能选中实际界面对应的 Widget、查看 Widget tree 和属性、使用 Layout Explorer，并开启 slow animations、layout guidelines、baselines、highlight repaints 和 oversized images。Layout Explorer 的临时改值不会修改源码，hot reload 后恢复。[Use the Flutter inspector](https://docs.flutter.dev/tools/devtools/inspector)（查阅：2026-08-31）

`debugPaintSizeEnabled`、`debugRepaintRainbowEnabled`、`debugProfileBuildsEnabled`、`debugProfileLayoutsEnabled`、`debugProfilePaintsEnabled` 都是诊断开关，会改变输出或增加 tracing 成本。它们用于回答“谁 build / layout / paint 了”，不能常驻 production，也不能只凭彩虹闪动次数下结论。[debugPaintSizeEnabled](https://api.flutter.dev/flutter/rendering/debugPaintSizeEnabled.html) · [debugRepaintRainbowEnabled](https://api.flutter.dev/flutter/rendering/debugRepaintRainbowEnabled.html) · [3.47.0 widget build tracing source](https://github.com/flutter/flutter/blob/4cf2416426/packages/flutter/lib/src/widgets/debug.dart#L137) · [debugProfileLayoutsEnabled](https://api.flutter.dev/flutter/rendering/debugProfileLayoutsEnabled.html) · [debugProfilePaintsEnabled](https://api.flutter.dev/flutter/rendering/debugProfilePaintsEnabled.html)（查阅：2026-08-31）

## 6. Widget—Element—RenderObject 与流水线

### 6.1 三棵树各自保存什么

Widget 是不可变配置，可以频繁创建；Element 表示配置在树中的长期位置，持有 Widget、父子关系和 `BuildContext`，在 frame 之间保留；RenderObject 负责 layout、paint、hit testing 与 accessibility。`ComponentElement` 组织其他 Element，`RenderObjectElement` 把 Widget 配置更新到 RenderObject。[Flutter architectural overview](https://docs.flutter.dev/resources/architectural-overview)（查阅：2026-08-31）

框架用 `runtimeType` 与 Key 判断 `Widget.canUpdate`，可复用时让已有 Element 更新配置；因此“build 产生了新 Widget 对象”不等于状态和 RenderObject 全部重建。第三部分已经讲过 Key；这里用 Inspector 和最小 probe 对照三棵树，不重新列 Key 种类。[Widget.canUpdate API](https://api.flutter.dev/flutter/widgets/Widget/canUpdate.html) · [Inside Flutter](https://docs.flutter.dev/resources/inside-flutter)（查阅：2026-08-31）

### 6.2 frame 不是只有 build 和 paint

`PipelineOwner` 维护脏 RenderObject，并按 layout、compositing bits、paint、semantics 阶段 flush。build 属于 Widget / Element 更新，layout 决定几何，paint 记录绘制命令，compositing 把 layer 组合，semantics 生成辅助技术使用的树。[PipelineOwner API](https://api.flutter.dev/flutter/rendering/PipelineOwner-class.html) · [3.47.0 rendering/object.dart](https://github.com/flutter/flutter/blob/4cf2416426/packages/flutter/lib/src/rendering/object.dart#L1019)（查阅：2026-08-31）

脏标记决定影响范围：

- 配置变更可能只需要 build；
- 约束、尺寸或会影响父子几何的属性调用 `markNeedsLayout`，layout 后通常还需 paint / semantics；
- 颜色、阴影、绘制进度等不改变几何的属性可以只 `markNeedsPaint`；
- label、role 或 action 变化需要 `markNeedsSemanticsUpdate`。

不能把“重建”统称为“重绘”，也不能从 `setState` 直接推断 GPU 工作量。动画应优先改变最晚阶段能表达的属性，但是否值得优化仍要看 profile trace。

### 6.3 布局边界与一次遍历

RenderObject 从父级接收 Constraints，选择 size，再由父级定位子级。框架通过 relayout boundary 避免无关祖先重复布局，但 intrinsic 查询、复杂 baseline 和某些需要先测量所有子项的布局会增加额外 pass。长列表应使用 lazy builder，固定 extent 时 `SliverFixedExtentList` 能跳过逐子项测量主轴尺寸。[RenderObject.layout API](https://api.flutter.dev/flutter/rendering/RenderObject/layout.html) · [Performance best practices](https://docs.flutter.dev/perf/best-practices) · [SliverList API](https://api.flutter.dev/flutter/widgets/SliverList-class.html)（查阅：2026-08-31）

## 7. `CustomPainter` 与 `RepaintBoundary`

### 7.1 `CustomPainter` 适合连续绘制，不替代普通 Widget

`CustomPainter.paint` 获得 Canvas 和 Size；绘制应留在边界内，必要时先 `clipRect`，并成对使用 `save` / `restore`。它适合时间轴、图表、装饰和大量连续几何，不适合把文本按钮、表单或可访问内容全部压成一张画布。[CustomPainter API](https://api.flutter.dev/flutter/rendering/CustomPainter-class.html)（查阅：2026-08-31）

稳定实现合同：

- painter 构造参数是不可变绘制输入；
- `shouldRepaint` 比较真正影响像素的字段；返回 `false` 只是允许跳过 delegate 更新导致的 paint，祖先 / 后代重绘或 size 改变仍可能调用 `paint`；
- 只变化绘制、不变化 build / layout 的输入通过 `repaint: Listenable` 直接通知 paint；
- 自绘内容若承载含义，要用普通 Widget 提供等价语义，或实现 `semanticsBuilder` 与 `shouldRebuildSemantics`；
- `isComplex` 与 `willChange` 只是 raster cache hint，不是性能按钮。

这些行为均由 3.47.0 `CustomPainter` / `RenderCustomPaint` API 明确规定。[CustomPainter.shouldRepaint](https://api.flutter.dev/flutter/rendering/CustomPainter/shouldRepaint.html) · [CustomPainter.semanticsBuilder](https://api.flutter.dev/flutter/rendering/CustomPainter/semanticsBuilder.html) · [CustomPaint API](https://api.flutter.dev/flutter/widgets/CustomPaint-class.html)（查阅：2026-08-31）

某些 blend mode 会因为 CustomPainter 共享 Canvas 而影响先前内容；`saveLayer` 可隔离，但建立 offscreen buffer 有成本，只能在正确性需要时使用，并用 trace 检查。[CustomPainter API](https://api.flutter.dev/flutter/rendering/CustomPainter-class.html) · [Performance best practices](https://docs.flutter.dev/perf/best-practices)（查阅：2026-08-31）

### 7.2 `RepaintBoundary` 隔离 repaint，也增加成本

`RepaintBoundary` 让子树拥有独立 layer：脏 paint 向上只传播到最近 boundary，boundary 内重绘也不会自动带上外部。静态而复杂的子树还可能被 raster cache 缓存。[RepaintBoundary API](https://api.flutter.dev/flutter/widgets/RepaintBoundary-class.html)（查阅：2026-08-31）

它不是“包得越多越快”。独立 layer、合成和可能的缓存都占资源；若 boundary 两侧总是一起变化，隔离没有收益。`ListView` / `SliverChildBuilderDelegate` 默认已经给子项加 repaint boundary，项目不得再逐层套壳。先用 repaint rainbow / Track paints 找到变化不对称的边界，再在 profile trace 中验证。[SliverChildBuilderDelegate.addRepaintBoundaries API](https://api.flutter.dev/flutter/widgets/SliverChildBuilderDelegate/addRepaintBoundaries.html) · [RepaintBoundary API](https://api.flutter.dev/flutter/widgets/RepaintBoundary-class.html)（查阅：2026-08-31）

## 8. Sliver 协议与长滚动

### 8.1 Widget 层先组合已有 Sliver

`CustomScrollView` 接收 sliver 序列；常用组件包括 `SliverAppBar`、`SliverPersistentHeader`、`SliverList`、`SliverGrid`、`SliverFillRemaining` 和 `SliverToBoxAdapter`。普通 box 必须通过 adapter 进入 sliver 世界，不能把 `Container` 直接放进 `slivers`。[Using slivers](https://docs.flutter.dev/ui/layout/scrolling/slivers) · [CustomScrollView API](https://api.flutter.dev/flutter/widgets/CustomScrollView-class.html)（查阅：2026-08-31）

正文以组合现成 Sliver 为生产主线，只用一个只读协议探针解释 RenderSliver；不要求读者手写通用 `RenderSliver`。自定义 RenderObject 是 framework-level API，错误 geometry 会触发复杂断言，首个正式项目没有这个必要。

### 8.2 `SliverConstraints` 输入，`SliverGeometry` 输出

Viewport 给每个 RenderSliver 的核心输入包括：当前 `scrollOffset`、剩余可绘制长度 `remainingPaintExtent`、横轴范围、`cacheOrigin` 和 `remainingCacheExtent`。Sliver layout 后返回 `SliverGeometry`，至少描述总 `scrollExtent`、当前 `paintExtent`、`layoutExtent`、最大绘制范围、hit-test 可见性和 cache extent。paint extent 不能超过 viewport 给出的 remaining paint extent。[SliverConstraints API](https://api.flutter.dev/flutter/rendering/SliverConstraints-class.html) · [SliverGeometry API](https://api.flutter.dev/flutter/rendering/SliverGeometry-class.html) · [RenderSliver API](https://api.flutter.dev/flutter/rendering/RenderSliver-class.html)（查阅：2026-08-31）

cache extent 是“允许提前 layout / materialize 的区域”，不等于像素缓存，也不保证对象永久保活。调大它会提前准备更多内容，也会增加构建和内存成本；只在测量证明滚动前方准备不足时调整。

### 8.3 lazy、extent 与列表身份

`SliverList` 对不可见子项的主轴尺寸未知，因此使用 dead reckoning，把新 materialize 的子项放在已有子项旁。固定高度项目优先 `SliverFixedExtentList`；只有一个代表尺寸时可用 `SliverPrototypeExtentList`。多 delegate viewport 为估算总 scroll extent，可能强制 layout 每个 delegate 的第一个 child。[SliverList API](https://api.flutter.dev/flutter/widgets/SliverList-class.html) · [SliverMultiBoxAdaptorWidget API](https://api.flutter.dev/flutter/widgets/SliverMultiBoxAdaptorWidget-class.html)（查阅：2026-08-31）

3.47.0 版本边界：`SliverList.separated` 和 `ListView.separated` 正把 `findChildIndexCallback` 迁移为 `findItemIndexCallback`；旧 callback 返回含 separator 的 child index，新 callback 返回不含 separator 的 item index，二者不能同时提供。该弃用发生在 3.37.0-1.0.pre 后。正文只有在 keyed separated list 确实需要回查索引时才提，不为了覆盖 API 强塞示例。[3.47.0 SliverList source](https://github.com/flutter/flutter/blob/4cf2416426/packages/flutter/lib/src/widgets/sliver.dart#L167)（查阅：2026-08-31）

## 9. 性能分析、帧预算与 Web 边界

### 9.1 先定义 workload，再录 trace

性能结论至少记录：

- 构建模式、Flutter / 浏览器版本、renderer、机器和窗口；
- fixture 规模、起始滚动位置、操作脚本与录制区间；
- 首次运行还是 warm run；
- 观察到的是 build、layout、paint、raster、GC、图片解码还是浏览器 long task。

没有可重复 workload 的“感觉更流畅”不可验收。debug mode 有额外断言、JIT 和开发服务，不能作为发布性能证据；native 用真实低端目标设备的 profile mode，Web 用 profile Web + Chrome DevTools。[Flutter performance profiling](https://docs.flutter.dev/perf/ui-performance) · [Flutter build modes](https://docs.flutter.dev/testing/build-modes)（查阅：2026-08-31）

### 9.2 帧预算跟随刷新率

官方文档常以 60Hz 的约 16ms 和 120Hz 为例。正文应写通用关系：一帧可用时间约为 `1 / display refresh rate`；60Hz 约 16.7ms，120Hz 约 8.3ms。它是呈现节奏，不是所有机器都必须写死的 CI 常量。丢帧、输入延迟和长任务应结合目标设备与连续分布判断，不能拿一帧 17ms 判项目失败。[Flutter performance profiling](https://docs.flutter.dev/perf/ui-performance) · [Use the Performance view](https://docs.flutter.dev/tools/devtools/performance)（查阅：2026-08-31）

普通共享 CI 的负载、GPU、浏览器调度不稳定，项目自动门槛固定结构性条件：lazy materialization、无 overflow、无未捕获异常、工作流完成、trace 脚本可重复。绝对 frame time、p95 或 dropped frames 只在受控机器建立基线后启用。

### 9.3 原生 DevTools 与 Web Chrome DevTools

mobile / desktop 的 DevTools Performance view 提供 Flutter Frames、UI / raster thread、frame analysis、timeline events，并能临时 Track widget builds / layouts / paints。Web 不显示这套 Flutter Frames；Flutter 3.14+ 会把 build frame、draw scene、GC 等 timeline events送入 Chrome DevTools Performance panel，项目可按需启用 `debugProfileBuildsEnabledUserWidgets`、`debugProfileLayoutsEnabled`、`debugProfilePaintsEnabled`。[Use the Performance view](https://docs.flutter.dev/tools/devtools/performance) · [Debug performance for web apps](https://docs.flutter.dev/perf/web-performance)（查阅：2026-08-31）

Tracing flags 会增加事件和开销。先在 flags 全关时录 baseline；只有定位不到阶段时再开一个 flag，不能把开启详细 tracing 的数字与 baseline 直接比较。

### 9.4 Shader 与 renderer 不能混讲

DevTools native frame chart能标出 shader compilation。Flutter 3.47 的 iOS 和 Android API 29+ 默认使用 Impeller；Impeller在 engine build 时预编译较小的 shader 集合，目标是避免运行时 shader compilation。旧的 SkSL warm-up 教程不能当作当前所有 Flutter 项目的通用优化。[Impeller rendering engine](https://docs.flutter.dev/perf/impeller) · [Use the Performance view](https://docs.flutter.dev/tools/devtools/performance)（查阅：2026-08-31）

Web 走不同 renderer。3.47.0 工具源码固定：普通 JS 编译默认 CanvasKit，`--wasm` 默认 Skwasm；Wasm 构建仍生成 JS fallback，运行时没有 WasmGC 时使用 JS 输出。Skwasm 多线程还依赖 COOP / COEP 响应头。项目继续以现有 JS release build 为发布基线，不在第七部分顺手迁移 Wasm；Web jank 用 Chrome trace 看实际 renderer 的事件和浏览器 long task，不照搬 native shader 结论。[Compile Flutter to WebAssembly](https://docs.flutter.dev/platform-integration/web/wasm) · [3.47.0 WebRendererMode source](https://github.com/flutter/flutter/blob/4cf2416426/packages/flutter_tools/lib/src/web/compile.dart#L186)（查阅：2026-08-31）

## 10. `07-01` 至 `07-07` 固定章节边界

### 10.1 `07-01` 测试策略与单元测试

前置：`architecture.viewmodel`、`test.fake-repository`。

首次完整讲解：

- `test.strategy`
- `test.unit`
- `test.determinism`

重点：

- 从功能风险表选择 unit / provider / widget / integration / golden / profile 证据；
- 解释速度、信心、依赖和维护成本，不给固定金字塔比例；
- 用“档案记录排序与同年 tie-breaker”纯 Dart 例子写 arrange—act—assert、table-driven cases、fake clock；
- 区分 fake、mock、真实依赖和回归测试。

禁止提前出现：`WidgetTester` API、Semantics / golden、ChromeDriver、DevTools、项目源码。

### 10.2 `07-02` Widget、语义与视觉测试

前置：`test.widget-smoke`、`a11y.semantics`。

首次完整讲解：

- `test.widget`
- `test.semantics`
- `test.golden-boundary`

重点：

- `testWidgets`、`pumpWidget`、Finder、Matcher、tap / enterText / drag / keyboard；
- 精确 `pump`，`pumpAndSettle` 返回次数、超时与持续动画边界；
- offstage、lazy list 和 `scrollUntilVisible`；
- Semantics label / role / state / action / traversal，不断言 node ID；
- golden 的 capture boundary、固定字体与环境、diff 审查；
- fixture、viewport、locale、text scale 与清理。

示例使用独立“档案筛选条”和“馆藏状态徽记”，不使用第七部分项目；只在本章加入 Semantics 测试和一张确定性 golden，不讲 Chrome 驱动。

### 10.3 `07-03` Web 浏览器关键流程

前置：`test.widget`、`navigation.go-router`。

首次完整讲解：

- `test.integration-web`
- `test.webdriver`
- `test.failure-artifact`

重点：

- integration 只保留关键旅程，解释 ChromeDriver、端口、URL、刷新和真实资产；
- 区分 Widget test、release build 和真实 Chrome 各自能证明什么；
- 失败时保留命令、URL、日志、截图和最小 fixture。

示例使用独立浏览器流程，不重复 07-02 的 Widget 分支；不得提前解析“长卷时间轴”或“数字档案浏览器”。

### 10.4 `07-04` Widget、Element、RenderObject

前置：`runtime.element-identity`、`runtime.build`。

首次完整讲解：

- `internals.widget-element-renderobject`
- `internals.update-matching`
- `debug.rebuild`

重点：

- debug / profile / release、assert 边界、结构化日志、断点和回归测试；
- 用 Inspector 对照 Widget、Element、RenderObject 与 `BuildContext`；
- 解释 Widget 可丢弃、Element 持久、RenderObject 承担 layout / paint；
- 一次配置更新如何复用 Element，不把 build 说成整树重建。

示例为可切换标题的三棵树 probe；不引入自定义 RenderObject。

### 10.5 `07-05` build、layout、paint、composite

前置：`internals.widget-element-renderobject`、`layout.constraints`。

首次完整讲解：

- `render.pipeline`
- `render.repaint-boundary`
- `debug.layout-paint`

重点：

- build、layout、compositing bits、paint、semantics；
- `markNeedsLayout` / `markNeedsPaint` / `markNeedsSemanticsUpdate` 的影响范围；
- `CustomPainter`、`repaint: Listenable`、`shouldRepaint`、`semanticsBuilder`；
- `RepaintBoundary` 的隔离收益、layer / cache 成本和验证方式。

示例只画一条可更新的馆藏年代尺，使用普通 Widget 承担交互；不提前讲 Sliver 协议和项目实现。

### 10.6 `07-06` 长列表、Sliver 与性能分析

前置：`render.pipeline`、`layout.lazy-list`、`test.determinism`。

首次完整讲解：

- `performance.frame-budget`
- `performance.devtools`
- `layout.sliver`
- `performance.memory`
- `project.scroll-timeline`

重点：

- 用 `CustomScrollView`、header、list、grid、adapter 建立组合主线；
- 解释 `SliverConstraints` → `SliverGeometry`、paint / cache extent 与 dead reckoning；
- 根据固定 / 可变 extent 选 Sliver；
- 定义 workload，区分 debug / profile，按刷新率理解帧预算；
- native DevTools 与 Web Chrome DevTools、shader / Impeller / Web renderer 边界；
- 正文末尾集中引用并讲解重点项目“长卷时间轴”，不得跨到 07-07 继续拆项目。

### 10.7 `07-07` 统筹项目：数字档案浏览器

前置：本部分全部 `provides`。

首次完整讲解：

- `project.digital-archive-browser`

本章只做项目集中讲解：项目简报、风险表、测试分层、树与渲染取舍、Sliver 结构、Web profile 证据、关键源码 region 和验收结果。07-01 至 07-06 的小例子与“长卷时间轴”都不得成为统筹项目的分段预告。

## 11. 重点项目：长卷时间轴

### 11.1 使用场景与路径

地方档案馆要发布一条“河岸修复六十年”长卷，读者可以按阶段浏览 72 条确定性事件，通过目录跳到某个阶段，并按四类主题过滤。时间轴要保留长卷的连续视觉，但不能一次构建全部事件，也不能把文字、按钮和可访问性画进 Canvas。

固定路径、ID 和预览路径：

```text
examples/focus/scroll_timeline/
project: scroll-timeline
/flutter-tutorial/previews/scroll-timeline/
```

### 11.2 数据与功能合同

固定 fixture：6 个阶段、72 条事件、4 个主题。最小模型：

- `TimelineEra`：稳定 ID、名称、起止年份、短说明；
- `TimelineEvent`：稳定 ID、era ID、年份、同年序号、标题、摘要、主题；
- 排序固定为年份、同年序号、稳定 ID，过滤后保持原顺序。

功能固定为：

- `CustomScrollView` + pinned 阶段目录 + lazy `SliverList`；
- 窄屏为单列长卷，宽屏保留左侧目录和右侧时间轴；布局切换不改变筛选或当前可见阶段；
- 四类主题多选与“全部”恢复；空结果有明确状态；
- 目录按钮使用 `Scrollable.ensureVisible` / 对应 Sliver 位置跳转，焦点落到目标阶段标题；
- 时间轴脊线和滚动进度使用 `CustomPainter`，事件标题、摘要、按钮全部由普通 Widget 与 Semantics 提供；
- scroll controller 作为 painter 的 `repaint` Listenable，进度变化不触发整页 `setState`；
- 只在 profile 证明 overlay 与列表 repaint 不对称时保留一处 `RepaintBoundary`；不得给每个事件额外嵌套 boundary；
- 320×720、768×900、1440×900、200% 文本和 reduced motion 下完成筛选、目录跳转和连续滚动；
- 视觉采用档案修复桌的炭黑、矿物蓝与铜色标记，保留纸张留白但不做仿旧噪点、卷轴边框或通用后台卡片阵列。

### 11.3 明确不做

- 不做网络、数据库、账号、编辑、上传、评论或地图；
- 不做水平时间轴、自由缩放、拖拽惯性或无限数据；
- 不手写 `RenderSliver`；
- 不使用自定义 shader、`saveLayer` 特效或逐项 Hero；
- 不把 hover 设为查看事件的唯一方式；
- 不复制 Flutter 官方 sliver / parallax 示例的视觉和数据。

### 11.4 测试与性能合同

Unit / Widget 至少覆盖：

1. 同年事件排序 tie-breaker、单类 / 多类筛选和空结果；
2. 首帧只 materialize viewport 与 cache 邻近事件，远端事件在滚动前不存在、滚动后出现；
3. pinned header、目录跳转、焦点、键盘筛选和恢复全部；
4. CustomPainter 输入相同不 repaint，进度 / 主题变化触发 repaint；
5. painter 不吞掉事件标题、年份和操作的 Semantics；
6. 320×720、768×900、1440×900、200% 文本、reduced motion 无 overflow；
7. 一张固定 1440×900 的首屏 golden 和一张固定 320×720 的中段 golden，使用受控测试字体并固定 DPR、locale、fixture 与 scroll offset；中文实际字形由 Chrome 检查。

Chrome 关键流程：选择两个主题，键盘跳到第五阶段，连续滚动到末尾，恢复全部并回到第一阶段；release Web 从独立 base href 加载。

性能证据固定两个 workload：

- baseline：无 tracing flags，profile Web 从第一阶段连续滚到末尾；
- diagnosis：只开 `debugProfileBuildsEnabledUserWidgets` 或 `debugProfilePaintsEnabled` 之一，复现同一段滚动。

项目记录浏览器、renderer、fixture、窗口和操作脚本。自动测试只固定 lazy materialization、无异常和旅程完成；不把普通 CI 的绝对 frame time 设为唯一门槛。若加入 / 移除 `RepaintBoundary`，必须保留前后同一 workload 的 Chrome trace 结论。

## 12. 统筹项目：数字档案浏览器

### 12.1 使用场景与路径

研究者要浏览一批已数字化的城市公共档案：搜索题名和人物，按年代、馆藏和开放状态筛选，在列表 / 紧凑网格间切换，打开稳定深链接查看记录，并把最多三条记录放入对照栏。数据来自本地确定性 fixture，项目重点是测试证据、lazy 渲染和 Web profile，不再引入新的后端栈。

固定路径、ID 和预览路径：

```text
examples/capstones/digital_archive_browser/
project: digital-archive-browser
/flutter-tutorial/previews/digital-archive-browser/
```

预览沿用 hash URL 和独立 base href。

### 12.2 数据合同

固定 fixture：120 条记录、6 个馆藏、8 个年代段、4 种开放状态。最小模型：

- `ArchiveRecord`：稳定 ID、馆藏 ID、年代、题名、人物、摘要、开放状态、媒介、缩略图 seed；
- `ArchiveCollection`：稳定 ID、名称、说明；
- `ArchiveQuery`：搜索、年代、馆藏、开放状态、排序、view mode；
- `ComparisonTray`：最多三个稳定 record ID，不复制完整记录。

搜索做大小写归一、空白折叠和 Unicode 安全包含匹配；排序必须有稳定 ID tie-breaker。缩略图使用本地确定性资源或由 seed 驱动的轻量绘制，不请求远程图片。

### 12.3 功能合同

- 首页 hash URL 保存搜索、年代、馆藏、开放状态、排序和 view mode；非法 / 重复参数有稳定归一化策略；
- 宽屏为 filter rail + mixed sliver 结果区，窄屏为 filter sheet + 单列；切换不丢 query、焦点或 scroll state；
- 结果区用 `CustomScrollView`，包含 pinned 查询摘要、年代分组、lazy list / grid 和空状态；禁止 `SingleChildScrollView` 包含全部 120 项；
- record deep link `#/records/:recordId`，不存在 ID 有独立错误状态；Back / Forward、刷新和新标签恢复；
- 最多三条记录进入对照栏，对照题名、年代、人物、媒介和开放状态；第四条被拒绝时有可操作错误与 live region；
- query 是 URL 的单一事实来源；fixture Repository 是记录单一事实来源；对照栏由 ViewModel 保存稳定 ID；
- Riverpod 继续只负责对象图与状态，不为了本部分重写第六部分架构；
- 缩略图绘制与结果项文本分开，`shouldRepaint` 只比较 seed / palette；可访问名称由 Widget 提供；
- 320×720、768×900、1440×900、200% 文本、RTL 测试壳与 reduced motion 保持主要任务；
- 视觉采用现代数字阅览室：深墨蓝工作区、暖白档案面、馆藏色签和清晰元数据层级，不做文件夹拟物、泛黄滤镜或通用电商瀑布流。

### 12.4 架构与渲染合同

```text
ArchiveBrowserView / RecordDetailView / ComparisonView
  ↓ intent                         ↑ immutable view state
ArchiveBrowserViewModel / ComparisonViewModel
  ↓                                ↑ Result
ArchiveRepository（抽象接口，确定性 fixture 实现）
  └─ ArchiveFixtureService → bundled JSON / assets
```

- URL parser / encoder、query normalization、排序和对照上限是纯 Dart；
- Repository provider 是测试主要 override seam；
- query provider 从 Router 读取，不在 ViewModel 保留第二份可写 query；
- list / grid 共用同一结果序列和 record identity；
- 每个 lazy delegate 提供稳定 Key；只有数据顺序动态变化且状态需要随记录移动时才提供 index callback；
- 普通结果项沿用 delegate 默认 repaint boundaries，不逐项手工套两层；缩略图是否单独隔离由 profile 证据决定；
- `CustomPainter` 只负责无交互缩略图背景，题名、状态和操作都是 Widget / Semantics；
- 不实现自定义 RenderObject / RenderSliver。

### 12.5 明确不做

- 不做账号、上传、OCR、全文索引、服务端搜索、云同步或协作标注；
- 不做真实版权判断、个人敏感信息或下载原件；fixture 全部虚构；
- 不做收藏持久化、数据库迁移或离线同步；
- 不做图片缩放器、瓦片加载、视频 / 音频播放器；
- 不做 Wasm 迁移、renderer 切换或自定义 shader；
- 不把 golden 用作统筹项目的发布门槛：仓库首版规格只要求“长卷时间轴”维护第七部分 deterministic golden；
- 不与前六个统筹项目共享业务模型、主题组件、数据库或 provider 封装。

### 12.6 自动测试合同

Unit / provider 至少覆盖：

1. query parse / encode 往返、Unicode 搜索、空白折叠、非法 / 重复参数；
2. 多筛选交集、排序 tie-breaker、空结果与 view mode；
3. 对照栏新增、移除、重复 ID、第四条拒绝和记录不存在；
4. Repository fixture 错误映射，不泄漏底层异常文案；
5. family 参数隔离、override fake、离开页面后的 disposal；
6. list / grid 共用相同稳定结果与 record identity。

Widget / Semantics 至少覆盖：

1. loading、data、empty、首次失败和 retry；
2. URL query 改变时筛选控件、摘要和结果同步，不维护第二份值；
3. lazy 结果只 materialize viewport 附近，滚动后远端记录出现；
4. list / grid 切换、年代 header、非法详情和 Back；
5. 对照上限错误包含 label、live region、焦点和恢复动作；
6. 320×720、768×900、1440×900、200% 文本、RTL、reduced motion；
7. 键盘完成搜索、筛选、打开详情、加入三条记录、比较和返回。

本项目 `Visual` 为 `not-applicable`，因此不维护 golden；这不免除三种尺寸、200% 文本、截图 diff 人工审查和实际 Chrome 视觉检查。

### 12.7 Chrome 与 profile 合同

Chrome 关键流程固定为：

1. 输入 Unicode 查询，选择馆藏、年代和开放状态，切换紧凑网格；
2. 打开一条深链接，使用 Back / Forward，并复制 URL 到新标签；
3. 加入三条记录并打开对照，第四条显示可恢复错误；
4. 返回结果并滚到末端，确认 query、view mode 和 record identity 未丢；
5. 硬刷新，确认 URL 状态恢复；
6. release Web 从 `/flutter-tutorial/previews/digital-archive-browser/` 加载。

profile workload 固定为“120 条全部结果 → 连续滚动三段 → 切换 grid → 输入查询 → 打开详情 → Back”。先用 flags 关闭的 Chrome trace 建 baseline，再按问题只开启 build、layout 或 paint 之一。验收记录相对证据：是否一次构建全部 120 项、是否出现重复全结果 layout / paint、搜索是否产生浏览器 long task、修改后同一 workload 是否改善。未经受控机器校准，不把绝对 frame time 写入 CI pass / fail。

## 13. 全部分验收矩阵

| 维度 | 自动检查 | 浏览器 / profile 检查 |
| --- | --- | --- |
| 测试策略 | 风险表映射到具体 test 名称 | 关键旅程没有重复所有低层分支 |
| Unit / provider | 规则、fake、时钟、错误与状态迁移 | 不适用 |
| Widget | Finder、interaction、精确 pump、scroll | 真实输入行为与 Widget test 一致 |
| Semantics | label / role / state / action / traversal | 键盘与辅助技术抽查 |
| Golden | 长卷两张确定性 golden、字体与环境固定 | 人工审阅 diff，不盲更基准 |
| Integration | ChromeDriver 主旅程、URL、错误留证 | Back / Forward、刷新、新标签、release base href |
| 渲染 | painter、semantics、lazy materialization | repaint highlight 与视觉检查 |
| 性能 | 结构性断言、workload 可重复 | profile Web + Chrome trace，相对前后证据 |
| 响应式 | 320×720、768×900、1440×900、200% 文本 | 三种尺寸连续完成任务 |
| 发布 | analyze、unit / Widget、Chrome drive、release Web build | 实际预览路径加载 |

## 14. 写作时必须避免的误讲

| 不准确说法 | 应改为 |
| --- | --- |
| “测试金字塔要求 70% unit、20% widget、10% integration” | 官方只给速度、依赖、维护成本和信心的方向；项目按风险选择层级，不套固定比例。 |
| “Widget test 就是小型集成测试，所以可以代替浏览器” | Widget test 使用简化 UI 环境；URL、浏览器历史、真实 Web 资产和发布限制仍需 Chrome。 |
| “单元测试必须 mock 所有依赖” | 纯值和纯函数直接测试；稳定接口优先 fake，需要调用脚本时再考虑 mock。 |
| “Finder 找到文字就证明按钮可用” | 数量只是一层证据；还要断言 enabled、action、状态和交互结果。 |
| “`skipOffstage: false` 能找到 lazy 列表所有条目” | 它只包含已存在的 offstage Element；尚未 materialize 的条目要滚动创建。 |
| “交互后统一 `pumpAndSettle` 最稳” | 已知时长优先精确 pump；持续动画不会 settle，`pumpAndSettle` 还可能掩盖多一帧回归。 |
| “`pumpAndSettle` 没有返回值” | 3.47.0 返回 pump 次数，并可能超时；benchmark frame policy 下不能用。 |
| “Semantics test 比较整棵树最完整” | 断言用户可感知 label、role、state、action 与顺序；内部 node ID 和无关结构会让测试脆弱。 |
| “Golden 通过就说明功能正确” | Golden 比较像素；交互、语义、状态和 URL 仍需各自测试。 |
| “Golden 跨机器天然稳定” | 字体、OS、Flutter 版本、DPR 和 renderer 都可能改变像素，必须固定环境。 |
| “`flutter build web` 成功等于集成测试通过” | build 只证明可编译；Back / Forward、刷新、键盘和运行资产要在浏览器验证。 |
| “`assert` 可以保护 release 里的用户输入” | Release 关闭 assertions；用户输入必须用运行时 validation。 |
| “`print` 越多越容易定位问题” | 先保留最小复现、错误、stack trace 和结构化上下文；无边界日志会制造噪声并泄漏数据。 |
| “Widget 就是屏幕上的对象” | Widget 是不可变配置，Element 保存位置，RenderObject 负责 layout / paint / hit test / semantics。 |
| “build 一次就会重新 layout 和 paint 整个应用” | 脏标记与边界决定后续阶段和范围；build、layout、paint 不能混称。 |
| “`shouldRepaint: false` 保证 `paint` 不再执行” | 祖先 / 后代重绘或 size 改变仍可能 paint；它只允许跳过 delegate 更新造成的重绘。 |
| “自绘内容自动有可访问语义” | Canvas 像素没有业务语义；用普通 Widget 或 `semanticsBuilder` 补齐。 |
| “给每个 Widget 加 `RepaintBoundary` 会更快” | Boundary 增加 layer / cache 成本；delegate 常已自动添加，需用 profile 证明变化不对称。 |
| “cache extent 是图片像素缓存” | 它是 viewport 提前 layout / materialize 的范围，不是 raster cache。 |
| “Sliver 是一种带动画的 Widget” | Sliver 是 viewport 的滚动布局协议；动画只是部分组件的行为。 |
| “`SliverList` 知道所有不可见 child 的尺寸” | 可变高度列表用 dead reckoning；固定 extent 时选固定 extent sliver 更高效。 |
| “16ms 是 Flutter 永远不变的性能门槛” | 约 16.7ms 对应 60Hz，120Hz 约 8.3ms；按目标刷新率、设备和帧分布判断。 |
| “debug mode 看起来不卡就通过性能验收” | debug 的断言、JIT 和服务会改变行为；性能用 profile。 |
| “Flutter DevTools Performance view 可以直接分析 profile Web” | Web profile 用 Chrome DevTools Performance panel；Flutter Frames 视图用于 mobile / desktop。 |
| “shader warm-up 是所有 Flutter 卡顿的标准修复” | Impeller 与 Web renderer 的 shader 路径不同；先确认 renderer 与 trace 证据。 |
| “普通 CI 上一次 p95 超阈值就证明回归” | 共享 CI 性能噪声高；先固定 workload 与受控基线，CI 优先检查结构性不变量。 |

## 15. 正文参考资料清单

章节页尾只列实际使用的来源，不把本清单整体复制。

- [Testing Flutter apps](https://docs.flutter.dev/testing/overview)（查阅：2026-08-31）
- [An introduction to widget testing](https://docs.flutter.dev/cookbook/testing/widget/introduction)（查阅：2026-08-31）
- [Find widgets](https://docs.flutter.dev/cookbook/testing/widget/finders)（查阅：2026-08-31）
- [Tap, drag, and enter text](https://docs.flutter.dev/cookbook/testing/widget/tap-drag)（查阅：2026-08-31）
- [Handle scrolling](https://docs.flutter.dev/cookbook/testing/widget/scrolling)（查阅：2026-08-31）
- [WidgetTester API](https://api.flutter.dev/flutter/flutter_test/WidgetTester-class.html)（查阅：2026-08-31）
- [CommonFinders API](https://api.flutter.dev/flutter/flutter_test/CommonFinders-class.html)（查阅：2026-08-31）
- [matchesSemantics API](https://api.flutter.dev/flutter/flutter_test/matchesSemantics.html)（查阅：2026-08-31）
- [matchesGoldenFile API](https://api.flutter.dev/flutter/flutter_test/matchesGoldenFile.html)（查阅：2026-08-31）
- [GoldenFileComparator API](https://api.flutter.dev/flutter/flutter_test/GoldenFileComparator-class.html)（查阅：2026-08-31）
- [Check app functionality with an integration test](https://docs.flutter.dev/testing/integration-tests)（查阅：2026-08-31）
- [Testing each layer](https://docs.flutter.dev/app-architecture/case-study/testing)（查阅：2026-08-31）
- [Flutter build modes](https://docs.flutter.dev/testing/build-modes)（查阅：2026-08-31）
- [Dart assert](https://dart.dev/language/error-handling#assert)（查阅：2026-08-31）
- [developer.log API](https://api.dart.dev/dart-developer/log.html)（查阅：2026-08-31）
- [developer.debugger API](https://api.dart.dev/dart-developer/debugger.html)（查阅：2026-08-31）
- [Use the Flutter inspector](https://docs.flutter.dev/tools/devtools/inspector)（查阅：2026-08-31）
- [Flutter architectural overview](https://docs.flutter.dev/resources/architectural-overview)（查阅：2026-08-31）
- [Inside Flutter](https://docs.flutter.dev/resources/inside-flutter)（查阅：2026-08-31）
- [PipelineOwner API](https://api.flutter.dev/flutter/rendering/PipelineOwner-class.html)（查阅：2026-08-31）
- [CustomPainter API](https://api.flutter.dev/flutter/rendering/CustomPainter-class.html)（查阅：2026-08-31）
- [CustomPaint API](https://api.flutter.dev/flutter/widgets/CustomPaint-class.html)（查阅：2026-08-31）
- [RepaintBoundary API](https://api.flutter.dev/flutter/widgets/RepaintBoundary-class.html)（查阅：2026-08-31）
- [Using slivers](https://docs.flutter.dev/ui/layout/scrolling/slivers)（查阅：2026-08-31）
- [CustomScrollView API](https://api.flutter.dev/flutter/widgets/CustomScrollView-class.html)（查阅：2026-08-31）
- [SliverConstraints API](https://api.flutter.dev/flutter/rendering/SliverConstraints-class.html)（查阅：2026-08-31）
- [SliverGeometry API](https://api.flutter.dev/flutter/rendering/SliverGeometry-class.html)（查阅：2026-08-31）
- [SliverList API](https://api.flutter.dev/flutter/widgets/SliverList-class.html)（查阅：2026-08-31）
- [Performance best practices](https://docs.flutter.dev/perf/best-practices)（查阅：2026-08-31）
- [Flutter performance profiling](https://docs.flutter.dev/perf/ui-performance)（查阅：2026-08-31）
- [Use the Performance view](https://docs.flutter.dev/tools/devtools/performance)（查阅：2026-08-31）
- [Debug performance for web apps](https://docs.flutter.dev/perf/web-performance)（查阅：2026-08-31）
- [Impeller rendering engine](https://docs.flutter.dev/perf/impeller)（查阅：2026-08-31）
- [Compile Flutter to WebAssembly](https://docs.flutter.dev/platform-integration/web/wasm)（查阅：2026-08-31）
- [Flutter 3.47.0 framework source](https://github.com/flutter/flutter/tree/4cf2416426)（查阅：2026-08-31）

## 16. 进入实现前仍需验证

下列问题不改变章节与项目合同，但项目开工前要用正式源码验证：

1. 在当前 Windows + Flutter 3.47.0 环境建立最小 golden probe，确认受控测试字体、DPR、locale、`RepaintBoundary` 捕获范围和两种 viewport；再决定两张“长卷时间轴”基准的文件名与 comparator 配置，并用 Chrome 补查中文实际字形。
2. 用 Chrome integration probe 确认当前 Chrome / ChromeDriver 版本、`flutter drive` 命令、headless 行为、独立 base href 和失败截图保存位置；既有项目前几部分的通过记录不能替代 3.47.0 复验。
3. 为“长卷时间轴”做 320 / 768 / 1440 三宽原型，按内容拥挤点决定目录 rail 切换，不把某个设备名写成断点原因；同时确认 72 条可变高度事件的 cache extent 保持默认是否足够。
4. 先实现没有手工 `RepaintBoundary` 的时间轴进度 painter，录 profile Web baseline；只有 repaint trace 证明 overlay 与内容变化不对称时才加入 boundary，并保存前后同 workload 结论。
5. 用本地 3.47.0 验证 `scrollController` 作为 `CustomPainter(repaint:)` 时滚动只触发 paint，不引起项目自有 Widget rebuild；同时确认 painter 与普通 Widget 提供的 Semantics 不重复播报。
6. 在 `SliverList.separated` 的 keyed probe 中编译 `findItemIndexCallback`，确认 3.47.0 的 item index 语义；若正式项目不需要 separated keyed reordering，正文只保留版本注记，不写多余 API 示例。
7. 对“数字档案浏览器”120 条 fixture 录 flags 全关的 Chrome profile trace，再分别开启 build / layout / paint 单项追踪，确认页面能在当前 JS + CanvasKit 发布基线复现；不要在同一步引入 Wasm / Skwasm。
8. 受控性能机器和阈值尚未定义，因此第七部分首版不把绝对 frame time、p95 或 long-task 数量写进 CI。若后续要加入数字门槛，应先记录机器、Chrome、renderer、窗口、fixture、warm-up 与至少多次重复的基线分布。
