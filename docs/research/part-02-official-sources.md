# 第二部分官方资料研究：组件、布局与输入

> 查阅日期：2026-08-30
> 教程基线：Flutter 3.47.0、Dart 3.13.0
> 资料范围：Flutter / Dart 官方文档、API 文档、官方 cookbook，以及 Flutter 3.47.0 标签下的框架源码

这份笔记用于确定第二部分的知识边界和章节顺序，不直接充当教程正文。下文把框架行为写成“官方事实”，把课程取舍写成“编排建议”，避免把本站选择说成 Flutter 的硬性规定。

## 1. 版本基线

- Flutter 官方已发布 3.47.0，并提供对应 release notes 和 GitHub tag。当前仓库本机执行 `flutter --version` 得到 Flutter 3.47.0 stable、framework revision `4cf2416426`、Dart 3.13.0，与首版规格一致。[Flutter 3.47.0 release notes](https://docs.flutter.dev/release/release-notes/release-notes-3.47.0) · [flutter/flutter 3.47.0](https://github.com/flutter/flutter/releases/tag/3.47.0) · [Dart SDK 3.13.0](https://github.com/dart-lang/sdk/releases/tag/3.13.0)（查阅：2026-08-30）
- 本报告涉及的版本敏感结论以 `flutter/flutter` 的 `3.47.0` 标签源码为准，不用浮动的 `main` 分支替代。教程正文仍应优先链接稳定 API 页面；只有 API 页不足以说明边界时，再补固定标签的源码链接。[Flutter SDK archive](https://docs.flutter.dev/install/archive) · [flutter/flutter at 3.47.0](https://github.com/flutter/flutter/tree/3.47.0)（查阅：2026-08-30）

## 2. Box 约束与布局诊断

### 2.1 最小心智模型

- Flutter 的 box 布局是一次向下传约束、一次向上传具体几何信息的单遍过程。`BoxConstraints` 由 `minWidth`、`maxWidth`、`minHeight`、`maxHeight` 四个值组成；每个 `RenderBox` 接收父级约束，布局子级，再选择一个满足自身约束的 `Size`。子级位置由父级另行决定，子级本身不知道自己的位置。[Understanding constraints](https://docs.flutter.dev/ui/layout/constraints) · [BoxConstraints 3.47.0 源码](https://github.com/flutter/flutter/blob/3.47.0/packages/flutter/lib/src/rendering/box.dart#L53-L72)（查阅：2026-08-30）
- “父级传约束，子级选尺寸，父级定位置”适合解释 `RenderBox`，不能直接套到 sliver。sliver 使用 `SliverConstraints` 与 `SliverGeometry`，是为单轴滚动优化的另一套协议。[CustomScrollView API](https://api.flutter.dev/flutter/widgets/CustomScrollView-class.html) · [CustomScrollView 3.47.0 源码](https://github.com/flutter/flutter/blob/3.47.0/packages/flutter/lib/src/widgets/scroll_view.dart#L749-L769)（查阅：2026-08-30）
- 约束按轴判断。某一轴 `max` 有限，称为 bounded；`max` 为无穷，称为 unbounded。loose 只表示该轴 `min == 0`，不等于 unbounded；同一轴甚至可以同时 tight 和 loose，例如最小值与最大值都为 0。[BoxConstraints API](https://api.flutter.dev/flutter/rendering/BoxConstraints-class.html) · [BoxConstraints 3.47.0 源码](https://github.com/flutter/flutter/blob/3.47.0/packages/flutter/lib/src/rendering/box.dart#L74-L99)（查阅：2026-08-30）
- 子级写了 `width` 或 `height`，不代表最终尺寸必然等于该值。父级的 tight 约束可以覆盖子级偏好；loose 约束允许子级更小，但仍受最大值限制。教程应让读者先查看实际约束，再解释“为什么设置尺寸没有生效”。[Understanding constraints](https://docs.flutter.dev/ui/layout/constraints)（查阅：2026-08-30）

### 2.2 Overflow 与 unbounded 不是同一种错误

| 现象 | 真正含义 | 诊断顺序 |
| --- | --- | --- |
| `A RenderFlex overflowed by ... pixels` | Flex 已拿到有限可用空间，但子级总需求超过这段空间。 | 找到发生溢出的轴，检查非 flex 子级、长文本和固定尺寸，再决定换行、压缩、滚动或重组布局。 |
| `RenderFlex children have non-zero flex but incoming ... constraints are unbounded` | Flex 主轴没有有限上限，却要求非零 flex 子级分配“剩余空间”；`Expanded` 的填满要求与父级 shrink-wrap 意图冲突。 | 先找是谁传入无界主轴，常见来源是同轴滚动区域；再决定给 Flex 有限尺寸、去掉 flex，或改成真正需要的滚动结构。 |
| `Vertical viewport was given unbounded height` | viewport 想在滚动轴扩到可用最大尺寸，但父级没有给有限上限。 | 在 `Column` 中通常用 `Expanded` / 明确高度约束 viewport，或把页面改成一个统一的 scroll view。 |

Flex 的断言说明把 shrink-wrap 与 `Expanded` 同时使用是互斥指令，并给出 `mainAxisSize: MainAxisSize.min` 与 loose `Flexible` 的可能修复。但这不是通用替换法；`SingleChildScrollView` 文档明确指出，在滚动轴可用空间为无穷时，普通 `Expanded` / `Flexible` 通常没有可分配的有限“剩余空间”。[RenderFlex 3.47.0 源码](https://github.com/flutter/flutter/blob/3.47.0/packages/flutter/lib/src/rendering/flex.dart#L1102-L1174) · [SingleChildScrollView API](https://api.flutter.dev/flutter/widgets/SingleChildScrollView-class.html)（查阅：2026-08-30）

### 2.3 适合正文的约束探针

02-01 可以用三个小实验完成验证，代码只需 `LayoutBuilder`、`ConstrainedBox`、`Row` / `Column`、`Text` 和滚动组件：

1. tight 父约束覆盖子级指定尺寸，证明“尺寸是协商结果”；
2. `Row` 中长文本先发生有限空间 overflow，再用 `Expanded` 给文本有限宽度；
3. `SingleChildScrollView > Column > Expanded` 复现 unbounded flex 错误，分别用“去掉无意义 flex”和“把列表改为唯一滚动主体”修复。

这三个实验覆盖尺寸协商、有限空间不足和无界主轴三类问题，不需要提前讲 `RenderObject` 实现细节。[Understanding constraints](https://docs.flutter.dev/ui/layout/constraints) · [Row API](https://api.flutter.dev/flutter/widgets/Row-class.html) · [SingleChildScrollView API](https://api.flutter.dev/flutter/widgets/SingleChildScrollView-class.html)（查阅：2026-08-30）

## 3. Flex、Expanded、Wrap 与 Stack

### 3.1 Flex / Expanded

- `Row`、`Column` 和 `Flex` 的核心是六步布局：先用无界主轴约束布局零 flex 子级，再按 flex factor 分配剩余主轴空间，再用 tight 或 loose 约束布局非零 flex 子级，最后确定自身尺寸与子级位置。`CrossAxisAlignment.stretch` 会在交叉轴给子级 tight 约束。[Flex API](https://api.flutter.dev/flutter/widgets/Flex-class.html) · [RenderFlex 3.47.0 源码](https://github.com/flutter/flutter/blob/3.47.0/packages/flutter/lib/src/rendering/flex.dart#L365-L406)（查阅：2026-08-30）
- `Expanded` 等价于 `Flexible(fit: FlexFit.tight)`：子级必须填满获配空间。`Flexible` 默认 `FlexFit.loose`：子级最多使用获配空间，可以更小。二者的 flex factor 都是在放置零 flex 子级之后，对剩余空间按比例分配，不是按子级原始尺寸做比例缩放。[Expanded API](https://api.flutter.dev/flutter/widgets/Expanded-class.html) · [Flexible API](https://api.flutter.dev/flutter/widgets/Flexible-class.html) · [basic.dart 3.47.0](https://github.com/flutter/flutter/blob/3.47.0/packages/flutter/lib/src/widgets/basic.dart#L5910-L6025)（查阅：2026-08-30）
- `Expanded` / `Flexible` 是 `ParentDataWidget`，必须位于 `Row`、`Column` 或 `Flex` 的后代路径上，而且中间只能经过 `StatelessWidget` / `StatefulWidget`，不能隔着别的 `RenderObjectWidget`。正文不能把它讲成“任何地方都能占满剩余空间”的通用包装器。[Expanded API](https://api.flutter.dev/flutter/widgets/Expanded-class.html) · [Flexible API](https://api.flutter.dev/flutter/widgets/Flexible-class.html)（查阅：2026-08-30）

容易误讲的边界：

- `mainAxisAlignment` 只分配 Flex 布局后仍未使用的空间；如果 `Expanded` 已吃完剩余空间，`spaceBetween` 等值看起来可能没有效果。[RenderFlex 3.47.0 源码](https://github.com/flutter/flutter/blob/3.47.0/packages/flutter/lib/src/rendering/flex.dart#L395-L406)（查阅：2026-08-30）
- `Expanded` 能解决 `Row` 中长文本没有有限宽度的问题，但不能把任何 overflow 自动变成正确布局。内容本来就不应被压缩时，应改为 `Wrap`、滚动或重新排列。[Understanding constraints](https://docs.flutter.dev/ui/layout/constraints)（查阅：2026-08-30）
- 把 `Expanded` 机械换成 `Flexible` 可能只让断言消失，没有建立合理尺寸。修复必须回答“这一轴的有限空间从哪里来”。[RenderFlex 3.47.0 源码](https://github.com/flutter/flutter/blob/3.47.0/packages/flutter/lib/src/rendering/flex.dart#L1102-L1174)（查阅：2026-08-30）

### 3.2 Wrap

- `Wrap` 会逐个布局子级，在主轴放不下时创建新 run；`spacing` 管 run 内间距，`runSpacing` 管 run 之间的间距，`alignment` 与 `runAlignment` 分别控制两个层级的排列。[Wrap API](https://api.flutter.dev/flutter/widgets/Wrap-class.html) · [basic.dart 3.47.0](https://github.com/flutter/flutter/blob/3.47.0/packages/flutter/lib/src/widgets/basic.dart#L6028-L6111)（查阅：2026-08-30）
- `Wrap` 不是滚动组件，也不是 lazy list。它会布局参与排版的所有子级，适合标签、短操作组和数量受控的票券元素；大量数据仍应使用 builder 列表或网格。[Wrap API](https://api.flutter.dev/flutter/widgets/Wrap-class.html) · [Scrolling](https://docs.flutter.dev/ui/layout/scrolling)（查阅：2026-08-30）
- 换行点由真实约束与子级尺寸共同决定，不应按字符数或屏幕型号手算。若业务要求固定列数或可预测网格，应使用 `GridView` / grid delegate，而不是让 `Wrap` 承担网格语义。[Wrap API](https://api.flutter.dev/flutter/widgets/Wrap-class.html) · [GridView API](https://api.flutter.dev/flutter/widgets/GridView-class.html)（查阅：2026-08-30）

### 3.3 Stack

- `Stack` 用于重叠。非 positioned 子级先布局，并决定 Stack 的包围尺寸；如果没有非 positioned 子级，Stack 会尽量变大。positioned 子级随后布局，因此它们本身不负责撑开 Stack。[Stack API](https://api.flutter.dev/flutter/widgets/Stack-class.html) · [RenderStack 3.47.0 源码](https://github.com/flutter/flutter/blob/3.47.0/packages/flutter/lib/src/rendering/stack.dart#L333-L360)（查阅：2026-08-30）
- positioned 子级同时给出 `left` / `right` 时会得到确定宽度，同时给出 `top` / `bottom` 时会得到确定高度；某一维未固定时，该维可能收到无界约束。教程要让读者知道 `Positioned.fill`、双边 inset 与只设单边的约束差异。[Positioned API](https://api.flutter.dev/flutter/widgets/Positioned-class.html) · [RenderStack 3.47.0 源码](https://github.com/flutter/flutter/blob/3.47.0/packages/flutter/lib/src/rendering/stack.dart#L353-L366)（查阅：2026-08-30）
- `clipBehavior` 只按 Stack 直接子级的几何溢出裁剪；阴影、Transform 或后代绘制越界不一定被它裁掉。即使 `Clip.none`，Stack 的 hit-test 区域也不会扩到自身边界之外，画在外面的子级区域可能看得见却点不到。[Stack API](https://api.flutter.dev/flutter/widgets/Stack-class.html) · [basic.dart 3.47.0](https://github.com/flutter/flutter/blob/3.47.0/packages/flutter/lib/src/widgets/basic.dart#L4792-L4807)（查阅：2026-08-30）

票券排版器应把 `Stack` 限制在票根、印章、角标等确实重叠的局部。正文不应把整页都改成绝对定位；那会绕开正常约束流，也不利于长文本和窄屏。[Stack API](https://api.flutter.dev/flutter/widgets/Stack-class.html) · [Layouts in Flutter](https://docs.flutter.dev/ui/layout)（查阅：2026-08-30）

## 4. 滚动、lazy list、网格与 Sliver 初识

### 4.1 先区分内容规模

- `SingleChildScrollView` 适合一个通常能完整显示、只在窗口变小时需要滚动的 box，也适合需要双轴 shrink-wrap 的少量内容。若有很多同类子级，`ListView` 比 `SingleChildScrollView > Column` 高效得多。[SingleChildScrollView API](https://api.flutter.dev/flutter/widgets/SingleChildScrollView-class.html) · [single_child_scroll_view.dart 3.47.0](https://github.com/flutter/flutter/blob/3.47.0/packages/flutter/lib/src/widgets/single_child_scroll_view.dart#L28-L68)（查阅：2026-08-30）
- `ListView(children: ...)` 会先构造整个列表，适合少量子级；`ListView.builder` 按需调用 builder，适合大列表或无穷列表。`GridView.builder` 对网格提供同类按需构建入口。[ListView API](https://api.flutter.dev/flutter/widgets/ListView-class.html) · [ListView.builder API](https://api.flutter.dev/flutter/widgets/ListView/ListView.builder.html) · [GridView.builder API](https://api.flutter.dev/flutter/widgets/GridView/GridView.builder.html)（查阅：2026-08-30）
- “lazy”不等于“屏幕外绝不创建任何内容”。viewport 会为平滑滚动维护缓存范围；教程只需承诺不会像显式 `children` 那样一次创建所有项，不应把具体创建数量写成跨设备不变的常数。[ListView.builder API](https://api.flutter.dev/flutter/widgets/ListView/ListView.builder.html) · [ScrollView API](https://api.flutter.dev/flutter/widgets/ScrollView-class.html)（查阅：2026-08-30）
- 给 builder 提供非空 `itemCount` 能改善最大滚动范围估算。虽然 `itemBuilder` 可以提前返回 `null`，但这会让 `maxScrollExtent` 在到达末尾前不准确，并可能让 Scrollbar 在滚动过程中改变长度；有限数据应显式给 `itemCount`，不要靠返回 `null` 截断。[ListView.builder API](https://api.flutter.dev/flutter/widgets/ListView/ListView.builder.html) · [scroll_view.dart 3.47.0](https://github.com/flutter/flutter/blob/3.47.0/packages/flutter/lib/src/widgets/scroll_view.dart#L1358-L1385)（查阅：2026-08-30）
- `itemExtent`、`prototypeItem` 或 3.47.0 中的 `itemExtentBuilder` 能让滚动系统提前掌握主轴 extent，适合尺寸确实固定或可预测的列表；三者不能同时使用。不要为了性能给本来会随文本缩放变化的卡片写死高度。[ListView API](https://api.flutter.dev/flutter/widgets/ListView-class.html) · [scroll_view.dart 3.47.0](https://github.com/flutter/flutter/blob/3.47.0/packages/flutter/lib/src/widgets/scroll_view.dart#L950-L966)（查阅：2026-08-30）

空数据是数据状态，不是 builder 的特殊分支。`itemCount == 0` 时 builder 不会执行；页面应在列表外明确显示空状态，并给出恢复动作。这是本站界面约定，依据是 builder 只会收到 `0 <= index < itemCount` 的索引。[ListView.builder API](https://api.flutter.dev/flutter/widgets/ListView/ListView.builder.html)（查阅：2026-08-30）

### 4.2 shrinkWrap 与嵌套滚动

- 默认 scroll view 会在滚动轴扩到允许的最大尺寸；如果滚动轴约束无界，`shrinkWrap` 必须为 true。但 shrink-wrap 需要在滚动位置变化时重新计算 scroll view 尺寸，成本明显高于扩到有限 viewport。[ScrollView.shrinkWrap API](https://api.flutter.dev/flutter/widgets/ScrollView/shrinkWrap.html) · [scroll_view.dart 3.47.0](https://github.com/flutter/flutter/blob/3.47.0/packages/flutter/lib/src/widgets/scroll_view.dart#L276-L294)（查阅：2026-08-30）
- 因此，`shrinkWrap: true` 不能作为“列表放进 Column 报错”的默认答案。列表本来是页面主体时，应给它有限 viewport，例如放进 `Expanded`；页头、列表和网格需要同轴一起滚动时，通常应改成一个 `CustomScrollView`。[Scrolling](https://docs.flutter.dev/ui/layout/scrolling) · [CustomScrollView API](https://api.flutter.dev/flutter/widgets/CustomScrollView-class.html)（查阅：2026-08-30）
- 两个同轴 scrollable 嵌套会带来手势、滚动范围和语义上的额外问题。第二部分只讲“一个任务优先一个滚动主体”的默认设计；确有协调头部、Tab 或独立滚动区域时，再使用 `NestedScrollView` 等专用方案，不在基础章节展开。[Scrolling](https://docs.flutter.dev/ui/layout/scrolling) · [NestedScrollView API](https://api.flutter.dev/flutter/widgets/NestedScrollView-class.html)（查阅：2026-08-30）

### 4.3 Sliver 在第二部分讲到哪里

- 官方把 sliver 定义为 scrollable area 的一部分，可以在 `CustomScrollView` 中组合，以获得更细的滚动区域控制。常用入口是 `SliverList`、`SliverGrid`、`SliverAppBar` 和 `SliverToBoxAdapter`。[Using slivers](https://docs.flutter.dev/ui/layout/scrolling/slivers) · [CustomScrollView API](https://api.flutter.dev/flutter/widgets/CustomScrollView-class.html) · [SliverToBoxAdapter API](https://api.flutter.dev/flutter/widgets/SliverToBoxAdapter-class.html)（查阅：2026-08-30）
- `CustomScrollView.slivers` 接受 sliver widget，普通 box 不能直接混入；单个普通 box 通过 `SliverToBoxAdapter` 连接。大量普通子级不要逐个套 adapter，应使用 `SliverList` 或 `SliverGrid`。[SliverToBoxAdapter API](https://api.flutter.dev/flutter/widgets/SliverToBoxAdapter-class.html) · [CustomScrollView API](https://api.flutter.dev/flutter/widgets/CustomScrollView-class.html)（查阅：2026-08-30）
- `SliverList` 只物化可见区域附近的子级，无法预先知道未物化子级的主轴尺寸，因此用“dead reckoning”估算滚动位置。一个 viewport 使用多个 delegate 时，每个 delegate 的第一个子级都必须布局，供整体滚动范围估算。固定 extent 时，`SliverFixedExtentList` 能省去逐项测量。[SliverList API](https://api.flutter.dev/flutter/widgets/SliverList-class.html) · [sliver.dart 3.47.0](https://github.com/flutter/flutter/blob/3.47.0/packages/flutter/lib/src/widgets/sliver.dart#L66-L72) · [sliver.dart 3.47.0](https://github.com/flutter/flutter/blob/3.47.0/packages/flutter/lib/src/widgets/sliver.dart#L122-L140)（查阅：2026-08-30）

第二部分只需要让读者完成“普通页头 + lazy 列表 / 网格共用一个滚动主体”，并认识 box 与 sliver 的桥接。`RenderSliver` 协议、dead reckoning 的性能后果、复杂吸顶重叠、cache extent 调优和 profile trace 留到第七部分。这样能解决嵌套滚动问题，又不会提前展开渲染性能专题。[Using slivers](https://docs.flutter.dev/ui/layout/scrolling/slivers) · [CustomScrollView API](https://api.flutter.dev/flutter/widgets/CustomScrollView-class.html)（查阅：2026-08-30）

## 5. 可复用组件与 composition

### 5.1 官方事实

- Flutter 的 widgets layer 是组合抽象。Widget 是界面某一部分的不可变声明，Widget tree 由小型、单一用途的 widget 嵌套组成；Material 和 Cupertino 组件本身也建立在这套组合原语上。[Flutter architectural overview](https://docs.flutter.dev/resources/architectural-overview#architectural-layers) · [Flutter architectural overview: Widgets](https://docs.flutter.dev/resources/architectural-overview#widgets)（查阅：2026-08-30）
- `StatelessWidget.build` 应只依赖 widget 的不可变字段与从 `BuildContext` 取得的环境数据。官方 API 建议：可复用 UI 优先抽成 Widget，而不是返回 Widget 的 helper method；独立 Widget 能形成更新边界，也能使用 `const`。[StatelessWidget API](https://api.flutter.dev/flutter/widgets/StatelessWidget-class.html) · [framework.dart 3.47.0](https://github.com/flutter/flutter/blob/3.47.0/packages/flutter/lib/src/widgets/framework.dart#L399-L462)（查阅：2026-08-30）
- Flutter 官方交互教程展示了受控组件模式：父级持有共享状态，通过构造参数把值传给子级；子级通过 `ValueChanged<T>` 回调通知父级。局部高亮等纯内部瞬时状态可以由组件自己管理。[Add interactivity: Managing state](https://docs.flutter.dev/ui/interactivity#managing-state)（查阅：2026-08-30）
- widget 构造器惯例是命名参数，`key` 在前，`child` / `children` 或同类 slot 参数在后。`Theme.of(context)` 读取应用主题；自定义、需要插值的主题令牌可以使用 `ThemeExtension`。[StatelessWidget API](https://api.flutter.dev/flutter/widgets/StatelessWidget-class.html) · [Use themes](https://docs.flutter.dev/cookbook/design/themes) · [ThemeExtension API](https://api.flutter.dev/flutter/material/ThemeExtension-class.html)（查阅：2026-08-30）

### 5.2 本教程采用的组件接口边界

以下是依据上述机制做出的课程规则：

- 数据参数表达“显示什么”，回调表达“发生了什么”。优先使用 `String title`、`Exhibit exhibit`、`VoidCallback onDelete`、`ValueChanged<String> onQueryChanged` 这类语义接口，不把 `BuildContext`、内部 `Row`、`TextEditingController` 或某个私有按钮状态暴露给调用方。
- 需要调用方提供一段界面时，用 `Widget child`、`Widget? leading`、`List<Widget> actions` 或 builder 形成 slot。slot 负责内容注入，组件仍保有排版、语义和主题边界。
- 默认值只用于确实存在自然默认的参数；会改变业务含义的回调或数据用 `required`。回调为 null 是否代表 disabled，要沿用 Flutter 控件习惯并写进组件合同。
- 颜色、文字样式、圆角和间距优先来自 `ThemeData`、`ColorScheme`、`TextTheme` 或项目自己的 `ThemeExtension`，不为每个视觉细节增加构造参数。局部一次性差异再显式开放参数。
- 组件若自行创建 controller / focus node，就负责释放；若从构造器接收外部对象，生命周期由调用方负责。不得在组件内部悄悄 dispose 外部对象。这个所有权规则与 Flutter 对 `TextEditingController`、`FocusNode` 的生命周期要求一致。[TextEditingController API](https://api.flutter.dev/flutter/widgets/TextEditingController-class.html) · [FocusNode API](https://api.flutter.dev/flutter/widgets/FocusNode-class.html)（查阅：2026-08-30）

02-04 的重构任务应比较三种接口：复制粘贴卡片、泄漏内部布局的“万能卡片”、按业务语义收口的组件。正文重点放在调用处能否一眼看懂、组件能否单独测试、内部布局能否替换，不提前引入 repository 或全局状态管理。

## 6. 文本输入、Form 与 TextEditingController

### 6.1 Form 验证

- `TextFormField` 是把 `TextField` 包进 `FormField<String>` 的便利组件。单个 `TextFormField` 不强制要求 `Form` 祖先；`Form` 的价值是统一 save、reset 和 validate 多个字段。[TextFormField API](https://api.flutter.dev/flutter/material/TextFormField-class.html) · [text_form_field.dart 3.47.0](https://github.com/flutter/flutter/blob/3.47.0/packages/flutter/lib/src/material/text_form_field.dart#L19-L42)（查阅：2026-08-30）
- `validator` 是同步函数：无错误返回 `null`，有错误返回用于显示的字符串。`FormState.validate()` 会触发所有后代 `FormField` 的 validator、更新错误显示，并在全部无错时返回 `true`。[Build a form with validation](https://docs.flutter.dev/cookbook/forms/validation) · [FormState.validate API](https://api.flutter.dev/flutter/widgets/FormState/validate.html)（查阅：2026-08-30）
- cookbook 使用 `GlobalKey<FormState>` 访问表单，并明确要求只创建一次，不要在 `build` 中反复创建昂贵的 `GlobalKey`。复杂树也可以从后代 context 使用 `Form.of()`；教程可选择 key 方案，但不应说 `GlobalKey` 是 Form 唯一入口。[Build a form with validation](https://docs.flutter.dev/cookbook/forms/validation) · [Form.of API](https://api.flutter.dev/flutter/widgets/Form/of.html)（查阅：2026-08-30）
- 同步 validator 不应发网络请求，也不应返回 `Future`。异步唯一性检查属于独立提交 / 字段状态：先做本地同步校验，再运行异步动作，并通过页面状态或 `forceErrorText` 呈现服务端错误。按钮 loading、重复提交保护和失败重试也不属于 `FormState.validate()` 的职责。[FormFieldValidator API](https://api.flutter.dev/flutter/widgets/FormFieldValidator.html) · [FormField.forceErrorText API](https://api.flutter.dev/flutter/widgets/FormField/forceErrorText.html)（查阅：2026-08-30）

### 6.2 controller 的用途和生命周期

- 只需要响应文本变化时，`onChanged` 最直接；需要主动读写文本、控制 selection 或监听完整 `TextEditingValue` 时再使用 `TextEditingController`。[Handle changes to a text field](https://docs.flutter.dev/cookbook/forms/text-field-changes) · [TextEditingController API](https://api.flutter.dev/flutter/widgets/TextEditingController-class.html)（查阅：2026-08-30）
- controller 已有文本时，该文本就是字段初值。`TextFormField` 同时传 `controller` 与非空 `initialValue` 不成立；无 controller 时，组件才会创建内部 controller 并用 `initialValue` 初始化。[TextFormField API](https://api.flutter.dev/flutter/material/TextFormField-class.html) · [text_form_field.dart 3.47.0](https://github.com/flutter/flutter/blob/3.47.0/packages/flutter/lib/src/material/text_form_field.dart#L98-L104)（查阅：2026-08-30）
- 自己创建的 `TextEditingController` 是跨 build 存活的对象，应保存在 `State` 字段中，并在不再使用时调用 `dispose()`。不需要为简单初值专门写 `initState`：`final _titleController = TextEditingController();` 加 `dispose` 已足够；需要根据构造参数初始化时，再在 `initState` 建立它。生命周期原理在第三部分展开。[Handle changes to a text field](https://docs.flutter.dev/cookbook/forms/text-field-changes) · [TextEditingController API](https://api.flutter.dev/flutter/widgets/TextEditingController-class.html)（查阅：2026-08-30）
- lazy scrolling container 中的 `TextFormField` 应显式传 controller，并由滚动容器之上的 `StatefulWidget` 管理生命周期。否则列表项移出物化范围后，内部编辑状态可能随 element 销毁；不要把 controller 临时创建在 `itemBuilder` 或 `build` 里。[TextFormField API](https://api.flutter.dev/flutter/material/TextFormField-class.html) · [text_form_field.dart 3.47.0](https://github.com/flutter/flutter/blob/3.47.0/packages/flutter/lib/src/material/text_form_field.dart#L28-L42)（查阅：2026-08-30）
- controller listener 内再次修改 `text` / `selection` 可能形成通知循环；改 composing region 还可能与 Gboard 等输入法来回恢复。输入时格式化优先使用 `TextInputFormatter`。同时改文本和 selection 时应整体设置 `value`，因为单独设置 `text` 会清空 selection 与 composing range。[TextEditingController API](https://api.flutter.dev/flutter/widgets/TextEditingController-class.html) · [editable_text.dart 3.47.0](https://github.com/flutter/flutter/blob/3.47.0/packages/flutter/lib/src/widgets/editable_text.dart#L174-L204)（查阅：2026-08-30）

02-05 的项目只做本地同步规则与一次提交状态，不引入防抖、网络验证或请求竞态；这些内容属于第四部分。

## 7. Focus、Shortcuts、Actions、键盘与鼠标

### 7.1 Focus 是键盘输入的路由基础

- `FocusNode` 是持久对象，构成稀疏 focus tree。它不应在每次 `build` 中创建，否则会丢失焦点并可能泄漏；拥有它的 `State` 负责 dispose。若不需要从外部命令式调用 `requestFocus()`，让 `Focus` widget 自己管理 node 更省事。[Understanding Flutter's keyboard focus system](https://docs.flutter.dev/ui/interactivity/focus) · [FocusNode 3.47.0 源码](https://github.com/flutter/flutter/blob/3.47.0/packages/flutter/lib/src/widgets/focus_manager.dart#L361-L396)（查阅：2026-08-30）
- key event 从 primary focus 开始向 focus tree 的祖先传播。handler 返回 `ignored` 才继续向上；返回 `handled` 后停止。焦点遍历由 `FocusTraversalPolicy` 决定，默认不是简单的“代码出现顺序永远等于 Tab 顺序”。[FocusNode API](https://api.flutter.dev/flutter/widgets/FocusNode-class.html) · [focus_manager.dart 3.47.0](https://github.com/flutter/flutter/blob/3.47.0/packages/flutter/lib/src/widgets/focus_manager.dart#L399-L436)（查阅：2026-08-30）
- `canRequestFocus: false` 与 `skipTraversal: true` 不等价：前者禁止请求 primary focus，并隐含跳过遍历；后者只是不经遍历到达，仍可被显式聚焦。教程不能把两者都解释成“禁用控件”。[FocusNode API](https://api.flutter.dev/flutter/widgets/FocusNode-class.html)（查阅：2026-08-30）
- `unfocus()` 不会让应用进入“完全没有焦点”的稳定状态，它会把焦点交给 scope 或此前聚焦的子级。明确知道下一个目标时，直接对目标调用 `requestFocus()` 更可预测。[Understanding Flutter's keyboard focus system](https://docs.flutter.dev/ui/interactivity/focus#unfocusing)（查阅：2026-08-30）

### 7.2 Shortcuts 与 Actions 的分工

- `Shortcuts` 把 `ShortcutActivator` 映射为 `Intent`；`Actions` 再把 Intent 类型映射为具体 `Action`。这层分离让同一快捷键在当前焦点上下文中调用不同实现，也允许 action 根据 `isEnabled` 决定能否执行。[Using Actions and Shortcuts](https://docs.flutter.dev/ui/interactivity/actions-and-shortcuts) · [Shortcuts API](https://api.flutter.dev/flutter/widgets/Shortcuts-class.html) · [Actions API](https://api.flutter.dev/flutter/widgets/Actions-class.html)（查阅：2026-08-30）
- 简单、纯局部的按键回调可以使用 `CallbackShortcuts`；需要按钮与快捷键共享同一命令、支持 enabled 状态或让实现随焦点上下文变化时，使用 `Intent` / `Action`。不要在按钮 `onPressed` 和按键 handler 中复制两份保存或删除逻辑。[Using Actions and Shortcuts](https://docs.flutter.dev/ui/interactivity/actions-and-shortcuts#why-not-use-callbacks) · [Shortcuts 3.47.0 源码](https://github.com/flutter/flutter/blob/3.47.0/packages/flutter/lib/src/widgets/shortcuts.dart#L948-L1003)（查阅：2026-08-30）
- `FocusableActionDetector` 组合了 `Actions`、`Shortcuts`、`MouseRegion` 与 `Focus`，适合编写需要 hover、高亮、焦点遍历和键盘激活的自定义控件。它没有视觉外观，也不能替代控件自身的语义角色；能用 `Button`、`IconButton` 等现成控件时，优先使用现成控件。[FocusableActionDetector API](https://api.flutter.dev/flutter/widgets/FocusableActionDetector-class.html) · [actions.dart 3.47.0](https://github.com/flutter/flutter/blob/3.47.0/packages/flutter/lib/src/widgets/actions.dart#L1140-L1171)（查阅：2026-08-30）

### 7.3 键盘事件边界

- Flutter 3.47.0 应使用 `KeyEvent` / `HardwareKeyboard`。旧的 `RawKeyEvent`、`RawKeyboard` 与 `RawKeyboardListener` 已弃用，正文和项目不要再引入旧 API。[Key event migration](https://docs.flutter.dev/release/breaking-changes/key-event-migration) · [RawKeyboardListener 3.47.0 源码](https://github.com/flutter/flutter/blob/3.47.0/packages/flutter/lib/src/widgets/raw_keyboard_listener.dart#L17-L49)（查阅：2026-08-30）
- `KeyboardListener` 适合游戏或非文本硬件按键；文本输入应使用 `EditableText` / `TextField`，因为它们处理软键盘与 IME。3.47.0 的 `KeyboardListener.onKeyEvent` 是 `ValueChanged<KeyEvent>`，其内部 Focus handler 始终返回 `KeyEventResult.ignored`；需要消费事件时使用 `Focus.onKeyEvent` 或 `Shortcuts`。[KeyboardListener API](https://api.flutter.dev/flutter/widgets/KeyboardListener-class.html) · [keyboard_listener.dart 3.47.0](https://github.com/flutter/flutter/blob/3.47.0/packages/flutter/lib/src/widgets/keyboard_listener.dart#L17-L76)（查阅：2026-08-30）
- 一个标准 key tap 是 `KeyDownEvent`、零到多个 `KeyRepeatEvent`、`KeyUpEvent`。`physicalKey` 表示键盘物理位置，`logicalKey` 表示当前布局下的逻辑含义；普通命令快捷键通常匹配 logical key，依赖位置的游戏控制才更常看 physical key。[HardwareKeyboard API](https://api.flutter.dev/flutter/services/HardwareKeyboard-class.html) · [hardware_keyboard.dart 3.47.0](https://github.com/flutter/flutter/blob/3.47.0/packages/flutter/lib/src/services/hardware_keyboard.dart#L350-L367)（查阅：2026-08-30）
- Flutter 会在窗口失焦、初始锁定键状态等情况下合成事件以同步键盘状态；事件流不保证与原生事件一一对应，合成事件通过 `KeyEvent.synthesized` 标记。测试应验证用户命令结果，不要把某个平台的底层原生事件数量写死。[HardwareKeyboard API](https://api.flutter.dev/flutter/services/HardwareKeyboard-class.html) · [hardware_keyboard.dart 3.47.0](https://github.com/flutter/flutter/blob/3.47.0/packages/flutter/lib/src/services/hardware_keyboard.dart#L372-L404)（查阅：2026-08-30）

### 7.4 鼠标、pointer 与 gesture

- Flutter 输入分两层：pointer event 是触摸、鼠标、触控笔的原始位置与移动；gesture 是由一个或多个 pointer event 识别出的 tap、drag、scale 等语义动作。普通界面优先使用手势或现成控件，需要原始数据时才用 `Listener`。[Taps, drags, and other gestures](https://docs.flutter.dev/ui/interactivity/gestures) · [Listener API](https://api.flutter.dev/flutter/widgets/Listener-class.html)（查阅：2026-08-30）
- `MouseRegion` 负责 enter、exit、hover 与 mouse cursor，不代表“可点击”。hover 只能作为增强，核心操作仍需触摸和键盘路径。[MouseRegion API](https://api.flutter.dev/flutter/widgets/MouseRegion-class.html) · [basic.dart 3.47.0](https://github.com/flutter/flutter/blob/3.47.0/packages/flutter/lib/src/widgets/basic.dart#L7258-L7288)（查阅：2026-08-30）
- `Listener` 接收原始 down / move / up / hover / pan-zoom / signal。`GestureDetector` 识别高层手势，并会把多数手势回调映射到无障碍事件；Material 点击反馈通常优先用 `InkWell` 或现成按钮。[Listener API](https://api.flutter.dev/flutter/widgets/Listener-class.html) · [GestureDetector API](https://api.flutter.dev/flutter/widgets/GestureDetector-class.html)（查阅：2026-08-30）
- 父子 `GestureDetector` 同时识别相同手势时会进入 gesture arena，通常只有胜者收到最终 tap。把 `behavior` 改成 opaque 或 translucent 不会改变父子 recognizer 的竞争关系；它只改变 hit test 行为。正文应复现一次竞争，并用 `debugPrintGestureArenaDiagnostics` 观察，不展开自定义 recognizer。[GestureDetector API](https://api.flutter.dev/flutter/widgets/GestureDetector-class.html) · [gesture_detector.dart 3.47.0](https://github.com/flutter/flutter/blob/3.47.0/packages/flutter/lib/src/widgets/gesture_detector.dart#L162-L215)（查阅：2026-08-30）

## 8. 建议的七章顺序与深度

| 章节 | 主问题 | 讲透的内容 | 本章暂不展开 |
| --- | --- | --- | --- |
| 02-01 约束如何决定尺寸 | 为什么指定尺寸没生效，为什么会 overflow / unbounded | box 四值约束、按轴判断、尺寸协商、父级定位、三类错误探针 | RenderObject 自定义布局、intrinsics 性能细节 |
| 02-02 Flex、Wrap、Stack 的选择 | 一维分配、自动换行和重叠分别用什么 | Flex 六步算法、Expanded / Flexible、Wrap run、Stack 尺寸与 hit test 边界 | 文本表单、复杂响应式断点、动画 |
| 02-03 滚动、列表与网格 | 内容多了以后如何只建需要的项 | viewport、builder、itemCount、空状态、shrinkWrap 代价、一个滚动主体 | Sliver 性能调优、自定义 RenderSliver、复杂 NestedScrollView |
| 02-04 可复用组件的接口 | 什么应该成为参数，谁持有状态和资源 | 不可变配置、数据与回调、Widget slot、主题令牌、组件测试边界 | repository、依赖注入、全局状态管理 |
| 02-05 文本输入、表单与验证 | 如何保存输入、显示错误并提交 | onChanged / controller 取舍、Form 同步验证、controller 所有权与 dispose、提交状态 | 异步远程验证、防抖、竞态 |
| 02-06 手势、焦点、键盘与语义 | 如何让同一操作支持触摸、鼠标和键盘 | pointer / gesture 边界、focus tree、Shortcuts → Intent → Action、FocusableActionDetector、最小语义 | 自定义 recognizer、完整 WCAG、复杂焦点策略 |
| 02-07 统筹项目 | 能否把布局、组件、表单与输入组合起来 | 小型展览编辑器完整任务与 Web 验收 | 新框架概念 |

这组顺序有三条依赖：

1. 先理解有限与无界约束，再讲 Flex 和 viewport，否则读者只能背 `Expanded` / `shrinkWrap` 修复配方。[Understanding constraints](https://docs.flutter.dev/ui/layout/constraints) · [ScrollView.shrinkWrap API](https://api.flutter.dev/flutter/widgets/ScrollView/shrinkWrap.html)（查阅：2026-08-30）
2. 先讲组件接口，再讲表单，表单字段才能以值、回调和 controller 所有权来解释，而不是把所有状态塞进页面。[Add interactivity](https://docs.flutter.dev/ui/interactivity#managing-state) · [TextEditingController API](https://api.flutter.dev/flutter/widgets/TextEditingController-class.html)（查阅：2026-08-30）
3. 先有实际表单控件，再讲 focus、keyboard 和 actions，读者能观察焦点从字段移到按钮、快捷键如何调用同一个保存 Intent。[Understanding focus](https://docs.flutter.dev/ui/interactivity/focus) · [Using Actions and Shortcuts](https://docs.flutter.dev/ui/interactivity/actions-and-shortcuts)（查阅：2026-08-30）

## 9. 两个项目的内容边界

### 9.1 重点项目：票券排版器

项目应集中证明 02-01 与 02-02：

- 票面主体用有限宽度约束和 Flex 分配；可变长度标题必须真实参与布局；
- 标签、票种或注意事项用 `Wrap`，数量保持受控；
- 票根、角标、印章等局部装饰用 `Stack`，并专门验证窄屏、200% 文本和 Stack 边外 hit test；
- 调试视图显示父约束和最终尺寸，但不引入 RenderObject 自定义代码。

现有项目描述要求“修改票券字段”，但该项目位于表单章节之前。为守住顺序，建议二选一：

1. 02-02 保持当前位置，交互改为已学过的预设内容长度、票种和版式切换，不出现 `TextEditingController` / `Form`；
2. 如果必须自由编辑文本，把项目移到 02-05，并让 02-02 只引用静态布局探针。

不要在 02-02 用一段未解释的表单代码换取“可编辑”外观。Flex、Wrap 和 Stack 本身已经足够支撑一个完整、可验证的布局项目。[Expanded API](https://api.flutter.dev/flutter/widgets/Expanded-class.html) · [Wrap API](https://api.flutter.dev/flutter/widgets/Wrap-class.html) · [Stack API](https://api.flutter.dev/flutter/widgets/Stack-class.html)（查阅：2026-08-30）

### 9.2 统筹项目：小型展览编辑器

项目适合把本部分能力集中在一个任务流中：

- 页面只有一个滚动主体，页头、筛选区、空状态和 lazy 展品列表按实际需要使用 box / sliver；
- 展品卡是受控、可单测的组件，接收数据和语义回调，不持有列表级业务状态；
- 新增 / 编辑表单使用同步 validator，controller 与 focus node 由页面 `State` 持有并释放；
- 保存、删除等命令由按钮和快捷键共同调用同一个 Intent / Action；hover 只补充视觉反馈；
- 无鼠标也能完成新增、修正验证错误、保存和删除，200% 文本下不靠固定卡片高度维持版式。

该项目不应提前加入网络保存、异步唯一性校验、持久化、路由或复杂状态管理。失败状态只覆盖本部分真实存在的本地验证与提交错误，不为凑状态制造远程服务。[Build a form with validation](https://docs.flutter.dev/cookbook/forms/validation) · [Using Actions and Shortcuts](https://docs.flutter.dev/ui/interactivity/actions-and-shortcuts) · [ListView.builder API](https://api.flutter.dev/flutter/widgets/ListView/ListView.builder.html)（查阅：2026-08-30）

## 10. 写作时必须避免的误讲

| 容易写成 | 应改成 |
| --- | --- |
| “Flutter 子级想多大就多大” | 子级只能在父级约束允许的范围内选尺寸。 |
| “loose 就是没有约束” | loose 只说明最小值为 0；最大值仍可能有限。 |
| “unbounded 就是父级完全不管” | 只表示某一轴最大值为无穷，另一轴仍可有界。 |
| “Expanded 会按内容比例放大” | 它忽略子级主轴偏好，按 flex factor 分剩余空间，并给 tight 约束。 |
| “Flexible 是不会报错的 Expanded” | loose fit 允许更小，但无界主轴是否合理仍要回到父约束。 |
| “Wrap 是响应式网格” | Wrap 按真实尺寸换 run，不保证固定列数，也不 lazy。 |
| “Stack 的 positioned 子级会撑开父级” | Stack 尺寸主要由非 positioned 子级或父约束决定。 |
| “Clip.none 后画出去的部分也能点击” | Stack 的 hit-test 区域不会超出自身 bounds。 |
| “加 shrinkWrap 就能解决嵌套列表” | 它会改变尺寸策略并增加滚动期间的布局成本，先确认是否该只有一个滚动主体。 |
| “builder 只创建屏幕内的精确 N 项” | 它按需创建，也可能创建缓存范围内的项；具体数量不是稳定合同。 |
| “Form 验证可以直接 async” | validator 是同步函数；异步检查和提交状态单独建模。 |
| “controller 在 build 里 new 就行” | controller 跨 build 存活，由拥有它的 State 释放。 |
| “没有焦点也能收到局部键盘事件” | key event 沿 focus tree 分发；局部处理必须先建立焦点路径。 |
| “KeyboardListener 适合文本输入” | 文本输入用 TextField / EditableText；KeyboardListener 面向非文本按键。 |
| “MouseRegion 让组件可操作” | 它只处理 hover / enter / exit / cursor，激活仍需触摸与键盘路径。 |
| “把 GestureDetector.behavior 改成 opaque 就能让父子都 onTap” | behavior 不改变 gesture arena 的父子竞争结果。 |
| “复用就是做一个参数很多的万能卡片” | 复用边界应围绕稳定业务语义，内部布局和资源所有权保持封装。 |

这些更正分别对应 Flutter 的 box 约束、Flex、Stack、ScrollView、Form、Focus、Actions 与 gesture 官方合同。[Understanding constraints](https://docs.flutter.dev/ui/layout/constraints) · [Scrolling](https://docs.flutter.dev/ui/layout/scrolling) · [Build a form with validation](https://docs.flutter.dev/cookbook/forms/validation) · [Understanding focus](https://docs.flutter.dev/ui/interactivity/focus) · [Using Actions and Shortcuts](https://docs.flutter.dev/ui/interactivity/actions-and-shortcuts) · [Taps, drags, and other gestures](https://docs.flutter.dev/ui/interactivity/gestures)（查阅：2026-08-30）

## 11. 正文参考资料清单

章节页尾只列实际使用的来源，不必把本清单整段复制过去。

- [Flutter 3.47.0 release notes](https://docs.flutter.dev/release/release-notes/release-notes-3.47.0)（查阅：2026-08-30）
- [Understanding constraints](https://docs.flutter.dev/ui/layout/constraints)（查阅：2026-08-30）
- [BoxConstraints API](https://api.flutter.dev/flutter/rendering/BoxConstraints-class.html)（查阅：2026-08-30）
- [Flex API](https://api.flutter.dev/flutter/widgets/Flex-class.html)（查阅：2026-08-30）
- [Expanded API](https://api.flutter.dev/flutter/widgets/Expanded-class.html)（查阅：2026-08-30）
- [Flexible API](https://api.flutter.dev/flutter/widgets/Flexible-class.html)（查阅：2026-08-30）
- [Wrap API](https://api.flutter.dev/flutter/widgets/Wrap-class.html)（查阅：2026-08-30）
- [Stack API](https://api.flutter.dev/flutter/widgets/Stack-class.html)（查阅：2026-08-30）
- [Scrolling](https://docs.flutter.dev/ui/layout/scrolling)（查阅：2026-08-30）
- [SingleChildScrollView API](https://api.flutter.dev/flutter/widgets/SingleChildScrollView-class.html)（查阅：2026-08-30）
- [ListView.builder API](https://api.flutter.dev/flutter/widgets/ListView/ListView.builder.html)（查阅：2026-08-30）
- [GridView.builder API](https://api.flutter.dev/flutter/widgets/GridView/GridView.builder.html)（查阅：2026-08-30）
- [Using slivers](https://docs.flutter.dev/ui/layout/scrolling/slivers)（查阅：2026-08-30）
- [CustomScrollView API](https://api.flutter.dev/flutter/widgets/CustomScrollView-class.html)（查阅：2026-08-30）
- [SliverList API](https://api.flutter.dev/flutter/widgets/SliverList-class.html)（查阅：2026-08-30）
- [Flutter architectural overview](https://docs.flutter.dev/resources/architectural-overview)（查阅：2026-08-30）
- [StatelessWidget API](https://api.flutter.dev/flutter/widgets/StatelessWidget-class.html)（查阅：2026-08-30）
- [Add interactivity](https://docs.flutter.dev/ui/interactivity)（查阅：2026-08-30）
- [Use themes](https://docs.flutter.dev/cookbook/design/themes)（查阅：2026-08-30）
- [Build a form with validation](https://docs.flutter.dev/cookbook/forms/validation)（查阅：2026-08-30）
- [Handle changes to a text field](https://docs.flutter.dev/cookbook/forms/text-field-changes)（查阅：2026-08-30）
- [TextFormField API](https://api.flutter.dev/flutter/material/TextFormField-class.html)（查阅：2026-08-30）
- [TextEditingController API](https://api.flutter.dev/flutter/widgets/TextEditingController-class.html)（查阅：2026-08-30）
- [Understanding Flutter's keyboard focus system](https://docs.flutter.dev/ui/interactivity/focus)（查阅：2026-08-30）
- [Using Actions and Shortcuts](https://docs.flutter.dev/ui/interactivity/actions-and-shortcuts)（查阅：2026-08-30）
- [FocusableActionDetector API](https://api.flutter.dev/flutter/widgets/FocusableActionDetector-class.html)（查阅：2026-08-30）
- [Key event migration](https://docs.flutter.dev/release/breaking-changes/key-event-migration)（查阅：2026-08-30）
- [HardwareKeyboard API](https://api.flutter.dev/flutter/services/HardwareKeyboard-class.html)（查阅：2026-08-30）
- [KeyboardListener API](https://api.flutter.dev/flutter/widgets/KeyboardListener-class.html)（查阅：2026-08-30）
- [Taps, drags, and other gestures](https://docs.flutter.dev/ui/interactivity/gestures)（查阅：2026-08-30）
- [MouseRegion API](https://api.flutter.dev/flutter/widgets/MouseRegion-class.html)（查阅：2026-08-30）
- [Listener API](https://api.flutter.dev/flutter/widgets/Listener-class.html)（查阅：2026-08-30）
- [GestureDetector API](https://api.flutter.dev/flutter/widgets/GestureDetector-class.html)（查阅：2026-08-30）
