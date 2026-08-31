---
title: Riverpod 3 基础
description: 从所有者、订阅和生命周期理解 ProviderScope、ProviderContainer、Ref、Provider 与 NotifierProvider。
part: 6
order: 4
kind: concept
requires:
  - state.inherited
  - state.change-notifier
  - architecture.udf
provides:
  - riverpod.provider
  - riverpod.ref
  - riverpod.notifier
  - riverpod.scope
status: verified
---

# Riverpod 3 基础

第三部分已经用 `InheritedWidget` 处理跨层获取，用 `ChangeNotifier` 处理通知。Riverpod 仍要回答同样的问题：状态由谁保存，消费者在哪里订阅，依赖如何创建，对象何时释放。

本教程固定使用 `flutter_riverpod 3.4.2`。Riverpod 3 已把 `StateProvider`、`StateNotifierProvider` 和 `ChangeNotifierProvider` 移到 `legacy.dart`；新代码使用 Notifier API。

## provider 是声明，container 才保存状态

```dart
final clockProvider = Provider<DateTime Function()>((ref) {
  return DateTime.now;
});
```

`clockProvider` 是不可变声明，描述如何得到一个值。真正的实例和缓存保存在 `ProviderContainer` 中。

Flutter 应用通常由 `ProviderScope` 创建并暴露 container：

```dart
void main() {
  runApp(const ProviderScope(child: App()));
}
```

两个独立 `ProviderContainer` 读取同一个 provider，可以得到两份彼此隔离的状态。顶层 provider 变量因此不是“全局可变单例”。

## Provider 适合创建只读依赖

Repository 和 Service 通常先用普通 `Provider` 接线：

```dart
final serviceProvider = Provider<BulletinService>(
  (ref) => FixtureBulletinService(),
);

final repositoryProvider = Provider<BulletinRepository>((ref) {
  return LocalBulletinRepository(ref.watch(serviceProvider));
});
```

`ref.watch(serviceProvider)` 建立依赖边。若 Service 实例变化，Repository provider 会重新计算。接口和构造函数仍定义架构边界，Riverpod 只接管对象图。

## Notifier 是 ViewModel 的一种实现

```dart
class FilterState {
  const FilterState({this.query = '', this.onlyOpen = false});

  final String query;
  final bool onlyOpen;

  FilterState copyWith({String? query, bool? onlyOpen}) {
    return FilterState(
      query: query ?? this.query,
      onlyOpen: onlyOpen ?? this.onlyOpen,
    );
  }
}

class FilterController extends Notifier<FilterState> {
  @override
  FilterState build() => const FilterState();

  void setQuery(String value) {
    state = state.copyWith(query: value);
  }

  void toggleOpen() {
    state = state.copyWith(onlyOpen: !state.onlyOpen);
  }
}

final filterProvider = NotifierProvider<FilterController, FilterState>(
  FilterController.new,
);
```

`build()` 创建初始状态并可读取其他 provider。方法表达用户意图，`state =` 发布新的不可变状态。不要把每个字段拆成一个 provider，也不要让 Widget 直接写 `state`。

## ConsumerWidget 用 Ref 读取 container

```dart
class FilterBar extends ConsumerWidget {
  const FilterBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(filterProvider);

    return SwitchListTile(
      title: Text(filter.onlyOpen ? '只看开放项目' : '查看全部项目'),
      value: filter.onlyOpen,
      onChanged: (_) => ref.read(filterProvider.notifier).toggleOpen(),
    );
  }
}
```

渲染依赖使用 `watch`，事件回调通常使用 `read` 取得 notifier。为了“减少重建”把 build 里的 `watch` 改成 `read`，会直接失去订阅；真正需要收窄订阅时，先测量，再使用后续章节的 `select`。

Stateful 页面使用 `ConsumerStatefulWidget` 与 `ConsumerState`。局部 `TextEditingController`、`FocusNode` 和动画 controller 仍由 State 创建并释放，不必迁入 provider。

## watch、read、listen 各管一件事

| API | 用途 | 常见位置 |
| --- | --- | --- |
| `watch` | 订阅并在变化时重新计算 | build、provider 的 build |
| `read` | 读取当前值，不订阅 | 点击、提交等事件回调 |
| `listen` | 状态变化时执行副作用 | SnackBar、导航、焦点反馈 |

