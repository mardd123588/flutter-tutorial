# 邻里资源交换站

第八部分的统筹项目。它把 pub workspace、Riverpod、fixture Service、Drift Web、hash URL、响应式界面、Chrome 集成测试和独立 release 构建放进同一个可发布应用。

项目内置 48 条资源，覆盖 6 个片区和 6 个类别。宽屏使用筛选、列表、详情三栏；中等宽度保留行内筛选；窄屏把筛选放进 bottom sheet，详情和发布改为独立页面。

## 数据边界

- fixture 随构建发布，`#/listings/r-001` 这类链接可以在其他浏览器恢复。
- 发布和认领写入当前浏览器的 Drift 数据库，不会同步到其他设备或其他用户。
- `local-...` 链接在没有对应本地数据的浏览器中只显示边界说明。
- 项目不连接远程服务，不处理账号、聊天、支付、精确住址、真实多人竞争或服务端库存。

认领事务用 `(listingId, claimantId)` 唯一键保证重复请求幂等。最后一份被认领后，资源状态从 `available` 变为 `reserved`。这只能证明本地顺序事务正确，不能代表真实多用户并发已经解决。

## 运行与测试

在项目目录运行：

```powershell
flutter run -d chrome
flutter analyze
flutter test
```

从仓库根目录执行完整 Web 验证。脚本会运行 analyze、Unit / Widget、Chrome integration 和独立 release 构建，并把失败日志写入 `build/ci-logs/neighborhood-exchange/`：

```powershell
node tool/ci/verify_project.mjs --project neighborhood-exchange --integration --build
```

Chrome integration 需要与本机 Chrome 匹配的 ChromeDriver。CI 使用 `tool/ci/install_chromedriver.mjs` 按 Chrome build 下载对应版本，并在独立 job 中使用固定端口。

## Release 与 Pages staging

从仓库根目录构建当前项目，再把 13 个预览与 VitePress 站点合并：

```powershell
pnpm release:build:exchange
pnpm release:stage
pnpm release:smoke
```

release 构建固定使用：

```text
--pwa-strategy=none
--no-web-resources-cdn
--base-href /flutter-tutorial/previews/neighborhood-exchange/
```

`--pwa-strategy=none` 是 Flutter 3.47.0 的过渡参数，已经弃用。升级 Flutter 时要重新核对工具行为，不能直接沿用。staging 会检查入口、hash 深链接、`sqlite3.wasm`、`drift_worker.js`、本地 CanvasKit 和 0 字节 Service Worker。

## 测试范围

- Unit / Repository / Drift：fixture、筛选、字段边界、幂等认领、状态转换、恢复演示数据和本地链接边界。
- Widget / Semantics：loading、empty、error、retry、URL 恢复、发布错误焦点、认领 live region、320×720、768×900、1440×900、200% 文本、RTL，以及减少动画时移除详情过渡。
- Chrome：发布本地资源、重新打开本地状态、认领 fixture 并验证刷新后的持久化。
- Visual：`not-applicable`，不维护 golden；实际浏览器已检查三档尺寸，控制台没有 error 或 warn。

所有人物、片区和资源说明均为教学用虚构数据。
