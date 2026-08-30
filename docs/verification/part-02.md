# 第二部分内容验收记录

验收日期：2026-08-30  
范围：`site/guide/part-02/` 共 7 章  
适用版本：Flutter 3.47.0、Dart 3.13.0

## 内容检查

| 检查 | 结果 |
| --- | --- |
| 页面元数据 | 7 章都标为 `verified`；`requires` 只引用前序概念，`provides` 无重复 |
| 源码引用 | 章节通过命名 region 引用票券排版器和小型展览编辑器的已测试源码 |
| 章节结构 | 每章都有可验证任务或项目完成检查、复习线索，以及带查阅日期的一手资料 |
| 概念顺序 | 布局从约束进入，再讲组合、滚动、组件接口、输入和交互；提前出现的测试、响应式和语义代码都只作当前任务所需的简短说明 |
| 文风 | 按 `shuorenhua` 的 `docs`、`minimal` 检查，保留 Flutter 术语、命令、错误原文和限定条件 |
| 站点页面 | 7 章都在 1440×900 与 390×844 检查标题、正文、章节导航和横向溢出；窄屏章节菜单可完整打开 |

`pnpm docs:check` 检查 14 章、42 个概念和 19 个页面。第二部分 7 章均通过任务、复习线索、参考资料、查阅日期、知识依赖与源码 region 检查。

## 项目自动化

验收使用 Chrome 151.0.7922.174 与 ChromeDriver 151.0.7922.138。ChromeDriver 监听 Flutter Web 集成测试默认使用的 4444 端口。

| 项目 | Analyze | Unit / Widget | Chrome 关键流程 | Release Web |
| --- | --- | --- | --- | --- |
| 票券排版器 | `flutter analyze` 通过 | `flutter test examples/focus/ticket_layout_studio/test`，6 项通过，含 golden | `integration_test/ticket_layout_studio_test.dart` 通过 | 使用 `/flutter-tutorial/previews/ticket-layout-studio/` base href 构建成功 |
| 小型展览编辑器 | `flutter analyze` 通过 | `flutter test examples/capstones/micro_gallery_editor/test`，9 项通过 | `integration_test/gallery_editor_test.dart` 通过 | 使用 `/flutter-tutorial/previews/micro-gallery-editor/` base href 构建成功 |

两个 Chrome 关键流程均使用 `flutter drive -d web-server --browser-name=chrome`。票券排版器切换票面预设；小型展览编辑器先复现年份错误，再修正资料并新增展品。

## 界面质量

| 检查 | 票券排版器 | 小型展览编辑器 |
| --- | --- | --- |
| Keyboard | Tab 与 Enter 可切换票面预设 | 筛选、Ctrl+N、Ctrl+S 与表单焦点流程可用 |
| Semantics | 预设按钮保留可识别名称与选中状态 | 选中展品暴露 button / selected flags，保存状态使用 live region |
| Responsive | 320×720、768×900、1440×900 无横向溢出 | 320×720、768×900、1440×900 无横向溢出 |
| Text scale | 320×720、200% 文本缩放 Widget 测试通过 | 320×720、200% 文本缩放 Widget 测试通过 |
| Motion | `not-applicable`，项目没有补间或循环动画 | `not-applicable`，项目没有补间或循环动画 |
| Visual | 标准票确定性 golden 通过 | `not-applicable`，首版规格不要求该项目维护 golden |

截图保存在各项目的 `.impeccable/review/`：

- `ticket-mobile.png`、`ticket-tablet.png`、`ticket-desktop.png`
- `gallery-mobile.png`、`gallery-tablet.png`、`gallery-desktop.png`

## 验收中修正的问题

- 小型展览编辑器的搜索图标最初显示为缺字方框。项目在 `pubspec.yaml` 中启用 `uses-material-design: true` 后，release Web 页面显示正常。
- Ctrl+N 创建空白展签时，表单最初立即显示所有错误。加入 `_showValidation` 后，空白表单保持可编辑；首次提交失败后才进入自动验证状态。
- 票券移动端和平板截图第一次在 Flutter Web 尚未加载时保存，只得到空白帧。重新加载并等待页面完成渲染后重拍。
- Flutter 3.47 将 `SemanticsNode.hasFlag` 标为弃用。语义测试改用 `flagsCollection` 后，静态分析与 9 项展览项目测试通过。
