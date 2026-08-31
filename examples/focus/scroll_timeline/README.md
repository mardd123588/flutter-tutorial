# 长卷时间轴

第七部分的重点项目。它用一份 72 条记录的固定档案，集中验证 `Sliver` 懒构建、`CustomPainter` 滚动重绘、Riverpod 筛选、响应式目录、键盘焦点与性能采样。

项目不连接远程服务，也不随机生成数据。六个阶段、四类主题和每条事件的顺序都写在 `timeline_data.dart`，测试可直接断言数量与排序。

## 运行

```powershell
flutter run -d chrome
```

```powershell
flutter analyze
flutter test
```

更新两张确定性 golden：

```powershell
flutter test --update-goldens test/scroll_timeline_app_test.dart
```

构建教程站预览使用的子路径版本：

```powershell
flutter build web --release --base-href /flutter-tutorial/previews/scroll-timeline/
```

## Web 主流程与 profile

先启动与浏览器版本匹配的 ChromeDriver，再运行：

```powershell
chromedriver --port=4444
flutter drive -d chrome --driver test_driver/integration_test.dart --target integration_test/scroll_timeline_test.dart --profile
```

命令会把 `watchPerformance` 采到的帧数据写入 `build/integration_response_data.json`。这份数据用来比较同一机器上的改动，不设置跨机器通用的毫秒门槛。

## 验证范围

- Unit：fixture 数量、阶段关联、排序和主题筛选。
- Widget：懒构建、组合筛选、目录跳转与焦点、Semantics、320/768/1440 三档宽度、200% 文本和减少动画。
- Golden：1440×900 首屏、320×720 中段。
- Chrome：真实点击、长距离双向滚动和 profile 数据落盘。

所有人物、地点与档案均为教学用虚构数据。
