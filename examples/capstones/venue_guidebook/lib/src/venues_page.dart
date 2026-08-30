import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../l10n/app_localizations.dart';
import '../l10n/app_localizations_en.dart';
import '../l10n/app_localizations_zh.dart';
import 'venue_data.dart';
import 'venue_guide_controller.dart';
import 'venue_guidebook_app.dart';
import 'venue_localizations.dart';
import 'venue_url_codec.dart';

class GuidePageFrame extends StatelessWidget {
  const GuidePageFrame({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: guidePaper,
      child: CustomPaint(
        painter: const _FoldRulePainter(),
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            padding: const EdgeInsetsDirectional.fromSTEB(18, 18, 18, 44),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1240),
                child: child,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class GuideSectionHeader extends StatelessWidget {
  const GuideSectionHeader({
    required this.title,
    required this.body,
    this.trailing,
    super.key,
  });

  final String title;
  final String body;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: guideCobalt,
      padding: const EdgeInsets.all(22),
      child: Wrap(
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.end,
        spacing: 28,
        runSpacing: 18,
        children: [
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontFamily: 'serif',
                    fontSize: 42,
                    height: 0.98,
                    letterSpacing: -1.2,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  body,
                  style: const TextStyle(
                    color: Color(0xFFE1E7FF),
                    fontSize: 17,
                    height: 1.45,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          ?trailing,
        ],
      ),
    );
  }
}

class VenuesPage extends StatefulWidget {
  const VenuesPage({required this.controller, super.key});

  final VenueGuideController controller;

  @override
  State<VenuesPage> createState() => _VenuesPageState();
}

class _VenuesPageState extends State<VenuesPage> {
  late final TextEditingController _searchController;
  late final FocusNode _searchFocusNode;
  String _query = '';
  int? _floor;
  VenueTag? _tag;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _searchFocusNode = FocusNode(debugLabel: 'venue-search');
    widget.controller.registerSearchFocusNode(_searchFocusNode);
  }

  @override
  void dispose() {
    widget.controller.unregisterSearchFocusNode(_searchFocusNode);
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _clearFilters() {
    _searchController.clear();
    setState(() {
      _query = '';
      _floor = null;
      _tag = null;
    });
    _searchFocusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final searchLocales = [AppLocalizationsZh(), AppLocalizationsEn()];
    final normalizedQuery = _query.trim().toLowerCase();
    final visibleVenues = venues.where((venue) {
      final searchText = searchLocales
          .expand(
            (locale) => [
              locale.venueName(venue),
              locale.venueSummary(venue),
              ...venue.tags.map(locale.tagLabel),
              ...venue.floors.map(locale.floorLabel),
            ],
          )
          .join(' ')
          .toLowerCase();
      final matchesQuery =
          normalizedQuery.isEmpty || searchText.contains(normalizedQuery);
      final matchesFloor = _floor == null || venue.floors.contains(_floor);
      final matchesTag = _tag == null || venue.tags.contains(_tag);
      return matchesQuery && matchesFloor && matchesTag;
    }).toList();

    return GuidePageFrame(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          GuideSectionHeader(
            title: strings.appTitle,
            body: strings.appSubtitle,
            trailing: _DateStamp(
              text: strings.updatedOn(DateTime(2026, 8, 30)),
            ),
          ),
          const SizedBox(height: 18),
          _SearchDeck(
            controller: _searchController,
            focusNode: _searchFocusNode,
            query: _query,
            floor: _floor,
            tag: _tag,
            onQueryChanged: (value) => setState(() => _query = value),
            onFloorChanged: (value) => setState(() => _floor = value),
            onTagChanged: (value) => setState(() => _tag = value),
            onClear: _clearFilters,
          ),
          const SizedBox(height: 16),
          // #region result-live-region
          Semantics(
            key: const ValueKey('venue-result-status'),
            liveRegion: true,
            label: strings.resultCount(visibleVenues.length),
            child: ExcludeSemantics(
              child: Text(
                strings.resultCount(visibleVenues.length),
                style: const TextStyle(
                  color: guideCobaltDeep,
                  fontFamily: 'monospace',
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
          // #endregion result-live-region
          const SizedBox(height: 10),
          if (visibleVenues.isEmpty)
            _NoResults(onClear: _clearFilters)
          else
            ...visibleVenues.indexed.map(
              (entry) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _VenueIndexRow(index: entry.$1, venue: entry.$2),
              ),
            ),
        ],
      ),
    );
  }
}

class _DateStamp extends StatelessWidget {
  const _DateStamp({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 250),
      color: guideChartreuse,
      padding: const EdgeInsets.all(14),
      child: Text(
        text,
        style: const TextStyle(
          color: guideInk,
          fontFamily: 'monospace',
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _SearchDeck extends StatelessWidget {
  const _SearchDeck({
    required this.controller,
    required this.focusNode,
    required this.query,
    required this.floor,
    required this.tag,
    required this.onQueryChanged,
    required this.onFloorChanged,
    required this.onTagChanged,
    required this.onClear,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final String query;
  final int? floor;
  final VenueTag? tag;
  final ValueChanged<String> onQueryChanged;
  final ValueChanged<int?> onFloorChanged;
  final ValueChanged<VenueTag?> onTagChanged;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    return Container(
      color: guideCobaltDeep,
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            key: const ValueKey('venue-search-field'),
            controller: controller,
            focusNode: focusNode,
            onChanged: onQueryChanged,
            textInputAction: TextInputAction.search,
            decoration: InputDecoration(
              labelText: strings.searchLabel,
              hintText: strings.searchHint,
              helperText: strings.searchShortcutHint,
              helperStyle: const TextStyle(
                color: Color(0xFFDCE4FF),
                fontWeight: FontWeight.w700,
              ),
              prefixIcon: const Icon(Icons.search),
              suffixIcon: query.isEmpty
                  ? null
                  : IconButton(
                      key: const ValueKey('clear-search'),
                      tooltip: strings.clearSearch,
                      onPressed: () {
                        controller.clear();
                        onQueryChanged('');
                        focusNode.requestFocus();
                      },
                      icon: const Icon(Icons.close),
                    ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            strings.filterByFloor,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _FilterButton(
                key: const ValueKey('floor-all'),
                label: strings.allFloors,
                selected: floor == null,
                onPressed: () => onFloorChanged(null),
              ),
              for (final value in [1, 2, 3, 4])
                _FilterButton(
                  key: ValueKey('floor-$value'),
                  label: strings.floorShortLabel(value),
                  selected: floor == value,
                  onPressed: () => onFloorChanged(value),
                ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            strings.filterByTag,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _FilterButton(
                key: const ValueKey('tag-all'),
                label: strings.clearTag,
                selected: tag == null,
                onPressed: () => onTagChanged(null),
              ),
              for (final value in VenueTag.values)
                _FilterButton(
                  key: ValueKey('tag-${value.id}'),
                  label: strings.tagLabel(value),
                  selected: tag == value,
                  onPressed: () => onTagChanged(value),
                ),
              if (query.isNotEmpty || floor != null || tag != null)
                TextButton.icon(
                  onPressed: onClear,
                  style: TextButton.styleFrom(foregroundColor: guideChartreuse),
                  icon: const Icon(Icons.restart_alt),
                  label: Text(strings.browseAll),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FilterButton extends StatelessWidget {
  const _FilterButton({
    required this.label,
    required this.selected,
    required this.onPressed,
    super.key,
  });

  final String label;
  final bool selected;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    return Semantics(
      button: true,
      selected: selected,
      label: selected ? '$label，${strings.selectedState}' : label,
      child: ExcludeSemantics(
        child: OutlinedButton(
          onPressed: onPressed,
          style: OutlinedButton.styleFrom(
            backgroundColor: selected ? guideChartreuse : guideCobaltDeep,
            foregroundColor: selected ? guideInk : Colors.white,
            side: BorderSide(color: selected ? guideChartreuse : Colors.white),
          ),
          child: Text(label),
        ),
      ),
    );
  }
}

class _VenueIndexRow extends StatelessWidget {
  const _VenueIndexRow({required this.index, required this.venue});

  final int index;
  final Venue venue;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final name = strings.venueName(venue);
    final floorText = venue.floors.map(strings.floorLabel).join(' / ');
    final tagText = venue.tags.map(strings.tagLabel).join('、');
    return Semantics(
      button: true,
      label: strings.venueItemLabel(name, floorText, tagText),
      child: ExcludeSemantics(
        child: Material(
          color: index.isEven ? guidePaperBright : const Color(0xFFE7DFC0),
          child: InkWell(
            key: ValueKey('open-venue-${venue.id}'),
            onTap: () => context.go('/venues/${venue.id}'),
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final compact = constraints.maxWidth < 660;
                  final number = _VenueNumber(index: index);
                  final details = _VenueRowDetails(venue: venue);
                  final action = Icon(
                    Directionality.of(context) == TextDirection.rtl
                        ? Icons.arrow_back
                        : Icons.arrow_forward,
                    color: guideCobalt,
                  );
                  if (compact) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            number,
                            const SizedBox(width: 14),
                            Expanded(child: details),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Align(
                          alignment: AlignmentDirectional.centerEnd,
                          child: action,
                        ),
                      ],
                    );
                  }
                  return Row(
                    children: [
                      number,
                      const SizedBox(width: 18),
                      Expanded(child: details),
                      const SizedBox(width: 18),
                      action,
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _VenueNumber extends StatelessWidget {
  const _VenueNumber({required this.index});

  final int index;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 54,
      height: 54,
      color: guideCobalt,
      alignment: Alignment.center,
      child: Text(
        '${index + 1}'.padLeft(2, '0'),
        style: const TextStyle(
          color: Colors.white,
          fontFamily: 'monospace',
          fontSize: 19,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _VenueRowDetails extends StatelessWidget {
  const _VenueRowDetails({required this.venue});

  final Venue venue;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          strings.venueName(venue),
          style: const TextStyle(
            color: guideInk,
            fontSize: 25,
            height: 1.05,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          strings.venueSummary(venue),
          style: const TextStyle(color: guideMutedInk, height: 1.45),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 7,
          runSpacing: 7,
          children: [
            for (final floor in venue.floors)
              _IndexTag(label: strings.floorShortLabel(floor), strong: true),
            for (final tag in venue.tags)
              _IndexTag(label: strings.tagLabel(tag)),
          ],
        ),
      ],
    );
  }
}

class _IndexTag extends StatelessWidget {
  const _IndexTag({required this.label, this.strong = false});

  final String label;
  final bool strong;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: strong ? guideChartreuse : guideInk,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      child: Text(
        label,
        style: TextStyle(
          color: strong ? guideInk : Colors.white,
          fontFamily: strong ? 'monospace' : null,
          fontSize: 13,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _NoResults extends StatelessWidget {
  const _NoResults({required this.onClear});

  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    return Container(
      color: guidePaperBright,
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.search_off, size: 34, color: guideCobalt),
          const SizedBox(height: 12),
          Text(
            strings.noResultsTitle,
            style: const TextStyle(
              color: guideInk,
              fontSize: 26,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          Text(strings.noResultsBody),
          const SizedBox(height: 18),
          FilledButton(onPressed: onClear, child: Text(strings.browseAll)),
        ],
      ),
    );
  }
}

class VenueDetailPage extends StatelessWidget {
  const VenueDetailPage({
    required this.venue,
    required this.selection,
    super.key,
  });

  final Venue venue;
  final VenueSelection selection;

  void _navigate(BuildContext context, VenueSelection selection) {
    final uri = const VenueUrlCodec().encode(venue, selection);
    context.go(uri.toString());
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final rooms = venue.roomsByFloor[selection.floor]!;
    final roomNames = rooms.map(strings.venueText).join('、');
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    return GuidePageFrame(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _DetailHeader(venue: venue, selection: selection),
          const SizedBox(height: 18),
          _DetailControls(
            venue: venue,
            selection: selection,
            onFloorChanged: (floor) => _navigate(
              context,
              VenueSelection(floor: floor, tag: selection.tag),
            ),
            onTagChanged: (tag) => _navigate(
              context,
              VenueSelection(floor: selection.floor, tag: tag),
            ),
          ),
          const SizedBox(height: 18),
          // #region responsive-detail-layout
          LayoutBuilder(
            builder: (context, constraints) {
              final split = constraints.maxWidth >= 980;
              final plan = _FloorPlanPanel(
                floor: selection.floor,
                rooms: rooms,
                animationDuration: reduceMotion
                    ? Duration.zero
                    : const Duration(milliseconds: 260),
                semanticsLabel: strings.floorPlanSummary(
                  selection.floor,
                  roomNames,
                ),
              );
              final list = _RoomList(floor: selection.floor, rooms: rooms);
              if (!split) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [plan, const SizedBox(height: 16), list],
                );
              }
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 6, child: plan),
                  const SizedBox(width: 16),
                  Expanded(flex: 4, child: list),
                ],
              );
            },
          ),
          // #endregion responsive-detail-layout
        ],
      ),
    );
  }
}

class _DetailHeader extends StatelessWidget {
  const _DetailHeader({required this.venue, required this.selection});

  final Venue venue;
  final VenueSelection selection;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    return Container(
      color: guideCobalt,
      padding: const EdgeInsets.all(20),
      child: Wrap(
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 24,
        runSpacing: 16,
        children: [
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                IconButton(
                  key: const ValueKey('back-to-venues'),
                  tooltip: strings.backToVenues,
                  onPressed: () => context.go('/venues'),
                  style: IconButton.styleFrom(
                    backgroundColor: guideChartreuse,
                    foregroundColor: guideInk,
                  ),
                  icon: Icon(
                    Directionality.of(context) == TextDirection.rtl
                        ? Icons.arrow_forward
                        : Icons.arrow_back,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  strings.venueName(venue),
                  style: const TextStyle(
                    color: Colors.white,
                    fontFamily: 'serif',
                    fontSize: 38,
                    height: 1,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  strings.venueSummary(venue),
                  style: const TextStyle(
                    color: Color(0xFFE1E7FF),
                    fontSize: 16,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
          Container(
            color: guideChartreuse,
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  strings.floorShortLabel(selection.floor),
                  style: const TextStyle(
                    color: guideInk,
                    fontFamily: 'monospace',
                    fontSize: 30,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  strings.openPeriod(venue.openStart, venue.openEnd),
                  style: const TextStyle(
                    color: guideInk,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailControls extends StatelessWidget {
  const _DetailControls({
    required this.venue,
    required this.selection,
    required this.onFloorChanged,
    required this.onTagChanged,
  });

  final Venue venue;
  final VenueSelection selection;
  final ValueChanged<int> onFloorChanged;
  final ValueChanged<VenueTag?> onTagChanged;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    return Container(
      color: guidePaperBright,
      padding: const EdgeInsets.all(18),
      child: Wrap(
        spacing: 28,
        runSpacing: 18,
        children: [
          ConstrainedBox(
            constraints: const BoxConstraints(minWidth: 220),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  strings.currentFloor,
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final floor in venue.floors)
                      _FilterButton(
                        key: ValueKey('detail-floor-$floor'),
                        label: strings.floorShortLabel(floor),
                        selected: selection.floor == floor,
                        onPressed: () => onFloorChanged(floor),
                      ),
                  ],
                ),
              ],
            ),
          ),
          ConstrainedBox(
            constraints: const BoxConstraints(minWidth: 280),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  strings.filterByTag,
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _FilterButton(
                      key: const ValueKey('detail-tag-all'),
                      label: strings.clearTag,
                      selected: selection.tag == null,
                      onPressed: () => onTagChanged(null),
                    ),
                    for (final tag in venue.tags)
                      _FilterButton(
                        key: ValueKey('detail-tag-${tag.id}'),
                        label: strings.tagLabel(tag),
                        selected: selection.tag == tag,
                        onPressed: () => onTagChanged(tag),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FloorPlanPanel extends StatelessWidget {
  const _FloorPlanPanel({
    required this.floor,
    required this.rooms,
    required this.animationDuration,
    required this.semanticsLabel,
  });

  final int floor;
  final List<VenueTextKey> rooms;
  final Duration animationDuration;
  final String semanticsLabel;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    return Container(
      color: guideCobaltDeep,
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            strings.floorPlanTitle,
            style: const TextStyle(
              color: guideChartreuse,
              fontSize: 24,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 12),
          // #region floor-plan-semantics
          Semantics(
            key: const ValueKey('floor-plan-semantics'),
            image: true,
            label: semanticsLabel,
            child: ExcludeSemantics(
              child: AnimatedSwitcher(
                key: const ValueKey('floor-plan-switcher'),
                duration: animationDuration,
                child: AspectRatio(
                  key: ValueKey('floor-plan-$floor'),
                  aspectRatio: 1.35,
                  child: CustomPaint(
                    painter: _FloorPlanPainter(
                      floor: floor,
                      textDirection: Directionality.of(context),
                    ),
                  ),
                ),
              ),
            ),
          ),
          // #endregion floor-plan-semantics
          const SizedBox(height: 12),
          Text(
            rooms.map(strings.venueText).join(' · '),
            style: const TextStyle(
              color: Colors.white,
              fontFamily: 'monospace',
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _RoomList extends StatefulWidget {
  const _RoomList({required this.floor, required this.rooms});

  final int floor;
  final List<VenueTextKey> rooms;

  @override
  State<_RoomList> createState() => _RoomListState();
}

class _RoomListState extends State<_RoomList> {
  VenueTextKey? _selectedRoom;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    return Container(
      color: guidePaperBright,
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            strings.placesOnFloor,
            style: const TextStyle(
              color: guideInk,
              fontSize: 24,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 12),
          FocusTraversalGroup(
            child: Column(
              children: [
                for (final entry in widget.rooms.indexed)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: _RoomRow(
                      index: entry.$1,
                      floor: widget.floor,
                      room: entry.$2,
                      selected: _selectedRoom == entry.$2,
                      onPressed: () => setState(() {
                        _selectedRoom = _selectedRoom == entry.$2
                            ? null
                            : entry.$2;
                      }),
                    ),
                  ),
              ],
            ),
          ),
          if (_selectedRoom case final selectedRoom?) ...[
            const SizedBox(height: 6),
            Semantics(
              key: const ValueKey('room-selection-status'),
              liveRegion: true,
              child: Container(
                color: guideChartreuse,
                padding: const EdgeInsets.all(12),
                child: Text(
                  '${strings.floorLabel(widget.floor)} · '
                  '${strings.venueText(selectedRoom)}',
                  style: const TextStyle(
                    color: guideInk,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _RoomRow extends StatelessWidget {
  const _RoomRow({
    required this.index,
    required this.floor,
    required this.room,
    required this.selected,
    required this.onPressed,
  });

  final int index;
  final int floor;
  final VenueTextKey room;
  final bool selected;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final roomName = strings.venueText(room);
    return Semantics(
      button: true,
      selected: selected,
      label: '$roomName，${strings.floorLabel(floor)}',
      child: ExcludeSemantics(
        child: Material(
          color: index.isEven ? guidePaper : const Color(0xFFE7DFC0),
          child: InkWell(
            key: ValueKey('room-${room.name}'),
            onTap: onPressed,
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    color: guideChartreuse,
                    alignment: Alignment.center,
                    child: Text(
                      '${index + 1}'.padLeft(2, '0'),
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      roomName,
                      style: const TextStyle(fontWeight: FontWeight.w900),
                    ),
                  ),
                  Icon(
                    selected ? Icons.check_box : Icons.crop_square,
                    color: guideCobalt,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _FloorPlanPainter extends CustomPainter {
  const _FloorPlanPainter({required this.floor, required this.textDirection});

  final int floor;
  final TextDirection textDirection;

  @override
  void paint(Canvas canvas, Size size) {
    if (textDirection == TextDirection.rtl) {
      canvas
        ..translate(size.width, 0)
        ..scale(-1, 1);
    }
    final wall = Paint()
      ..color = guidePaperBright
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;
    final route = Paint()
      ..color = guideChartreuse
      ..style = PaintingStyle.stroke
      ..strokeWidth = 7
      ..strokeCap = StrokeCap.square;
    final room = Paint()..color = guideCobalt;
    final marker = Paint()..color = guideChartreuse;
    final rect = Rect.fromLTWH(10, 10, size.width - 20, size.height - 20);
    canvas.drawRect(rect, wall);
    final firstRoom = Rect.fromLTWH(
      size.width * 0.08,
      size.height * 0.12,
      size.width * 0.36,
      size.height * 0.32,
    );
    final secondRoom = Rect.fromLTWH(
      size.width * 0.55,
      size.height * 0.18,
      size.width * 0.34,
      size.height * 0.48,
    );
    canvas.drawRect(firstRoom, room);
    canvas.drawRect(secondRoom, room);
    final path = Path()
      ..moveTo(size.width * 0.12, size.height * 0.78)
      ..lineTo(size.width * 0.32, size.height * 0.58)
      ..lineTo(size.width * 0.58, size.height * (0.72 - floor * 0.04))
      ..lineTo(size.width * 0.78, size.height * 0.48);
    canvas.drawPath(path, route);
    canvas.drawRect(
      Rect.fromCenter(
        center: Offset(size.width * 0.12, size.height * 0.78),
        width: 18,
        height: 18,
      ),
      marker,
    );
    canvas.drawRect(
      Rect.fromCenter(
        center: Offset(size.width * 0.78, size.height * 0.48),
        width: 18,
        height: 18,
      ),
      marker,
    );
  }

  @override
  bool shouldRepaint(_FloorPlanPainter oldDelegate) {
    return oldDelegate.floor != floor ||
        oldDelegate.textDirection != textDirection;
  }
}

class _FoldRulePainter extends CustomPainter {
  const _FoldRulePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = guideRule.withValues(alpha: 0.42)
      ..strokeWidth = 1;
    for (double x = 80; x < size.width; x += 240) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
  }

  @override
  bool shouldRepaint(_FoldRulePainter oldDelegate) => false;
}
