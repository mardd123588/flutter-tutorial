# Profile 证据

性能测试覆盖一次主题筛选，以及长卷向下、向上各八次快速滚动。`ScrollController` 直接作为 `TimelineProgressPainter` 的 `repaint`，所以进度线更新不经过页面级 `setState`；事件由 `SliverList.builder` 按需创建。

## 复现条件

- 模式：Flutter Web profile
- 设备：Chrome
- 入口：`integration_test/scroll_timeline_test.dart`
- 报告键：`long_scroll`
- 原始输出：`build/integration_response_data.json`

## 2026-08-31 基线

- Flutter 3.47.0、Dart 3.13.0、Chrome / ChromeDriver 151.0.7922.174。
- 595 帧；build p90 1.199ms、p99 3.301ms；raster p90 1.5ms、p99 3.301ms。
- build 与 raster 各有 1 帧超过框架预算。单次最差值可能包含浏览器或采样抖动，不据此添加 `RepaintBoundary`。
- 可审阅摘要见 `performance/profile-summary.json`；完整逐帧数组由复现命令重新生成。

跨机器的帧耗时不可直接比较。本项目保留复现命令、环境摘要与同环境回归方法，不把这组数字写成 CI 门槛。
