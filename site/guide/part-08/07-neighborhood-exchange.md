---
title: 项目：邻里资源交换站
description: 完整讲解 48 条固定资源、Riverpod、Drift 幂等认领、hash URL、响应式公告板、可访问状态、CI 与 Pages 发布。
part: 8
order: 7
kind: capstone
requires:
  - engineering.pub-workspace
  - engineering.dependencies
  - engineering.config
  - engineering.ci
  - engineering.affected-projects
  - engineering.reproducibility
  - web.release-build
  - web.base-href
  - web.wasm-boundary
  - deployment.pages
  - deployment.preview-layout
  - deployment.rollback
  - platform.plugin
  - platform.permission
  - platform.channel
  - platform.web-limit
  - release.quality
  - release.privacy
  - release.license
  - release.migration
provides:
  - project.neighborhood-exchange
project: neighborhood-exchange
status: verified
---

# 项目：邻里资源交换站

邻里资源交换站是第八部分的统筹项目。读者以社区共享点值班成员的身份浏览、发布和认领资源；应用把本地数据边界、工程输入、CI、Web release 子路径和 Pages artifact 放进同一条可验证路径。

单项工程合同可回查[workspace 与配置](/guide/part-08/01-workspace-dependencies-config)、[可复现 CI](/guide/part-08/02-reproducible-ci)、[Web release 构建](/guide/part-08/03-flutter-web-release)、[Pages 发布](/guide/part-08/04-github-pages-publishing)、[平台扩展](/guide/part-08/05-platform-plugins-permissions-channels)和[发布质量](/guide/part-08/06-release-quality-privacy-upgrades)。本章只解释这些合同如何约束一个可发布应用。

本章完整讲解项目。前六章引用过的 workspace、分享 Service 和发布脚本，会在这里回到完整应用中的位置。

## 项目简报

### 固定数据

项目内置 48 条虚构资源，覆盖：

- 6 个片区：青禾里、石桥巷、南园、河埠头、松影街、望塔坊；
- 6 个类别：工具、园艺、厨房、阅读、活动物料、技能时段；
- 3 个派生状态：`available`、`reserved`、`completed`；
- 3 种交接方式和一组预设可用时段。

fixture ID 固定为 `r-001` 至 `r-048`。本地发布使用 `local-` 前缀，当前演示身份固定为 `local-neighbor`，显示名“林澄”。fixture 与测试时钟都不读取执行当天。

### 用户任务

- 搜索标题、说明和发布者；
- 按片区、类别、状态筛选，切换排序与列表 / 紧凑网格；
- 打开 hash 深链接，使用 Back / Forward 和刷新恢复；
- 发布一条只保存在当前浏览器的资源；
- 以固定本地身份认领一份资源；
- 复制 fixture 或本地资源链接，并看见不同的数据边界。

项目不做账号、云同步、真实多人竞争、聊天、支付、精确地址、图片上传、推送、PWA 或 path URL。

## 数据边界直接写进界面

静态站点没有共享后端：

| 数据 | 当前浏览器 | 另一浏览器 |
| --- | --- | --- |
| `r-001` 至 `r-048` fixture | 能恢复 | 同版本也能恢复基础记录 |
| 本地发布 `local-...` | 写入 Drift，可刷新恢复 | 没有记录，只显示本地边界说明 |
| 当前身份认领结果 | 写入 Drift，可刷新恢复 | 仍看到 fixture 的构建内置基础状态 |

发布成功文案写“仅此浏览器可见”，认领成功写“仅保存在当前浏览器”。应用不使用“已同步”“邻居已收到”或“实时库存”一类措辞。

“关于此预览”页显示公开构建配置：

```text
APP_ENV=demo
CONTENT_VERSION=<commit-sha>
```

这些值帮助确认当前 artifact，不包含秘密。

## 领域模型只保存事实

`ExchangeListing` 保存总量、剩余量和完成时间。状态由事实派生：

