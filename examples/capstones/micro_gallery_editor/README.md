# 小型展览编辑器

第二部分统筹项目。策展人可以筛选展品卡，新增、编辑、保存和删除展品，并用键盘完成同一条主要流程。

数据只保存在内存中，刷新页面会恢复种子展品。项目集中验证布局、组件接口、同步表单验证、controller 与焦点生命周期、快捷键和语义状态，不提前引入网络、持久化或全局状态管理。

## 运行

```powershell
flutter test examples/capstones/micro_gallery_editor/test
cd examples/capstones/micro_gallery_editor
flutter run -d chrome
```

构建 Pages 预览：

```powershell
flutter build web --release --base-href /flutter-tutorial/previews/micro-gallery-editor/
```

项目不访问外部服务，数据和视觉资源都在仓库内。
