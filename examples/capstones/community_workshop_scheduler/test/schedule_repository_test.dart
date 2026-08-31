import 'dart:async';

import 'package:community_workshop_scheduler/src/data/schedule_repository.dart';
import 'package:community_workshop_scheduler/src/data/schedule_storage_service.dart';
import 'package:community_workshop_scheduler/src/data/workshop_catalog_service.dart';
import 'package:community_workshop_scheduler/src/domain/schedule_conflict_policy.dart';
import 'package:community_workshop_scheduler/src/domain/schedule_models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'rejects a save with every conflict and leaves storage unchanged',
    () async {
      final storage = MemoryScheduleStorage();
      final repository = LocalScheduleRepository(
        catalogService: const FixtureWorkshopCatalogService(),
        storage: storage,
        conflictPolicy: const ScheduleConflictPolicy(),
      );
      const candidate = ScheduleEntry(
        id: 'session-new',
        workshopId: 'workshop-mending',
        instructorId: 'instructor-lin',
        venueId: 'venue-forge',
        dayId: 'day-sat',
        startMinute: 600,
        endMinute: 660,
        expectedAttendees: 30,
      );

      final result = await repository.save(candidate);

      expect(result, isA<ScheduleFailureResult<ScheduleEntry>>());
      final failure = (result as ScheduleFailureResult<ScheduleEntry>).failure;
      expect(failure, isA<ScheduleConflictFailure>());
      expect(
        (failure as ScheduleConflictFailure).conflicts.map(
          (conflict) => conflict.kind,
        ),
        const [
          ScheduleConflictKind.capacityExceeded,
          ScheduleConflictKind.venueOverlap,
          ScheduleConflictKind.instructorOverlap,
        ],
      );
      expect(storage.upsertCount, 0);
    },
  );

  test(
    'successful writes and restore arrive through the repository stream',
    () async {
      final storage = MemoryScheduleStorage();
      final repository = LocalScheduleRepository(
        catalogService: const FixtureWorkshopCatalogService(),
        storage: storage,
        conflictPolicy: const ScheduleConflictPolicy(),
      );
      const added = ScheduleEntry(
        id: 'session-added',
        workshopId: 'workshop-mending',
        instructorId: 'instructor-he',
        venueId: 'venue-hall',
        dayId: 'day-sat',
        startMinute: 780,
        endMinute: 840,
        expectedAttendees: 20,
      );
      final updated = repository
          .watchSchedule(const ScheduleQuery())
          .firstWhere(
            (result) =>
                result is ScheduleSuccess<List<ScheduleEntry>> &&
                result.value.any((entry) => entry.id == added.id),
          );

      expect(
        await repository.save(added),
        isA<ScheduleSuccess<ScheduleEntry>>(),
      );
      expect(
        (await updated as ScheduleSuccess<List<ScheduleEntry>>).value,
        contains(added),
      );

      final restored = repository
          .watchSchedule(const ScheduleQuery())
          .firstWhere(
            (result) =>
                result is ScheduleSuccess<List<ScheduleEntry>> &&
                result.value.length == 10,
          );
      expect(await repository.restoreDemoData(), isA<ScheduleSuccess<void>>());
      expect(
        (await restored as ScheduleSuccess<List<ScheduleEntry>>).value,
        fixtureWorkshopCatalog.initialSchedule,
      );
    },
  );

  test('maps storage exceptions without leaking their text', () async {
    final repository = LocalScheduleRepository(
      catalogService: const FixtureWorkshopCatalogService(),
      storage: ThrowingScheduleStorage(),
      conflictPolicy: const ScheduleConflictPolicy(),
    );

    final result = await repository.save(
      fixtureWorkshopCatalog.initialSchedule.first,
    );

    expect(result, isA<ScheduleFailureResult<ScheduleEntry>>());
    expect(
      (result as ScheduleFailureResult<ScheduleEntry>).failure,
      isA<ScheduleStorageFailure>(),
    );
    expect(result.toString(), isNot(contains('database password')));
  });

  test('does not turn programming errors into storage failures', () async {
    final repository = LocalScheduleRepository(
      catalogService: const FixtureWorkshopCatalogService(),
      storage: ErrorScheduleStorage(),
      conflictPolicy: const ScheduleConflictPolicy(),
    );

    await expectLater(
      repository.save(fixtureWorkshopCatalog.initialSchedule.first),
      throwsStateError,
    );
  });
}

class MemoryScheduleStorage implements ScheduleStorageService {
  final _changes = StreamController<List<ScheduleEntry>>.broadcast();
  final List<ScheduleEntry> _entries = [];
  var upsertCount = 0;

  @override
  Future<void> ensureSeeded(List<ScheduleEntry> entries) async {
    if (_entries.isEmpty) _entries.addAll(entries);
  }

  @override
  Future<ScheduleEntry?> findEntry(String id) async {
    return _entries.where((entry) => entry.id == id).firstOrNull;
  }

  @override
  Future<List<ScheduleEntry>> readEntries() async => List.of(_entries);

  @override
  Future<void> restoreEntries(List<ScheduleEntry> entries) async {
    _entries
      ..clear()
      ..addAll(entries);
    _changes.add(List.of(_entries));
  }

  @override
  Future<void> upsertEntry(ScheduleEntry entry) async {
    upsertCount += 1;
    _entries.removeWhere((existing) => existing.id == entry.id);
    _entries.add(entry);
    _changes.add(List.of(_entries));
  }

  @override
  Stream<List<ScheduleEntry>> watchEntries(ScheduleQuery query) async* {
    yield _entries.where(query.matches).toList();
    yield* _changes.stream.map(
      (entries) => entries.where(query.matches).toList(),
    );
  }
}

class ThrowingScheduleStorage extends MemoryScheduleStorage {
  @override
  Future<List<ScheduleEntry>> readEntries() {
    throw Exception('database password should stay private');
  }
}

class ErrorScheduleStorage extends MemoryScheduleStorage {
  @override
  Future<List<ScheduleEntry>> readEntries() {
    throw StateError('broken invariant');
  }
}
