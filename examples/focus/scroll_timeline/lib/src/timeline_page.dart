import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'timeline_data.dart';
import 'timeline_painter.dart';
import 'timeline_providers.dart';
import 'timeline_theme.dart';

class TimelinePage extends ConsumerStatefulWidget {
  const TimelinePage({super.key});

  @override
  ConsumerState<TimelinePage> createState() => _TimelinePageState();
}

class _TimelinePageState extends ConsumerState<TimelinePage> {
  late final ScrollController _scrollController;
  late final Map<String, GlobalKey> _eraKeys;
  late final Map<String, FocusNode> _eraFocusNodes;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _eraKeys = {for (final era in timelineEras) era.id: GlobalKey()};
    _eraFocusNodes = {
      for (final era in timelineEras)
        era.id: FocusNode(debugLabel: 'era-${era.id}'),
    };
  }

  @override
  void dispose() {
    _scrollController.dispose();
    for (final node in _eraFocusNodes.values) {
      node.dispose();
    }
    super.dispose();
  }

  // #region timeline-directory-focus
  Future<void> _jumpToEra(TimelineEra era) async {
    final targetContext = _eraKeys[era.id]!.currentContext;
    if (targetContext == null) return;
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    await Scrollable.ensureVisible(
      targetContext,
      alignment: 0.08,
      duration: reduceMotion
          ? Duration.zero
          : const Duration(milliseconds: 420),
      curve: Curves.easeOutCubic,
    );
    if (!mounted) return;
    _eraFocusNodes[era.id]!.requestFocus();
  }
  // #endregion timeline-directory-focus

  @override
  Widget build(BuildContext context) {
    final selectedTopics = ref.watch(selectedTopicsProvider);
    final events = ref.watch(filteredTimelineProvider);

    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final wide = constraints.maxWidth >= 980;
            final scroll = _TimelineScroll(
              controller: _scrollController,
              eraKeys: _eraKeys,
              eraFocusNodes: _eraFocusNodes,
              events: events,
              selectedTopics: selectedTopics,
              showPinnedDirectory: !wide,
              onJumpToEra: _jumpToEra,
            );

            if (!wide) return scroll;
            return Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  width: 286,
                  child: _ArchiveRail(
                    selectedTopics: selectedTopics,
                    onJumpToEra: _jumpToEra,
                  ),
                ),
                const VerticalDivider(width: 1, color: archiveRule),
                Expanded(child: scroll),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _ArchiveRail extends ConsumerWidget {
  const _ArchiveRail({required this.selectedTopics, required this.onJumpToEra});

  final Set<TimelineTopic> selectedTopics;
  final ValueChanged<TimelineEra> onJumpToEra;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ColoredBox(
      color: archiveCharcoal,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(22, 26, 22, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              '长卷时间轴',
              style: Theme.of(context).textTheme.headlineSmall
                  ?.copyWith(color: archivePaperBright),
            ),
            const SizedBox(height: 8),
            Text(
              '目录与主题筛选',
              style: Theme.of(context).textTheme.bodyMedium
                  ?.copyWith(color: const Color(0xFFD4CEC2)),
            ),
            const SizedBox(height: 28),
            _TopicFilters(selectedTopics: selectedTopics, dark: true),
            const SizedBox(height: 30),
            for (final era in timelineEras)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: TextButton(
                  onPressed: () => onJumpToEra(era),
                  style: TextButton.styleFrom(
                    alignment: Alignment.centerLeft,
                    foregroundColor: archivePaperBright,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 14,
                    ),
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(8)),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${era.startYear}—${era.endYear}',
                        style: const TextStyle(
                          color: Color(0xFFB9CBC7),
                          fontFeatures: [FontFeature.tabularFigures()],
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(era.title),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _TimelineScroll extends ConsumerWidget {
  const _TimelineScroll({
    required this.controller,
    required this.eraKeys,
    required this.eraFocusNodes,
    required this.events,
    required this.selectedTopics,
    required this.showPinnedDirectory,
    required this.onJumpToEra,
  });

  final ScrollController controller;
  final Map<String, GlobalKey> eraKeys;
  final Map<String, FocusNode> eraFocusNodes;
  final List<TimelineEvent> events;
  final Set<TimelineTopic> selectedTopics;
  final bool showPinnedDirectory;
  final ValueChanged<TimelineEra> onJumpToEra;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textScale = MediaQuery.textScalerOf(context).scale(1);
    final directoryHeight = (76 * textScale).clamp(76.0, 132.0);
    final eventsByEra = {
      for (final era in timelineEras)
        era.id: events
            .where((event) => event.eraId == era.id)
            .toList(growable: false),
    };

    // #region timeline-sliver-composition
    return ColoredBox(
      color: archivePaper,
      child: CustomPaint(
        painter: TimelineProgressPainter(controller: controller),
        child: CustomScrollView(
          key: const ValueKey('timeline-scroll'),
          controller: controller,
          slivers: [
            const SliverToBoxAdapter(child: _TimelineHero()),
            if (showPinnedDirectory)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(38, 0, 20, 18),
                  child: _TopicFilters(selectedTopics: selectedTopics),
                ),
              ),
            if (showPinnedDirectory)
              SliverPersistentHeader(
                pinned: true,
                delegate: _DirectoryHeaderDelegate(
                  height: directoryHeight,
                  onJumpToEra: onJumpToEra,
                ),
              ),
            if (events.isEmpty)
              const SliverFillRemaining(
                hasScrollBody: false,
                child: _TimelineEmptyState(),
              )
            else
              for (final era in timelineEras) ...[
                SliverToBoxAdapter(
                  child: _EraHeader(
                    key: eraKeys[era.id],
                    era: era,
                    focusNode: eraFocusNodes[era.id]!,
                    count: eventsByEra[era.id]!.length,
                  ),
                ),
                SliverList.builder(
                  itemCount: eventsByEra[era.id]!.length,
                  itemBuilder: (context, index) =>
                      _TimelineEventRow(event: eventsByEra[era.id]![index]),
                ),
              ],
            const SliverToBoxAdapter(child: _ArchiveFooter()),
          ],
        ),
      ),
    );
    // #endregion timeline-sliver-composition
  }
}

