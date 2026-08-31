import 'schedule_models.dart';

// #region schedule-conflict-policy
class ScheduleConflictPolicy {
  const ScheduleConflictPolicy();

  List<ScheduleConflict> evaluate({
    required ScheduleEntry candidate,
    required List<ScheduleEntry> existingEntries,
    required Set<String> validDayIds,
    required Set<String> workshopIds,
    required Set<String> instructorIds,
    required Map<String, int> venueCapacities,
  }) {
    final conflicts = <ScheduleConflict>[];
    if (!validDayIds.contains(candidate.dayId)) {
      conflicts.add(
        const ScheduleConflict(kind: ScheduleConflictKind.invalidDay),
      );
    }
    if (candidate.startMinute >= candidate.endMinute) {
      conflicts.add(
        const ScheduleConflict(kind: ScheduleConflictKind.invalidTimeRange),
      );
    }
    if (candidate.startMinute < 9 * 60 || candidate.endMinute > 18 * 60) {
      conflicts.add(
        const ScheduleConflict(
          kind: ScheduleConflictKind.outsideOperatingHours,
        ),
      );
    }
    if (!workshopIds.contains(candidate.workshopId)) {
      conflicts.add(
        const ScheduleConflict(kind: ScheduleConflictKind.unknownWorkshop),
      );
    }
    if (!venueCapacities.containsKey(candidate.venueId)) {
      conflicts.add(
        const ScheduleConflict(kind: ScheduleConflictKind.unknownVenue),
      );
    }
    if (!instructorIds.contains(candidate.instructorId)) {
      conflicts.add(
        const ScheduleConflict(kind: ScheduleConflictKind.unknownInstructor),
      );
    }
    final venueCapacity = venueCapacities[candidate.venueId];
    if (venueCapacity != null && candidate.expectedAttendees > venueCapacity) {
      conflicts.add(
        const ScheduleConflict(kind: ScheduleConflictKind.capacityExceeded),
      );
    }
    final orderedEntries = [...existingEntries]
      ..sort((left, right) {
        final byStart = left.startMinute.compareTo(right.startMinute);
        return byStart != 0 ? byStart : left.id.compareTo(right.id);
      });
    for (final entry in orderedEntries) {
      final overlaps =
          candidate.startMinute < entry.endMinute &&
          entry.startMinute < candidate.endMinute;
      if (entry.id != candidate.id &&
          entry.dayId == candidate.dayId &&
          entry.venueId == candidate.venueId &&
          overlaps) {
        conflicts.add(
          ScheduleConflict(
            kind: ScheduleConflictKind.venueOverlap,
            relatedEntryId: entry.id,
            relatedStartMinute: entry.startMinute,
            relatedEndMinute: entry.endMinute,
          ),
        );
      }
      if (entry.id != candidate.id &&
          entry.dayId == candidate.dayId &&
          entry.instructorId == candidate.instructorId &&
          overlaps) {
        conflicts.add(
          ScheduleConflict(
            kind: ScheduleConflictKind.instructorOverlap,
            relatedEntryId: entry.id,
            relatedStartMinute: entry.startMinute,
            relatedEndMinute: entry.endMinute,
          ),
        );
      }
    }
    return conflicts;
  }
}
// #endregion schedule-conflict-policy
