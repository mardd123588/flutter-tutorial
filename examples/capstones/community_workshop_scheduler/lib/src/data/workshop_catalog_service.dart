import '../domain/schedule_models.dart';

abstract interface class WorkshopCatalogService {
  Future<WorkshopCatalog> load();
}

class FixtureWorkshopCatalogService implements WorkshopCatalogService {
  const FixtureWorkshopCatalogService();

  @override
  Future<WorkshopCatalog> load() async => fixtureWorkshopCatalog;
}

final fixtureWorkshopCatalog = WorkshopCatalog(
  days: [
    EventDay(id: 'day-sat', label: '周六 · 9月12日', date: DateTime(2026, 9, 12)),
    EventDay(id: 'day-sun', label: '周日 · 9月13日', date: DateTime(2026, 9, 13)),
  ],
  venues: const [
    Venue(
      id: 'venue-forge',
      name: '铸光工坊',
      capacity: 24,
      accessibility: ['无障碍入口', '感应环'],
    ),
    Venue(
      id: 'venue-river',
      name: '河岸教室',
      capacity: 36,
      accessibility: ['无障碍坡道', '可调节工作台'],
    ),
    Venue(
      id: 'venue-hall',
      name: '共享大厅',
      capacity: 64,
      accessibility: ['无障碍卫生间', '安静区'],
    ),
  ],
  instructors: const [
    Instructor(id: 'instructor-lin', name: '林玥', bio: '植物染与低废弃生活实践者。'),
    Instructor(id: 'instructor-zhou', name: '周栖云', bio: '声音采集与公共空间创作者。'),
    Instructor(id: 'instructor-tao', name: '陶然', bio: '社区档案与参与式地图研究者。'),
    Instructor(id: 'instructor-he', name: '何榛', bio: '修补、木作与工具共享组织者。'),
    Instructor(id: 'instructor-chen', name: '陈牧', bio: '家庭影像教育与定格动画讲师。'),
  ],
  workshops: const [
    Workshop(
      id: 'workshop-dye-map',
      title: '植物染社区地图',
      category: '材料实验',
      summary: '用厨房边角料染出一张可折叠的街区地图。',
    ),
    Workshop(
      id: 'workshop-sound-walk',
      title: '声音漫步工作室',
      category: '城市观察',
      summary: '采集河岸声音，再把它们排成一段三分钟声景。',
    ),
    Workshop(
      id: 'workshop-mending',
      title: '修补与再造',
      category: '循环生活',
      summary: '从一处破损开始，练习可见修补和材料判断。',
    ),
    Workshop(
      id: 'workshop-story-map',
      title: '社区故事地图',
      category: '公共叙事',
      summary: '把口述片段、地点和时间压进一张协作地图。',
    ),
    Workshop(
      id: 'workshop-wood',
      title: '微型木作：窗边搁架',
      category: '工具入门',
      summary: '完成测量、打磨和连接，做一只真正可用的小搁架。',
    ),
    Workshop(
      id: 'workshop-stop-motion',
      title: '家庭定格动画',
      category: '影像表达',
      summary: '用纸张与随身物品共同完成一段短动画。',
    ),
    Workshop(
      id: 'workshop-low-waste',
      title: '低废弃厨房实验',
      category: '食物设计',
      summary: '围绕一篮当季食材设计完整、少浪费的菜单。',
    ),
    Workshop(
      id: 'workshop-light',
      title: '夜间光影装置',
      category: '空间创作',
      summary: '用低亮度光源和半透明材料搭建临时装置。',
    ),
  ],
  initialSchedule: const [
    ScheduleEntry(
      id: 'session-01',
      workshopId: 'workshop-dye-map',
      instructorId: 'instructor-lin',
      venueId: 'venue-forge',
      dayId: 'day-sat',
      startMinute: 540,
      endMinute: 630,
      expectedAttendees: 20,
    ),
    ScheduleEntry(
      id: 'session-02',
      workshopId: 'workshop-sound-walk',
      instructorId: 'instructor-zhou',
      venueId: 'venue-river',
      dayId: 'day-sat',
      startMinute: 540,
      endMinute: 600,
      expectedAttendees: 28,
    ),
    ScheduleEntry(
      id: 'session-03',
      workshopId: 'workshop-story-map',
      instructorId: 'instructor-tao',
      venueId: 'venue-hall',
      dayId: 'day-sat',
      startMinute: 570,
      endMinute: 660,
      expectedAttendees: 42,
    ),
    ScheduleEntry(
      id: 'session-04',
      workshopId: 'workshop-mending',
      instructorId: 'instructor-he',
      venueId: 'venue-forge',
      dayId: 'day-sat',
      startMinute: 660,
      endMinute: 750,
      expectedAttendees: 18,
    ),
    ScheduleEntry(
      id: 'session-05',
      workshopId: 'workshop-stop-motion',
      instructorId: 'instructor-chen',
      venueId: 'venue-river',
      dayId: 'day-sat',
      startMinute: 660,
      endMinute: 750,
      expectedAttendees: 30,
    ),
    ScheduleEntry(
      id: 'session-06',
      workshopId: 'workshop-wood',
      instructorId: 'instructor-he',
      venueId: 'venue-forge',
      dayId: 'day-sun',
      startMinute: 540,
      endMinute: 630,
      expectedAttendees: 16,
    ),
    ScheduleEntry(
      id: 'session-07',
      workshopId: 'workshop-low-waste',
      instructorId: 'instructor-lin',
      venueId: 'venue-river',
      dayId: 'day-sun',
      startMinute: 570,
      endMinute: 660,
      expectedAttendees: 30,
    ),
    ScheduleEntry(
      id: 'session-08',
      workshopId: 'workshop-light',
      instructorId: 'instructor-zhou',
      venueId: 'venue-hall',
      dayId: 'day-sun',
      startMinute: 600,
      endMinute: 690,
      expectedAttendees: 46,
    ),
    ScheduleEntry(
      id: 'session-09',
      workshopId: 'workshop-story-map',
      instructorId: 'instructor-tao',
      venueId: 'venue-forge',
      dayId: 'day-sun',
      startMinute: 780,
      endMinute: 870,
      expectedAttendees: 22,
    ),
    ScheduleEntry(
      id: 'session-10',
      workshopId: 'workshop-stop-motion',
      instructorId: 'instructor-chen',
      venueId: 'venue-river',
      dayId: 'day-sun',
      startMinute: 840,
      endMinute: 930,
      expectedAttendees: 26,
    ),
  ],
);
