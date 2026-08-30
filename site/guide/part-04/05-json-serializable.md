---
title: json_serializable 与生成代码
description: 对照手写映射理解 annotation、build_runner、默认宽松行为和生成器边界。
part: 4
order: 5
kind: concept
requires:
  - data.json
  - model.immutable
provides:
  - codegen.json-serializable
  - tool.build-runner
status: verified
---

# json_serializable 与生成代码

手写模型先建立了字段合同。`json_serializable` 接着替换重复的取值、类型转换和键名映射，不替你决定字段是否可信、错误如何呈现、模型是否不可变，也不生成业务校验。

## annotation 描述映射

城市活动 DTO 使用普通 class、`@JsonSerializable()` 和 `part`：

<<< ../../../examples/capstones/city_event_radar/lib/src/event_dto.dart#generated-event-dto{dart}

`@JsonKey(name: 'starts_at')` 只处理 JSON 键名与 Dart 字段名不同的情况。生成的 `fromJson` 和 `toJson` 是普通 Dart 代码，运行时不需要反射，Web 也不需要额外生成器。

依赖分成两类：

```yaml
dependencies:
  json_annotation: 4.12.0

dev_dependencies:
  build_runner: 2.16.0
  json_serializable: 6.14.1
```

annotation 留在运行时代码中；生成器只在开发和 CI 阶段执行。

## 生成命令和 part 必须对齐

一次生成：

```powershell
dart run build_runner build
```

持续监听：

```powershell
dart run build_runner watch
```

源文件 `event_dto.dart` 对应 `part 'event_dto.g.dart';`。文件名、part 名或 class annotation 不一致时，生成文件不会出现或无法被库引用。

生成代码应提交到仓库，因为教程、CI 和使用者都需要相同映射。不要手改 `.g.dart`；修改 annotation 或字段后重新生成。生成器报告冲突时，先确认文件是否由另一套命令或旧分支生成，不把 `--delete-conflicting-outputs` 当作无条件清理按钮。

## 默认行为仍然宽松

`json_serializable` 默认忽略未知字段，等价于 `disallowUnrecognizedKeys: false`。这对服务端向前增加字段很实用，但不能写成“生成器自动拒绝所有合同变化”。

必填非 nullable 字段缺失时，生成代码通常在 cast 或构造阶段失败。若项目需要统一、带字段上下文的错误，可使用 checked generation，再在外层捕获 `CheckedFromJsonException`。是否打开 checked 是可观测性取舍，不是所有模型的固定配置。

`defaultValue`、`required`、nullable 和自定义 `fromJson` 要逐字段选择。不要用默认值掩盖服务端本应提供的关键数据。

## 外层容器仍适合手写

活动响应的 envelope 包含 `generated_at` 和 `events`。项目手写根节点、数组与索引检查，再把每个条目交给生成 DTO：

<<< ../../../examples/capstones/city_event_radar/lib/src/event_feed.dart#hand-written-feed-envelope{dart}

这是一种常见组合：

- 外层负责响应版本、分页、列表索引和错误位置；
- 生成 DTO 负责稳定字段映射；
- `toDomain()` 负责复制集合或转换到界面模型。

生成器不会替代这些边界。

## 用同一 fixture 对照

迁移到生成代码前，保留手写模型的 fixture 表。让手写版和生成版同时解析：

- 完整对象；
- 未知字段；
- 缺失必填字段；
- null；
- 错误类型；
- 时间转换失败。

两套结果一致后再删除重复映射。这样引入生成器的收益是减少机械代码，而不是悄悄改变容错策略。

## 可验证任务

把一个手写活动 DTO 改为 `json_serializable`：

1. 添加 annotation、part 和两个生成方法。
2. 用 `JsonKey` 映射 snake_case 时间字段。
3. 运行 build_runner，并检查生成文件进入版本控制。
4. 同一组 fixture 同时跑手写版和生成版。
5. 说明未知字段、缺失字段和 nullable 的实际行为。
6. 增加一个业务规则测试，证明它仍由模型或业务代码负责。

## 复习线索

- `json_serializable` 生成 JSON 映射，不生成不可变性、相等或业务校验。
- annotation 是运行时依赖；build_runner 和 generator 是开发依赖。
- 默认忽略未知字段；严格模式和 checked 错误要显式选择。
- 外层 envelope、列表索引和错误呈现仍由应用代码负责。

## 参考资料

- [json_serializable 6.14.1 README](https://github.com/google/json_serializable.dart/blob/json_serializable-v6.14.1/json_serializable/README.md)（查阅：2026-08-30）
- [JsonSerializable 4.12.0 API](https://pub.dev/documentation/json_annotation/4.12.0/json_annotation/JsonSerializable-class.html)（查阅：2026-08-30）
- [JsonKey 4.12.0 API](https://pub.dev/documentation/json_annotation/4.12.0/json_annotation/JsonKey-class.html)（查阅：2026-08-30）
- [CheckedFromJsonException API](https://pub.dev/documentation/json_annotation/4.12.0/json_annotation/CheckedFromJsonException-class.html)（查阅：2026-08-30）
- [build_runner package](https://pub.dev/packages/build_runner/versions/2.16.0)（查阅：2026-08-30）
