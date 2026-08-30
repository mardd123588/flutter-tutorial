---
title: 手写 JSON 模型
description: 从 dynamic payload 建立不可变 DTO，并明确缺字段、null、类型错误与未知字段策略。
part: 4
order: 3
kind: concept
requires:
  - data.service
  - dart.const
provides:
  - data.json
  - model.immutable
  - error.decode
status: verified
---

# 手写 JSON 模型

`jsonDecode` 只证明文本符合 JSON 语法，返回值仍是由 Map、List、数字、字符串、布尔和 null 组成的动态结构。模型解析的工作，是把这组不可信值变成应用可以依赖的类型，并在不符合合同时给出可定位错误。

## 先检查容器，再读字段

不要从 `dynamic` 开始连续 `as`：

```dart
final title = (jsonDecode(body) as Map<String, dynamic>)['title'] as String;
```

根节点、列表项和字段任一层不符合预期时，这段代码只留下零散的类型错误。更稳的顺序是：

1. 根节点必须是对象。
2. 列表字段必须是数组。
3. 每个条目必须是对象。
4. 模型构造函数逐字段检查并转换。

书目模型把字段错误写成明确的 `FormatException`：

<<< ../../../examples/focus/instant_book_search/lib/src/book.dart#hand-written-book-json{dart}

Service 捕获这些错误，再加上“响应格式错误”的任务上下文。模型不需要知道 HTTP status，Service 也不需要知道字段如何显示。

## 缺失、null 和类型错误不同

JSON 对象的字段有四种情况：

| 输入 | 含义示例 | 处理策略 |
| --- | --- | --- |
| 缺失 | 服务端没发送 `venue` | 必填字段报错；可选字段使用明确默认值 |
| null | 服务端明确发送 `"venue": null` | 只有模型允许 null 时接受 |
| 类型错误 | `"year": "2024"` | 默认报错，不悄悄猜转换 |
| 未知字段 | 新增 `"source": "city"` | 默认忽略，严格接口可拒绝 |

缺失和 null 不应自动合并。`json['note'] ?? ''` 会把“没发送”和“明确为空”都变成空字符串，还可能把服务端合同变化藏起来。

数字也要按接口合同处理。JSON 没有 int 与 double 两种语法类别，Dart decoder 会按字面量返回 `int` 或 `double`。若接口允许 `3` 和 `3.0`，模型可以接收 `num` 后显式转换；若只允许整数，直接拒绝小数更安全。

## DTO 保持不可变

从网络来的模型适合使用 final 字段和 const 构造函数。不可变并不自动带来值相等，但能保证解析后字段不会在多个消费者之间被原地修改。

列表字段还要考虑集合本身：

```dart
tags: List.unmodifiable(rawTags),
```

只把字段声明成 `final List<String>`，调用方仍能 `tags.add(...)`。是否复制取决于数据边界；跨 Service 返回的 DTO 默认不应暴露可变输入集合。

## 转换规则写在边界上

时间字符串先用 `DateTime.tryParse`，失败时保留字段名。枚举不要用 `Enum.values.byName` 直接把未知值变成难懂异常，可以提供显式映射：

```dart
EventKind parseKind(Object? value) => switch (value) {
  'walk' => EventKind.walk,
  'workshop' => EventKind.workshop,
  _ => throw FormatException('未知 kind：$value'),
};
```

如果后端允许向前兼容的未知枚举，可增加 `unknown`；如果该字段决定计费或权限，拒绝未知值更合适。策略来自字段用途，不来自统一模板。

## 错误要能定位到条目

解析列表时，外层应补上索引：

```dart
for (var index = 0; index < values.length; index += 1) {
  try {
    items.add(Item.fromJson(values[index]));
  } catch (error) {
    throw FormatException('items[$index] 解析失败：$error');
  }
}
```

这样“第三项缺 title”不会变成整页的“网络失败”。生产日志可以保留 URI、status 和受限响应摘要；用户界面只需要说明数据暂时无法读取并提供恢复动作，不能把完整响应或敏感字段直接展示出来。

## 可验证任务

为城市活动 DTO 准备一张 fixture 表，逐项验证：

1. 完整对象成功解析，并忽略一个未知字段。
2. 必填字段缺失、为 null、类型错误时分别失败。
3. 可选字段缺失时使用文档中声明的默认值。
4. 无效时间和未知枚举保留字段名。
5. 列表第二项错误时，异常包含 `events[1]`。
6. 解析后的 tags 不能被外部修改。

## 复习线索

- `jsonDecode` 验证语法，模型 parser 验证结构和字段合同。
- 缺失、null、错误类型和未知字段是四种情况。
- DTO 默认不可变；集合边界也要避免暴露可变输入。
- 外层补容器路径和索引，内层说明具体字段。

## 参考资料

- [dart:convert library](https://api.dart.dev/dart-convert/)（查阅：2026-08-30）
- [jsonDecode API](https://api.dart.dev/dart-convert/jsonDecode.html)（查阅：2026-08-30）
- [FormatException API](https://api.dart.dev/dart-core/FormatException-class.html)（查阅：2026-08-30）
- [DateTime.tryParse API](https://api.dart.dev/dart-core/DateTime/tryParse.html)（查阅：2026-08-30）
