---
title: Workspace、依赖与配置
description: 用 pub workspace、锁文件和公开编译时配置固定多项目仓库的依赖输入，同时守住 Web 客户端的秘密边界。
part: 8
order: 1
kind: concept
requires:
  - ecosystem.package-evaluation
  - project.anatomy
provides:
  - engineering.pub-workspace
  - engineering.dependencies
  - engineering.config
status: verified
---

# Workspace、依赖与配置

仓库里只有一个 Flutter 应用时，项目自己的 `pubspec.yaml` 足以描述大部分输入。现在仓库有 13 个独立项目，还要构建 VitePress 站点。依赖解析、锁文件、工具版本和公开配置必须从仓库根统一说明，否则本地与 CI 很容易各用一套输入。

## Pub workspace 共享解析，不共享业务代码

根 `pubspec.yaml` 列出全部成员：

<<< ../../../pubspec.yaml{yaml}

Dart 3.11 起，workspace 成员也可以用 glob，并可继续组织嵌套 workspace。本仓库仍显式列出 13 个项目：课程项目数量变化不频繁，成员增删能直接出现在 manifest diff 中。

每个成员仍有自己的 `pubspec.yaml`，并声明：

```yaml
environment:
  sdk: '>=3.13.0 <4.0.0'

resolution: workspace
```

Pub 在 workspace 根生成一个 `pubspec.lock` 和一份 `.dart_tool/package_config.json`。从根目录或成员目录运行 `flutter pub get`，都会使用这次统一解析。

Workspace 没有让成员自动看见彼此的 `lib/`。一个项目若要导入另一个包，仍须在 `dependencies` 中显式声明；同一 workspace 的本地包可以使用普通依赖声明，不要求再写 `path`。本教程刻意不建立这些项目间依赖：13 个练习项目共享工具输入，但不共享 domain、Repository、主题或组件包。读者可以单独打开、阅读和删改任一项目。

## Manifest、lockfile 与缓存各管一件事

| 文件或机制 | 回答的问题 |
| --- | --- |
| `pubspec.yaml` | 这个 Dart / Flutter 包允许哪些依赖和版本范围？ |
| `pubspec.lock` | 本仓库这次解析到哪些精确版本和内容 hash？ |
| `package.json` | Node 工具、脚本和允许的 Node 版本是什么？ |
| `pnpm-lock.yaml` | Node 依赖图具体解析成什么？ |
| Pub / pnpm cache | 已下载的包能否复用，少走网络？ |

缓存只影响下载成本。锁文件不匹配时，即使命中缓存，安装也应失败。

CI 使用两条 locked install：

```powershell
flutter pub get --enforce-lockfile
pnpm install --frozen-lockfile
```

`--enforce-lockfile` 要求现有 Dart 锁文件精确满足 manifest；`--frozen-lockfile` 禁止 pnpm 在安装时改写锁文件。依赖升级要先在独立变更中更新 manifest 和 lockfile，再提交两者的 diff。

## Direct、transitive 与 dev dependency

项目源码直接导入的包放在 `dependencies`。测试、生成器和只在开发阶段运行的工具放在 `dev_dependencies`。传递依赖由 Pub 解出，项目不为了“锁住版本”把它们全部抄进 manifest；精确结果已经在 lockfile 中。

判断一个包放在哪里，可以问两个问题：

1. `lib/` 或应用运行时是否直接使用它？是，就放 `dependencies`。
2. 只有测试、生成代码或开发命令需要它吗？是，就放 `dev_dependencies`。

生成文件是另一条边界。`exchange_database.g.dart` 由 Drift 生成并提交，因为项目要让读者直接运行和阅读；它的源声明仍在 `exchange_database.dart`，升级生成器后必须重新生成并检查 diff。

Flutter 资产需要同时满足两件事：文件存在，且项目 `pubspec.yaml` 已声明。Web 专用文件如 `sqlite3.wasm` 和 `drift_worker.js` 放在 `web/`，由发布脚本额外检查，不能只凭本地开发服务器成功就认为 release 已携带它们。