```dart
ExchangeStatus get status {
  if (completedAt != null) return ExchangeStatus.completed;
  if (remainingQuantity == 0) return ExchangeStatus.reserved;
  return ExchangeStatus.available;
}

bool canBeClaimedBy(String userId) {
  return status == ExchangeStatus.available &&
      ownerId != userId &&
      !claimedByCurrentUser;
}
```

数据库不再保存一列容易与数量冲突的 `status`。查询按搜索、片区、类别和派生状态求交集，排序最后用稳定 ID 打破平局。

发布草稿在 domain 层验证。标题 trim 后不能为空，最多 40 个 grapheme；说明最多 240 个 grapheme；数量是 1 到 9 的整数。使用 `characters.length`，避免把一个由多个 code unit 组成的用户可见字符算成多位。

## fixture Service、Repository 与 Drift 分工

对象图如下：

```text
View
  ↓ intent                    ↑ AsyncValue / command state
Riverpod providers
  ↓ query / command           ↑ ExchangeResult / stream
ExchangeRepository
  ├── FixtureExchangeService  首次种子
  └── ExchangeStorageService  Drift Web / test fake
```

Repository 先向 fixture Service 取得固定列表，再调用 `ensureSeeded`。数据库用 `fixture-seed-v1` 标记，重复启动不会覆盖本地发布和认领。

发布流程先验证草稿，再用注入的 clock 生成 UTC 时间和 `local-...` ID，最后写入 storage。Repository 把数据库与 fixture 异常映射为稳定的 `ExchangeFailure`，页面不显示原始异常字符串。

## 认领事务保证本地幂等

Drift 的认领表以 `(listingId, claimantId)` 为复合主键。`claimOne` 在同一事务内：

1. 查询是否已有同一身份的认领；
2. 查询资源是否存在；
3. 拒绝自己的资源、已完成或剩余为 0 的资源；
4. 插入认领记录；
5. 把 `remainingQuantity` 减 1，并更新时间。

重复请求返回 `alreadyClaimed`，不会再次扣减。最后一份被取走后，派生状态自动变成 `reserved`。

这个事务只证明同一浏览器数据库中的顺序执行和持久化。它没有服务器锁、全局唯一约束或跨用户事务，不能代表真实多人同时认领已经解决。

## Riverpod 组合依赖和命令状态

Provider 图把基础设施替换点放在顶部：

```dart
final exchangeRepositoryProvider = Provider<ExchangeRepository>((ref) {
  return LocalExchangeRepository(
    fixtureService: ref.watch(fixtureExchangeServiceProvider),
    storage: ref.watch(exchangeStorageServiceProvider),
  );
});

final exchangeListingsProvider = StreamProvider.autoDispose
    .family<ExchangeResult<List<ExchangeListing>>, ExchangeQuery>(
      (ref, query) => ref.watch(exchangeRepositoryProvider).watch(query),
      retry: noExchangeRetry,
    );
```

列表用 `family` 把不可变 `ExchangeQuery` 作为 provider 身份。发布和认领分别使用 Notifier 保存 submitting、字段错误、当前资源和结果；Repository 仍是数据单一事实来源。

`exchangeStorageServiceProvider` 在生产环境创建 Drift，测试用 `overrideWithValue` 注入内存数据库或 fake Repository。`ref.onDispose(database.close)` 让 provider 拥有并释放数据库。

## URL 保存可分享查询

Codec 只写非默认值，非法枚举回退为默认：

<<< ../../../examples/capstones/neighborhood_exchange/lib/src/domain/exchange_url_codec.dart{dart}

查询 URL 例如：

```text
#/exchange?q=折叠&category=tools&sort=title&view=compactGrid
```

详情使用 `#/listings/:listingId`。1100px 以上，详情嵌在右栏；更窄时进入独立页面。Route ID 保持不变，所以刷新和复制链接恢复同一资源。

