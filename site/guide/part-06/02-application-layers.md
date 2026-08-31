---
title: View、ViewModel、Repository、Service
description: 用普通构造函数逐层分开界面、页面状态、数据策略和外部数据源，并判断何时才需要 domain 层。
part: 6
order: 2
kind: concept
requires:
  - architecture.udf
  - data.service
provides:
  - architecture.view
  - architecture.viewmodel
  - architecture.repository
  - architecture.service
status: verified
---

# View、ViewModel、Repository、Service

分层先回答“谁负责什么”。状态管理包只负责把对象接起来、保存状态和通知订阅者，不能替你决定缓存、错误映射或业务规则放在哪里。

本章先用普通 Dart 接口、构造函数和 `ChangeNotifier`。下一章再处理 Result 与命令，之后才接入 Riverpod。

## 四个责任边界

```text
View
  ↓ 用户意图      ↑ UI state
ViewModel
  ↓ 数据操作      ↑ model
Repository
  ↓ 原始读写      ↑ raw data
Service
```

| 层 | 负责 | 不负责 |
| --- | --- | --- |
| View | Widget、布局、输入、导航、焦点、文案 | SQL、缓存策略、业务规则 |
| ViewModel | 页面状态、筛选、排序、动作入口 | 打开数据库、依赖 `BuildContext` |
| Repository | 单一事实来源、缓存、模型转换、刷新策略 | 布局、SnackBar、路由 |
| Service | 适配一个 HTTP、数据库或平台数据源 | 页面 loading、跨数据源业务组合 |

这里的 View 是一个功能的 Widget 组合，不要求每个叶子 Widget 都配一个 ViewModel。

## Service 只适配一个数据源

先从最低层提取外部访问：

```dart
abstract interface class BulletinService {
  Future<List<Map<String, Object?>>> fetchRows();
}

class FixtureBulletinService implements BulletinService {
  @override
  Future<List<Map<String, Object?>>> fetchRows() async {
    return const [
      {'id': 'notice-1', 'title': '周末工具共享'},
      {'id': 'notice-2', 'title': '河岸清理报名'},
    ];
  }
}
```

Service 返回外部边界的数据形状。它不保存“当前页面选中了哪条”，也不决定失败后是否显示重试按钮。

每个数据源一个 Service 是好用的默认值。REST endpoint、本地文件、Drift 数据库和平台插件都属于外部边界；不用为了“层次整齐”给每个方法单独建 Service。

## Repository 管数据策略

Repository 把原始数据转换成应用模型，并决定缓存和刷新：

```dart
class Bulletin {
  const Bulletin({required this.id, required this.title});

  final String id;
  final String title;
}

abstract interface class BulletinRepository {
  Future<List<Bulletin>> load({bool forceRefresh = false});
}

class LocalBulletinRepository implements BulletinRepository {
  LocalBulletinRepository(this.service);

  final BulletinService service;
  List<Bulletin>? _cache;

  @override
  Future<List<Bulletin>> load({bool forceRefresh = false}) async {
    if (!forceRefresh && _cache case final cached?) return cached;

    final rows = await service.fetchRows();
    final bulletins = rows
        .map(
          (row) => Bulletin(
            id: row['id']! as String,
            title: row['title']! as String,
          ),
        )
        .toList(growable: false);
    _cache = bulletins;
    return bulletins;
  }
}
```

调用方只知道 `BulletinRepository`。fixture、HTTP 或数据库实现可以替换，ViewModel 的接口不变。

Repository 不应互相调用。需要合并两个 Repository 的简单规则，先放进使用它们的 ViewModel；组合复杂且被多个 ViewModel 重复时，再提取 domain use-case。

## ViewModel 把模型整理成页面状态

这一版先用读者已经学过的 `ChangeNotifier`：

```dart
class BulletinListViewModel extends ChangeNotifier {
  BulletinListViewModel(this.repository);

  final BulletinRepository repository;

  List<Bulletin> _items = const [];
  bool _loading = false;
  Object? _error;

  List<Bulletin> get items => _items;
  bool get loading => _loading;
  Object? get error => _error;

  Future<void> load({bool forceRefresh = false}) async {
    if (_loading) return;
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      _items = await repository.load(forceRefresh: forceRefresh);
    } on Object catch (error) {
      _error = error;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }
}
```

