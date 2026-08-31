---
title: 项目：城市活动雷达
description: 统筹 HTTP、JSON、搜索竞态、偏好、缓存、离线回退与 Drift 收藏。
part: 4
order: 8
kind: capstone
requires:
  - async.ui-state
  - async.future-builder
  - async.stream-builder
  - async.stale-result
  - data.http-client
  - data.service
  - error.network
  - test.http-client
  - data.json
  - model.immutable
  - error.decode
  - async.debounce
  - async.race
  - async.cancellation-boundary
  - codegen.json-serializable
  - tool.build-runner
  - storage.preferences
  - data.cache
  - offline.fallback
  - storage.relational
  - storage.drift
  - storage.migration
  - storage.web-boundary
provides:
  - project.city-event-radar
project: city-event-radar
status: verified
---

# 项目：城市活动雷达

城市活动雷达把这一部分的异步与数据边界放进一张值班图。读者可以搜索活动、筛选分区、收藏条目、模拟离线并刷新。页面始终显示数据来源和更新时间，不把 fixture、缓存与网络结果混成同一种“成功”。

单项机制可回查[异步状态](/guide/part-04/01-async-ui-state)、[HTTP Service](/guide/part-04/02-http-service)、[手写 JSON](/guide/part-04/03-hand-written-json)、[搜索竞态](/guide/part-04/04-search-race)、[代码生成](/guide/part-04/05-json-serializable)、[缓存与离线回退](/guide/part-04/06-preferences-cache-offline)和[Drift](/guide/part-04/07-drift-relational-data)。本章只解释这些边界如何共享一份活动数据。

## 项目简报

先按下面的合同独立实现，再阅读后续拆解。

### 使用场景

居民在活动开始前几天整理周末安排。网络不稳定时，他们仍要查看上次活动列表和本地收藏；恢复联网后可以重新刷新。

### 功能要求

- 默认数据源是可控 HTTP fixture，CI 不访问外部服务；
- 手写 envelope 解析，活动条目用 `json_serializable`；
- 搜索有防抖和请求 generation，旧响应不能覆盖新结果；
- `SharedPreferencesAsync` 只保存分区和“只看收藏”偏好；
- Drift 保存收藏、标签关系、完整活动缓存和同步时间；
- 网络失败时依次使用 Drift 缓存和内置 fixture，并标明来源；
- 收藏由 Drift 查询 Stream 驱动，刷新页面后仍在；
- migration 从 version 1 保留旧收藏；
- Web release 产物携带匹配的 Wasm 和 Worker。

### 验收

- 搜索 `夜` 后立刻改为 `河`，最终只显示河岸活动；
- 收藏河岸活动，刷新后收藏仍在；
- 切换模拟离线，页面保留活动并显示缓存来源；
- 只看收藏与分区筛选可以组合，空交集提供清空条件提示；
- 320×720、200% 文本、键盘和语义操作无阻塞；
- analyze、单元测试、Widget 测试、Chrome 集成测试和 Web release 构建全部通过。

## 数据边界保持窄

项目仍使用第三部分学过的 controller / notifier，没有提前引入 ViewModel、Repository、Result 或 Riverpod。依赖从应用入口传入：Service、偏好 store 和本地数据库都可以替换。

数据流按下面的顺序工作：

```text
输入参数
  → HTTP fixture Service
  → envelope + generated DTO
  → generation guard
  → 当前页面状态

网络失败
  → Drift 完整缓存
  → 内置教学 fixture

收藏动作
  → Drift transaction
  → watchSavedIds Stream
  → 当前列表派生收藏状态
```

这里没有“万能本地存储”。偏好、缓存与关系数据按失败成本和查询需求分开。

## 在线成功只缓存完整 feed

空查询成功时，controller 才把 raw JSON 与本地时间写入 Drift。带搜索词的响应可能只有一部分活动，不能覆盖完整离线缓存。

离线搜索读取完整缓存，再在本地匹配当前 query。回退逻辑集中在 controller：

<<< ../../../examples/capstones/city_event_radar/lib/src/event_radar_controller.dart#cache-fallback{dart}

缓存有明确的 fresh / stale 判断。过期缓存仍可展示，但页面显示“过期缓存”和更新时间；没有缓存时才进入内置 fixture。

## 收藏和缓存共用数据库，不共用语义

收藏是用户动作，需要事务、关系唯一性和持续 Stream。活动缓存可被网络全量替换，需要 savedAt 和 migration。它们共用 Drift 连接，但表和动作分开。

