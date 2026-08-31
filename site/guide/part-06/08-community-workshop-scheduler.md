---
title: 项目：社区工坊排期台
description: 统筹应用分层、Result、Riverpod、参数化查询、冲突规则、Drift 持久化、响应式界面与 Web 测试。
part: 6
order: 8
kind: capstone
requires:
  - architecture.complexity-signals
  - architecture.ssot
  - architecture.udf
  - architecture.view
  - architecture.viewmodel
  - architecture.repository
  - architecture.service
  - architecture.result
  - architecture.command
  - error.presentation
  - riverpod.provider
  - riverpod.ref
  - riverpod.notifier
  - riverpod.scope
  - riverpod.async-notifier
  - riverpod.family
  - riverpod.invalidation
  - riverpod.disposal
  - riverpod.override
  - test.provider-container
  - test.fake-repository
  - riverpod.codegen-boundary
  - ecosystem.package-evaluation
  - ecosystem.upgrade-boundary
provides:
  - project.community-workshop-scheduler
project: community-workshop-scheduler
status: verified
---

# 项目：社区工坊排期台

社区工坊排期台把这一部分的分层、Result、Riverpod、依赖替换和代码生成放进一个本地 Flutter Web 应用。协调员可以查看两天排期，按活动日、场馆和讲师筛选，新建或编辑场次；保存前一次显示全部冲突，刷新后改动仍保存在当前浏览器。

本章集中讲完整项目。前七章的小例子不依赖它，也没有跨章拆解同一功能。

## 项目简报

### 使用场景

社区活动中心要安排一个固定周末的工坊。场馆、讲师和初始排期由 fixture 提供，不连接网络；协调员调整后的排期写入 Drift。

固定数据包括：

- 2 个活动日；
- 3 个场馆；
- 5 位讲师；
- 8 个工坊；
- 10 条初始排期。

所有场次只能落在 09:00–18:00，表单按 30 分钟步长输入。时间保存为当天分钟数，不做时区换算。

### 功能要求

- 宽屏按日期和场馆显示时间排期墙；窄屏改为分组议程；
- 活动日与场馆筛选写入 URL，讲师筛选保留在当前页面；
- 场次详情使用 `#/sessions/:sessionId`，未知 ID 有独立状态；
- 新建与编辑共用表单和保存逻辑；
- 容量、场馆重叠和讲师重叠一次全部显示；
- 同一保存动作运行时不能重复提交；
- 首次打开 seed 10 条排期，之后保留本地修改；
- “恢复演示数据”先确认，再覆盖当前本地排期；
- 320×720、768×900、1440×900 与 200% 文本下可完成主要任务；
- Web 使用 Hash URL，release 子路径支持详情直达和刷新。

### 明确不做

项目不做账号、云同步、多人实时编辑、权限、报名、支付、删除、拖拽唯一操作、跨时区和外部日历。这里的“本地”表示 Drift 是正式数据源，不表示有离线同步。

Riverpod offline persistence 与 Mutations 仍是 experimental，本项目不使用。数据库迁移和持久化继续由 Drift 管理。

## 架构与三个事实来源

```text
ScheduleBoardPage / WorkshopEditorPage
  ↓ intent                         ↑ immutable state
WorkshopCatalogController / WorkshopEditorController
filteredScheduleProvider
  ↓                                ↑ ScheduleResult
ScheduleRepository
  ├─ ScheduleConflictPolicy
  ├─ WorkshopCatalogService → fixture
  └─ ScheduleStorageService → Drift Web
```

项目没有为了目录完整而给每个动作创建 use-case。冲突规则复杂、需要被新建和编辑复用，所以提取成纯 domain policy；其余组合留在 Repository 和 ViewModel。

三类可写数据各有一个事实来源：

| 数据 | 事实来源 | 说明 |
| --- | --- | --- |
| 活动日、场馆筛选 | URL query | 刷新与 Back / Forward 可恢复 |
| 已保存排期 | Drift / Repository | Widget 不直接写数据库 |
| 编辑草稿 | `WorkshopEditorController` | 保存成功前不冒充正式排期 |

讲师筛选是页面临时状态，不写 URL。它不会改变详情身份，也不要求复制链接后恢复。

