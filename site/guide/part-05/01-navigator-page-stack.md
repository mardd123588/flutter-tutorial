---
title: Navigator 与页面栈
description: 用 Route 栈理解 push、pop、返回结果、对话框、嵌套导航与离开确认。
part: 5
order: 1
kind: concept
requires:
  - state.lifecycle
  - runtime.mounted
  - input.form
provides:
  - navigation.navigator-stack
  - navigation.route-result
  - navigation.pop-scope
status: verified
---

# Navigator 与页面栈

`Navigator` 管理一组 `Route`。当前 Route 在栈顶，`push` 把新 Route 放到上面，`pop` 完成栈顶 Route。页面只是 Route 最常见的内容；对话框、菜单和底部弹层也可以是 Route。

这一章先使用 `Navigator + MaterialPageRoute`。当页面数量少、没有 Web 深链接要求时，它仍是清楚而直接的写法。

## push 返回一个 Future

打开选择页时，可以同时声明“回来时需要什么结果”：</n+
```dart
final venueId = await Navigator.of(context).push<String>(
  MaterialPageRoute(
    builder: (context) => const VenuePickerPage(),
  ),
);
```

`push<String>` 返回 `Future<String?>`。泛型 `String` 表示这个 Route 成功结束时可交回一个字符串；`null` 通常表示用户直接返回，没有选择。

选择页用同一个类型完成 Route：

```dart
onPressed: () {
  Navigator.of(context).pop('materials-hall');
},
```

这里的 `pop` 不只是“回上一页”。它完成当前 Route，并把 `'materials-hall'` 交给上一段 `await`。类型写错会在编译期暴露。

## await 之后重新检查 context

等待期间，发起导航的 Widget 可能已经从树中移除。异步返回后再访问 `context`，先检查 `context.mounted`：

```dart
final venueId = await Navigator.of(context).push<String>(route);
if (!context.mounted || venueId == null) return;

ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(content: Text('已选择 $venueId')),
);
```

`mounted` 只回答这个 `BuildContext` 是否还在树中。它不会判断返回值是否为空，也不会替你取消异步工作。

## dialog 也是 Route

`showDialog<T>` 仍然返回 `Future<T?>`：

```dart
final confirmed = await showDialog<bool>(
  context: context,
  builder: (context) => AlertDialog(
    title: const Text('离开编辑页？'),
    content: const Text('尚未保存的修改会丢失。'),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context, false),
        child: const Text('继续编辑'),
      ),
      FilledButton(
        onPressed: () => Navigator.pop(context, true),
        child: const Text('离开'),
      ),
    ],
  ),
);
```

`barrierDismissible: false` 只禁止点击遮罩关闭。系统返回、路由恢复和代码主动 `pop` 是另外几条路径，不能用这个参数代替完整的离开合同。

默认情况下，dialog 会放到根 Navigator。若页面位于嵌套 Navigator 中，并且对话框只属于当前局部流程，可显式设置 `useRootNavigator: false`。关闭时也要找到同一个 Navigator。

## 嵌套 Navigator 形成局部页面栈

应用可以有多个 Navigator。例如结账流程在一个面板内依次显示地址、配送和确认，外层仍保留应用导航。此时：

```text
根 Navigator
├─ 首页 Route
└─ 结账外壳 Route
   └─ 内层 Navigator
      ├─ 地址 Route
      └─ 配送 Route  ← 当前局部页面
```

`Navigator.of(context)` 会沿 Element 树寻找最近的 Navigator。要操作根栈，可保存 `GlobalKey<NavigatorState>`，或在 API 支持时使用 `rootNavigator: true`。嵌套栈能隔离流程，也增加了“这次 pop 到底操作哪一层”的判断成本；没有独立流程时不要先加一层。

## PopScope 先声明能否离开

`PopScope` 参与系统返回、预测性返回和 Navigator 的 pop 判断。新代码不再使用已弃用的 `WillPopScope`。

