import 'package:digital_archive_browser/src/data/archive_repository.dart';
import 'package:digital_archive_browser/src/domain/archive_models.dart';
import 'package:digital_archive_browser/src/domain/archive_query.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late List<ArchiveRecord> records;

  setUp(() async {
    records = await FixtureArchiveRepository().fetchRecords();
  });

  test('filters by intersection and applies a stable title sort', () {
    final query = ArchiveQuery(
      search: '河岸',
      era: ArchiveEra.era1990s,
      collection: ArchiveCollection.maps,
      access: ArchiveAccess.open,
      sort: ArchiveSort.title,
    );
    final result = filterArchiveRecords(records, query);

    expect(result, isNotEmpty);
    expect(
      result.every(
        (record) =>
            record.searchText.contains('河岸') &&
            record.era == query.era &&
            record.collection == query.collection &&
            record.access == query.access,
      ),
      isTrue,
    );
    expect(
      result,
      orderedEquals(<ArchiveRecord>[...result]..sort(compareArchiveTitle)),
    );
  });

  test('comparison rejects duplicates, missing IDs, and a fourth record', () {
    var state = const ArchiveComparison();
    final knownIds = records.map((record) => record.id).toSet();

    for (final record in records.take(3)) {
      final result = state.add(record.id, knownIds);
      expect(result.outcome, ComparisonOutcome.added);
      state = result.comparison;
    }
    expect(
      state.add(records.first.id, knownIds).outcome,
      ComparisonOutcome.duplicate,
    );
    expect(
      state.add('record-missing', knownIds).outcome,
      ComparisonOutcome.missing,
    );
    expect(
      state.add(records[3].id, knownIds).outcome,
      ComparisonOutcome.limitReached,
    );
    expect(state.ids, hasLength(3));
  });
}
