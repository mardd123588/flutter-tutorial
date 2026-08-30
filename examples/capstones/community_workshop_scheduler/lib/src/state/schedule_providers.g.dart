// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'schedule_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(filteredSchedule)
final filteredScheduleProvider = FilteredScheduleFamily._();

final class FilteredScheduleProvider
    extends
        $FunctionalProvider<
          AsyncValue<ScheduleResult<List<ScheduleEntry>>>,
          ScheduleResult<List<ScheduleEntry>>,
          Stream<ScheduleResult<List<ScheduleEntry>>>
        >
    with
        $FutureModifier<ScheduleResult<List<ScheduleEntry>>>,
        $StreamProvider<ScheduleResult<List<ScheduleEntry>>> {
  FilteredScheduleProvider._({
    required FilteredScheduleFamily super.from,
    required ({String? dayId, String? venueId, String? instructorId})
    super.argument,
  }) : super(
         retry: null,
         name: r'filteredScheduleProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$filteredScheduleHash();

  @override
  String toString() {
    return r'filteredScheduleProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $StreamProviderElement<ScheduleResult<List<ScheduleEntry>>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<ScheduleResult<List<ScheduleEntry>>> create(Ref ref) {
    final argument =
        this.argument
            as ({String? dayId, String? venueId, String? instructorId});
    return filteredSchedule(
      ref,
      dayId: argument.dayId,
      venueId: argument.venueId,
      instructorId: argument.instructorId,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is FilteredScheduleProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$filteredScheduleHash() => r'43bafd2ca41686e0827286846bc63cfa12676d58';

final class FilteredScheduleFamily extends $Family
    with
        $FunctionalFamilyOverride<
          Stream<ScheduleResult<List<ScheduleEntry>>>,
          ({String? dayId, String? venueId, String? instructorId})
        > {
  FilteredScheduleFamily._()
    : super(
        retry: null,
        name: r'filteredScheduleProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  FilteredScheduleProvider call({
    String? dayId,
    String? venueId,
    String? instructorId,
  }) => FilteredScheduleProvider._(
    argument: (dayId: dayId, venueId: venueId, instructorId: instructorId),
    from: this,
  );

  @override
  String toString() => r'filteredScheduleProvider';
}
