---
title: 状态放在哪里
description: 从界面重建需求判断状态所有权，区分源状态、派生值和短暂界面状态，并界定 setState 的作用范围。
part: 3
order: 1
kind: concept
requires:
  - state.ephemeral-basic
  - runtime.build
provides:
  - state.ownership
  - state.set-state
  - state.derived
status: verified
---

# 状态放在哪里

状态代码难维护，常见原因不是 API 选错，而是一开始就没说清谁拥有这份数据。一份状态放得太低，兄弟组件只好互相找实例；放得太高，每次局部操作又会牵动不相干的接口。先确定所有权，再选 `setState`、`ChangeNotifier` 或后续的状态管理方案。

## 状态是重建界面所需的事实

把页面销毁后重新建立，如果某个值会影响当前界面，它就是状态的一部分。这里的“值”不只包括字段，也包括当前筛选条件、是否展开、滚动位置和正在进行的动画进度。

判断一份数据放在哪里，可以依次问四个问题：

1. 哪些 Widget 需要读取它？
2. 哪个对象负责修改它？
3. 离开当前 Widget 后，它是否可以丢失？
4. 它能否从其他状态同步算出？

状态应放在所有读写者最近的共同拥有者。只有一张卡片需要的展开状态可以留在卡片内；筛选栏和列表都需要的筛选条件，应放到两者共同的父级；跨页面、需要持久化或由服务更新的数据，才继续向应用层移动。

“临时状态”和“应用状态”不是由数据类型决定的。同一个当前页签，在一次性向导里可以是局部状态；若需要写入 URL、恢复会话并被多个页面读取，它就不再只是局部状态。

## 源状态只保留一份

能从其他值同步算出的结果是派生状态。假设页面保存完整植物列表和筛选条件，显示列表应在读取时计算：

```dart
List<Plant> get visiblePlants {
  return plants.where(matchesCurrentFilter).toList(growable: false);
}
```

不要同时维护 `plants`、`filter` 和另一份可变的 `visiblePlants`。新增、删除、筛选和撤销时，三份数据很容易失去同步。

适合直接派生的值包括：

- 列表筛选结果和计数；
- 当前是否允许提交；
- 价格合计；
- 由选中 ID 查到的当前对象。

派生不等于永远不能缓存。计算昂贵时可以缓存，但缓存的失效条件必须由源状态的所有者一起管理，并覆盖每条失效路径。本部分只有少量内存数据，不提前增加缓存层。

## 本地状态和受控状态各有边界

一个受控组件从外部接收值，并用回调报告用户意图：

```dart
class FilterBar extends StatelessWidget {
  const FilterBar({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final PlantFilter value;
  final ValueChanged<PlantFilter> onChanged;
}
```

它不保留第二份当前筛选值。父级能恢复、测试和协调筛选条件，列表也能读取同一事实。

局部状态则只服务组件自身。例如一张植物卡的“展开观察”不影响筛选、排序或撤销，卡片销毁后也不必恢复，因此可以留在行内 `State`。第三章会说明列表重排时如何让这份局部状态继续属于正确的植物。

所有状态都上移并不会自动变好。鼠标 hover、输入光标和一次短暂按压若被提升到页面根部，会扩大接口和重建范围，却没有增加可恢复性。

## `setState` 做了两件事

`setState` 先同步执行回调，再把当前 `State` 对应的 Element 标记为需要重建：

```dart
void toggleExpanded() {
  setState(() {
    expanded = !expanded;
  });
}
```

回调不能写成 `async`。异步工作应在外面等待，拿到结果后再同步写入：

```dart
final result = await repository.load();
if (!mounted) return;
setState(() {
  records = result;
});
```

`setState` 不会直接修改屏幕，也不保证“只重建那一个 Text”。它从当前 Element 开始安排下一次构建，后代可能继续参与更新。反过来，它也不表示整个应用必然重建。

只在字段变化会改变 `build` 结果时调用 `setState`。把日志、计数器自增或网络请求本身包进回调，不会让它们更安全，只会隐藏真正的界面状态变更。

## 先按所有权拆重建边界

重建范围首先是建模问题。列表顺序由页面拥有，行内备注由每一行拥有，那么调整顺序时页面重建列表，行内状态仍可由对应 Element 保留。若把所有备注也提升成一个巨大的页面 Map，当然可以工作，但要承担更多同步和接口成本。

当一份共享状态让页面结构变得拥挤时，再把“数据与操作”提取到独立对象；第四章会用 `ChangeNotifier` 完成这一步。提取对象不是为了消灭重建，而是为了明确所有者、修改入口和可测试边界。

## 可验证任务

做一个带分类筛选的三项清单，并完成下面的状态审计：

1. 只保存完整列表和当前筛选条件，把可见列表改成 getter 或 `build` 内局部变量。
2. 把筛选栏写成受控组件，只接收值与 `onChanged`。
3. 给每一行加入局部展开状态，不把它上移到页面。
4. 在每次 `setState` 前写明哪个字段会改变 `build` 结果；删掉只包住日志或异步等待的调用。
5. 分别测试空筛选结果、切换筛选和展开一行，确认三类状态没有互相复制。

## 复习线索

- 状态放在所有读写者最近的共同拥有者。
- 源状态只保留一份；便宜且确定的结果在读取时派生。
- 受控组件报告意图，局部状态服务可独立丢失的界面细节。
- `setState` 同步改字段并标记当前 Element 重建，不直接修改屏幕。

## 参考资料

- [Start thinking declaratively](https://docs.flutter.dev/data-and-backend/state-mgmt/declarative)（查阅：2026-08-30）
- [Ephemeral state and app state](https://docs.flutter.dev/data-and-backend/state-mgmt/ephemeral-vs-app)（查阅：2026-08-30）
- [Simple app state management](https://docs.flutter.dev/data-and-backend/state-mgmt/simple)（查阅：2026-08-30）
- [State.setState API](https://api.flutter.dev/flutter/widgets/State/setState.html)（查阅：2026-08-30）
