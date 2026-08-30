import '../domain/schedule_conflict_policy.dart';
import '../domain/schedule_models.dart';
import 'schedule_storage_service.dart';
import 'workshop_catalog_service.dart';

sealed class ScheduleResult<T> {
  const ScheduleResult();
}

class ScheduleSuccess<T> extends ScheduleResult<T> {
  const ScheduleSuccess(this.value);

  final T value;
}

class ScheduleFailureResult<T> extends ScheduleResult<T> {
  const ScheduleFailureResult(this.failure);

  final ScheduleFailure failure;
}

sealed class ScheduleFailure {
  const ScheduleFailure();
}

class ScheduleCatalogFailure extends ScheduleFailure {
  const ScheduleCatalogFailure();
}

class ScheduleStorageFailure extends ScheduleFailure {
  const ScheduleStorageFailure();
}

class ScheduleValidationFailure extends ScheduleFailure {
  const ScheduleValidationFailure(this.conflicts);

  final List<ScheduleConflict> conflicts;
}

class ScheduleConflictFailure extends ScheduleFailure {
  const ScheduleConflictFailure(this.conflicts);

  final List<ScheduleConflict> conflicts;
}

class ScheduleNotFoundFailure extends ScheduleFailure {
  const ScheduleNotFoundFailure(this.id);

  final String id;
}

abstract interface class ScheduleRepository {
  Future<ScheduleResult<WorkshopCatalog>> loadCatalog();

  Stream<ScheduleResult<List<ScheduleEntry>>> watchSchedule(
    ScheduleQuery query,
  );

  Future<ScheduleResult<ScheduleEntry>> findEntry(String id);

  Future<ScheduleResult<ScheduleEntry>> save(ScheduleEntry entry);

  Future<ScheduleResult<void>> restoreDemoData();
}

class LocalScheduleRepository implements ScheduleRepository {
  LocalScheduleRepository({
    required this.catalogService,
    required this.storage,
    required this.conflictPolicy,
  });

  final WorkshopCatalogService catalogService;
  final ScheduleStorageService storage;
  final ScheduleConflictPolicy conflictPolicy;
  WorkshopCatalog? _catalog;

  @override
  Future<ScheduleResult<WorkshopCatalog>> loadCatalog() async {
    var catalog = _catalog;
    if (catalog == null) {
      try {
        catalog = await catalogService.load();
        _catalog = catalog;
      } on Object {
        return const ScheduleFailureResult(ScheduleCatalogFailure());
      }
    }
    try {
      await storage.ensureSeeded(catalog.initialSchedule);
    } on Object {
      return const ScheduleFailureResult(ScheduleStorageFailure());
    }
    return ScheduleSuccess(catalog);
  }

  @override
  Stream<ScheduleResult<List<ScheduleEntry>>> watchSchedule(
    ScheduleQuery query,
  ) async* {
    final ready = await loadCatalog();
    if (ready case ScheduleFailureResult<WorkshopCatalog>(:final failure)) {
      yield ScheduleFailureResult(failure);
      return;
    }
    try {
      await for (final entries in storage.watchEntries(query)) {
        yield ScheduleSuccess(entries);
      }
    } on Object {
      yield const ScheduleFailureResult(ScheduleStorageFailure());
    }
  }

  @override
  Future<ScheduleResult<ScheduleEntry>> findEntry(String id) async {
    final ready = await loadCatalog();
    if (ready case ScheduleFailureResult<WorkshopCatalog>(:final failure)) {
      return ScheduleFailureResult(failure);
    }
    try {
      final entry = await storage.findEntry(id);
      return entry == null
          ? ScheduleFailureResult(ScheduleNotFoundFailure(id))
          : ScheduleSuccess(entry);
    } on Object {
      return const ScheduleFailureResult(ScheduleStorageFailure());
    }
  }

  @override
  Future<ScheduleResult<ScheduleEntry>> save(ScheduleEntry entry) async {
    final ready = await loadCatalog();
    if (ready case ScheduleFailureResult<WorkshopCatalog>(:final failure)) {
      return ScheduleFailureResult(failure);
    }
    final catalog = (ready as ScheduleSuccess<WorkshopCatalog>).value;
    try {
      final entries = await storage.readEntries();
      final conflicts = conflictPolicy.evaluate(
        candidate: entry,
        existingEntries: entries,
        validDayIds: catalog.days.map((day) => day.id).toSet(),
        workshopIds: catalog.workshops.map((workshop) => workshop.id).toSet(),
        instructorIds: catalog.instructors
            .map((instructor) => instructor.id)
            .toSet(),
        venueCapacities: {
          for (final venue in catalog.venues) venue.id: venue.capacity,
        },
      );
      final validation = conflicts
          .where((conflict) => _validationKinds.contains(conflict.kind))
          .toList(growable: false);
      if (validation.isNotEmpty) {
        return ScheduleFailureResult(ScheduleValidationFailure(validation));
      }
      if (conflicts.isNotEmpty) {
        return ScheduleFailureResult(ScheduleConflictFailure(conflicts));
      }
      await storage.upsertEntry(entry);
      return ScheduleSuccess(entry);
    } on Object {
      return const ScheduleFailureResult(ScheduleStorageFailure());
    }
  }

  @override
  Future<ScheduleResult<void>> restoreDemoData() async {
    final ready = await loadCatalog();
    if (ready case ScheduleFailureResult<WorkshopCatalog>(:final failure)) {
      return ScheduleFailureResult(failure);
    }
    final catalog = (ready as ScheduleSuccess<WorkshopCatalog>).value;
    try {
      await storage.restoreEntries(catalog.initialSchedule);
      return const ScheduleSuccess(null);
    } on Object {
      return const ScheduleFailureResult(ScheduleStorageFailure());
    }
  }
}

const _validationKinds = {
  ScheduleConflictKind.invalidDay,
  ScheduleConflictKind.invalidTimeRange,
  ScheduleConflictKind.outsideOperatingHours,
  ScheduleConflictKind.unknownWorkshop,
  ScheduleConflictKind.unknownVenue,
  ScheduleConflictKind.unknownInstructor,
};
