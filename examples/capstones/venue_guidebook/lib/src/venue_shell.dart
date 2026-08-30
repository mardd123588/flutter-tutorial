import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../l10n/app_localizations.dart';
import 'venue_guide_controller.dart';
import 'venue_guidebook_app.dart';

class VenueShell extends StatefulWidget {
  const VenueShell({
    required this.controller,
    required this.uri,
    required this.child,
    super.key,
  });

  final VenueGuideController controller;
  final Uri uri;
  final Widget child;

  @override
  State<VenueShell> createState() => _VenueShellState();
}

class _VenueShellState extends State<VenueShell> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  int get _selectedIndex {
    if (widget.uri.path.startsWith('/routes')) return 1;
    if (widget.uri.path.startsWith('/about')) return 2;
    return 0;
  }

  // #region shell-keyboard-boundary
  KeyEventResult _handleKeyEvent(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;
    if (event.logicalKey == LogicalKeyboardKey.escape &&
        (_scaffoldKey.currentState?.isDrawerOpen ?? false)) {
      _scaffoldKey.currentState?.closeDrawer();
      return KeyEventResult.handled;
    }
    if (event.logicalKey == LogicalKeyboardKey.slash && !_isEditingText()) {
      widget.controller.focusSearch(context);
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  bool _isEditingText() {
    final focusContext = FocusManager.instance.primaryFocus?.context;
    if (focusContext == null) return false;
    return focusContext.widget is EditableText ||
        focusContext.findAncestorWidgetOfExactType<EditableText>() != null;
  }
  // #endregion shell-keyboard-boundary

  void _selectDestination(int index) {
    const paths = ['/venues', '/routes', '/about'];
    context.go(paths[index]);
  }

  void _toggleLocale() {
    final previousFocus = FocusManager.instance.primaryFocus;
    final nextLocale = widget.controller.locale.languageCode == 'zh'
        ? const Locale('en')
        : const Locale('zh');
    widget.controller.setLocale(nextLocale, restoreFocus: previousFocus);
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    // #region responsive-navigation-shell
    return Focus(
      onKeyEvent: _handleKeyEvent,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final useRail = constraints.maxWidth >= 900;
          return Scaffold(
            key: _scaffoldKey,
            appBar: useRail
                ? null
                : AppBar(
                    backgroundColor: guideCobaltDeep,
                    foregroundColor: Colors.white,
                    toolbarHeight: 68,
                    leading: IconButton(
                      key: const ValueKey('open-navigation'),
                      tooltip: strings.openNavigation,
                      onPressed: () => _scaffoldKey.currentState?.openDrawer(),
                      icon: const Icon(Icons.menu),
                    ),
                    title: Text(
                      strings.appTitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w900),
                    ),
                    actions: [
                      _LocaleButton(
                        locale: widget.controller.locale,
                        onPressed: _toggleLocale,
                      ),
                      const SizedBox(width: 6),
                    ],
                  ),
            drawer: useRail
                ? null
                : _GuideDrawer(
                    selectedIndex: _selectedIndex,
                    locale: widget.controller.locale,
                    onDestinationSelected: (index) {
                      Navigator.of(context).pop();
                      _selectDestination(index);
                    },
                    onLocalePressed: _toggleLocale,
                  ),
            body: useRail
                ? Row(
                    children: [
                      _GuideRail(
                        selectedIndex: _selectedIndex,
                        locale: widget.controller.locale,
                        onDestinationSelected: _selectDestination,
                        onLocalePressed: _toggleLocale,
                      ),
                      Expanded(child: widget.child),
                    ],
                  )
                : widget.child,
          );
        },
      ),
    );
    // #endregion responsive-navigation-shell
  }
}

class _GuideRail extends StatelessWidget {
  const _GuideRail({
    required this.selectedIndex,
    required this.locale,
    required this.onDestinationSelected,
    required this.onLocalePressed,
  });

