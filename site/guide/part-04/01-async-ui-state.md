---
title: 把 Future 与 Stream 变成界面状态
description: 从一次结果、持续事件和 AsyncSnapshot 建立可恢复的异步界面状态。
part: 4
order: 1
kind: concept
requires:
  - state.ownership
  - state.lifecycle
provides:
  - async.ui-state
  - async.future-builder
  - async.stream-builder
  - async.stale-result
status: verified
---

# 把 Future 与 Stream 变成界面状态

`Future` 表示一次尚未完成的结果，`Stream` 表示一段时间内的多次事件。它们解决的是异步计算合同；加载、空数据、重试和保留旧结果则是界面合同。先把两层分开，后面接 HTTP、缓存和数据库时才不会把所有状态压成一个 `isLoading`。

## Future 只完成一次

`Future<T>` 最终得到一个 `T` 或一个错误，并且只完成一次。`await` 暂停当前 async 函数，不会阻塞浏览器主线程；它也不会把同步 JSON 解析自动搬到其他 isolate。

```dart
Future<Profile> loadProfile() async {
  try {
    return await source.fetchProfile();
  } finally {
    source.releaseTemporaryHandle();
  }
}
```

连续写两个 `await` 表示顺序执行。两个任务互不依赖时，先创建 Future，再用 `Future.wait` 聚合。无论是否设置 `eagerError`，`Future.wait` 都不会替你取消其他任务。

`.timeout(...)` 也不是取消。它返回一个新的 Future，在期限到达后停止等待原结果；底层工作仍可能继续。后面处理搜索竞态时，我们会把“停止等待”“忽略旧结果”“停止底层请求”分成三件事。

## Stream 可以继续产生事件

Stream 可以发出多次 data 和 error，最后至多一个 done。error 事件不一定结束 Stream；数据库查询在一次错误之后能否继续，要看数据源合同。

single-subscription stream 的整个生命周期只允许一个监听者。broadcast stream 允许多个监听者，但没有监听者时不会保存事件，因此 `asBroadcastStream()` 不是“记住最后一个值”的缓存。

拥有订阅的 State 负责取消：

```dart
late final StreamSubscription<Reading> subscription;

@override
void initState() {
  super.initState();
  subscription = readings.listen(handleReading);
}

@override
void dispose() {
  subscription.cancel();
  super.dispose();
}
```

一次 HTTP 响应用 Future；持续变化的数据库查询、WebSocket 消息或传感数据才适合 Stream。Stream 不是更强的 Future。

## Builder 不负责创建任务

`FutureBuilder.future` 和 `StreamBuilder.stream` 都要在 `build` 之前取得。若在 `build` 中现场调用 `load()`，父级每次重建都可能得到新 Future，任务也随之重启。

```dart
late Future<List<Item>> _request;

@override
void initState() {
  super.initState();
  _request = widget.source.load();
}

void retry() {
  setState(() => _request = widget.source.load());
}
```

Builder 只会看到按时间排列的快照子序列，中间帧可能被 Flutter pipeline 合并。不要在 builder 里计数、导航或写数据库。一个已经完成但身份不同的新 Future，也可能先产生一帧 `ConnectionState.waiting`。

`AsyncSnapshot.hasData == false` 不能直接翻译成“正在加载”。成功完成的 `Future<void>` 或合法的 null 结果也没有 data。判断顺序应从 `connectionState`、`hasError` 和任务自己的空值语义出发。

## 页面状态比 AsyncSnapshot 更具体

同一个 Future 快照无法表达“旧数据仍可用”。页面至少需要区分：

| 状态 | 当前数据 | 页面行为 |
| --- | --- | --- |
| 首次加载 | 无 | 保留标题和退出路径，显示进度 |
| 空结果 | 成功但集合为空 | 说明没有匹配项，允许清空条件 |
| 成功 | 有 | 显示当前数据 |
| 后台刷新 | 有旧数据 | 保留内容，局部提示刷新中 |
| 首次失败 | 无 | 说明失败与恢复动作 |
| 刷新失败 | 有旧数据 | 保留内容，显示错误与旧数据时间 |

这张表不是 Flutter 固定枚举，而是任务状态。`AsyncSnapshot` 负责连接合同，页面状态负责用户下一步能做什么。

## 旧结果要有明确身份

更换 Future 时，`FutureBuilder` 可以短暂保留旧快照；框架也会忽略旧 Future 后续触发的 builder 回调。但这不代表任意 controller 都自动安全。自己管理异步请求时，需要记录哪次请求仍然有效：

```dart
final request = ++issuedRequest;
final result = await source.load();
if (request != activeRequest || !mounted) return;
setState(() => items = result);
```

请求编号没有取消底层工作，只阻止旧结果写回当前状态。它是后续搜索与刷新流程的最低安全线。

## 可验证任务

用一个内存数据源分别提供 `Future<List<String>> loadOnce()` 与 `Stream<List<String>> watch()`：

1. Future 页面覆盖首次加载、空数据、成功和失败。
2. 重试时保留旧列表，并单独显示刷新状态。
3. Stream 页面处理 data、error 和 done；error 后再发一条 data，确认页面能恢复。
4. 父级重建时不创建新 Future 或 Stream。
5. 用 `Completer` 让两次 Future 逆序完成，断言旧结果不写回。

## 复习线索

- Future 只完成一次；Stream 可以产生多次 data、error，最后结束。
- timeout 限制等待时间，不取消原任务。
- Builder 接收已取得的 Future 或 Stream，不在 `build` 中创建任务。
- AsyncSnapshot 描述连接；空数据、旧数据和重试属于页面状态。

## 参考资料

- [Asynchronous programming: futures, async, await](https://dart.dev/libraries/async/async-await)（查阅：2026-08-30）
- [Future.timeout API](https://api.dart.dev/dart-async/Future/timeout.html)（查阅：2026-08-30）
- [Stream API](https://api.dart.dev/dart-async/Stream-class.html)（查阅：2026-08-30）
- [FutureBuilder API](https://api.flutter.dev/flutter/widgets/FutureBuilder-class.html)（查阅：2026-08-30）
- [StreamBuilder API](https://api.flutter.dev/flutter/widgets/StreamBuilder-class.html)（查阅：2026-08-30）
- [AsyncSnapshot API](https://api.flutter.dev/flutter/widgets/AsyncSnapshot-class.html)（查阅：2026-08-30）
