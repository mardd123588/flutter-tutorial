---
title: 代码生成、包选择与升级边界
description: 在重复明显时使用 Riverpod 代码生成，并用版本、平台、许可、维护和退出成本评估生态包与升级。
part: 6
order: 7
kind: concept
requires:
  - tool.build-runner
  - riverpod.provider
provides:
  - riverpod.codegen-boundary
  - ecosystem.package-evaluation
  - ecosystem.upgrade-boundary
status: verified
---

# 代码生成、包选择与升级边界

Riverpod 的手写声明已经能完成 Provider、Notifier、family 和自动释放。代码生成主要减少 family 与 notifier 的重复类型声明，并允许一个函数直接接收多个命名参数。

是否使用生成器取决于重复量和项目已有工具链，不取决于“生产项目都应该生成”。

## 先看手写 family 的成本

```dart
class BulletinQuery {
  const BulletinQuery({this.dayId, this.zoneId, this.ownerId});

  final String? dayId;
  final String? zoneId;
  final String? ownerId;

  @override
  bool operator ==(Object other) =>
      other is BulletinQuery &&
      other.dayId == dayId &&
      other.zoneId == zoneId &&
      other.ownerId == ownerId;

  @override
  int get hashCode => Object.hash(dayId, zoneId, ownerId);
}

final bulletinsProvider = StreamProvider.autoDispose
    .family<List<Bulletin>, BulletinQuery>((ref, query) {
      return ref.watch(repositoryProvider).watch(query);
    });
```

这段声明清楚、无生成步骤。参数对象本来就是领域概念时，手写 equality 仍有价值。

如果 provider 只为了接三个命名参数而反复创建包装类型，生成器开始有收益。

## generated family 保留普通函数形状

依赖版本固定为：

```yaml
dependencies:
  flutter_riverpod: 3.4.2
  riverpod_annotation: 4.0.6

dev_dependencies:
  build_runner: 2.16.0
  riverpod_generator: 4.0.8
```

源码声明：

```dart
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'bulletin_providers.g.dart';

@riverpod
Stream<List<Bulletin>> filteredBulletins(
  Ref ref, {
  String? dayId,
  String? zoneId,
  String? ownerId,
}) {
  final query = BulletinQuery(
    dayId: dayId,
    zoneId: zoneId,
    ownerId: ownerId,
  );
  return ref.watch(repositoryProvider).watch(query);
}
```

使用时仍是参数化 provider：

```dart
ref.watch(
  filteredBulletinsProvider(
    dayId: selectedDay,
    zoneId: selectedZone,
    ownerId: selectedOwner,
  ),
);
```

生成 provider 默认自动释放。只有明确需要永久保留时才写 `@Riverpod(keepAlive: true)`；不要因为旧资料里的默认值不同就猜。

## 生成与检查

一次生成：

```powershell
dart run build_runner build --delete-conflicting-outputs
```

持续生成：

```powershell
dart run build_runner watch --delete-conflicting-outputs
```

遇到问题按顺序检查：

1. `part` 文件名是否与源文件一致；
2. annotation、generator 与 runtime 版本是否匹配；
3. 是否有旧生成文件或冲突输出；
4. 生成后是否运行 `flutter analyze` 和相关测试；
5. 构建产物是否已按仓库约定提交。

不要手改 `.g.dart`。修改声明，重新生成，再检查 diff。

## 什么时候值得生成

本教程采用三个条件：

- 项目已经使用 build_runner；
- family 有多个反复出现的参数，手写声明明显重复；
- 生成后的调用形式比参数包装更容易读和测。

只有一个简单 `Provider` 或 `NotifierProvider` 时，手写往往更短。全项目同时维护手写与生成两套风格也没问题，前提是边界可解释。

## 选包先看任务，再看指标

评估生态包时按这张表走：

| 维度 | 要核对什么 |
| --- | --- |
| 任务匹配 | 是否解决当前具体问题，能否用 SDK 简单完成 |
| 版本约束 | 最低 Dart / Flutter、Current、Resolvable、Latest |
| 平台 | Web 是否真实构建并跑关键流程，不只看标签 |
| API 稳定性 | changelog、迁移文档、experimental 标记 |
| 维护 | 最近发布、issue 处理、核心维护者与仓库状态 |
| 许可 | 是否允许项目分发与修改，依赖许可是否可接受 |
| 退出成本 | 业务模型是否被包类型绑住，能否从接口边界替换 |