## 冲突规则是纯 Dart policy

冲突检测不依赖 Widget、Riverpod 或 Drift：

<<< ../../../examples/capstones/community_workshop_scheduler/lib/src/domain/schedule_conflict_policy.dart#schedule-conflict-policy{dart}

重叠判断采用半开区间：

```dart
candidate.startMinute < entry.endMinute &&
entry.startMinute < candidate.endMinute
```

因此前一场在 10:00 结束、后一场在 10:00 开始时不冲突。`entry.id != candidate.id` 让编辑操作排除自身。

policy 先追加活动日、时间、引用 ID 和容量验证，再按开始时间与 ID 排序已有场次，最后追加场馆和讲师重叠。返回顺序稳定，UI 和测试都能一次看到完整问题，不需要用户逐条试错。

对应单元测试同时固定半开区间和编辑排除自身：

<<< ../../../examples/capstones/community_workshop_scheduler/test/schedule_conflict_policy_test.dart#half-open-self-exclusion-test{dart}

## Result 合同不泄漏底层异常

项目用 sealed 结果和 typed failure 连接 Repository 与状态层：

<<< ../../../examples/capstones/community_workshop_scheduler/lib/src/data/schedule_repository.dart#schedule-result-contract{dart}

验证失败、冲突、记录不存在、目录加载失败和存储失败是不同类型。Failure 不保存中文文案，View 根据类别生成当前界面的说明和恢复动作。

保存流程先加载目录和现有排期，再运行同一 policy：

<<< ../../../examples/capstones/community_workshop_scheduler/lib/src/data/schedule_repository.dart#schedule-repository-save{dart}

纯验证问题返回 `ScheduleValidationFailure`，容量或重叠返回 `ScheduleConflictFailure`。只有没有冲突时才执行 `upsertEntry`，所以“显示三个冲突”不会先写入一部分数据。

Repository 只捕获 `Exception` 并映射为基础设施 failure。`StateError`、类型错误和不变量破坏继续抛出，测试会明确区分这两条路径。

## fixture Service 与 Drift 各管一类数据

`FixtureWorkshopCatalogService` 提供只读目录和 10 条初始排期。Drift 只保存可修改的排期记录与 seed 标记。

数据库实现了 `ScheduleStorageService`：

<<< ../../../examples/capstones/community_workshop_scheduler/lib/src/data/schedule_database.dart#drift-schedule-storage{dart}

`ensureSeeded` 在事务中检查 `fixture-seed`，只在首次打开写入 fixture。以后刷新不会覆盖用户调整。

`watchEntries` 把 `ScheduleQuery` 转成 Drift 条件并返回查询 Stream。保存成功后，Drift 自己让当前查询发出新结果，不需要再 invalidate 同一个排期 provider。

“恢复演示数据”在一个事务里清空排期、重写 10 条 fixture，并恢复 seed 标记。UI 在调用前弹出确认，因为这个动作会覆盖当前浏览器里的项目数据。

Web 默认连接显式声明 `sqlite3.wasm` 与 `drift_worker.js`。两个资产随项目构建，并与 `drift 2.34.3` / `drift_flutter 0.3.1` 保持同一版本链路。

## Riverpod 对象图按收益混用手写与生成

Service、数据库和 Repository 使用手写 `Provider`；目录使用 `AsyncNotifier`；详情使用 auto-dispose family；三参数排期查询是唯一 generated family：

<<< ../../../examples/capstones/community_workshop_scheduler/lib/src/state/schedule_providers.dart#schedule-provider-graph{dart}

数据库由 provider 创建，`ref.onDispose(database.close)` 明确释放连接。Repository provider 组合两个 Service 和纯 policy，也是测试时的主要 override 接缝。

`WorkshopCatalogController` 负责首次加载和失败重试。`filteredScheduleProvider` 接收活动日、场馆、讲师三个命名参数，内部构造不可变 `ScheduleQuery`，默认自动释放；页面离开后，Drift 查询监听也会结束。

这里只生成一处代码。其余声明手写更短，也更容易直接看出对象图。

## 编辑 Controller 管草稿与保存命令状态

编辑页使用 auto-dispose Notifier：

