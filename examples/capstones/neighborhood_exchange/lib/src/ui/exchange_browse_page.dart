import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../data/exchange_repository.dart';
import '../domain/exchange_models.dart';
import '../domain/exchange_url_codec.dart';
import '../state/exchange_providers.dart';
import 'exchange_components.dart';
import 'exchange_detail_page.dart';
import 'exchange_theme.dart';

class ExchangeBrowsePage extends ConsumerStatefulWidget {
  const ExchangeBrowsePage({
    super.key,
    required this.uri,
    this.selectedListingId,
  });

  final Uri uri;
  final String? selectedListingId;

  @override
  ConsumerState<ExchangeBrowsePage> createState() => _ExchangeBrowsePageState();
}

class _ExchangeBrowsePageState extends ConsumerState<ExchangeBrowsePage> {
  late final TextEditingController _searchController;

  ExchangeQuery get _query => const ExchangeUrlCodec().parse(widget.uri);

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: _query.search);
  }

  @override
  void didUpdateWidget(covariant ExchangeBrowsePage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_query.search != _searchController.text) {
      _searchController.value = TextEditingValue(
        text: _query.search,
        selection: TextSelection.collapsed(offset: _query.search.length),
      );
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const ExchangeHeader(),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth >= 1100) {
                  return _wideLayout(context);
                }
                return _compactLayout(
                  context,
                  medium: constraints.maxWidth >= 700,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _wideLayout(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(18),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 270,
            child: _FilterLedger(
              query: _query,
              onChanged: _replaceQuery,
              onClear: _clearQuery,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _ResultsDesk(
              query: _query,
              selectedListingId: widget.selectedListingId,
              searchController: _searchController,
              onSearch: _setSearch,
              onQueryChanged: _replaceQuery,
              onOpen: _openListing,
            ),
          ),
          const SizedBox(width: 16),
          SizedBox(
            width: 390,
            child: AnimatedSwitcher(
              key: const ValueKey('detail-transition'),
              duration: MediaQuery.disableAnimationsOf(context)
                  ? Duration.zero
                  : const Duration(milliseconds: 220),
              switchInCurve: Curves.easeOutCubic,
              switchOutCurve: Curves.easeInCubic,
              transitionBuilder: (child, animation) => FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0.04, 0),
                    end: Offset.zero,
                  ).animate(animation),
                  child: child,
                ),
              ),
              child: widget.selectedListingId == null
                  ? const _DetailPlaceholder(key: ValueKey('empty-claim-slip'))
                  : ExchangeDetailPanel(
                      key: ValueKey('detail-${widget.selectedListingId}'),
                      listingId: widget.selectedListingId!,
                      query: _query,
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _compactLayout(BuildContext context, {required bool medium}) {
    final horizontalPadding = medium ? 18.0 : 12.0;
    final largeText = MediaQuery.textScalerOf(context).scale(1) > 1.5;
    final heading = _BrowseIntro(query: _query);
    final search = _CompactSearchBar(
      controller: _searchController,
      onSearch: _setSearch,
      onFilter: () => _openFilters(context),
      activeFilterCount: _activeFilterCount(_query),
    );
    final results = _ResultsDesk(
      query: _query,
      selectedListingId: widget.selectedListingId,
      searchController: _searchController,
      onSearch: _setSearch,
      onQueryChanged: _replaceQuery,
      onOpen: _openListing,
      showSearch: false,
      medium: medium,
    );
    if (largeText) {
      return ListView(
        key: const ValueKey('large-text-browse-scroll'),
        padding: EdgeInsets.fromLTRB(
          horizontalPadding,
          16,
          horizontalPadding,
          20,
        ),
        children: [
          heading,
          const SizedBox(height: 14),
          search,
          if (medium) ...[
            const SizedBox(height: 12),
            _MediumFilterStrip(query: _query, onChanged: _replaceQuery),
          ],
          const SizedBox(height: 12),
          SizedBox(height: 760, child: results),
        ],
      );
    }
    return Padding(
      padding: EdgeInsets.fromLTRB(horizontalPadding, 16, horizontalPadding, 0),
      child: Column(
        children: [
          heading,
          const SizedBox(height: 14),
          search,
          if (medium) ...[
            const SizedBox(height: 12),
            _MediumFilterStrip(query: _query, onChanged: _replaceQuery),
          ],
          const SizedBox(height: 12),
          Expanded(child: results),
        ],
      ),
    );
  }

  void _setSearch(String value) {
    _replaceQuery(_queryWith(_query, search: value));
  }

  void _replaceQuery(ExchangeQuery query) {
    final location = const ExchangeUrlCodec().encode(
      path: '/exchange',
      query: query,
    );
    context.go(location.toString());
  }

  void _clearQuery() {
    _searchController.clear();
    _replaceQuery(const ExchangeQuery());
  }

  void _openListing(String id) {
    final location = const ExchangeUrlCodec().encode(
      path: '/listings/$id',
      query: _query,
    );
    context.go(location.toString());
  }

  Future<void> _openFilters(BuildContext context) async {
    final nextQuery = await showModalBottomSheet<ExchangeQuery>(
      context: context,
      isScrollControlled: true,
      builder: (context) => _FilterSheet(query: _query),
    );
    if (nextQuery == null || !context.mounted) return;
    _replaceQuery(nextQuery);
  }
}

