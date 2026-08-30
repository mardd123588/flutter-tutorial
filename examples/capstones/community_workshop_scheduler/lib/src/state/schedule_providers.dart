import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../data/schedule_database.dart';
import '../data/schedule_repository.dart';
import '../data/schedule_storage_service.dart';
import '../data/workshop_catalog_service.dart';
import '../domain/schedule_conflict_policy.dart';
import '../domain/schedule_models.dart';

part 'schedule_providers.g.dart';

final workshopCatalogServiceProvider = Provider<WorkshopCatalogService>(
  (ref) => const FixtureWorkshopCatalogService(),
);

final scheduleStorageServiceProvider = Provider<ScheduleStorageService>((ref) {
  final database = ScheduleDatabase.defaults();
  ref.onDispose(database.close);
  return database;
});

final scheduleRepositoryProvider = Provider<ScheduleRepository>((ref) {
  return LocalScheduleRepository(
    catalogService: ref.watch(workshopCatalogServiceProvider),
    storage: ref.watch(scheduleStorageServiceProvider),
    conflictPolicy: const ScheduleConflictPolicy(),
  );
});

final workshopCatalogProvider =
    AsyncNotifierProvider<
      WorkshopCatalogController,
      ScheduleResult<WorkshopCatalog>
    >(WorkshopCatalogController.new, retry: noProviderRetry);

final sessionEntryProvider = FutureProvider.autoDispose
    .family<ScheduleResult<ScheduleEntry>, String>(
      (ref, id) => ref.watch(scheduleRepositoryProvider).findEntry(id),
      retry: noProviderRetry,
    );

class WorkshopCatalogController
    extends AsyncNotifier<ScheduleResult<WorkshopCatalog>> {
  @override
  Future<ScheduleResult<WorkshopCatalog>> build() {
    return ref.watch(scheduleRepositoryProvider).loadCatalog();
  }

  void retry() => ref.invalidateSelf();
}

@riverpod
Stream<ScheduleResult<List<ScheduleEntry>>> filteredSchedule(
  Ref ref, {
  String? dayId,
  String? venueId,
  String? instructorId,
}) {
  final query = ScheduleQuery(
    dayId: dayId,
    venueId: venueId,
    instructorId: instructorId,
  );
  return ref.watch(scheduleRepositoryProvider).watchSchedule(query);
}

final workshopEditorProvider =
    NotifierProvider.autoDispose<WorkshopEditorController, WorkshopEditorState>(
      WorkshopEditorController.new,
      retry: noProviderRetry,
    );

class WorkshopEditorState {
  const WorkshopEditorState({
    this.draft,
    this.isSaving = false,
    this.conflicts = const [],
    this.failure,
    this.savedEntry,
  });

  final ScheduleEntry? draft;
  final bool isSaving;
  final List<ScheduleConflict> conflicts;
  final ScheduleFailure? failure;
  final ScheduleEntry? savedEntry;
}

class WorkshopEditorController extends Notifier<WorkshopEditorState> {
  @override
  WorkshopEditorState build() => const WorkshopEditorState();

  void begin(ScheduleEntry draft) {
    state = WorkshopEditorState(draft: draft);
  }

  void update(ScheduleEntry draft) {
    state = WorkshopEditorState(draft: draft);
  }

  Future<ScheduleResult<ScheduleEntry>?> save() async {
    final draft = state.draft;
    if (draft == null || state.isSaving) return null;
    state = WorkshopEditorState(draft: draft, isSaving: true);
    final result = await ref.read(scheduleRepositoryProvider).save(draft);
    if (!ref.mounted) return result;
    switch (result) {
      case ScheduleSuccess<ScheduleEntry>(:final value):
        state = WorkshopEditorState(draft: value, savedEntry: value);
      case ScheduleFailureResult<ScheduleEntry>(:final failure):
        final conflicts = switch (failure) {
          ScheduleConflictFailure(:final conflicts) => conflicts,
          ScheduleValidationFailure(:final conflicts) => conflicts,
          _ => const <ScheduleConflict>[],
        };
        state = WorkshopEditorState(
          draft: draft,
          conflicts: conflicts,
          failure: failure,
        );
    }
    return result;
  }
}

Duration? noProviderRetry(int retryCount, Object error) => null;
