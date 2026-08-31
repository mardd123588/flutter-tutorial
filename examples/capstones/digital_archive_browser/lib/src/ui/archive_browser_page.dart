import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../domain/archive_models.dart';
import '../domain/archive_query.dart';
import '../state/archive_providers.dart';
import 'archive_theme.dart';
import 'archive_thumbnail_painter.dart';

class ArchiveBrowserPage extends ConsumerStatefulWidget {
  const ArchiveBrowserPage({super.key, required this.uri});

  final Uri uri;

  @override
  ConsumerState<ArchiveBrowserPage> createState() => _ArchiveBrowserPageState();
}

class _ArchiveBrowserPageState extends ConsumerState<ArchiveBrowserPage> {
  late final FocusNode _comparisonErrorFocus;
  String? _comparisonError;

  @override
  void initState() {
    super.initState();
    _comparisonErrorFocus = FocusNode(debugLabel: 'comparison-limit-error');
  }

  @override
  void dispose() {
    _comparisonErrorFocus.dispose();
    super.dispose();
  }

  void _replaceQuery(ArchiveQuery query) {
    context.go(query.toUri().toString());
  }

  void _addComparison(ArchiveRecord record, Set<String> knownIds) {
    final outcome = ref
        .read(archiveComparisonProvider.notifier)
        .add(record.id, knownIds);
    setState(() {
      _comparisonError = outcome == ComparisonOutcome.limitReached
          ? '对照栏最多放 3 条记录。移除一条后可以继续添加。'
          : null;
    });
    if (_comparisonError != null) {
      _comparisonErrorFocus.requestFocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    final query = ref.watch(archiveQueryProvider(widget.uri));
    final records = ref.watch(filteredArchiveProvider(query));
    final comparison = ref.watch(archiveComparisonProvider);

    return Scaffold(
      bottomNavigationBar: comparison.ids.isEmpty
          ? null
          : _ComparisonBar(query: query, comparison: comparison),
      body: SafeArea(
        child: records.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stackTrace) => _ArchiveLoadError(
            onRetry: () => ref.invalidate(archiveRecordsProvider),
          ),
          data: (filtered) {
            final allRecords =
                ref.read(archiveRecordsProvider).value ?? filtered;
            return LayoutBuilder(
              builder: (context, constraints) {
                final wide = constraints.maxWidth >= 1050;
                final content = _ArchiveResults(
                  query: query,
                  records: filtered,
                  allRecordIds: allRecords.map((record) => record.id).toSet(),
                  comparison: comparison,
                  comparisonError: _comparisonError,
                  comparisonErrorFocus: _comparisonErrorFocus,
                  onQueryChanged: _replaceQuery,
                  onAddComparison: _addComparison,
                  showCompactFilters: !wide,
                );
                if (!wide) return content;
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(
                      width: 292,
                      child: _FilterRail(
                        query: query,
                        onChanged: _replaceQuery,
                      ),
                    ),
                    const VerticalDivider(width: 1, color: rule),
                    Expanded(child: content),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _FilterRail extends StatelessWidget {
  const _FilterRail({required this.query, required this.onChanged});

  final ArchiveQuery query;
  final ValueChanged<ArchiveQuery> onChanged;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: ink,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(22, 30, 22, 36),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              '数字档案\n阅览室',
              style: Theme.of(context).textTheme.headlineMedium
                  ?.copyWith(color: paper),
            ),
            const SizedBox(height: 8),
            const Text(
              '120 条固定馆藏 · 本地教学数据',
              style: TextStyle(color: cyanLight),
            ),
            const SizedBox(height: 30),
            _FilterControls(query: query, onChanged: onChanged, dark: true),
          ],
        ),
      ),
    );
  }
}

// #region archive-mixed-slivers
class _ArchiveResults extends StatelessWidget {
  const _ArchiveResults({
    required this.query,
    required this.records,
    required this.allRecordIds,
    required this.comparison,
    required this.comparisonError,
    required this.comparisonErrorFocus,
    required this.onQueryChanged,
    required this.onAddComparison,
    required this.showCompactFilters,
  });

