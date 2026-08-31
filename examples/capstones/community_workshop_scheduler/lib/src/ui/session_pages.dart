import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../data/schedule_repository.dart';
import '../domain/schedule_models.dart';
import '../state/schedule_providers.dart';
import 'schedule_board_page.dart';
import 'scheduler_theme.dart';

class WorkshopEditorPage extends ConsumerStatefulWidget {
  const WorkshopEditorPage({required this.uri, this.sessionId, super.key});

  final Uri uri;
  final String? sessionId;

  @override
  ConsumerState<WorkshopEditorPage> createState() => _WorkshopEditorPageState();
}

class _WorkshopEditorPageState extends ConsumerState<WorkshopEditorPage> {
  final _conflictSummaryFocus = FocusNode(debugLabel: 'conflict summary');
  final _attendeesFocus = FocusNode(debugLabel: 'expected attendees');
  final _attendeesController = TextEditingController();
  ScheduleEntry? _draft;
  bool _editorStarted = false;

  @override
  void dispose() {
    _conflictSummaryFocus.dispose();
    _attendeesFocus.dispose();
    _attendeesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final catalogValue = ref.watch(workshopCatalogProvider);
    return Scaffold(
      body: SafeArea(
        child: catalogValue.when(
          data: (result) => switch (result) {
            ScheduleSuccess<WorkshopCatalog>(:final value) => _buildWithCatalog(
              value,
            ),
            ScheduleFailureResult<WorkshopCatalog>() =>
              const _EditorLoadFailure(),
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stackTrace) => const _EditorLoadFailure(),
        ),
      ),
    );
  }

  Widget _buildWithCatalog(WorkshopCatalog catalog) {
    final sessionId = widget.sessionId;
    if (sessionId == null) {
      _initializeDraft(_newDraft(catalog));
      return _buildEditor(catalog);
    }
    final entryValue = ref.watch(sessionEntryProvider(sessionId));
    return entryValue.when(
      data: (result) => switch (result) {
        ScheduleSuccess<ScheduleEntry>(:final value) => _editorForEntry(
          catalog,
          value,
        ),
        ScheduleFailureResult<ScheduleEntry>(
          failure: ScheduleNotFoundFailure(),
        ) =>
          SessionNotFound(sessionId: sessionId),
        ScheduleFailureResult<ScheduleEntry>() => const _EditorLoadFailure(),
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) => const _EditorLoadFailure(),
    );
  }

  Widget _editorForEntry(WorkshopCatalog catalog, ScheduleEntry entry) {
    _initializeDraft(entry);
    return _buildEditor(catalog);
  }

