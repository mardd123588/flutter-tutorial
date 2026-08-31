enum TimelineTopic {
  ecology('生态复原'),
  engineering('工程治理'),
  community('社区共建'),
  memory('口述记忆');

  const TimelineTopic(this.label);

  final String label;
}

class TimelineEra {
  const TimelineEra({
    required this.id,
    required this.title,
    required this.startYear,
    required this.endYear,
    required this.summary,
  });

  final String id;
  final String title;
  final int startYear;
  final int endYear;
  final String summary;
}

class TimelineEvent {
  const TimelineEvent({
    required this.id,
    required this.eraId,
    required this.year,
    required this.sequence,
    required this.title,
    required this.summary,
    required this.topic,
  });

  final String id;
  final String eraId;
  final int year;
  final int sequence;
  final String title;
  final String summary;
  final TimelineTopic topic;
}

const timelineEras = <TimelineEra>[
  TimelineEra(
    id: 'blocked-river',
    title: '封堵之前',
    startYear: 1965,
    endYear: 1974,
    summary: '工业扩张压缩河道，居民仍用照片和手绘图保存旧岸线。',
  ),
  TimelineEra(
    id: 'first-dredging',
    title: '第一次清淤',
    startYear: 1975,
    endYear: 1984,
    summary: '治理从排洪工程开始，测绘数据第一次连续覆盖整段河岸。',
  ),
  TimelineEra(
    id: 'public-bank',
    title: '岸线回到人群',
    startYear: 1985,
    endYear: 1994,
    summary: '围墙逐段拆除，步道、菜场和码头重新连接沿岸生活。',
  ),
  TimelineEra(
    id: 'wetland-link',
    title: '湿地重新连通',
    startYear: 1995,
    endYear: 2004,
    summary: '支流、滩涂和雨水花园开始作为同一套生态系统维护。',
  ),
  TimelineEra(
    id: 'shared-stewardship',
    title: '共治试验',
    startYear: 2005,
    endYear: 2014,
    summary: '学校、商户和居民小组共同记录水质、物种和使用冲突。',
  ),
  TimelineEra(
    id: 'river-classroom',
    title: '河流成为课堂',
    startYear: 2015,
    endYear: 2024,
    summary: '开放数据、夜间观察和口述档案让修复过程持续可查。',
  ),
];

const _titlesByEra = <String, List<String>>{
  'blocked-river': [
    '最后一班摆渡靠岸',
    '旧堤照片完成编号',
    '染坊排口首次测绘',
    '居民手绘三条支沟',
    '木码头停止装卸',
    '鱼市迁出西岸',
    '雨季水位越过石阶',
    '铁路桥下形成淤塞',
    '河湾芦苇只剩一片',
    '学校保存水鸟标本',
    '工程队封闭北岸',
    '老船工录下潮汐口诀',
  ],
  'first-dredging': [
    '清淤船进入主河槽',
    '第一组断面桩落位',
    '排洪闸完成试开',
    '沿岸工厂改接管线',
    '桥墩淤泥分批清运',
    '雨量站开始逐日记录',
    '南岸护坡更换石料',
    '冬季低水位完成复测',
    '旧支沟恢复排水',
    '居民提出保留石阶',
    '水位警戒线重新标定',
    '十年测绘册完成归档',
  ],
  'public-bank': [
    '北岸围墙拆除百米',
    '临时菜场迁回河边',
    '旧码头改成观测台',
    '第一段慢行路开放',
    '工人俱乐部种下柳树',
    '桥下空间增设照明',
    '社区绘制安全水深图',
    '夏季戏水区划出边界',
    '石阶按原尺寸修复',
    '口述访谈记录摆渡故事',
    '两岸步道首次连通',
    '公共岸线纳入养护表',
  ],
  'wetland-link': [
    '东侧支流重新开口',
    '滩涂种植第一批莎草',
    '雨水花园接入街区',
    '水鸟调查改用固定样线',
    '混凝土护坡切出缓坡',
    '鱼类洄游通道完成',
    '枯水期保留浅水岛',
    '湿地学校开出观察课',
    '夜间照明避开繁殖地',
    '外来植物开始分区清理',
    '支流监测数据公开',
    '连续湿地带通过验收',
  ],
  'shared-stewardship': [
    '居民认领十二段岸线',
    '商户签署雨污分流约定',
    '学校建立每月水样日',
    '志愿者记录第一百种鸟',
    '河岸冲突改用公开议事',
    '夜跑路线避开静养区',
    '旧仓库变成修复工作站',
    '社区地图标出无障碍坡道',
    '暴雨后巡查首次联动',
    '商船限速写入管理规则',
    '口述档案向公众开放',
    '共治小组发布十年报告',
  ],
  'river-classroom': [
    '开放平台上线水质曲线',
    '学生制作河岸声音地图',
    '夜间昆虫观察固定路线',
    '旧闸房开放为资料室',
    '手机端发布无障碍导览',
    '极端降雨演练加入社区',
    '湿地碳汇开始年度盘点',
    '修复争议保留完整记录',
    '桥下展览展示工程剖面',
    '青年讲解员整理方言词',
    '沿岸学校共享课程包',
    '六十年长卷完成校订',
  ],
};

// #region timeline-fixture-filter
final List<TimelineEvent> timelineEvents = List.unmodifiable(
  <TimelineEvent>[
    for (final era in timelineEras)
      for (var index = 0; index < _titlesByEra[era.id]!.length; index++)
        TimelineEvent(
          id: '${era.id}-${(index + 1).toString().padLeft(2, '0')}',
          eraId: era.id,
          year: era.startYear + (index * 9 ~/ 11),
          sequence: index % 2,
          title: _titlesByEra[era.id]![index],
          summary: '${era.title}阶段的第 ${index + 1} 份档案，记录现场变化、参与者和后续影响。',
          topic: TimelineTopic.values[index % TimelineTopic.values.length],
        ),
  ]..sort((left, right) {
    final year = left.year.compareTo(right.year);
    if (year != 0) return year;
    final sequence = left.sequence.compareTo(right.sequence);
    if (sequence != 0) return sequence;
    return left.id.compareTo(right.id);
  }),
);

List<TimelineEvent> filterTimelineEvents(Set<TimelineTopic> selectedTopics) {
  if (selectedTopics.isEmpty) return timelineEvents;
  return List.unmodifiable(
    timelineEvents.where((event) => selectedTopics.contains(event.topic)),
  );
}
// #endregion timeline-fixture-filter