下载量、Pub points 和 Flutter Favorite 都是线索，不能单独决定采用。平台标签来自声明和静态分析，也不能代替 release 构建与真实浏览器测试。

Riverpod 在本教程中的退出成本受接口控制：ViewModel 可以换实现，Repository 与 Service 仍是普通 Dart 接口，业务模型不继承 Riverpod 类型。

## Current、Resolvable、Latest 不一样

运行：

```powershell
flutter pub outdated
```

输出中的三个版本回答不同问题：

- **Current**：锁文件当前使用的版本；
- **Resolvable**：在现有约束和整个依赖图下能解析的最高版本；
- **Latest**：pub.dev 上最新版本，可能超出现有约束或与其他依赖冲突。

看到 Latest 更高，不代表直接改一个版本号就能升级。先读 changelog 与迁移文档，再确认配套 generator、annotation 和 build_runner 组合。

## 一次跨一个可解释边界

升级状态包时，不要同时升级数据库、路由、Flutter SDK 和生成器链。更稳的顺序是：

1. 记录当前 analyze、测试、浏览器流程和 release build 结果；
2. 只改一组紧密配套的依赖；
3. 重新解析并检查 lockfile；
4. 重新生成代码；
5. 运行静态检查、相关单元与 Widget 测试；
6. 在 Web 执行关键流程，再做 release 子路径构建；
7. 检查生成 diff 和行为变化后再提交。

本教程的 Riverpod runtime 是 3.4.2，配套 annotation 是 4.0.6、generator 是 4.0.8。包的主版本号不必相同，兼容关系要看各自 pubspec 与实际解析结果。

## 实验功能单独设边界

Riverpod offline persistence 与 Mutations 在当前文档中仍标为 experimental。本教程不把它们放进正式数据路径：持久化继续交给 Drift，业务写入继续通过 Repository 与 Result。

实验功能可以做隔离探针，但不能在没有迁移、退出和失败策略时成为统筹项目的唯一实现。

## 可验证任务

选择一个已有的三参数 family：

- 保留一份手写版本，记录参数对象和声明代码量；
- 用 `@riverpod` 改写同一查询，确认默认 auto-dispose；
- 运行 build_runner、analyze 和 provider 测试；
- 用 `flutter pub outdated` 记录 Current、Resolvable、Latest；
- 检查 runtime、annotation、generator、build_runner 的兼容约束；
- 构建 release Web，并在浏览器跑一次参数切换和返回流程；
- 写下如果移除 Riverpod，需要修改哪些文件。

若生成版没有明显减少重复，保留手写版本。

## 常见误区

- 为所有 provider 开启代码生成。
- 手动修改 `.g.dart`。
- 认为 runtime 3.x 必须配 generator 3.x。
- 认为 generated provider 默认永久保留。
- 只看下载量或平台标签选包。
- 把 Latest 当作当前依赖图可直接升级的版本。
- 一次升级 SDK、状态包、数据库和路由，再靠失败定位问题。
- 把 experimental 功能放进唯一数据路径。

## 复习线索

- 代码生成解决重复声明，不改变 provider、container 和依赖图原理。
- generated provider 默认 auto-dispose，keepAlive 必须显式选择。
- 包选择要核任务、版本、平台、许可、维护与退出成本。
- Current、Resolvable、Latest 回答不同问题；升级一次跨一个可解释边界。

## 参考资料

- [Riverpod code generation](https://riverpod.dev/docs/concepts/about_code_generation)（查阅：2026-08-30）
- [riverpod_annotation 4.0.6](https://pub.dev/packages/riverpod_annotation/versions/4.0.6)（查阅：2026-08-30）
- [riverpod_generator 4.0.8](https://pub.dev/packages/riverpod_generator/versions/4.0.8)（查阅：2026-08-30）
- [build_runner 2.16.0](https://pub.dev/packages/build_runner/versions/2.16.0)（查阅：2026-08-30）
- [Dart package dependencies](https://dart.dev/tools/pub/dependencies)（查阅：2026-08-30）
- [dart pub outdated](https://dart.dev/tools/pub/cmd/pub-outdated)（查阅：2026-08-30）
- [Riverpod offline persistence](https://riverpod.dev/docs/concepts2/offline)（查阅：2026-08-30）
- [Riverpod Mutations](https://riverpod.dev/docs/concepts2/mutations)（查阅：2026-08-30）

