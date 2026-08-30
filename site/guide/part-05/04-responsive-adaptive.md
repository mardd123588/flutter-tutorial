---
title: 响应式与平台适应
description: 依据实际约束切换布局与导航，并为指针、键盘和平台惯例保留等价操作。
part: 5
order: 4
kind: concept
requires:
  - layout.constraints
  - layout.flex
  - input.focus
  - input.keyboard
  - navigation.shell-route
provides:
  - layout.responsive
  - layout.content-breakpoint
  - navigation.adaptive-shell
  - input.adaptive
status: verified
---

# 响应式与平台适应

响应式布局根据可用空间重新排列同一份内容，平台适应则尊重输入方式和平台惯例。两者都不该靠“这是手机还是平板”来猜。

窗口可以缩放、分屏、嵌入侧栏，也可能运行在折叠设备上。真正影响当前 Widget 的，是父级约束、文本尺寸和任务需要多少空间。

## MediaQuery 看窗口，LayoutBuilder 看局部约束

`MediaQuery.sizeOf(context)` 读取整个应用窗口。`LayoutBuilder` 的 `constraints` 来自当前 Widget 的父级：

```dart
LayoutBuilder(
  builder: (context, constraints) {
    final showSidePanel = constraints.maxWidth >= 760;
    return showSidePanel
        ? Row(
            children: [
              const Expanded(child: VenueList()),
              SizedBox(width: 320, child: VenueSummary()),
            ],
          )
        : const VenueList();
  },
)
```

页面最外层是否显示侧栏，可以参考窗口宽度；嵌在页面里的卡片、工具栏或面板必须看自己的约束。即使窗口有 1400px，一个只分到 420px 的子区域也不能采用宽布局。

优先使用 `MediaQuery.sizeOf`、`paddingOf`、`textScalerOf` 和 `disableAnimationsOf` 等特定 accessor。`MediaQuery.of` 会依赖整份 `MediaQueryData`，其他字段变化也可能让调用处重建。

## 断点来自内容开始拥挤的位置

可以先用 600 logical px 做探测，再把真实内容放进去检查：

1. 使用最长中文与英文标题；
2. 文本放大到 200%；
3. 保留主操作、错误信息和焦点指示；
4. 缩窄窗口，记录任务第一次断裂的宽度；
5. 把断点放在断裂前，而不是套用设备分类。

一个页面在 680px 已经需要换行，另一个页面可能到 900px 才适合放 NavigationRail。断点属于这组内容和布局，不是 Flutter 全局常量。

## 导航组件可以换，目的地不能换

同一组顶层目的地可在窄屏放进 `NavigationDrawer`，宽屏放进 `NavigationRail`：

```dart
LayoutBuilder(
  builder: (context, constraints) {
    final useRail = constraints.maxWidth >= 760;
    return Scaffold(
      drawer: useRail
          ? null
          : NavigationDrawer(
              selectedIndex: selectedIndex,
              onDestinationSelected: openDestination,
              children: destinations,
            ),
      body: useRail
          ? Row(
              children: [
                NavigationRail(
                  selectedIndex: selectedIndex,
                  onDestinationSelected: openDestination,
                  destinations: railDestinations,
                ),
                Expanded(child: child),
              ],
            )
          : child,
    );
  },
)
```

`selectedIndex` 应由当前 Router URI 推导，`openDestination` 导航到同一组 path。窗口跨过断点时只替换导航容器，不重建路由树，也不清掉搜索、筛选或当前详情。

Drawer 是临时层：打开后焦点应进入其中，Escape 或返回关闭后回到合理触发点。Rail 常驻，不应抢走内容区的首个任务焦点。

## 先重排，再考虑隐藏

空间不足时按这个顺序处理：

- 允许标题和按钮文字换行或增高；
- `Row` 改 `Wrap`，双栏改上下排列；
- 把次要动作移入有文字名称的菜单；
- 最后才隐藏可省略信息。

主操作、当前状态、错误原因和恢复动作不能因为窄屏消失。横向滚动适合时间轴或宽表格，不适合修补普通表单和导航溢出。

## Hover 只能增强

Web 和桌面有鼠标 hover、滚轮和右键，移动设备主要依靠触摸。只在 hover 时出现的按钮，触屏用户无法发现，键盘用户也不一定能到达。

内置 Material 按钮、`InkWell` 和可选择控件已经处理大量 hover、focus 与键盘行为。自定义复合控件可用 `FocusableActionDetector` 同时管理：

