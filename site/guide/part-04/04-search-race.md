---
title: 防抖、竞态与即时书目检索
description: 用可控延迟证明防抖不等于取消，并让旧响应无法覆盖新查询。
part: 4
order: 4
kind: focus-project
requires:
  - input.text
  - async.stale-result
  - data.http-client
provides:
  - async.debounce
  - async.race
  - async.cancellation-boundary
project: instant-book-search
status: verified
---

# 防抖、竞态与即时书目检索

搜索框每敲一个字就发请求，会产生大量无意义查询。加上防抖以后，请求数量少了，但已经发出的旧请求仍可能晚到，并覆盖更新的结果。即时书目检索用固定延迟把这个错误稳定复现：`星` 用 850ms 返回，稍后输入的 `河` 只用 120ms。

## 防抖只阻止尚未开始的工作

防抖在每次输入时取消旧 Timer，再安排新 Timer：

```dart
void updateQuery(String value) {
  query = value.trim();
  debounceTimer?.cancel();
  if (query.isEmpty) {
    resetToIdle();
    return;
  }
  debounceTimer = Timer(delay, () => search(query));
}
```

取消 Timer 后，尚未触发的请求不会开始。若旧 Timer 已经触发，请求就进入另一个生命周期，继续取消 Timer 没有作用。

空查询要立即复位，不等防抖结束；页面同时清掉错误和结果。前后空格是否参与查询由产品合同决定，本项目统一 trim。

## 用 generation 阻止旧结果写回

项目给每个真正发出的请求递增编号：

<<< ../../../examples/focus/instant_book_search/lib/src/book_search_controller.dart#debounce-and-generation{dart}

关键判断是：

```dart
if (request != activeRequest || disposed) return;
```

新查询开始后，`activeRequest` 已经变化。旧响应可以完成，但只能被记录为“已忽略”，不能改写 results、error 或 settledQuery。

这条守卫同时保护成功和失败。否则旧请求晚到的 503 也可能把新查询的成功页面替换成错误页。

## 主动取消是另一项优化

`http 1.6.0` 提供 `AbortableRequest`，Web 的 Fetch 实现也能响应取消。主动取消可以节省带宽和解析工作，但不能替代 generation：

- 取消信号可能在响应完成后才到达；
- 某些 Client 不支持取消；
- 服务端可能已经处理请求；
- 页面仍需判断哪个结果属于当前参数。

本项目只实现 generation guard，把“正确性”与“节省工作”分开。读者可以在完成基础项目后增加 abort，但必须单独测试 `RequestAbortedException` 不会显示成普通网络失败。

## 项目简报

即时书目检索是一张编辑校样台。用户输入书名、作者或主题，页面在一侧显示书目校样，另一侧显示当前请求编号、已结算查询和被忽略的旧响应数。

必须满足：

- 输入停顿后才发请求，清空输入立即回到初始状态；
- 默认使用原创固定书目和本地 fixture，不访问真实服务；
- `星` 与 `河` 可以逆序完成，最终只显示 `河` 的结果；
- 覆盖初始、加载、空结果、成功、失败、重试和保留旧结果；
- Service 注入 Client，测试不访问网络；
- 320×720、200% 文本缩放、键盘和语义状态可用。

视觉采用“编辑校样请求台”：暖纸、蓝铅笔登记簿、朱红退回章和金色状态戳。它没有复刻官方 Album 或 Photos 示例，界面重点是请求到达顺序。

## 失败时不要清掉有用数据

新查询开始时，项目把 phase 改为 loading，但保留上一批 results。若刷新失败，错误区说明当前失败，旧书目仍留在下方。重试只重跑当前 query，不恢复已经过期的旧参数。

空结果则不同：它是一次成功响应，应该替换旧结果并显示“没有匹配项”。把空结果保留为旧数据，会让用户误以为当前查询找到了那些书。

## 测试要控制完成顺序

竞态测试不用真实等待 850ms。fake Service 为每个 query 保存一个 `Completer`，测试先完成新请求，再完成旧请求：

```dart
final oldSearch = controller.searchNow('星');
final newSearch = controller.searchNow('河');
service.complete('河', riverBooks);
await newSearch;
service.complete('星', starBooks);
await oldSearch;
```

最终断言 settledQuery、results 和 ignoredResponseCount。只断言“最后出现河流书目”不够，还要断言星图结果从未覆盖当前状态。

## 运行与检查

项目路径：`examples/focus/instant_book_search`。

```powershell
flutter analyze examples/focus/instant_book_search
flutter test examples/focus/instant_book_search/test
cd examples/focus/instant_book_search
flutter run -d chrome
```

release Web 构建：

```powershell
flutter build web --release --base-href /flutter-tutorial/previews/instant-book-search/
```

打开后先点击“运行竞态演示”，确认 `河` 的书目先出现；再等 `星` 请求结束，结果保持不变，“忽略的旧响应”增加到 1。输入“断线”后首次返回 503，点击重试应恢复。

## 项目完成检查

- [ ] 能说明防抖 Timer 只阻止尚未开始的请求。
- [ ] 成功与失败写回前都检查 request generation。
- [ ] 加载或刷新失败时保留可用旧结果；空结果会替换旧结果。
- [ ] timeout、generation 和主动取消三个边界没有混写。
- [ ] `MockClient` 覆盖成功、status、timeout 和坏 JSON。
- [ ] Unit、Widget、Chrome 关键流程和 release Web build 全部通过。

## 复习线索

- 防抖减少请求次数，generation 保证旧响应不写回。
- 主动取消优化资源使用，不能替代结果身份检查。
- 空结果是成功；刷新失败可以继续展示带时间和来源的旧数据。
- [项目源码](https://github.com/mardd123588/flutter-tutorial/tree/main/examples/focus/instant_book_search)

## 参考资料

- [Timer.cancel API](https://api.dart.dev/dart-async/Timer/cancel.html)（查阅：2026-08-30）
- [Future.timeout API](https://api.dart.dev/dart-async/Future/timeout.html)（查阅：2026-08-30）
- [AbortableRequest 1.6.0 API](https://pub.dev/documentation/http/1.6.0/http/AbortableRequest-class.html)（查阅：2026-08-30）
- [RequestAbortedException 1.6.0 API](https://pub.dev/documentation/http/1.6.0/http/RequestAbortedException-class.html)（查阅：2026-08-30）
- [WidgetTester.pump API](https://api.flutter.dev/flutter/flutter_test/WidgetTester/pump.html)（查阅：2026-08-30）
