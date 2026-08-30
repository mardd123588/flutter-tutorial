---
title: 国际化与本地化
description: 用 gen_l10n、ARB、intl 与方向性布局支持中英文，同时保持稳定业务值和 URL。
part: 5
order: 6
kind: concept
requires:
  - navigation.url-state
  - a11y.text-scale
  - layout.responsive
provides:
  - i18n.gen-l10n
  - i18n.arb
  - i18n.format
  - i18n.locale
  - i18n.directionality
status: verified
---

# 国际化与本地化

国际化先把代码改成能承载多种语言、格式和方向，本地化再为具体 locale 提供消息。把中文字符串换成英文只是其中一部分；复数、日期、数字、文本方向和稳定资源身份也要一起处理。

本章示例是一个中英文地点摘要页。业务层保存地点 ID、日期和人数，展示层按当前 locale 生成文字。

## 接入 flutter_localizations 与 gen_l10n

`pubspec.yaml`：

```yaml
dependencies:
  flutter:
    sdk: flutter
  flutter_localizations:
    sdk: flutter
  intl: 0.20.3

flutter:
  generate: true
  uses-material-design: true
```

`l10n.yaml`：

```yaml
arb-dir: lib/l10n
template-arb-file: app_zh.arb
output-localization-file: app_localizations.dart
output-class: AppLocalizations
nullable-getter: false
preferred-supported-locales:
  - zh
  - en
```

运行 `flutter gen-l10n`，或让 Flutter 构建流程生成本地化类。生成文件不要手工修改；改 ARB 和配置后重新生成。

## ARB 同时保存消息和参数合同

`app_zh.arb` 可以包含普通消息、placeholder、复数和日期格式：

```json
{
  "@@locale": "zh",
  "placeTitle": "地点摘要",
  "placeSummary": "{name}位于 {floor} 层",
  "@placeSummary": {
    "placeholders": {
      "name": {"type": "String"},
      "floor": {"type": "int"}
    }
  },
  "visitorCount": "{count, plural, =0{暂无访客} =1{1 位访客} other{{count} 位访客}}",
  "@visitorCount": {
    "placeholders": {
      "count": {"type": "int"}
    }
  },
  "updatedOn": "更新于 {date}",
  "@updatedOn": {
    "placeholders": {
      "date": {"type": "DateTime", "format": "yMMMMd"}
    }
  }
}
```

placeholder 名必须是合法 Dart identifier。元数据里的 `type` 和 `format` 会进入生成的方法签名，翻译者也能看到变量含义。

英文 ARB 保持相同 key 与参数，句序可完全不同：

```json
{
  "@@locale": "en",
  "placeTitle": "Place summary",
  "placeSummary": "{name} is on floor {floor}",
  "visitorCount": "{count, plural, =0{No visitors} =1{1 visitor} other{{count} visitors}}",
  "updatedOn": "Updated {date}"
}
```

只有 `other` 是 ICU plural 必需分支，但常见产品仍应明确零和单数。不能在 UI 中手写 `count == 1` 代替 locale 的复数规则。

## MaterialApp 使用生成的 delegate

```dart
MaterialApp.router(
  locale: locale,
  supportedLocales: AppLocalizations.supportedLocales,
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
  routerConfig: router,
)
```

`GlobalWidgetsLocalizations.delegate` 会提供默认文本方向等 Widgets 本地化数据；生成类的 `localizationsDelegates` 已汇集需要的 delegate。

在 Widget 内读取：

```dart
final strings = AppLocalizations.of(context);

Text(strings.placeSummary(place.name, place.floor));
Text(strings.visitorCount(visitorCount));
Text(strings.updatedOn(updatedAt));
```

`AppLocalizations.of(context)` 依赖当前 Localizations。locale 改变后，读取它的 Widget 会按新消息重建。

## Locale 表达语言、脚本与地区

简单中英文可以使用 `Locale('zh')` 和 `Locale('en')`。需要区分脚本或地区时，使用 `Locale.fromSubtags`：

```dart
const Locale.fromSubtags(
  languageCode: 'zh',
  scriptCode: 'Hans',
  countryCode: 'CN',
)
```

不要用 `toString()` 拼业务判断。根据需要读取 `languageCode`、`scriptCode` 和 `countryCode`，并为不支持的组合定义回退。

用户切换语言时，controller 只改变 locale。当前 Router URI、地点 ID、query、搜索文本和业务选择不应被重建成默认值。

## intl 只格式化展示

业务层继续保存 `DateTime`、`num` 和枚举。显示前再按 locale 格式化：

```dart
final languageTag = Localizations.localeOf(context).toLanguageTag();
final dateText = DateFormat.yMMMd(languageTag).format(updatedAt);
final distanceText = NumberFormat.decimalPatternDigits(
  locale: languageTag,
  decimalDigits: 1,
).format(distanceKilometers);
```

