# 全教程第三轮总复核

> 复核日期：2026-09-01
> 基线提交：`7382ffc`
> 范围：13 个 Flutter 项目的 analyze、全部测试、Chrome 集成测试、Web release 构建、golden、生成代码和 Pages staging artifact。

## 验证环境

- Flutter 3.47.0，Dart 3.13.0；
- Node.js 26.7.0，pnpm 10.34.5；
- Chrome 151.0.7922.174；
- ChromeDriver 151.0.7922.138，与 Chrome 同属 `151.0.7922` build。

验证脚本会把项目、commit、工具版本、端口、命令、退出码、analyze / test / integration 日志和 ChromeDriver 日志写入 `build/ci-logs/<slug>/`。Windows 本地运行现在会寻找标准 Chrome 安装位置和仓库内的 ChromeDriver；CI 仍可用 `CHROME_BINARY`、`CHROMEDRIVER_BINARY` 和 PATH 覆盖。

## 13 项矩阵

| 项目 | 普通测试 | Chrome 集成测试 | Web release |
| --- | ---: | --- | --- |
| `daily-rhythm-board` | 5 | 通过 | 通过 |
| `ticket-layout-studio` | 7 | 通过 | 通过 |
| `micro-gallery-editor` | 9 | 通过 | 通过 |
| `sortable-duty-board` | 7 | 通过 | 通过 |
| `plant-care-desk` | 10 | 通过 | 通过 |
| `instant-book-search` | 11 | 通过 | 通过 |
| `city-event-radar` | 14 | 通过 | 通过 |
| `route-share-card` | 10 | 通过 | 通过 |
| `venue-guidebook` | 18 | 通过 | 通过 |
| `community-workshop-scheduler` | 25 | 通过 | 通过 |
| `scroll-timeline` | 11 | 通过 | 通过 |
| `digital-archive-browser` | 16 | 通过 | 通过 |
| `neighborhood-exchange` | 26 | 通过 | 通过 |

合计 169 项普通测试。每个项目都通过 `flutter analyze`；Chrome 集成测试统一使用 1440×900 的 headless Chrome 主旅程；13 个项目都完成独立 Web release 构建，并通过各自的 base href、本地 CanvasKit、空 `flutter_service_worker.js` 和声明资产检查。

## 本轮修正

### 票券排版器

Chrome 中文字体让横向标准票需要 220px 高度，原来的 `IntrinsicHeight` 只给主区留下 164px，产生 6px 的底部溢出。横向票面现在声明 220px 最低高度，并补了 1440×900 下切换窄票的 Widget 回归测试。

这项布局修正使 `ticket-layout-studio.png` 产生 0.92% 差异。已对比 master、test 和 isolated diff；变化只在票面底边向下移动 6px，内容、颜色和对齐关系没有变化，因此更新该基准图。其余四张 golden 原样通过。

### 社区工坊排期台

原 Chrome 流程用同名时间文本选择离屏下拉项，结束时间没有真正改变，后续断言也没有直接检查 Drift。流程改为选择“周日 · 9月13日”“共享大厅 · 64 人”和“陈牧”，在不依赖离屏菜单的情况下同时解除场馆、讲师和容量冲突。

保存后直接读取 Drift，核对本地记录的日期、场馆、讲师和预计人数；关闭数据库并重建应用后，再用该记录的详情 URL 验证“预计 30 人”。重开验收现在确实覆盖新增记录，不再用 fixture 标题代替持久化证据。

### 邻里资源交换站

宽屏详情面板和内部 `ListView` 原来共用 `detail-<id>`，集成测试因此找到两个 Widget。内部滚动容器不再复用面板 key；发布、首次重开、认领和第二次重开之间还增加了异步异常检查，避免多个异常到测试结束时才被合并报告。

### 验证与字体

- Windows ChromeDriver 安装改用系统 `tar` 解压，不再要求额外安装 `unzip`；
- `verify_project.mjs` 可直接使用仓库内驱动，也能从 Windows 标准目录读取 Chrome 版本；
- `flutter drive -d web-server` 不支持 `--screenshot`，验证脚本已移除该参数，研究记录也不再声称失败 artifact 自动包含截图；
- 11 个实际引用 Cupertino 字体的项目显式依赖 `cupertino_icons 1.0.9`。release 构建现在会打包并 tree-shake `CupertinoIcons.ttf`，不再出现缺字体警告；`daily-rhythm-board` 和 `ticket-layout-studio` 的构建没有引用该字体，未增加无用依赖。

## Golden 与生成代码

仓库共有 5 张 golden：票券排版器 1 张、场馆导览册 2 张、长卷时间轴 2 张。五张都通过；只有上文说明的票券基准图因真实布局修正而更新。

以下三个项目重新运行 `dart run build_runner build`：

- `city-event-radar`；
- `community-workshop-scheduler`；
- `neighborhood-exchange`。

提交中的 `.g.dart` 与重新生成结果一致，没有源码差异。当前 build_runner 已忽略移除的 `--delete-conflicting-outputs` 选项，后两次复验使用不带该参数的命令。

## Pages staging artifact

`pnpm docs:build` 完成 VitePress client、server bundle 和页面渲染。随后重新构建 13 个 Flutter 预览，并执行：

```text
pnpm release:stage
pnpm release:smoke
```

`release-manifest.json` 含 13 个预览。staging smoke 请求站点入口、项目索引、manifest、13 个预览入口、hash URL 对应的 HTTP 入口，以及项目声明的 Wasm / Worker 资源，并核对状态码与 MIME。artifact 中实际有 81 个 `.wasm` 文件和 16 个 Worker 文件，其中包括本地 CanvasKit 资源以及三个 Drift 项目的 `sqlite3.wasm`、`drift_worker.js`。

## 仍保留的边界

- Flutter 3.47.0 会提示 `--pwa-strategy=none` 已弃用。本教程把它限定为当前版本关闭默认 offline-first Worker 的过渡参数，并继续验证生成的 `flutter_service_worker.js` 为 0 字节；升级 Flutter 时必须重新核对。
- Flutter Web 构建会执行 Wasm dry run；本轮通过的是默认 JavaScript release 产物，不把 dry run 扩大成 `--wasm` 发布证据。
- VitePress 报告部分 chunk 超过 500kB。这不影响当前构建和 staging smoke，但后续若加入更多客户端功能，应单独评估拆包。
- 本轮验证的是本地 Chrome 和 Pages staging。production Pages、缓存更新和旧 Service Worker 注销仍需首次线上部署后验收。