这段代码先展示责任位置，错误仍是 `Object?`。下一章会把可预期失败改为 sealed Result，并把动作状态收进 Command。

ViewModel 不接收 `BuildContext`。它发布状态和动作结果，View 再决定显示哪段文字、把焦点移到哪里、是否导航。

## View 只渲染并转交意图

```dart
class BulletinListView extends StatelessWidget {
  const BulletinListView({required this.viewModel, super.key});

  final BulletinListViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: viewModel,
      builder: (context, child) {
        if (viewModel.loading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (viewModel.error != null) {
          return FilledButton(
            onPressed: () => viewModel.load(forceRefresh: true),
            child: const Text('重新加载'),
          );
        }
        return ListView(
          children: [
            for (final item in viewModel.items) ListTile(title: Text(item.title)),
          ],
        );
      },
    );
  }
}
```

View 可以根据宽度换布局，可以做导航与焦点反馈，也可以保存输入框草稿。它不应该解析 Service 返回的 Map，也不直接修改 Repository 缓存。

## 构造函数先把对象图接清楚

```dart
final service = FixtureBulletinService();
final repository = LocalBulletinRepository(service);
final viewModel = BulletinListViewModel(repository);

runApp(BulletinListView(viewModel: viewModel));
```

这已经是依赖注入：对象不在内部偷偷创建，而是从构造函数传入。Riverpod 后面会接管创建、作用域、释放和测试替换，依赖方向仍由这些接口决定。

测试也按同一接缝分开：

- ViewModel 测试替换 Repository；
- Repository 测试替换 Service；
- Widget 测试复用 fake Repository 或构造好的 ViewModel；
- Service 测试只验证外部边界的解析与错误。

## domain 层按三条条件增加

多数 CRUD 不需要 use-case。满足下面任一条件并持续造成重复时，再增加 domain 层：

- 一个动作需要组合多个 Repository；
- 业务规则本身明显复杂；
- 同一规则被多个 ViewModel 复用。

纯冲突检测、计价、资格判断适合成为 domain policy 或纯函数。仅仅把 `repository.save()` 包一层同名 `SaveUseCase.call()`，没有增加边界价值。

## 可验证任务

把一个活动公告页面分成四层，保持原 Widget 测试的可见行为不变：

- Fixture Service 返回原始 Map；
- Repository 转成不可变模型，并缓存最近一次成功结果；
- `ChangeNotifier` ViewModel 暴露 loading、data、error 和刷新动作；
- View 只显示状态并转交刷新意图；
- Repository 测试使用 fake Service，ViewModel 测试使用 fake Repository。

完成后尝试把 fixture Service 换成另一个实现。View 与 ViewModel 不应修改。

## 常见误区

- 把 Service 和 Repository 当作两个名字相近的转发层。
- 让 Repository 互相调用，形成隐含依赖图。
- 每个按钮、Widget 或 Repository 方法都创建 use-case。
- 在 ViewModel 里保存 `BuildContext` 并直接导航。
- 认为用了 Riverpod 才算依赖注入。

## 复习线索

- Service 适配外部数据源，Repository 决定数据策略和单一事实来源。
- ViewModel 把模型整理成页面状态；View 处理布局、输入和展示副作用。
- 构造函数先固定依赖方向，状态容器后接入。
- domain 层只在跨 Repository、复杂规则或复用达到阈值时增加。

## 参考资料

- [Flutter guide to app architecture](https://docs.flutter.dev/app-architecture/guide)（查阅：2026-08-30）
- [Flutter dependency injection case study](https://docs.flutter.dev/app-architecture/case-study/dependency-injection)（查阅：2026-08-30）
- [Flutter testing each layer](https://docs.flutter.dev/app-architecture/case-study/testing)（查阅：2026-08-30）
- [ChangeNotifier API](https://api.flutter.dev/flutter/foundation/ChangeNotifier-class.html)（查阅：2026-08-30）

