# Web 集成测试使用 web-server 与 ChromeDriver

浏览器关键流程通过 Flutter `integration_test`、`flutter drive -d web-server` 和与 Chrome 主版本匹配的 ChromeDriver 运行。当前环境中 `flutter test -d chrome` 不支持 Web integration test，`flutter drive -d chrome` 连接后挂起；独立 WebDriver 路径已完成同一测试，因此本地与 CI 都不依赖直接 Chrome 设备。
