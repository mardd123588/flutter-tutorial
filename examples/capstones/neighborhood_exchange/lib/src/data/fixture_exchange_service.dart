import '../domain/exchange_models.dart';

abstract interface class FixtureExchangeService {
  Future<List<ExchangeListing>> load();
}

class DeterministicFixtureExchangeService implements FixtureExchangeService {
  const DeterministicFixtureExchangeService();

  @override
  Future<List<ExchangeListing>> load() async => fixtureExchangeListings;
}

final fixtureExchangeListings = List<ExchangeListing>.unmodifiable(
  List.generate(48, _fixtureAt),
);

ExchangeListing _fixtureAt(int index) {
  final category =
      ExchangeCategory.values[index % ExchangeCategory.values.length];
  final content =
      _contentByCategory[category]![index ~/ ExchangeCategory.values.length];
  final totalQuantity = 1 + (index % 3);
  final isCompleted = index % 13 == 12;
  final isReserved = !isCompleted && index % 7 == 6;
  final createdAt = DateTime.utc(
    2026,
    8,
    20,
  ).subtract(Duration(hours: index * 7));
  return ExchangeListing(
    id: 'r-${(index + 1).toString().padLeft(3, '0')}',
    origin: ListingOrigin.fixture,
    title: content.$1,
    description: content.$2,
    category: category,
    neighborhood:
        Neighborhood.values[(index * 5 + 1) % Neighborhood.values.length],
    handoffMethod: HandoffMethod.values[index % HandoffMethod.values.length],
    availableWindow:
        AvailableWindow.values[index % AvailableWindow.values.length],
    totalQuantity: totalQuantity,
    remainingQuantity: isCompleted || isReserved ? 0 : totalQuantity,
    ownerId: 'neighbor-${(index % _ownerNames.length) + 1}',
    ownerDisplayName: _ownerNames[index % _ownerNames.length],
    createdAt: createdAt,
    updatedAt: createdAt,
    completedAt: isCompleted ? createdAt.add(const Duration(days: 2)) : null,
  );
}

const _ownerNames = ['周岚', '陈默', '方遥', '许禾', '梁夏', '江芮', '宋原', '闻知'];

const _contentByCategory = <ExchangeCategory, List<(String, String)>>{
  ExchangeCategory.tools: [
    ('折叠手推车', '承重约 60 公斤，适合搬花盆和纸箱，车轮已检查。'),
    ('家用冲击钻', '附 6 支常用钻头，只用于室内轻量安装。'),
    ('棘轮螺丝刀组', '一柄主杆和 24 枚批头，取用后请按槽位归还。'),
    ('激光水平仪', '两线自校准，适合挂画和安装层板。'),
    ('小型工具箱', '含羊角锤、卷尺、钳子和绝缘胶带。'),
    ('折叠工作梯', '三步梯，展开后请确认安全扣完全锁定。'),
    ('瓷砖修边锉', '适合少量边缘修整，不用于整片切割。'),
    ('手持打气筒', '兼容美式和法式气嘴，附球针。'),
  ],
  ExchangeCategory.garden: [
    ('阳台育苗盘', '每套 24 格，已清洗晾干，可配合透明罩使用。'),
    ('长柄修枝剪', '适合修整拇指粗细以下的枝条。'),
    ('社区堆肥筛', '木框金属网，取用前请自备接料布。'),
    ('浇水壶两只', '细长壶嘴，适合窗台和高处花盆。'),
    ('园艺手套套装', '三种尺码各一双，已清洁。'),
    ('种子压穴板', '一次压出 20 个等距穴位，适合叶菜育苗。'),
    ('折叠晾晒网', '三层网面，可晾香草、种子和花材。'),
    ('土壤酸碱试纸', '剩余 18 条，附颜色对照说明。'),
  ],
  ExchangeCategory.kitchen: [
    ('手摇压面机', '可调 7 档厚度，附细面切刀。'),
    ('六升汤锅', '适合社区聚餐，电磁炉和燃气灶均可用。'),
    ('饼干模具盒', '含字母、数字和基础形状共 36 枚。'),
    ('保温饮料桶', '容量 8 升，带水龙头，不用于碳酸饮料。'),
    ('竹制蒸笼组', '直径 24 厘米，两层蒸笼和一个盖。'),
    ('厨房电子秤', '量程 5 公斤，精度 1 克，附新电池。'),
    ('手持打蛋器', '五档调速，附两组搅拌头。'),
    ('玻璃密封罐', '四只一组，适合短期存放干货。'),
  ],
  ExchangeCategory.reading: [
    ('儿童自然观察包', '含三本图鉴、放大镜和可擦记录板。'),
    ('城市散步书单', '六本独立出版物，按编号整套借还。'),
    ('大字版小说两册', '字号较大，适合长时间阅读。'),
    ('桌游规则参考册', '整理了 20 款常见桌游的中文规则。'),
    ('建筑入门图册', '以公共空间为主题，共四册。'),
    ('亲子共读布袋', '含三本绘本和一套故事顺序卡。'),
    ('植物拓印手册', '附本地常见叶片索引，不含耗材。'),
    ('旧物修复资料夹', '收录木器、织物和小家电的基础检查表。'),
  ],
  ExchangeCategory.eventKit: [
    ('折叠指示牌', 'A3 竖版四块，可换纸张，附配重底座。'),
    ('桌面名牌夹', '透明夹 24 个，适合工作坊和圆桌讨论。'),
    ('便携扩音器', '含头戴麦克风，适合 30 人以内空间。'),
    ('彩色夹板套装', 'A4 夹板 12 个，六种颜色。'),
    ('投票圆点贴', '六色共约 300 枚，用于现场共创。'),
    ('延长线收纳箱', '含三条 5 米延长线和安全胶带。'),
    ('活动签到板', '两块硬板、号码牌和可擦笔。'),
    ('可折叠背景布', '暖灰色 2×3 米，适合小型记录拍摄。'),
  ],
  ExchangeCategory.skill: [
    ('自行车基础检查', '可协助检查胎压、刹车和链条，不进行零件更换。'),
    ('旧衣纽扣修补', '带上衣物和备用纽扣，现场完成基础缝补。'),
    ('手机照片整理', '一起建立相册和备份习惯，不接触账号密码。'),
    ('阳台香草养护', '根据光照和盆土情况给出一页养护建议。'),
    ('简历排版互助', '只调整信息层级和版式，不代写经历。'),
    ('家庭收纳标记', '协助设计一套可持续维护的标签规则。'),
    ('儿童桌游带领', '可带领一场 45 分钟的合作型桌游。'),
    ('小家电安全初检', '仅做外观和电源线检查，不拆机维修。'),
  ],
};
