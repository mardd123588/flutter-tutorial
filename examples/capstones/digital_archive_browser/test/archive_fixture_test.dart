import 'package:digital_archive_browser/src/data/archive_repository.dart';
import 'package:digital_archive_browser/src/domain/archive_models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('fixture has stable dimensions and unique identities', () async {
    final records = await FixtureArchiveRepository().fetchRecords();

    expect(records, hasLength(120));
    expect(records.map((record) => record.id).toSet(), hasLength(120));
    expect(records.map((record) => record.collection).toSet(), hasLength(6));
    expect(records.map((record) => record.era).toSet(), hasLength(8));
    expect(records.map((record) => record.access).toSet(), hasLength(4));
    expect(
      records,
      orderedEquals(<ArchiveRecord>[...records]..sort(compareArchiveIdentity)),
    );
  });
}