  final ArchiveQuery query;
  final List<ArchiveRecord> records;
  final Set<String> allRecordIds;
  final ArchiveComparison comparison;
  final String? comparisonError;
  final FocusNode comparisonErrorFocus;
  final ValueChanged<ArchiveQuery> onQueryChanged;
  final void Function(ArchiveRecord, Set<String>) onAddComparison;
  final bool showCompactFilters;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final effectiveGrid =
            query.view == ArchiveView.grid && constraints.maxWidth >= 600;
        final textScale = MediaQuery.textScalerOf(context).scale(1);
        final summaryHeight = (70 * textScale).clamp(70.0, 118.0);
        final grouped = {
          for (final era in ArchiveEra.values)
            era: records
                .where((record) => record.era == era)
                .toList(growable: false),
        };
        final scroll = CustomScrollView(
          key: const ValueKey('archive-results-scroll'),
          slivers: [
            SliverToBoxAdapter(
              child: _ArchiveHeader(
                query: query,
                showCompactFilters: showCompactFilters,
                onChanged: onQueryChanged,
              ),
            ),
            SliverPersistentHeader(
              pinned: true,
              delegate: _ResultSummaryDelegate(
                height: summaryHeight,
                count: records.length,
                query: query,
                onChanged: onQueryChanged,
              ),
            ),
            if (records.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: _EmptyArchive(
                  onReset: () => onQueryChanged(const ArchiveQuery()),
                ),
              )
            else
              for (final era in ArchiveEra.values)
                if (grouped[era]!.isNotEmpty) ...[
                  SliverToBoxAdapter(
                    child: _EraLabel(era: era, count: grouped[era]!.length),
                  ),
                  if (effectiveGrid)
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(28, 0, 28, 20),
                      sliver: SliverGrid.builder(
                        itemCount: grouped[era]!.length,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: constraints.maxWidth >= 1080 ? 3 : 2,
                          mainAxisExtent: 272,
                          crossAxisSpacing: 14,
                          mainAxisSpacing: 14,
                        ),
                        itemBuilder: (context, index) => _ArchiveRecordCard(
                          record: grouped[era]![index],
                          compact: true,
                          stacked: false,
                          selected: comparison.ids.contains(
                            grouped[era]![index].id,
                          ),
                          query: query,
                          onCompare: () => onAddComparison(
                            grouped[era]![index],
                            allRecordIds,
                          ),
                        ),
                      ),
                    )
                  else
                    SliverList.builder(
                      itemCount: grouped[era]!.length,
                      itemBuilder: (context, index) => Padding(
                        padding: const EdgeInsets.fromLTRB(28, 0, 28, 12),
                        child: _ArchiveRecordCard(
                          record: grouped[era]![index],
                          compact: false,
                          stacked: constraints.maxWidth < 520,
                          selected: comparison.ids.contains(
                            grouped[era]![index].id,
                          ),
                          query: query,
                          onCompare: () => onAddComparison(
                            grouped[era]![index],
                            allRecordIds,
                          ),
                        ),
                      ),
                    ),
                ],
            const SliverToBoxAdapter(child: SizedBox(height: 48)),
          ],
        );
        if (comparisonError == null) return scroll;
        return Column(
          children: [
            _ComparisonLimitBanner(
              message: comparisonError!,
              focusNode: comparisonErrorFocus,
              onRecover: comparison.ids.isEmpty
                  ? null
                  : () => context.readComparison().remove(comparison.ids.first),
            ),
            Expanded(child: scroll),
          ],
        );
      },
    );
  }
}
// #endregion archive-mixed-slivers

// #region archive-comparison-feedback
class _ComparisonLimitBanner extends StatelessWidget {
  const _ComparisonLimitBanner({
    required this.message,
    required this.focusNode,
    required this.onRecover,
  });

  final String message;
  final FocusNode focusNode;
  final VoidCallback? onRecover;