fixture 深链接能跨浏览器恢复。本地链接在复制前弹出说明；另一浏览器打开不存在的 `local-...` ID 时，页面明确写“这条记录属于另一个浏览器”，并提供“返回全部资源”。普通未知 fixture ID 使用另一种错误状态。

## 三档布局共享同一状态

| 宽度 | 布局 |
| --- | --- |
| 1100px 及以上 | 左侧筛选簿、中间公告列表、右侧详情 |
| 700–1099px | 单栏结果桌和行内筛选条，详情独立页面 |
| 700px 以下 | 筛选进入 bottom sheet，详情与发布使用独立页面 |

资源卡在 420px 以下把取用签移到底部；紧凑网格在可用宽度达到 560px 后才使用两列。200% 文本时页面允许完整滚动，不用固定高度裁切内容。

布局只改变信息摆放。筛选值仍来自 URL，列表仍来自同一 provider，选中资源仍由稳定 ID 确定。

## 可访问状态与动效

项目把用户可感知结果写进测试合同：

- 结果数量使用 Semantics live region；
- 发布失败后焦点移到完整错误摘要，字段仍保留关联错误；
- 认领成功和失败有文字、状态与恢复动作，不只换颜色；
- 卡片不吞掉内部复制、认领按钮的语义；
- 320×720、200% 文本和 RTL 保留主要任务；
- 所有主要按钮至少 48px 高，并有可见键盘焦点。

宽屏切换详情时使用 220ms 淡入和 4% 水平位移。`MediaQuery.disableAnimationsOf(context)` 为真时，`AnimatedSwitcher.duration` 直接变成 `Duration.zero`。动效只解释详情替换，没有循环动画。

## 分享能力留在 Service 边界

`ResourceShareService` 只暴露复制链接。Web 实现调用 Clipboard，Widget 测试换成 recording fake，验证本地链接警告和最终 URL。

若以后增加系统 share sheet，新增原生实现和 capability 即可。首版没有真机证据，所以不加入 share plugin，也不声称原生系统分享已经完成。

## Workspace、CI 与发布接入

项目是根 pub workspace 的第 13 个成员，也是 `tool/projects.json` 的 `neighborhood-exchange` 条目。项目清单还声明 Drift Web 资产：

```json
{
  "slug": "neighborhood-exchange",
  "chapter": "08-07",
  "webAssets": ["sqlite3.wasm", "drift_worker.js"]
}
```

Pull Request 修改项目私有文件时只选择本项目；根 lockfile、CI、release 工具和 workflow 变化触发全部 13 个项目。`main` 固定全量验证。

独立 Web release 构建使用：

```text
--pwa-strategy=none
--no-web-resources-cdn
--base-href /flutter-tutorial/previews/neighborhood-exchange/
```

构建脚本检查 base、`useLocalCanvasKit: true`、0 字节 Service Worker、`sqlite3.wasm` 和 `drift_worker.js`。随后预览与 VitePress、其余 12 个项目一起进入 `build/pages-staging`，smoke 从真实 `/flutter-tutorial/` base 验证入口和 MIME。

## 自动验收覆盖的风险

项目共有 26 项单元测试、Repository 测试、Drift 测试与 Widget 测试，覆盖：

- 48 条稳定 fixture、6 个片区、6 个类别；
- 派生状态、筛选、排序 tie-breaker、grapheme 与数量边界；
- fixture 只导入一次、发布持久化、认领幂等和恢复演示数据；
- 普通未知 ID 与缺失本地链接的不同错误；
- loading、empty、error、retry；
- URL 恢复、窄屏筛选、本地链接警告；
- 发布错误摘要焦点、认领 live region；
- 320×720、768×900、1440×900、200% 文本、RTL、reduced motion。

