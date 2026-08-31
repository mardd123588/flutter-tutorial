import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/archive_repository.dart';
import '../domain/archive_models.dart';
import '../domain/archive_query.dart';

// #region archive-provider-graph
final archiveRepositoryProvider = Provider<ArchiveRepository>(
  (ref) => FixtureArchiveRepository(),
);

final archiveRecordsProvider = FutureProvider<List<ArchiveRecord>>((ref) async {
  try {
    return await ref.watch(archiveRepositoryProvider).fetchRecords();
  } on ArchiveLoadException {
    rethrow;
  } catch (_) {
    throw const ArchiveLoadException();
  }
});

final archiveQueryProvider = Provider.family<ArchiveQuery, Uri>(
  (ref, uri) => ArchiveQuery.fromUri(uri),
);

final filteredArchiveProvider =
    Provider.family<AsyncValue<List<ArchiveRecord>>, ArchiveQuery>(
      (ref, query) => ref
          .watch(archiveRecordsProvider)
          .whenData((records) => filterArchiveRecords(records, query)),
    );

final archiveComparisonProvider =
    NotifierProvider<ArchiveComparisonController, ArchiveComparison>(
      ArchiveComparisonController.new,
    );

class ArchiveComparisonController extends Notifier<ArchiveComparison> {
  @override
  ArchiveComparison build() => const ArchiveComparison();

  ComparisonOutcome add(String id, Set<String> knownIds) {
    final result = state.add(id, knownIds);
    state = result.comparison;
    return result.outcome;
  }

  void remove(String id) {
    state = state.remove(id);
  }

  void clear() {
    state = const ArchiveComparison();
  }
}

Duration? noArchiveProviderRetry(int retryCount, Object error) => null;
// #endregion archive-provider-graph