  @override
  Widget build(BuildContext context) {
    return Focus(
      focusNode: focusNode,
      child: Semantics(
        key: const ValueKey('comparison-limit-status'),
        liveRegion: true,
        container: true,
        label: message,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFFFFE7DE),
            border: Border(
              bottom: BorderSide(color: Theme.of(context).colorScheme.error),
            ),
          ),
          child: Wrap(
            spacing: 12,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(message),
              TextButton(
                key: const ValueKey('comparison-recovery'),
                onPressed: onRecover,
                child: const Text('移除最早一条'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
// #endregion archive-comparison-feedback

class _ArchiveHeader extends StatelessWidget {
  const _ArchiveHeader({
    required this.query,
    required this.showCompactFilters,
    required this.onChanged,
  });

  final ArchiveQuery query;
  final bool showCompactFilters;
  final ValueChanged<ArchiveQuery> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(30, 34, 30, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('城市公共档案', style: Theme.of(context).textTheme.displayMedium),
          const SizedBox(height: 10),
          const Text('搜索题名与人物，按年代、馆藏和开放状态缩小范围。链接会保留当前阅览条件。'),
          const SizedBox(height: 22),
          _ArchiveSearchField(query: query, onChanged: onChanged),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              if (showCompactFilters)
                OutlinedButton.icon(
                  key: const ValueKey('open-filter-sheet'),
                  onPressed: () => showModalBottomSheet<void>(
                    context: context,
                    isScrollControlled: true,
                    builder: (context) => SafeArea(
                      child: SingleChildScrollView(
                        padding: EdgeInsets.fromLTRB(
                          22,
                          26,
                          22,
                          28 + MediaQuery.viewInsetsOf(context).bottom,
                        ),
                        child: _FilterControls(
                          query: query,
                          onChanged: onChanged,
                        ),
                      ),
                    ),
                  ),
                  icon: const Icon(Icons.tune),
                  label: const Text('筛选'),
                ),
              SizedBox(
                width: 250,
                child: SegmentedButton<ArchiveView>(
                  key: const ValueKey('archive-view-toggle'),
                  segments: const [
                    ButtonSegment(
                      value: ArchiveView.list,
                      icon: Icon(Icons.view_agenda_outlined),
                      label: Text('列表'),
                    ),
                    ButtonSegment(
                      value: ArchiveView.grid,
                      icon: Icon(Icons.grid_view_outlined),
                      label: Text('网格'),
                    ),
                  ],
                  selected: {query.view},
                  onSelectionChanged: (value) =>
                      onChanged(query.copyWith(view: value.single)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ArchiveSearchField extends StatefulWidget {
  const _ArchiveSearchField({required this.query, required this.onChanged});

  final ArchiveQuery query;
  final ValueChanged<ArchiveQuery> onChanged;

  @override
  State<_ArchiveSearchField> createState() => _ArchiveSearchFieldState();
}

class _ArchiveSearchFieldState extends State<_ArchiveSearchField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.query.search);
  }

  @override
  void didUpdateWidget(_ArchiveSearchField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_controller.text != widget.query.search) {
      _controller.value = TextEditingValue(
        text: widget.query.search,
        selection: TextSelection.collapsed(offset: widget.query.search.length),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 720),
      child: TextField(
        key: const ValueKey('archive-search'),
        controller: _controller,
        textInputAction: TextInputAction.search,
        onChanged: (value) =>
            widget.onChanged(widget.query.copyWith(search: value)),
        onSubmitted: (value) =>
            widget.onChanged(widget.query.copyWith(search: value)),
        decoration: InputDecoration(
          labelText: '搜索题名、人物或摘要',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: IconButton(
            tooltip: '提交搜索',
            onPressed: () => widget.onChanged(
              widget.query.copyWith(search: _controller.text),
            ),
            icon: const Icon(Icons.arrow_forward),
          ),
        ),
      ),
    );
  }
}

class _FilterControls extends StatelessWidget {
  const _FilterControls({
    required this.query,
    required this.onChanged,
    this.dark = false,
  });

  final ArchiveQuery query;
  final ValueChanged<ArchiveQuery> onChanged;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    final labelColor = dark ? paper : ink;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          '缩小范围',
          style: Theme.of(context).textTheme.titleMedium
              ?.copyWith(color: labelColor),
        ),
        const SizedBox(height: 14),
        _ArchiveDropdown<ArchiveEra>(
          key: ValueKey('era-filter-${query.era?.slug ?? 'all'}'),
          label: '年代',
          value: query.era,
          values: ArchiveEra.values,
          readLabel: (value) => value.label,
          onChanged: (value) => onChanged(query.copyWith(era: () => value)),
        ),
        const SizedBox(height: 12),
        _ArchiveDropdown<ArchiveCollection>(
          key: ValueKey('collection-filter-${query.collection?.slug ?? 'all'}'),
          label: '馆藏',
          value: query.collection,
          values: ArchiveCollection.values,
          readLabel: (value) => value.label,
          onChanged: (value) =>
              onChanged(query.copyWith(collection: () => value)),
        ),
        const SizedBox(height: 12),
        _ArchiveDropdown<ArchiveAccess>(
          key: ValueKey('access-filter-${query.access?.slug ?? 'all'}'),
          label: '开放状态',
          value: query.access,
          values: ArchiveAccess.values,
          readLabel: (value) => value.label,
          onChanged: (value) => onChanged(query.copyWith(access: () => value)),
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<ArchiveSort>(
          key: ValueKey('sort-filter-${query.sort.slug}'),
          initialValue: query.sort,
          decoration: const InputDecoration(labelText: '排序'),
          items: [
            for (final value in ArchiveSort.values)
              DropdownMenuItem(value: value, child: Text(value.label)),
          ],
          onChanged: (value) {
            if (value != null) onChanged(query.copyWith(sort: value));
          },
        ),
        const SizedBox(height: 16),
        TextButton(
          onPressed: () => onChanged(const ArchiveQuery()),
          style: TextButton.styleFrom(foregroundColor: dark ? cyanLight : cyan),
          child: const Text('清除全部条件'),
        ),
      ],
    );
  }
}

class _ArchiveDropdown<T> extends StatelessWidget {
  const _ArchiveDropdown({
    super.key,
    required this.label,
    required this.value,
    required this.values,
    required this.readLabel,
    required this.onChanged,
  });

  final String label;
  final T? value;
  final List<T> values;
  final String Function(T) readLabel;
  final ValueChanged<T?> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<T?>(
      initialValue: value,
      decoration: InputDecoration(labelText: label),
      items: [
        DropdownMenuItem<T?>(value: null, child: const Text('全部')),
        for (final item in values)
          DropdownMenuItem<T?>(value: item, child: Text(readLabel(item))),
      ],
      onChanged: onChanged,
    );
  }
}

class _ResultSummaryDelegate extends SliverPersistentHeaderDelegate {
  _ResultSummaryDelegate({
    required this.height,
    required this.count,
    required this.query,
    required this.onChanged,
  });

  final double height;
  final int count;
  final ArchiveQuery query;
  final ValueChanged<ArchiveQuery> onChanged;

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
    return SizedBox.expand(
      child: Material(
        color: paper,
        elevation: overlapsContent ? 5 : 0,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
          child: Row(
            children: [
              Expanded(
                child: Semantics(
                  key: const ValueKey('archive-result-status'),
                  liveRegion: true,
                  label: '找到 $count 条记录',
                  child: Text(
                    '找到 $count 条记录',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
              ),
              Text(query.sort.label),
            ],
          ),
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(_ResultSummaryDelegate oldDelegate) =>
      oldDelegate.height != height ||
      oldDelegate.count != count ||
      oldDelegate.query != query;
}

class _EraLabel extends StatelessWidget {
  const _EraLabel({required this.era, required this.count});

  final ArchiveEra era;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 26, 28, 14),
      child: Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Text(era.label, style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(width: 10),
          Text('$count 条', style: const TextStyle(color: inkSoft)),
        ],
      ),
    );
  }
}

class _ArchiveRecordCard extends StatelessWidget {
  const _ArchiveRecordCard({
    required this.record,
    required this.compact,
    required this.stacked,
    required this.selected,
    required this.query,
    required this.onCompare,
  });

  final ArchiveRecord record;
  final bool compact;
  final bool stacked;
  final bool selected;
  final ArchiveQuery query;
  final VoidCallback onCompare;

  @override
  Widget build(BuildContext context) {
    final thumbnail = Semantics(
      image: true,
      label: '${record.title}的抽象档案缩略图',
      child: SizedBox(
        width: compact ? double.infinity : 126,
        height: compact ? 96 : 118,
        child: CustomPaint(
          painter: ArchiveThumbnailPainter(
            seed: record.thumbnailSeed,
            collectionIndex: record.collection.index,
          ),
        ),
      ),
    );
    final details = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${record.year} · ${record.collection.label}',
          style: const TextStyle(color: cyan, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 5),
        Text(record.title, style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 6),
        Text(
          '${record.people.join('、')} · ${record.medium.label} · ${record.access.label}',
        ),
        if (!stacked) const Spacer() else const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: [
            TextButton(
              key: ValueKey('open-${record.id}'),
              onPressed: () => context.push(
                query.toUri(path: '/records/${record.id}').toString(),
              ),
              child: const Text('查看'),
            ),
            TextButton.icon(
              key: ValueKey('compare-${record.id}'),
              onPressed: selected ? null : onCompare,
              icon: Icon(selected ? Icons.check : Icons.compare_arrows),
              label: Text(selected ? '已加入' : '加入对照'),
            ),
          ],
        ),
      ],
    );
    return Card(
      key: ValueKey(record.id),
      margin: EdgeInsets.zero,
      color: paper,
      elevation: 0,
      shape: RoundedRectangleBorder(
        side: const BorderSide(color: rule),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: compact
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  thumbnail,
                  const SizedBox(height: 12),
                  Expanded(child: details),
                ],
              )
            : stacked
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [thumbnail, const SizedBox(height: 14), details],
              )
            : SizedBox(
                height: 142,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    thumbnail,
                    const SizedBox(width: 16),
                    Expanded(child: details),
                  ],
                ),
              ),
      ),
    );
  }
}