  void _initializeDraft(ScheduleEntry draft) {
    if (_draft != null) return;
    _draft = draft;
    _attendeesController.text = draft.expectedAttendees.toString();
    if (_editorStarted) return;
    _editorStarted = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) ref.read(workshopEditorProvider.notifier).begin(draft);
    });
  }

  ScheduleEntry _newDraft(WorkshopCatalog catalog) {
    final queryDay = widget.uri.queryParameters['day'];
    final queryVenue = widget.uri.queryParameters['venue'];
    return ScheduleEntry(
      id: 'session-local-${DateTime.now().microsecondsSinceEpoch}',
      workshopId: catalog.workshops.first.id,
      instructorId: catalog.instructors.first.id,
      venueId: catalog.venue(queryVenue ?? '')?.id ?? catalog.venues.first.id,
      dayId: catalog.day(queryDay ?? '')?.id ?? catalog.days.first.id,
      startMinute: 540,
      endMinute: 600,
      expectedAttendees: 12,
    );
  }

  Widget _buildEditor(WorkshopCatalog catalog) {
    final draft = _draft!;
    final editor = ref.watch(workshopEditorProvider);
    final title = widget.sessionId == null ? '新建排期' : '编辑排期';
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(child: _EditorHeader(title: title)),
        SliverToBoxAdapter(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 920),
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (editor.conflicts.isNotEmpty ||
                        editor.failure != null) ...[
                      Focus(
                        key: const ValueKey('conflict-summary-focus'),
                        focusNode: _conflictSummaryFocus,
                        child: _ConflictSummary(
                          catalog: catalog,
                          draft: draft,
                          conflicts: editor.conflicts,
                          attendeesFocus: _attendeesFocus,
                        ),
                      ),
                      const SizedBox(height: 18),
                    ],
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: dispatchPaper,
                        border: Border.all(color: dispatchInk, width: 2),
                        borderRadius: const BorderRadius.all(
                          Radius.circular(8),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '场次资料',
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                          const SizedBox(height: 8),
                          const Text('时间按半小时选择；保存前会同时检查场馆、讲师和容量。'),
                          const SizedBox(height: 20),
                          _EditorFields(
                            catalog: catalog,
                            draft: draft,
                            attendeesController: _attendeesController,
                            attendeesFocus: _attendeesFocus,
                            onChanged: _updateDraft,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    Wrap(
                      alignment: WrapAlignment.end,
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        OutlinedButton(
                          onPressed: editor.isSaving
                              ? null
                              : () => _returnToBoard(context),
                          child: const Text('取消'),
                        ),
                        FilledButton.icon(
                          key: const ValueKey('save-session'),
                          onPressed: editor.isSaving ? null : _save,
                          icon: editor.isSaving
                              ? const SizedBox.square(
                                  dimension: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(Icons.check),
                          label: Text(editor.isSaving ? '正在保存' : '检查并保存'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _updateDraft(ScheduleEntry draft) {
    setState(() => _draft = draft);
    ref.read(workshopEditorProvider.notifier).update(draft);
  }

  Future<void> _save() async {
    final attendeeCount = int.tryParse(_attendeesController.text);
    _updateDraft(_draft!.copyWith(expectedAttendees: attendeeCount ?? 0));
    final result = await ref.read(workshopEditorProvider.notifier).save();
    if (!mounted || result == null) return;
    if (result case ScheduleSuccess<ScheduleEntry>(:final value)) {
      context.go('/sessions/${value.id}');
      return;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _conflictSummaryFocus.requestFocus();
    });
  }
}

class _EditorHeader extends StatelessWidget {
  const _EditorHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: dispatchInk,
      padding: const EdgeInsets.all(18),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 920),
          child: Row(
            children: [
              IconButton(
                tooltip: '返回排期台',
                onPressed: () => _returnToBoard(context),
                color: dispatchPaper,
                icon: const Icon(Icons.arrow_back),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.displaySmall
                      ?.copyWith(color: dispatchPaper),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EditorFields extends StatelessWidget {
  const _EditorFields({
    required this.catalog,
    required this.draft,
    required this.attendeesController,
    required this.attendeesFocus,
    required this.onChanged,
  });

  final WorkshopCatalog catalog;
  final ScheduleEntry draft;
  final TextEditingController attendeesController;
  final FocusNode attendeesFocus;
  final ValueChanged<ScheduleEntry> onChanged;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final fieldWidth = constraints.maxWidth >= 660
            ? (constraints.maxWidth - 14) / 2
            : constraints.maxWidth;
        return Wrap(
          spacing: 14,
          runSpacing: 16,
          children: [
            _SizedEditorField(
              width: fieldWidth,
              child: DropdownButtonFormField<String>(
                key: const ValueKey('workshop-field'),
                initialValue: draft.workshopId,
                decoration: const InputDecoration(labelText: '工坊'),
                items: [
                  for (final workshop in catalog.workshops)
                    DropdownMenuItem(
                      value: workshop.id,
                      child: Text(workshop.title),
                    ),
                ],
                onChanged: (value) {
                  if (value != null) {
                    onChanged(draft.copyWith(workshopId: value));
                  }
                },
              ),
            ),
            _SizedEditorField(
              width: fieldWidth,
              child: DropdownButtonFormField<String>(
                key: const ValueKey('instructor-field'),
                initialValue: draft.instructorId,
                decoration: const InputDecoration(labelText: '讲师'),
                items: [
                  for (final instructor in catalog.instructors)
                    DropdownMenuItem(
                      value: instructor.id,
                      child: Text(instructor.name),
                    ),
                ],
                onChanged: (value) {
                  if (value != null) {
                    onChanged(draft.copyWith(instructorId: value));
                  }
                },
              ),
            ),
            _SizedEditorField(
              width: fieldWidth,
              child: DropdownButtonFormField<String>(
                key: const ValueKey('day-field'),
                initialValue: draft.dayId,
                decoration: const InputDecoration(labelText: '活动日'),
                items: [
                  for (final day in catalog.days)
                    DropdownMenuItem(value: day.id, child: Text(day.label)),
                ],
                onChanged: (value) {
                  if (value != null) onChanged(draft.copyWith(dayId: value));
                },
              ),
            ),
            _SizedEditorField(
              width: fieldWidth,
              child: DropdownButtonFormField<String>(
                key: const ValueKey('venue-field'),
                initialValue: draft.venueId,
                decoration: const InputDecoration(labelText: '场馆'),
                items: [
                  for (final venue in catalog.venues)
                    DropdownMenuItem(
                      value: venue.id,
                      child: Text('${venue.name} · ${venue.capacity} 人'),
                    ),
                ],
                onChanged: (value) {
                  if (value != null) onChanged(draft.copyWith(venueId: value));
                },
              ),
            ),
            _SizedEditorField(
              width: fieldWidth,
              child: DropdownButtonFormField<int>(
                key: const ValueKey('start-time-field'),
                initialValue: draft.startMinute,
                decoration: const InputDecoration(labelText: '开始时间'),
                items: [
                  for (var minute = 540; minute < 1080; minute += 30)
                    DropdownMenuItem(
                      value: minute,
                      child: Text(formatMinutes(minute)),
                    ),
                ],
                onChanged: (value) {
                  if (value != null) {
                    onChanged(draft.copyWith(startMinute: value));
                  }
                },
              ),
            ),
            _SizedEditorField(
              width: fieldWidth,
              child: DropdownButtonFormField<int>(
                key: const ValueKey('end-time-field'),
                initialValue: draft.endMinute,
                decoration: const InputDecoration(labelText: '结束时间'),
                items: [
                  for (var minute = 570; minute <= 1080; minute += 30)
                    DropdownMenuItem(
                      value: minute,
                      child: Text(formatMinutes(minute)),
                    ),
                ],
                onChanged: (value) {
                  if (value != null) {
                    onChanged(draft.copyWith(endMinute: value));
                  }
                },
              ),
            ),
            _SizedEditorField(
              width: fieldWidth,
              child: TextField(
                key: const ValueKey('expected-attendees-field'),
                controller: attendeesController,
                focusNode: attendeesFocus,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: '预计人数',
                  helperText: '不能超过所选场馆容量',
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _SizedEditorField extends StatelessWidget {
  const _SizedEditorField({required this.width, required this.child});

  final double width;
  final Widget child;

  @override
  Widget build(BuildContext context) => SizedBox(width: width, child: child);
}

// #region conflict-summary
class _ConflictSummary extends StatelessWidget {
  const _ConflictSummary({
    required this.catalog,
    required this.draft,
    required this.conflicts,
    required this.attendeesFocus,
  });

  final WorkshopCatalog catalog;
  final ScheduleEntry draft;
  final List<ScheduleConflict> conflicts;
  final FocusNode attendeesFocus;

  @override
  Widget build(BuildContext context) {
    if (conflicts.isEmpty) {
      return Semantics(
        liveRegion: true,
        child: Container(
          key: const ValueKey('conflict-summary'),
          padding: const EdgeInsets.all(18),
          color: const Color(0xFFFFE4D0),
          child: const Text('保存失败。排期没有改变，请稍后重试。'),
        ),
      );
    }
    return Semantics(
      liveRegion: true,
      container: true,
      label: '发现 ${conflicts.length} 个排期冲突，请一次处理完再保存',
      child: Container(
        key: const ValueKey('conflict-summary'),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: const Color(0xFFFFE4D0),
          border: Border.all(color: dispatchRed, width: 2),
          borderRadius: const BorderRadius.all(Radius.circular(8)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              '先处理这 ${conflicts.length} 个问题',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 6),
            const Text('本次没有写入任何内容。修好后再保存一次即可。'),
            const SizedBox(height: 4),
            for (final conflict in conflicts)
              _ConflictRow(
                conflict: conflict,
                catalog: catalog,
                draft: draft,
                attendeesFocus: attendeesFocus,
              ),
          ],
        ),
      ),
    );
  }
}

class _ConflictRow extends StatelessWidget {
  const _ConflictRow({
    required this.conflict,
    required this.catalog,
    required this.draft,
    required this.attendeesFocus,
  });

  final ScheduleConflict conflict;
  final WorkshopCatalog catalog;
  final ScheduleEntry draft;
  final FocusNode attendeesFocus;

  @override
  Widget build(BuildContext context) {
    final venue = catalog.venue(draft.venueId);
    final instructor = catalog.instructor(draft.instructorId);
    final relatedTime = conflict.relatedStartMinute == null
        ? '相同时段'
        : '${formatMinutes(conflict.relatedStartMinute!)}–${formatMinutes(conflict.relatedEndMinute!)}';
    final (title, detail) = _describeConflict(
      conflict,
      draft,
      venue,
      instructor,
      relatedTime,
    );
    final relatedId = conflict.relatedEntryId;
    final adjustsCapacity =
        conflict.kind == ScheduleConflictKind.capacityExceeded;
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Container(
        padding: const EdgeInsets.all(12),
        color: dispatchPaper,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final text = Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 3),
                Text(detail),
              ],
            );
            final action = TextButton(
              onPressed: adjustsCapacity
                  ? attendeesFocus.requestFocus
                  : relatedId == null
                  ? null
                  : () => context.push('/sessions/$relatedId'),
              child: Text(adjustsCapacity ? '调整人数' : '查看场次'),
            );
            if (constraints.maxWidth < 520) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [text, const SizedBox(height: 6), action],
              );
            }
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.warning_amber_rounded, color: dispatchRed),
                const SizedBox(width: 10),
                Expanded(child: text),
                const SizedBox(width: 8),
                action,
              ],
            );
          },
        ),
      ),
    );
  }
}

