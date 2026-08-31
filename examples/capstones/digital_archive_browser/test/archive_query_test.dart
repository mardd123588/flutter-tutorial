import 'package:digital_archive_browser/src/domain/archive_models.dart';
import 'package:digital_archive_browser/src/domain/archive_query.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // #region archive-query-round-trip-test
  test('normalizes and round-trips every URL-owned field', () {
    final query = ArchiveQuery.fromUri(
      Uri.parse(
        '/archive?q=%20%E6%B2%B3%E5%B2%B8%20%20%E5%AD%A6%E6%A0%A1%20'
        '&era=era-1990s&collection=maps&access=open'
        '&sort=title&view=grid',
      ),
    );

    expect(query.search, '河岸 学校');
    expect(query.era, ArchiveEra.era1990s);
    expect(query.collection, ArchiveCollection.maps);
    expect(query.access, ArchiveAccess.open);
    expect(query.sort, ArchiveSort.title);
    expect(query.view, ArchiveView.grid);
    expect(ArchiveQuery.fromUri(query.toUri()), query);
  });
  // #endregion archive-query-round-trip-test

  test('drops invalid and duplicate values deterministically', () {
    final query = ArchiveQuery.fromUri(
      Uri.parse('/archive?era=bad&era=era-2000s&view=poster&sort=year'),
    );

    expect(query.era, isNull);
    expect(query.view, ArchiveView.list);
    expect(query.sort, ArchiveSort.year);
    expect(query.toUri().toString(), '/archive');
  });
}
