# 路线分享卡

第五部分的重点项目，用稳定路线 ID 和可验证的 query 参数组成可分享链接。项目内只有三条固定路线，不访问地图、网络、定位、数据库或登录服务。

项目覆盖这些边界：

- `/routes/:routeId` 保存路线身份；
- `mode` 和 `start` 保存可选偏好；
- 重复参数、未知枚举、超长起点、不存在的路线和未匹配地址分别处理；
- 复制完整 URL 后，不依赖 `extra` 或内存状态即可恢复同一路线；
- 自绘路线只作摘要，站点列表承担实际阅读和操作。

## 运行

```powershell
cd examples/focus/route_share_card
flutter test test
flutter run -d chrome
```

Chrome 集成测试需要先在 4444 端口启动 ChromeDriver：

```powershell
flutter drive -d web-server --browser-name=chrome --driver=test_driver/integration_test.dart --target=integration_test/route_share_card_test.dart
```

构建 Pages 预览：

```powershell
flutter build web --release --base-href /flutter-tutorial/previews/route-share-card/
```

部署后还要从 `#/routes/museum-loop?mode=quiet` 直达，检查刷新、Back、Forward 和复制到新标签。开发服务器能刷新，不代表 GitHub Pages 的部署路径已经正确。
