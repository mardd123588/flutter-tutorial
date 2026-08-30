---
title: HTTP Service 与错误边界
description: 注入 Client，分开处理状态码、超时、传输失败、解析失败与 Web CORS。
part: 4
order: 2
kind: concept
requires:
  - async.ui-state
provides:
  - data.http-client
  - data.service
  - error.network
  - test.http-client
status: verified
---

# HTTP Service 与错误边界

页面直接调用 `http.get()` 很快，却把 URI、状态码、超时和解析规则都粘进 Widget。最小改进不是先上完整架构，而是把请求收进一个接收 `http.Client` 的 Service。页面只处理任务结果，测试可以替换 Client。

## 注入 Client 是最小接缝

即时书目检索的 Service 把 Client 放进构造函数：

<<< ../../../examples/focus/instant_book_search/lib/src/book_search_service.dart#injectable-http-service{dart}

这段代码完成四件事：

1. 用 `Uri` 组装 query，不手工拼接和转义。
2. 给调用方等待设置期限。
3. 在解析 JSON 前检查 status。
4. 把传输、status 和 decode 失败翻译成页面可处理的错误。

多个请求复用的 Client 应由明确的上层所有者关闭。`Client.close()` 释放整个 Client 的资源，不是单次请求的取消按钮。

## 没抛异常不等于 HTTP 成功

`Client.get()` 收到 404 或 500 时仍返回 `Response`。Service 必须按接口合同判断允许的状态：

| 现象 | Service 应保留的信息 | 页面可能动作 |
| --- | --- | --- |
| timeout | 等待期限、请求动作 | 重试，说明可能仍在执行 |
| `ClientException` | 传输失败摘要 | 检查网络或使用缓存 |
| 非预期 status | status、URI、有限响应摘要 | 按 401、404、429、5xx 分类 |
| JSON 文本或字段错误 | decode 位置与原因 | 报告数据格式问题，不说“网络断了” |

不要先把 500 的 HTML 错误页交给 JSON parser，再把 `FormatException` 显示成“数据损坏”。status 边界应先通过。

`Response.body` 会根据 `Content-Type` 解码。`http 1.6.0` 对没有 charset 的 `application/json` 使用 UTF-8；测试仍应给中文 fixture 和正确 content-type，避免 ASCII 样本掩盖编码错误。

## timeout 与取消仍是两层

```dart
final response = await client.get(uri).timeout(const Duration(seconds: 4));
```

这行只让返回的 Future 在 4 秒后超时。底层 Fetch 可能继续。`http 1.6.0` 提供 `AbortableRequest`，但只有 Client 和传输实现支持时才会停止底层请求。

界面需要分开决定：

- 超时后是否允许用户重试；
- 旧响应回来后是否还能写状态；
- 是否值得为节省带宽接入主动 abort。

即使能 abort，请求编号仍要保留，因为取消可能来不及，服务端也可能已经完成工作。

## Web 还受 CORS 约束

Web 上默认 Client 使用 Fetch。浏览器会检查 origin、预检和服务端响应头。Flutter 代码不能“关闭 CORS”，也不能靠添加普通请求头绕过服务端限制。

`BrowserClient.withCredentials` 决定跨站请求是否携带 cookie 等凭据。打开它以后，服务端仍需返回匹配的 CORS headers。Chrome 能打开一个 API URL，不等于页面脚本有权读取响应。

教程项目使用可重复 fixture：默认预览和 CI 不访问公开 API。真实服务只适合手动验证 CORS、限流和实际数据变化。

## 用 MockClient 测合同

`MockClient` 的 handler 会收到完整 request，再返回响应或错误：

```dart
final client = MockClient((request) async {
  expect(request.url.queryParameters['q'], '河');
  return Response.bytes(
    utf8.encode(fixture),
    200,
    headers: {'content-type': 'application/json; charset=utf-8'},
  );
});
```

Service 测试至少覆盖成功、超时、非预期 status 和坏 JSON。它能证明应用如何发送与解释请求，不能证明 CORS、远端服务或浏览器缓存行为。

## 可验证任务

为一个活动列表写可注入 Client 的 Service：

1. 断言 method、path 和 query 参数。
2. 200 + 中文 fixture 返回结果。
3. 503 保留 status，不进入 JSON parser。
4. 超时被翻译成可重试错误，同时说明底层任务未必取消。
5. 坏 JSON 被标为 decode 失败，不标为网络失败。
6. Widget 测试只注入 fake Service，不访问真实网络。

## 复习线索

- Service 收住 URI、status、timeout 和解析边界；Widget 处理任务状态。
- `Client.get()` 对 4xx、5xx 返回 Response，应用自己判断成功范围。
- `MockClient` 证明请求与响应合同，不证明 CORS 或远端可用性。
- Web CORS 由浏览器和服务端共同执行，客户端不能关闭。

## 参考资料

- [http 1.6.0 package](https://pub.dev/packages/http/versions/1.6.0)（查阅：2026-08-30）
- [Client 1.6.0 API](https://pub.dev/documentation/http/1.6.0/http/Client-class.html)（查阅：2026-08-30）
- [BrowserClient 1.6.0 API](https://pub.dev/documentation/http/1.6.0/browser_client/BrowserClient-class.html)（查阅：2026-08-30）
- [AbortableRequest 1.6.0 API](https://pub.dev/documentation/http/1.6.0/http/AbortableRequest-class.html)（查阅：2026-08-30）
- [MockClient 1.6.0 API](https://pub.dev/documentation/http/1.6.0/testing/MockClient-class.html)（查阅：2026-08-30）
- [Fetch Standard: CORS protocol](https://fetch.spec.whatwg.org/#http-cors-protocol)（查阅：2026-08-30）
