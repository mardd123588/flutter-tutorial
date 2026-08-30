# 第四部分官方资料研究：异步、网络与本地数据

> 查阅日期：2026-08-30
> 教程基线：Flutter 3.47.0、Dart 3.13.0
> 依赖基线：`http 1.6.0`、`json_serializable 6.14.1`、`json_annotation 4.12.0`、`shared_preferences 2.5.5`、`drift 2.34.3`、`drift_flutter 0.3.1`
> 资料范围：Dart / Flutter 官方文档与源码、pub.dev 包文档与官方仓库、HTTP 与 Fetch 规范

这份笔记只确定第四部分的知识边界、章节依赖和项目验收方式，不直接充当教程正文。下文把 SDK、包和协议规定写成“官方事实”，把状态类型、缓存策略和项目拆分写成“课程建议”。

## 1. 版本基线与最容易误教的变化

- 本机基线为 Flutter 3.47.0、Dart 3.13.0。涉及 `FutureBuilder`、`StreamBuilder` 和 `AsyncSnapshot` 的结论以 Flutter `3.47.0` 标签源码为准；Dart 异步合同以 Dart 3.13.0 API 与 SDK 源码为准。[Flutter 3.47.0 release notes](https://docs.flutter.dev/release/release-notes/release-notes-3.47.0) · [Flutter async.dart 3.47.0](https://github.com/flutter/flutter/blob/3.47.0/packages/flutter/lib/src/widgets/async.dart) · [Dart SDK 3.13.0](https://github.com/dart-lang/sdk/releases/tag/3.13.0)（查阅：2026-08-30）
- `http 1.6.0` 的 Web 默认实现是基于 Fetch API 的 `BrowserClient`。从 `http 1.5.0` 起包内提供 `AbortableRequest`，1.6.0 又修复了 Web 响应体等待下一块数据时的取消问题。旧教程里“Web 只能用 `XMLHttpRequest`”“`package:http` 没有请求取消能力”的说法已经过时。[http 1.6.0 changelog](https://pub.dev/packages/http/versions/1.6.0/changelog) · [BrowserClient 1.6.0](https://pub.dev/documentation/http/1.6.0/browser_client/BrowserClient-class.html) · [AbortableRequest 1.6.0](https://pub.dev/documentation/http/1.6.0/http/AbortableRequest-class.html)（查阅：2026-08-30）
- `http 1.4.0` 起，`application/json` 未声明 charset 时，`Response.body` 默认按 UTF-8 解码；1.6.0 又调整了 `Request.body` 自动添加 charset 的范围，只为文本和 XML media type 添加。教程不应沿用“JSON 默认按 latin1 解码”或“设置 JSON body 后一定自动补 `charset=utf-8`”的旧结论。[http 1.6.0 changelog](https://pub.dev/packages/http/versions/1.6.0/changelog) · [Response 1.6.0](https://pub.dev/documentation/http/1.6.0/http/Response-class.html)（查阅：2026-08-30）
- `json_serializable 6.14.1` 要求 Dart `^3.9.0`，能在 Dart 3.13.0 使用；配套 annotation 范围是 `json_annotation >=4.12.0 <4.13.0`。6.14 新增的 PATCH 三态字段与 6.12 新增的 JSON Schema 生成不属于本部分必需内容，不能因为示例 README 出现 `createJsonSchema: true` 就默认带入所有 DTO。[json_serializable 6.14.1 metadata](https://pub.dev/api/packages/json_serializable) · [json_serializable 6.14.1 changelog](https://pub.dev/packages/json_serializable/versions/6.14.1/changelog) · [json_serializable 6.14.1 README](https://github.com/google/json_serializable.dart/blob/json_serializable-v6.14.1/json_serializable/README.md)（查阅：2026-08-30）
- Drift 2.32 已切换到 `sqlite3` 3.x，Web 项目必须同步更新 `sqlite3.wasm`；2.34.2 会在语句执行后 flush IndexedDB 写入，2.34.3 又在 OPFS 访问外层使用 navigator locks。第四部分固定下载 Drift 2.34.3 同一 release 的 `sqlite3.wasm` 与 `drift_worker.js`，不复用旧教程或旧项目里的 Wasm 文件。[Drift 2.34.3 changelog](https://pub.dev/packages/drift/versions/2.34.3/changelog) · [Drift 2.34.3 release assets](https://github.com/simolus3/drift/releases/tag/drift-2.34.3)（查阅：2026-08-30）
- `drift_flutter 0.3.1` 的 `driftDatabase()` 返回值已从较宽泛的 `QueryExecutor` 改为 `DatabaseConnection`。数据库类仍应保留接收执行器或连接的测试构造函数，但正文类型说明要按 0.3.1 更新。[drift_flutter 0.3.1 changelog](https://pub.dev/packages/drift_flutter/versions/0.3.1/changelog) · [driftDatabase 0.3.1](https://pub.dev/documentation/drift_flutter/0.3.1/drift_flutter/driftDatabase.html)（查阅：2026-08-30）
- `shared_preferences 2.3.0` 起有三套 API，旧 `SharedPreferences` 已被标为未来弃用。新项目应在 `SharedPreferencesAsync` 与 `SharedPreferencesWithCache` 中选择；本部分只保存少量筛选偏好，默认使用不带本地缓存的 `SharedPreferencesAsync`。[shared_preferences 2.5.5 README](https://pub.dev/packages/shared_preferences/versions/2.5.5)（查阅：2026-08-30）

## 2. `Future`、`async` 与 `await`

### 2.1 一个 Future 只有一次完成结果

- `Future<T>` 表示稍后得到一个 `T` 或一个错误，最多完成一次。`async` 函数返回 Future；`await` 只暂停当前异步函数，不阻塞浏览器主线程，也不会把底层 I/O 变成同步调用。[Asynchronous programming: futures, async, await](https://dart.dev/libraries/async/async-await) · [Future API](https://api.dart.dev/dart-async/Future-class.html)（查阅：2026-08-30）
- `async` / `await` 不会自动把同步计算搬到另一个 isolate。大体量 JSON 解析或同步循环仍会占用当前 isolate；本部分使用小型 payload，把 isolate 与 Web Worker 的计算拆分留到性能专题。[Dart concurrency](https://dart.dev/language/concurrency)（查阅：2026-08-30）
- `try` / `catch` / `finally` 可以直接包住 `await`；`finally` 仍用于释放本次调用拥有的资源。错误若未被捕获，会让 async 函数返回的 Future 以错误完成。正文优先使用这套控制流，再把 `then` / `catchError` 作为阅读已有代码所需知识。[Futures and error handling](https://dart.dev/libraries/async/futures-error-handling) · [Dart async language](https://dart.dev/language/async)（查阅：2026-08-30）
- 连续写两个 `await` 会按顺序等待；需要并发时，应先创建彼此独立的 Future，再用 `Future.wait` 聚合。`Future.wait` 默认等所有 Future 结束后报告第一个错误，`eagerError: true` 会更早报告，但都没有取消其他 Future 的合同。[Future.wait API](https://api.dart.dev/dart-async/Future/wait.html) · [future.dart 3.13.0](https://github.com/dart-lang/sdk/blob/3.13.0/sdk/lib/async/future.dart#L468-L611)（查阅：2026-08-30）
- `unawaited(future)` 只表达“有意不等待”并压住 lint，不处理 Future 的错误，也不会让工作取消。若任务可能失败，仍要在任务内部或返回的 Future 上处理错误。[unawaited API](https://api.dart.dev/dart-async/unawaited.html) · [future.dart 3.13.0](https://github.com/dart-lang/sdk/blob/3.13.0/sdk/lib/async/future.dart#L1021-L1059)（查阅：2026-08-30）

### 2.2 超时不是取消

- `Future.timeout` 返回一个新的 Future。超时后它以 `TimeoutException` 或 `onTimeout` 的结果完成，原 Future 仍可继续执行；原 Future 之后产生的值或错误会被 timeout 返回值忽略。把 `.timeout(...)` 写在 HTTP 调用外层只能限制调用方等待多久，不能证明浏览器请求已停止。[Future.timeout API](https://api.dart.dev/dart-async/Future/timeout.html) · [future.dart 3.13.0](https://github.com/dart-lang/sdk/blob/3.13.0/sdk/lib/async/future.dart#L942-L1018)（查阅：2026-08-30）
- Dart 的普通 `Future` 没有通用 `cancel()`。能否停止底层工作取决于产生 Future 的 API：timer 可取消，Stream 订阅可取消，`package:http` 的部分 Client 可处理 `AbortableRequest`。课程必须把“停止等待”“忽略旧结果”“停止底层工作”写成三件事。[Timer.cancel API](https://api.dart.dev/dart-async/Timer/cancel.html) · [StreamSubscription.cancel API](https://api.dart.dev/dart-async/StreamSubscription/cancel.html) · [Abortable API 1.6.0](https://pub.dev/documentation/http/1.6.0/http/Abortable-class.html)（查阅：2026-08-30）

### 2.3 本部分只补 Flutter 需要的 Dart

04-01 需要复习 Future 的值 / 错误、`async` / `await`、`try` / `catch` / `finally` 和独立任务的并发。Completer、Zone、microtask 排序、`FutureOr` 泛型设计和 isolate 属于按需入口，不在本部分展开。防抖只需要 `Timer`，测试竞态只需要 `Completer` 的最短说明。

## 3. `Stream` 与订阅生命周期

### 3.1 Stream 有数据、错误和结束三类事件

- Stream 可以产生任意数量的数据事件和错误事件，最后至多一个 done 事件。错误事件不一定终止 Stream；是否继续取决于数据源和监听方式。`await for` 遇到未处理错误会重新抛出并退出循环，手工 `listen` 可分别处理 `onData`、`onError` 和 `onDone`。[Stream API](https://api.dart.dev/dart-async/Stream-class.html) · [Using streams](https://dart.dev/libraries/async/using-streams) · [stream.dart 3.13.0](https://github.com/dart-lang/sdk/blob/3.13.0/sdk/lib/async/stream.dart#L7-L138)（查阅：2026-08-30）
- `async*` 每次调用会创建一个 single-subscription stream。single-subscription stream 的整个生命周期只允许一个监听者；broadcast stream 允许多个监听者，但没有监听者时不会缓存事件，新监听者只收到订阅后的事件。教程不能把 `asBroadcastStream()` 当作“缓存最近值”的办法。[Stream API](https://api.dart.dev/dart-async/Stream-class.html) · [StreamController.broadcast API](https://api.dart.dev/dart-async/StreamController/StreamController.broadcast.html)（查阅：2026-08-30）
- `StreamSubscription.cancel()` 调用后不再接收事件，返回的 Future 在数据源清理结束后完成。拥有订阅的 State 应在 `dispose` 中取消；若后续操作依赖清理完成，在普通异步代码中还要等待该 Future。[StreamSubscription.cancel API](https://api.dart.dev/dart-async/StreamSubscription/cancel.html)（查阅：2026-08-30）
- `Stream.timeout` 针对相邻事件之间没有新事件的时段，每次数据或错误事件都会重置计时；它和“整个操作总时长不得超过 N 秒”不是同一个合同。[Stream.timeout API](https://api.dart.dev/dart-async/Stream/timeout.html) · [stream.dart 3.13.0](https://github.com/dart-lang/sdk/blob/3.13.0/sdk/lib/async/stream.dart#L1983-L2071)（查阅：2026-08-30）

### 3.2 Stream 适合持续变化，不是 Future 的更强替代

- 单次 HTTP 响应、一次保存和一次 JSON 解析用 Future。数据库查询观察、WebSocket 消息和持续传感数据才用 Stream。把一次 Future 强行包成长期 Stream，只会增加订阅、错误事件和关闭时机的概念。
- 04-01 可以让同一内存数据源提供 `Future<List<Item>> loadOnce()` 与 `Stream<List<Item>> watch()`，比较一次结果与持续更新。此处不提前出现 HTTP、JSON 或数据库；Stream 由 `StreamController` 或 `async*` 测试源驱动，章节结束时释放 controller。

## 4. `FutureBuilder`、`StreamBuilder` 与异步 UI 状态

### 4.1 Builder 的真实合同

- `FutureBuilder.future` 必须在 `initState`、`didUpdateWidget` 或 `didChangeDependencies` 等更早位置取得，不能在 `build` 中现场创建。父级每次重建都创建新 Future，会重启异步任务。[FutureBuilder API](https://api.flutter.dev/flutter/widgets/FutureBuilder-class.html) · [async.dart 3.47.0](https://github.com/flutter/flutter/blob/3.47.0/packages/flutter/lib/src/widgets/async.dart#L458-L535)（查阅：2026-08-30）
- 给 `FutureBuilder` 一个已经完成但身份不同的新 Future，仍可能先出现一帧 `ConnectionState.waiting`；框架无法同步判断普通 Future 已完成。Widget 测试不应断言“已完成 Future 的第一帧必然直接是 data”。[FutureBuilder API](https://api.flutter.dev/flutter/widgets/FutureBuilder-class.html)（查阅：2026-08-30）
- `FutureBuilder` 的 builder 只会收到时间相关快照序列的一个有序子序列，最终完成快照会出现，但中间帧可能被 Flutter pipeline 合并。builder 应纯粹根据当前 snapshot 返回界面，不能把日志、导航、计数或业务写入放进“每个快照都会执行”的假设里。[FutureBuilder API](https://api.flutter.dev/flutter/widgets/FutureBuilder-class.html) · [async.dart 3.47.0](https://github.com/flutter/flutter/blob/3.47.0/packages/flutter/lib/src/widgets/async.dart#L474-L505)（查阅：2026-08-30）
- Future 更换后，旧 Future 的数据或错误可保留在 `none` / `waiting` 快照中；框架用 callback identity 忽略旧 Future 之后的完成回调，但不会取消旧 Future。本部分可用它解释“保留旧数据显示刷新中”和“停止旧请求”是两个问题。[FutureBuilder API](https://api.flutter.dev/flutter/widgets/FutureBuilder-class.html) · [async.dart 3.47.0](https://github.com/flutter/flutter/blob/3.47.0/packages/flutter/lib/src/widgets/async.dart#L591-L668)（查阅：2026-08-30）
- `AsyncSnapshot.hasData` 只在 `data != null` 时为 true。一个成功完成的 `Future<void>` 或合法返回 null 的 Future 仍会 `hasData == false`；应先判断 `connectionState` 与 `hasError`，不能把 `!hasData` 一律当作 loading。[AsyncSnapshot API](https://api.flutter.dev/flutter/widgets/AsyncSnapshot-class.html) · [async.dart 3.47.0](https://github.com/flutter/flutter/blob/3.47.0/packages/flutter/lib/src/widgets/async.dart#L205-L319)（查阅：2026-08-30）
- `StreamBuilder.stream` 同样要在 `build` 之前取得。第一帧一定早于 Stream listener 处理事件；需要同步已知值时用 `initialData`。builder 也只看到事件快照的有序子序列，因此不能在 builder 中实现必须逐事件执行的副作用。[StreamBuilder API](https://api.flutter.dev/flutter/widgets/StreamBuilder-class.html) · [async.dart 3.47.0](https://github.com/flutter/flutter/blob/3.47.0/packages/flutter/lib/src/widgets/async.dart#L325-L455)（查阅：2026-08-30）
- Stream 的错误快照通常处于 `ConnectionState.active`，之后仍可能被新的数据快照替换；done 快照保留最后的数据或错误。教程不能把 Stream 的第一个 error 自动解释成永久终态。[StreamBuilder API](https://api.flutter.dev/flutter/widgets/StreamBuilder-class.html)（查阅：2026-08-30）

### 4.2 UI 状态需要比 `AsyncSnapshot` 更接近任务

`AsyncSnapshot` 描述连接和最近一次异步交互，不知道“空列表”“后台刷新”“旧数据仍可用”“错误后可重试”这些产品语义。课程建议把页面状态至少区分为：

| 状态 | 数据 | 界面动作 |
| --- | --- | --- |
| 首次加载 | 无 | 显示页面骨架或进度，并保留页面标题与退出路径。 |
| 空结果 | 成功但集合为空 | 说明筛选或查询没有结果，提供清空条件或修改查询。 |
| 成功 | 有当前数据 | 显示主要任务。 |
| 后台刷新 | 有旧数据 | 保留内容，显示不遮挡任务的刷新状态。 |
| 首次失败 | 无 | 显示可理解的失败类型和重试动作。 |
| 刷新失败 | 有旧数据 | 保留旧数据，标出更新时间与刷新失败，不把整页替换成错误页。 |

这张表是课程状态设计，不是 Flutter 强制枚举。04-01 先用 `FutureBuilder` / `StreamBuilder` 读懂 SDK 快照；需要重试、旧数据和并发命令时，再用显式不可变状态记录任务语义。空数据是成功结果，不是网络错误。[AsyncSnapshot API](https://api.flutter.dev/flutter/widgets/AsyncSnapshot-class.html) · [FutureBuilder API](https://api.flutter.dev/flutter/widgets/FutureBuilder-class.html)（查阅：2026-08-30）

## 5. `package:http` 的 Service 与 Web 边界

### 5.1 可注入 Client 是最小测试接缝

- `package:http` 官方建议在可测试代码中注入 `Client`，而不是把顶层 `http.get()` 写死在 Service 内。多个请求复用 Client 时应由明确的所有者在不再使用后 `close()`；`Client.close()` 不是单个请求的取消按钮。[http 1.6.0 README](https://pub.dev/packages/http/versions/1.6.0) · [Client 1.6.0](https://pub.dev/documentation/http/1.6.0/http/Client-class.html)（查阅：2026-08-30）
- `Client.get()` 对 HTTP 404、500 等状态仍返回 `Response`，应用必须检查 `statusCode`。`Client.read()` / `readBytes()` 才会对 `statusCode >= 400` 抛 `ClientException`；它们把 3xx 视为成功。教程应在 Service 中按接口合同明确接受哪些 2xx，而不是写“请求没抛异常就是成功”。[Client.get 1.6.0](https://pub.dev/documentation/http/1.6.0/http/Client/get.html) · [Client.read 1.6.0](https://pub.dev/documentation/http/1.6.0/http/Client/read.html) · [base_client.dart 1.6.0 source](https://github.com/dart-lang/http/blob/master/pkgs/http/lib/src/base_client.dart)（查阅：2026-08-30）
- `Response.body` 根据 `Content-Type` 的 charset 解码；`application/json` 没有 charset 时按 UTF-8。Service 测试要包含中文 fixture 和正确 content-type，避免纯 ASCII 样本掩盖解码错误。[Response 1.6.0](https://pub.dev/documentation/http/1.6.0/http/Response-class.html)（查阅：2026-08-30）
- Flutter 官方网络 recipe 把请求创建放进 `initState`，并在响应后检查 status 与解析 JSON；本教程只借用生命周期原则，不复制其 Album 题材或页面结构。[Fetch data from the internet](https://docs.flutter.dev/cookbook/networking/fetch-data)（查阅：2026-08-30）

### 5.2 Web 请求受浏览器限制

- Web 上默认 `Client()` 选择 `BrowserClient`，它由 `window.fetch` 驱动。请求受 Fetch 与 CORS 约束；服务端没有允许当前 origin 时，Flutter 代码不能靠添加普通请求头绕过预检或读取受限响应。[BrowserClient 1.6.0](https://pub.dev/documentation/http/1.6.0/browser_client/BrowserClient-class.html) · [Fetch Standard: CORS protocol](https://fetch.spec.whatwg.org/#http-cors-protocol)（查阅：2026-08-30）
- `BrowserClient.withCredentials` 默认 false，决定跨站请求是否发送 cookie 等凭据。启用凭据还要求服务端返回匹配的 CORS headers，不能只改客户端开关。[BrowserClient.withCredentials 1.6.0](https://pub.dev/documentation/http/1.6.0/browser_client/BrowserClient/withCredentials.html) · [Fetch Standard: credentials and CORS](https://fetch.spec.whatwg.org/#credentials)（查阅：2026-08-30）
- `BrowserClient` 忽略 `persistentConnection` 和 `maxRedirects`；`followRedirects: false` 遇到重定向会得到 `ClientException`。这些字段不能按 `IOClient` 语义写进跨平台教程。[BrowserClient 1.6.0](https://pub.dev/documentation/http/1.6.0/browser_client/BrowserClient-class.html)（查阅：2026-08-30）
- 网络项目默认使用本地 fixture 或 fake Service，真实公开 API 只作为可切换数据源且不进入 CI。这样测试的失败类型来自代码合同，而不是 CORS、远端限流或公开数据变更。前半句是仓库既定规格，后半句是课程测试取舍。

### 5.3 Service 错误分层

04-02 至少区分以下边界，页面再决定怎么显示：

1. `TimeoutException`：调用方等待超过限制；不能据此声称请求已停止。
2. `ClientException` / `RequestAbortedException`：传输、浏览器 Fetch 或主动终止失败。
3. 非预期 status：保留 status、请求 URI 和必要响应摘要，不把 HTML 错误页交给 JSON parser。
4. `FormatException` 或字段转换错误：响应到达，但 JSON 文本或 payload 结构不符合合同。

`RequestAbortedException` 继承 `ClientException`，若界面需要把“用户发起新搜索导致旧请求取消”与真实网络失败分开，捕获顺序要先判断前者。[ClientException 1.6.0](https://pub.dev/documentation/http/1.6.0/http/ClientException-class.html) · [RequestAbortedException 1.6.0](https://pub.dev/documentation/http/1.6.0/http/RequestAbortedException-class.html) · [FormatException API](https://api.dart.dev/dart-core/FormatException-class.html)（查阅：2026-08-30）

## 6. 手写 JSON 与 `json_serializable`

### 6.1 手写解析先建立运行时边界

- `jsonDecode` 返回动态 JSON 结构：object 映射为 Map，array 映射为 List，值可能是 num、String、bool 或 null。它只保证文本符合 JSON 语法，不保证根节点、字段、业务枚举或日期格式符合接口合同。[jsonDecode API](https://api.dart.dev/dart-convert/jsonDecode.html) · [JsonDecoder API](https://api.dart.dev/dart-convert/JsonDecoder-class.html)（查阅：2026-08-30）
- 手写 parser 应先验证根节点，再逐字段区分“必填缺失”“明确 null”“类型错误”“格式错误”。未知字段默认忽略能容忍服务端向前增加字段；需要严格 payload 时再明确拒绝。未知枚举值应映射到可显示的 sentinel 或产生带字段名的转换错误，不能靠 `as` 让运行时 TypeError 泄漏到界面。
- DTO 负责映射传输字段，不可变界面模型负责 Flutter 代码真正需要的值与不变量。本部分可以用同一个普通 Dart 类承载两者，但要把 JSON key、缺省值与显示文案分开；完整 Repository / domain 分层留到第六部分。
- 测试 fixture 至少覆盖：完整记录、可选字段缺失、必填字段缺失、错误类型、未知字段、未知枚举、坏日期、根节点不是 object / list。每个失败都断言稳定的错误类别和字段上下文，不依赖 VM 的原始 cast 报错文本。

### 6.2 生成器替换机械映射，不替代模型设计

- `@JsonSerializable` 生成 `fromJson` / `toJson` 顶层函数，模型通过 `part '<name>.g.dart'` 和工厂 / 方法连接；生成命令是 `dart run build_runner build`。`json_annotation` 是运行时 annotation 依赖，`json_serializable` 与 `build_runner` 放在 dev dependencies。[json_serializable 6.14.1 README](https://github.com/google/json_serializable.dart/blob/json_serializable-v6.14.1/json_serializable/README.md) · [build_runner](https://pub.dev/packages/build_runner)（查阅：2026-08-30）
- 默认配置 `checked: false`、`disallowUnrecognizedKeys: false`、`includeIfNull: true`。因此默认生成代码会忽略未知 key，并用普通 cast / converter 解析；它不是一套自动严格校验器。[JsonSerializable 4.12.0](https://pub.dev/documentation/json_annotation/4.12.0/json_annotation/JsonSerializable-class.html) · [json_serializable build configuration](https://github.com/google/json_serializable.dart/blob/json_serializable-v6.14.1/json_serializable/README.md#build-configuration)（查阅：2026-08-30）
- `JsonKey.required` 检查 key 是否存在，`disallowNullValue` 区分存在但为 null，`defaultValue` 处理缺失或 null，`unknownEnumValue` 处理未识别枚举。`disallowUnrecognizedKeys` 会拒绝未知字段；这些开关必须按接口兼容策略选择，不能全部开启后称为“更安全”。[JsonKey 4.12.0](https://pub.dev/documentation/json_annotation/4.12.0/json_annotation/JsonKey-class.html) · [JsonSerializable.disallowUnrecognizedKeys](https://pub.dev/documentation/json_annotation/4.12.0/json_annotation/JsonSerializable/disallowUnrecognizedKeys.html)（查阅：2026-08-30）
- `checked: true` 会把反序列化中的字段转换错误包装为 `CheckedFromJsonException`，便于保留类名、字段和原错误。它增加运行时检查，但仍不会替应用判断字符串长度、业务范围、跨字段关系或服务端语义。[CheckedFromJsonException 4.12.0](https://pub.dev/documentation/json_annotation/4.12.0/json_annotation/CheckedFromJsonException-class.html) · [JsonSerializable.checked](https://pub.dev/documentation/json_annotation/4.12.0/json_annotation/JsonSerializable/checked.html)（查阅：2026-08-30）
- 包原生支持常见 core 类型与这些类型组成的集合；自定义类型用其自身 `fromJson` / `toJson`、`JsonKey.fromJson` / `toJson` 或 `JsonConverter`。代码生成不提供值相等、`copyWith`、sealed union 或业务验证。[json_serializable supported types](https://github.com/google/json_serializable.dart/blob/json_serializable-v6.14.1/json_serializable/README.md#supported-types) · [JsonConverter 4.12.0](https://pub.dev/documentation/json_annotation/4.12.0/json_annotation/JsonConverter-class.html)（查阅：2026-08-30）
- 04-05 用同一 DTO 的手写版与生成版跑同一组 fixture 测试。比较点是重复映射、错误上下文、配置和构建工具，不比较行数，也不顺带引入 Freezed。

## 7. 防抖、竞态、取消与重试

### 7.1 竞态正确性先于资源取消

- 防抖 timer 只阻止尚未开始的搜索；请求一旦发送，取消 timer 不会影响请求。重点项目应把输入值标准化后再启动搜索，并让清空输入立即清空结果、取消待发 timer、使当前请求结果失效。[Timer.cancel API](https://api.dart.dev/dart-async/Timer/cancel.html)（查阅：2026-08-30）
- 最小正确性方案是单调递增的 request generation：开始搜索时记录 generation，结果回来后只有仍等于当前 generation 才能更新状态。测试用两个 `Completer` 反序完成，先完成新查询、后完成旧查询，最后仍显示新结果。这个规则独立于底层 Client 是否支持取消。
- 取消能节省网络和解析工作，但不能代替 generation 检查。取消信号可能晚于响应完成，Client 也可能不支持某种取消方式；界面仍要拒绝过期结果。

### 7.2 `http 1.6.0` 的主动终止边界

- `AbortableRequest.abortTrigger` 是一个 Future；它完成时通知支持取消的 Client。若响应 Future 尚未完成，`Client.send` 以 `RequestAbortedException` 失败；若已经拿到 `StreamedResponse`，取消会向响应 stream 注入同一异常并提前关闭。trigger 本身不能以错误完成。[Abortable API 1.6.0](https://pub.dev/documentation/http/1.6.0/http/Abortable-class.html) · [RequestAbortedException 1.6.0](https://pub.dev/documentation/http/1.6.0/http/RequestAbortedException-class.html)（查阅：2026-08-30）
- `Client.get()` 没有 abortTrigger 参数。需要主动取消时，要构造 `AbortableRequest` 并走 `Client.send()`，再消费 `StreamedResponse`；不能在普通 `get()` 返回的 Future 上想象一个 `cancel()`。[AbortableRequest 1.6.0](https://pub.dev/documentation/http/1.6.0/http/AbortableRequest-class.html) · [Client.send 1.6.0](https://pub.dev/documentation/http/1.6.0/http/Client/send.html)（查阅：2026-08-30）
- `BrowserClient`、`IOClient` 与 `RetryClient` 支持这套终止协议。`MockClient` 不会自动处理 abort，handler 需要自行观察请求并抛 `RequestAbortedException`；因此取消测试不能只换成默认 `MockClient` 后期待行为自动一致。[http 1.6.0 README: Aborting requests](https://pub.dev/packages/http/versions/1.6.0#aborting-requests) · [MockClient 1.6.0](https://pub.dev/documentation/http/1.6.0/testing/MockClient-class.html)（查阅：2026-08-30）

### 7.3 重试必须受请求语义约束

- `RetryClient` 默认只重试 status 503，默认重试 3 次，也就是最多发送 4 次；首次等待 500ms，之后每次乘 1.5。默认不会重试任意异常，条件、延迟和回调都可配置。正文若使用它，要显式写清这些默认值，不能说“网络错会自动重试三次”。[RetryClient 1.6.0](https://pub.dev/documentation/http/1.6.0/retry/RetryClient-class.html)（查阅：2026-08-30）
- HTTP 规范只允许客户端在请求语义幂等，或能确认原请求未生效时自动重试非幂等请求。搜索 GET 可以有限重试；创建订单、提交表单等写请求不能无条件自动重发。[RFC 9110 §9.2.2 Idempotent Methods](https://www.rfc-editor.org/rfc/rfc9110.html#section-9.2.2)（查阅：2026-08-30）
- 本部分采用有上限、可测试、带退避的重试，只处理明确的临时 transport failure、408 / 429 / 503 等项目合同允许的情况；4xx 参数错误、JSON 格式错误和业务拒绝不自动重试。自动重试结束后仍保留人工重试入口。
- 所有 delay 和 debounce 都注入或封装成可控时钟 / Duration。测试推进 fake time，不真实等待数秒；不能让竞态测试依赖机器速度。

## 8. 内存缓存、HTTP cache、偏好与离线回退

### 8.1 三种“缓存”不能混成一个概念

| 层 | 所有者 | 能回答的问题 | 本部分边界 |
| --- | --- | --- | --- |
| 页面 / Service 内存缓存 | 应用代码 | 某个查询参数是否已有数据、数据何时取得、是否允许 stale-while-refresh | 刷新页面后丢失；要自己定义 key、新鲜度和并发去重。 |
| 浏览器 HTTP cache | 浏览器与 HTTP 响应头 | 响应能否复用、何时重新验证、304 如何合并 | `BrowserClient` 走 Fetch；应用不把内存 Map 冒充 HTTP cache。 |
| 本地持久化 | `SharedPreferencesAsync` 或 Drift | 偏好、收藏和离线数据能否跨刷新保留 | 数据形态决定存储，不用一个包保存所有内容。 |

- HTTP cache 的 freshness 由 `Cache-Control`、`Expires`、`Age` 等协议字段决定；`no-store` 禁止存储，`no-cache` 允许存储但复用前必须验证。正文必须纠正常见的“`no-cache` 等于完全不缓存”。[RFC 9111 HTTP Caching](https://www.rfc-editor.org/rfc/rfc9111.html) · [RFC 9111 §5.2.2 Response Directives](https://www.rfc-editor.org/rfc/rfc9111.html#section-5.2.2)（查阅：2026-08-30）
- ETag / `If-None-Match` 与 Last-Modified / `If-Modified-Since` 可做条件请求；304 不带新的完整表示，缓存要把元数据更新应用到已存响应。若项目手工实现条件请求，必须同时拥有旧 body；只处理 304 status 而没有本地副本无法得到数据。[RFC 9111 §4.3 Validation](https://www.rfc-editor.org/rfc/rfc9111.html#section-4.3)（查阅：2026-08-30）
- `BrowserClient` 继承浏览器 Fetch 行为，但 `package:http` 的跨平台 `Client` 接口不提供统一的命中统计或缓存策略 API。项目要展示“上次成功同步时间”和 stale 状态，应由应用缓存元数据或 Drift 记录，不猜测响应是否来自浏览器 cache。[BrowserClient 1.6.0](https://pub.dev/documentation/http/1.6.0/browser_client/BrowserClient-class.html) · [Fetch Standard: HTTP-network-or-cache fetch](https://fetch.spec.whatwg.org/#http-network-or-cache-fetch)（查阅：2026-08-30）

### 8.2 内存缓存需要明确策略

课程建议把内存缓存写成窄接口，并固定以下合同：

- key 包含所有影响结果的查询参数；标准化空白和大小写规则要与请求 URI 一致；
- entry 保存数据与取得时间，freshness 由注入时钟判断；
- 相同 key 的进行中 Future 可共享，失败后要移除，避免永久缓存失败；
- 手动刷新绕过 freshness，但仍可保留旧数据显示刷新中；
- 容量与逐出规则按项目数据量明确，不能留下无界 Map；
- 内存缓存只活在当前应用实例，浏览器刷新后失效。

这些是项目缓存策略，不是 HTTP 规范。04-06 用固定 clock 覆盖 fresh hit、stale refresh、失败保留旧数据、手动刷新和逐出。

### 8.3 偏好和业务数据分开

- `SharedPreferencesAsync` 只支持 int、double、bool、String 与 `List<String>` 等简单值，Web 后端是 LocalStorage。写入返回后也不保证关键数据已经可靠持久化，官方明确禁止把它用于关键数据。[shared_preferences 2.5.5 README](https://pub.dev/packages/shared_preferences/versions/2.5.5)（查阅：2026-08-30）
- `SharedPreferencesAsync` 不维护本地缓存，每次读写都是异步平台存储调用；`SharedPreferencesWithCache` 可同步读取，但多 isolate、多 engine 或其他写入者会造成陈旧值，需要 `reload`。第四部分只保存活动类型、距离或排序偏好，使用 Async API；收藏与活动快照进入 Drift。[shared_preferences 2.5.5 README: cache and async getters](https://pub.dev/packages/shared_preferences/versions/2.5.5#cache-and-async-or-sync-getters)（查阅：2026-08-30）
- 本地 fixture 是随应用发布的已知样本，不是网络缓存。断网或可控故障时可显示 fixture，但界面必须标明数据来源和固定更新时间；不能把 fixture 显示成“刚同步”。

## 9. Drift 2.34.3：关系数据、迁移与 Web

### 9.1 关系数据与响应式查询

- Drift 是 SQLite 上的响应式关系数据层，查询可以一次性 `get()`，也可以 `watch()` 成 Stream。所有 watch 查询订阅后都会先产生一份当前结果，不需要先 `get()` 再 watch。[Drift stream queries 2.34.3](https://github.com/simolus3/drift/blob/drift-2.34.3/docs/content/dart_api/streams.md)（查阅：2026-08-30）
- Drift 通过跟踪查询涉及的表来推断需要重跑的 Stream。它是表级启发式：可能比必要次数更频繁地重跑，外部 SQLite 客户端的写入也不会自动触发。查询 Stream 应返回有限行数并保持查询成本可控。[Drift stream caveats 2.34.3](https://github.com/simolus3/drift/blob/drift-2.34.3/docs/content/dart_api/streams.md#caveats)（查阅：2026-08-30）
- `transaction` 内所有数据库调用都要 `await`；callback 完成后 transaction 关闭。成功时变更整体可见，抛错则回滚。transaction 外创建的查询 Stream 只在 transaction 完成后看到一致更新；transaction 内创建的 Stream 随 transaction 结束而关闭。[Drift transactions 2.34.3](https://github.com/simolus3/drift/blob/drift-2.34.3/docs/content/dart_api/transactions.md)（查阅：2026-08-30）
- 04-07 可用“活动表 + 收藏表 + 同步元数据”体现关系查询和事务：替换一次网络快照时保留用户收藏，用 join 输出收藏活动，用一个 transaction 写入活动和同步时间。若只保存一个 JSON 字符串，就没有承担 Drift 教学成本的理由。

### 9.2 迁移要保存历史并测试

- 数据库通过 `schemaVersion` 与 `MigrationStrategy.onUpgrade` 应用变更。Drift 官方明确说手写 migration 容易丢数据，推荐 `dart run drift_dev make-migrations` 生成逐步迁移与测试；查询 migration 中旧 schema 时还要避免让最新版 data class 错读旧列。[Drift migrations 2.34.3](https://github.com/simolus3/drift/blob/drift-2.34.3/docs/content/migrations/index.md) · [Drift migration API 2.34.3](https://github.com/simolus3/drift/blob/drift-2.34.3/docs/content/migrations/api.md)（查阅：2026-08-30）
- schema test 先从导出的旧 schema 建库，再执行应用 migration，并语义比较 `sqlite_schema`；数据完整性测试还要在迁移前插入旧版数据，迁移后验证内容。只验证“新建最新版数据库成功”不能证明升级路径可用。[Testing Drift migrations 2.34.3](https://github.com/simolus3/drift/blob/drift-2.34.3/docs/content/migrations/tests.md)（查阅：2026-08-30）
- 第四部分只做一次小迁移，例如为活动增加来源或场馆字段，并保存 v1 schema。读者需要看到新增非空列如何提供默认值、迁移失败如何回滚、旧数据如何保留；复杂数据回填和多分支 downgrade 不在本章展开。

### 9.3 Web 需要 Wasm、Worker 与能力探测

- Web 浏览器不自带 sqlite3。Drift 需要 `sqlite3.wasm`，并用 Web Worker 在后台线程运行数据库、在可行时跨标签共享；两个文件应从同一 Drift release 取得。2.34.3 release 的文件名是 `sqlite3.wasm` 与 `drift_worker.js`。[Drift Web prerequisites 2.34.3](https://github.com/simolus3/drift/blob/drift-2.34.3/docs/content/platforms/web.md#getting-started) · [Drift 2.34.3 release](https://github.com/simolus3/drift/releases/tag/drift-2.34.3)（查阅：2026-08-30）
- Flutter 项目可用 `driftDatabase(name:, web: DriftWebOptions(...))`，显式传入 Wasm 与 worker URI。`DriftWebOptions.onResult` 能读取 `WasmDatabaseResult.chosenImplementation` 与 `missingFeatures`，项目应把不可靠存储模式变成可观察状态，不只打印日志。[driftDatabase 0.3.1](https://pub.dev/documentation/drift_flutter/0.3.1/drift_flutter/driftDatabase.html) · [DriftWebOptions 0.3.1](https://pub.dev/documentation/drift_flutter/0.3.1/drift_flutter/DriftWebOptions-class.html) · [WasmDatabaseResult 2.34.3](https://pub.dev/documentation/drift/2.34.3/wasm/WasmDatabaseResult-class.html)（查阅：2026-08-30）
- `WasmDatabase.open` 会探测浏览器能力并按条件选择 `opfsShared`、`opfsLocks`、`sharedIndexedDb`、`unsafeIndexedDb` 或 `inMemory`。`unsafeIndexedDb` 不支持同一数据库被多标签安全访问，`inMemory` 不持久化；若选中后二者且本地数据关键，界面应警告而不是继续承诺离线保存。[Drift Web storage implementations 2.34.3](https://github.com/simolus3/drift/blob/drift-2.34.3/docs/content/platforms/web.md#supported-storage-implementations) · [WasmStorageImplementation 2.34.3](https://pub.dev/documentation/drift/2.34.3/wasm/WasmStorageImplementation.html)（查阅：2026-08-30）
- OPFS 的同步访问通常需要 `Cross-Origin-Opener-Policy: same-origin` 与 `Cross-Origin-Embedder-Policy: require-corp` 或 `credentialless`。没有这些 headers 时 Drift 会回退，不等于完全不能运行；开启 headers 又可能影响 Google Auth 弹窗等功能，所以需要在实际部署环境验证。[Drift Web additional headers 2.34.3](https://github.com/simolus3/drift/blob/drift-2.34.3/docs/content/platforms/web.md#additional-headers)（查阅：2026-08-30）
- `sqlite3.wasm` 必须以 `Content-Type: application/wasm` 提供。`flutter run` 会处理，但 release 构建经静态服务器或 GitHub Pages 发布后仍要检查响应头、base path 和 worker 加载；`flutter build web` 成功本身不能证明数据库能打开。[Drift Web serving wasm 2.34.3](https://github.com/simolus3/drift/blob/drift-2.34.3/docs/content/platforms/web.md#prerequisites) · [Build and release a web app](https://docs.flutter.dev/deployment/web)（查阅：2026-08-30）
- Firefox private browsing、Chrome Android 无 Shared Worker 等环境可能触发 IndexedDB 或内存回退；多标签保证也会变化。教程只承诺在指定桌面 Chrome Web 验收，正文要列出未验证浏览器，不把一次 Chrome 通过写成所有 Web 平台保证。[Drift supported browsers 2.34.3](https://github.com/simolus3/drift/blob/drift-2.34.3/docs/content/platforms/web.md#supported-browsers)（查阅：2026-08-30）

## 10. 测试边界

### 10.1 按风险选择测试层

| 风险 | 最小测试证据 | 不能证明的事 |
| --- | --- | --- |
| Future / Stream 状态 | 用 Completer、StreamController 和精确 `pump` 验证 loading、data、error、done、旧数据。 | 真实浏览器网络与持久化。 |
| HTTP Service | 注入 `MockClient`，覆盖成功、timeout、status、坏 JSON、中文编码。 | CORS、Fetch、服务端实际可用性。 |
| 搜索竞态 | 两个 Completer 逆序完成；fake time 推进 debounce。 | 底层请求真的停止。 |
| 主动取消 | 支持 abort 的专用 fake 或真实 BrowserClient 集成测试。 | 默认 MockClient 自动模拟 abort。 |
| JSON 模型 | 手写版与生成版跑同一 fixture 表。 | 服务端未来一定不改 schema。 |
| 内存缓存 | 注入 clock，验证 freshness、stale、失败与逐出。 | 浏览器 HTTP cache 命中。 |
| Drift 逻辑 | 内存数据库验证查询、transaction、Stream 和 migration。 | Wasm / Worker 资产、浏览器存储选择、刷新、多标签。 |
| Drift Web | Chrome 加载 release 资产，写入、刷新重开、离线读取并记录 chosenImplementation。 | 未测试浏览器与移动端实现。 |

- `MockClient` 能用 handler 构造响应或错误，不发送真实请求。它适合 Service 合同；若要断言 method、URI、query 和 headers，应在 handler 内检查请求。Flutter 官方也要求把 HTTP Client 作为依赖传入待测函数。[MockClient 1.6.0](https://pub.dev/documentation/http/1.6.0/testing/MockClient-class.html) · [Flutter mocking dependencies](https://docs.flutter.dev/cookbook/testing/unit/mocking)（查阅：2026-08-30）
- Widget 测试通过 `pump(duration)` 推进 timer 与动画时钟；有长期 Stream、重试 timer 或数据库通知时，不应依赖 `pumpAndSettle` 猜何时结束。[WidgetTester.pump API](https://api.flutter.dev/flutter/flutter_test/WidgetTester/pump.html) · [WidgetTester.pumpAndSettle API](https://api.flutter.dev/flutter/flutter_test/WidgetTester/pumpAndSettle.html)（查阅：2026-08-30）
- Drift 官方单元测试建议使用内存数据库，并在测试结束时 `close()`；migration verifier 可从导出的历史 schema 建库。它能证明 SQL、映射和迁移，但底层不是浏览器的 OPFS / IndexedDB 选择。[Testing Drift 2.34.3](https://github.com/simolus3/drift/blob/drift-2.34.3/docs/content/testing.md) · [Testing Drift migrations 2.34.3](https://github.com/simolus3/drift/blob/drift-2.34.3/docs/content/migrations/tests.md)（查阅：2026-08-30）
- 浏览器关键流程使用 Flutter 官方 Web integration test / ChromeDriver 流程；数据库还要增加一次 release Web 静态服务器验收，检查 `sqlite3.wasm` MIME、worker URL、刷新持久化和多标签行为。普通 integration test 通过不能代替 release 部署检查。[Flutter integration tests: web browser](https://docs.flutter.dev/testing/integration-tests#test-in-a-web-browser) · [Drift Web 2.34.3](https://github.com/simolus3/drift/blob/drift-2.34.3/docs/content/platforms/web.md)（查阅：2026-08-30）

## 11. 建议的八章顺序

| 章节 | 主问题 | 讲透的内容 | 本章暂不展开 |
| --- | --- | --- | --- |
| 04-01 把 Future 与 Stream 变成界面状态 | 一次结果与持续更新如何进入 UI | Future / Stream 合同、错误、订阅、`FutureBuilder` / `StreamBuilder`、loading / empty / data / error、旧数据 | HTTP、JSON、数据库、状态管理包 |
| 04-02 HTTP Service 与错误边界 | 请求如何保持可替换、可测试 | 注入 `Client`、URI、status、timeout、Web CORS、fixture、错误分类 | JSON 字段模型、重试策略、架构分层 |
| 04-03 手写 JSON 模型 | 动态 payload 如何变成可信模型 | 根节点、必填 / 可选 / null、未知字段与枚举、转换错误、不可变 DTO | 代码生成、Freezed、Repository |
| 04-04 防抖、竞态与即时书目检索 | 旧响应为什么覆盖新结果 | timer、防抖、generation、主动取消边界、旧结果、人工重试；完成重点项目 | 通用状态库、无限滚动、真实 API 作为 CI 依赖 |
| 04-05 `json_serializable` 与生成代码 | 何时值得替换手写映射 | annotation、part、命令、默认宽松行为、checked、同 fixture 对照 | Freezed、JSON Schema、通用 codegen 架构 |
| 04-06 偏好、缓存与离线回退 | 数据该留多久、留在哪里 | `SharedPreferencesAsync`、内存 key / freshness、HTTP cache 基础、stale UI、fixture 来源 | Service Worker、PWA、通用同步引擎 |
| 04-07 关系数据、Drift 与迁移 | 收藏和离线活动如何可靠演进 | 表、查询、transaction、watch Stream、schema migration、Web Wasm / worker / fallback、测试边界 | 高级 SQL、DAO 大型分层、加密数据库 |
| 04-08 统筹项目：城市活动雷达 | 能否把网络与本地事实组合起来 | 在线加载、解析、筛选偏好、收藏、旧数据、失败恢复、迁移、Web 验收 | Riverpod、Repository / ViewModel 正式分层 |

依赖顺序有五条理由：

1. 先用内存 fake 讲异步 UI，读者不会同时猜 Future、HTTP、JSON 和 Widget 生命周期。[FutureBuilder API](https://api.flutter.dev/flutter/widgets/FutureBuilder-class.html) · [StreamBuilder API](https://api.flutter.dev/flutter/widgets/StreamBuilder-class.html)（查阅：2026-08-30）
2. HTTP Service 先返回原始响应或 parser 接口，下一章再展开 JSON 字段错误；Transport 与 decode failure 才不会混成一个 Exception。
3. 竞态项目放在手写 JSON 之后，搜索结果可使用真实模型；生成器放在项目之后，读者已经知道它替换的代码和没有替换的验证。
4. 先建立内存 freshness 与旧数据状态，再加入持久化；否则“数据库里有数据”容易被误写成“数据仍然新鲜”。
5. Drift 放在最后一个概念章，因为它同时依赖 Stream、模型、缓存语义和迁移测试；capstone 只组合已有概念，不再增加新存储包。

## 12. 两个项目的内容边界

### 12.1 重点项目：即时书目检索

项目集中证明 04-01 至 04-04：

- 输入停顿后才发起查询，空白查询不请求；清空输入立即回到初始状态；
- Service 接收 `http.Client` 或窄接口，默认预览可使用固定书目 fixture，真实公开 API 只作手动切换；
- 两次查询可控延迟并逆序完成，旧响应永远不能覆盖新结果；
- 区分初始、搜索中、空结果、成功、失败、保留旧结果重试；
- 支持 generation guard；若实现 `AbortableRequest`，还要单独测试取消异常不显示成网络失败；
- 单元测试覆盖 parser、status、timeout 与竞态，Widget 测试覆盖 debounce、空结果和重试，Chrome 流程快速输入两次验证最终查询；
- 不使用 Riverpod、Repository、Drift 或 `json_serializable`，避免重点从竞态移走。

项目不能复刻官方 Album / Photos 示例。题材可以是有封面色块、作者、语言、出版信息和馆藏状态的书目工作台，但 fixture 要原创，界面明确标注教学示例数据。

### 12.2 统筹项目：城市活动雷达

项目集中复习本部分：

- 网络 Service、fixture Service 与故障开关遵守同一窄接口；默认 CI 不访问远端；
- 手写或生成 DTO 只处理 payload，页面状态保留 source、lastSuccessfulSync、stale 与 refresh error；
- `SharedPreferencesAsync` 保存筛选偏好，不保存收藏或活动记录；
- Drift 保存活动快照、收藏关系和同步元数据，查询 Stream 驱动可见列表；
- 在线成功后 transaction 更新快照与同步时间，网络失败后读取旧数据；没有旧数据时才使用带固定来源标记的 fixture；
- v1 → v2 migration 保留收藏和活动，schema verifier 与数据完整性测试都通过；
- Web 运行时记录 `chosenImplementation`，遇到 `unsafeIndexedDb` / `inMemory` 时不承诺可靠离线；
- Chrome 验收覆盖在线加载、收藏、刷新页面后仍在、故障后读取旧数据、恢复联网刷新；另检查 `sqlite3.wasm` MIME 与 worker 请求。

项目仍使用第三部分的本地 controller / notifier 边界。正式 ViewModel、Repository、Result 与 Riverpod 放到第六部分；不能为了项目“像生产应用”提前讲完整架构。

## 13. 写作时必须避免的误讲

| 容易写成 | 应改成 |
| --- | --- |
| “`await` 会阻塞线程” | `await` 暂停当前 async 函数，事件循环仍可处理其他工作。 |
| “`.timeout` 会取消 HTTP 请求” | 它只让包装后的 Future 超时；要停止支持的请求需 `AbortableRequest`。 |
| “Future 都能 cancel” | 普通 Future 没有通用取消；取消属于数据源 API。 |
| “`FutureBuilder` 放在 build 里就会缓存 Future” | Future 要在生命周期或状态对象中先取得；build 创建会重启任务。 |
| “已完成 Future 第一帧一定是 data” | 新 Future 即使已完成，也可能先有一帧 waiting。 |
| “`snapshot.hasData == false` 就是 loading” | 成功 null 也没有 data；先看 connectionState 与 hasError。 |
| “Stream 一报错就结束” | error 是事件，数据源可能继续；`await for` 的未处理错误才会退出循环。 |
| “broadcast stream 会保存最后一个值” | 无监听者时事件会丢失；它不是 replay cache。 |
| “HTTP 404 会让 `client.get` 抛异常” | `get` 返回 Response，Service 自己判断 status。 |
| “CORS 能在 Flutter 里关掉” | CORS 由浏览器与服务端响应控制，客户端不能绕过。 |
| “取消防抖 timer 就取消了请求” | timer 只阻止尚未开始的请求；已发请求另行处理。 |
| “请求能取消就不需要 request generation” | generation 保证旧结果不写回；取消只减少无用工作。 |
| “所有失败都自动重试” | 只重试项目合同允许的临时失败和幂等操作，并设置上限与退避。 |
| “`jsonDecode` 已经验证模型” | 它只验证 JSON 语法，字段结构和业务值由 parser 负责。 |
| “`json_serializable` 自动拒绝未知字段” | 默认 `disallowUnrecognizedKeys: false`，未知字段被忽略。 |
| “生成器同时生成不可变、相等和业务校验” | 它只生成 JSON 映射；其余责任仍在模型。 |
| “内存 Map 就是 HTTP cache” | 应用缓存与浏览器 HTTP cache 是两层，key、freshness 和失效合同不同。 |
| “`Cache-Control: no-cache` 表示不能存” | 它允许存储，但复用前必须验证；禁止存储的是 `no-store`。 |
| “Shared Preferences 可以存关键业务记录” | 官方不保证写入返回后已可靠持久化；只保存少量偏好。 |
| “Drift watch 只在结果真的变化时通知” | Drift 按涉及表启发式重跑，可能比需要更频繁。 |
| “内存数据库测试通过就证明 Drift Web 可用” | 还要在 Chrome 验证 Wasm、worker、存储回退、刷新和多标签。 |
| “没有 COOP / COEP，Drift 就不能运行” | Drift 会回退到其他实现；速度、持久化和多标签保证可能降低。 |
| “`flutter build web` 成功就证明 Wasm 能加载” | 部署服务器仍要返回正确 MIME，并保证 worker 与 base path 可访问。 |

## 14. 正文参考资料清单

章节页尾只列实际使用的来源，不必把本清单整段复制过去。

- [Dart SDK 3.13.0 release](https://github.com/dart-lang/sdk/releases/tag/3.13.0)（查阅：2026-08-30）
- [Asynchronous programming: futures, async, await](https://dart.dev/libraries/async/async-await)（查阅：2026-08-30）
- [Dart async language](https://dart.dev/language/async)（查阅：2026-08-30）
- [Dart concurrency](https://dart.dev/language/concurrency)（查阅：2026-08-30）
- [Futures and error handling](https://dart.dev/libraries/async/futures-error-handling)（查阅：2026-08-30）
- [Using streams](https://dart.dev/libraries/async/using-streams)（查阅：2026-08-30）
- [Future API](https://api.dart.dev/dart-async/Future-class.html)（查阅：2026-08-30）
- [Future.wait API](https://api.dart.dev/dart-async/Future/wait.html)（查阅：2026-08-30）
- [Future.timeout API](https://api.dart.dev/dart-async/Future/timeout.html)（查阅：2026-08-30）
- [Stream API](https://api.dart.dev/dart-async/Stream-class.html)（查阅：2026-08-30）
- [Stream.timeout API](https://api.dart.dev/dart-async/Stream/timeout.html)（查阅：2026-08-30）
- [StreamSubscription.cancel API](https://api.dart.dev/dart-async/StreamSubscription/cancel.html)（查阅：2026-08-30）
- [StreamController.broadcast API](https://api.dart.dev/dart-async/StreamController/StreamController.broadcast.html)（查阅：2026-08-30）
- [jsonDecode API](https://api.dart.dev/dart-convert/jsonDecode.html)（查阅：2026-08-30）
- [Flutter 3.47.0 release notes](https://docs.flutter.dev/release/release-notes/release-notes-3.47.0)（查阅：2026-08-30）
- [FutureBuilder API](https://api.flutter.dev/flutter/widgets/FutureBuilder-class.html)（查阅：2026-08-30）
- [StreamBuilder API](https://api.flutter.dev/flutter/widgets/StreamBuilder-class.html)（查阅：2026-08-30）
- [AsyncSnapshot API](https://api.flutter.dev/flutter/widgets/AsyncSnapshot-class.html)（查阅：2026-08-30）
- [Fetch data from the internet](https://docs.flutter.dev/cookbook/networking/fetch-data)（查阅：2026-08-30）
- [Mock dependencies using Mockito](https://docs.flutter.dev/cookbook/testing/unit/mocking)（查阅：2026-08-30）
- [Flutter Web integration tests](https://docs.flutter.dev/testing/integration-tests#test-in-a-web-browser)（查阅：2026-08-30）
- [Build and release a web app](https://docs.flutter.dev/deployment/web)（查阅：2026-08-30）
- [http 1.6.0 package](https://pub.dev/packages/http/versions/1.6.0)（查阅：2026-08-30）
- [http 1.6.0 changelog](https://pub.dev/packages/http/versions/1.6.0/changelog)（查阅：2026-08-30）
- [Client 1.6.0](https://pub.dev/documentation/http/1.6.0/http/Client-class.html)（查阅：2026-08-30）
- [BrowserClient 1.6.0](https://pub.dev/documentation/http/1.6.0/browser_client/BrowserClient-class.html)（查阅：2026-08-30）
- [AbortableRequest 1.6.0](https://pub.dev/documentation/http/1.6.0/http/AbortableRequest-class.html)（查阅：2026-08-30）
- [RequestAbortedException 1.6.0](https://pub.dev/documentation/http/1.6.0/http/RequestAbortedException-class.html)（查阅：2026-08-30）
- [MockClient 1.6.0](https://pub.dev/documentation/http/1.6.0/testing/MockClient-class.html)（查阅：2026-08-30）
- [RetryClient 1.6.0](https://pub.dev/documentation/http/1.6.0/retry/RetryClient-class.html)（查阅：2026-08-30）
- [Fetch Standard](https://fetch.spec.whatwg.org/)（查阅：2026-08-30）
- [RFC 9110: HTTP Semantics](https://www.rfc-editor.org/rfc/rfc9110.html)（查阅：2026-08-30）
- [RFC 9111: HTTP Caching](https://www.rfc-editor.org/rfc/rfc9111.html)（查阅：2026-08-30）
- [json_serializable 6.14.1 package](https://pub.dev/packages/json_serializable/versions/6.14.1)（查阅：2026-08-30）
- [json_serializable 6.14.1 README](https://github.com/google/json_serializable.dart/blob/json_serializable-v6.14.1/json_serializable/README.md)（查阅：2026-08-30）
- [JsonSerializable 4.12.0](https://pub.dev/documentation/json_annotation/4.12.0/json_annotation/JsonSerializable-class.html)（查阅：2026-08-30）
- [JsonKey 4.12.0](https://pub.dev/documentation/json_annotation/4.12.0/json_annotation/JsonKey-class.html)（查阅：2026-08-30）
- [CheckedFromJsonException 4.12.0](https://pub.dev/documentation/json_annotation/4.12.0/json_annotation/CheckedFromJsonException-class.html)（查阅：2026-08-30）
- [shared_preferences 2.5.5 package](https://pub.dev/packages/shared_preferences/versions/2.5.5)（查阅：2026-08-30）
- [Drift 2.34.3 package](https://pub.dev/packages/drift/versions/2.34.3)（查阅：2026-08-30）
- [Drift 2.34.3 release](https://github.com/simolus3/drift/releases/tag/drift-2.34.3)（查阅：2026-08-30）
- [Drift Web 2.34.3](https://github.com/simolus3/drift/blob/drift-2.34.3/docs/content/platforms/web.md)（查阅：2026-08-30）
- [Drift stream queries 2.34.3](https://github.com/simolus3/drift/blob/drift-2.34.3/docs/content/dart_api/streams.md)（查阅：2026-08-30）
- [Drift transactions 2.34.3](https://github.com/simolus3/drift/blob/drift-2.34.3/docs/content/dart_api/transactions.md)（查阅：2026-08-30）
- [Drift migrations 2.34.3](https://github.com/simolus3/drift/blob/drift-2.34.3/docs/content/migrations/index.md)（查阅：2026-08-30）
- [Testing Drift migrations 2.34.3](https://github.com/simolus3/drift/blob/drift-2.34.3/docs/content/migrations/tests.md)（查阅：2026-08-30）
- [Testing Drift 2.34.3](https://github.com/simolus3/drift/blob/drift-2.34.3/docs/content/testing.md)（查阅：2026-08-30）
- [driftDatabase 0.3.1](https://pub.dev/documentation/drift_flutter/0.3.1/drift_flutter/driftDatabase.html)（查阅：2026-08-30）
- [DriftWebOptions 0.3.1](https://pub.dev/documentation/drift_flutter/0.3.1/drift_flutter/DriftWebOptions-class.html)（查阅：2026-08-30）
- [WasmDatabase.open 2.34.3](https://pub.dev/documentation/drift/2.34.3/wasm/WasmDatabase/open.html)（查阅：2026-08-30）
- [WasmDatabaseResult 2.34.3](https://pub.dev/documentation/drift/2.34.3/wasm/WasmDatabaseResult-class.html)（查阅：2026-08-30）
