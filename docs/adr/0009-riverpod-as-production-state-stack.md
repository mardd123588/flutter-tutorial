# 生产实践采用 Riverpod 3

教程先讲 `StatefulWidget`、`InheritedWidget`、`Listenable` 与 `ChangeNotifier`，生产实践再统一使用 Riverpod 3 处理异步状态、缓存失效、依赖替换和测试。主线不使用 hooks，代码生成只在重复达到明确阈值时引入；Flutter 3.47 的探针已通过 analyze、Widget 测试、Chrome 集成测试和 release Web 构建。