`SharedPreferencesAsync` 没有保存任何活动 payload 或收藏 ID。即使偏好写入失败，数据库事实仍然完整。

## 搜索继续遵守 generation

城市项目没有因为加入缓存和数据库就换一套竞态规则。每次请求仍分配递增编号；成功和失败写回前都检查 active request。旧请求的错误也不能覆盖新查询。

搜索 loading 时保留当前活动。只有当前请求成功返回空集合，页面才进入空结果；网络失败会保留缓存或 fixture，并把 phase 标为 degraded。

## Drift Web 的发布检查

项目默认连接声明了 `sqlite3.wasm` 和 `drift_worker.js`。两个文件来自与 Drift 2.34.3 匹配的探针结果。

浏览器检查不能停在“页面打开”：

1. Network 面板确认 worker 无 404。
2. Wasm 响应为 `application/wasm`。
3. 收藏一项后刷新，收藏仍在。
4. 再开一个标签页，记录多标签读写是否同步。
5. 没有 SharedArrayBuffer 时，确认回退实现和持久化结果。

当前仓库探针在缺少 SharedArrayBuffer 时选择 Shared IndexedDB，并已验证刷新与多标签读写。这个结论只覆盖指定桌面 Chrome 和当前部署配置。

## 界面把来源放在任务旁边

活动雷达采用“城市夜班调度图”：深色扫描面展示当前活动信号，纸色调度单承载可操作详情，数据值班簿列出 source、freshness、可见数量、收藏数和旧响应计数。

`CustomPainter` 是 Flutter 的 canvas 自绘入口，这里只用它绘制扫描装饰。扫描动画只在数据变化时执行一次；系统要求减少动画时直接显示终态。活动列表和来源文字始终存在，像素不是唯一信息载体。[渲染流水线与自绘边界](/guide/part-07/05-rendering-pipeline)会再解释它的重绘与语义责任。

所有活动、场地、时间、价格和信号值都明确标为教学示例。项目不加载地图、第三方字体、分析脚本或远程图片。

## 运行与检查

项目路径：`examples/capstones/city_event_radar`。

```powershell
flutter analyze examples/capstones/city_event_radar
flutter test examples/capstones/city_event_radar/test
cd examples/capstones/city_event_radar
flutter run -d chrome
```

重新生成 JSON 与 Drift 代码：

```powershell
dart run build_runner build
```

Web release 构建：

```powershell
flutter build web --release --base-href /flutter-tutorial/previews/city-event-radar/
```

## 项目完成检查

- [ ] 能分别解释 Future 请求、数据库 Stream 和页面任务状态。
- [ ] status、timeout、decode 与离线失败没有混成一个错误。
- [ ] 手写 envelope 与生成 DTO 通过同一 fixture 边界测试。
- [ ] 防抖、generation 和缓存回退在参数变化时保持一致。
- [ ] SharedPreferences 只保存非关键偏好。
- [ ] Drift transaction、watch、migration 与 Web 资产都有独立测试证据。
- [ ] 页面明确显示网络、fresh cache、stale cache 和 bundled fixture。
- [ ] Chrome 中收藏刷新持久化，release Wasm 和 worker 加载正常。

## 复习线索

- 网络成功、缓存回退和内置 fixture 必须保留来源与时间。
- 搜索参数变化仍以 generation 判断结果身份，缓存不会替代竞态控制。
- 偏好、缓存和关系数据按失败成本与查询需求选择存储。
- [项目源码](https://github.com/mardd123588/flutter-tutorial/tree/main/examples/capstones/city_event_radar)

## 参考资料

- [Flutter networking recipe](https://docs.flutter.dev/cookbook/networking/fetch-data)（查阅：2026-08-30）
- [http 1.6.0 package](https://pub.dev/packages/http/versions/1.6.0)（查阅：2026-08-30）
- [json_serializable 6.14.1 package](https://pub.dev/packages/json_serializable/versions/6.14.1)（查阅：2026-08-30）
- [shared_preferences 2.5.5 package](https://pub.dev/packages/shared_preferences/versions/2.5.5)（查阅：2026-08-30）
- [Drift 2.34.3 Web documentation](https://github.com/simolus3/drift/blob/drift-2.34.3/docs/content/platforms/web.md)（查阅：2026-08-30）
- [Flutter Web integration tests](https://docs.flutter.dev/testing/integration-tests#test-in-a-web-browser)（查阅：2026-08-30）
