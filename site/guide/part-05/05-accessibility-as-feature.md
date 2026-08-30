---
title: 可访问性作为功能
description: 把语义、焦点、键盘、文本缩放、对比度、错误和减少动画纳入功能合同。
part: 5
order: 5
kind: concept
requires:
  - input.focus
  - input.keyboard
  - a11y.semantics-basic
  - animation.reduced-motion
  - layout.responsive
provides:
  - a11y.semantics
  - a11y.keyboard-flow
  - a11y.text-scale
  - a11y.error-feedback
  - a11y.motion-preference
status: verified
---

# 可访问性作为功能

一个任务能否只用键盘完成、放大文字后是否仍可操作、错误能否被读出，都是功能结果。`Semantics` 只是其中一层。

这一章用一个独立的“预约参观时段”场景检查完整流程：选择日期、选时段、提交、修正错误。它不依赖后面的统筹项目。

## 先继承内置控件的语义

Material 按钮、文本框、复选框和导航组件已经提供名称、角色、状态与动作。先使用正确控件，再为自绘或组合内容补语义。

自定义时段行同时显示名称、余量和选中状态，可以把内部视觉细节合成一个节点：

```dart
Semantics(
  button: true,
  selected: selected,
  label: '$label，剩余 $remaining 个名额',
  child: ExcludeSemantics(
    child: InkWell(
      onTap: onPressed,
      child: visualRow,
    ),
  ),
)
```

`ExcludeSemantics` 防止同一文字被子节点再播报一次。不要给已有文字标签的普通按钮重复加同名 label；重复语义比缺少修饰更难用。

装饰图应排除语义。自绘路线、图表或平面图若传递信息，需要一条简短摘要；具体数据和操作仍由真实文本、列表和按钮承担。

## 状态变化需要可感知反馈

提交成功、搜索结果数变化或异步错误出现时，焦点可能仍在原控件。`liveRegion` 可以让辅助技术获知更新：

```dart
Semantics(
  liveRegion: true,
  child: Text(statusMessage),
)
```

状态文字应持续存在足够时间，也要能被视觉用户看到。只变颜色、只震动、只弹一个很快消失的提示，都没有覆盖所有输入与感知方式。

Live region 要短，描述变化本身。不要把整个结果列表放进去，否则每次更新都会朗读大量内容。

## 焦点顺序跟随阅读顺序

默认 `ReadingOrderTraversalPolicy` 会结合几何位置和 `Directionality` 计算顺序。布局的 Widget 顺序与视觉顺序一致时，通常不需要手写序号。

`FocusTraversalGroup` 用来隔离局部区域：

```dart
FocusTraversalGroup(
  child: Wrap(
    spacing: 8,
    runSpacing: 8,
    children: timeSlotButtons,
  ),
)
```

只有布局重排导致默认顺序含糊时才使用显式 traversal policy。大量 `NumericFocusOrder` 很容易在增删控件后失真。

Dialog、Drawer 和错误遮罩打开后，焦点不能继续落在被遮挡内容。关闭临时层后，应回到触发按钮或下一步合理位置。WCAG 2.2 还要求焦点指示可见，并且不被作者创建的内容完全遮挡。

## 快捷键不能抢文本输入

`Shortcuts` 将按键映射为 `Intent`，`Actions` 执行动作：

```dart
Shortcuts(
  shortcuts: const {
    SingleActivator(LogicalKeyboardKey.keyS, control: true):
        SaveIntent(),
  },
  child: Actions(
    actions: {
      SaveIntent: CallbackAction<SaveIntent>(
        onInvoke: (_) {
          save();
          return null;
        },
      ),
    },
    child: content,
  ),
)
```

快捷键只在当前焦点树中生效，但应用根部的作用域仍可能包住文本框。`/`、空格、方向键、Backspace 等编辑按键要检查 `EditableText` 焦点，或把快捷键作用域放到不会覆盖编辑器的位置。

验收时从页面首个可聚焦元素开始，用 Tab / Shift+Tab / Enter / Space / Escape 完成整个任务。鼠标能点通不能证明键盘流程成立。

## 点击目标与可见焦点

Flutter 的可访问性检查建议可点击目标至少 48×48 logical px。视觉图标可以小于 48px，但命中区域不能跟着缩小。

焦点样式要与背景有清楚差异，并且不能只靠细微色相变化。hover 和 focus 是两个状态：鼠标移开后，键盘焦点仍要可见。

## 200% 文本不丢内容和功能

WCAG 2.2 的 Resize Text 要求文本放大到 200% 时仍可使用；Reflow 关注 320 CSS px 等效宽度下通常不需要双向滚动。

Flutter 中优先修布局：

- 标题允许多行；
- 固定高度改为最小高度；
- 横排按钮使用 `Wrap`；
- 页面可垂直滚动；
- 错误文字与字段保持相邻；
- 关键动作不使用 `FittedBox` 缩成难读小字。

