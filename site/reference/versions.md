---
title: 适用版本
description: 教程使用的工具链、主要教学依赖与版本边界。
---

# 适用版本

首版正文和示例以根 `pubspec.lock`、`pnpm-lock.yaml` 和 CI 配置为准。下面记录当前验证过的工具链与主要教学依赖，不表示所有较新版本都兼容。

## 工具链

| 工具 | 版本 |
| --- | --- |
| Flutter | 3.47.0 |
| Dart | 3.13.0 |
| Node.js | CI 使用 22 LTS；本地支持 22～26 |
| VitePress | 1.6.4 |
| Vue | 3.5.42 |
| pnpm | 10.34.5 |

CI 固定 Node.js 22 主版本，依赖安装仍由 lockfile 约束；本地 `engines` 接受 22～26。Flutter SDK 升级要单独运行完整验证，不能只凭 Dart 版本范围判断兼容性。

## 主要教学依赖

| 用途 | 包 | 版本 |
| --- | --- | --- |
| 路由 | `go_router` | 18.0.0 |
| 状态管理 | `flutter_riverpod` | 3.4.2 |
| Riverpod 注解 | `riverpod_annotation` | 4.0.6 |
| Riverpod 生成器 | `riverpod_generator` | 4.0.8 |
| 关系数据 | `drift` | 2.34.3 |
| Flutter 数据库接入 | `drift_flutter` | 0.3.1 |
| HTTP | `http` | 1.6.0 |
| JSON 注解 | `json_annotation` | 4.12.0 |
| JSON 生成器 | `json_serializable` | 6.14.1 |
| 本地偏好 | `shared_preferences` | 2.5.5 |
| 本地化格式 | `intl` | 0.20.3 |
| 用户可见字符计数 | `characters` | 1.4.1 |

## 版本边界

- 教程讲的是上表版本已经验证的 API；升级时先读 changelog 和迁移说明，再更新 lockfile。
- 代码生成包与运行时包一起升级，并重新生成源码。
- Drift Web 升级后重新检查 `sqlite3.wasm`、Worker、MIME 和浏览器持久化。
- Flutter、路由、Riverpod 或数据库跨主要版本时，运行 13 个项目的分析、测试、Chrome 集成测试和 Web release 构建。
- 具体发布步骤见[发布清单](/reference/release-checklist)。
