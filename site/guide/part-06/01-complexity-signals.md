---
title: 复杂度从哪里出现
description: 从状态、I/O、同步与测试信号判断应用何时需要分层，并建立单一事实来源和单向数据流。
part: 6
order: 1
kind: concept
requires:
  - state.ownership
  - data.service
  - navigation.router
provides:
  - architecture.complexity-signals
  - architecture.ssot
  - architecture.udf
status: verified
---

# 复杂度从哪里出现

页面代码变长不一定需要新架构。真正麻烦的是责任开始互相牵连：一个 Widget 既读数据库，又改缓存，还要判断业务规则；同一份数据在页面、controller 和存储里都能写；为了测一条规则，必须启动整棵 Widget 树。

应用架构先解决这些同步与依赖问题。目录只是结果，不是起点。

## 先把页面里的五类东西分开

看一段混合页面时，先标出这些内容：

| 类别 | 例子 | 常见所有者 |
| --- | --- | --- |
| 局部 UI state | 当前输入、展开状态、焦点 | View |
| 业务 state | 活动列表、收藏、排期 | Repository 或 ViewModel |
| 派生 state | 筛选结果、总数、是否可提交 | 从源状态计算 |
| I/O | HTTP、数据库、平台插件 | Service |
| 一次性副作用 | 导航、SnackBar、焦点移动 | View 在明确结果后执行 |

下面这类写法可以工作，但责任已经粘在一起：

```dart
Future<void> save() async {
  setState(() => saving = true);
  final rows = await database.readRows();
  final conflict = rows.any(overlapsDraft);
  if (conflict) {
    setState(() {
      saving = false;
      errorText = '时间冲突';
    });
    return;
  }
  await database.write(draft);
  if (!mounted) return;
  setState(() => saving = false);
  Navigator.pop(context);
}
```

这里混有按钮状态、数据库访问、冲突判断、错误文案和导航。改存储会碰页面，改规则也会碰页面；规则测试还得构造 Widget。

## 单一事实来源管的是写入权

单一事实来源（single source of truth）不是“全应用只有一个对象”。它要求某类可修改数据只有一个负责写入的位置。

例如排期记录由 Repository 管理：

```text
数据库查询结果 ──→ Repository ──→ 页面状态
                       ↑
                    保存动作
```

页面可以持有编辑草稿，但草稿不是已经保存的排期。筛选结果也不需要另存一份可写列表，它应由“完整排期 + 筛选条件”计算得到。

重复存储派生值会制造同步问题：

```dart
// 容易漂移：entries 和 visibleEntries 都能被改。
List<Entry> entries = [];
List<Entry> visibleEntries = [];

// 更稳：只保存源状态。
List<Entry> get visibleEntries =>
    entries.where((entry) => filter.matches(entry)).toList();
```

URL、数据库和页面草稿可以各自成为不同数据的事实来源。边界清楚比“统一放进一个大状态对象”更重要。

## 单向数据流让修改路径可追踪

单向数据流（unidirectional data flow）把状态和事件分开：

```text
状态：Repository / ViewModel ──→ View ──→ Widget
事件：用户操作 ──→ View ──→ ViewModel / Repository
```

View 根据不可变状态绘制。用户点击保存后，意图沿反方向进入逻辑层；写入完成，新的状态再流回 View。页面不直接改数据库结果，也不让 Service 主动操纵 Widget。

这条流向没有规定必须使用哪个状态管理包。`StatefulWidget`、`ChangeNotifier` 和 Riverpod 都能实现单向数据流，差别在对象创建、订阅范围、生命周期和依赖替换能力。

## 七个值得停下来整理的信号

出现一项不必立刻重构。多项一起出现，继续把代码塞进页面通常会越来越难测。

1. 一个 Widget 同时处理输入、I/O、缓存、错误和显示文字；
2. 同一份业务数据存在多个可写副本；
3. 两个以上页面需要相同数据或写入规则；
4. 保存、刷新、删除各自带运行中、失败、重试和防重复边界；
5. 测一条规则必须启动完整 Widget 树或真实数据库；
6. 把 fixture 换成真实实现时，需要修改调用方；
7. 多个 ViewModel 重复组合多个 Repository 的同一条复杂规则。

前五项通常说明 UI 与 data 责任该分开。第六项说明依赖接缝不清楚。第七项持续出现时，才值得考虑独立 domain use-case。

## 渐进迁移，不同时换掉所有东西

整理旧页面时保留可运行基线：

1. 先补加载、空、成功、失败和提交结果的行为测试；
2. 标出 UI state、业务 state、派生值、I/O 与副作用；
3. 先提取一个外部数据源；
4. 再确定业务数据的唯一写入点；
5. 最后移动页面组合逻辑和动作状态。

每一步只改变一条依赖边界。若页面已经很小，只有一个局部开关或输入框草稿，停在 `StatefulWidget` 完全合理。

## 别和 Flutter 框架内部架构混在一起

Widget、Element、RenderObject 描述 Flutter 如何维护配置、身份和渲染对象。本部分讨论的是你的应用如何分配 View、业务逻辑和数据访问责任。

两者会在运行时相遇，但解决的问题不同：应用分层不能解释布局约束，Element 树也不会替你决定数据库写入应该放在哪里。

## 可验证任务

找一个同时包含列表、筛选、保存和错误提示的旧页面，只做责任标注，不重构：

- 圈出源状态与派生状态；
- 标出所有 I/O 调用；
- 写出每类可修改数据的唯一写入者；
- 画出一次“点击保存”的事件方向和状态返回方向；
- 指出当前最小的一个提取接缝，并说明为什么不一次拆完。

如果页面只有局部 UI state，也要明确写下“不分层”的理由。

## 常见误区

- 用文件行数或项目人数直接决定架构层数。
- 把所有状态塞进一个全局对象，称为单一事实来源。
- 保存源列表和筛选列表两份可写数据。
- 一次性更换目录、状态包、错误类型和存储实现。
- 把 Clean Architecture 的目录数量当作完成度。

## 复习线索

- 复杂度来自责任互相牵连，不来自页面看起来长。
- 单一事实来源限制写入权；派生数据从源状态计算。
- 状态向下，用户意图向上，写入发生在明确的所有者中。
- 多个复杂度信号一起出现时再增加结构，小功能可以停在 SDK 方案。

## 参考资料

- [Flutter common architecture concepts](https://docs.flutter.dev/app-architecture/concepts)（查阅：2026-08-30）
- [Flutter architecture recommendations](https://docs.flutter.dev/app-architecture/recommendations)（查阅：2026-08-30）
- [Flutter guide to app architecture](https://docs.flutter.dev/app-architecture/guide)（查阅：2026-08-30）

