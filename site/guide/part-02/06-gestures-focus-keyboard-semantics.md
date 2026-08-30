---
title: 手势、焦点、键盘与语义
description: 让同一操作支持触摸、鼠标和键盘，并为状态变化提供可读语义。
part: 2
order: 6
kind: concept
requires:
  - state.local-basic
  - input.text
provides:
  - input.gesture
  - input.focus
  - input.keyboard
  - a11y.semantics-basic
status: verified
---

# 手势、焦点、键盘与语义

鼠标能点只是交互的一条路径。一个可操作控件还要能获得焦点、响应键盘、暴露语义，并让保存或删除后的状态变化被读到。

## pointer、gesture 和控件分三层

pointer event 是原始的 down、move、up、hover 等输入；gesture 把一串 pointer event 识别成 tap、drag 或 scale；按钮、`InkWell` 等控件再提供视觉、焦点、键盘和语义行为。

选择顺序通常是：

1. 有现成按钮语义时使用 `FilledButton`、`IconButton`、`Checkbox` 等控件。
2. 自定义可点击表面使用 `InkWell` 或 `GestureDetector`，并补齐焦点和语义。
3. 只有需要原始坐标、滚轮或 pan-zoom 数据时才使用 `Listener`。

`MouseRegion` 只处理 enter、exit、hover 和 cursor。它能增加桌面反馈，不能单独让组件可点击或可由键盘操作。

## gesture arena 决定谁获胜

父子 `GestureDetector` 同时识别同一次 tap 时，会把 recognizer 放进 gesture arena，通常只有胜者收到最终回调。`HitTestBehavior.opaque` 或 `translucent` 改变的是命中测试区域，不会让父子 recognizer 同时获胜。

调试竞争时可以临时启用 `debugPrintGestureArenaDiagnostics`，观察 recognizer 如何进入和离开 arena。修复通常来自明确交互边界：避免在父子两层声明同一种 tap，或让不同区域承担不同动作。

## FocusNode 是持久的输入路由节点

键盘事件从 primary focus 开始，沿 focus tree 向祖先传播。局部快捷键要生效，当前焦点必须位于对应的 `Shortcuts` / `Actions` 子树中。

需要命令式 `requestFocus()` 时，把 `FocusNode` 放在 State 中并 dispose。小型展览编辑器在新建后把焦点送到标题字段，资源所有权与 controller 相同。若无需直接操作 node，让 `Focus` 或输入控件内部管理更简单。

`canRequestFocus: false` 会阻止节点成为 primary focus；`skipTraversal: true` 只让 Tab 遍历跳过它，代码仍可显式聚焦。两者不能都解释成“禁用控件”。

`unfocus()` 也不会永久清空焦点，它会把焦点交给 scope 或之前的子级。明确知道下一站时，直接 `requestFocus()` 更可预测。

## Shortcuts、Intent、Action 分开映射与执行

小型展览编辑器同时支持 Windows/Linux 的 Ctrl 和 macOS 的 Meta：

<<< ../../../examples/capstones/micro_gallery_editor/lib/src/gallery_editor.dart#keyboard-shortcuts{dart}

`Shortcuts` 把按键组合映射为 Intent；`Actions` 再把 Intent 类型映射为具体 Action。按钮和快捷键最终调用同一个 `_saveExhibit` 或 `_beginNewExhibit`，不会复制两份业务逻辑。

简单、纯局部的回调可以使用 `CallbackShortcuts`。当命令需要共享实现、根据上下文替换或根据状态启用时，Intent / Action 的边界更清楚。

Flutter 3.47 使用 `KeyEvent`、`HardwareKeyboard` 和 `KeyboardListener`。旧的 `RawKeyEvent`、`RawKeyboard`、`RawKeyboardListener` 已弃用，不进入新代码。文本输入继续交给 `TextField` / `EditableText` 处理软键盘和 IME；`KeyboardListener` 适合非文本硬件按键。

## 语义说明角色、名称、状态和变化

自带 Material 控件通常已有按钮、输入框和 disabled 语义。自定义展签表面使用 `Semantics(button: true, selected: selected, label: ...)`，让辅助技术知道它是可操作、可选中的展品，而不只是几段文字。

语义 label 保留任务所需信息，避免把视觉装饰和重复文字全部拼进去。条码装饰这类没有信息的内容使用 `ExcludeSemantics`。

保存、删除和验证失败不会自动获得焦点。项目用 live region 宣布状态变化：

<<< ../../../examples/capstones/micro_gallery_editor/lib/src/gallery_editor.dart#semantic-status{dart}

live region 应播报重要、短促、真实发生的变化。输入每个字符都更新的提示不适合持续播报，否则会打断用户。

## 先验证结果，不绑定底层事件数量

一个标准按键通常包含 down、零到多个 repeat 和 up；窗口切换时 Flutter 还可能合成事件来同步状态。测试应验证命令结果，不把某个平台产生的底层事件数量写死。

项目的 Widget 测试发送 Ctrl+N，并检查进入新建状态：

<<< ../../../examples/capstones/micro_gallery_editor/test/gallery_editor_test.dart#keyboard-test{dart}

浏览器验收还要实际用 Tab、Shift+Tab、Enter、Space 和快捷键完成主流程，观察焦点环是否可见、顺序是否符合界面阅读关系。

## 可验证任务

在展品列表中完成以下检查：

1. 只用 Tab 和 Enter 选择一件展品，再进入表单修改标题。
2. 添加 Ctrl/Cmd+S 快捷键，让它与保存按钮调用同一命令。
3. 给自定义展签补按钮角色、名称和 selected 状态。
4. 保存失败时用 live region 宣布“请先修正表单中的问题”。
5. 故意在父子两层添加 `onTap`，观察 gesture arena，再移除重复手势边界。

## 复习线索

- pointer 是原始输入，gesture 是识别结果，控件还包含焦点和语义。
- key event 从 primary focus 沿 focus tree 分发。
- `Shortcuts → Intent → Actions` 把按键映射和命令实现分开。
- `MouseRegion` 只增强 hover；`Semantics` 与 live region 补足可读状态。
- Flutter 3.47 使用 KeyEvent API，不使用 RawKeyboard API。

## 参考资料

- [Taps, drags, and other gestures](https://docs.flutter.dev/ui/interactivity/gestures)（查阅：2026-08-30）
- [Understanding Flutter's keyboard focus system](https://docs.flutter.dev/ui/interactivity/focus)（查阅：2026-08-30）
- [Using Actions and Shortcuts](https://docs.flutter.dev/ui/interactivity/actions-and-shortcuts)（查阅：2026-08-30）
- [FocusableActionDetector class](https://api.flutter.dev/flutter/widgets/FocusableActionDetector-class.html)（查阅：2026-08-30）
- [Key event migration](https://docs.flutter.dev/release/breaking-changes/key-event-migration)（查阅：2026-08-30）
- [Semantics class](https://api.flutter.dev/flutter/widgets/Semantics-class.html)（查阅：2026-08-30）

