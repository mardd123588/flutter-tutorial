import '../domain/archive_models.dart';
import '../domain/archive_query.dart';

abstract interface class ArchiveRepository {
  Future<List<ArchiveRecord>> fetchRecords();
}

class ArchiveLoadException implements Exception {
  const ArchiveLoadException();
}

class FixtureArchiveRepository implements ArchiveRepository {
  @override
  Future<List<ArchiveRecord>> fetchRecords() async => fixtureArchiveRecords;
}

const _titleSubjects = [
  '河岸夜校合影',
  '码头工人名册',
  '旧城水系测绘',
  '雨季广播手记',
  '街区更新剪报',
  '公共花园记录',
  '桥下剧场节目单',
  '渡口声音访谈',
  '社区食堂账册',
  '沿河骑行调查',
];

const _people = ['林岚', '周谨', '何川', '孟秋', '顾屿', '陶然', '闻溪', '许澄'];

final List<ArchiveRecord> fixtureArchiveRecords = List.unmodifiable(
  <ArchiveRecord>[
    for (var index = 0; index < 120; index++)
      ArchiveRecord(
        id: 'record-${(index + 1).toString().padLeft(3, '0')}',
        title:
            '${_titleSubjects[index % _titleSubjects.length]} · ${index + 1}',
        year: ArchiveEra.values[index % 8].startYear + ((index ~/ 8) % 10),
        era: ArchiveEra.values[index % 8],
        collection: ArchiveCollection.values[(index ~/ 8) % 6],
        access: ArchiveAccess.values[(index ~/ 24) % 4],
        medium:
            ArchiveMedium.values[(index ~/ 8) % ArchiveMedium.values.length],
        people: [
          _people[index % _people.length],
          _people[(index + 3) % _people.length],
        ],
        summary: '记录河岸与街区在第 ${index + 1} 次整理中的人物、地点和使用变化。',
        thumbnailSeed: 7919 + index * 37,
      ),
  ]..sort(compareArchiveIdentity),
);

List<ArchiveRecord> filterArchiveRecords(
  List<ArchiveRecord> records,
  ArchiveQuery query,
) {
  final search = query.search.toLowerCase();
  final result = records.where((record) {
    return (search.isEmpty ||
            record.searchText.toLowerCase().contains(search)) &&
        (query.era == null || record.era == query.era) &&
        (query.collection == null || record.collection == query.collection) &&
        (query.access == null || record.access == query.access);
  }).toList();
  result.sort(
    query.sort == ArchiveSort.title
        ? compareArchiveTitle
        : compareArchiveIdentity,
  );
  return List.unmodifiable(result);
}