class _TimelineHero extends StatelessWidget {
  const _TimelineHero();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(54, 42, 28, 34),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 920),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('河岸修复六十年', style: Theme.of(context).textTheme.displayLarge),
            const SizedBox(height: 16),
            Text(
              '从封堵、清淤到共治课堂，72 份档案沿着同一条河岸展开。主题筛选不会改写顺序，目录跳转会把焦点送到阶段标题。',
              style: Theme.of(context).textTheme.bodyLarge
                  ?.copyWith(color: archiveCharcoalSoft),
            ),
            const SizedBox(height: 24),
            const Wrap(
              spacing: 18,
              runSpacing: 8,
              children: [
                _ArchiveStamp(label: '1965—2024'),
                _ArchiveStamp(label: '6 个阶段'),
                _ArchiveStamp(label: '72 份档案'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ArchiveStamp extends StatelessWidget {
  const _ArchiveStamp({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: mineralBlueDeep),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Text(
          label,
          style: const TextStyle(
            color: mineralBlueDeep,
            fontWeight: FontWeight.w800,
            fontFeatures: [FontFeature.tabularFigures()],
          ),
        ),
      ),
    );
  }
}

class _TopicFilters extends ConsumerWidget {
  const _TopicFilters({required this.selectedTopics, this.dark = false});

  final Set<TimelineTopic> selectedTopics;
  final bool dark;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(selectedTopicsProvider.notifier);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          selectedTopics.isEmpty
              ? '当前显示全部主题'
              : '已选 ${selectedTopics.length} 个主题',
          style: Theme.of(context).textTheme.labelLarge
              ?.copyWith(color: dark ? archivePaperBright : archiveCharcoal),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final topic in TimelineTopic.values)
              FilterChip(
                key: ValueKey('topic-${topic.name}'),
                label: Text(topic.label),
                selected: selectedTopics.contains(topic),
                onSelected: (_) => controller.toggle(topic),
                backgroundColor: dark
                    ? archiveCharcoalSoft
                    : archivePaperBright,
                labelStyle: TextStyle(
                  color: selectedTopics.contains(topic)
                      ? archivePaperBright
                      : dark
                      ? archivePaperBright
                      : archiveCharcoal,
                  fontWeight: FontWeight.w700,
                ),
              ),
            if (selectedTopics.isNotEmpty)
              TextButton(
                onPressed: controller.clear,
                style: TextButton.styleFrom(
                  foregroundColor: dark ? const Color(0xFFF0C5A9) : copper,
                ),
                child: const Text('恢复全部'),
              ),
          ],
        ),
      ],
    );
  }
}

class _DirectoryHeaderDelegate extends SliverPersistentHeaderDelegate {
  _DirectoryHeaderDelegate({required this.height, required this.onJumpToEra});

  final double height;
  final ValueChanged<TimelineEra> onJumpToEra;

  @override
  double get minExtent => height;

