---
title: 项目：今日节奏板
description: 用一个独立 Web 项目复习 Widget 组合、基础布局、主题、局部状态和测试。
part: 1
order: 7
kind: capstone
requires:
  - toolchain.flutter
  - dart.flutter-expressions
  - ui.widget-tree
  - runtime.build-context
  - layout.box
  - theme.material3
  - state.ephemeral-basic
  - test.widget-smoke
provides:
  - project.daily-rhythm-board
project: daily-rhythm-board
status: verified
---

# 项目：今日节奏板

这章集中讲完一个项目，不把它延伸到后续章节。建议先按项目简报自己实现，再看源码如何处理组件边界、窄屏和测试。

## 项目简报

一天不需要被填满。这个工具把五个有意安排的时段放在日晷刻度上，用户选择一项后，影线转到对应时间，底部显示这段时间的说明。

必须完成的功能：

- 显示日期、标题和五个时段；
- 每个时段包含时间、名称、时长和说明；
- 选择时段后，列表、日晷语义和详情同步更新；
- 宽屏使用日晷与列表双栏，窄屏改为上下排列；
- 320×720 视口不出现 overflow；
- 鼠标、键盘和语义树都能完成或理解主要操作。

视觉不能直接套默认 Material 卡片列表。当前项目采用“日晷记录页”：沙色纸张、墨色文字、陶土色影线，操作仍使用标准按钮语义。

## 先运行验收

项目路径：`examples/capstones/daily_rhythm_board`。

```powershell
flutter analyze
flutter test examples/capstones/daily_rhythm_board/test
cd examples/capstones/daily_rhythm_board
flutter run -d chrome
```

release Web 构建使用实际预览路径：

```powershell
flutter build web --release --base-href /flutter-tutorial/previews/daily-rhythm-board/
```

开发服务器能打开不代表发布产物路径正确。base href 必须和 GitHub Pages 中的最终目录一致。

## 数据先保持普通

五个时段是不可变 `RhythmEntry` 列表。项目没有为了展示架构提前加入 Repository、JSON 或数据库；这些能力还没学，也不是这组固定演示数据所必需。

日晷位置由 `minutesFromStart / 720` 得到 0～1 的比例。这个纯函数单独测试，界面只消费结果。即使项目很小，也值得把可计算规则和 Widget 分开。

## 组件边界按页面语言划分

主要组件不是 `TopLeftCard`、`GreenPanel` 一类视觉名称，而是：

- `_DayHeader`：标题与日期；
- `_SundialPanel`：当前时段的图形和语义；
- `_RhythmList`：时段顺序与选择回调；
- `_RhythmEntryButton`：单项布局和选中状态；
- `_SelectedEntry`：当前说明。

这些名称能在项目简报中找到。布局调整时，业务结构仍然可读。

## 只保留一个局部状态

页面保存 `_selectedIndex`。按钮把 index 通过回调交回页面，页面在 `setState` 中修改，再从 `dailyRhythm[_selectedIndex]` 推导当前条目。

项目没有同时保存 `selectedEntry`、`selectedTime` 和 `selectedDescription`。这些值都能从索引推出，多存几份只会增加不同步的可能。

## 日晷不用提前引入自定义绘制

日晷由 `Stack`、半圆装饰、九条旋转刻度和一条影线组成。这里故意不用 CustomPainter：读者刚学会普通 Widget 组合，当前图形也能由可测试的布局组件表达。

第五部分会系统讨论响应式断点，第七部分才解释 paint 阶段。现在的 `LayoutBuilder` 只承担一个早期质量要求：可用宽度不足时，把双栏改成上下排列。

## 测试覆盖用户观察到的结果

项目包含三层证据：

- 单元测试确认日晷位置有序且落在 0～1；
- Widget 测试点击午后时段，检查详情与语义；窄屏测试再检查日晷、刻度、按钮和说明的布局矩形；
- Chrome 关键流程测试在完整 Web 应用中完成同一选择。

交互测试不读取私有索引，只验证用户能看到的结果。窄屏测试会检查日晷绘制区里的影针和刻度；如果图形结构重写，这一条布局测试需要跟着调整，但状态实现仍可独立替换。

## 项目完成检查

- [ ] 能解释 Widget、Element 与屏幕像素不是同一个对象。
- [ ] 能指出每个 BuildContext 在树中的位置。
- [ ] 能说明为什么选中时段属于页面内临时状态。
- [ ] 能在不改数据模型的情况下调整宽屏与窄屏组合。
- [ ] 能让失败测试先复现问题，再修改代码。
- [ ] analyze、单元测试、Widget 测试、Chrome 关键流程和 release Web build 全部通过。

## 复习线索

- [项目源码](https://github.com/mardd123588/flutter-tutorial/tree/main/examples/capstones/daily_rhythm_board)
- Web 预览将在 Pages 首次发布后开放。
- 下一部分从约束算法开始，解释本项目为什么需要 Expanded、Wrap 和 LayoutBuilder。

## 参考资料

- [Building user interfaces with Flutter](https://docs.flutter.dev/ui)（查阅：2026-08-29）
- [Understanding constraints](https://docs.flutter.dev/ui/layout/constraints)（查阅：2026-08-29）
- [Testing Flutter apps](https://docs.flutter.dev/testing/overview)（查阅：2026-08-29）
- [Build and release a web app](https://docs.flutter.dev/deployment/web)（查阅：2026-08-29）
