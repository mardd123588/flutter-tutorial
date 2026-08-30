# 场馆导览册

第五部分的统筹项目。它把 `ShellRoute`、深链接、响应式导航、中英文、键盘操作、Semantics 与 golden 测试放进同一个 Flutter Web 应用。

应用提供“地点”“路线”“关于”三个顶层目的地。宽度达到 900px 时使用 `NavigationRail`，较窄时改用 `NavigationDrawer`，路由结构保持不变。地点详情使用 `/venues/:venueId`，楼层和标签写入 query，例如：

```text
#/venues/atrium?floor=2&tag=accessible
```

切换语言只更新界面文案，不修改 path、query、当前地点或搜索焦点。按 `/` 可从任意顶层页面聚焦地点搜索；焦点已在输入框内时，`/` 仍是普通输入。Escape 用来关闭抽屉等临时层。

楼层图由 `CustomPainter` 绘制，只向辅助技术提供一条摘要。房间的选择和反馈由可聚焦列表与 live region 承担，图形本身没有隐藏操作。

## 运行

```powershell
cd examples/capstones/venue_guidebook
flutter gen-l10n
flutter run -d chrome
```

执行静态检查、Unit、Widget 与 golden 测试：

```powershell
flutter analyze
flutter test
```

Chrome 集成测试需要先在 4444 端口启动 ChromeDriver：

```powershell
flutter drive -d web-server --browser-name=chrome --driver=test_driver/integration_test.dart --target=integration_test/venue_guidebook_test.dart
```

构建 GitHub Pages 预览：

```powershell
flutter build web --release --base-href /flutter-tutorial/previews/venue-guidebook/
```

测试覆盖 320×720、768×900、1440×900、200% 文本、RTL 测试壳、减少动画、URL 错误分支和两张确定性 golden。RTL 只用于检查方向性布局，不表示项目已经提供阿拉伯语等 RTL 语言。

场馆、开放时段、房间和路线都是本地教学数据。项目不使用地图、定位、网络、数据库、账号或推送，也不与其他示例共享业务模型和 UI 组件。
