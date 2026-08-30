# 社区工坊排期台

第六部分的统筹项目。它把冲突规则、Riverpod、fixture Service、Repository、Drift 与响应式 Flutter Web 界面放进一条完整的数据流。

应用管理 2 个活动日、3 个场馆、5 位讲师、8 个工坊和 10 条初始排期。宽度达到 980px 时显示按场馆分列的排期墙；较窄时改为按日期、时间分组的议程列表。两种布局读取同一份状态，不各自维护数据。

活动日和场馆筛选写入 URL，例如：

```text
#/schedule?day=day-sat&venue=venue-forge
```

讲师筛选只保留在当前页面状态中。场次详情使用 `/sessions/:sessionId`，新建页使用 `/new`，编辑页使用 `/sessions/:sessionId/edit`。默认 Hash URL 可在 GitHub Pages 子路径下直接刷新。

## 冲突规则

保存前由 `ScheduleConflictPolicy` 一次返回全部问题，界面集中显示，不要求用户逐次提交才能发现下一项。

- 活动日、工坊、场馆和讲师必须存在。
- 开始时间必须早于结束时间，且排期要落在 09:00–18:00。
- 预计人数不能超过场馆容量。
- 同一活动日内，同一场馆或同一讲师的时间不能重叠。
- 时间区间按 `[start, end)` 处理；前一场 10:00 结束，后一场可在 10:00 开始。
- 编辑已有场次时，冲突检查会排除该场次自身。

冲突摘要使用 live region，并在保存失败后获得焦点。容量冲突提供回到预计人数输入框的入口；时间冲突会列出相关场次和时段。

## 数据流

`FixtureWorkshopCatalogService` 提供稳定的教学目录。`LocalScheduleRepository` 负责加载目录、初始化数据库、执行冲突规则，并把失败转换为明确的结果类型。`ScheduleDatabase` 实现 `ScheduleStorageService`，在 Web 上通过 Drift、SQLite WASM 与 worker 保存排期。

Riverpod 只暴露页面需要的状态：目录、单条场次、编辑器状态，以及一个由活动日、场馆、讲师共同组成的 generated family。UI 不直接访问 Drift。

首次打开时写入 10 条 fixture 排期，之后保留当前浏览器中的修改。“恢复演示数据”会先确认，再覆盖本地排期。

## 运行

```powershell
cd examples/capstones/community_workshop_scheduler
flutter run -d chrome
```

执行静态检查、Unit 与 Widget 测试：

```powershell
flutter analyze
flutter test
```

Chrome 集成测试需要先在 4444 端口启动 ChromeDriver：

```powershell
flutter drive -d web-server --browser-name=chrome --driver=test_driver/integration_test.dart --target=integration_test/community_workshop_scheduler_test.dart
```

构建 GitHub Pages 预览：

```powershell
flutter build web --release --base-href /flutter-tutorial/previews/community-workshop-scheduler/
```

测试覆盖冲突顺序与半开区间、Repository 失败边界、Drift seed 与恢复、Riverpod 筛选、新建和编辑流程、320×720、768×900、1440×900、200% 文本、URL 筛选、深链接和浏览器重开后的本地持久化。

目录、排期和人物资料都是本地教学数据。项目不连接网络服务，不包含账号、权限、多人协作、时区换算或服务端冲突仲裁；Web 是本项目的验收平台。
