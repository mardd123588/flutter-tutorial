---
title: 平台插件、权限与平台通道
description: 用 Service 接缝隔离 plugin 与平台能力，理解 federated plugin、MethodChannel、权限状态和 Web 验证边界。
part: 8
order: 5
kind: concept
requires:
  - ecosystem.package-evaluation
  - architecture.service
provides:
  - platform.plugin
  - platform.permission
  - platform.channel
  - platform.web-limit
status: verified
---

# 平台插件、权限与平台通道

Flutter 的跨平台 API 覆盖界面、输入和常用系统能力，但相机、通知、系统分享、后台任务等功能仍要调用平台实现。应用层不应到处判断 `kIsWeb` 或直接发 `MethodChannel` 消息。先定义业务需要的能力，再把 plugin 和平台代码放到基础设施边界。

## Package、plugin 与 federated plugin

| 类型 | 主要内容 |
| --- | --- |
| Dart package | Dart API 和实现，不一定包含平台代码 |
| Flutter plugin | Dart API 加一个或多个平台实现 |
| Federated plugin | app-facing API、platform interface、各平台实现分包 |

Federated 结构允许 Android、iOS、Web 等实现独立发布，也允许平台方提供 endorsed implementation。应用通常依赖 app-facing package，不直接导入每个平台包。

Pub.dev 的平台标记只说明包声明了对应实现。它没有证明权限流程、浏览器兼容、可访问性、隐私和你的业务场景已经通过。评估表应分成两列：

```text
包宣称支持的平台 | 本项目实际验证的平台
```

“邻里资源交换站”只验收 Web。系统分享、相机、通知和日历仍属于 `native verification required`。

## Service 把业务意图与 plugin 分开

项目只需要“复制可公开链接”，所以接口很小：

<<< ../../../examples/capstones/neighborhood_exchange/lib/src/platform/resource_share_service.dart{dart}

Widget 依赖 `ResourceShareService`，不知道底层是 Clipboard、系统 share sheet 还是不支持实现。Riverpod provider 负责选择当前实现，测试用 recording fake 替换它。

将来加入原生系统分享时，可以增加一个平台实现：

```dart
sealed class ShareResult {
  const ShareResult();
}

class ShareCompleted extends ShareResult {
  const ShareCompleted();
}

class ShareUnavailable extends ShareResult {
  const ShareUnavailable(this.reason);
  final String reason;
}

abstract interface class ResourceShareService {
  Future<ShareResult> share(Uri uri);
}
```

接口返回业务可处理的结果，不把 `MissingPluginException` 或平台错误字符串直接交给页面。Web 可以复制链接；原生实现可以调用 plugin；不支持的平台返回 `ShareUnavailable`。

条件导入也应停在这个目录：

```dart
import 'resource_share_stub.dart'
    if (dart.library.js_interop) 'resource_share_web.dart'
    if (dart.library.io) 'resource_share_native.dart';
```

条件导入选择实现，capability 告诉 UI 当前能做什么。业务规则和 Widget 不散布平台分支。

## MethodChannel 是异步消息边界

Flutter 平台通道在 Dart 与宿主平台之间传递消息。`MethodChannel` 通过 channel name、method name、参数和 codec 形成合同：

```dart
const channel = MethodChannel('dev.example/calendar');

Future<bool> addCalendarEntry(Map<String, Object?> entry) async {
  final result = await channel.invokeMethod<bool>('addEntry', entry);
  return result ?? false;
}
```

平台端必须注册同名 channel 和 method，并按 codec 支持的类型解码。调用是异步的；失败可能来自平台不支持、实现未注册、参数不合法、权限拒绝或宿主 API 失败。

Channel 层适合做薄适配：验证和转换参数、调用平台 API、把结果映射回稳定类型。业务规则留在 Dart Service / Repository；Widget 不直接拼 method name。

优先使用维护良好的 plugin。只有现有插件不满足合同，或者应用要调用自有平台 API 时，才维护 platform channel。自定义 channel 意味着 Android、iOS、测试、错误映射和升级都由项目负责。

## 权限是一段会变化的状态

权限流程可以画成：

