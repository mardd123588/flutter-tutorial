import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../data/schedule_repository.dart';
import '../domain/schedule_models.dart';
import '../state/schedule_providers.dart';
import 'scheduler_theme.dart';

class ScheduleBoardPage extends ConsumerStatefulWidget {
  const ScheduleBoardPage({required this.uri, super.key});

  final Uri uri;

  @override
  ConsumerState<ScheduleBoardPage> createState() => _ScheduleBoardPageState();
}

class _ScheduleBoardPageState extends ConsumerState<ScheduleBoardPage> {
  String? _instructorId;

  @override
  Widget build(BuildContext context) {
    final catalogValue = ref.watch(workshopCatalogProvider);
    return Scaffold(
      body: SafeArea(
        child: catalogValue.when(
          data: (result) => switch (result) {
            ScheduleSuccess<WorkshopCatalog>(:final value) => _buildBoard(
              context,
              value,
            ),
            ScheduleFailureResult<WorkshopCatalog>() => _InitialFailure(
              onRetry: () => ref.read(workshopCatalogProvider.notifier).retry(),
            ),
          },
          loading: () => const _BoardLoading(),
          error: (error, stackTrace) => _InitialFailure(
            onRetry: () => ref.read(workshopCatalogProvider.notifier).retry(),
          ),
        ),
      ),
    );
  }