<<< ../../../examples/capstones/community_workshop_scheduler/lib/src/state/schedule_providers.dart#workshop-editor-viewmodel{dart}

`begin` 建立表单草稿，`update` 发布新草稿。`save` 先检查 `state.isSaving`，连续点击不会重复调用 Repository。

异步返回前页面可能已经离开，所以写回状态前检查 `ref.mounted`。保存成功发布 `savedEntry`；验证或冲突失败保留原草稿，并把全部冲突放进 state。Widget 只读取状态，不复制 Repository 规则。

这里没有通用 Command 类，因为单个 Notifier 只有一个保存动作；`isSaving + failure + savedEntry` 已经构成明确命令状态。若同一模式在多个 ViewModel 重复，再提取通用 Command 才有收益。

## URL 恢复筛选，路由恢复页面身份

路由表集中声明主页、新建、编辑和详情：

<<< ../../../examples/capstones/community_workshop_scheduler/lib/src/ui/community_workshop_scheduler_app.dart#workshop-scheduler-router{dart}

主页地址示例：

```text
#/schedule?day=day-sat&venue=venue-forge
```

主页从 `state.uri` 读取 day 与 venue。用户切换这两个筛选时调用 `context.go` 写回 query，因此浏览器 Back / Forward 能恢复筛选。新建页继承当前 day 和 venue，减少重复输入。

详情身份只放在 path：

```text
#/sessions/session-01
```

路由匹配但本地记录不存在时，详情 provider 返回 `ScheduleNotFoundFailure`，页面解释 ID 可能已被恢复演示数据覆盖；完全无法匹配的地址进入统一路由错误页。

## 同一数据切换排期墙与议程

内容区在 980px 处替换布局：

<<< ../../../examples/capstones/community_workshop_scheduler/lib/src/ui/schedule_board_page.dart#responsive-schedule-content{dart}

宽屏排期墙按活动日分区、按场馆分列，时间轴显示 09:00–18:00。窄屏议程按活动日和时间排序，保留场馆、讲师和人数。

两种布局都接收同一个 `WorkshopCatalog` 和同一组 `ScheduleEntry`，没有各自保存筛选或排期。断点由时间列和场馆标题能否读清决定，不按“手机 / 平板”设备名切换。

页头在 720px 以下上下排列，筛选区在 680px 以下改为单列，编辑表单在 660px 以下改单列。页面可以增高并滚动，320px 和 200% 文本下不靠压低缩放解决溢出。

## 冲突一次显示，并把焦点送到摘要

保存失败后，编辑页在下一帧请求 `_conflictSummaryFocus`。摘要同时提供持续可见文本、live region 和每条问题的修复动作：

<<< ../../../examples/capstones/community_workshop_scheduler/lib/src/ui/session_pages.dart#conflict-summary{dart}

容量冲突的“调整人数”把焦点送回预计人数输入框；场馆和讲师重叠提供“查看场次”，打开相关详情。窄屏下动作移到文字下方，错误原因和恢复入口都不会消失。

颜色只增强识别。Semantics label 会宣布冲突数量，标题、详情和按钮文字仍完整说明问题。

Widget 测试同时断言三类冲突只出现一次，并确认焦点已经落到摘要：

<<< ../../../examples/capstones/community_workshop_scheduler/test/community_workshop_scheduler_app_test.dart#scheduler-conflict-focus-test{dart}

## 测试分层覆盖不同风险

项目目前有 25 条 Unit / Widget 测试：

- domain policy：场馆、讲师、容量、多冲突顺序、半开区间和编辑排除自身；
- Repository：冲突不写入、Drift 风格 Stream 更新、恢复数据、Exception 映射和 Error 继续抛出；
- Drift：首次 seed 与查询；
- Riverpod：Repository override、query 参数隔离、保存状态；
- Widget：loading、empty、failure、未知详情、冲突焦点、URL 筛选、三种尺寸和 200% 文本。

响应式测试对同一份数据分别渲染宽屏与窄屏：

<<< ../../../examples/capstones/community_workshop_scheduler/test/community_workshop_scheduler_app_test.dart#scheduler-responsive-test{dart}

