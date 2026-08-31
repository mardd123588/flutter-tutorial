---
title: 项目：场馆导览册
description: 统筹 ShellRoute、深链接、响应式导航、键盘、语义、本地化与 Web 测试。
part: 5
order: 7
kind: capstone
requires:
  - navigation.navigator-stack
  - navigation.route-result
  - navigation.pop-scope
  - navigation.router
  - navigation.url-state
  - navigation.go-router
  - navigation.shell-route
  - navigation.deep-link
  - navigation.url-validation
  - deployment.hash-url
  - layout.responsive
  - layout.content-breakpoint
  - navigation.adaptive-shell
  - input.adaptive
  - a11y.semantics
  - a11y.keyboard-flow
  - a11y.text-scale
  - a11y.error-feedback
  - a11y.motion-preference
  - i18n.gen-l10n
  - i18n.arb
  - i18n.format
  - i18n.locale
  - i18n.directionality
provides:
  - project.venue-guidebook
project: venue-guidebook
status: verified
---

# 项目：场馆导览册

场馆导览册把这一部分的路由、URL、响应式、输入、可访问性和本地化放进同一个 Flutter Web 应用。用户可以搜索地点、查看楼层、切换标签、浏览三条路线，并在中文与英文之间切换。

需要回查单项机制时，可返回[页面栈](/guide/part-05/01-navigator-page-stack)、[Router 与 go_router](/guide/part-05/02-router-url-go-router)、[深链接](/guide/part-05/03-deep-links-route-share-card)、[响应式与平台适配](/guide/part-05/04-responsive-adaptive)、[可访问性](/guide/part-05/05-accessibility-as-feature)和[国际化](/guide/part-05/06-internationalization-localization)。本章只讲这些机制如何共享路由与页面状态。

这里从项目合同开始，再按数据与控制流解释实现。建议先独立完成一个版本，再对照源码和测试。

## 项目简报

### 使用场景

访客在馆内用手机、平板或公共触屏查找地点。工作人员也会在桌面浏览器打开同一地址。网络与定位不可用时，固定导览数据仍应完整显示。

### 功能要求

- 顶层有“地点”“路线”“关于”三个目的地；
- `ShellRoute` 保持共同外壳，不使用 `StatefulShellRoute`；
- `/venues/:venueId` 保存地点身份，`floor` 和 `tag` 写入 query；
- 900px 以下使用 `NavigationDrawer`，以上使用 `NavigationRail`；
- `/` 聚焦地点搜索，Escape 关闭 Drawer；
- 中英文切换后保留 URL、query、搜索文本和焦点；
- 楼层图只给语义摘要，房间操作由可聚焦列表承担；
- 200% 文本、RTL 测试壳和减少动画模式不丢任务；
- 两张确定性 golden 固定宽屏首页与窄屏详情的视觉基线。

### 明确不做

项目不接地图 SDK、室内定位、网络、数据库、账号或推送，也不与路线分享卡共享业务模型和 UI 包。RTL 只检查布局健壮性，不表示已经提供阿拉伯语等 RTL 翻译。

## 先看完整状态流

```text
地址栏 / 浏览器历史
        ↕ GoRouter
VenueUrlCodec ──→ ValidVenueLink / InvalidVenueLink
        ↓
ShellRoute ──→ Drawer 或 Rail ──→ 当前页面
        ↓
VenueGuideController
  ├─ Locale
  └─ 搜索 FocusNode 注册点
        ↓
ARB / gen_l10n ──→ 当前语言文字与格式
```

地点列表的搜索与筛选是页面局部状态；地点身份、楼层和标签属于可分享状态，写进 URL；locale 属于跨页面显示偏好；焦点节点仍由创建它的页面负责释放。每一类状态只有一个事实来源。

## ShellRoute 只保留共同外壳

路由表把三个顶层目的地放进一个普通 `ShellRoute`：

