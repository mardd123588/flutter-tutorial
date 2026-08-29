import 'package:flutter/foundation.dart';

@immutable
class RhythmEntry {
  const RhythmEntry({
    required this.id,
    required this.time,
    required this.title,
    required this.description,
    required this.minutesFromStart,
    required this.durationMinutes,
    required this.tone,
  });

  final String id;
  final String time;
  final String title;
  final String description;
  final int minutesFromStart;
  final int durationMinutes;
  final RhythmTone tone;
}

enum RhythmTone { rise, focus, pause, close }

const dailyRhythm = <RhythmEntry>[
  RhythmEntry(
    id: 'morning-review',
    time: '08:10',
    title: '晨间校准',
    description: '先看昨天留下的三条记录，再决定今天真正需要完成的事。',
    minutesFromStart: 70,
    durationMinutes: 25,
    tone: RhythmTone.rise,
  ),
  RhythmEntry(
    id: 'deep-work',
    time: '09:00',
    title: '第一段专注',
    description: '关闭消息提醒，只处理需要完整上下文的任务。',
    minutesFromStart: 120,
    durationMinutes: 90,
    tone: RhythmTone.focus,
  ),
  RhythmEntry(
    id: 'walk-break',
    time: '10:45',
    title: '离屏走动',
    description: '离开桌面十五分钟，让视线和注意力都换一个距离。',
    minutesFromStart: 225,
    durationMinutes: 15,
    tone: RhythmTone.pause,
  ),
  RhythmEntry(
    id: 'afternoon-focus',
    time: '14:00',
    title: '午后专注',
    description: '把范围压到一个可交付结果，结束前留五分钟记录下一步。',
    minutesFromStart: 420,
    durationMinutes: 75,
    tone: RhythmTone.focus,
  ),
  RhythmEntry(
    id: 'day-close',
    time: '17:20',
    title: '收整桌面',
    description: '归档完成项，写下明天开始时不需要重新思考的第一步。',
    minutesFromStart: 620,
    durationMinutes: 20,
    tone: RhythmTone.close,
  ),
];

double sundialPositionFor(RhythmEntry entry) {
  const visibleMinutes = 720;
  return (entry.minutesFromStart / visibleMinutes).clamp(0, 1);
}
