import '../domain/schedule_models.dart';

abstract interface class ScheduleStorageService {
  Future<void> ensureSeeded(List<ScheduleEntry> entries);

  Stream<List<ScheduleEntry>> watchEntries(ScheduleQuery query);

  Future<List<ScheduleEntry>> readEntries();

  Future<ScheduleEntry?> findEntry(String id);

  Future<void> upsertEntry(ScheduleEntry entry);

  Future<void> restoreEntries(List<ScheduleEntry> entries);
}