日期 skeleton 会按 locale 选择顺序，数字格式会选择分组符和小数符。不要为了显示把业务数值先改成字符串再存回模型。

常用消息格式优先放进 ARB placeholder，让翻译与句序集中管理。业务层单独生成报表或非 Widget 文本时，再直接使用 `DateFormat`、`NumberFormat`。

## URL 使用稳定 ID，不使用翻译标题

下面的地址在中英文下都保持不变：

```text
/venues/materials-hall?floor=2
```

页面显示“材料展厅”或“Materials Hall”，模型仍保存 `materials-hall`。语言是展示偏好，不是资源身份。把翻译标题写进 path 会造成：

- 换语言时 URL 改变；
- 旧链接随文案调整失效；
- 同一资源出现多个不稳定地址；
- 解析逻辑被翻译细节污染。

若产品确实需要 locale 前缀，如 `/en/venues/...`，它应是明确的路由合同，并处理 canonical、redirect 和默认语言；不能临时用标题代替 ID。

## Directionality 影响 start 与 end

`Directionality.of(context)` 告诉布局当前文本方向。可镜像的几何使用方向性 API：

```dart
Padding(
  padding: const EdgeInsetsDirectional.fromSTEB(24, 12, 16, 12),
  child: Align(
    alignment: AlignmentDirectional.centerStart,
    child: content,
  ),
)
```

LTR 中 start 在左，RTL 中 start 在右。对应 API 还有 `PositionedDirectional`、`BorderDirectional` 和 `TextAlign.start`。

并非所有内容都水平翻转。播放、时间推进、品牌标志、地图与真实空间方向要按语义判断；楼层图若镜像，也要保证摘要和真实操作列表仍一致。

当前示例只提供中文和英文，它们都是 LTR。可以在测试外层额外包 `Directionality(textDirection: TextDirection.rtl)` 检查方向性几何，但不能据此声称已完成阿拉伯语本地化。

## 翻译不能破坏布局

英文可能更长，中文在 200% 文本下也会快速增高。国际化测试至少覆盖：

- 最长标题与按钮文字；
- 复数的 0、1、2；
- 日期和数字格式；
- 320×720 与 200% 文本；
- locale 切换前后的 URI 与业务选择；
- RTL 测试壳中的 start / end 排列。

不要把控件宽度按中文短句固定死，也不要用省略号隐藏关键错误和主操作。

## 可验证任务

完成一个地点摘要页：

- ARB 提供中英文地点名、placeholder、plural 和日期；
- `MaterialApp` 使用生成的 delegates 与 supportedLocales；
- 日期和距离按当前 locale 格式化；
- `/venues/materials-hall?floor=2` 在切换语言后保持不变；
- 搜索文本与焦点不因 locale 重建丢失；
- 额外 RTL 测试壳无 overflow，但文档不宣称支持 RTL 语言。

## 常见误区

- 把所有字符串集中到一个 Dart map，却丢掉 plural、格式和生成检查。
- 在 Widget 中用 `count == 1` 手写英文复数。
- 把格式化后的日期和数字保存回业务模型。
- 语言切换时重建 Router，导致 URI 和页面任务归零。
- 用翻译标题作为 route ID。
- 把 RTL 理解成所有图形无条件水平翻转。

## 复习线索

- ARB 保存消息和 placeholder 合同，`gen_l10n` 生成类型安全入口。
- `intl` 处理显示格式，不改变业务值。
- locale 改变展示；稳定 ID 保持资源和 URL 身份。
- Directional 几何处理 start / end，是否镜像仍由内容语义决定。

## 参考资料

- [Flutter internationalization](https://docs.flutter.dev/ui/accessibility-and-internationalization/internationalization)（查阅：2026-08-30）
- [intl 0.20.3](https://pub.dev/packages/intl/versions/0.20.3)（查阅：2026-08-30）
- [DateFormat 0.20.3 API](https://pub.dev/documentation/intl/0.20.3/intl/DateFormat-class.html)（查阅：2026-08-30）
- [NumberFormat 0.20.3 API](https://pub.dev/documentation/intl/0.20.3/intl/NumberFormat-class.html)（查阅：2026-08-30）
- [Locale.fromSubtags API](https://api.flutter.dev/flutter/dart-ui/Locale/Locale.fromSubtags.html)（查阅：2026-08-30）
- [Directionality API](https://api.flutter.dev/flutter/widgets/Directionality-class.html)（查阅：2026-08-30）
- [EdgeInsetsDirectional API](https://api.flutter.dev/flutter/painting/EdgeInsetsDirectional-class.html)（查阅：2026-08-30）