(String, String) _describeConflict(
  ScheduleConflict conflict,
  ScheduleEntry draft,
  Venue? venue,
  Instructor? instructor,
  String relatedTime,
) {
  return switch (conflict.kind) {
    ScheduleConflictKind.capacityExceeded => (
      '预计人数超过场馆容量',
      '预计 ${draft.expectedAttendees} 人，${venue?.name ?? '所选场馆'}最多容纳 ${venue?.capacity ?? 0} 人。',
    ),
    ScheduleConflictKind.venueOverlap => (
      '场馆时段重叠',
      '${venue?.name ?? '所选场馆'}在 $relatedTime 已有场次。',
    ),
    ScheduleConflictKind.instructorOverlap => (
      '讲师时段重叠',
      '${instructor?.name ?? '所选讲师'}在 $relatedTime 已有场次。',
    ),
    ScheduleConflictKind.invalidDay => ('活动日无效', '请选择本次活动提供的两个日期之一。'),
    ScheduleConflictKind.invalidTimeRange => ('时间顺序无效', '结束时间必须晚于开始时间。'),
    ScheduleConflictKind.outsideOperatingHours => (
      '超出开放时段',
      '场次必须完整落在 09:00–18:00。',
    ),
    ScheduleConflictKind.unknownWorkshop => ('工坊不存在', '重新选择一项工坊。'),
    ScheduleConflictKind.unknownVenue => ('场馆不存在', '重新选择一处场馆。'),
    ScheduleConflictKind.unknownInstructor => ('讲师不存在', '重新选择一位讲师。'),
  };
}
// #endregion conflict-summary