<<< ../../../examples/capstones/venue_guidebook/lib/src/venue_guidebook_app.dart#venue-guide-router{dart}

`/` 规范化到 `/venues`。地点详情仍在 Shell 内，所以宽屏 Rail 和窄屏 AppBar 都持续存在。三个目的地没有各自的深层栈，也没有“切回标签后恢复到标签内第三层页面”的需求，普通 `ShellRoute` 已经够用。

详情 builder 先调用 `VenueUrlCodec`。匹配成功才构造 `VenueDetailPage`，参数非法则构造 `VenueLinkErrorPage`；完全未匹配地址由 `errorBuilder` 处理。

## URL codec 保持领域边界

地点 URL 采用：

```text
/venues/atrium?floor=2&tag=accessible
```

解析与 canonical 编码集中在一个无 UI 的 codec：

<<< ../../../examples/capstones/venue_guidebook/lib/src/venue_url_codec.dart#venue-url-codec{dart}

项目逐类拒绝未知地点、重复参数、未知参数、非整数楼层、不存在的楼层和不适用于当前地点的标签。默认楼层与空标签不写入 URL，因此：

```text
/venues/atrium?floor=1  → canonical: /venues/atrium
```

用户切换楼层或标签时，详情页创建新的 `VenueSelection`，交给 codec 编码，再 `context.go`。控件状态由解析后的 selection 构造，不另存一份可漂移的本地副本。

## 导航组件随约束替换

外壳从当前 URI 推导 `selectedIndex`，并在 900px 处替换导航容器：

<<< ../../../examples/capstones/venue_guidebook/lib/src/venue_shell.dart#responsive-navigation-shell{dart}

窄屏 Scaffold 提供 AppBar 和 Drawer，宽屏 body 改为 Rail 加 `Expanded(child: page)`。两支调用同一个 `_selectDestination`，目的地 path 不随布局变化。

900px 是项目用中英文导航标签、200% 文本和实际内容测出的断点，不是设备分类。详情内部还有第二个局部断点：

<<< ../../../examples/capstones/venue_guidebook/lib/src/venues_page.dart#responsive-detail-layout{dart}

980px 以上楼层图和房间列表按 6:4 并排，以下按相同阅读顺序上下排列。局部布局读取自己的 constraints，没有拿整个窗口宽度代替。

## 搜索状态留在地点页

`VenuesPage` 自己拥有 `TextEditingController`、`FocusNode`、query、floor 和 tag。它在 `initState` 注册搜索焦点，在 `dispose` 注销并释放资源。

搜索同时匹配中英文名称与摘要。这样用户切换语言后，原先输入的“材料”仍能找到 Materials Hall，不会因为显示语言变化突然得到空结果。真实产品是否跨语言搜索要由数据和检索合同决定；这里用固定小数据明确实现。

结果数量同时作为可见文字和 live region：

<<< ../../../examples/capstones/venue_guidebook/lib/src/venues_page.dart#result-live-region{dart}

`ExcludeSemantics` 防止同一结果数播报两次。无结果页面给出“查看全部地点”动作，清空 query、floor 和 tag 后把焦点送回搜索框。

## 快捷键有输入边界

外壳处理 `/` 和 Escape，但先确认事件是 KeyDown，并检查当前焦点是否位于 `EditableText`：

<<< ../../../examples/capstones/venue_guidebook/lib/src/venue_shell.dart#shell-keyboard-boundary{dart}

因此 `/` 在普通页面聚焦搜索；焦点已经在输入框时，它仍作为普通字符输入。Escape 只在 Drawer 打开时消费，否则交给更近的焦点作用域。

从“关于”页按 `/` 时，controller 先导航到 `/venues`，再等待地点页注册新的 FocusNode。这个跨路由焦点请求限制为三个 frame，避免无限重试：

<<< ../../../examples/capstones/venue_guidebook/lib/src/venue_guide_controller.dart#guide-controller{dart}

