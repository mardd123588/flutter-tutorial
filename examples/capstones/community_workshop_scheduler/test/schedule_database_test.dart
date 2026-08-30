import 'package:community_workshop_scheduler/src/data/schedule_database.dart';
import 'package:community_workshop_scheduler/src/data/workshop_catalog_service.dart';
import 'package:community_workshop_scheduler/src/domain/schedule_models.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('seeds once, streams filtered writes, and restores demo data', () async {
    final database = ScheduleDatabase(NativeDatabase.memory());
    addTearDown(database.close);
    final initial = fixtureWorkshopCatalog.initialSchedule;

    await database.ensureSeeded(initial);
    expect(await database.readEntries(), hasLength(10));

    const added = ScheduleEntry(
      id: 'session-added',
      workshopId: 'workshop-mending',
      instructorId: 'instructor-he',
      venueId: 'venue-hall',
      dayId: 'day-sat',
      startMinute: 900,
      endMinute: 990,
      expectedAttendees: 20,
    );
    final matching = database.watchEntries(
      const ScheduleQuery(dayId: 'day-sat', venueId: 'venue-hall'),
    );
    final updated = matching.firstWhere(
      (entries) => entries.any((entry) => entry.id == added.id),
    );

    await database.upsertEntry(added);
    expect(await updated, contains(added));
    await database.ensureSeeded(initial);
    expect(await database.readEntries(), hasLength(11));

    await database.restoreEntries(initial);
    expect(await database.readEntries(), initial);
  });
}
