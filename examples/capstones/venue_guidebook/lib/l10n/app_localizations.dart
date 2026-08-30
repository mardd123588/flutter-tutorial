import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('zh'),
    Locale('en'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In zh, this message translates to:
  /// **'场馆导览册'**
  String get appTitle;

  /// No description provided for @appSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'一册看清楼层、地点与参观路线'**
  String get appSubtitle;

  /// No description provided for @venuesDestination.
  ///
  /// In zh, this message translates to:
  /// **'地点'**
  String get venuesDestination;

  /// No description provided for @routesDestination.
  ///
  /// In zh, this message translates to:
  /// **'路线'**
  String get routesDestination;

  /// No description provided for @aboutDestination.
  ///
  /// In zh, this message translates to:
  /// **'关于'**
  String get aboutDestination;

  /// No description provided for @openNavigation.
  ///
  /// In zh, this message translates to:
  /// **'打开导航'**
  String get openNavigation;

  /// No description provided for @closeNavigation.
  ///
  /// In zh, this message translates to:
  /// **'关闭导航'**
  String get closeNavigation;

  /// No description provided for @languageLabel.
  ///
  /// In zh, this message translates to:
  /// **'界面语言'**
  String get languageLabel;

  /// No description provided for @switchToChinese.
  ///
  /// In zh, this message translates to:
  /// **'切换为中文'**
  String get switchToChinese;

  /// No description provided for @switchToEnglish.
  ///
  /// In zh, this message translates to:
  /// **'Switch to English'**
  String get switchToEnglish;

  /// No description provided for @searchLabel.
  ///
  /// In zh, this message translates to:
  /// **'搜索地点'**
  String get searchLabel;

  /// No description provided for @searchHint.
  ///
  /// In zh, this message translates to:
  /// **'输入展厅、设施或标签'**
  String get searchHint;

  /// No description provided for @searchShortcutHint.
  ///
  /// In zh, this message translates to:
  /// **'按 / 聚焦搜索'**
  String get searchShortcutHint;

  /// No description provided for @clearSearch.
  ///
  /// In zh, this message translates to:
  /// **'清空搜索'**
  String get clearSearch;

  /// No description provided for @resultCount.
  ///
  /// In zh, this message translates to:
  /// **'{count, plural, =0{没有匹配地点} =1{找到 1 个地点} other{找到 {count} 个地点}}'**
  String resultCount(int count);

  /// No description provided for @noResultsTitle.
  ///
  /// In zh, this message translates to:
  /// **'没有找到地点'**
  String get noResultsTitle;

  /// No description provided for @noResultsBody.
  ///
  /// In zh, this message translates to:
  /// **'换一个地点名、楼层或标签试试。'**
  String get noResultsBody;

  /// No description provided for @browseAll.
  ///
  /// In zh, this message translates to:
  /// **'查看全部地点'**
  String get browseAll;

  /// No description provided for @featuredGuide.
  ///
  /// In zh, this message translates to:
  /// **'今日导览索引'**
  String get featuredGuide;

  /// No description provided for @updatedOn.
  ///
  /// In zh, this message translates to:
  /// **'资料日期：{date}'**
  String updatedOn(DateTime date);

  /// No description provided for @viewVenue.
  ///
  /// In zh, this message translates to:
  /// **'查看地点'**
  String get viewVenue;

  /// No description provided for @venueItemLabel.
  ///
  /// In zh, this message translates to:
  /// **'{name}，{floor}，{tags}'**
  String venueItemLabel(String name, String floor, String tags);

  /// No description provided for @floorLabel.
  ///
  /// In zh, this message translates to:
  /// **'{floor} 层'**
  String floorLabel(int floor);

  /// No description provided for @floorShortLabel.
  ///
  /// In zh, this message translates to:
  /// **'F{floor}'**
  String floorShortLabel(int floor);

  /// No description provided for @allFloors.
  ///
  /// In zh, this message translates to:
  /// **'全部楼层'**
  String get allFloors;

  /// No description provided for @filterByFloor.
  ///
  /// In zh, this message translates to:
  /// **'按楼层查看'**
  String get filterByFloor;

  /// No description provided for @filterByTag.
  ///
  /// In zh, this message translates to:
  /// **'按标签查看'**
  String get filterByTag;

  /// No description provided for @clearTag.
  ///
  /// In zh, this message translates to:
  /// **'全部标签'**
  String get clearTag;

  /// No description provided for @quietTag.
  ///
  /// In zh, this message translates to:
  /// **'安静'**
  String get quietTag;

  /// No description provided for @accessibleTag.
  ///
  /// In zh, this message translates to:
  /// **'无障碍'**
  String get accessibleTag;

  /// No description provided for @familyTag.
  ///
  /// In zh, this message translates to:
  /// **'亲子'**
  String get familyTag;

  /// No description provided for @studioTag.
  ///
  /// In zh, this message translates to:
  /// **'工坊'**
  String get studioTag;

  /// No description provided for @selectedState.
  ///
  /// In zh, this message translates to:
  /// **'已选择'**
  String get selectedState;

  /// No description provided for @venueDetails.
  ///
  /// In zh, this message translates to:
  /// **'地点详情'**
  String get venueDetails;

  /// No description provided for @backToVenues.
  ///
  /// In zh, this message translates to:
  /// **'返回地点列表'**
  String get backToVenues;

  /// No description provided for @openHours.
  ///
  /// In zh, this message translates to:
  /// **'开放时段'**
  String get openHours;

  /// No description provided for @openPeriod.
  ///
  /// In zh, this message translates to:
  /// **'{start}–{end}'**
  String openPeriod(String start, String end);

  /// No description provided for @currentFloor.
  ///
  /// In zh, this message translates to:
  /// **'当前楼层'**
  String get currentFloor;

  /// No description provided for @floorPlanTitle.
  ///
  /// In zh, this message translates to:
  /// **'楼层示意'**
  String get floorPlanTitle;

  /// No description provided for @floorPlanSummary.
  ///
  /// In zh, this message translates to:
  /// **'{floor} 层平面摘要：{rooms}'**
  String floorPlanSummary(int floor, String rooms);

  /// No description provided for @placesOnFloor.
  ///
  /// In zh, this message translates to:
  /// **'本层地点'**
  String get placesOnFloor;

  /// No description provided for @routeIndexTitle.
  ///
  /// In zh, this message translates to:
  /// **'三条馆内路线'**
  String get routeIndexTitle;

  /// No description provided for @routeIndexBody.
  ///
  /// In zh, this message translates to:
  /// **'路线使用本地固定数据。先看停靠顺序，再按自己的节奏行走。'**
  String get routeIndexBody;

  /// No description provided for @routeStopCount.
  ///
  /// In zh, this message translates to:
  /// **'{count, plural, =1{1 个停靠点} other{{count} 个停靠点}}'**
  String routeStopCount(int count);

  /// No description provided for @aboutTitle.
  ///
  /// In zh, this message translates to:
  /// **'这本导览册如何工作'**
  String get aboutTitle;

  /// No description provided for @aboutBody.
  ///
  /// In zh, this message translates to:
  /// **'地点身份写在 path，楼层和标签写在 query。切换语言不会改变当前地址，也不会丢掉正在查看的地点。'**
  String get aboutBody;

  /// No description provided for @keyboardTitle.
  ///
  /// In zh, this message translates to:
  /// **'键盘操作'**
  String get keyboardTitle;

  /// No description provided for @keyboardBody.
  ///
  /// In zh, this message translates to:
  /// **'按 / 聚焦地点搜索；按 Escape 关闭抽屉等临时层。焦点在输入框里时，/ 仍会正常输入。'**
  String get keyboardBody;

  /// No description provided for @accessibilityTitle.
  ///
  /// In zh, this message translates to:
  /// **'图形只是摘要'**
  String get accessibilityTitle;

  /// No description provided for @accessibilityBody.
  ///
  /// In zh, this message translates to:
  /// **'楼层图不承担操作。屏幕阅读器会读出摘要，键盘和触屏操作都在真实地点列表中完成。'**
  String get accessibilityBody;

  /// No description provided for @linkErrorTitle.
  ///
  /// In zh, this message translates to:
  /// **'这个地点链接无法打开'**
  String get linkErrorTitle;

  /// No description provided for @unmatchedTitle.
  ///
  /// In zh, this message translates to:
  /// **'没有匹配的页面'**
  String get unmatchedTitle;

  /// No description provided for @unknownVenueError.
  ///
  /// In zh, this message translates to:
  /// **'地点“{venueId}”不存在。'**
  String unknownVenueError(String venueId);

  /// No description provided for @invalidFloorError.
  ///
  /// In zh, this message translates to:
  /// **'floor 必须是整数。'**
  String get invalidFloorError;

  /// No description provided for @unavailableFloorError.
  ///
  /// In zh, this message translates to:
  /// **'这个地点不在 {floor} 层。'**
  String unavailableFloorError(int floor);

  /// No description provided for @invalidTagError.
  ///
  /// In zh, this message translates to:
  /// **'标签“{tag}”不适用于这个地点。'**
  String invalidTagError(String tag);

  /// No description provided for @duplicateParameterError.
  ///
  /// In zh, this message translates to:
  /// **'参数“{parameter}”重复出现。'**
  String duplicateParameterError(String parameter);

  /// No description provided for @unsupportedParameterError.
  ///
  /// In zh, this message translates to:
  /// **'参数“{parameter}”不受支持。'**
  String unsupportedParameterError(String parameter);

  /// No description provided for @repairLink.
  ///
  /// In zh, this message translates to:
  /// **'返回地点列表'**
  String get repairLink;

  /// No description provided for @unmatchedBody.
  ///
  /// In zh, this message translates to:
  /// **'地址没有对应内容。请从地点、路线或关于页重新进入。'**
  String get unmatchedBody;

  /// No description provided for @atriumName.
  ///
  /// In zh, this message translates to:
  /// **'中央中庭'**
  String get atriumName;

  /// No description provided for @atriumSummary.
  ///
  /// In zh, this message translates to:
  /// **'连接主入口、展厅与二层连桥，是最容易确认方向的位置。'**
  String get atriumSummary;

  /// No description provided for @materialHallName.
  ///
  /// In zh, this message translates to:
  /// **'材料展厅'**
  String get materialHallName;

  /// No description provided for @materialHallSummary.
  ///
  /// In zh, this message translates to:
  /// **'展示木、纸、金属和织物的修复样本，可近距离比较工艺。'**
  String get materialHallSummary;

  /// No description provided for @soundLabName.
  ///
  /// In zh, this message translates to:
  /// **'声音实验室'**
  String get soundLabName;

  /// No description provided for @soundLabSummary.
  ///
  /// In zh, this message translates to:
  /// **'一间可预约试听的安静空间，展示馆藏录音与声景作品。'**
  String get soundLabSummary;

  /// No description provided for @roofStudioName.
  ///
  /// In zh, this message translates to:
  /// **'屋顶工坊'**
  String get roofStudioName;

  /// No description provided for @roofStudioSummary.
  ///
  /// In zh, this message translates to:
  /// **'面向家庭和小组的动手区域，天气良好时开放露台。'**
  String get roofStudioSummary;

  /// No description provided for @informationDesk.
  ///
  /// In zh, this message translates to:
  /// **'服务台'**
  String get informationDesk;

  /// No description provided for @mainGallery.
  ///
  /// In zh, this message translates to:
  /// **'主展厅'**
  String get mainGallery;

  /// No description provided for @quietAlcove.
  ///
  /// In zh, this message translates to:
  /// **'安静角'**
  String get quietAlcove;

  /// No description provided for @bridge.
  ///
  /// In zh, this message translates to:
  /// **'连桥'**
  String get bridge;

  /// No description provided for @materialsArchive.
  ///
  /// In zh, this message translates to:
  /// **'材料档案'**
  String get materialsArchive;

  /// No description provided for @sampleTables.
  ///
  /// In zh, this message translates to:
  /// **'样本台'**
  String get sampleTables;

  /// No description provided for @listeningRoom.
  ///
  /// In zh, this message translates to:
  /// **'试听室'**
  String get listeningRoom;

  /// No description provided for @recordingBooth.
  ///
  /// In zh, this message translates to:
  /// **'录音间'**
  String get recordingBooth;

  /// No description provided for @workbench.
  ///
  /// In zh, this message translates to:
  /// **'工作台'**
  String get workbench;

  /// No description provided for @terrace.
  ///
  /// In zh, this message translates to:
  /// **'露台'**
  String get terrace;

  /// No description provided for @orientationRoute.
  ///
  /// In zh, this message translates to:
  /// **'首次到访'**
  String get orientationRoute;

  /// No description provided for @orientationRouteBody.
  ///
  /// In zh, this message translates to:
  /// **'从中庭确认方向，再到材料展厅和声音实验室。'**
  String get orientationRouteBody;

  /// No description provided for @quietRoute.
  ///
  /// In zh, this message translates to:
  /// **'安静路线'**
  String get quietRoute;

  /// No description provided for @quietRouteBody.
  ///
  /// In zh, this message translates to:
  /// **'避开工坊时段，经过安静角、材料档案和试听室。'**
  String get quietRouteBody;

  /// No description provided for @familyRoute.
  ///
  /// In zh, this message translates to:
  /// **'亲子路线'**
  String get familyRoute;

  /// No description provided for @familyRouteBody.
  ///
  /// In zh, this message translates to:
  /// **'从服务台领取任务纸，最后到屋顶工坊完成作品。'**
  String get familyRouteBody;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
