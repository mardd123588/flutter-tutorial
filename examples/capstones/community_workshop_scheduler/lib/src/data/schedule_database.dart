import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import '../domain/schedule_models.dart';
import 'schedule_storage_service.dart';

part 'schedule_database.g.dart';

class ScheduleRecords extends Table {
  TextColumn get entryId => text()();
  TextColumn get workshopId => text()();
  TextColumn get instructorId => text()();
  TextColumn get venueId => text()();
  TextColumn get dayId => text()();
  IntColumn get startMinute => integer()();
  IntColumn get endMinute => integer()();
  IntColumn get expectedAttendees => integer()();

  @override
  Set<Column<Object>> get primaryKey => {entryId};
}

class ScheduleSettings extends Table {
  TextColumn get settingKey => text()();
  TextColumn get settingValue => text()();

  @override
  Set<Column<Object>> get primaryKey => {settingKey};
}

@DriftDatabase(tables: [ScheduleRecords, ScheduleSettings])
class ScheduleDatabase extends _$ScheduleDatabase
    implements ScheduleStorageService {
  ScheduleDatabase(super.executor);

  ScheduleDatabase.defaults()
    : super(
        driftDatabase(
          name: 'community_workshop_scheduler',
          web: DriftWebOptions(
            sqlite3Wasm: Uri.parse('sqlite3.wasm'),
            driftWorker: Uri.parse('drift_worker.js'),
          ),
        ),
      );

  @override
  int get schemaVersion => 1;

  @override
  Future<void> ensureSeeded(List<ScheduleEntry> entries) {
    return transaction(() async {
      final marker =
          await (select(scheduleSettings)
                ..where((row) => row.settingKey.equals('fixture-seed')))
              .getSingleOrNull();
      if (marker != null) return;
      await batch((batch) {
        batch.insertAll(scheduleRecords, entries.map(_toCompanion).toList());
        batch.insert(
          scheduleSettings,
          ScheduleSettingsCompanion.insert(
            settingKey: 'fixture-seed',
            settingValue: '1',
          ),
        );
      });
    });
  }

  @override
  Stream<List<ScheduleEntry>> watchEntries(ScheduleQuery query) {
    final statement = select(scheduleRecords);
    if (query.dayId != null) {
      statement.where((row) => row.dayId.equals(query.dayId!));
    }
    if (query.venueId != null) {
      statement.where((row) => row.venueId.equals(query.venueId!));
    }
    if (query.instructorId != null) {
      statement.where((row) => row.instructorId.equals(query.instructorId!));
    }
    statement.orderBy(_entryOrder);
    return statement.watch().map(
      (rows) => rows.map(_fromRecord).toList(growable: false),
    );
  }

  @override
  Future<List<ScheduleEntry>> readEntries() async {
    final statement = select(scheduleRecords)..orderBy(_entryOrder);
    final rows = await statement.get();
    return rows.map(_fromRecord).toList(growable: false);
  }

  @override
  Future<ScheduleEntry?> findEntry(String id) async {
    final row = await (select(
      scheduleRecords,
    )..where((record) => record.entryId.equals(id))).getSingleOrNull();
    return row == null ? null : _fromRecord(row);
  }

  @override
  Future<void> upsertEntry(ScheduleEntry entry) {
    return into(scheduleRecords).insertOnConflictUpdate(_toCompanion(entry));
  }

  @override
  Future<void> restoreEntries(List<ScheduleEntry> entries) {
    return transaction(() async {
      await delete(scheduleRecords).go();
      await batch((batch) {
        batch.insertAll(scheduleRecords, entries.map(_toCompanion).toList());
        batch.insert(
          scheduleSettings,
          ScheduleSettingsCompanion.insert(
            settingKey: 'fixture-seed',
            settingValue: '1',
          ),
          mode: InsertMode.insertOrReplace,
        );
      });
    });
  }

  List<OrderingTerm Function(ScheduleRecords)> get _entryOrder => [
    (row) => OrderingTerm(expression: row.dayId),
    (row) => OrderingTerm(expression: row.startMinute),
    (row) => OrderingTerm(expression: row.entryId),
  ];

  ScheduleEntry _fromRecord(ScheduleRecord row) {
    return ScheduleEntry(
      id: row.entryId,
      workshopId: row.workshopId,
      instructorId: row.instructorId,
      venueId: row.venueId,
      dayId: row.dayId,
      startMinute: row.startMinute,
      endMinute: row.endMinute,
      expectedAttendees: row.expectedAttendees,
    );
  }

  ScheduleRecordsCompanion _toCompanion(ScheduleEntry entry) {
    return ScheduleRecordsCompanion.insert(
      entryId: entry.id,
      workshopId: entry.workshopId,
      instructorId: entry.instructorId,
      venueId: entry.venueId,
      dayId: entry.dayId,
      startMinute: entry.startMinute,
      endMinute: entry.endMinute,
      expectedAttendees: entry.expectedAttendees,
    );
  }
}
