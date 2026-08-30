---
title: 生命周期与副作用
description: 沿 State 生命周期安排初始化、依赖读取、配置替换、订阅和释放，并处理异步后的 mounted 边界。
part: 3
order: 2
kind: concept
requires:
  - state.ownership
  - runtime.build-context
provides:
  - state.lifecycle
  - runtime.mounted
  - runtime.side-effect
status: verified
---

# 生命周期与副作用

`State` 会跨多次 Widget 配置更新继续存在。controller、监听器和异步回调若只按“页面打开、页面关闭”理解，很容易漏掉配置替换、依赖变化和暂时移出树的情况。生命周期方法不是固定仪式，每一个都对应不同的可用信息。

## 先记住完整顺序

一个新 `State` 的主要路径如下：

| 阶段 | 发生什么 | 适合做什么 |
| --- | --- | --- |
| `createState` | StatefulWidget 创建 State | 只创建对象 |
| `mounted == true` | State 与 BuildContext 关联 | 框架内部建立挂载关系 |
| `initState` | 对当前 State 只调用一次 | 创建自有资源、订阅 widget 直接提供的对象 |
| `didChangeDependencies` | 首次紧跟 `initState`，依赖变化时再调用 | 读取 inherited 依赖并据此初始化 |
| `build` | 可以调用很多次 | 由当前状态返回 Widget 配置 |
| `didUpdateWidget` | 同位置换入同类型同 Key 的新配置 | 对比旧新参数，替换订阅或同步本地字段 |
| `deactivate` | State 暂时从树中移除 | 很少用于业务清理；它可能重新插入 |
| `dispose` | State 永久离开树 | 释放自己拥有的资源，调用 `super.dispose()` |

`mounted` 在 `initState` 之前已经为 true，`dispose` 后变为 false。`deactivate` 后仍可能重新挂载，所以不能在这里提前销毁 controller。

## `initState` 不能依赖 inherited 数据

`initState` 适合创建 `TextEditingController`、`FocusNode`、`AnimationController`，也适合订阅 `widget` 参数直接传入的 `Listenable`。它不能调用会建立 inherited 依赖的 `Theme.of(context)`、`MediaQuery.of(context)` 或自定义 `Scope.of(context)`。

这类读取放在 `didChangeDependencies`：

```dart
@override
void didChangeDependencies() {
  super.didChangeDependencies();
  final locale = Localizations.localeOf(context);
  // 只在依赖变化时同步与 locale 有关的资源。
}
```

`didChangeDependencies` 可能多次执行。若初始化成本高，要保存上次依赖值并比较，而不是每次无条件重建资源。

## 订阅需要三段式协议

若 State 监听外部传入的对象，必须覆盖初始化、配置替换和释放：

```dart
@override
void initState() {
  super.initState();
  widget.source.addListener(_handleChange);
}

@override
void didUpdateWidget(covariant Meter oldWidget) {
  super.didUpdateWidget(oldWidget);
  if (widget.source != oldWidget.source) {
    oldWidget.source.removeListener(_handleChange);
    widget.source.addListener(_handleChange);
  }
}

@override
void dispose() {
  widget.source.removeListener(_handleChange);
  super.dispose();
}
```

只写 `initState` 和 `dispose` 会漏掉父级换入新对象的情况：State 继续存活，却仍在监听旧 source。`didUpdateWidget` 之后框架一定会调用 `build`，因此只为同步字段而在其中调用 `setState` 通常是多余的。

资源由创建者释放。State 自己创建的 controller 在 `dispose` 中销毁；外部传入的 controller 只退订，不替所有者 dispose。这个规则和第二部分的表单资源所有权相同。

## `build` 保持可重复

`build` 可能因为父级更新、窗口变化、主题变化或 inherited 依赖更新而执行。不要在其中发请求、启动计时器、添加监听器或创建需要 dispose 的对象。

`build` 可以做确定的派生计算，也可以创建普通的短命 Widget 配置。副作用应由明确事件或生命周期触发：

- 用户点击后保存；
- `initState` 开始一次与当前 State 同寿命的工作；
- `didUpdateWidget` 响应输入对象替换；
- `didChangeDependencies` 响应 inherited 依赖变化。

确实要在首帧布局完成后执行依赖尺寸或焦点树的操作，可使用 `WidgetsBinding.instance.addPostFrameCallback`。它只把回调排到该帧之后，不会自动取消，也不能代替正确的所有权判断。

## 跨过 `await` 后重新检查资格

异步等待期间，用户可能已经离开页面。继续调用 `setState`、`Navigator.of(context)` 或 `ScaffoldMessenger.of(context)` 前，要检查实际使用对象是否仍挂载：

```dart
await saveDraft();
if (!context.mounted) return;
Navigator.of(context).pop();
```

若后面调用的是当前 `State` 的 `setState`，检查 `mounted`；若使用的是方法参数中的局部 `context`，检查 `context.mounted`。不要用一个无关对象的 mounted 状态替另一个 context 作保证。

`mounted` 只是最后一道使用资格检查，不是取消机制。计时器、Stream 订阅、动画监听和可取消请求仍应在 `dispose` 中停止，否则后台工作和对象引用会继续存在。修复 `setState() called after dispose()` 时，优先找到谁还在回调已经销毁的 State，而不是到处补 `if (!mounted) return`。

`dispose` 也不是应用退出通知。操作系统可以直接终止进程，框架没有机会遍历 Widget tree。必须持久化的数据应在业务动作或应用生命周期节点保存，不能只等 `dispose`。

## 可验证任务

写一个 `StatefulWidget`，接收外部 `ChangeNotifier source`，并用日志与测试验证：

1. 首次挂载依次经过 `initState`、`didChangeDependencies`、`build`。
2. 父级换入另一个 source 时触发 `didUpdateWidget`，旧对象不再能更新页面，新对象可以。
3. Widget 移出树后，两边都没有残留监听。
4. 启动一个延迟操作后立即移出 Widget，取消实际工作；另写一条只用 mounted 守住最终 UI 更新的对照测试。
5. 在 `build` 中故意添加监听器，观察重复注册后移除错误实现。

## 复习线索

- `initState` 处理直接输入和自有资源；inherited 依赖放在 `didChangeDependencies`。
- 外部订阅遵守 `initState → didUpdateWidget → dispose` 三段式协议。
- `deactivate` 可能回到树中，`dispose` 才是永久结束。
- `mounted` 防止使用失效 State 或 context；取消工作仍要单独完成。

## 参考资料

- [State API](https://api.flutter.dev/flutter/widgets/State-class.html)（查阅：2026-08-30）
- [State.initState API](https://api.flutter.dev/flutter/widgets/State/initState.html)（查阅：2026-08-30）
- [State.didUpdateWidget API](https://api.flutter.dev/flutter/widgets/State/didUpdateWidget.html)（查阅：2026-08-30）
- [State.dispose API](https://api.flutter.dev/flutter/widgets/State/dispose.html)（查阅：2026-08-30）
- [BuildContext.mounted API](https://api.flutter.dev/flutter/widgets/BuildContext/mounted.html)（查阅：2026-08-30）
- [use_build_context_synchronously](https://dart.dev/tools/linter-rules/use_build_context_synchronously)（查阅：2026-08-30）
