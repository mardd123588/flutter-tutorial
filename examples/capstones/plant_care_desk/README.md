# 植物照护台

第三部分统筹项目。温室值班员可以筛选植物、记录一次浇水、查看状态变化并撤销上次操作。列表会按照护紧迫度重新排序，展开状态通过稳定 Key 留在对应植物上。

页面用 `ChangeNotifier` 保存共享状态，用 `InheritedNotifier` 把控制器提供给子树。湿度变化使用隐式动画，操作回执使用由 `AnimationController` 管理的显式过渡；系统要求减少动画时，两者都直接显示终态。

最近一次浇水会保存完整快照。切换到“需要照护”后完成浇水，记录会离开当前结果；撤销会恢复操作前的植物数据与筛选条件。稳定 `ValueKey` 让卡片展开状态在重排后仍属于同一植物。

## 运行

```powershell
flutter test examples/capstones/plant_care_desk/test
cd examples/capstones/plant_care_desk
flutter run -d chrome
```

构建 Pages 预览：

```powershell
flutter build web --release --base-href /flutter-tutorial/previews/plant-care-desk/
```

项目不访问外部服务。植物、区域与湿度均为教学示例数据，刷新页面会恢复源码中的初始记录。

氧化金属、雾面表盘、铜针、刻度和检修戳都由项目内的 `CustomPainter` 绘制，没有外部图片或第三方字体资产。
