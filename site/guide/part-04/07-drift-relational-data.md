---
title: 关系数据、Drift 与迁移
description: 用表、事务、查询 Stream 和 schema migration 保存收藏关系，并核对 Drift Web 资产与回退边界。
part: 4
order: 7
kind: concept
requires:
  - model.immutable
  - async.stream-builder
provides:
  - storage.relational
  - storage.drift
  - storage.migration
  - storage.web-boundary
status: verified
---

# 关系数据、Drift 与迁移

偏好适合独立小值；收藏、标签和缓存同步时间需要查询、事务和迁移。城市活动雷达使用 Drift，把表定义写成 Dart，再生成类型安全 SQL 接口。数据库仍然是 SQLite：表设计、事务边界和迁移责任没有消失。

## 表从查询和一致性出发

项目有三组数据：收藏活动、收藏与标签关系、最近一次完整活动缓存：

<<< ../../../examples/capstones/city_event_radar/lib/src/event_database.dart#drift-tables{dart}

`SavedEvents` 以稳定 event ID 为主键。`SavedEventTags` 使用 `(eventId, tag)` 复合主键，同一收藏不会重复写同一标签。`EventCaches` 只保存一个完整 feed 及写入时间；它是可替换缓存，不是活动的唯一事实来源。

关系表没有直接把 `List<String>` 塞进一个字符串字段。这样可以查询某个标签、保证组合唯一，并在删除收藏时明确处理对应关系。

## transaction 保证一次动作完整

收藏一个活动要同时写收藏行和多条标签行；取消收藏要先删关系再删收藏。项目把两条路径放进同一 transaction：

<<< ../../../examples/capstones/city_event_radar/lib/src/event_database.dart#drift-watch-and-transaction{dart}

中间任一步失败，整个 transaction 回滚。没有 transaction 时，页面可能显示“已收藏”，标签关系却只写了一半。

transaction 内不要等待用户输入、网络请求或长时间计算。先取得网络结果和模型，再开启短事务写本地一致状态。

## watch 查询会重跑

Drift 的 `watch()` 返回 Stream。相关表发生写入后，Drift 按查询涉及的表重新执行并发出结果。它使用启发式表更新追踪，可能比“结果值真正变化”更频繁，不应写成精确字段级通知。

页面订阅收藏 ID 集合后，再计算当前列表的 saved 状态。数据库 Stream 负责持续事实，Widget 负责展示；关闭数据库前要先结束使用它的订阅。

单元测试使用 `NativeDatabase.memory()`，能验证 SQL、事务和 Stream，不证明浏览器的 Wasm、Worker 或持久化实现。

## migration 是发布合同

项目当前 schema version 为 2。版本 1 只有收藏活动；版本 2 增加保存时间、标签关系和缓存表：

<<< ../../../examples/capstones/city_event_radar/lib/src/event_database.dart#drift-migration{dart}

升级不能只验证“新安装能建表”。测试要先建立 version 1 数据库、插入一条旧收藏，再用当前数据库打开，确认：

- 旧收藏仍在；
- 新列存在；
- 新关系表和缓存表可读写；
- `PRAGMA user_version` 更新到当前版本。

复杂 schema 应导出历史 schema 并使用 Drift migration verifier。这个项目的迁移很小，测试仍实际从 version 1 文件升级，不只调用 `createAll()`。

## 缓存也需要独立写入时间

项目把完整 payload 与本地 savedAt 一起写入 Drift：

<<< ../../../examples/capstones/city_event_radar/lib/src/event_database.dart#drift-cache{dart}

网络成功只在空查询时更新完整缓存，避免把一次筛选结果误当作全量数据。离线搜索则读取完整缓存后在本地匹配。

`SharedPreferencesAsync` 仍只负责筛选偏好。把缓存迁到 Drift 后，职责和迁移路径都更明确。

## Drift Web 需要匹配资产

Drift 2.34.3 的 Web 预览携带同版本链路所需：

- `web/sqlite3.wasm`
- `web/drift_worker.js`

`sqlite3.wasm` 必须以 `application/wasm` 提供。Web release 构建成功只证明文件进入产物，不证明部署服务器的 MIME、worker URL 和 base path 正确。

Drift 会按浏览器能力选择 OPFS、带锁 OPFS、Shared IndexedDB、unsafe IndexedDB 或内存实现。没有 COOP / COEP 时通常会回退，不是必然无法运行；回退到 unsafe IndexedDB 时多标签安全性降低，回退到内存时刷新不持久化。

本教程只承诺指定桌面 Chrome 的 Web 验收。Firefox private browsing、移动 Chrome 和其他存储实现需要单独验证。

## 可验证任务

为收藏数据库完成以下检查：

1. 收藏写入活动和标签，取消后两张表都清理。
2. 故意让 transaction 中途失败，确认没有半条记录。
3. `watchSavedIds()` 依次发出空集合、收藏集合和空集合。
4. 从 version 1 文件升级到 version 2，旧收藏保留。
5. 服务器能从 Web release 产物正确返回 Wasm MIME，worker 无 404。
6. Chrome 中收藏后刷新仍在；另开标签页记录当前存储实现与同步边界。

## 复习线索

- 表设计服务于查询、唯一性和一致性，不是把对象机械拆列。
- 多表动作放进短 transaction；网络请求留在事务外。
- watch 查询会因相关表写入而重跑，可能产生额外通知。
- 内存数据库测试和 Drift Web 验收解决不同风险。

## 参考资料

- [Drift 2.34.3 package](https://pub.dev/packages/drift/versions/2.34.3)（查阅：2026-08-30）
- [Drift stream queries](https://github.com/simolus3/drift/blob/drift-2.34.3/docs/content/dart_api/streams.md)（查阅：2026-08-30）
- [Drift transactions](https://github.com/simolus3/drift/blob/drift-2.34.3/docs/content/dart_api/transactions.md)（查阅：2026-08-30）
- [Drift migrations](https://github.com/simolus3/drift/blob/drift-2.34.3/docs/content/migrations/index.md)（查阅：2026-08-30）
- [Testing Drift migrations](https://github.com/simolus3/drift/blob/drift-2.34.3/docs/content/migrations/tests.md)（查阅：2026-08-30）
- [Drift Web](https://github.com/simolus3/drift/blob/drift-2.34.3/docs/content/platforms/web.md)（查阅：2026-08-30）
- [DriftWebOptions 0.3.1 API](https://pub.dev/documentation/drift_flutter/0.3.1/drift_flutter/DriftWebOptions-class.html)（查阅：2026-08-30）
