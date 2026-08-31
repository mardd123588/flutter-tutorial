---
title: 异步状态、缓存失效与组合
description: 用 AsyncNotifier、family、自动释放和失效 API 管理异步状态、参数化缓存与 provider 依赖图。
part: 6
order: 5
kind: concept
requires:
  - riverpod.provider
  - async.ui-state
  - data.cache
provides:
  - riverpod.async-notifier
  - riverpod.family
  - riverpod.invalidation
  - riverpod.disposal
status: verified
---

# 异步状态、缓存失效与组合

同步 Notifier 只需要发布当前状态。异步数据还要表达首次加载、旧值刷新、失败、重试和参数变化后的缓存身份。Riverpod 用 `AsyncValue` 描述执行状态，用 provider 依赖图决定重新计算。

Repository 仍是业务数据的单一事实来源。provider 的缓存用于组合和复用异步读取，不替代数据库、HTTP 缓存或 Repository 策略。

## AsyncNotifier 分开初始化与用户动作

```dart
class BulletinController extends AsyncNotifier<List<Bulletin>> {
  @override
  Future<List<Bulletin>> build() {
    return ref.watch(repositoryProvider).load();
  }

  Future<void> refresh() async {
    ref.invalidateSelf();
    await future;
  }

  Future<void> archive(String id) async {
    final repository = ref.read(repositoryProvider);
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await repository.archive(id);
      return repository.load(forceRefresh: true);
    });
  }
}

final bulletinsProvider =
    AsyncNotifierProvider<BulletinController, List<Bulletin>>(
      BulletinController.new,
    );
```

`build()` 定义 provider 如何得到初始值以及依赖哪些 provider。`archive()` 是用户动作，负责写入并发布动作后的状态。不要在 Widget 的 `onPressed` 里复制 loading、try/catch 和刷新流程。

这个简例在归档期间进入完整 loading。若产品要求旧列表保持可见，应把“列表数据”和“归档命令状态”分开建模；不要调用 Riverpod 标为内部 API 的 `copyWithPrevious`。由 `invalidate` 触发的重新计算会保留上一次值，UI 可通过 `isRefreshing` 区分刷新与首次加载。

## AsyncValue 描述执行状态，不替代 Result

```dart
final asyncItems = ref.watch(bulletinsProvider);

return asyncItems.when(
  data: (items) => BulletinList(items: items),
  loading: () => const BulletinSkeleton(),
  error: (error, stackTrace) => RetryPane(
    onRetry: () => ref.invalidate(bulletinsProvider),
  ),
);
```

`AsyncValue` 的 error 分支适合未预期异常和加载失败。时间冲突、容量不足等可预期业务结果仍应通过 Result 或 typed failure 返回，不要故意 `throw` 成 provider 崩溃。

刷新时常同时存在旧值与 loading 标记。产品可以保留列表并显示细小刷新状态；首次加载没有旧值时再显示完整 loading 页面。

## Riverpod 3 默认会自动重试

Riverpod 3 对 provider 失败默认执行自动重试。若页面已经提供明确重试入口，或测试需要确定次数，可在 provider 或根 `ProviderScope` 显式配置：

```dart
Duration? noProviderRetry(int retryCount, Object error) => null;

final bulletinsProvider =
    AsyncNotifierProvider<BulletinController, List<Bulletin>>(
      BulletinController.new,
      retry: noProviderRetry,
    );
```

默认策略不等于所有失败都值得重试。认证失败、参数非法和业务冲突通常应直接返回稳定失败；暂时性网络或存储错误才可能进入有上限的重试策略。

## family 把参数变成缓存身份

同一个查询逻辑会随筛选参数变化。family 为每组参数建立独立 provider 实例：

```dart
class BulletinQuery {
  const BulletinQuery({this.zone, this.openOnly = false});

  final String? zone;
  final bool openOnly;

  @override
  bool operator ==(Object other) {
    return other is BulletinQuery &&
        other.zone == zone &&
        other.openOnly == openOnly;
  }

  @override
  int get hashCode => Object.hash(zone, openOnly);
}

final filteredBulletinsProvider = FutureProvider.autoDispose
    .family<List<Bulletin>, BulletinQuery>((ref, query) {
      return ref.watch(repositoryProvider).loadQuery(query);
    });
```

参数必须有稳定的 `==` 与 `hashCode`。每次 build 都创建一个默认 identity 的可变对象，会不断得到新缓存实例。

family 没有“查询全部实例”的魔法。`filteredBulletinsProvider(queryA)` 与 `filteredBulletinsProvider(queryB)` 是两个明确实例，失效时也要区分单个实例和整组实例。

