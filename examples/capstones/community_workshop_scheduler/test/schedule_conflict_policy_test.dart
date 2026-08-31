import 'package:community_workshop_scheduler/src/domain/schedule_conflict_policy.dart';
import 'package:community_workshop_scheduler/src/domain/schedule_models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('reports a venue overlap on the same activity day', () {
    const policy = ScheduleConflictPolicy();
    final conflicts = policy.evaluate(
      candidate: const ScheduleEntry(
        id: 'candidate',
        workshopId: 'workshop-2',
        instructorId: 'instructor-2',
        venueId: 'venue-a',
        dayId: 'day-1',
        startMinute: 10 * 60,
        endMinute: 11 * 60,
        expectedAttendees: 18,
      ),
      existingEntries: const [
        ScheduleEntry(
          id: 'existing',
          workshopId: 'workshop-1',
          instructorId: 'instructor-1',
          venueId: 'venue-a',
          dayId: 'day-1',
          startMinute: 9 * 60 + 30,
          endMinute: 10 * 60 + 30,
          expectedAttendees: 12,
        ),
      ],
      validDayIds: const {'day-1', 'day-2'},
      workshopIds: const {'workshop-1', 'workshop-2'},
      instructorIds: const {'instructor-1', 'instructor-2'},
      venueCapacities: const {'venue-a': 24},
    );

    expect(conflicts, [
      const ScheduleConflict(
        kind: ScheduleConflictKind.venueOverlap,
        relatedEntryId: 'existing',
      ),
    ]);
  });

  test('reports an instructor overlap even when the venue differs', () {
    const policy = ScheduleConflictPolicy();
    final conflicts = policy.evaluate(
      candidate: const ScheduleEntry(
        id: 'candidate',
        workshopId: 'workshop-2',
        instructorId: 'instructor-1',
        venueId: 'venue-b',
        dayId: 'day-1',
        startMinute: 10 * 60,
        endMinute: 11 * 60,
        expectedAttendees: 18,
      ),
      existingEntries: const [
        ScheduleEntry(
          id: 'existing',
          workshopId: 'workshop-1',
          instructorId: 'instructor-1',
          venueId: 'venue-a',
          dayId: 'day-1',
          startMinute: 9 * 60 + 30,
          endMinute: 10 * 60 + 30,
          expectedAttendees: 12,
        ),
      ],
      validDayIds: const {'day-1', 'day-2'},
      workshopIds: const {'workshop-1', 'workshop-2'},
      instructorIds: const {'instructor-1', 'instructor-2'},
      venueCapacities: const {'venue-a': 24, 'venue-b': 40},
    );

    expect(conflicts, [
      const ScheduleConflict(
        kind: ScheduleConflictKind.instructorOverlap,
        relatedEntryId: 'existing',
      ),
    ]);
  });

  test('returns every validation failure in a stable order', () {
    const policy = ScheduleConflictPolicy();
    final conflicts = policy.evaluate(
      candidate: const ScheduleEntry(
        id: 'candidate',
        workshopId: 'missing-workshop',
        instructorId: 'missing-instructor',
        venueId: 'missing-venue',
        dayId: 'missing-day',
        startMinute: 8 * 60,
        endMinute: 8 * 60,
        expectedAttendees: 18,
      ),
      existingEntries: const [],
      validDayIds: const {'day-1', 'day-2'},
      workshopIds: const {'workshop-1'},
      instructorIds: const {'instructor-1'},
      venueCapacities: const {'venue-a': 24},
    );

    expect(conflicts.map((conflict) => conflict.kind), const [
      ScheduleConflictKind.invalidDay,
      ScheduleConflictKind.invalidTimeRange,
      ScheduleConflictKind.outsideOperatingHours,
      ScheduleConflictKind.unknownWorkshop,
      ScheduleConflictKind.unknownVenue,
      ScheduleConflictKind.unknownInstructor,
    ]);
  });

  test('reports capacity without hiding time conflicts', () {
    const policy = ScheduleConflictPolicy();
    final conflicts = policy.evaluate(
      candidate: const ScheduleEntry(
        id: 'candidate',
        workshopId: 'workshop-2',
        instructorId: 'instructor-1',
        venueId: 'venue-a',
        dayId: 'day-1',
        startMinute: 10 * 60,
        endMinute: 11 * 60,
        expectedAttendees: 30,
      ),
      existingEntries: const [
        ScheduleEntry(
          id: 'existing',
          workshopId: 'workshop-1',
          instructorId: 'instructor-1',
          venueId: 'venue-a',
          dayId: 'day-1',
          startMinute: 9 * 60 + 30,
          endMinute: 10 * 60 + 30,
          expectedAttendees: 12,
        ),
      ],
      validDayIds: const {'day-1', 'day-2'},
      workshopIds: const {'workshop-1', 'workshop-2'},
      instructorIds: const {'instructor-1'},
      venueCapacities: const {'venue-a': 24},
    );

    expect(conflicts.map((conflict) => conflict.kind), const [
      ScheduleConflictKind.capacityExceeded,
      ScheduleConflictKind.venueOverlap,
      ScheduleConflictKind.instructorOverlap,
    ]);
  });

  // #region half-open-self-exclusion-test
  test('uses half-open intervals and excludes the edited entry itself', () {
    const policy = ScheduleConflictPolicy();
    final conflicts = policy.evaluate(
      candidate: const ScheduleEntry(
        id: 'edited',
        workshopId: 'workshop-1',
        instructorId: 'instructor-1',
        venueId: 'venue-a',
        dayId: 'day-1',
        startMinute: 10 * 60,
        endMinute: 11 * 60,
        expectedAttendees: 18,
      ),
      existingEntries: const [
        ScheduleEntry(
          id: 'edited',
          workshopId: 'workshop-1',
          instructorId: 'instructor-1',
          venueId: 'venue-a',
          dayId: 'day-1',
          startMinute: 10 * 60,
          endMinute: 11 * 60,
          expectedAttendees: 18,
        ),
        ScheduleEntry(
          id: 'adjacent',
          workshopId: 'workshop-2',
          instructorId: 'instructor-1',
          venueId: 'venue-a',
          dayId: 'day-1',
          startMinute: 11 * 60,
          endMinute: 12 * 60,
          expectedAttendees: 12,
        ),
      ],
      validDayIds: const {'day-1'},
      workshopIds: const {'workshop-1', 'workshop-2'},
      instructorIds: const {'instructor-1'},
      venueCapacities: const {'venue-a': 24},
    );

    expect(conflicts, isEmpty);
  });
  // #endregion half-open-self-exclusion-test

  test('orders overlaps by session time, then by conflict kind', () {
    const policy = ScheduleConflictPolicy();
    final conflicts = policy.evaluate(
      candidate: const ScheduleEntry(
        id: 'candidate',
        workshopId: 'workshop-1',
        instructorId: 'instructor-1',
        venueId: 'venue-a',
        dayId: 'day-1',
        startMinute: 10 * 60,
        endMinute: 11 * 60,
        expectedAttendees: 18,
      ),
      existingEntries: const [
        ScheduleEntry(
          id: 'later',
          workshopId: 'workshop-2',
          instructorId: 'instructor-1',
          venueId: 'venue-a',
          dayId: 'day-1',
          startMinute: 10 * 60 + 30,
          endMinute: 11 * 60 + 30,
          expectedAttendees: 12,
        ),
        ScheduleEntry(
          id: 'earlier',
          workshopId: 'workshop-2',
          instructorId: 'instructor-1',
          venueId: 'venue-a',
          dayId: 'day-1',
          startMinute: 9 * 60 + 30,
          endMinute: 10 * 60 + 30,
          expectedAttendees: 12,
        ),
      ],
      validDayIds: const {'day-1'},
      workshopIds: const {'workshop-1', 'workshop-2'},
      instructorIds: const {'instructor-1'},
      venueCapacities: const {'venue-a': 24},
    );

    expect(conflicts, const [
      ScheduleConflict(
        kind: ScheduleConflictKind.venueOverlap,
        relatedEntryId: 'earlier',
      ),
      ScheduleConflict(
        kind: ScheduleConflictKind.instructorOverlap,
        relatedEntryId: 'earlier',
      ),
      ScheduleConflict(
        kind: ScheduleConflictKind.venueOverlap,
        relatedEntryId: 'later',
      ),
      ScheduleConflict(
        kind: ScheduleConflictKind.instructorOverlap,
        relatedEntryId: 'later',
      ),
    ]);
  });
}
