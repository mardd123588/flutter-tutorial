import 'package:digital_archive_browser/src/data/archive_repository.dart';
import 'package:digital_archive_browser/src/domain/archive_models.dart';
import 'package:digital_archive_browser/src/domain/archive_query.dart';
import 'package:digital_archive_browser/src/state/archive_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('repository override and query families stay isolated', () async {
    final container = ProviderContainer(
      retry: noArchiveProviderRetry,
      overrides: [
        archiveRepositoryProvider.overrideWithValue(_SmallRepository()),
      ],
    );
    addTearDown(container.dispose);

    final records = await container.read(archiveRecordsProvider.future);
    expect(records, hasLength(4));
    expect(
      container
          .read(filteredArchiveProvider(const ArchiveQuery(search: '河岸')))
          .requireValue,
      isNotEmpty,
    );
    expect(
      container
          .read(filteredArchiveProvider(const ArchiveQuery(search: '不存在')))
          .requireValue,
      isEmpty,
    );
  });
}

class _SmallRepository implements ArchiveRepository {
  @override
  Future<List<ArchiveRecord>> fetchRecords() async =>
      fixtureArchiveRecords.take(4).toList(growable: false);
}