```dart
PopScope<void>(
  canPop: !hasUnsavedChanges,
  onPopInvokedWithResult: (didPop, result) async {
    if (didPop) return;

    final leave = await confirmLeave(context);
    if (leave && context.mounted) {
      Navigator.of(context).pop();
    }
  },
  child: const EditVenuePage(),
)
```

`canPop` 是事前决定；`onPopInvokedWithResult` 是事后通知。`didPop == true` 表示 Route 已经完成，回调不能再撤销。`didPop == false` 时才适合解释阻止原因、询问用户，然后按确认结果主动离开。

离开确认必须覆盖两条结果：确认后退出，取消后留在原页且编辑状态不变。若页面还提供“关闭”按钮，这个按钮也应复用同一套确认逻辑，不能只保护系统返回键。

## maybePop 与 canPop

- `Navigator.pop` 请求完成当前 Route；
- `Navigator.maybePop` 先询问 Route 的 pop disposition，可能被 `PopScope` 阻止；
- `Navigator.canPop` 只说明当前 Navigator 是否有可弹出的内容，不代表业务上允许丢弃修改。

应用栏返回按钮通常调用 `maybePop` 更合适。保存按钮完成页面并返回结果时，明确调用 `pop(result)`。

## 状态恢复不是保存整个应用

普通 `Navigator.push` 不参与状态恢复。需要在进程被系统终止后重建导航历史时，要配置 `restorationScopeId`，并使用 `restorablePush`、`RestorableRouteFuture` 等 API。Route builder 必须可静态重建，参数也要能序列化。

恢复的是已注册的 navigation / restoration 状态，不是任意内存对象。草稿正文、网络缓存或数据库事实仍要由各自的持久化方案负责。

## 可验证任务

做一个两页的“参观日期选择”流程：

- 首页用 `push<DateTime>` 打开日期页；
- 日期页确认时 `pop` 日期，取消时返回 `null`；
- 首页在 `await` 后检查 `context.mounted`；
- 日期页有未保存修改时用 `PopScope` 询问；
- dialog 的确认和取消都写 Widget 测试。

测试至少断言三件事：结果能返回、取消不改首页、离开确认被拒绝时页面仍在。

## 常见误区

- 把 `push` 当成无返回值命令，随后用全局变量传选择结果。
- 在 `await` 后直接使用 `context`。
- 认为 `barrierDismissible: false` 已阻止所有 dialog 离开路径。
- 在 `onPopInvokedWithResult` 里试图把已经发生的 pop 改成失败。
- 嵌套 Navigator 后仍默认 `Navigator.of(context)` 一定指向根栈。

## 复习线索

- Route 被 `pop<T>` 完成，`push<T>` 返回的 Future 接收结果。
- `context.mounted` 处理异步后的 Widget 生命周期，不处理业务取消。
- `PopScope.canPop` 负责事前边界，回调只报告尝试结果。
- 嵌套 Navigator 的价值是局部流程栈，代价是必须明确操作哪一层。

## 参考资料

- [Navigator API](https://api.flutter.dev/flutter/widgets/Navigator-class.html)（查阅：2026-08-30）
- [Navigator.push API](https://api.flutter.dev/flutter/widgets/Navigator/push.html)（查阅：2026-08-30）
- [Navigator.pop API](https://api.flutter.dev/flutter/widgets/Navigator/pop.html)（查阅：2026-08-30）
- [Navigator.maybePop API](https://api.flutter.dev/flutter/widgets/Navigator/maybePop.html)（查阅：2026-08-30）
- [showDialog API](https://api.flutter.dev/flutter/material/showDialog.html)（查阅：2026-08-30）
- [PopScope API](https://api.flutter.dev/flutter/widgets/PopScope-class.html)（查阅：2026-08-30）
- [RestorableRouteFuture API](https://api.flutter.dev/flutter/widgets/RestorableRouteFuture-class.html)（查阅：2026-08-30）
