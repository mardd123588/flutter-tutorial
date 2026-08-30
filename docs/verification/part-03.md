# 第三部分内容验收记录

验收日期：2026-08-30
范围：`site/guide/part-03/` 共 7 章
适用版本：Flutter 3.47.0、Dart 3.13.0

## 内容检查

| 检查 | 结果 |
| --- | --- |
| 页面元数据 | 7 章都标为 `verified`；`requires` 只引用前序概念，`provides` 无重复 |
| 源码引用 | 章节通过命名 region 引用可排序值班板和植物照护台的已测试源码 |
| 章节结构 | 每章都有验证任务或项目检查、复习线索，以及带查阅日期的一手资料 |
| 概念顺序 | 先讲状态所有权与生命周期，再进入 Element、Key、通知机制和动画；项目只使用前面已经解释的机制 |
| 文风 | 按 `shuorenhua` 的 `docs`、`minimal` 检查，保留 Flutter 术语、命令、路径、代码标识和限定条件 |

`pnpm docs:check` 检查 21 章、61 个概念和 26 个页面。第三部分 7 章均通过任务、复习线索、参考资料、查阅日期、知识依赖与源码 region 检查。

## 项目自动化

验收使用 ChromeDriver 151.0.7922.138。ChromeDriver 监听 Flutter Web 集成测试默认使用的 4444 端口。

| 项目 | Analyze | Unit / Widget | Chrome 关键流程 | Release Web |
| --- | --- | --- | --- | --- |
| 可排序值班板 | `flutter analyze` 通过 | 7 项通过 | 填写安岚的交接备注并下移，备注仍属于安岚 | `flutter build web --release` 成功 |
| 植物照护台 | `flutter analyze` 通过 | 10 项通过 | 筛选待照护植物、记录浇水并撤销，数据与筛选条件恢复 | `flutter build web --release` 成功 |

两个 Chrome 流程都使用 `flutter drive -d web-server --browser-name=chrome`。集成测试在最终视觉重建后重新执行。

## 界面质量

| 检查 | 可排序值班板 | 植物照护台 |
| --- | --- | --- |
| Keyboard | 保留拖动与明确的上移、下移按钮；Tab / Enter 实测路径未因绘制层重建改变 | 筛选片、查看观察、记录浇水与撤销都保留原生按钮语义 |
| Semantics | 成员行包含姓名、呼号和位置，拖动按钮有成员名 | 植物行包含名称、区域、湿度与目标，回执使用 live region |
| Responsive | 320×720、768×900、1440×900 无横向溢出 | 320×720、768×900、1440×900 无横向溢出 |
| Text scale | 320×720、200% 文本缩放 Widget 测试通过 | 320×720、200% 文本缩放 Widget 测试通过 |
| Motion | 列表重排沿用 Flutter 控件行为，没有循环或装饰动画 | 读数使用 480ms 隐式动画，回执使用 360ms 显式动画；reduced motion 直接显示终态 |
| Visual | 活字装版台材料通过独立 finish review，结论为 `ship` | 温室仪表材料通过独立 finish review，结论为 `ship` |

截图保存在各项目的 `.impeccable/review/`：

- `mobile.png`
- `tablet.png`
- `desktop.png`

两个项目都生成了 `DESIGN.md` 与 `.impeccable/design.json`。sidecar 已通过 JSON 解析；界面材质全部由项目内 `CustomPainter` 绘制，没有外部图片或第三方字体资产。

## 验收中修正的问题

- 两个项目原先缺少 viewport meta，移动浏览器会使用桌面宽度。补上 `width=device-width, initial-scale=1.0` 后，320px 浏览器的内容宽度与视口一致。
- 可排序值班板原先只有纯色矩形，未兑现墨石、锌条和校样纸的方向。最终版加入石台纹理、金属导轨、紧固件、纸纤维、套准标记和衬线标题。
- 植物照护台原先使用两张指标卡和水平进度条。最终版改为一行观测摘要，以及带刻度、目标线、铜针、滑尺和检修戳的湿度仪表。
- 两个界面都补充“教学示例数据”说明，避免把固定人物、站点、植物和读数误解为真实记录。
- 浏览器验收截图受本机 150% 显示缩放影响。截图按真实目标视口渲染，再对固定缩放做机械校正；响应式断点仍以 320、768、1440 的实际布局约束检查。
