---
title: 项目：小型展览编辑器
description: 用一个独立 Web 项目复习布局选择、组件接口、表单、筛选、键盘和语义。
part: 2
order: 7
kind: capstone
requires:
  - layout.constraints
  - layout.size-choice
  - layout.overflow-diagnosis
  - layout.flex
  - layout.wrap
  - layout.stack
  - layout.scrollable
  - layout.lazy-list
  - layout.grid
  - component.api
  - component.slot
  - theme.tokens
  - input.text
  - input.form
  - input.validation
  - state.local-basic
  - input.gesture
  - input.focus
  - input.keyboard
  - a11y.semantics-basic
provides:
  - project.micro-gallery-editor
project: micro-gallery-editor
status: verified
---

# 项目：小型展览编辑器

这章一次讲完统筹项目。先按项目简报实现，再回来对照结构、测试和取舍；后续章节不会继续拆解这个项目。

项目把[约束](/guide/part-02/01-constraints)、[滚动与网格](/guide/part-02/03-scrolling-lists-grids)、[组件接口](/guide/part-02/04-component-interfaces)、[表单验证](/guide/part-02/05-text-input-and-forms)和[焦点、键盘与语义](/guide/part-02/06-gestures-focus-keyboard-semantics)放进同一条编辑流程。单项 API 回到对应章节，本章只讲项目内的数据流与取舍。

## 项目简报

小型展览编辑器服务一面临时展墙。策展人可以筛选现有展签，选择一件展品修改资料，也可以新建或删除展品。所有数据留在内存中，刷新页面会恢复种子数据。

必须完成的功能：

- 展墙显示标题、艺术家、年份和材料；
- 可按标题、艺术家或材料筛选展品卡；
- 支持新增、编辑、保存和删除；
- 标题、艺术家、年份、材料和说明都经过同步验证；
- Ctrl/Cmd+N 新建，Ctrl/Cmd+S 保存；
- 宽屏把展墙与编辑台并排，窄屏改为上下排列；
- 320×720 和 200% 文本缩放下不出现 overflow；
- 鼠标、键盘和语义树都能完成或理解主要操作。

视觉方向是“可移动展签轨道”：深蓝展墙、纸色展签、黄铜分隔与珊瑚色操作。界面不使用默认卡片网格换皮，标准 Material 控件仍保留熟悉的输入和按钮行为。

## 先运行验收

项目路径：`examples/capstones/micro_gallery_editor`。

```powershell
flutter analyze
flutter test examples/capstones/micro_gallery_editor/test
cd examples/capstones/micro_gallery_editor
flutter run -d chrome
```

Web release 构建使用最终预览路径：

```powershell
flutter build web --release --base-href /flutter-tutorial/previews/micro-gallery-editor/
```

Chrome 集成测试由 `integration_test/gallery_editor_test.dart` 驱动。它需要与当前 Chrome build 匹配的 ChromeDriver，运行方式会在[Web 浏览器关键流程](/guide/part-07/03-web-integration)中系统讲解。

## 状态保持在页面内

项目当前只有页面内数据，不引入 Repository、数据库或全局状态管理。页面持有：

- 展品列表和当前选中 ID；
- 筛选词；
- 五个字段 controller 与标题 FocusNode；
- 最近一次用户操作的状态文本。

显示中的展品由筛选词和完整列表推导，不另存一份可变“筛选结果”。保存时根据 selected ID 决定新增还是替换；删除后选择相邻展品，列表为空时清空表单。

这组状态足以支撑当前任务。第三部分会讨论状态所有权和派生状态，当前项目不提前套用完整应用架构。

## 布局按内容规模选择

页面只有一个 `SingleChildScrollView`。数据量固定且很小，展签使用 Wrap 自然换行；它没有伪装成 lazy list。第三章的 1000 项任务已经单独验证 builder 与 GridView，当前项目按真实内容规模选择更简单的结构。

宽度达到 980 时，`Row` 给展墙剩余空间，编辑台固定为 420；窄屏改成 Column。展签本身不写固定高度，长标题和文本缩放可以把纸签撑高。