## 项目清单是仓库工具的共同输入

根 workspace 解决 Dart 包解析，发布工具还需要 slug、路径、章节和集成测试入口。本仓库把它们集中在 `tool/projects.json`：

<<< ../../../tool/projects.json{json}

受影响项目检测、独立构建、Pages 合并和 smoke test 都读取这份清单。新增项目若只改 workspace，却没加入清单，仓库检查会把未知 `examples/` 路径视为全量变化；发布前仍应补齐清单，而不是依赖这个保守回退长期运行。

## 编译时配置只能放公开值

Flutter 支持 `--dart-define`：

```powershell
flutter build web --release `
  --dart-define=APP_ENV=demo `
  --dart-define=CONTENT_VERSION=a1985a4
```

Dart 代码可读取这些值：

```dart
const appEnvironment = String.fromEnvironment(
  'APP_ENV',
  defaultValue: 'local',
);
const contentVersion = String.fromEnvironment(
  'CONTENT_VERSION',
  defaultValue: 'working-tree',
);
```

这适合环境名称、公开 API 根地址、功能开关和 commit SHA。Web 应用最终要把代码和资源交给浏览器，用户可以检查下载内容和请求。token、私钥、服务账号、数据库密码和可写后端凭据不能放进 `--dart-define`、`.env`、VitePress 配置或 Pages artifact。

Flutter 3.47.0 还提供 `--web-define=<KEY=VALUE>`，用于替换 `web/index.html` 和 `web/flutter_bootstrap.js` 中的 `{{KEY}}` 模板变量；`--dart-define` 则进入 Dart 编译时环境，供 `String.fromEnvironment` 等 API 读取。两种值都会进入浏览器可取得的产物，都只能放公开配置。

秘密应留在可信服务端或 GitHub Actions secret 中，并且只传给确实需要它的 job。即便如此，也不要把秘密写进构建日志或客户端产物。

## 可验证任务

在仓库根运行：

```powershell
flutter pub get --enforce-lockfile
pnpm install --frozen-lockfile
```

随后进入 `examples/capstones/neighborhood_exchange` 再运行 `flutter pub get --enforce-lockfile`，确认它没有生成成员级 `pubspec.lock`。检查根 `pubspec.lock` 和 `.dart_tool/package_config.json`，找出该项目的 Drift、Riverpod 与 go_router 解析结果。

最后把一个依赖约束临时改成锁文件不能满足的版本，观察 locked install 失败，再恢复 manifest。记录哪条命令失败、为什么失败；不要删除 lockfile 后把重新解析当作修复。

## 复习线索

- Pub workspace 共享解析和 lockfile，成员之间仍需显式依赖。
- Manifest 声明允许范围，lockfile记录精确结果，缓存只复用下载。
- 运行时直接依赖、开发依赖、生成文件和 Web 资产有不同归属。
- `tool/projects.json` 是 CI、构建、Pages 合并和 smoke test 的共同项目清单。
- Web 客户端能被检查，`--dart-define` 只能保存公开配置。

## 参考资料

- [Pub workspaces](https://dart.dev/tools/pub/workspaces)（查阅：2026-08-31）
- [`dart pub get`](https://dart.dev/tools/pub/cmd/pub-get)（查阅：2026-08-31）
- [Package dependencies](https://dart.dev/tools/pub/dependencies)（查阅：2026-08-31）
- [Adding assets and images](https://docs.flutter.dev/ui/assets/assets-and-images)（查阅：2026-08-31）
- [Build and release a web app](https://docs.flutter.dev/deployment/web)（查阅：2026-08-31）
- [Flutter Web FAQ: security](https://docs.flutter.dev/platform-integration/web/faq#how-do-i-securely-store-my-apps-secrets)（查阅：2026-08-31）
- [`pnpm install --frozen-lockfile`](https://pnpm.io/cli/install#--frozen-lockfile)（查阅：2026-08-31）