FocusNode 的所有权没有转移给 controller。controller 只保存当前注册引用，页面仍在 dispose 时释放它。

## 切换语言保持当前任务

`VenueGuidebookApp` 用 `AnimatedBuilder` 监听 controller，并把 `controller.locale` 传给 `MaterialApp.router`。生成的 `AppLocalizations.supportedLocales` 与 `localizationsDelegates` 提供中英文消息和 Material / Widgets 本地化。

本地数据不保存中文或英文标题，而保存 `VenueTextKey`。`VenueLocalizations` extension 把 key 映射到生成类的方法。路径仍使用 `atrium`、`materials-hall` 等稳定 ID。

语言按钮先保存 `FocusManager.instance.primaryFocus`，更新 locale 后在 post-frame callback 请求原焦点。Router 本身没有重建，path 与 query 保持不变。

Widget 测试同时核对 URL、搜索文本、英文结果和焦点：

<<< ../../../examples/capstones/venue_guidebook/test/venue_guidebook_app_test.dart#locale-preserves-task-test{dart}

项目的 ARB 还包含 `resultCount`、`routeStopCount` plural，`updatedOn` 日期 placeholder，以及地点名、楼层、标签和错误消息。开放时段目前是固定本地字符串；若将来接入真实时区数据，应先把业务值建模为时间，再在展示边界格式化。

## 楼层图和房间列表分工

`CustomPainter` 画楼层轮廓、房间块和路线。本章只使用它的绘制接口；重绘与渲染阶段留到[渲染流水线与自绘边界](/guide/part-07/05-rendering-pipeline)。图形外层只提供一条 `image` 语义摘要：

<<< ../../../examples/capstones/venue_guidebook/lib/src/venues_page.dart#floor-plan-semantics{dart}

图中没有隐藏点击区域。具体房间使用普通 `InkWell` 列表，每行有按钮角色、楼层名称和 selected 状态；选中后显示持续可见的黄绿色状态块，并由 live region 宣布。

这一分工保留了视觉概览，也让键盘和屏幕阅读器拥有完整操作入口。若把每个绘制矩形都做成自定义命中与语义节点，焦点顺序、缩放和触摸目标会复杂很多。

语义测试同时检查结果数、楼层图 image flag、摘要文字、房间操作和选择状态：

<<< ../../../examples/capstones/venue_guidebook/test/venue_guidebook_app_test.dart#semantics-contract-test{dart}

## 文本缩放、方向与减少动画

页面使用滚动容器、`Wrap`、可增高控件和局部断点。测试在 320×720 下把 `TextScaler` 设为 2，仍保留搜索和主要任务。

Padding 主要使用 `EdgeInsetsDirectional`，返回箭头根据 `Directionality` 选择方向；楼层 painter 在 RTL 测试壳中镜像几何。中文和英文仍是 LTR，测试只证明方向性 API 没有立刻破版。

楼层切换使用 260ms `AnimatedSwitcher`。`MediaQuery.disableAnimationsOf(context)` 为 true 时传 `Duration.zero`，图形直接到终态，房间文字和选中反馈继续显示。

## 测试矩阵覆盖不同失败方式

项目的单元测试、Widget 测试与 golden 测试共 18 项：

- codec 默认值、round-trip 和七类非法 URL；
- Drawer / Rail 切换和 Escape；
- 深链接恢复与 query 更新；
- 语言切换保持 URL、文本与焦点；
- `/` 跨页面聚焦和输入框边界；
- 结果数、楼层摘要、房间选择语义；
- 320×720、768×900、1440×900；
- 200% 文本、RTL 测试壳、减少动画；
- 两张确定性 golden。

响应式尺寸矩阵直接成为 Widget 测试：

<<< ../../../examples/capstones/venue_guidebook/test/venue_guidebook_app_test.dart#responsive-matrix-test{dart}

Golden 固定宽屏地点目录和 390×844 的紧凑详情：

