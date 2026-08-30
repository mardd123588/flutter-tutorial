import 'package:flutter/foundation.dart';

@immutable
class EventDay {
  const EventDay({required this.id, required this.label, required this.date});

  final String id;
  final String label;
  final DateTime date;
}

@immutable
class Workshop {
  const Workshop({
    required this.id,
    required this.title,
    required this.category,
    required this.summary,
  });

  final String id;
  final String title;
  final String category;
  final String summary;
}

@immutable
class Venue {
  const Venue({
    required this.id,
    required this.name,
    required this.capacity,
    required this.accessibility,
  });

  final String id;
  final String name;
  final int capacity;
  final List<String> accessibility;
}

@immutable
class Instructor {
  const Instructor({required this.id, required this.name, required this.bio});

  final String id;
  final String name;
  final String bio;
}

@immutable
class ScheduleEntry {
  const ScheduleEntry({
    required this.id,
    required this.workshopId,
    required this.instructorId,
    required this.venueId,
    required this.dayId,
    required this.startMinute,
    required this.endMinute,
    required this.expectedAttendees,
  });

  final String id;
  final String workshopId;
  final String instructorId;
  final String venueId;
  final String dayId;
  final int startMinute;
  final int endMinute;
  final int expectedAttendees;

  ScheduleEntry copyWith({
    String? id,
    String? workshopId,
    String? instructorId,
    String? venueId,
    String? dayId,
    int? startMinute,
    int? endMinute,
    int? expectedAttendees,
  }) {
    return ScheduleEntry(
      id: id ?? this.id,
      workshopId: workshopId ?? this.workshopId,
      instructorId: instructorId ?? this.instructorId,
      venueId: venueId ?? this.venueId,
      dayId: dayId ?? this.dayId,
      startMinute: startMinute ?? this.startMinute,
      endMinute: endMinute ?? this.endMinute,
      expectedAttendees: expectedAttendees ?? this.expectedAttendees,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is ScheduleEntry &&
        other.id == id &&
        other.workshopId == workshopId &&
        other.instructorId == instructorId &&
        other.venueId == venueId &&
        other.dayId == dayId &&
        other.startMinute == startMinute &&
        other.endMinute == endMinute &&
        other.expectedAttendees == expectedAttendees;
  }

  @override
  int get hashCode => Object.hash(
    id,
    workshopId,
    instructorId,
    venueId,
    dayId,
    startMinute,
    endMinute,
    expectedAttendees,
  );
}

@immutable
class ScheduleQuery {
  const ScheduleQuery({this.dayId, this.venueId, this.instructorId});

  final String? dayId;
  final String? venueId;
  final String? instructorId;

  bool matches(ScheduleEntry entry) {
    return (dayId == null || entry.dayId == dayId) &&
        (venueId == null || entry.venueId == venueId) &&
        (instructorId == null || entry.instructorId == instructorId);
  }

  @override
  bool operator ==(Object other) {
    return other is ScheduleQuery &&
        other.dayId == dayId &&
        other.venueId == venueId &&
        other.instructorId == instructorId;
  }

  @override
  int get hashCode => Object.hash(dayId, venueId, instructorId);
}

@immutable
class WorkshopCatalog {
  const WorkshopCatalog({
    required this.days,
    required this.venues,
    required this.instructors,
    required this.workshops,
    required this.initialSchedule,
  });

  final List<EventDay> days;
  final List<Venue> venues;
  final List<Instructor> instructors;
  final List<Workshop> workshops;
  final List<ScheduleEntry> initialSchedule;

  EventDay? day(String id) => _findById(days, id, (value) => value.id);

  Venue? venue(String id) => _findById(venues, id, (value) => value.id);

  Instructor? instructor(String id) =>
      _findById(instructors, id, (value) => value.id);

  Workshop? workshop(String id) =>
      _findById(workshops, id, (value) => value.id);

  T? _findById<T>(List<T> values, String id, String Function(T value) readId) {
    for (final value in values) {
      if (readId(value) == id) return value;
    }
    return null;
  }
}

enum ScheduleConflictKind {
  invalidDay,
  invalidTimeRange,
  outsideOperatingHours,
  unknownWorkshop,
  unknownVenue,
  unknownInstructor,
  capacityExceeded,
  venueOverlap,
  instructorOverlap,
}

@immutable
class ScheduleConflict {
  const ScheduleConflict({
    required this.kind,
    this.relatedEntryId,
    this.relatedStartMinute,
    this.relatedEndMinute,
  });

  final ScheduleConflictKind kind;
  final String? relatedEntryId;
  final int? relatedStartMinute;
  final int? relatedEndMinute;

  @override
  bool operator ==(Object other) {
    return other is ScheduleConflict &&
        other.kind == kind &&
        other.relatedEntryId == relatedEntryId;
  }

  @override
  int get hashCode => Object.hash(kind, relatedEntryId);
}
