# 第四部分内容验收记录

验收日期：2026-08-30  
范围：`site/guide/part-04/` 共 8 章  
适用版本：Flutter 3.47.0、Dart 3.13.0

## 内容检查

| 检查 | 结果 |
| --- | --- |
| 页面元数据 | 8 章都标为 `verified`；`requires` 只引用前序概念，`provides` 无重复 |
| 源码引用 | 章节通过命名 region 引用即时书目检索和城市活动雷达的已测试源码 |
| 章节结构 | 每章都有可验证任务或项目完成检查、复习线索，以及带查阅日期的一手资料 |
| 概念顺序 | 先讲 Future、Stream 与 UI 状态，再进入 HTTP、手写 JSON、竞态、生成代码、缓存、Drift 和统筹项目 |
| 技术边界 | 明确区分 timeout 与取消、MockClient 与真实浏览器网络、偏好与缓存、内存测试与 Drift Web 部署 |
| 文风 | 按 `shuorenhua` 的 `docs`、`minimal` 检查，保留 API、命令、路径、版本、数字与限定条件 |
| 站点页面 | 首页出现第四部分当前可学入口；第一章在 1440×900、项目章在 390×844 检查标题、正文和横向溢出 |

`pnpm docs:check` 检查 29 章、85 个概念和 34 个页面。`pnpm docs:build` 完成 client、server bundle 与页面渲染。

## 项目自动化

验收使用 ChromeDriver 151.0.7922.138。ChromeDriver 监听 Flutter Web 集成测试默认使用的 4444 端口。

| 项目 | Analyze | Unit / Widget | Chrome 关键流程 | Release Web |
| --- | --- | --- | --- | --- |
| 即时书目检索 | `flutter analyze` 通过 | 11 项通过 | 先发慢查询，再发快查询；旧响应到达后不能覆盖新结果 | 使用 `/flutter-tutorial/previews/instant-book-search/` base href 构建成功 |
| 城市活动雷达 | `flutter analyze` 通过 | 14 项通过 | 搜索活动、写入 Drift 收藏、切换离线并读取持久化 feed 缓存 | 使用 `/flutter-tutorial/previews/city-event-radar/` base href 构建成功 |

城市活动雷达另行执行 `dart run build_runner build`，同步生成 `event_dto.g.dart` 与 `event_database.g.dart`。Chrome 流程都使用 `flutter drive -d web-server --browser-name=chrome`，并在最终视觉修正后重新执行。

## 界面质量

| 检查 | 即时书目检索 | 城市活动雷达 |
| --- | --- | --- |
| Keyboard | 搜索框、竞态演示、空结果与失败入口均保留原生焦点和按钮行为 | 搜索、分区、只看收藏、网络开关、刷新与收藏均保留原生控件行为 |
| Semantics | 结果状态使用 live region；清除按钮、重试和竞态演示有可识别名称 | 离线通知和空结果使用 live region；雷达图提供当前信号数量，收藏按钮带活动名称 |
| Responsive | 320×720、768×900、1440×900 无横向溢出；窄屏先显示主结果，再显示请求登记簿 | 320×720、768×900、1440×900 无横向溢出；窄屏在扫描面前显示来源和更新时间摘要 |
| Text scale | 320px、200% 文本缩放 Widget 测试通过 | 320px、200% 文本缩放 Widget 测试通过 |
| Motion | 240ms 结果切换；`disableAnimations` 时使用零时长 | 720ms 雷达入场；`disableAnimations` 时使用零时长 |
| Visual | 独立 finish review 复核两项修正后结论为 `ship` | 独立 finish review 复核两项修正后结论为 `ship` |

截图保存在各项目的 `.impeccable/review/`：

- `mobile.png`
- `tablet.png`
- `desktop.png`

六张截图都在交给 reviewer 前打开检查。第一次捕获只得到 Flutter 启动帧，已判为无效并重拍；最终截图包含对应项目首屏，宽度与文件名一致。

两个项目都生成了 `DESIGN.md` 与 `.impeccable/design.json`。sidecar 已通过 JSON 解析，并保留配色、组件、动效和设计规则；界面材质由项目内 `CustomPainter` 与 Flutter 控件绘制，没有外部图片或第三方字体资产。

## 验收中修正的问题

- 城市活动雷达的集成测试最初直接点击视口外控件，并用固定等待猜测 Drift 查询流何时更新。测试改为先滚到控件可见，再订阅目标收藏 ID 后执行点击。
- 即时书目检索的集成测试最初用两个固定 `pump` 等待竞态结果。浏览器调度较慢时会提前断言；最终改为在 5 秒上限内按 50ms 推进，直到目标结果出现。
- 即时书目检索的窄屏最初先显示完整请求登记簿，把主结果推到首屏外。最终顺序改为检索校样在前、登记簿在后。
- 即时书目检索蓝底上的小号金色文字对比度不足。文字改为纸白，金色只保留边框与高亮下划线。
- 城市活动雷达的窄屏最初要滚过大型扫描面才能看到来源与更新时间。最终在扫描面前加入紧凑数据出处条。
- 城市活动雷达纸面上的告警红文字对比度不足。文字色改为 `#8F2F27`；大面积告警底仍使用原来的 `#C94A3D`。

## Web 发布边界

城市活动雷达的 release 产物包含 `sqlite3.wasm` 与 `drift_worker.js`。构建成功不能证明部署服务器会返回正确的 Worker URL、Wasm URL 与 `application/wasm` MIME；GitHub Pages 发布后仍要在真实站点检查这三项。Drift 内存测试也不证明浏览器持久化、多标签页协调或存储配额行为。