```text
capability check
      ↓
current status ── denied permanently ──→ settings / explanation
      ↓ request
granted / denied / restricted / unsupported
      ↓ app resumes
recheck current status
```

不要只保存一个永久的 `bool hasPermission`。用户可以在系统设置中修改权限，应用也可能在请求期间进入后台。页面恢复到 resumed 后，要重新读取状态。

权限文案应说明当前动作需要什么，不要在应用启动时批量请求尚未使用的权限。拒绝后保留上下文和替代路径；永久拒绝、平台不支持、浏览器策略阻止与用户取消要分开显示。

不同平台的权限模型也不同：

- Android 权限受 manifest、运行时授权和版本行为影响；
- Apple 平台常要求 Info.plist purpose string，并由系统弹窗展示；
- Web 能力可能要求 HTTPS、安全上下文、用户手势或浏览器许可；
- 浏览器权限状态和原生永久拒绝不能强行映射成同一个枚举。

Service 可以统一业务结果，但不能抹掉平台上确实不同的恢复动作。

## 三种证据标签

平台能力在教程中使用三种标签：

| 标签 | 含义 |
| --- | --- |
| `Web verified` | 已在本仓库 Chrome 集成测试和 Web release 子路径验证 |
| `contract tested` | Dart 接口、fake 与错误映射有测试，未验证真实平台 API |
| `native verification required` | 需要真机、权限弹窗、商店配置或宿主代码证据 |

`contract tested` 不能写成“原生功能已完成”。Fake 证明调用者遵守接口，不能证明相机、通知或系统分享在设备上工作。

## Web 平台的硬边界

浏览器沙箱限制文件系统、后台执行、系统权限和窗口控制。Flutter plugin 即使提供 Web 实现，也可能依赖特定浏览器 API、HTTPS 或用户手势。集成测试还不能操作所有系统级权限弹窗。

遇到平台功能时，先决定验收目标：

1. Web 有等价能力：实现并做 `Web verified`。
2. Web 只有降级路径：返回 capability，界面解释限制。
3. 只在原生成立：保留 Service 合同和测试替身，标记 `native verification required`。

不要为了让 Web demo 看起来完整而伪造“系统通知已发送”或“日历已写入”。

## 可验证任务

为“分享资源链接”写一份平台合同，包含 capability、成功、不支持、取消和失败结果。实现一个 Web fake 与一个不支持实现，再写 contract test，验证两者都不会把平台异常直接抛给 Widget。

随后画出相机权限状态机，标明请求前、系统弹窗后、应用 resume 后分别读取什么。列出 Android、iOS、Web 需要的真实验证证据；没有真机证据的项标记为 `native verification required`。

## 复习线索

- Plugin 提供平台实现，federated plugin 把 API、接口与各平台实现分包。
- Service 表达业务能力，plugin 和 channel 留在基础设施边界。
- MethodChannel 是异步消息合同，不是业务状态容器。
- 权限需要 capability、请求结果和 resume 后复查。
- Package 的平台标记不等于项目已经验证该平台。
- Fake 证明调用合同，不能代替真机、权限和商店配置。

## 参考资料

- [Developing packages and plugins](https://docs.flutter.dev/packages-and-plugins/developing-packages)（查阅：2026-08-31）
- [Federated plugins](https://docs.flutter.dev/packages-and-plugins/developing-packages#federated-plugins)（查阅：2026-08-31）
- [Writing custom platform-specific code](https://docs.flutter.dev/platform-integration/platform-channels)（查阅：2026-08-31）
- [`MethodChannel`](https://api.flutter.dev/flutter/services/MethodChannel-class.html)（查阅：2026-08-31）
- [`AppLifecycleState`](https://api.flutter.dev/flutter/dart-ui/AppLifecycleState.html)（查阅：2026-08-31）
- [Android permissions](https://developer.android.com/guide/topics/permissions/overview)（查阅：2026-08-31）
- [Apple: Requesting authorization](https://developer.apple.com/documentation/bundleresources/requesting-authorization-for-media-capture-on-ios)（查阅：2026-08-31）
- [Permissions API](https://www.w3.org/TR/permissions/)（查阅：2026-08-31）