  Widget _buildBoard(BuildContext context, WorkshopCatalog catalog) {
    final requestedDay = widget.uri.queryParameters['day'];
    final requestedVenue = widget.uri.queryParameters['venue'];
    final dayId = catalog.day(requestedDay ?? '') == null ? null : requestedDay;
    final venueId = catalog.venue(requestedVenue ?? '') == null
        ? null
        : requestedVenue;
    final scheduleValue = ref.watch(
      filteredScheduleProvider(
        dayId: dayId,
        venueId: venueId,
        instructorId: _instructorId,
      ),
    );
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: _BoardHeader(
            onRestore: _confirmRestore,
            onCreate: () {
              final query = <String, String>{'day': ?dayId, 'venue': ?venueId};
              context.push(
                Uri(path: '/new', queryParameters: query).toString(),
              );
            },
          ),
        ),
        SliverToBoxAdapter(
          child: _FilterDesk(
            catalog: catalog,
            dayId: dayId,
            venueId: venueId,
            instructorId: _instructorId,
            onDayChanged: (value) => _writeUrl(dayId: value, venueId: venueId),
            onVenueChanged: (value) => _writeUrl(dayId: dayId, venueId: value),
            onInstructorChanged: (value) =>
                setState(() => _instructorId = value),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 0, 18, 48),
            child: scheduleValue.when(
              data: (result) => switch (result) {
                ScheduleSuccess<List<ScheduleEntry>>(:final value) =>
                  _ScheduleContent(catalog: catalog, entries: value),
                ScheduleFailureResult<List<ScheduleEntry>>() => _StreamFailure(
                  onRetry: () => ref.invalidate(
                    filteredScheduleProvider(
                      dayId: dayId,
                      venueId: venueId,
                      instructorId: _instructorId,
                    ),
                  ),
                ),
              },
              loading: () => const _BoardLoading(compact: true),
              error: (error, stackTrace) => _StreamFailure(
                onRetry: () => ref.invalidate(
                  filteredScheduleProvider(
                    dayId: dayId,
                    venueId: venueId,
                    instructorId: _instructorId,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _writeUrl({String? dayId, String? venueId}) {
    final query = <String, String>{'day': ?dayId, 'venue': ?venueId};
    context.go(Uri(path: '/schedule', queryParameters: query).toString());
  }

  Future<void> _confirmRestore() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('恢复演示数据？'),
        content: const Text('这会覆盖你在此浏览器里修改过的排期，恢复为固定的 10 条演示场次。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          FilledButton(
            key: const ValueKey('confirm-restore-demo'),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('恢复 10 条演示数据'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    final result = await ref.read(scheduleRepositoryProvider).restoreDemoData();
    if (!mounted || result is ScheduleSuccess<void>) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('恢复失败。排期没有被覆盖，请稍后重试。')));
  }
}

class _BoardHeader extends StatelessWidget {
  const _BoardHeader({required this.onRestore, required this.onCreate});

  final VoidCallback onRestore;
  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: dispatchInk,
      padding: const EdgeInsets.all(18),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1320),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final compact = constraints.maxWidth < 720;
              final title = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    compact && constraints.maxWidth < 400
                        ? '社区工坊\n排期台'
                        : '社区工坊排期台',
                    style: Theme.of(context).textTheme.displaySmall
                        ?.copyWith(color: dispatchPaper),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '两天、三处场馆，一次看清全部冲突。',
                    style: TextStyle(color: Color(0xFFD5E4E9), fontSize: 15),
                  ),
                ],
              );
              final actions = Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  OutlinedButton.icon(
                    key: const ValueKey('restore-demo-data'),
                    onPressed: onRestore,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: dispatchPaper,
                      side: const BorderSide(color: dispatchPaper),
                    ),
                    icon: const Icon(Icons.restart_alt),
                    label: const Text('恢复演示数据'),
                  ),
                  FilledButton.icon(
                    key: const ValueKey('create-session'),
                    onPressed: onCreate,
                    style: FilledButton.styleFrom(
                      backgroundColor: dispatchOrange,
                      foregroundColor: dispatchInk,
                    ),
                    icon: const Icon(Icons.add),
                    label: const Text('新建排期'),
                  ),
                ],
              );
              if (compact) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [title, const SizedBox(height: 18), actions],
                );
              }
              return Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(child: title),
                  const SizedBox(width: 24),
                  actions,
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _FilterDesk extends StatelessWidget {
  const _FilterDesk({
    required this.catalog,
    required this.dayId,
    required this.venueId,
    required this.instructorId,
    required this.onDayChanged,
    required this.onVenueChanged,
    required this.onInstructorChanged,
  });

  final WorkshopCatalog catalog;
  final String? dayId;
  final String? venueId;
  final String? instructorId;
  final ValueChanged<String?> onDayChanged;
  final ValueChanged<String?> onVenueChanged;
  final ValueChanged<String?> onInstructorChanged;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1320),
        child: Container(
          margin: const EdgeInsets.all(18),
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            color: dispatchBlueDeep,
            borderRadius: BorderRadius.all(Radius.circular(8)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.tune, color: dispatchGreen),
                  SizedBox(width: 8),
                  Text(
                    '筛选工作面',
                    style: TextStyle(
                      color: dispatchPaper,
                      fontWeight: FontWeight.w800,
                      fontSize: 17,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              LayoutBuilder(
                builder: (context, constraints) {
                  final fieldWidth = constraints.maxWidth < 680
                      ? constraints.maxWidth
                      : 210.0;
                  return Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      _FilterField(
                        width: fieldWidth,
                        label: '活动日',
                        child: DropdownButtonFormField<String?>(
                          key: const ValueKey('day-filter'),
                          initialValue: dayId,
                          isExpanded: true,
                          items: [
                            const DropdownMenuItem(
                              value: null,
                              child: Text('全部活动日'),
                            ),
                            for (final day in catalog.days)
                              DropdownMenuItem(
                                value: day.id,
                                child: Text(day.label),
                              ),
                          ],
                          onChanged: onDayChanged,
                        ),
                      ),
                      _FilterField(
                        width: fieldWidth,
                        label: '场馆',
                        child: DropdownButtonFormField<String?>(
                          key: const ValueKey('venue-filter'),
                          initialValue: venueId,
                          isExpanded: true,
                          items: [
                            const DropdownMenuItem(
                              value: null,
                              child: Text('全部场馆'),
                            ),
                            for (final venue in catalog.venues)
                              DropdownMenuItem(
                                value: venue.id,
                                child: Text(venue.name),
                              ),
                          ],
                          onChanged: onVenueChanged,
                        ),
                      ),
                      _FilterField(
                        width: fieldWidth,
                        label: '讲师',
                        child: DropdownButtonFormField<String?>(
                          key: const ValueKey('instructor-filter'),
                          initialValue: instructorId,
                          isExpanded: true,
                          items: [
                            const DropdownMenuItem(
                              value: null,
                              child: Text('全部讲师'),
                            ),
                            for (final instructor in catalog.instructors)
                              DropdownMenuItem(
                                value: instructor.id,
                                child: Text(instructor.name),
                              ),
                          ],
                          onChanged: onInstructorChanged,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FilterField extends StatelessWidget {
  const _FilterField({
    required this.width,
    required this.label,
    required this.child,
  });

  final double width;
  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Color(0xFFD5E4E9))),
          const SizedBox(height: 6),
          child,
        ],
      ),
    );
  }
}

// #region responsive-schedule-content
class _ScheduleContent extends StatelessWidget {
  const _ScheduleContent({required this.catalog, required this.entries});

  final WorkshopCatalog catalog;
  final List<ScheduleEntry> entries;

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) return const _EmptySchedule();
    return Semantics(
      key: const ValueKey('schedule-result-status'),
      liveRegion: true,
      label: '当前显示 ${entries.length} 个场次',
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1320),
          child: LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth >= 980) {
                return _WideScheduleWall(catalog: catalog, entries: entries);
              }
              return _CompactScheduleAgenda(catalog: catalog, entries: entries);
            },
          ),
        ),
      ),
    );
  }
}
// #endregion responsive-schedule-content