Chrome 集成测试完成以下流程：从筛选后的排期进入详情并返回；新建同时触发容量、场馆和讲师冲突；修正场馆与时间后保存；关闭并重新打开应用，确认 Drift 中的新排期仍在。

浏览器还人工检查了 1440×900、768×900、320×720、详情深链接、手机编辑页、Back / Forward 和 release 子路径硬刷新。本项目不维护 golden；它的首要风险是状态、规则和数据流，视觉仍通过实际截图和三档尺寸检查。

## 运行与检查

项目路径：`examples/capstones/community_workshop_scheduler`。

```powershell
cd examples/capstones/community_workshop_scheduler
flutter analyze
flutter test
flutter run -d chrome
```

ChromeDriver 在 4444 端口运行后执行：

```powershell
flutter drive -d web-server --browser-name=chrome --driver=test_driver/integration_test.dart --target=integration_test/community_workshop_scheduler_test.dart
```

GitHub Pages 预览构建：

```powershell
flutter build web --release --base-href /flutter-tutorial/previews/community-workshop-scheduler/
```

直接打开详情：

```text
/flutter-tutorial/previews/community-workshop-scheduler/#/sessions/session-01
```

刷新后回到主页，切换 day / venue，再用 Back / Forward 检查 query 恢复。随后只用键盘完成新建、保存失败、修复冲突和再次保存。

## 项目完成检查

- [ ] URL、Drift 和编辑草稿分别管理自己的源状态，没有可写副本漂移。
- [ ] View 不直接访问 Drift，Repository 不依赖 Widget 或 `BuildContext`。
- [ ] 冲突 policy 同时用于新建、编辑和单元测试。
- [ ] 时间采用 `[start, end)`，编辑排除自身，一次返回全部冲突。
- [ ] Repository 映射可恢复 Exception，程序 Error 继续暴露。
- [ ] 同一保存动作不能重复启动，异步返回前检查 `ref.mounted`。
- [ ] 只有三参数 family 使用生成器，其他 provider 保持手写。
- [ ] Drift 查询 Stream 推送写入结果，不做冗余 invalidate。
- [ ] 宽屏排期墙与窄屏议程读取同一份状态。
- [ ] 冲突有可见文字、live region、焦点和修复入口。
- [ ] 25 条测试、Chrome 集成测试和 release 子路径构建通过。

## 复习线索

- 分层从责任和测试接缝开始，不从目录模板开始。
- URL 管筛选，Drift 管正式排期，Notifier 管编辑草稿。
- domain policy 保持纯 Dart；Repository 负责数据策略和 failure 映射。
- provider 声明对象图，container 保存状态；Repository provider 是主要 override 接缝。
- family 参数决定查询缓存身份，Drift Stream 已更新数据时不重复失效。
- 错误摘要要同时解决理解、焦点和恢复，不只变成红色。
- [项目源码](https://github.com/mardd123588/flutter-tutorial/tree/main/examples/capstones/community_workshop_scheduler)

## 参考资料

- [Flutter guide to app architecture](https://docs.flutter.dev/app-architecture/guide)（查阅：2026-08-30）
- [Flutter Result pattern](https://docs.flutter.dev/app-architecture/design-patterns/result)（查阅：2026-08-30）
- [Flutter Command pattern](https://docs.flutter.dev/app-architecture/design-patterns/command)（查阅：2026-08-30）
- [Riverpod providers](https://riverpod.dev/docs/concepts2/providers)（查阅：2026-08-30）
- [Riverpod family](https://riverpod.dev/docs/concepts2/family)（查阅：2026-08-30）
- [Riverpod automatic disposal](https://riverpod.dev/docs/concepts2/auto_dispose)（查阅：2026-08-30）
- [Riverpod testing](https://riverpod.dev/docs/how_to/testing)（查阅：2026-08-30）
- [Riverpod code generation](https://riverpod.dev/docs/concepts/about_code_generation)（查阅：2026-08-30）
- [Drift Web](https://drift.simonbinder.eu/platforms/web/)（查阅：2026-08-30）
- [Flutter Web integration tests](https://docs.flutter.dev/testing/integration-tests#test-in-a-web-browser)（查阅：2026-08-30）
- [Build and release a Flutter Web app](https://docs.flutter.dev/deployment/web)（查阅：2026-08-30）

