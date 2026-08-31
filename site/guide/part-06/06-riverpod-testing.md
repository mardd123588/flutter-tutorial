---
title: 依赖替换与 Riverpod 测试
description: 用 Repository 接缝、ProviderContainer.test、override 和根 ProviderScope 分开测试状态与 Widget。
part: 6
order: 6
kind: concept
requires:
  - riverpod.scope
  - architecture.repository
  - test.widget-smoke
provides:
  - riverpod.override
  - test.provider-container
  - test.fake-repository
status: verified
---

# 依赖替换与 Riverpod 测试

Riverpod 测试的重点不是 mock provider。先把 Repository 定成稳定接口，再在 container 边界替换实现；同一 fake 可以供纯 provider 测试和 Widget 测试使用。

每个测试创建独立 container，避免缓存、监听和异步状态从上一例泄漏。

## fake 保留合同，不复制实现

```dart
class FakeBulletinRepository implements BulletinRepository {
  FakeBulletinRepository({this.items = const [], this.failure});

  final List<Bulletin> items;
  final AppFailure? failure;
  int loadCalls = 0;

  @override
  Future<Result<List<Bulletin>>> load(BulletinQuery query) async {
    loadCalls += 1;
    final error = failure;
    return error == null ? Ok(items) : Failure(error);
  }
}
```

fake 实现同一输入输出合同，并提供测试需要的可观察记录。它不复制真实缓存、SQL 或重试算法；复制得越多，越可能让测试同时复刻同一个错误。

Repository provider 是主要替换接缝：

```dart
final repositoryProvider = Provider<BulletinRepository>((ref) {
  throw UnimplementedError('在应用入口提供实现');
});
```

ViewModel 和派生 provider 继续运行真实代码，只替换最下游依赖。

## ProviderContainer.test 隔离每个测试

```dart
test('loads bulletins from the replacement repository', () async {
  final fake = FakeBulletinRepository(items: const [sampleBulletin]);
  final container = ProviderContainer.test(
    overrides: [repositoryProvider.overrideWithValue(fake)],
  );

  final result = await container.read(
    filteredBulletinsProvider(const BulletinQuery()).future,
  );

  expect(result, isA<Ok<List<Bulletin>>>());
  expect(fake.loadCalls, 1);
});
```

`ProviderContainer.test()` 为测试创建 container，并在测试结束时释放。不要在文件顶层共享一个 container；family 缓存、listener 和 override 会互相影响。

同步 provider 直接 `read`。Future / Stream provider 通常读取 `.future`，让测试等待明确的第一个异步结果，而不是用任意 `pump(Duration)` 猜完成时间。

## 自动释放 provider 要在等待期间保活

只调用 `read` 后，auto-dispose provider 可能在异步完成前失去监听。测试持续订阅：

```dart
test('keeps an auto-dispose query alive', () async {
  final container = ProviderContainer.test(
    overrides: [repositoryProvider.overrideWithValue(fakeRepository)],
  );
  final provider = filteredBulletinsProvider(const BulletinQuery());
  final subscription = container.listen(provider, (previous, next) {});
  addTearDown(subscription.close);

  final result = await container.read(provider.future);
  expect(result, isA<Ok<List<Bulletin>>>());
});
```

这同时测试真实生命周期。不要为了让测试方便而把生产 provider 改成永久 keep-alive。

## family 测试要证明参数隔离

```dart
final north = filteredBulletinsProvider(
  const BulletinQuery(zone: 'north'),
);
final south = filteredBulletinsProvider(
  const BulletinQuery(zone: 'south'),
);

expect(north, isNot(same(south)));
```

更有价值的断言是让 fake 按 query 返回不同数据，再分别读取两组结果。这样可以发现 equality 错误、参数漏传和错误复用缓存。

## 失效测试观察调用次数和状态

```dart
await container.read(provider.future);
expect(fake.loadCalls, 1);

container.invalidate(provider);
await container.read(provider.future);
expect(fake.loadCalls, 2);
```

