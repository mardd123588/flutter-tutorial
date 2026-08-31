enum ArchiveCollection {
  photographs('photographs', '影像馆藏'),
  letters('letters', '书信手稿'),
  maps('maps', '地图测绘'),
  audio('audio', '声音档案'),
  newspapers('newspapers', '地方报刊'),
  objects('objects', '实物记录');

  const ArchiveCollection(this.slug, this.label);

  final String slug;
  final String label;
}

enum ArchiveEra {
  era1950s('era-1950s', '1950 年代', 1950),
  era1960s('era-1960s', '1960 年代', 1960),
  era1970s('era-1970s', '1970 年代', 1970),
  era1980s('era-1980s', '1980 年代', 1980),
  era1990s('era-1990s', '1990 年代', 1990),
  era2000s('era-2000s', '2000 年代', 2000),
  era2010s('era-2010s', '2010 年代', 2010),
  era2020s('era-2020s', '2020 年代', 2020);

  const ArchiveEra(this.slug, this.label, this.startYear);

  final String slug;
  final String label;
  final int startYear;
}

enum ArchiveAccess {
  open('open', '开放阅览'),
  readingRoom('reading-room', '阅览室查看'),
  excerpt('excerpt', '仅开放节选'),
  restricted('restricted', '限制查阅');

  const ArchiveAccess(this.slug, this.label);

  final String slug;
  final String label;
}

enum ArchiveMedium {
  photograph('照片'),
  manuscript('手稿'),
  plan('图纸'),
  recording('录音'),
  clipping('剪报'),
  objectCard('实物卡');

  const ArchiveMedium(this.label);

  final String label;
}

class ArchiveRecord {
  const ArchiveRecord({
    required this.id,
    required this.title,
    required this.year,
    required this.era,
    required this.collection,
    required this.access,
    required this.medium,
    required this.people,
    required this.summary,
    required this.thumbnailSeed,
  });

  final String id;
  final String title;
  final int year;
  final ArchiveEra era;
  final ArchiveCollection collection;
  final ArchiveAccess access;
  final ArchiveMedium medium;
  final List<String> people;
  final String summary;
  final int thumbnailSeed;

  String get searchText => '$title ${people.join(' ')} $summary';
}

int compareArchiveIdentity(ArchiveRecord left, ArchiveRecord right) {
  final year = left.year.compareTo(right.year);
  return year != 0 ? year : left.id.compareTo(right.id);
}

int compareArchiveTitle(ArchiveRecord left, ArchiveRecord right) {
  final title = left.title.compareTo(right.title);
  return title != 0 ? title : left.id.compareTo(right.id);
}

enum ComparisonOutcome { added, duplicate, missing, limitReached }

class ComparisonResult {
  const ComparisonResult(this.comparison, this.outcome);

  final ArchiveComparison comparison;
  final ComparisonOutcome outcome;
}

class ArchiveComparison {
  const ArchiveComparison([this.ids = const []]);

  final List<String> ids;

  ComparisonResult add(String id, Set<String> knownIds) {
    if (!knownIds.contains(id)) {
      return ComparisonResult(this, ComparisonOutcome.missing);
    }
    if (ids.contains(id)) {
      return ComparisonResult(this, ComparisonOutcome.duplicate);
    }
    if (ids.length == 3) {
      return ComparisonResult(this, ComparisonOutcome.limitReached);
    }
    return ComparisonResult(
      ArchiveComparison(List.unmodifiable([...ids, id])),
      ComparisonOutcome.added,
    );
  }

  ArchiveComparison remove(String id) =>
      ArchiveComparison(List.unmodifiable(ids.where((value) => value != id)));
}