class _WideScheduleWall extends StatelessWidget {
  const _WideScheduleWall({required this.catalog, required this.entries});

  final WorkshopCatalog catalog;
  final List<ScheduleEntry> entries;

  @override
  Widget build(BuildContext context) {
    final dayIds = entries.map((entry) => entry.dayId).toSet();
    return Semantics(
      container: true,
      label: '宽屏场馆排期墙，共 ${entries.length} 个场次',
      child: Column(
        key: const ValueKey('wide-schedule-wall'),
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final day in catalog.days.where(
            (day) => dayIds.contains(day.id),
          )) ...[
            _DayTimeline(
              day: day,
              catalog: catalog,
              entries: entries.where((entry) => entry.dayId == day.id).toList(),
            ),
            const SizedBox(height: 24),
          ],
        ],
      ),
    );
  }
}

class _DayTimeline extends StatelessWidget {
  const _DayTimeline({
    required this.day,
    required this.catalog,
    required this.entries,
  });

  final EventDay day;
  final WorkshopCatalog catalog;
  final List<ScheduleEntry> entries;

  @override
  Widget build(BuildContext context) {
    final visibleVenueIds = entries.map((entry) => entry.venueId).toSet();
    final venues = catalog.venues
        .where((venue) => visibleVenueIds.contains(venue.id))
        .toList();
    return Container(
      decoration: BoxDecoration(
        color: dispatchPaper,
        border: Border.all(color: dispatchInk, width: 2),
        borderRadius: const BorderRadius.all(Radius.circular(8)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            color: dispatchBlue,
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            child: Text(
              day.label,
              style: Theme.of(context).textTheme.headlineSmall
                  ?.copyWith(color: Colors.white),
            ),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(width: 64, child: _TimeRail()),
              for (final venue in venues)
                Expanded(
                  child: _VenueTimeline(
                    venue: venue,
                    catalog: catalog,
                    entries: entries
                        .where((entry) => entry.venueId == venue.id)
                        .toList(),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TimeRail extends StatelessWidget {
  const _TimeRail();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 58),
        SizedBox(
          height: 540,
          child: Stack(
            children: [
              for (var hour = 9; hour <= 18; hour++)
                Positioned(
                  top: (hour - 9) * 60.0 - (hour == 18 ? 18 : 0),
                  left: 10,
                  child: Text(
                    '${hour.toString().padLeft(2, '0')}:00',
                    style: const TextStyle(
                      color: dispatchSteel,
                      fontFeatures: [FontFeature.tabularFigures()],
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _VenueTimeline extends StatelessWidget {
  const _VenueTimeline({
    required this.venue,
    required this.catalog,
    required this.entries,
  });

  final Venue venue;
  final WorkshopCatalog catalog;
  final List<ScheduleEntry> entries;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(left: BorderSide(color: dispatchRule)),
      ),
      child: Column(
        children: [
          Container(
            height: 58,
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            color: dispatchEnamel,
            child: Text(
              '${venue.name} · ${venue.capacity} 人',
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
          SizedBox(
            height: 540,
            child: Stack(
              children: [
                for (var hour = 0; hour <= 9; hour++)
                  Positioned(
                    left: 0,
                    right: 0,
                    top: hour * 60.0,
                    child: const Divider(height: 1, color: Color(0xFFD3D7D3)),
                  ),
                for (final entry in entries)
                  Positioned(
                    top: (entry.startMinute - 540).toDouble() + 4,
                    left: 8,
                    right: 8,
                    height:
                        (entry.endMinute - entry.startMinute).toDouble() - 8,
                    child: _ScheduleStrip(entry: entry, catalog: catalog),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ScheduleStrip extends StatelessWidget {
  const _ScheduleStrip({required this.entry, required this.catalog});

  final ScheduleEntry entry;
  final WorkshopCatalog catalog;

  @override
  Widget build(BuildContext context) {
    final workshop = catalog.workshop(entry.workshopId)!;
    final instructor = catalog.instructor(entry.instructorId)!;
    return Semantics(
      button: true,
      label:
          '${formatMinutes(entry.startMinute)} 到 ${formatMinutes(entry.endMinute)}，${workshop.title}，讲师 ${instructor.name}',
      child: Material(
        color: dispatchGreen,
        borderRadius: const BorderRadius.all(Radius.circular(6)),
        child: InkWell(
          key: ValueKey('session-strip-${entry.id}'),
          borderRadius: const BorderRadius.all(Radius.circular(6)),
          onTap: () => context.push('/sessions/${entry.id}'),
          child: Padding(
            padding: const EdgeInsets.all(9),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${formatMinutes(entry.startMinute)}–${formatMinutes(entry.endMinute)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 3),
                Flexible(
                  child: Text(
                    workshop.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w900),
                  ),
                ),
                if (entry.endMinute - entry.startMinute >= 90)
                  Text(instructor.name, style: const TextStyle(fontSize: 12)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CompactScheduleAgenda extends StatelessWidget {
  const _CompactScheduleAgenda({required this.catalog, required this.entries});

  final WorkshopCatalog catalog;
  final List<ScheduleEntry> entries;

  @override
  Widget build(BuildContext context) {
    final dayIds = entries.map((entry) => entry.dayId).toSet();
    return Semantics(
      container: true,
      label: '分组议程，共 ${entries.length} 个场次',
      child: Column(
        key: const ValueKey('compact-schedule-agenda'),
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final day in catalog.days.where(
            (day) => dayIds.contains(day.id),
          )) ...[
            Container(
              color: dispatchBlue,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Text(
                day.label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            for (final entry in entries.where((entry) => entry.dayId == day.id))
              _AgendaRow(entry: entry, catalog: catalog),
            const SizedBox(height: 20),
          ],
        ],
      ),
    );
  }
}

class _AgendaRow extends StatelessWidget {
  const _AgendaRow({required this.entry, required this.catalog});

  final ScheduleEntry entry;
  final WorkshopCatalog catalog;

  @override
  Widget build(BuildContext context) {
    final workshop = catalog.workshop(entry.workshopId)!;
    final venue = catalog.venue(entry.venueId)!;
    final instructor = catalog.instructor(entry.instructorId)!;
    return Material(
      color: dispatchPaper,
      child: InkWell(
        key: ValueKey('agenda-session-${entry.id}'),
        onTap: () => context.push('/sessions/${entry.id}'),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: dispatchRule)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 62,
                child: Text(
                  formatMinutes(entry.startMinute),
                  style: const TextStyle(
                    color: dispatchBlue,
                    fontWeight: FontWeight.w900,
                    fontFeatures: [FontFeature.tabularFigures()],
                  ),
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      workshop.title,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 5),
                    Text(
                      '${venue.name} · ${instructor.name} · ${entry.expectedAttendees} 人',
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptySchedule extends StatelessWidget {
  const _EmptySchedule();

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const ValueKey('empty-schedule'),
      padding: const EdgeInsets.all(28),
      color: dispatchPaper,
      child: const Column(
        children: [
          Icon(Icons.filter_alt_off_outlined, size: 44),
          SizedBox(height: 12),
          Text(
            '当前筛选下没有场次',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
          ),
          SizedBox(height: 6),
          Text('换一个活动日、场馆或讲师，排期数据本身不会改变。'),
        ],
      ),
    );
  }
}

class _BoardLoading extends StatelessWidget {
  const _BoardLoading({this.compact = false});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(compact ? 32 : 64),
        child: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 14),
            Text('正在读取本地排期…'),
          ],
        ),
      ),
    );
  }
}

class _InitialFailure extends StatelessWidget {
  const _InitialFailure({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.storage_outlined, size: 48),
            const SizedBox(height: 14),
            Text('本地排期暂时打不开', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 8),
            const Text('没有数据被覆盖。重试会重新打开目录和本地数据库。'),
            const SizedBox(height: 18),
            FilledButton.icon(
              key: const ValueKey('retry-initial-load'),
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('重试'),
            ),
          ],
        ),
      ),
    );
  }
}

class _StreamFailure extends StatelessWidget {
  const _StreamFailure({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const ValueKey('schedule-stream-failure'),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFFFE4D0),
        border: Border.all(color: dispatchRed, width: 2),
      ),
      child: Column(
        children: [
          const Text(
            '排期读取中断',
            style: TextStyle(fontSize: 19, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 6),
          const Text('筛选没有被清空。重新订阅本地排期即可继续。'),
          const SizedBox(height: 14),
          FilledButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text('重新读取'),
          ),
        ],
      ),
    );
  }
}

String formatMinutes(int minute) {
  final hour = minute ~/ 60;
  final remainder = minute % 60;
  return '${hour.toString().padLeft(2, '0')}:${remainder.toString().padLeft(2, '0')}';
}
