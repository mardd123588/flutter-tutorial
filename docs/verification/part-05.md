# 第五部分内容验收记录

验收日期：2026-08-30  
范围：`site/guide/part-05/` 共 7 章  
适用版本：Flutter 3.47.0、Dart 3.13.0、`go_router 18.0.0`、`intl 0.20.3`

## 内容检查

| 检查 | 结果 |
| --- | --- |
| 页面元数据 | 7 章都标为 `verified`；`requires` 只引用前序概念，`provides` 无重复 |
| 源码引用 | 05-03 与 05-07 通过命名 region 引用路线分享卡和场馆导览册的已测试源码 |
| 章节结构 | 每章都有可验证任务或项目完成检查、复习线索，以及带查阅日期的一手资料 |
| 概念顺序 | 先讲 Navigator 页面栈，再进入 Router、URL、深链接、响应式、可访问性、本地化和统筹项目 |
| 项目边界 | 路线分享卡只在 05-03 完整讲解；场馆导览册只在 05-07 完整讲解，05-04～05-06 使用独立小例子 |
| 技术边界 | 明确区分 Router 与 Navigator、浏览器历史与页面栈、URI 语法与领域验证、响应式与设备分类、RTL 测试与真实语言支持 |
| 文风 | 按 `shuorenhua` 的 `docs`、`minimal`、`structural` 检查，保留 API、命令、路径、版本、数字和适用条件 |

`pnpm docs:check` 检查 36 章、111 个概念和 41 个页面。`pnpm docs:build` 完成 client、server bundle 与页面渲染。

## 项目自动化

| 项目 | Analyze | Unit / Widget / Golden | Chrome 关键流程 | Release Web |
| --- | --- | --- | --- | --- |
| 路线分享卡 | `flutter analyze` 通过 | 10 项通过 | 打开路线并把 mode 写入 URL；浏览器另验直达、刷新、Back、Forward 和新标签复制 | 使用 `/flutter-tutorial/previews/route-share-card/` base href 构建成功 |
| 场馆导览册 | `flutter analyze` 通过 | 18 项通过 | 搜索地点、进入详情、切换楼层和语言，URI 保持 `/venues/atrium?floor=2` | 使用 `/flutter-tutorial/previews/venue-guidebook/` base href 构建成功 |

两项测试都从仓库根 workspace 执行。依赖求解提示 9 个包存在与当前约束不兼容的更新版本，不影响本次基线；本次不修改依赖版本。

## 场馆导览册质量矩阵

| 检查 | 结果 |
| --- | --- |
| Navigation | 普通 `ShellRoute` 承载地点、路线、关于；未知资源、非法 query 与未匹配地址分开处理 |
| Keyboard | `/` 跨顶层页面聚焦搜索，输入框内保留普通字符语义；Escape 关闭 Drawer |
| Semantics | 结果数量使用 live region；楼层图只提供 image 摘要；房间列表承担按钮与 selected 状态 |
| Responsive | 320×720、768×900、1440×900 通过；900px 以下 Drawer，以上 Rail |
| Text scale | 320×720、200% 文本缩放 Widget 测试通过 |
| Localization | 中文与英文切换后保留 path、query、搜索文本和焦点；ARB 覆盖 placeholder、plural 与日期 |
| Directionality | RTL 测试壳通过；文档明确不把它写成完整 RTL 语言支持 |
| Motion | `disableAnimations` 时楼层切换使用零时长 |
| Visual | 宽屏地点页与紧凑详情页两张 deterministic golden 通过 |

浏览器验收另行覆盖 hash 深链接直达、刷新、Back / Forward、语言切换和键盘输入边界。Widget 测试不代替 GitHub Pages 子路径与浏览器历史检查。

## 界面材料

两个项目都包含 `DESIGN.md`、`.impeccable/design.json` 和桌面、平板、移动尺寸截图。路线分享卡使用防水骑行 cue sheet 语言；场馆导览册使用折页式公共导视手册语言。两者都使用本地系统字体、自绘图形和 Flutter 控件，没有远程图片或第三方字体。

场馆导览册 finish review 结论为 `ship`。楼层图只保留一条语义摘要，房间操作全部位于真实列表；这个决定同时满足视觉概览与键盘、屏幕阅读器操作边界。

## Web 发布边界

两个项目继续使用 hash URL。VitePress 位于 `/flutter-tutorial/`，项目预览位于 `/flutter-tutorial/previews/<project-slug>/`；release 构建必须使用完整 `--base-href`。

GitHub Pages 没有 Flutter Path 策略所需的任意路径 rewrite。本地开发服务器可以刷新，不代表 Pages 上的 path URL 可用。发布后仍要从真实子路径打开 hash 深链接，并检查静态资源、刷新和浏览器历史。