不要在应用根部把 `MediaQuery.textScaler` 限制到 1.0。那会把用户设置直接抹掉。

## 对比度和颜色不是同一件事

WCAG 2.2 AA 要求普通文本至少 4.5:1，大文本至少 3:1。对比度工具能检查颜色组合，却不能判断状态是否只靠颜色表达。

选中时同时使用文字、图标或 `Semantics.selected`；错误同时提供标题和说明；禁用状态不能只把透明度降到无法阅读。hover、focus、error、disabled 都要分别检查。

## 错误要指出对象和修复方法

字段错误应靠近字段，并进入语义树：

```dart
TextFormField(
  decoration: const InputDecoration(labelText: '同行人数'),
  validator: (value) {
    final count = int.tryParse(value ?? '');
    if (count == null) return '请输入整数。';
    if (count < 1 || count > 6) return '人数应在 1 到 6 之间。';
    return null;
  },
)
```

“输入有误”没有指出哪一项错了。“边框变红”也没有给屏幕阅读器或色觉不同的用户修复线索。页面级 URL 错误还应提供一个安全返回入口。

## 减少动画保留状态反馈

```dart
final reduceMotion = MediaQuery.disableAnimationsOf(context);
final duration = reduceMotion
    ? Duration.zero
    : const Duration(milliseconds: 240);
```

装饰性入场、位移和路线绘制可以直接到终态。加载、焦点、保存成功与错误反馈仍要出现；“减少动画”不等于隐藏状态变化。

`disableAnimations` 是 Flutter 暴露的重要信号，但各平台底层来源并不完全相同。不要把它描述成所有平台动画偏好的唯一来源。

## 自动测试能证明什么

Widget 测试可检查语义节点：

```dart
final handle = tester.ensureSemantics();
final node = tester.getSemantics(find.byKey(const ValueKey('slot-morning')));
expect(node.label, contains('剩余 3 个名额'));
expect(node.flagsCollection.isSelected, isTrue);
handle.dispose();
```

测试还应发送 Tab、Enter、Escape，设置 200% `TextScaler`，并把 `disableAnimations` 设为 true。自动测试仍不能替代 TalkBack / VoiceOver、浏览器语义树和真实焦点可见性的人工检查。

## 可验证任务

完成“预约参观时段”的独立验收页：

- 只用键盘选择日期、时段并提交；
- 时段行有名称、余量、按钮角色和选中状态；
- 提交错误指出字段与修复方式；
- 结果状态使用短 live region；
- 320×720、200% 文本下无横向溢出；
- `disableAnimations` 下直接显示终态；
- hover、focus、selected 和 error 不只靠颜色区分。

## 常见误区

- 给每个 Widget 都加 `Semantics`，造成重复播报。
- 自绘图既没有摘要，也没有等价真实列表。
- 焦点顺序按编号硬写，布局一改就错。
- 全局快捷键抢走输入框里的 `/`、空格或方向键。
- 限制文本缩放来消除 overflow。
- 用红色边框作为唯一错误提示。
- 减少动画时连保存结果也不显示。

## 复习线索

- 先使用语义正确的内置控件，再补自绘与组合内容。
- 焦点、键盘、文本缩放、错误和动画偏好共同决定任务是否可完成。
- live region 只宣布短状态变化，详细内容保持为普通可读界面。
- 自动语义测试和真实辅助技术检查解决不同问题。

## 参考资料

- [Flutter accessibility](https://docs.flutter.dev/ui/accessibility-and-internationalization/accessibility)（查阅：2026-08-30）
- [Semantics API](https://api.flutter.dev/flutter/widgets/Semantics-class.html)（查阅：2026-08-30）
- [FocusTraversalGroup API](https://api.flutter.dev/flutter/widgets/FocusTraversalGroup-class.html)（查阅：2026-08-30）
- [Shortcuts API](https://api.flutter.dev/flutter/widgets/Shortcuts-class.html)（查阅：2026-08-30）
- [Actions API](https://api.flutter.dev/flutter/widgets/Actions-class.html)（查阅：2026-08-30）
- [MediaQueryData.disableAnimations API](https://api.flutter.dev/flutter/widgets/MediaQueryData/disableAnimations.html)（查阅：2026-08-30）
- [WCAG 2.2 Resize Text](https://www.w3.org/WAI/WCAG22/Understanding/resize-text.html)（查阅：2026-08-30）
- [WCAG 2.2 Reflow](https://www.w3.org/WAI/WCAG22/Understanding/reflow.html)（查阅：2026-08-30）
- [WCAG 2.2 Focus Visible](https://www.w3.org/WAI/WCAG22/Understanding/focus-visible.html)（查阅：2026-08-30）
- [WCAG 2.2 Contrast Minimum](https://www.w3.org/WAI/WCAG22/Understanding/contrast-minimum.html)（查阅：2026-08-30）
- [WCAG 2.2 Error Identification](https://www.w3.org/WAI/WCAG22/Understanding/error-identification.html)（查阅：2026-08-30）
