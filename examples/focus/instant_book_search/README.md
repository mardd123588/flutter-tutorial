# 即时书目检索

第四部分的请求竞态重点项目。读者可以输入书名、作者或主题，也可以直接运行“慢请求后发、快请求先回”的演示。页面保留最新查询的结果，并在请求登记簿中显示当前编号、已结算编号和被忽略的旧响应数。

项目用于练习以下边界：

- 向 Service 注入 `http.Client`，用固定 fixture 复现成功、空结果、状态码错误、解析错误和超时。
- 防抖只取消尚未触发的 `Timer`。
- generation 让旧响应失效，不把 `Future.timeout` 解释成底层请求已取消。
- 新请求失败或加载时保留仍有用的旧结果。
- 手写 JSON 映射忽略未知字段，并对缺失或类型错误给出可定位的异常。

## 运行

```powershell
flutter test examples/focus/instant_book_search/test
cd examples/focus/instant_book_search
flutter run -d chrome
```

Chrome 集成测试需要先在 4444 端口启动 ChromeDriver：

```powershell
flutter drive -d web-server --browser-name=chrome --driver=test_driver/integration_test.dart --target=integration_test/instant_book_search_test.dart
```

构建 Pages 预览：

```powershell
flutter build web --release --base-href /flutter-tutorial/previews/instant-book-search/
```

项目不会访问真实图书服务。书目、延迟和错误响应都固定在 `FixtureBookClient` 中，测试与截图可以重复得到同一结果。

暖色校样纸、蓝铅笔登记簿、朱红校对标记和网格底板都由 Flutter Widget 与 `CustomPainter` 绘制，没有外部图片或第三方字体资产。
