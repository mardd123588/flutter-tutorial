# Flutter 项目使用 pub workspace 管理

13 个独立 Flutter 项目与可验证片段加入 Dart pub workspace，只共享依赖解析、lint 和验证工具，不共享业务包。仓库不引入 Melos；Node 侧只有一个 VitePress 包，由根目录 `package.json` 与 `pnpm-lock.yaml` 管理，减少读者需要理解的仓库工具层。