  @override
  double get maxExtent => height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Material(
      color: archiveCharcoal,
      elevation: overlapsContent ? 6 : 0,
      child: Align(
        alignment: Alignment.centerLeft,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 10),
          child: Row(
            children: [
              for (final era in timelineEras)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: TextButton(
                    onPressed: () => onJumpToEra(era),
                    key: ValueKey('directory-${era.id}'),
                    style: TextButton.styleFrom(
                      foregroundColor: archivePaperBright,
                      side: const BorderSide(color: Color(0xFF69736E)),
                    ),
                    child: Text(era.title),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(_DirectoryHeaderDelegate oldDelegate) {
    return oldDelegate.height != height ||
        oldDelegate.onJumpToEra != onJumpToEra;
  }
}

class _EraHeader extends StatelessWidget {
  const _EraHeader({
    super.key,
    required this.era,
    required this.focusNode,
    required this.count,
  });

  final TimelineEra era;
  final FocusNode focusNode;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Focus(
      key: ValueKey('era-focus-${era.id}'),
      focusNode: focusNode,
      child: Builder(
        builder: (context) {
          final focused = Focus.of(context).hasFocus;
          return Semantics(
            key: ValueKey('era-semantics-${era.id}'),
            header: true,
            label: '${era.title}，${era.startYear} 到 ${era.endYear}，$count 份档案',
            child: AnimatedContainer(
              duration: MediaQuery.disableAnimationsOf(context)
                  ? Duration.zero
                  : const Duration(milliseconds: 180),
              margin: const EdgeInsets.fromLTRB(48, 34, 22, 0),
              padding: const EdgeInsets.fromLTRB(22, 22, 22, 20),
              decoration: BoxDecoration(
                color: mineralBlueDeep,
                borderRadius: BorderRadius.circular(12),
                border: focused
                    ? Border.all(color: copper, width: 4)
                    : Border.all(color: mineralBlueDeep),
              ),
              child: Wrap(
                spacing: 24,
                runSpacing: 12,
                crossAxisAlignment: WrapCrossAlignment.end,
                children: [
                  SizedBox(
                    width: 220,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${era.startYear}—${era.endYear}',
                          style: const TextStyle(
                            color: Color(0xFFC8DCD7),
                            fontWeight: FontWeight.w800,
                            fontFeatures: [FontFeature.tabularFigures()],
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          era.title,
                          style: Theme.of(context).textTheme.headlineLarge
                              ?.copyWith(color: archivePaperBright),
                        ),
                      ],
                    ),
                  ),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 520),
                    child: Text(
                      era.summary,
                      style: Theme.of(context).textTheme.bodyLarge
                          ?.copyWith(color: const Color(0xFFE2E5DD)),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _TimelineEventRow extends StatelessWidget {
  const _TimelineEventRow({required this.event});

  final TimelineEvent event;

  Color get _topicColor => switch (event.topic) {
    TimelineTopic.ecology => moss,
    TimelineTopic.engineering => mineralBlue,
    TimelineTopic.community => copper,
    TimelineTopic.memory => const Color(0xFF78618A),
  };

  @override
  Widget build(BuildContext context) {
    return Semantics(
      key: ValueKey('event-semantics-${event.id}'),
      container: true,
      label:
          '${event.year} 年，${event.title}，${event.topic.label}。${event.summary}',
      child: Padding(
        key: ValueKey(event.id),
        padding: const EdgeInsets.fromLTRB(48, 0, 22, 0),
        child: DecoratedBox(
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: archiveRule)),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 22),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 78,
                  child: Text(
                    '${event.year}',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: mineralBlueDeep,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                ),
                Container(
                  width: 12,
                  height: 12,
                  margin: const EdgeInsets.only(top: 7, right: 18),
                  decoration: BoxDecoration(
                    color: _topicColor,
                    shape: BoxShape.circle,
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        event.topic.label,
                        style: Theme.of(context).textTheme.labelLarge
                            ?.copyWith(color: _topicColor),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        event.title,
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 7),
                      Text(
                        event.summary,
                        style: Theme.of(context).textTheme.bodyMedium
                            ?.copyWith(color: archiveCharcoalSoft),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TimelineEmptyState extends ConsumerWidget {
  const _TimelineEmptyState();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('没有符合条件的档案', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 10),
            const Text('恢复全部主题，重新查看完整长卷。'),
            const SizedBox(height: 18),
            FilledButton(
              onPressed: ref.read(selectedTopicsProvider.notifier).clear,
              child: const Text('恢复全部'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ArchiveFooter extends StatelessWidget {
  const _ArchiveFooter();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(48, 42, 22, 56),
      child: Text(
        '档案截至 2024 年。所有人物、地点与记录均为教学用虚构数据。',
        style: Theme.of(context).textTheme.bodyMedium
            ?.copyWith(color: archiveCharcoalSoft),
      ),
    );
  }
}