class _BrowseIntro extends StatelessWidget {
  const _BrowseIntro({required this.query});

  final ExchangeQuery query;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '今天可以互相帮什么？',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 4),
              const Text('内置演示资源可跨浏览器打开；本地发布和认领只留在当前浏览器。'),
            ],
          ),
        ),
      ],
    );
  }
}

class _CompactSearchBar extends StatelessWidget {
  const _CompactSearchBar({
    required this.controller,
    required this.onSearch,
    required this.onFilter,
    required this.activeFilterCount,
  });

  final TextEditingController controller;
  final ValueChanged<String> onSearch;
  final VoidCallback onFilter;
  final int activeFilterCount;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: TextField(
            key: const ValueKey('listing-search'),
            controller: controller,
            textInputAction: TextInputAction.search,
            onSubmitted: onSearch,
            decoration: InputDecoration(
              labelText: '搜索资源、说明或发布者',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: IconButton(
                tooltip: '执行搜索',
                onPressed: () => onSearch(controller.text),
                icon: const Icon(Icons.arrow_forward),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Badge(
          isLabelVisible: activeFilterCount > 0,
          label: Text('$activeFilterCount'),
          child: IconButton.filledTonal(
            key: const ValueKey('open-filters'),
            tooltip: '筛选资源',
            onPressed: onFilter,
            icon: const Icon(Icons.tune),
          ),
        ),
      ],
    );
  }
}

class _MediumFilterStrip extends StatelessWidget {
  const _MediumFilterStrip({required this.query, required this.onChanged});

  final ExchangeQuery query;
  final ValueChanged<ExchangeQuery> onChanged;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: exchangeInk,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            SizedBox(
              width: 210,
              child: _NeighborhoodDropdown(
                query: query,
                onChanged: onChanged,
                dark: true,
              ),
            ),
            SizedBox(
              width: 190,
              child: _CategoryDropdown(
                query: query,
                onChanged: onChanged,
                dark: true,
              ),
            ),
            SizedBox(
              width: 170,
              child: _StatusDropdown(
                query: query,
                onChanged: onChanged,
                dark: true,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterLedger extends StatelessWidget {
  const _FilterLedger({
    required this.query,
    required this.onChanged,
    required this.onClear,
  });

  final ExchangeQuery query;
  final ValueChanged<ExchangeQuery> onChanged;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Material(
      key: const ValueKey('filter-ledger'),
      color: exchangeInk,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: ListView(
          children: [
            Text(
              '值班筛选簿',
              style: Theme.of(context).textTheme.headlineSmall
                  ?.copyWith(color: exchangePaper, fontFamily: 'Georgia'),
            ),
            const SizedBox(height: 8),
            Text(
              '先缩小范围，再打开取用签。',
              style: Theme.of(context).textTheme.bodyMedium
                  ?.copyWith(color: exchangePaperMuted),
            ),
            const SizedBox(height: 22),
            _NeighborhoodDropdown(
              query: query,
              onChanged: onChanged,
              dark: true,
            ),
            const SizedBox(height: 14),
            _CategoryDropdown(query: query, onChanged: onChanged, dark: true),
            const SizedBox(height: 14),
            _StatusDropdown(query: query, onChanged: onChanged, dark: true),
            const SizedBox(height: 14),
            _SortDropdown(query: query, onChanged: onChanged, dark: true),
            const SizedBox(height: 22),
            OutlinedButton.icon(
              onPressed: onClear,
              style: OutlinedButton.styleFrom(
                foregroundColor: exchangePaper,
                side: const BorderSide(color: exchangePaperMuted),
              ),
              icon: const Icon(Icons.restart_alt),
              label: const Text('清除全部条件'),
            ),
            const SizedBox(height: 22),
            const Divider(color: exchangeRule),
            const SizedBox(height: 14),
            Text(
              '当前身份',
              style: Theme.of(context).textTheme.labelLarge
                  ?.copyWith(color: exchangePaperMuted),
            ),
            const SizedBox(height: 5),
            Text(
              localUserDisplayName,
              style: Theme.of(context).textTheme.titleLarge
                  ?.copyWith(color: exchangePaper),
            ),
            const SizedBox(height: 6),
            Text(
              '演示身份，不是账号。',
              style: Theme.of(context).textTheme.bodySmall
                  ?.copyWith(color: exchangePaperMuted),
            ),
          ],
        ),
      ),
    );
  }
}

class _ResultsDesk extends ConsumerWidget {
  const _ResultsDesk({
    required this.query,
    required this.selectedListingId,
    required this.searchController,
    required this.onSearch,
    required this.onQueryChanged,
    required this.onOpen,
    this.showSearch = true,
    this.medium = false,
  });