class _ComparisonBar extends ConsumerWidget {
  const _ComparisonBar({required this.query, required this.comparison});

  final ArchiveQuery query;
  final ArchiveComparison comparison;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Material(
      color: ink,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  '对照栏 ${comparison.ids.length}/3',
                  style: const TextStyle(
                    color: paper,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              TextButton(
                onPressed: ref.read(archiveComparisonProvider.notifier).clear,
                style: TextButton.styleFrom(foregroundColor: cyanLight),
                child: const Text('清空'),
              ),
              FilledButton(
                key: const ValueKey('open-comparison'),
                onPressed: comparison.ids.length < 2
                    ? null
                    : () => context.push(
                        query.toUri(path: '/compare').toString(),
                      ),
                style: FilledButton.styleFrom(
                  backgroundColor: amber,
                  foregroundColor: ink,
                ),
                child: const Text('开始对照'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyArchive extends StatelessWidget {
  const _EmptyArchive({required this.onReset});

  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '没有符合条件的记录',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 10),
            const Text('可以换一个关键词，或清除筛选条件。'),
            const SizedBox(height: 18),
            FilledButton(onPressed: onReset, child: const Text('查看全部 120 条')),
          ],
        ),
      ),
    );
  }
}

class _ArchiveLoadError extends StatelessWidget {
  const _ArchiveLoadError({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('档案暂时没有加载出来', style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 8),
          const Text('本地数据读取失败，请重试。'),
          const SizedBox(height: 18),
          FilledButton(onPressed: onRetry, child: const Text('重新加载')),
        ],
      ),
    );
  }
}

extension on BuildContext {
  ArchiveComparisonController readComparison() {
    final element = this as Element;
    final scope = ProviderScope.containerOf(element);
    return scope.read(archiveComparisonProvider.notifier);
  }
}