- `onShowHoverHighlight`：指针提示；
- `onShowFocusHighlight`：可见键盘焦点；
- `shortcuts` / `actions`：等价键盘操作；
- `mouseCursor`：指针反馈。

真实动作仍要有可点击、可聚焦、带名称的入口。hover 预览可以省略，hover 里的“删除”不能成为唯一删除方式。

## 键盘操作按焦点作用域工作

快捷键不是全局广播。`Shortcuts` 把按键映射到 `Intent`，`Actions` 在当前焦点树中寻找对应动作。页面切换布局后，要保持同一个任务的焦点顺序：导航、标题动作、筛选、内容。

不要在应用根部直接监听所有按键。文本框里 `/`、方向键和空格都有编辑意义；快捷键必须先判断当前焦点域，或只包住应生效的页面区域。

## 平台适应到明确惯例

Flutter 提供按平台选择行为的组件：

```dart
Switch.adaptive(
  value: enabled,
  onChanged: onChanged,
)

final accepted = await showAdaptiveDialog<bool>(
  context: context,
  builder: buildDialog,
);
```

`showAdaptiveDialog` 在 iOS / macOS 使用 Cupertino dialog，在其他平台使用 Material dialog；不同分支的默认 barrier 行为也可能不同。适应后仍要测试确认、取消和系统返回。

组件视觉与交互适应通常读取 `Theme.of(context).platform`。只有调用平台系统 API 时才需要直接判断实际目标平台。没有必要把整个 Material 应用逐页改画成 Cupertino；返回、dialog、switch 等有明确惯例的部分先适应即可。

## 200% 文本也是布局条件

窗口宽度没变，文字放大后可用空间会迅速减少。不要全局限制 `textScaler` 来掩盖溢出。使用可增高控件、`Wrap`、`Flexible`、滚动页面和足够的垂直间距，让核心任务在 320px 等效宽度与 200% 文本下仍能完成。

检查时不要只看有没有黄色 overflow 条纹，还要确认长标题、错误文本、Drawer 目的地和按钮都能读完、聚焦和触发。

## 可验证任务

做一个独立的场馆列表壳：三个目的地、一个筛选区和一组列表，不接完整项目。

- 320×720：AppBar + Drawer，筛选纵向换行；
- 768×900：仍使用 Drawer，但内容可双列；
- 1440×900：NavigationRail + 主内容；
- 三种尺寸共享 path、selectedIndex 和筛选状态；
- 200% 文本下不横向溢出；
- Tab、Enter、Space、Escape 能完成导航与筛选。

Widget 测试直接设置 `tester.view.physicalSize` 和 `devicePixelRatio`。布局组件存在只是第一步，还要断言任务控件可见且 `tester.takeException()` 为 null。

## 常见误区

- 写成“600px 以下是手机，以上是平板”。
- 用横竖屏代替实际窗口约束。
- 为窄屏和宽屏维护两套路由与状态。
- 把主要动作藏在 hover overlay。
- 为避免 200% 文本溢出而压低用户缩放设置。
- 只根据平台名换颜色，没有处理返回、dialog 或输入惯例。

## 复习线索

- `MediaQuery` 看窗口环境，`LayoutBuilder` 看当前位置的父级约束。
- 断点由内容、文本缩放和任务连续性共同决定。
- Drawer 与 Rail 可以替换，目的地、URL 和状态必须保持。
- 平台适应选择有明确惯例的行为，不重写整套信息结构。

## 参考资料

- [Flutter adaptive and responsive design](https://docs.flutter.dev/ui/adaptive-responsive)（查阅：2026-08-30）
- [Adaptive responsive general approach](https://docs.flutter.dev/ui/adaptive-responsive/general)（查阅：2026-08-30）
- [Adaptive input](https://docs.flutter.dev/ui/adaptive-responsive/input)（查阅：2026-08-30）
- [LayoutBuilder API](https://api.flutter.dev/flutter/widgets/LayoutBuilder-class.html)（查阅：2026-08-30）
- [MediaQuery API](https://api.flutter.dev/flutter/widgets/MediaQuery-class.html)（查阅：2026-08-30）
- [NavigationRail API](https://api.flutter.dev/flutter/material/NavigationRail-class.html)（查阅：2026-08-30）
- [NavigationDrawer API](https://api.flutter.dev/flutter/material/NavigationDrawer-class.html)（查阅：2026-08-30）
- [FocusableActionDetector API](https://api.flutter.dev/flutter/widgets/FocusableActionDetector-class.html)（查阅：2026-08-30）
- [showAdaptiveDialog API](https://api.flutter.dev/flutter/material/showAdaptiveDialog.html)（查阅：2026-08-30）