  final ExchangeQuery query;
  final String? selectedListingId;
  final TextEditingController searchController;
  final ValueChanged<String> onSearch;
  final ValueChanged<ExchangeQuery> onQueryChanged;
  final ValueChanged<String> onOpen;
  final bool showSearch;
  final bool medium;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final listings = ref.watch(exchangeListingsProvider(query));
    return Material(
      color: exchangePaperMuted,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 0),
        child: Column(
          children: [
            if (showSearch) ...[
              _BrowseIntro(query: query),
              const SizedBox(height: 14),
              TextField(
                key: const ValueKey('listing-search'),
                controller: searchController,
                textInputAction: TextInputAction.search,
                onSubmitted: onSearch,
                decoration: InputDecoration(
                  labelText: '搜索资源、说明或发布者',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: IconButton(
                    tooltip: '执行搜索',
                    onPressed: () => onSearch(searchController.text),
                    icon: const Icon(Icons.arrow_forward),
                  ),
                ),
              ),
              const SizedBox(height: 14),
            ],
            Row(
              children: [
                Expanded(
                  child: listings.when(
                    data: (result) {
                      final count = switch (result) {
                        ExchangeSuccess<List<ExchangeListing>>(:final value) =>
                          value.length,
                        _ => 0,
                      };
                      return Semantics(
                        key: const ValueKey('listing-result-status'),
                        liveRegion: true,
                        label: '当前显示 $count 条演示资源',
                        child: Text(
                          '$count 条演示资源',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      );
                    },
                    loading: () => const Text('正在读取资源'),
                    error: (error, stackTrace) => const Text('资源读取失败'),
                  ),
                ),
                SegmentedButton<ExchangeView>(
                  key: const ValueKey('listing-view-switch'),
                  showSelectedIcon: false,
                  segments: const [
                    ButtonSegment(
                      value: ExchangeView.list,
                      label: Text('列表', softWrap: false),
                    ),
                    ButtonSegment(
                      value: ExchangeView.compactGrid,
                      label: Text('网格', softWrap: false),
                    ),
                  ],
                  selected: {query.view},
                  onSelectionChanged: (selection) =>
                      onQueryChanged(_queryWith(query, view: selection.single)),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Expanded(
              child: listings.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stackTrace) => const ExchangeStatePanel(
                  icon: Icons.sync_problem,
                  title: '资源读取失败',
                  message: 'Provider 没有完成本地数据读取。',
                ),
                data: (result) => switch (result) {
                  ExchangeSuccess<List<ExchangeListing>>(:final value) =>
                    _ListingResults(
                      listings: value,
                      query: query,
                      selectedListingId: selectedListingId,
                      onOpen: onOpen,
                      medium: medium,
                    ),
                  ExchangeFailureResult<List<ExchangeListing>>() =>
                    ExchangeStatePanel(
                      panelKey: const ValueKey('listing-load-failure'),
                      icon: Icons.storage_outlined,
                      title: '本地资源没有准备好',
                      message: 'fixture 或浏览器数据库读取失败。请重新加载后再试。',
                      actionLabel: '重试',
                      action: () =>
                          ref.invalidate(exchangeListingsProvider(query)),
                    ),
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ListingResults extends StatelessWidget {
  const _ListingResults({
    required this.listings,
    required this.query,
    required this.selectedListingId,
    required this.onOpen,
    required this.medium,
  });

  final List<ExchangeListing> listings;
  final ExchangeQuery query;
  final String? selectedListingId;
  final ValueChanged<String> onOpen;
  final bool medium;

  @override
  Widget build(BuildContext context) {
    if (listings.isEmpty) {
      return const ExchangeStatePanel(
        panelKey: ValueKey('empty-listings'),
        icon: Icons.filter_alt_off_outlined,
        title: '没有符合条件的资源',
        message: '减少一个筛选条件，或换一个更短的关键词。',
      );
    }
    if (query.view == ExchangeView.compactGrid) {
      return LayoutBuilder(
        builder: (context, constraints) {
          final columns = constraints.maxWidth >= 560 ? 2 : 1;
          return GridView.builder(
            key: const ValueKey('listing-grid'),
            padding: const EdgeInsets.only(bottom: 20),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: columns,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: columns == 1 ? 1.15 : 0.88,
            ),
            itemCount: listings.length,
            itemBuilder: (context, index) {
              final listing = listings[index];
              return NoticeCard(
                listing: listing,
                grid: true,
                selected: selectedListingId == listing.id,
                onOpen: () => onOpen(listing.id),
              );
            },
          );
        },
      );
    }
    return ListView.separated(
      key: const ValueKey('listing-list'),
      padding: const EdgeInsets.only(bottom: 20),
      itemCount: listings.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final listing = listings[index];
        return NoticeCard(
          listing: listing,
          selected: selectedListingId == listing.id,
          onOpen: () => onOpen(listing.id),
        );
      },
    );
  }
}

class _DetailPlaceholder extends StatelessWidget {
  const _DetailPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: exchangePaper,
      borderRadius: BorderRadius.circular(2),
      child: Padding(
        padding: const EdgeInsets.all(26),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Align(
              alignment: Alignment.centerLeft,
              child: Icon(
                Icons.local_offer_outlined,
                size: 42,
                color: exchangeGreen,
              ),
            ),
            const SizedBox(height: 16),
            Text('待填写取用签', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 10),
            const Text(
              '选择中间的一条演示资源，交接方式、数量和本地数据边界会填入这里。',
            ),
            const Divider(height: 38),
            const DetailFact(
              icon: Icons.inventory_2_outlined,
              label: '资源',
              value: '等待选择',
            ),
            const SizedBox(height: 18),
            const DetailFact(
              icon: Icons.schedule,
              label: '交接时段',
              value: '等待选择',
            ),
            const SizedBox(height: 18),
            const DetailFact(
              icon: Icons.pin_outlined,
              label: '取用数量',
              value: '等待选择',
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterSheet extends StatefulWidget {
  const _FilterSheet({required this.query});

  final ExchangeQuery query;

  @override
  State<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<_FilterSheet> {
  late ExchangeQuery query = widget.query;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          18,
          12,
          18,
          18 + MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 48,
                  height: 4,
                  decoration: BoxDecoration(
                    color: exchangeRule,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Text('筛选资源', style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 18),
              _NeighborhoodDropdown(
                query: query,
                onChanged: (value) => setState(() => query = value),
              ),
              const SizedBox(height: 14),
              _CategoryDropdown(
                query: query,
                onChanged: (value) => setState(() => query = value),
              ),
              const SizedBox(height: 14),
              _StatusDropdown(
                query: query,
                onChanged: (value) => setState(() => query = value),
              ),
              const SizedBox(height: 14),
              _SortDropdown(
                query: query,
                onChanged: (value) => setState(() => query = value),
              ),
              const SizedBox(height: 22),
              FilledButton(
                key: const ValueKey('apply-filters'),
                onPressed: () => Navigator.pop(context, query),
                child: const Text('应用筛选'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(
                  context,
                  ExchangeQuery(search: query.search, view: query.view),
                ),
                child: const Text('清除筛选'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NeighborhoodDropdown extends StatelessWidget {
  const _NeighborhoodDropdown({
    required this.query,
    required this.onChanged,
    this.dark = false,
  });

  final ExchangeQuery query;
  final ValueChanged<ExchangeQuery> onChanged;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<Neighborhood?>(
      key: const ValueKey('neighborhood-filter'),
      initialValue: query.neighborhood,
      decoration: _decoration('片区', dark),
      dropdownColor: exchangePaper,
      items: [
        const DropdownMenuItem(value: null, child: Text('全部片区')),
        ...Neighborhood.values.map(
          (value) => DropdownMenuItem(value: value, child: Text(value.label)),
        ),
      ],
      onChanged: (value) => onChanged(_queryWith(query, neighborhood: value)),
    );
  }
}

class _CategoryDropdown extends StatelessWidget {
  const _CategoryDropdown({
    required this.query,
    required this.onChanged,
    this.dark = false,
  });

  final ExchangeQuery query;
  final ValueChanged<ExchangeQuery> onChanged;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<ExchangeCategory?>(
      key: const ValueKey('category-filter'),
      initialValue: query.category,
      decoration: _decoration('类别', dark),
      dropdownColor: exchangePaper,
      items: [
        const DropdownMenuItem(value: null, child: Text('全部类别')),
        ...ExchangeCategory.values.map(
          (value) => DropdownMenuItem(value: value, child: Text(value.label)),
        ),
      ],
      onChanged: (value) => onChanged(_queryWith(query, category: value)),
    );
  }
}

class _StatusDropdown extends StatelessWidget {
  const _StatusDropdown({
    required this.query,
    required this.onChanged,
    this.dark = false,
  });

  final ExchangeQuery query;
  final ValueChanged<ExchangeQuery> onChanged;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<ExchangeStatus?>(
      key: const ValueKey('status-filter'),
      initialValue: query.status,
      decoration: _decoration('状态', dark),
      dropdownColor: exchangePaper,
      items: [
        const DropdownMenuItem(value: null, child: Text('全部状态')),
        ...ExchangeStatus.values.map(
          (value) => DropdownMenuItem(value: value, child: Text(value.label)),
        ),
      ],
      onChanged: (value) => onChanged(_queryWith(query, status: value)),
    );
  }
}

class _SortDropdown extends StatelessWidget {
  const _SortDropdown({
    required this.query,
    required this.onChanged,
    this.dark = false,
  });

  final ExchangeQuery query;
  final ValueChanged<ExchangeQuery> onChanged;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<ExchangeSort>(
      key: const ValueKey('sort-filter'),
      initialValue: query.sort,
      decoration: _decoration('排序', dark),
      dropdownColor: exchangePaper,
      items: const [
        DropdownMenuItem(value: ExchangeSort.newest, child: Text('最近发布')),
        DropdownMenuItem(
          value: ExchangeSort.earliestPickup,
          child: Text('最早可取'),
        ),
        DropdownMenuItem(value: ExchangeSort.title, child: Text('按名称')),
      ],
      onChanged: (value) {
        if (value != null) onChanged(_queryWith(query, sort: value));
      },
    );
  }
}

InputDecoration _decoration(String label, bool dark) {
  return InputDecoration(
    labelText: label,
    labelStyle: dark ? const TextStyle(color: exchangeInk) : null,
  );
}

const _unchangedFilter = Object();

ExchangeQuery _queryWith(
  ExchangeQuery query, {
  String? search,
  Object? neighborhood = _unchangedFilter,
  Object? category = _unchangedFilter,
  Object? status = _unchangedFilter,
  ExchangeSort? sort,
  ExchangeView? view,
}) {
  return ExchangeQuery(
    search: search ?? query.search,
    neighborhood: identical(neighborhood, _unchangedFilter)
        ? query.neighborhood
        : neighborhood as Neighborhood?,
    category: identical(category, _unchangedFilter)
        ? query.category
        : category as ExchangeCategory?,
    status: identical(status, _unchangedFilter)
        ? query.status
        : status as ExchangeStatus?,
    sort: sort ?? query.sort,
    view: view ?? query.view,
  );
}

int _activeFilterCount(ExchangeQuery query) {
  return [
    query.neighborhood,
    query.category,
    query.status,
  ].where((value) => value != null).length;
}
