# Flutter Web 主栈探针结果

> 验证日期：2026-08-29  
> 环境：Flutter 3.47.0、Dart 3.13.0、Chrome 151.0.7922.174、Windows 10  
> 探针位置：`.scratch/stack_probe`，不属于正式示例项目

## 验证问题

这次探针只回答三件事：`flutter_riverpod 3.4.2` 能否进入 Flutter Web 构建，`go_router 18.0.0` 在 GitHub Pages 子路径下采用什么 URL 方式，以及 Drift 2.34.3 的 Web 资产和持久化能否工作。

## 通过项

- `flutter analyze` 通过。
- 使用内存 Drift 数据库的 Widget 测试通过。测试覆盖 Riverpod provider override、查询流更新和显式释放组件树。
- `flutter build web --release --base-href /flutter-tutorial/` 通过。构建包含 `flutter_riverpod 3.4.2`、`go_router 18.0.0`、`drift 2.34.3` 与 `drift_flutter 0.3.1`。
- release 产物能从 `/flutter-tutorial/` 加载。`sqlite3.wasm` 返回 `Content-Type: application/wasm`，`drift_worker.js` 正常加载。
- Drift 能写入数据，刷新后仍能读到；第二个同源标签页能读写同一数据库，第一个标签页刷新后能看到新数据。
- 当前浏览器缺少 SharedArrayBuffer 和部分 Worker 能力时，Drift 自动选择 `WasmStorageImplementation.sharedIndexedDb`。探针没有把这种回退当成错误。
- go_router 的 hash URL `#/details` 在仓库子路径下支持刷新、浏览器后退和前进。
- 启动 ChromeDriver 151.0.7922.138 后，`flutter drive --driver=test_driver/integration_test.dart --target=integration_test/stack_probe_web_test.dart -d web-server --browser-name=chrome --web-port=18081` 通过，输出 `All tests passed.`。这条测试覆盖真实 Drift Web 数据库、Riverpod 更新和 go_router 页面切换。

## 发现的边界

- 普通静态服务器访问 `/flutter-tutorial/details` 返回 404，`/flutter-tutorial/#/details` 正常。GitHub Pages 首版应使用 hash URL；如果以后改为 path URL，需要单独实现并测试 404 回退或重写规则。
- `flutter test integration_test/stack_probe_web_test.dart -d chrome` 直接返回 `Web devices are not supported for integration tests yet.`。
- `flutter drive --driver=test_driver/integration_test.dart --target=integration_test/stack_probe_web_test.dart -d chrome` 能启动 Chrome 并连接调试服务，但在当前环境中没有完成测试。正式验收改用 `web-server` 设备和独立 ChromeDriver，不使用直接 Chrome 设备。
- Widget 测试释放 Riverpod 管理的 Drift 查询流时，需要先卸载组件树并推进一次测试时间，否则 Drift 的零时长关闭计时器会触发 pending timer 断言。
- 本次没有验证隐私模式关闭后的持久化。浏览器私密存储本来就可能在会话结束后清除，正式项目需要把它写成平台边界，不承诺跨私密会话保存。

## 对选型的影响

- `flutter_riverpod` 的 pub.dev Web 标签缺失没有反映成安装、分析、Widget 测试或 release Web 构建问题，可以继续作为状态管理主方案。
- `go_router` 可以作为主路由方案，但 GitHub Pages 首版固定使用 hash URL。
- Drift 可以用于需要关系查询和迁移的项目。项目必须携带匹配版本的 `sqlite3.wasm` 与 `drift_worker.js`，并测试浏览器能力回退。
- Chrome 关键流程使用 Flutter `integration_test`、`flutter drive -d web-server` 和与 Chrome 主版本匹配的 ChromeDriver。CI 需要固定驱动获取方式与端口，不能依赖 `flutter drive -d chrome`。
