# 可排序值班板

第三部分的列表身份重点项目。值班成员可以拖动排序，也可以使用明确的上移、下移按钮。每行自己的交接备注和确认状态由该行 `State` 持有；稳定 `ValueKey` 让这些状态在重排后继续属于同一成员。

项目面向 Flutter 3.47，使用 `ReorderableListView.onReorderItem`。回调给出的目标索引已完成移除旧项后的调整，数据函数直接执行 remove 后 insert。

## 运行

```powershell
flutter test examples/focus/sortable_duty_board/test
cd examples/focus/sortable_duty_board
flutter run -d chrome
```

构建 Pages 预览：

```powershell
flutter build web --release --base-href /flutter-tutorial/previews/sortable-duty-board/
```

项目不访问外部服务。人物、站点与班次均为教学示例数据，固定在源码中。

石台、锌制装版框、校样纸纤维和套准标记都由项目内的 `CustomPainter` 绘制，没有外部图片或第三方字体资产。