```dart
ref.listen(saveStateProvider, (previous, next) {
  if (next case SaveSucceeded()) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('已保存')),
    );
  }
});
```

这里假设 `saveStateProvider` 和 `SaveSucceeded` 已在状态层定义；片段只说明 `listen` 的使用位置。

副作用仍要避免重复消费，并检查当前 Widget 是否适合执行导航或焦点变化。`listen` 不是把 View 责任搬进 provider 的理由。

## Scope 可以覆盖一棵子树

应用根部通常只有一个 `ProviderScope`。较小的子 scope 可用于测试、预览或确实需要隔离状态的功能：

```dart
ProviderScope(
  child: PreviewPane(),
)
```

不要随手给每个页面套 scope。新的 scope 意味着新的 container 边界，可能让读者以为状态应该共享，实际却得到两份实例。

## 与 ChangeNotifier 的对应关系

| ChangeNotifier 方案 | Riverpod 方案 |
| --- | --- |
| 外部创建并传入 notifier | provider 声明创建逻辑 |
| `notifyListeners()` | `state = newState` |
| `ListenableBuilder` | `ref.watch` |
| 所有者调用 `dispose()` | container 根据 provider 生命周期释放 |
| 构造函数替换依赖 | provider override，下一章后再展开 |

迁移的目标是保持状态类型、用户动作和测试断言不变，只替换创建、订阅与生命周期机制。`ChangeNotifier` 仍是 Flutter 支持的 SDK 方案；小范围状态、SDK 对接和渐进迁移继续可以使用。

## Riverpod 3 的几个版本边界

- `Ref` 不再带 provider 类型泛型；
- 不再使用 `ProviderRef`、`FutureProviderRef` 等专用 Ref 子类；
- 不再使用 `AutoDisposeNotifier`、`FamilyNotifier` 等专用基类；
- family 与自动释放功能仍存在，只是统一到 provider 参数和声明方式；
- 本章不引入 hooks、legacy providers、family、auto-dispose 或代码生成。

看到旧文章里的 `StateNotifierProvider` 或带泛型 `Ref` 时，先按 Riverpod 3 迁移文档核对。

## 可验证任务

把一个已有的 `ChangeNotifier` 筛选功能等价迁移到 Riverpod：

- 保留同一个不可变 `FilterState`；
- 用 `NotifierProvider` 管 query 和 onlyOpen；
- build 里用 `watch`，按钮回调用 `read`；
- 用 `listen` 观察一次明确的状态变化并显示反馈；
- 根部只放一个 `ProviderScope`；
- 迁移前后的 Widget 测试断言保持一致。

不要在这一步加入异步加载、family、override 或生成代码。

## 常见误区

- 把 provider 顶层变量理解为全局可变单例。
- 在所有按钮和 build 中都用 `watch`。
- 为了少重建，把应该订阅的值改成 `read`。
- 把 `TextEditingController`、`FocusNode` 等局部资源全部移进 provider。
- 把 Riverpod 当成应用架构本身。
- 从旧教程复制 legacy provider 或旧版 Ref 类型。

## 复习线索

- provider 描述创建方式，container 保存实例与状态，`ProviderScope` 暴露 container。
- `watch` 管渲染依赖，`read` 管事件读取，`listen` 管展示副作用。
- Notifier 可以实现 ViewModel，但不会自动决定 Repository 与 Service 边界。
- Riverpod 3 统一了 Ref、Notifier、family 和 auto-dispose 接口，旧资料要先核版本。

## 参考资料

- [Riverpod 3.4.2 package](https://pub.dev/packages/riverpod/versions/3.4.2)（查阅：2026-08-30）
- [flutter_riverpod 3.4.2 package](https://pub.dev/packages/flutter_riverpod/versions/3.4.2)（查阅：2026-08-30）
- [Riverpod providers](https://riverpod.dev/docs/concepts2/providers)（查阅：2026-08-30）
- [Riverpod refs](https://riverpod.dev/docs/concepts2/refs)（查阅：2026-08-30）
- [Riverpod 3 migration](https://riverpod.dev/docs/3.0_migration)（查阅：2026-08-30）
- [Flutter architecture recommendations](https://docs.flutter.dev/app-architecture/recommendations)（查阅：2026-08-30）
