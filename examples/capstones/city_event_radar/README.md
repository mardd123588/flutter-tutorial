# 城市活动雷达

第四部分的统筹项目。页面把活动列表当作夜班调度任务：搜索和分区筛选决定当前信号，收藏写入 Drift；网络不可用时，界面明确显示正在使用新鲜缓存、过期缓存还是内置 fixture。

项目串起以下内容：

- 向 HTTP Service 注入 Client，并把外层 feed 容器与 `json_serializable` DTO 分开处理。
- 用防抖和 generation 处理搜索竞态。
- 用 `SharedPreferencesAsync` 保存分区与“只看收藏”偏好。
- 用 Drift 保存收藏、标签关系、完整 feed 缓存和缓存写入时间。
- 用事务完成收藏与标签写入，用查询 `Stream` 更新收藏状态。
- 演示 schema v1 到 v2 的迁移，并保留 Web 所需的 Wasm 与 Worker 资产。

## 运行

生成代码并执行测试：

```powershell
cd examples/capstones/city_event_radar
dart run build_runner build
flutter test test
flutter run -d chrome
```

Chrome 集成测试需要先在 4444 端口启动 ChromeDriver：

```powershell
flutter drive -d web-server --browser-name=chrome --driver=test_driver/integration_test.dart --target=integration_test/city_event_radar_test.dart
```

构建 Pages 预览：

```powershell
flutter build web --release --base-href /flutter-tutorial/previews/city-event-radar/
```

`web/sqlite3.wasm` 与 `web/drift_worker.js` 必须和当前 Drift 版本匹配。release 构建成功只说明资产进入产物；部署后仍要检查 Worker URL、Wasm URL 和 `application/wasm` MIME。

活动、场地、时间、价格和信号值都是教学 fixture。项目不请求远端服务，也不把固定数据写成真实城市信息。

扫描范围、活动信号、调度纸和数据值班簿都由 Flutter Widget 与 `CustomPainter` 绘制，没有外部图片或第三方字体资产。