  final int selectedIndex;
  final Locale locale;
  final ValueChanged<int> onDestinationSelected;
  final VoidCallback onLocalePressed;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    return SafeArea(
      child: NavigationRail(
        key: const ValueKey('wide-navigation-rail'),
        minWidth: 104,
        backgroundColor: guideCobaltDeep,
        selectedIndex: selectedIndex,
        onDestinationSelected: onDestinationSelected,
        labelType: NavigationRailLabelType.all,
        useIndicator: true,
        indicatorColor: guideChartreuse,
        selectedIconTheme: const IconThemeData(color: guideInk),
        unselectedIconTheme: const IconThemeData(color: Colors.white),
        selectedLabelTextStyle: const TextStyle(
          color: guideChartreuse,
          fontWeight: FontWeight.w900,
        ),
        unselectedLabelTextStyle: const TextStyle(color: Colors.white),
        leading: const Padding(
          padding: EdgeInsets.only(bottom: 18),
          child: _GuideMark(),
        ),
        trailing: Padding(
          padding: const EdgeInsets.only(top: 24),
          child: _LocaleButton(locale: locale, onPressed: onLocalePressed),
        ),
        destinations: [
          NavigationRailDestination(
            icon: const Icon(Icons.place_outlined),
            selectedIcon: const Icon(Icons.place),
            label: Text(strings.venuesDestination),
          ),
          NavigationRailDestination(
            icon: const Icon(Icons.route_outlined),
            selectedIcon: const Icon(Icons.route),
            label: Text(strings.routesDestination),
          ),
          NavigationRailDestination(
            icon: const Icon(Icons.menu_book_outlined),
            selectedIcon: const Icon(Icons.menu_book),
            label: Text(strings.aboutDestination),
          ),
        ],
      ),
    );
  }
}

class _GuideDrawer extends StatelessWidget {
  const _GuideDrawer({
    required this.selectedIndex,
    required this.locale,
    required this.onDestinationSelected,
    required this.onLocalePressed,
  });

  final int selectedIndex;
  final Locale locale;
  final ValueChanged<int> onDestinationSelected;
  final VoidCallback onLocalePressed;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    return NavigationDrawer(
      key: const ValueKey('compact-navigation-drawer'),
      backgroundColor: guidePaperBright,
      selectedIndex: selectedIndex,
      onDestinationSelected: onDestinationSelected,
      children: [
        Container(
          color: guideCobaltDeep,
          padding: const EdgeInsetsDirectional.fromSTEB(24, 28, 24, 22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _GuideMark(),
              const SizedBox(height: 18),
              Text(
                strings.appTitle,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  height: 1,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                strings.appSubtitle,
                style: const TextStyle(color: Color(0xFFDCE4FF), height: 1.4),
              ),
            ],
          ),
        ),
        NavigationDrawerDestination(
          icon: const Icon(Icons.place_outlined),
          selectedIcon: const Icon(Icons.place),
          label: Text(strings.venuesDestination),
        ),
        NavigationDrawerDestination(
          icon: const Icon(Icons.route_outlined),
          selectedIcon: const Icon(Icons.route),
          label: Text(strings.routesDestination),
        ),
        NavigationDrawerDestination(
          icon: const Icon(Icons.menu_book_outlined),
          selectedIcon: const Icon(Icons.menu_book),
          label: Text(strings.aboutDestination),
        ),
        const Divider(),
        Padding(
          padding: const EdgeInsets.all(16),
          child: _LocaleButton(
            locale: locale,
            onPressed: onLocalePressed,
            showLabel: true,
          ),
        ),
      ],
    );
  }
}

class _GuideMark extends StatelessWidget {
  const _GuideMark();

  @override
  Widget build(BuildContext context) {
    return Semantics(
      hidden: true,
      child: Container(
        width: 52,
        height: 52,
        color: guideChartreuse,
        alignment: Alignment.center,
        child: const Text(
          'VG',
          style: TextStyle(
            color: guideInk,
            fontFamily: 'monospace',
            fontSize: 19,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}

class _LocaleButton extends StatelessWidget {
  const _LocaleButton({
    required this.locale,
    required this.onPressed,
    this.showLabel = false,
  });

  final Locale locale;
  final VoidCallback onPressed;
  final bool showLabel;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final switchingToEnglish = locale.languageCode == 'zh';
    final tooltip = switchingToEnglish
        ? strings.switchToEnglish
        : strings.switchToChinese;
    final label = switchingToEnglish ? 'EN' : '中文';
    if (showLabel) {
      return OutlinedButton.icon(
        key: const ValueKey('locale-toggle-drawer'),
        onPressed: onPressed,
        icon: const Icon(Icons.translate),
        label: Text('${strings.languageLabel} · $label'),
      );
    }
    return IconButton(
      key: const ValueKey('locale-toggle'),
      tooltip: tooltip,
      onPressed: onPressed,
      style: IconButton.styleFrom(
        backgroundColor: guideChartreuse,
        foregroundColor: guideInk,
      ),
      icon: Text(label, style: const TextStyle(fontWeight: FontWeight.w900)),
    );
  }
}