Chrome 集成测试完成“发布本地资源 → 关闭并重开数据库 → 恢复详情 → 认领 fixture → 再次重开 → 保留认领状态”。它使用真实 Drift Web 和浏览器持久化，但不访问远程服务。

这条流程没有遍历全部查询参数、非法 URL、全新浏览器 profile 或键盘边界；这些情况分别由 Widget 测试和人工验收覆盖，不能算进 Chrome 集成测试的结果。

本轮三档人工 Chrome 检查没有 console error 或 warn。项目不维护 golden，“视觉”为 `not-applicable`；响应式 Widget 测试和浏览器视觉检查仍然保留。

## 运行与发布

项目目录内：

```powershell
cd examples/capstones/neighborhood_exchange
flutter analyze
flutter test
```

仓库根运行完整项目验证：

```powershell
node tool/ci/verify_project.mjs --project neighborhood-exchange --integration --build
```

构建并合并 Pages staging：

```powershell
pnpm docs:build
pnpm release:build:exchange
pnpm release:stage
pnpm release:smoke
```

预览入口：

```text
/flutter-tutorial/previews/neighborhood-exchange/#/exchange
```

## 项目完成检查

- [ ] 根 workspace 与项目 analyze 通过，locked install 不改 lockfile。
- [ ] fixture 保持 48 条、6 个片区、6 个类别和稳定 ID。
- [ ] 发布验证使用 grapheme，数量限制为 1–9。
- [ ] 认领事务按复合主键幂等，最后一份派生为 `reserved`。
- [ ] fixture、本地发布和认领的跨浏览器边界写在结果旁边。
- [ ] URL 保存查询和详情，非法 fixture 与缺失本地链接可恢复。
- [ ] 三档宽度、200% 文本、RTL、键盘、Semantics 和 reduced motion 通过。
- [ ] Chrome 完成发布、重开、认领与再次重开持久化。
- [ ] Web release 产物能从独立 base 加载本地 CanvasKit、Wasm 与 Worker。
- [ ] VitePress 与 13 个预览合并后通过 Pages staging smoke。
- [ ] 隐私、许可、已知限制、commit 和回滚入口已经记录。

## 复习线索

- Workspace 统一解析，项目仍保持独立业务代码和测试。
- 状态从数量与完成时间派生，数据库只保存事实。
- Repository 组合 fixture 与 Drift，Riverpod 负责依赖和 UI 命令状态。
- 复合主键和事务提供本地幂等，不代表真实多人并发。
- URL 能分享 fixture 查询，本地记录和认领只属于当前浏览器。
- 响应式布局重排界面，不复制查询、列表或选中状态。
- CI、独立 Web release 构建、Pages staging 和生产发布证明的是不同层级。
- [项目源码](https://github.com/mardd123588/flutter-tutorial/tree/main/examples/capstones/neighborhood_exchange)

## 参考资料

- [Pub workspaces](https://dart.dev/tools/pub/workspaces)（查阅：2026-08-31）
- [Riverpod: Providers](https://riverpod.dev/docs/concepts2/providers)（查阅：2026-08-31）
- [Drift: Web](https://drift.simonbinder.eu/platforms/web/)（查阅：2026-08-31）
- [Drift: Transactions](https://drift.simonbinder.eu/dart_api/transactions/)（查阅：2026-08-31）
- [Navigation and routing](https://docs.flutter.dev/ui/navigation)（查阅：2026-08-31）
- [Flutter accessibility](https://docs.flutter.dev/ui/accessibility-and-internationalization/accessibility)（查阅：2026-08-31）
- [Check app functionality with an integration test](https://docs.flutter.dev/testing/integration-tests)（查阅：2026-08-31）
- [Build and release a web app](https://docs.flutter.dev/deployment/web)（查阅：2026-08-31）
- [Using custom workflows with GitHub Pages](https://docs.github.com/en/pages/getting-started-with-github-pages/using-custom-workflows-with-github-pages)（查阅：2026-08-31）
