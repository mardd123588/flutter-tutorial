# 票券排版器

第二部分的布局重点项目。三档票面宽度展示父约束如何改变 `Flex`、`Wrap` 与 `Stack` 的组合，适合读完“Flex、Wrap、Stack 的选择”后独立复习。

项目使用预设宽度，不包含文本表单。这样可以在输入章节之前只关注约束、票根排列、标签换行和局部角标。

## 运行

```powershell
flutter test examples/focus/ticket_layout_studio/test
cd examples/focus/ticket_layout_studio
flutter run -d chrome
```

更新确定性 golden：

```powershell
flutter test --update-goldens test
```

构建 Pages 预览：

```powershell
flutter build web --release --base-href /flutter-tutorial/previews/ticket-layout-studio/
```

项目不访问外部服务，数据和视觉资源都在仓库内。