筛选框使用 `onChanged`，因为页面只需要响应当前文本；编辑字段使用 controller，因为选择、新建和删除都会主动改写整组内容。两种输入方式各自服务不同需求。

## 组件接口保留展览语义

`_GalleryWall` 接收展品、选中 ID、筛选词与回调；`_ExhibitLabel` 接收一件展品、选中状态和选择回调；`_EditorLedger` 接收由页面拥有的 controller、FocusNode 与保存删除动作。

展签不直接修改列表，编辑台也不 dispose 外部 controller。内部布局可以换成网格或列表，调用方仍然围绕“选择展品”“保存展签”阅读代码。

项目使用模块内视觉常量和 Material 主题。若同一套展览角色需要扩展到更多页面，再把黄铜、展墙和展签角色提升为 `ThemeExtension`；一个页面还不需要先建立通用设计系统。

## 表单提交只有一条路径

保存按钮和 Ctrl/Cmd+S 都调用同一个保存方法。方法先执行 `FormState.validate()`，失败时只更新状态；通过后统一 trim 字段、建立 Exhibit，再新增或替换。

validator 保持纯同步，单元测试直接覆盖空值、合法年份、非数字和越界年份。项目没有远程服务，因此不添加假的网络 loading、重试或异步唯一性检查。

## 键盘和语义跟着任务走

新建动作清空字段后，把焦点送到标题。展签暴露 button、selected 和包含作品信息的 label；条码类装饰不进入语义树。保存、删除与验证失败写入 live region，让焦点仍在字段中时也能收到结果。

浏览器验收至少走一遍：

1. 用 Tab 到达“新建”，按 Enter。
2. 填写无效年份并保存，确认字段错误可读。
3. 修正年份，用 Ctrl/Cmd+S 保存。
4. 用筛选框找到新展品，再用键盘选择。
5. 删除展品，确认状态与下一选中项同步。

## 测试覆盖用户能观察到的结果

项目现有证据包括：

- 单元测试：必填和年份规则；
- Widget 测试：空表单错误、新增成功、筛选、Ctrl+N、320×720 与 200% 文本；
- Chrome 集成测试：完整 Web 应用中修正验证错误并新增展品；
- Web release 构建：使用 Pages 预览 base href。

响应式测试不读取私有断点，只检查目标视口完成布局且没有异常：

<<< ../../../examples/capstones/micro_gallery_editor/test/gallery_editor_test.dart#responsive-test{dart}

自动化测试不能替代实际键盘顺序、焦点可见性、对比度和语义阅读。项目状态矩阵会分别记录这些人工检查。

## 项目完成检查

- [ ] 能说明为什么完整列表是状态，筛选结果是派生值。
- [ ] 能解释筛选框使用 `onChanged`、编辑字段使用 controller 的原因。
- [ ] 能指出宽屏和窄屏分别由哪一层约束决定。
- [ ] 能让按钮与快捷键调用同一个保存动作。
- [ ] 能用键盘完成新增、修正验证错误、保存、筛选和删除。
- [ ] 能说明展签、状态消息和装饰分别如何进入或排除语义树。
- [ ] analyze、单元测试、Widget 测试、Chrome 集成测试和 Web release 构建全部通过。

## 复习线索

- [项目源码](https://github.com/mardd123588/flutter-tutorial/tree/main/examples/capstones/micro_gallery_editor)
- 约束与布局选择：02-01～02-03。
- 组件接口与主题令牌：02-04。
- 表单、焦点、快捷键与语义：02-05～02-06。

## 参考资料

- [Layouts in Flutter](https://docs.flutter.dev/ui/layout)（查阅：2026-08-30）
- [Build a form with validation](https://docs.flutter.dev/cookbook/forms/validation)（查阅：2026-08-30）
- [Understanding Flutter's keyboard focus system](https://docs.flutter.dev/ui/interactivity/focus)（查阅：2026-08-30）
- [Using Actions and Shortcuts](https://docs.flutter.dev/ui/interactivity/actions-and-shortcuts)（查阅：2026-08-30）
- [Semantics class](https://api.flutter.dev/flutter/widgets/Semantics-class.html)（查阅：2026-08-30）
- [Build and release a web app](https://docs.flutter.dev/deployment/web)（查阅：2026-08-30）
