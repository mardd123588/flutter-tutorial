---
title: 文本输入、表单与验证
description: 管理文本 controller、同步验证和提交状态，建立清楚的输入资源所有权。
part: 2
order: 5
kind: concept
requires:
  - dart.callbacks
  - component.api
  - state.ephemeral-basic
provides:
  - input.text
  - input.form
  - input.validation
  - state.local-basic
status: verified
---

# 文本输入、表单与验证

文本输入有两类状态：字段里正在编辑的值，以及一次提交是否通过。`TextField`、controller 和 Form 分别处理不同层次，不应让 validator 同时承担网络请求、保存和错误恢复。

## `onChanged` 与 controller 的选择

只需要在文本变化时更新一个值，`onChanged` 最直接：

```dart
TextField(
  onChanged: (value) => setState(() => query = value),
)
```

需要主动读写文本、清空字段、移动 selection，或在“选择展品”时整组替换内容，再使用 `TextEditingController`。

controller 是跨 build 存活的对象。小型展览编辑器由页面 `State` 创建并释放五个 controller 和标题焦点：

<<< ../../../examples/capstones/micro_gallery_editor/lib/src/gallery_editor.dart#input-lifecycle{dart}

不要在 `build` 或 lazy list 的 `itemBuilder` 中临时 `TextEditingController()`。重建会丢失对象身份，列表项移出 viewport 后也可能丢失内部编辑状态。

自己传了 controller 时，controller 的 `text` 就是初值，不能再同时给 `TextFormField.initialValue`。若 listener 中再次修改 `text` 或 selection，还要防止通知循环；输入格式化优先使用 `TextInputFormatter`。

## Form 负责协调多个字段

`TextFormField` 是把 `TextField` 放进 `FormField<String>` 的便利组件。单个字段可以独立工作；当保存动作需要一起验证标题、艺术家、年份和说明时，用 `Form` 统一调用更清楚。

小型展览编辑器把 `GlobalKey<FormState>` 保存在 State 字段中，没有在 `build` 里反复创建。字段只声明标签、输入行为和 validator：

<<< ../../../examples/capstones/micro_gallery_editor/lib/src/gallery_editor.dart#form-fields{dart}

`textInputAction: TextInputAction.next` 告诉软键盘这是连续字段；多行说明使用 newline。它们影响输入体验，不替代焦点顺序和键盘可操作性检查。

## validator 是同步函数

validator 无错误返回 `null`，有错误返回显示给用户的字符串。项目把可独立测试的规则留在普通 Dart 函数中：

<<< ../../../examples/capstones/micro_gallery_editor/lib/src/gallery_data.dart#validation{dart}

`FormState.validate()` 会依次运行后代字段的 validator，更新错误显示，并在全部通过时返回 `true`。项目先验证，再读取 controller：

<<< ../../../examples/capstones/micro_gallery_editor/lib/src/gallery_editor.dart#form-submit{dart}

先读取再校验会让无效值进入模型；校验失败后仍继续保存，也会让字段错误和页面状态互相矛盾。

## 本地错误与异步错误分开

`FormFieldValidator` 不是 async API。必填、格式和范围这类本地规则放在 validator；用户名是否已占用、网络保存失败和服务端冲突需要独立的异步状态。

可靠的提交顺序通常是：

1. 运行本地同步验证。
2. 通过后把提交状态改为进行中，并防止重复提交。
3. 执行异步动作。
4. 成功后更新页面；失败后显示服务端错误和重试入口。

第四部分会实现异步状态与竞态。本章项目只保存到内存列表，因此提交状态只有“验证失败”和“已保存”两类真实结果，不伪造远程 loading。

## 错误提示要说明恢复动作

“年份需为 1000—2099 的四位数字”同时给出格式和范围，比“输入有误”更容易修正。页面级状态“请先修正表单中的问题”负责宣布提交未完成，字段级错误指出具体位置。

项目在第一次提交失败前关闭自动校验；失败后才切到 `AutovalidateMode.onUserInteraction`，让错误随后续输入更新。这样新建空表单时保持干净，用户尝试提交后又能立即看到修正结果。是否采用这一策略取决于任务，不是 Form 的强制规则。

Widget 测试从用户动作验证错误，不读取私有 FormState：

<<< ../../../examples/capstones/micro_gallery_editor/test/gallery_editor_test.dart#validation-test{dart}

成功路径则填写所有字段并检查新增结果：

<<< ../../../examples/capstones/micro_gallery_editor/test/gallery_editor_test.dart#new-exhibit-test{dart}

## 可验证任务

给一个“新增展品”表单补齐以下行为：

1. 标题只需要响应变化，先用 `onChanged`；年份需要保存时统一读取，使用 controller。
2. 必填字段拒绝纯空格，年份只接受 1000～2099。
3. 首次打开不显示错误；提交空表单后显示字段错误和页面状态。
4. 校验通过后新增一条记录并清楚说明保存结果。
5. Widget 测试覆盖一次失败和一次成功，不通过私有字段判断结果。

## 复习线索

- `onChanged` 处理简单变化；controller 用于主动读写和完整编辑值。
- controller、FocusNode 和 GlobalKey 要跨 build 存活，由所有者释放或维护。
- Form 统一触发多个同步 validator；异步检查单独建模。
- 字段错误定位问题，页面状态说明提交结果。

## 参考资料

- [Build a form with validation](https://docs.flutter.dev/cookbook/forms/validation)（查阅：2026-08-30）
- [Handle changes to a text field](https://docs.flutter.dev/cookbook/forms/text-field-changes)（查阅：2026-08-30）
- [TextFormField class](https://api.flutter.dev/flutter/material/TextFormField-class.html)（查阅：2026-08-30）
- [TextEditingController class](https://api.flutter.dev/flutter/widgets/TextEditingController-class.html)（查阅：2026-08-30）
- [FormState.validate](https://api.flutter.dev/flutter/widgets/FormState/validate.html)（查阅：2026-08-30）
