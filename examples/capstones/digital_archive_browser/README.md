# 数字档案浏览器

第七部分的统筹项目。它把固定 fixture、Riverpod 对象图、hash URL、响应式筛选、mixed sliver、`CustomPainter` 缩略图、三项对照和 Web profile 放进同一个 Flutter 应用。

## 运行与检查

```powershell
flutter run -d chrome
flutter analyze
flutter test
```

发布预览使用独立子路径，hash route 由 Flutter Web 默认 URL 策略保留：

```powershell
flutter build web --release --base-href /flutter-tutorial/previews/digital-archive-browser/
```

## Chrome 主流程与 profile

先启动与 Chrome 版本匹配的 ChromeDriver：

```powershell
chromedriver --port=4444
flutter drive -d chrome --driver test_driver/integration_test.dart --target integration_test/digital_archive_browser_test.dart --profile
```

测试会执行固定 workload：浏览 120 条结果、连续滚动三段、切换网格、输入查询、打开详情并返回，再加入三条记录。帧数据写入 `build/integration_response_data.json` 的 `archive_journey` 键。

## 测试边界

- Unit：URL 归一化、筛选、排序、fixture 维度与对照上限。
- Provider：Repository override 和 family 参数隔离。
- Widget/Semantics：loading、error、retry、empty、URL 同步、lazy materialization、非法详情、live region、焦点和恢复动作。
- Responsive：320×720、768×900、1440×900、200% 文本、RTL 测试壳与减少动画。
- Visual：`not-applicable`，不维护 golden；仍需真实 Chrome 的三档截图检查。

所有人物、地点与档案均为教学用虚构数据。