## 自动释放管理参数化订阅

`autoDispose` provider 在最后一个监听者离开后等待一个 frame；期间没有新监听者才释放。它适合搜索参数、详情 ID 和数据库查询流，避免用户浏览过的每个参数永久留在内存。

```dart
final streamProvider = StreamProvider.autoDispose
    .family<List<Bulletin>, BulletinQuery>((ref, query) {
      final subscription = analytics.watchQuery(query);
      ref.onDispose(subscription.close);
      return repository.watch(query);
    });
```

`ref.onCancel` 表示最后一个监听者离开，`ref.onResume` 表示在释放前恢复监听，`ref.onDispose` 才是最终销毁。释放回调只清理资源，不应再修改其他 provider。

对 WebSocket、Timer、StreamSubscription 等资源，要明确谁创建、谁释放。Repository 返回的 Stream 若已经在取消监听时释放底层资源，provider 不需要重复关闭同一个对象。

## watch 组成依赖图

```dart
final selectedZoneProvider = NotifierProvider<ZoneController, String?>(
  ZoneController.new,
);

final visibleCountProvider = Provider<int>((ref) {
  final zone = ref.watch(selectedZoneProvider);
  final items = ref.watch(
    filteredBulletinsProvider(BulletinQuery(zone: zone)),
  );
  return items.value?.length ?? 0;
});
```

上游变化后，下游重新计算。不要在每个动作结束后手工刷新整棵树；先让依赖关系表达谁真正依赖谁。

## invalidate 与 refresh 表达数据失效

```dart
ref.invalidate(filteredBulletinsProvider(query));
```

`invalidate` 标记当前实例失效。有监听者时会重新计算，没有监听者时在下次读取再创建。

```dart
final items = await ref.refresh(
  filteredBulletinsProvider(query).future,
);
```

`refresh` 等价于失效后立即读取，适合调用方确实需要等待新值。若 Drift 查询 Stream 会在写入后自行发出最新结果，就不要再冗余 invalidate；否则会造成额外查询和难解释的 loading 状态。

## select 只能解决测量到的重建

```dart
final count = ref.watch(
  bulletinsProvider.select((value) => value.value?.length ?? 0),
);
```

`select` 只在选中值按 `==` 变化时通知消费者。选中可变 List 后原地修改，仍可能漏通知。先用 DevTools 或 build 计数确认无关重建，再收窄订阅；默认 `watch` 往往更清楚。

异步派生可使用 `selectAsync`，但它同样不是“更高级的写法”，只在实际订阅面过宽时使用。

## 可验证任务

做一个参数化公告查询：

- `AsyncNotifier` 首次加载并支持用户刷新；
- 刷新时保留旧列表，首次加载显示完整 loading；
- family 使用不可变 `BulletinQuery`；
- 不同 zone 拥有独立缓存；
- 自动释放后底层订阅关闭；
- Repository Stream 写入后主动更新时，不额外 invalidate；
- 显式关闭默认 retry，并提供一次用户触发的重试。

记录 `select` 前后的重建次数；没有可测收益就保留普通 `watch`。

## 常见误区

- 把 provider 缓存当成持久化存储。
- 用 `throw` 表达正常业务冲突。
- family 参数没有稳定 equality。
- 认为 auto-dispose 在离开瞬间同步销毁。
- 写入 Stream 数据后又无条件 invalidate 同一查询。
- 把 `refresh` 理解为清空所有 family 实例。
- 没有测量就大量使用 `select`。

## 复习线索

- `AsyncNotifier.build()` 管初始化，方法管用户动作。
- `AsyncValue` 可以同时保留旧值和 loading/error 状态；Result 继续表达业务失败。
- family 参数决定缓存身份，auto-dispose 管参数实例的生命周期。
- `watch` 建依赖图，`invalidate` 标失效，`refresh` 失效后立即读取。

## 参考资料

- [Riverpod AsyncNotifierProvider](https://pub.dev/documentation/riverpod/3.4.2/riverpod/AsyncNotifierProvider-class.html)（查阅：2026-08-30）
- [Riverpod family](https://riverpod.dev/docs/concepts2/family)（查阅：2026-08-30）
- [Riverpod automatic disposal](https://riverpod.dev/docs/concepts2/auto_dispose)（查阅：2026-08-30）
- [Riverpod automatic retry](https://riverpod.dev/docs/concepts2/retry)（查阅：2026-08-30）
- [Riverpod refs](https://riverpod.dev/docs/concepts2/refs)（查阅：2026-08-30）
