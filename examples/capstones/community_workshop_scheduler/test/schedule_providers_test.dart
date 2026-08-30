import 'dart:async';

import 'package:community_workshop_scheduler/src/data/schedule_repository.dart';
import 'package:community_workshop_scheduler/src/domain/schedule_models.dart';
import 'package:community_workshop_scheduler/src/state/schedule_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'generated query family keeps parameter combinations independent',
    () async {
      final repository = ControlledScheduleRepository();
      final container = ProviderContainer.test(
        overrides: [scheduleRepositoryProvider.overrideWithValue(repository)],
      );
      const saturday = ScheduleEntry(
        id: 'sat',
        workshopId: 'workshop',
        instructorId: 'instructor-a',
        venueId: 'venue-a',
        dayId: 'day-sat',
        startMinute: 540,
        endMinute: 600,
        expectedAttendees: 12,
      );
      const sunday = ScheduleEntry(
        id: 'sun',
        workshopId: 'workshop',
        instructorId: 'instructor-b',
        venueId: 'venue-b',
        dayId: 'day-sun',
        startMinute: 540,
        endMinute: 600,
        expectedAttendees: 12,
      );
      repository.entries = const [saturday, sunday];
      final saturdayProvider = filteredScheduleProvider(dayId: 'day-sat');
      final sundayProvider = filteredScheduleProvider(dayId: 'day-sun');
      final saturdayKeepAlive = container.listen(saturdayProvider, (_, _) {});
      final sundayKeepAlive = container.listen(sundayProvider, (_, _) {});
      addTearDown(saturdayKeepAlive.close);
      addTearDown(sundayKeepAlive.close);

      final saturdayResult = await container.read(saturdayProvider.future);
      final sundayResult = await container.read(sundayProvider.future);

      expect((saturdayResult as ScheduleSuccess<List<ScheduleEntry>>).value, [
        saturday,
      ]);
      expect((sundayResult as ScheduleSuccess<List<ScheduleEntry>>).value, [
        sunday,
      ]);
    },
  );

  test(
    'editor command ignores a duplicate save while work is running',
    () async {
      final repository = ControlledScheduleRepository()..holdSave();
      final container = ProviderContainer.test(
        overrides: [scheduleRepositoryProvider.overrideWithValue(repository)],
      );
      addTearDown(container.dispose);
      const draft = ScheduleEntry(
        id: 'draft',
        workshopId: 'workshop',
        instructorId: 'instructor-a',
        venueId: 'venue-a',
        dayId: 'day-sat',
        startMinute: 540,
        endMinute: 600,
        expectedAttendees: 12,
      );
      final controller = container.read(workshopEditorProvider.notifier);
      controller.begin(draft);

      final first = controller.save();
      final duplicate = await controller.save();

      expect(duplicate, isNull);
      expect(repository.saveCalls, 1);
      expect(container.read(workshopEditorProvider).isSaving, isTrue);

      repository.completeSave(const ScheduleSuccess(draft));
      await first;
      expect(container.read(workshopEditorProvider).isSaving, isFalse);
      expect(container.read(workshopEditorProvider).savedEntry, draft);
    },
  );

  test(
    'generated schedule family releases its stream after the last listener',
    () async {
      final repository = DisposalScheduleRepository();
      final container = ProviderContainer.test(
        overrides: [scheduleRepositoryProvider.overrideWithValue(repository)],
      );
      final provider = filteredScheduleProvider(
        dayId: 'day-sat',
        venueId: 'venue-a',
        instructorId: 'instructor-a',
      );
      final subscription = container.listen(provider, (_, _) {});
      await container.read(provider.future);

      subscription.close();
      await container.pump();
      await container.pump();

      expect(repository.cancelCount, 1);
    },
  );
}

class ControlledScheduleRepository implements ScheduleRepository {
  List<ScheduleEntry> entries = const [];
  Completer<ScheduleResult<ScheduleEntry>>? _saveCompleter;
  var saveCalls = 0;

  void holdSave() {
    _saveCompleter = Completer<ScheduleResult<ScheduleEntry>>();
  }

  void completeSave(ScheduleResult<ScheduleEntry> result) {
    _saveCompleter?.complete(result);
  }

  @override
  Future<ScheduleResult<ScheduleEntry>> findEntry(String id) async {
    return ScheduleSuccess(entries.firstWhere((entry) => entry.id == id));
  }

  @override
  Future<ScheduleResult<WorkshopCatalog>> loadCatalog() async {
    return const ScheduleFailureResult(ScheduleCatalogFailure());
  }

  @override
  Future<ScheduleResult<void>> restoreDemoData() async {
    return const ScheduleSuccess(null);
  }

  @override
  Future<ScheduleResult<ScheduleEntry>> save(ScheduleEntry entry) {
    saveCalls += 1;
    return _saveCompleter?.future ?? Future.value(ScheduleSuccess(entry));
  }

  @override
  Stream<ScheduleResult<List<ScheduleEntry>>> watchSchedule(
    ScheduleQuery query,
  ) {
    return Stream.value(
      ScheduleSuccess(entries.where(query.matches).toList(growable: false)),
    );
  }
}

class DisposalScheduleRepository extends ControlledScheduleRepository {
  DisposalScheduleRepository() {
    controller = StreamController<ScheduleResult<List<ScheduleEntry>>>(
      onListen: () {
        controller.add(const ScheduleSuccess([]));
      },
      onCancel: () {
        cancelCount += 1;
      },
    );
  }

  late final StreamController<ScheduleResult<List<ScheduleEntry>>> controller;
  var cancelCount = 0;

  @override
  Stream<ScheduleResult<List<ScheduleEntry>>> watchSchedule(
    ScheduleQuery query,
  ) {
    return controller.stream;
  }
}
