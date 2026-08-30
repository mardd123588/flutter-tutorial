---
title: Element 身份、Key 与重排
description: 从 Widget 更新匹配解释行内状态串位，并用可排序值班板验证稳定 Key 和 Flutter 3.47 重排索引。
part: 3
order: 3
kind: focus-project
requires:
  - state.lifecycle
  - layout.lazy-list
provides:
  - runtime.element-identity
  - runtime.keys
  - list.reorder
project: sortable-duty-board
status: verified
---

# Element 身份、Key 与重排

列表名字已经换了顺序，输入框里的文字却留在原位置，这不是 TextField 自己串了数据。旧 Element 和 State 被按位置复用，而新 Widget 配置代表了另一个业务对象。Key 负责给框架足够的身份信息，让配置更新与业务对象对齐。

## 状态默认跟着 Element

Widget 是不可变配置；Element 把 Widget 放进树中，State 再挂在 StatefulElement 上。父级重建后，框架要判断旧 Element 能否接收当前位置的新 Widget。

核心条件可以写成：

```text
oldWidget.runtimeType == newWidget.runtimeType
&& oldWidget.key == newWidget.key
```

一组没有 key 的同类型行会按兄弟位置匹配。把第一项移动到第三项后，索引 0 的旧 State 仍留在索引 0，只是收到第二位成员的新 Widget 配置。若 State 内有备注 controller 或展开状态，它们看起来就换了人。

Key 不负责排序，也不保存状态。它只参与同一父级下兄弟 Element 的更新匹配。排序仍然要修改数据，再用新顺序重建 Widget。

## Key 要放在被移动的直接子级

稳定业务 ID 通常使用 `ValueKey`：

```dart
for (final member in members)
  DutyRow(
    key: ValueKey(member.id),
    member: member,
  )
```

把 key 只放到行内部的 TextField 上不够。列表直接移动的是 `DutyRow`，它仍会先按位置复用旧 State，深处的 key 无法替外层建立兄弟身份。

常见 Key 的边界如下：

| Key | 相等规则 | 合适场景 |
| --- | --- | --- |
| `ValueKey(value)` | 值相等 | 稳定 ID、枚举、不可变业务键 |
| `ObjectKey(object)` | 对象身份相同 | 对象实例本身就是身份，替换实例应视为新项 |
| `UniqueKey()` | 每次都不相等 | 明确要求强制创建新 Element |
| `GlobalKey` | 整棵树全局唯一 | 跨位置访问特定 State、Form 或移动整棵子树 |

不要用 `UniqueKey` 修复列表串位。每次 build 都创建新 key 会让所有旧 State 失配，输入和焦点直接丢失。普通数据列表也不需要 `GlobalKey`；它的全局注册、子树移动和依赖重建成本都高于稳定 `ValueKey`。

## Flutter 3.47 使用 `onReorderItem`

可排序值班板的纯数据函数执行 remove 后直接 insert：

<<< ../../../examples/focus/sortable_duty_board/lib/src/duty_data.dart#reorder-data{dart}

Flutter 3.47 的 `ReorderableListView.onReorder` 已弃用。新参数 `onReorderItem` 传入的 `newIndex` 已按旧项移除后的列表调整，不再使用旧教程常见的：

```dart
if (newIndex > oldIndex) newIndex -= 1;
```

再减一次会把向后移动的项目插早一位。项目把稳定 key 放在 ReorderableListView 的直接子级上：

<<< ../../../examples/focus/sortable_duty_board/lib/src/sortable_duty_board.dart#keyed-reorder-list{dart}

每项都必须有 key。`buildDefaultDragHandles: false` 关闭平台默认拖动入口，项目在行内放置明确的拖动把手，同时提供“上移 / 下移”按钮。后者不是重复功能：普通键盘和部分辅助技术用户需要可见、可聚焦的替代路径。

## 项目简报

可排序值班板模拟社区站白班排位。每位成员有姓名、呼号和时段；值班员可以记录交接备注、确认交接，再调整成员顺序。

必须满足：

- 拖动和按钮重排共用同一份列表状态；
- 备注与确认状态留在各自行内；
- 重排后，两者仍属于同一成员；
- 首项不能继续上移，末项不能继续下移；
- 操作结果进入 live region；
- 320×720 和 200% 文本缩放下无 overflow。

视觉方向是“活字排版台”：深色装版区、纸色值班条、氧化红行动标记和蓝色校样操作。它没有照搬官方 ReorderableList 示例，业务身份、替代操作和状态验证都是项目自己的任务。

## 先制造能看见的身份状态

只断言名字顺序变化，最多证明列表模型改了，不能证明 State 没有串位。Widget 测试先在安岚行写入备注并勾选确认，再把安岚下移，最后按业务 key 找到输入框：

<<< ../../../examples/focus/sortable_duty_board/test/sortable_duty_board_test.dart#identity-reorder-test{dart}

这个测试同时经过三层：

1. 纯函数产生新列表顺序；
2. 页面按新顺序重建行 Widget；
3. `ValueKey(member.id)` 让旧 Element 和 State 移到同一成员的新位置。

如果去掉行 key，名字顺序测试仍可能通过，备注与复选框断言会暴露错配。

## 运行与检查

项目路径：`examples/focus/sortable_duty_board`。

```powershell
flutter analyze
flutter test examples/focus/sortable_duty_board/test
cd examples/focus/sortable_duty_board
flutter run -d chrome
```

release Web 构建：

```powershell
flutter build web --release --base-href /flutter-tutorial/previews/sortable-duty-board/
```

浏览器中分别用鼠标拖动和 Tab + Enter 操作上移、下移按钮。确认焦点可见，状态文本更新，移动到边界后对应按钮禁用。

## 项目完成检查

- [ ] 能用 Widget、Element、State 三层解释“备注留在位置上”。
- [ ] 能说明 Key 的匹配范围，并把 key 放在被重排的直接子级上。
- [ ] 能根据业务身份选择 `ValueKey`，不用 `UniqueKey` 掩盖问题。
- [ ] 使用 Flutter 3.47 的 `onReorderItem`，向后移动时不再手工减索引。
- [ ] 拖动与上移 / 下移按钮调用同一重排逻辑。
- [ ] 测试先制造行内状态，再验证它跟随同一业务 ID。
- [ ] analyze、Unit、Widget、Chrome 关键流程和 release Web build 全部通过。

## 复习线索

- 没有 key 的同类型兄弟默认按位置匹配；State 属于 Element，不属于数据对象。
- Key 参与同一父级下的兄弟更新匹配，不执行排序也不持久化数据。
- 稳定业务 ID 使用 `ValueKey`；`UniqueKey` 会主动放弃复用。
- [项目源码](https://github.com/mardd123588/flutter-tutorial/tree/main/examples/focus/sortable_duty_board)

## 参考资料

- [Widget.canUpdate API](https://api.flutter.dev/flutter/widgets/Widget/canUpdate.html)（查阅：2026-08-30）
- [Key API](https://api.flutter.dev/flutter/foundation/Key-class.html)（查阅：2026-08-30）
- [ValueKey API](https://api.flutter.dev/flutter/foundation/ValueKey-class.html)（查阅：2026-08-30）
- [GlobalKey API](https://api.flutter.dev/flutter/widgets/GlobalKey-class.html)（查阅：2026-08-30）
- [ReorderableListView API](https://api.flutter.dev/flutter/material/ReorderableListView-class.html)（查阅：2026-08-30）
- [ReorderableListView.onReorderItem API](https://api.flutter.dev/flutter/material/ReorderableListView/onReorderItem.html)（查阅：2026-08-30）
