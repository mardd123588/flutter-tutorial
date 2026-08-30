import 'dart:convert';

import 'event_feed.dart';

const fixtureGeneratedAt = '2026-08-30T09:00:00+08:00';

const fixtureEvents = <Map<String, Object?>>[
  {
    'id': 'river-listening-walk',
    'title': '河岸听觉散步',
    'venue': '东岸旧泵站',
    'district': '东岸',
    'starts_at': '2026-09-05T18:30:00+08:00',
    'price_label': '预约免费',
    'summary': '沿旧泵站、堤岸与渡口记录傍晚的机械声和水声。',
    'tags': ['步行', '声音', '户外'],
    'signal': 86,
  },
  {
    'id': 'night-print-lab',
    'title': '夜间双色印刷实验室',
    'venue': '老城纸品仓',
    'district': '老城',
    'starts_at': '2026-09-06T19:00:00+08:00',
    'price_label': '¥68',
    'summary': '用两种专色制作一张城市观察海报，材料由现场提供。',
    'tags': ['印刷', '工作坊', '夜间'],
    'signal': 92,
  },
  {
    'id': 'station-roof-film',
    'title': '站房屋顶短片夜',
    'venue': '西站三号库',
    'district': '西站',
    'starts_at': '2026-09-07T20:00:00+08:00',
    'price_label': '¥35',
    'summary': '六部城市短片连续放映，场间保留十分钟交流。',
    'tags': ['电影', '屋顶', '夜间'],
    'signal': 78,
  },
  {
    'id': 'old-town-repair-table',
    'title': '旧物修理长桌',
    'venue': '老城市民工坊',
    'district': '老城',
    'starts_at': '2026-09-08T14:00:00+08:00',
    'price_label': '预约免费',
    'summary': '带一件小型故障物品到共享长桌，现场提供基础工具。',
    'tags': ['修理', '社区', '工作坊'],
    'signal': 71,
  },
  {
    'id': 'east-bank-seed-swap',
    'title': '秋季种子交换所',
    'venue': '东岸温室前厅',
    'district': '东岸',
    'starts_at': '2026-09-09T10:30:00+08:00',
    'price_label': '自由交换',
    'summary': '按生长环境整理种子，并交换一份自己的种植记录。',
    'tags': ['植物', '交换', '家庭'],
    'signal': 64,
  },
  {
    'id': 'west-station-light-map',
    'title': '西站灯光地图采集',
    'venue': '西站信号楼',
    'district': '西站',
    'starts_at': '2026-09-10T18:45:00+08:00',
    'price_label': '¥20',
    'summary': '记录站区照明的颜色、间隔和盲区，制作一张夜行地图。',
    'tags': ['地图', '摄影', '夜间'],
    'signal': 83,
  },
];

String fixturePayload({String query = ''}) {
  final normalized = query.trim().toLowerCase();
  final events = normalized.isEmpty
      ? fixtureEvents
      : fixtureEvents
            .where((event) {
              final haystack = [
                event['title'],
                event['venue'],
                event['district'],
                event['summary'],
                ...(event['tags']! as List<Object?>),
              ].join(' ').toLowerCase();
              return haystack.contains(normalized);
            })
            .toList(growable: false);
  return jsonEncode({
    'generated_at': fixtureGeneratedAt,
    'events': events,
    'teaching_fixture': true,
  });
}

EventFeed bundledFixtureFeed() => EventFeed.fromJsonString(fixturePayload());
