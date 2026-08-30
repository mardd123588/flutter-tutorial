// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appTitle => '场馆导览册';

  @override
  String get appSubtitle => '一册看清楼层、地点与参观路线';

  @override
  String get venuesDestination => '地点';

  @override
  String get routesDestination => '路线';

  @override
  String get aboutDestination => '关于';

  @override
  String get openNavigation => '打开导航';

  @override
  String get closeNavigation => '关闭导航';

  @override
  String get languageLabel => '界面语言';

  @override
  String get switchToChinese => '切换为中文';

  @override
  String get switchToEnglish => 'Switch to English';

  @override
  String get searchLabel => '搜索地点';

  @override
  String get searchHint => '输入展厅、设施或标签';

  @override
  String get searchShortcutHint => '按 / 聚焦搜索';

  @override
  String get clearSearch => '清空搜索';

  @override
  String resultCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '找到 $count 个地点',
      one: '找到 1 个地点',
      zero: '没有匹配地点',
    );
    return '$_temp0';
  }

  @override
  String get noResultsTitle => '没有找到地点';

  @override
  String get noResultsBody => '换一个地点名、楼层或标签试试。';

  @override
  String get browseAll => '查看全部地点';

  @override
  String get featuredGuide => '今日导览索引';

  @override
  String updatedOn(DateTime date) {
    final intl.DateFormat dateDateFormat = intl.DateFormat.yMMMMd(localeName);
    final String dateString = dateDateFormat.format(date);

    return '资料日期：$dateString';
  }

  @override
  String get viewVenue => '查看地点';

  @override
  String venueItemLabel(String name, String floor, String tags) {
    return '$name，$floor，$tags';
  }

  @override
  String floorLabel(int floor) {
    return '$floor 层';
  }

  @override
  String floorShortLabel(int floor) {
    return 'F$floor';
  }

  @override
  String get allFloors => '全部楼层';

  @override
  String get filterByFloor => '按楼层查看';

  @override
  String get filterByTag => '按标签查看';

  @override
  String get clearTag => '全部标签';

  @override
  String get quietTag => '安静';

  @override
  String get accessibleTag => '无障碍';

  @override
  String get familyTag => '亲子';

  @override
  String get studioTag => '工坊';

  @override
  String get selectedState => '已选择';

  @override
  String get venueDetails => '地点详情';

  @override
  String get backToVenues => '返回地点列表';

  @override
  String get openHours => '开放时段';

  @override
  String openPeriod(String start, String end) {
    return '$start–$end';
  }

  @override
  String get currentFloor => '当前楼层';

  @override
  String get floorPlanTitle => '楼层示意';

  @override
  String floorPlanSummary(int floor, String rooms) {
    return '$floor 层平面摘要：$rooms';
  }

  @override
  String get placesOnFloor => '本层地点';

  @override
  String get routeIndexTitle => '三条馆内路线';

  @override
  String get routeIndexBody => '路线使用本地固定数据。先看停靠顺序，再按自己的节奏行走。';

  @override
  String routeStopCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 个停靠点',
      one: '1 个停靠点',
    );
    return '$_temp0';
  }

  @override
  String get aboutTitle => '这本导览册如何工作';

  @override
  String get aboutBody =>
      '地点身份写在 path，楼层和标签写在 query。切换语言不会改变当前地址，也不会丢掉正在查看的地点。';

  @override
  String get keyboardTitle => '键盘操作';

  @override
  String get keyboardBody => '按 / 聚焦地点搜索；按 Escape 关闭抽屉等临时层。焦点在输入框里时，/ 仍会正常输入。';

  @override
  String get accessibilityTitle => '图形只是摘要';

  @override
  String get accessibilityBody => '楼层图不承担操作。屏幕阅读器会读出摘要，键盘和触屏操作都在真实地点列表中完成。';

  @override
  String get linkErrorTitle => '这个地点链接无法打开';

  @override
  String get unmatchedTitle => '没有匹配的页面';

  @override
  String unknownVenueError(String venueId) {
    return '地点“$venueId”不存在。';
  }

  @override
  String get invalidFloorError => 'floor 必须是整数。';

  @override
  String unavailableFloorError(int floor) {
    return '这个地点不在 $floor 层。';
  }

  @override
  String invalidTagError(String tag) {
    return '标签“$tag”不适用于这个地点。';
  }

  @override
  String duplicateParameterError(String parameter) {
    return '参数“$parameter”重复出现。';
  }

  @override
  String unsupportedParameterError(String parameter) {
    return '参数“$parameter”不受支持。';
  }

  @override
  String get repairLink => '返回地点列表';

  @override
  String get unmatchedBody => '地址没有对应内容。请从地点、路线或关于页重新进入。';

  @override
  String get atriumName => '中央中庭';

  @override
  String get atriumSummary => '连接主入口、展厅与二层连桥，是最容易确认方向的位置。';

  @override
  String get materialHallName => '材料展厅';

  @override
  String get materialHallSummary => '展示木、纸、金属和织物的修复样本，可近距离比较工艺。';

  @override
  String get soundLabName => '声音实验室';

  @override
  String get soundLabSummary => '一间可预约试听的安静空间，展示馆藏录音与声景作品。';

  @override
  String get roofStudioName => '屋顶工坊';

  @override
  String get roofStudioSummary => '面向家庭和小组的动手区域，天气良好时开放露台。';

  @override
  String get informationDesk => '服务台';

  @override
  String get mainGallery => '主展厅';

  @override
  String get quietAlcove => '安静角';

  @override
  String get bridge => '连桥';

  @override
  String get materialsArchive => '材料档案';

  @override
  String get sampleTables => '样本台';

  @override
  String get listeningRoom => '试听室';

  @override
  String get recordingBooth => '录音间';

  @override
  String get workbench => '工作台';

  @override
  String get terrace => '露台';

  @override
  String get orientationRoute => '首次到访';

  @override
  String get orientationRouteBody => '从中庭确认方向，再到材料展厅和声音实验室。';

  @override
  String get quietRoute => '安静路线';

  @override
  String get quietRouteBody => '避开工坊时段，经过安静角、材料档案和试听室。';

  @override
  String get familyRoute => '亲子路线';

  @override
  String get familyRouteBody => '从服务台领取任务纸，最后到屋顶工坊完成作品。';
}