class SessionDetailPage extends ConsumerWidget {
  const SessionDetailPage({required this.sessionId, super.key});

  final String sessionId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final catalogValue = ref.watch(workshopCatalogProvider);
    final entryValue = ref.watch(sessionEntryProvider(sessionId));
    return Scaffold(
      body: SafeArea(
        child: catalogValue.when(
          data: (catalogResult) => switch (catalogResult) {
            ScheduleSuccess<WorkshopCatalog>(value: final catalog) =>
              entryValue.when(
                data: (entryResult) => switch (entryResult) {
                  ScheduleSuccess<ScheduleEntry>(value: final entry) =>
                    _SessionDetail(catalog: catalog, entry: entry),
                  ScheduleFailureResult<ScheduleEntry>(
                    failure: ScheduleNotFoundFailure(),
                  ) =>
                    SessionNotFound(sessionId: sessionId),
                  ScheduleFailureResult<ScheduleEntry>() =>
                    const _EditorLoadFailure(),
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stackTrace) => const _EditorLoadFailure(),
              ),
            ScheduleFailureResult<WorkshopCatalog>() =>
              const _EditorLoadFailure(),
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stackTrace) => const _EditorLoadFailure(),
        ),
      ),
    );
  }
}

class _SessionDetail extends StatelessWidget {
  const _SessionDetail({required this.catalog, required this.entry});

