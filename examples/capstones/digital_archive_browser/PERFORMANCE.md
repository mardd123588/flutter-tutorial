# Profile 证据

固定 workload 为“120 条全部结果 → 连续滚动三段 → 切换 grid → 输入查询 → 打开详情 → Back”。自动测试同时断言 lazy 结果不会一次 materialize 120 项，不把普通 CI 的绝对毫秒数当作通用门槛。

## 复现条件

- 模式：Flutter Web profile
- 设备：Chrome
- 入口：`integration_test/digital_archive_browser_test.dart`
- 报告键：`archive_journey`
- 原始输出：`build/integration_response_data.json`

## 2026-08-31 基线

- Flutter 3.47.0、Dart 3.13.0、Chrome / ChromeDriver 151.0.7922.174，JavaScript 默认 CanvasKit 基线。
- 165 帧；build p90 5.801ms、p99 33.5ms；raster p90 3.801ms、p99 9.5ms。
- build 有 4 帧、raster 有 2 帧超过框架预算。workload 同时包含路由与视图切换，不能把这些离群值直接归因于缩略图绘制。
- 可审阅摘要见 `performance/profile-summary.json`；完整逐帧数组由复现命令重新生成。

若要调整 `RepaintBoundary` 或 delegate 结构，应在同一机器、同一 workload 下保留前后 JSON 与 Chrome trace，再判断变化是否成立。