如果数据由 Stream 推送，测试应让 fake Stream 发出第二个值，并确认消费者更新，同时断言没有额外 load 调用。失效是产品语义，不是固定模板。

## Widget 测试从根 scope 覆盖

```dart
await tester.pumpWidget(
  ProviderScope(
    overrides: [
      repositoryProvider.overrideWithValue(fakeRepository),
    ],
    child: const App(),
  ),
);

await tester.pumpAndSettle();
expect(find.text('周末工具共享'), findsOneWidget);
```

Widget 仍不知道 fake 的存在。测试可以通过 `tester.container()` 读取根 scope 的 provider 状态：

```dart
final container = tester.container();
expect(container.read(filterProvider).onlyOpen, isFalse);
```

优先断言用户可见行为；读取 container 适合验证纯 UI 很难观察的边界，例如动作只调用一次或某个 provider 已失效。

## 测哪一层

| 目标 | 替换 | 主要断言 |
| --- | --- | --- |
| domain policy | 不替换 | 纯输入输出和边界 |
| Repository | fake Service / 内存数据库 | 映射、缓存、事务、failure |
| ViewModel / provider | fake Repository | 状态转换、动作、防重复、失效 |
| View | 根 scope override | loading、data、error、焦点和操作 |

不要 mock Notifier 的方法再断言 Widget 调了它。这样只证明测试里的 mock 配置，没有证明真实状态转换。也不要让 Widget 测试直接操作数据库来绕开 Repository 接缝。

## 异步测试避免真实等待

fake 用 `Completer` 控制完成时机：

```dart
final completer = Completer<Result<List<Bulletin>>>();
fake.nextLoad = completer.future;

final future = container.read(provider.future);
expect(container.read(provider).isLoading, isTrue);

completer.complete(const Ok([sampleBulletin]));
expect(await future, isA<Ok<List<Bulletin>>>());
```

自动 retry 也应换成确定策略，或在 provider 上关闭。测试不依赖真实退避时间，才能稳定判断尝试次数和终止条件。

## 可验证任务

为上一章的参数化公告功能补两层测试：

- `ProviderContainer.test()` 替换 Repository，覆盖成功、失败和重试；
- 两个 query 返回不同数据，证明 family 缓存隔离；
- `listen` 保活 auto-dispose provider，关闭订阅后验证资源释放；
- Stream 更新不调用冗余 invalidate；
- Widget 根 scope 注入同一个 fake，覆盖 loading、data、empty、error 和刷新按钮；
- 连续点击同一动作，fake 只记录一次调用。

每例独立创建 container，不使用共享全局 fake。

## 常见误区

- mock Notifier，再断言 Widget 调用了 mock 方法。
- 测试之间共享 `ProviderContainer`。
- 为避免 auto-dispose 测试困难，把生产缓存改成永久保留。
- 用固定延迟等待 Future 或 retry。
- fake 复制真实 Repository 的缓存与错误。
- Widget 测试越过 Repository 直接操作数据库。

## 复习线索

- 主要替换接缝是 Repository provider，不是 Notifier。
- `ProviderContainer.test()` 让每例拥有独立缓存、监听和 override。
- auto-dispose 异步测试用 `listen` 保活，完成后关闭订阅。
- provider 测状态转换，Widget 测用户可见行为；Repository 与 domain 各有自己的边界测试。

## 参考资料

- [Riverpod testing](https://riverpod.dev/docs/how_to/testing)（查阅：2026-08-30）
- [ProviderContainer 3.4.2 API](https://pub.dev/documentation/riverpod/3.4.2/riverpod/ProviderContainer-class.html)（查阅：2026-08-30）
- [Riverpod provider overrides](https://riverpod.dev/docs/concepts2/overrides)（查阅：2026-09-01）
- [Flutter testing each layer](https://docs.flutter.dev/app-architecture/case-study/testing)（查阅：2026-08-30）
