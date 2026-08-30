---
title: 偏好、缓存与离线回退
description: 区分偏好、应用缓存和 HTTP cache，并用新鲜度决定旧数据如何继续服务。
part: 4
order: 6
kind: concept
requires:
  - data.service
  - async.ui-state
provides:
  - storage.preferences
  - data.cache
  - offline.fallback
status: verified
---

# 偏好、缓存与离线回退

“保存到本地”至少包含三类数据：用户偏好、可重新获取的缓存、必须可靠保留的业务记录。它们的失败成本不同，不能因为 API 都是 key-value 就放进同一个存储。

## SharedPreferencesAsync 只放少量偏好

`shared_preferences 2.5.5` 提供旧 `SharedPreferences`、`SharedPreferencesWithCache` 和 `SharedPreferencesAsync`。新项目不再优先使用旧 API。城市活动雷达选择 Async 版本，避免进程内缓存与底层存储不同步：

<<< ../../../examples/capstones/city_event_radar/lib/src/event_preferences.dart#async-preferences{dart}

它只保存“当前分区”和“只看收藏”开关。这些值丢失后最多恢复默认界面，不会丢活动或收藏。

插件文档明确提醒：写入返回后不保证数据已经可靠持久化，因此不要存认证密钥、支付状态、唯一业务记录或需要事务的数据。收藏和活动缓存会在下一章进入 Drift。

## 三层缓存不要混名

| 层 | 典型所有者 | 主要合同 |
| --- | --- | --- |
| 内存应用缓存 | controller / service | key、容量、freshness、失效 |
| 浏览器 HTTP cache | 浏览器与服务端 headers | `Cache-Control`、验证器、请求语义 |
| 本地持久化缓存 | 应用数据库 | schema、迁移、写入一致性、离线读取 |

内存 Map 不是 HTTP cache。`Cache-Control: no-cache` 也不是禁止保存，它表示复用前必须重新验证；禁止存储的是 `no-store`。

教程项目不尝试自己重写浏览器 HTTP cache。Service fixture 负责可重复响应，应用层只决定旧数据还能否展示。

## freshness 是时间合同

缓存条目至少需要：

```dart
class CacheEntry<T> {
  const CacheEntry(this.value, this.savedAt);

  final T value;
  final DateTime savedAt;
}
```

判断新鲜度要注入 clock：

```dart
final fresh = now().difference(entry.savedAt) <= freshFor;
```

测试固定 `now` 后，可以准确覆盖 19 分钟、20 分钟和 21 分钟。不要在断言中读取真实系统时间，也不要把服务端数据生成时间和本地缓存写入时间混成同一字段。

freshness 不是“能不能显示”的唯一条件。活动列表过期两小时仍可能比空白页面有用，但必须标出来源和更新时间；权限、余额等敏感数据则可能过期后完全不能使用。

## 回退顺序要可见

城市活动雷达采用：

1. 网络成功：显示新结果，写入本地缓存和同步时间。
2. 网络失败且有缓存：显示缓存，标出新鲜或过期。
3. 没有缓存：显示随应用发布的教学 fixture，并明确它不是实时数据。

页面不要把回退伪装成在线成功。用户需要看到 source、last updated 和 refresh error，才能判断数据能否用于当前任务。

新查询加载时也不急着清空旧结果。网络失败后，旧结果继续显示；空结果只有在成功响应明确返回空集合后才成立。

## fixture 是可复现底线

fixture 让教程、测试和发布预览不依赖外部服务。它必须：

- 固定内容和时间；
- 明确标为教学示例；
- 与真实 parser 使用相同 payload 结构；
- 能制造成功、空结果、status、timeout 和离线场景。

fixture 不是伪装出来的实时数据。项目页面和 README 都要说明来源边界。

## 可验证任务

为活动页增加偏好与缓存策略：

1. `SharedPreferencesAsync` 只保存分区和收藏筛选开关。
2. 用 fake store 测试偏好读写，不依赖浏览器插件。
3. 缓存条目记录 payload 与本地保存时间。
4. 注入 clock，覆盖 fresh、stale 和未来时间边界。
5. 网络失败时依次选择缓存、内置 fixture，并在 UI 显示来源。
6. 网络成功返回空集合时显示空结果，不回退旧缓存。

## 复习线索

- 偏好、可重新获取缓存和关键业务数据要按失败成本分开。
- `SharedPreferencesAsync` 适合少量非关键设置，不提供事务或关键持久化保证。
- freshness 决定旧数据如何标记，不自动决定能否继续展示。
- 离线回退要显示来源、更新时间和刷新错误。

## 参考资料

- [shared_preferences 2.5.5 package](https://pub.dev/packages/shared_preferences/versions/2.5.5)（查阅：2026-08-30）
- [RFC 9111: HTTP Caching](https://www.rfc-editor.org/rfc/rfc9111.html)（查阅：2026-08-30）
- [Cache-Control header](https://developer.mozilla.org/en-US/docs/Web/HTTP/Reference/Headers/Cache-Control)（查阅：2026-08-30）