  final WorkshopCatalog catalog;
  final ScheduleEntry entry;

  @override
  Widget build(BuildContext context) {
    final workshop = catalog.workshop(entry.workshopId)!;
    final day = catalog.day(entry.dayId)!;
    final venue = catalog.venue(entry.venueId)!;
    final instructor = catalog.instructor(entry.instructorId)!;
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Container(
            color: dispatchInk,
            padding: const EdgeInsets.all(18),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 860),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final title = Text(
                      workshop.title,
                      style: Theme.of(context).textTheme.displaySmall
                          ?.copyWith(color: dispatchPaper),
                    );
                    final back = IconButton(
                      tooltip: '返回排期台',
                      onPressed: () => _returnToBoard(context),
                      color: dispatchPaper,
                      icon: const Icon(Icons.arrow_back),
                    );
                    final edit = FilledButton.icon(
                      onPressed: () =>
                          context.push('/sessions/${entry.id}/edit'),
                      style: FilledButton.styleFrom(
                        backgroundColor: dispatchOrange,
                        foregroundColor: dispatchInk,
                      ),
                      icon: const Icon(Icons.edit_outlined),
                      label: const Text('编辑'),
                    );
                    if (constraints.maxWidth < 560) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          back,
                          const SizedBox(height: 8),
                          title,
                          const SizedBox(height: 16),
                          edit,
                        ],
                      );
                    }
                    return Row(
                      children: [
                        back,
                        const SizedBox(width: 12),
                        Expanded(child: title),
                        edit,
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 860),
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: dispatchPaper,
                    border: Border.all(color: dispatchInk, width: 2),
                    borderRadius: const BorderRadius.all(Radius.circular(8)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        workshop.category,
                        style: const TextStyle(
                          color: dispatchBlue,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        workshop.summary,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      const SizedBox(height: 18),
                      _DetailFact(
                        icon: Icons.calendar_today_outlined,
                        label: day.label,
                      ),
                      _DetailFact(
                        icon: Icons.schedule,
                        label:
                            '${formatMinutes(entry.startMinute)}–${formatMinutes(entry.endMinute)}',
                      ),
                      _DetailFact(
                        icon: Icons.meeting_room_outlined,
                        label: '${venue.name} · 容量 ${venue.capacity} 人',
                      ),
                      _DetailFact(
                        icon: Icons.person_outline,
                        label: '${instructor.name} · ${instructor.bio}',
                      ),
                      _DetailFact(
                        icon: Icons.groups_outlined,
                        label: '预计 ${entry.expectedAttendees} 人',
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _DetailFact extends StatelessWidget {
  const _DetailFact({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: dispatchBlue),
          const SizedBox(width: 10),
          Expanded(child: Text(label)),
        ],
      ),
    );
  }
}

class SessionNotFound extends StatelessWidget {
  const SessionNotFound({required this.sessionId, super.key});

  final String sessionId;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.event_busy_outlined, size: 48),
              const SizedBox(height: 14),
              Text('找不到这个场次', style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 8),
              Text('“$sessionId”不在当前本地排期中。它可能已被恢复演示数据覆盖。'),
              const SizedBox(height: 18),
              FilledButton.icon(
                onPressed: () => _returnToBoard(context),
                icon: const Icon(Icons.arrow_back),
                label: const Text('返回排期台'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EditorLoadFailure extends StatelessWidget {
  const _EditorLoadFailure();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.storage_outlined, size: 48),
            const SizedBox(height: 12),
            const Text('场次暂时打不开'),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () => _returnToBoard(context),
              child: const Text('返回排期台'),
            ),
          ],
        ),
      ),
    );
  }
}

void _returnToBoard(BuildContext context) {
  if (context.canPop()) {
    context.pop();
  } else {
    context.go('/schedule');
  }
}