<<< ../../../examples/capstones/venue_guidebook/test/venue_guidebook_app_test.dart#venue-golden-tests{dart}

Golden 能发现色块、间距、字体回退和布局变化，不证明交互正确。URL、焦点、语义和动画仍由各自测试承担。

Chrome 集成测试通过 `flutter drive` 完成搜索、进入中庭、切到二层、切换英文，并断言 URI 仍是 `/venues/atrium?floor=2`。Web release 产物另在真实浏览器补验直达、刷新、Back / Forward、语言切换和键盘输入边界。

## 运行与检查

项目路径：`examples/capstones/venue_guidebook`。

```powershell
cd examples/capstones/venue_guidebook
flutter gen-l10n
flutter analyze
flutter test
flutter run -d chrome
```

Chrome 集成测试需要 ChromeDriver 监听 4444 端口：

```powershell
flutter drive -d web-server --browser-name=chrome --driver=test_driver/integration_test.dart --target=integration_test/venue_guidebook_test.dart
```

GitHub Pages 预览构建：

```powershell
flutter build web --release --base-href /flutter-tutorial/previews/venue-guidebook/
```

部署后直接打开：

```text
/flutter-tutorial/previews/venue-guidebook/#/venues/atrium?floor=2&tag=accessible
```

刷新后切换语言，再使用 Back / Forward。随后只用键盘完成搜索、进入地点、选择房间和返回。

## 项目完成检查

- [ ] 三个顶层目的地共用普通 `ShellRoute`，没有多余独立栈。
- [ ] path、floor、tag 与 locale 各自只有一个事实来源。
- [ ] Drawer / Rail 替换不改变目的地、URL 或当前任务。
- [ ] `/` 不抢输入框，Escape 只处理合适的临时层。
- [ ] locale 切换保留 path、query、搜索文本与焦点。
- [ ] 楼层图有摘要，真实房间列表承担焦点、动作和 selected 状态。
- [ ] 320×720、768×900、1440×900、200% 文本、RTL 壳与减少动画都有证据。
- [ ] 两张 golden、Chrome 集成测试和 Web release 子路径构建均通过。

## 复习线索

- `ShellRoute` 保持共同导航，内部页面仍由 URL 匹配决定。
- 可分享状态写入 path / query；显示语言和页面局部输入分别管理。
- 响应式只替换布局与导航容器，不替换路由和任务。
- 自绘图给摘要，真实控件承担语义与操作。
- golden 测试、Widget 测试、Chrome 集成测试和人工浏览器检查各自覆盖不同风险。
- [项目源码](https://github.com/mardd123588/flutter-tutorial/tree/main/examples/capstones/venue_guidebook)

## 参考资料

- [Flutter navigation and routing](https://docs.flutter.dev/ui/navigation)（查阅：2026-08-30）
- [ShellRoute 18.0.0 API](https://pub.dev/documentation/go_router/18.0.0/go_router/ShellRoute-class.html)（查阅：2026-08-30）
- [Flutter URL strategies](https://docs.flutter.dev/ui/navigation/url-strategies)（查阅：2026-08-30）
- [Flutter adaptive and responsive design](https://docs.flutter.dev/ui/adaptive-responsive)（查阅：2026-08-30）
- [Flutter accessibility](https://docs.flutter.dev/ui/accessibility-and-internationalization/accessibility)（查阅：2026-08-30）
- [Flutter internationalization](https://docs.flutter.dev/ui/accessibility-and-internationalization/internationalization)（查阅：2026-08-30）
- [MediaQueryData.disableAnimations API](https://api.flutter.dev/flutter/widgets/MediaQueryData/disableAnimations.html)（查阅：2026-08-30）
- [Flutter Web integration tests](https://docs.flutter.dev/testing/integration-tests#test-in-a-web-browser)（查阅：2026-08-30）
- [Build and release a Flutter Web app](https://docs.flutter.dev/deployment/web)（查阅：2026-08-30）
