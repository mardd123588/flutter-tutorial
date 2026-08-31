---
title: Result、错误与命令
description: 用 sealed Result 区分预期失败，用 Command 管理异步动作，并把错误文案、焦点和恢复动作留在 View。
part: 6
order: 3
kind: concept
requires:
  - architecture.viewmodel
  - error.network
provides:
  - architecture.result
  - architecture.command
  - error.presentation
status: verified
---

# Result、错误与命令

Dart 不要求方法在签名里声明可能抛出的异常。跨过 Service、Repository 和 ViewModel 后，调用方很容易只剩一个宽泛的 `catch`，无法知道这是时间冲突、记录不存在、存储失败，还是程序写错了。

Result 适合表达调用方预期会处理的失败。Command 则把一次异步动作的运行状态和最近结果收在一起。

## 先区分三类失败

| 类型 | 表达 | 例子 |
| --- | --- | --- |
| 可预期业务失败 | typed failure + Result | 时间冲突、容量不足、记录不存在 |
| 可恢复基础设施失败 | Repository 映射后的 Result | 读取失败、写入失败、服务暂不可用 |
| 程序缺陷 | Error、assert 或未捕获异常 | 不可达分支、错误类型转换、不变量破坏 |

Result 不该吞掉所有异常。把 `TypeError` 也改成“请重试”，既隐藏缺陷，也让用户得到无效建议。

## sealed Result 让分支进入类型系统

```dart
sealed class Result<T> {
  const Result();
}

final class Ok<T> extends Result<T> {
  const Ok(this.value);
  final T value;
}

final class Failure<T> extends Result<T> {
  const Failure(this.error);
  final AppFailure error;
}

sealed class AppFailure {
  const AppFailure();
}

final class ConflictFailure extends AppFailure {
  const ConflictFailure(this.ids);
  final List<String> ids;
}

final class StorageFailure extends AppFailure {
  const StorageFailure();
}
```

Repository 返回稳定类别和诊断上下文，不返回已经写好的中文提示：

```dart
Future<Result<Entry>> save(Entry entry) async {
  final conflicts = policy.evaluate(entry);
  if (conflicts.isNotEmpty) {
    return Failure(ConflictFailure(conflicts));
  }

  try {
    await storage.write(entry);
    return Ok(entry);
  } on DatabaseException {
    return const Failure(StorageFailure());
  }
}
```

这里捕获的是边界里已知、可恢复的数据库异常。未预期的编程错误继续暴露。

## 模式匹配迫使调用方处理两支

```dart
switch (await repository.save(draft)) {
  case Ok<Entry>(:final value):
    state = state.saved(value);
  case Failure<Entry>(:final error):
    state = state.failed(error);
}
```

如果 Failure 继续细分，ViewModel 可以保留 failure 类别；View 再把类别翻成文案、焦点和恢复动作。不要让 UI 解析异常字符串来判断该显示哪个按钮。

## Command 管一项动作，不管整个页面

```dart
class Command<T> extends ChangeNotifier {
  Command(this._action);

  final Future<Result<T>> Function() _action;

  bool _running = false;
  Result<T>? _result;

  bool get running => _running;
  Result<T>? get result => _result;

  Future<void> execute() async {
    if (_running) return;
    _running = true;
    _result = null;
    notifyListeners();

    _result = await _action();
    _running = false;
    notifyListeners();
  }

  void clearResult() {
    _result = null;
    notifyListeners();
  }
}
```

同一 Command 在运行时拒绝再次启动，解决重复点击。它没有取消底层 Future，也没有让页面里其他 Command 停止。

保存和刷新可以各有一个 Command：

```text
saveCommand.running = true
refreshCommand.running = true
```

二者是否允许并行由业务合同决定，不能从“用了 Command”自动推出全局串行。

## 一次性结果需要消费

Command 的 `result` 常用于导航、SnackBar 或聚焦错误摘要。View 处理后要清理，否则下一次重建可能重复执行副作用。

```dart
void handleSaveResult(Result<Entry>? result) {
  switch (result) {
    case Ok<Entry>():
      Navigator.pop(context);
      saveCommand.clearResult();
    case Failure<Entry>(error: ConflictFailure()):
      conflictSummaryFocus.requestFocus();
      saveCommand.clearResult();
    case Failure<Entry>():
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('保存失败，请重试。')),
      );
      saveCommand.clearResult();
    case null:
      break;
  }
}
```

View 负责中文文案和焦点，是因为这些行为依赖当前界面。Failure 保存稳定类别，才能复用于不同语言、不同布局和测试。

## Result 与异步执行状态是两件事

`Result<Entry>` 回答“这次保存成功还是发生了预期失败”。`running` 回答“动作现在是否执行中”。后面 Riverpod 的 `AsyncValue` 也描述执行状态、旧值、刷新和异常，不会取代 Result 的业务失败边界。

一个时间冲突是正常业务结果，不应伪装成未捕获异常；一个错误类型转换也不应包装成普通冲突。

## 重试要回到原动作

可重试失败需要保存足够的输入，让用户再次执行同一动作。重试按钮调用 `command.execute()`，不复制 Repository 逻辑。

同时注意两条边界：

- 重试前允许用户修改草稿时，Command 应读取最新草稿；
- 需要严格重放原请求时，Command 创建时就固定输入。

两种语义都可以，必须在接口和测试里选清楚。

## 可验证任务

实现一个保存公告的 ViewModel 与 Command，覆盖：

- 保存成功返回 `Ok`；
- 标题重复返回 typed conflict；
- 存储失败返回稳定的 infrastructure failure；
- 连续点击两次只启动一次保存；
- 失败结束后可以重试；
- View 把冲突映射为可见摘要并移动焦点；
- 消费结果后重建不会重复导航或重复显示 SnackBar。

程序缺陷不要包装进 Result；为此再写一条测试，确认它仍会抛出。

## 常见误区

- `catch (Object)` 后把所有问题都改成同一错误文案。
- Failure 直接保存中文字符串，导致领域层绑定界面语言。
- 认为 Result 已经包含 loading 状态。
- 认为防重复等于取消正在运行的请求。
- 页面重建时反复消费同一个成功结果。

## 复习线索

- Result 表达预期成功与失败，程序缺陷继续暴露。
- Command 收拢一项动作的 running 和最近结果。
- 同一 Command 防重复，不代表所有动作串行，也不代表取消。
- Failure 保存稳定类别；View 决定文案、焦点、导航和恢复入口。

## 参考资料

- [Dart error handling](https://dart.dev/language/error-handling)（查阅：2026-08-30）
- [Dart Exception](https://api.dart.dev/dart-core/Exception-class.html)（查阅：2026-08-30）
- [Dart Error](https://api.dart.dev/dart-core/Error-class.html)（查阅：2026-08-30）
- [Flutter Result pattern](https://docs.flutter.dev/app-architecture/design-patterns/result)（查阅：2026-08-30）
- [Flutter Command pattern](https://docs.flutter.dev/app-architecture/design-patterns/command)（查阅：2026-08-30）

