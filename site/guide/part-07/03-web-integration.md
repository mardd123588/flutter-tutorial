---
title: Web 浏览器关键流程
description: 用 integration_test、ChromeDriver 和发布路径验证 URL、浏览器历史、刷新、真实资产与失败证据。
part: 7
order: 3
kind: concept
requires:
  - test.widget
  - navigation.go-router
provides:
  - test.integration-web
  - test.webdriver
  - test.failure-artifact
status: verified
---

# Web 浏览器关键流程

Widget 测试能驱动完整 Widget 生命周期，却没有真实地址栏、浏览器历史和发布服务器。`flutter build web` 只证明代码可以产生产物，也不证明用户能刷新深链接、加载 Wasm 或使用 Back / Forward。Web 关键流程要在真实 Chrome 中运行。

## 三类证据不要互相冒充

| 检查 | 能证明 | 不能证明 |
| --- | --- | --- |
| Widget test | Widget 生命周期、输入、焦点、Semantics、布局分支 | 地址栏、浏览器历史、发布资产 |
| release Web build | release 编译、tree shaking、静态产物生成 | 页面能正确交互、刷新和恢复 |
| Chrome integration | 真实浏览器中的主旅程、URL、资产和输入边界 | 所有纯规则分支、像素稳定性 |

一条 Chrome 流程应覆盖最重要的用户旅程，例如“打开列表 → 改筛选 → 打开详情 → Back → 刷新后恢复”。排序 tie-breaker、非法参数全集和每个空状态仍放在更便宜的测试层。

## Web 使用 ChromeDriver

本仓库使用 Flutter `integration_test`、`flutter drive -d web-server` 和 ChromeDriver。ChromeDriver 主版本要和本机 Chrome 匹配，并放在 `PATH` 中。

先启动 driver：

```bash
chromedriver --port=4444
```

再从项目目录运行：

```bash
flutter drive \
  --driver=test_driver/integration_test.dart \
  --target=integration_test/app_test.dart \
  -d web-server \
  --browser-name=chrome \
  --profile
```

PowerShell 可以把续行符换成反引号，或写成一行。端口被占用、Chrome 与 ChromeDriver 主版本不一致、driver 不在 `PATH`，都会在 Flutter 测试进入应用之前失败。

`-d web-server` 让 Flutter 启动 Web 服务，由 WebDriver 打开页面。它与 `flutter test -d chrome` 不是同一条路径；当前 Flutter 环境的 Web integration test 以 WebDriver 方案为准。

## Integration test 只保留关键旅程

测试仍使用熟悉的 `testWidgets` API：

```dart
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('restores a shared archive route', (tester) async {
    await tester.pumpWidget(const ArchiveApp());
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const ValueKey('search')), '河岸');
    await tester.testTextInput.receiveAction(TextInputAction.search);
    await tester.pumpAndSettle();

    expect(find.textContaining('河岸'), findsWidgets);
  });
}
```

这段 API 看起来像 Widget test，执行环境却是完整应用和真实浏览器。项目若要断言地址栏，应读取 Router 的 `RouteInformationProvider`，并在人工或浏览器自动化步骤中补查刷新、新标签与 Back / Forward；不要把组件内部字符串当作地址栏证据。

## URL 流程要覆盖恢复

一条可分享路线至少检查：

1. 初始 URL 能直达正确页面；
2. 改筛选后 URL 跟着更新；
3. Back / Forward 恢复页面状态；
4. 刷新不回到默认状态；
5. 复制到新标签仍能恢复；
6. release base href 下资产和路线都能加载。

Hash URL 可以绕开 GitHub Pages 的服务器回退限制，但应用内部仍要规范化非法或重复参数。URL 是状态来源时，Widget 不应再维护第二份可写筛选值。

## 发布路径是流程的一部分

本教程站点发布在 `/flutter-tutorial/`。独立项目必须用自己的子路径构建：

```bash
flutter build web --release --base-href /flutter-tutorial/previews/example-app/
```

检查生成的 `index.html`、脚本、字体、Wasm、Worker 和资源路径。开发服务器根路径能运行，不代表 GitHub Pages 子路径也正确。

## 失败时保留最小证据包

Integration 失败后，先留下能复现的材料：

- 完整命令与退出码；
- Flutter、Chrome、ChromeDriver 版本；
- 当前 URL 与最后一个成功 checkpoint；
- 浏览器控制台日志；
- 页面截图；
- 固定 fixture 和窗口尺寸；
- 测试名称、随机种子或输入序列；
- 服务端与 driver 端口。

不要先把测试改成重试三次。重试可能把竞态变成偶发通过，也可能覆盖真实资产缺失。只有外部环境明确不稳定、行为本身仍有独立断言时，才讨论有限重试。

## WebDriver 的边界

Flutter integration test 不能操作浏览器之外的系统权限弹窗、原生通知和部分 platform view。需要这些能力时，要换专门工具或人工验收。测试也不应该访问真实账号和不稳定网络；本仓库使用本地 fixture，避免外部服务把关键流程变成网络健康检查。

## 可验证任务

为一个带 hash URL 的档案列表设计一条 Chrome 关键流程，写出测试步骤和发布命令。流程必须覆盖筛选、详情、Back、刷新和 release 子路径；排序规则、空结果与非法参数分别说明应该落在哪个更低层测试中。

故意把 `--base-href` 改错一次，记录失败 URL、控制台错误和截图，再恢复配置。不要用“页面打不开”作为唯一失败描述。

## 复习线索

- Widget test、release build、Chrome integration 证明的是三件不同的事。
- Integration 只覆盖关键旅程，不复制 unit / widget 的分支矩阵。
- ChromeDriver 主版本必须匹配 Chrome。
- URL 流程要验证直达、更新、历史、刷新、新标签和发布子路径。
- 失败证据至少包含命令、版本、URL、日志、截图和 fixture。

## 参考资料

- [Check app functionality with an integration test](https://docs.flutter.dev/testing/integration-tests)（查阅：2026-08-31）
- [Flutter build modes](https://docs.flutter.dev/testing/build-modes)（查阅：2026-08-31）
- [Flutter Web deployment](https://docs.flutter.dev/deployment/web)（查阅：2026-08-31）
- [ChromeDriver downloads and version selection](https://developer.chrome.com/docs/chromedriver/downloads/version-selection)（查阅：2026-08-31）

