---
title: 测试策略与单元测试
description: 从功能风险选择测试层，用确定性输入、纯 Dart 单元测试和 fake 固定业务规则与状态迁移。
part: 7
order: 1
kind: concept
requires:
  - architecture.viewmodel
  - test.fake-repository
provides:
  - test.strategy
  - test.unit
  - test.determinism
status: verified
---

# 测试策略与单元测试

测试文件多，不等于风险覆盖得好。排序规则最适合用单元测试；焦点移动要挂起 Widget；URL 刷新要进入真实浏览器；滚动是否掉帧还得在 profile 模式记录 trace。先问“这条风险需要什么证据”，再选测试层。

Flutter 官方把自动化测试分为 unit、widget 和 integration。越靠近完整应用，环境更真实，运行和维护成本通常也更高。这里没有固定的 `70/20/10` 比例，每个功能按自己的失败方式组合证据。

## 从风险表开始

| 风险 | 首选证据 | 需要再补什么 |
| --- | --- | --- |
| 排序、解析、冲突规则 | unit | Repository 或 provider 状态测试 |
| ViewModel 状态迁移 | unit / provider | Widget 的用户反馈 |
| 输入、布局、焦点、Semantics | widget | Chrome 关键流程 |
| 字体、颜色、绘制结果 | golden | 人工审查 diff |
| URL、刷新、Back / Forward、Web 资产 | Chrome integration | release 子路径检查 |
| 长任务、异常 build / paint | profile trace | 同一 workload 的前后对照 |

一个行为可能需要两层证据。例如“保存冲突”可以用单元测试覆盖全部规则，再用 Widget 测试确认错误摘要得到焦点。不要在浏览器流程里重跑每一种冲突组合。

## 单元测试固定可观察合同

单元测试适合纯函数、值对象、规则对象和不接触 Flutter binding 的 ViewModel。测试应通过公开输入和输出观察行为，避免断言私有字段或内部调用顺序。

下面的排序规则先比年份，同年时再比序号，最后用稳定 ID 打破平局：

```dart
int compareRecord(ArchiveRecord left, ArchiveRecord right) {
  final year = left.year.compareTo(right.year);
  if (year != 0) return year;
  final sequence = left.sequence.compareTo(right.sequence);
  if (sequence != 0) return sequence;
  return left.id.compareTo(right.id);
}
```

测试按 arrange—act—assert 排列，失败时容易看出输入、动作和预期：

```dart
test('同年记录按序号和稳定 ID 排列', () {
  final records = [record('b', 1998, 2), record('c', 1998, 1), record('a', 1998, 1)];

  records.sort(compareRecord);

  expect(records.map((record) => record.id), ['a', 'c', 'b']);
});
```

只差输入和结果的分支适合 table-driven cases：

```dart
for (final testCase in [
  (query: ' 河岸  学校 ', expected: '河岸 学校'),
  (query: '夜校', expected: '夜校'),
  (query: '   ', expected: ''),
]) {
  test('normalizes ${testCase.query}', () {
    expect(normalizeQuery(testCase.query), testCase.expected);
  });
}
```

表格化减少重复 setup，但别把几个不同风险塞进一个循环。若失败消息已经无法指出是哪条规则，应该拆回有名字的测试。

## 稳定测试先控制输入

常见不稳定来源包括当前时间、随机数、执行顺序、共享缓存、网络和未等待的异步任务。解决办法是把变化源变成依赖，而不是增加重试次数。

```dart
typedef Clock = DateTime Function();

bool isExpired(DateTime savedAt, Clock clock) {
  return clock().difference(savedAt) > const Duration(hours: 24);
}
```

测试传入固定时钟：

```dart
final clock = () => DateTime.utc(2026, 8, 31, 12);
expect(isExpired(DateTime.utc(2026, 8, 30, 11), clock), isTrue);
```

fixture 也要固定顺序、稳定 ID 和明确数量。测试依赖“当前第一个元素”时，排序规则必须属于合同；否则后来新增一条数据就会产生无意义失败。

## fake、mock 与真实依赖

| 替身 | 适合 | 不适合 |
| --- | --- | --- |
| fake | 实现稳定接口，返回可控数据并记录必要输入 | 复制真实缓存、SQL 或重试算法 |
| mock | 需要逐次响应、参数匹配或调用脚本 | 给普通值对象和纯函数增加间接层 |
| 真实依赖 | 验证 SQL、插件、浏览器资产或集成合同 | 每条业务规则的快速反馈 |

第六部分已经用 fake Repository 替换真实数据源。这里再补一条边界：fake 应保留接口合同，但实现要短。若 fake 和生产实现使用同一套复杂算法，测试可能把同一个错误复制两遍。

## 回归测试先复现，再修复

发现缺陷后，先写最小失败用例。用例名称描述用户可见行为，例如“同年同序号按稳定 ID 排列”，不要写“修复 issue”。修复通过后，这条测试才有资格成为回归证据。

一个好的回归测试还应去掉与缺陷无关的界面、数据和时间。复现必须启动整应用时，通常说明更低层缺少可测试接缝；先判断是否能把规则移到纯 Dart，而不是立即扩大 integration 流程。

## 可验证任务

给一个“档案开放日期”规则补测试：发布日期晚于固定时钟时返回 `scheduled`，等于当前日期时返回 `open`。要求：

1. 用注入的 UTC 时钟，不调用 `DateTime.now()`；
2. 至少覆盖边界前、边界上、边界后三组输入；
3. 把排序 tie-breaker 与日期规则放在不同测试中；
4. 解释为什么这里不需要 Widget 或 Chrome。

## 复习线索

- 测试层由风险决定，没有固定比例。
- unit 固定纯规则和状态迁移；Widget、Chrome、golden、profile 各自补不同证据。
- fake 实现合同，mock 编排交互，真实依赖验证真实边界。
- 时钟、随机数、fixture、缓存和异步完成顺序都要可控。
- 回归测试先复现用户可见行为，再修改实现。

## 参考资料

- [Testing Flutter apps](https://docs.flutter.dev/testing/overview)（查阅：2026-08-31）
- [Testing each layer](https://docs.flutter.dev/app-architecture/case-study/testing)（查阅：2026-08-31）
- [Dart test package](https://pub.dev/packages/test)（查阅：2026-08-31）

