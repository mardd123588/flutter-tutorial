---
title: 把 Flutter 跑起来
description: 固定 Flutter 版本，认识项目结构，并分清 hot reload 与 hot restart。
part: 1
order: 1
kind: concept
requires: []
provides:
  - toolchain.flutter
  - project.anatomy
  - workflow.hot-reload
status: verified
---

# 把 Flutter 跑起来

这一章只解决环境和工作方式。结束时，你应当能在 Chrome 中运行一个 Flutter 项目，知道代码放在哪里，也能解释一次修改该用 hot reload 还是 hot restart。

## 固定版本再开始

本教程使用 Flutter 3.47.0 和 Dart 3.13.0。先看当前环境：

```powershell
flutter --version
flutter doctor -v
flutter devices
```

`flutter --version` 决定代码和 API 的基线。`flutter doctor -v` 检查 SDK、浏览器和平台工具；`flutter devices` 只列当前能启动的目标。三条命令回答的问题不同，不能用 doctor 没报错推断 Chrome 一定已经被识别。

如果你使用版本管理工具，把本教程版本固定在仓库，而不是依赖某台电脑碰巧安装的默认版本。仓库后续会在 CI 中再次固定 Flutter 3.47.0。

## 创建和运行项目

下面的命令只用于认识流程。正式项目已经放在仓库的 `examples/` 中，不需要重复创建。

```powershell
flutter create rhythm_probe --platforms=web
cd rhythm_probe
flutter run -d chrome
```

终端出现调试快捷键后，保持进程运行。改动 `lib/main.dart`，保存文件，Flutter 通常会自动触发 hot reload；也可以在终端按 `r`。

### 找不到 Chrome 时看哪里

`No supported devices connected` 只说明 Flutter 当前没有可用目标。按这个顺序检查：

1. `flutter devices` 是否列出 Chrome。
2. Chrome 是否安装在 Flutter 能识别的位置。
3. 终端是否在正确项目目录，目录中应当存在 `pubspec.yaml`。
4. `flutter doctor -v` 的 Chrome 项是否仍有错误。

把这类问题归到“设备发现”，不要一开始就改应用代码。

## 项目里哪些文件负责什么

一个最小 Flutter Web 项目里，最常用的路径不多：

| 路径 | 作用 |
| --- | --- |
| `lib/` | Dart 与 Flutter 源码，应用入口通常是 `lib/main.dart` |
| `test/` | 单元测试和 Widget 测试 |
| `integration_test/` | 在完整应用上运行的关键流程测试 |
| `web/` | Web 启动页、图标和 manifest 等平台外壳 |
| `pubspec.yaml` | SDK 范围、依赖、资源和包信息 |
| `analysis_options.yaml` | 静态分析与 lint 规则 |
| `build/` | 构建产物，可删除后重新生成，不手工维护 |

Flutter 的共享业务代码放在 `lib/`。`web/` 不是另一份应用，它只负责浏览器启动 Flutter 所需的外层文件。

## Hot reload 保留了什么

hot reload 会把更新后的 Dart 代码注入正在运行的 Dart VM，再让现有 Widget tree 重建。已有 `State` 通常会保留，所以你能在不丢当前操作位置的情况下调整界面。

下面这些修改经常需要 hot restart：

- 改了 `main()` 之前只执行一次的初始化；
- 改了全局变量或静态字段的初始值，希望它重新计算；
- 状态对象的结构变化让现有实例无法继续使用；
- reload 后的现象与代码明显不一致，需要排除旧状态影响。

hot restart 会重新运行 Dart 应用，但不重新编译浏览器外壳。修改 `web/index.html`、原生插件配置或平台代码时，通常要停止并重新运行。

::: warning 不要用 reload 结果证明初始化正确
hot reload 会保留状态。某个页面 reload 后正常，不代表应用从冷启动进入该页面也正常。初始化、路由恢复和持久化都要单独测试冷启动。
:::

## 可验证任务

1. 运行一个最小 Web 项目，把页面标题改成自己的文字，确认 hot reload 后界面更新。
2. 在 `State` 中放一个递增数字，点几次后修改它的初始值。先 reload，再 restart，记录两次结果为什么不同。
3. 运行 `flutter analyze`，确认静态分析和“能在浏览器打开”是两项独立检查。

## 复习线索

- 环境问题先区分 SDK、设备发现和项目目录。
- `lib/` 是共享应用代码，`web/` 是浏览器外壳。
- hot reload 保留现有状态；hot restart 重新运行 Dart 应用。

## 参考资料

- [Install Flutter](https://docs.flutter.dev/get-started/install)（查阅：2026-08-29）
- [Flutter CLI reference](https://docs.flutter.dev/reference/flutter-cli)（查阅：2026-08-29）
- [Hot reload](https://docs.flutter.dev/tools/hot-reload)（查阅：2026-08-29）
