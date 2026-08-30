import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'route_data.dart';
import 'route_url_codec.dart';
import 'share_clipboard.dart';

const _asphalt = Color(0xFF171B1D);
const _asphaltLight = Color(0xFF272D30);
const _sheet = Color(0xFFF2E9CC);
const _sheetBright = Color(0xFFFFF9E8);
const _ink = Color(0xFF171B1D);
const _mutedInk = Color(0xFF4B514F);
const _safetyYellow = Color(0xFFF2D229);
const _cobalt = Color(0xFF1747D1);
const _errorRed = Color(0xFFB7352B);

typedef ShareUrlBuilder = String Function(Uri location);

String defaultShareUrlBuilder(Uri location) =>
    Uri.base.replace(fragment: location.toString()).toString();

// #region route-share-router
GoRouter createRouteShareRouter({
  String initialLocation = '/',
  ShareClipboard clipboard = const SystemShareClipboard(),
  ShareUrlBuilder shareUrlBuilder = defaultShareUrlBuilder,
}) {
  const codec = RouteUrlCodec();
  return GoRouter(
    initialLocation: initialLocation,
    routes: [
      GoRoute(path: '/', builder: (context, state) => const RouteCatalogPage()),
      GoRoute(
        path: '/routes/:routeId',
        builder: (context, state) {
          final result = codec.parse(state.uri);
          return switch (result) {
            ValidRouteLink() => RouteDetailPage(
              key: ValueKey(state.uri.toString()),
              route: result.route,
              preference: result.preference,
              clipboard: clipboard,
              shareUrlBuilder: shareUrlBuilder,
            ),
            InvalidRouteLink() => RouteLinkErrorPage(result: result),
          };
        },
      ),
    ],
    errorBuilder: (context, state) => UnmatchedRoutePage(uri: state.uri),
  );
}
// #endregion route-share-router

class RouteShareCardApp extends StatelessWidget {
  const RouteShareCardApp({required this.router, super.key});

  final GoRouter router;

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: '路线分享卡',
      routerConfig: router,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: _cobalt,
          brightness: Brightness.light,
          surface: _sheet,
          error: _errorRed,
        ),
        scaffoldBackgroundColor: _asphalt,
        textSelectionTheme: const TextSelectionThemeData(
          cursorColor: _cobalt,
          selectionColor: Color(0x55F2D229),
          selectionHandleColor: _cobalt,
        ),
        focusColor: _safetyYellow,
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: _cobalt,
            foregroundColor: Colors.white,
            minimumSize: const Size(48, 48),
            shape: const RoundedRectangleBorder(),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: _ink,
            minimumSize: const Size(48, 48),
            shape: const RoundedRectangleBorder(),
            side: const BorderSide(color: _ink),
          ),
        ),
      ),
    );
  }
}

class RouteCatalogPage extends StatelessWidget {
  const RouteCatalogPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: CustomPaint(
          painter: const _RoadMarkPainter(),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 42),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1180),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const _CatalogHeader(),
                    const SizedBox(height: 18),
                    ...tourRoutes.indexed.map(
                      (entry) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _RouteManifestRow(
                          index: entry.$1,
                          route: entry.$2,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const _LinkRule(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CatalogHeader extends StatelessWidget {
  const _CatalogHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: _safetyYellow,
      padding: const EdgeInsets.all(22),
      child: Wrap(
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.end,
        spacing: 28,
        runSpacing: 18,
        children: [
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '路线分享卡',
                  style: TextStyle(
                    color: _ink,
                    fontSize: 40,
                    height: 0.98,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -1.3,
                  ),
                ),
                SizedBox(height: 12),
                Text(
                  '选择路线和行进偏好。地址栏会保存这次选择，复制链接就能在另一页恢复。',
                  style: TextStyle(
                    color: _ink,
                    fontSize: 17,
                    height: 1.45,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const _ManifestStamp(label: 'SHEETS', value: '03'),
        ],
      ),
    );
  }
}

class _RouteManifestRow extends StatelessWidget {
  const _RouteManifestRow({required this.index, required this.route});

  final int index;
  final TourRoute route;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label:
          '${route.title}，${route.durationMinutes} 分钟，${route.distanceKilometers} 公里',
      child: Material(
        color: index.isEven ? _sheetBright : _sheet,
        child: InkWell(
          key: ValueKey('open-route-${route.id}'),
          onTap: () => context.go('/routes/${route.id}'),
          focusColor: _safetyYellow.withValues(alpha: 0.34),
          hoverColor: _safetyYellow.withValues(alpha: 0.22),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final compact = constraints.maxWidth < 680;
                final number = _RouteNumber(index: index);
                final details = _RouteRowDetails(route: route);
                final trace = SizedBox(
                  width: compact ? constraints.maxWidth : 210,
                  height: 74,
                  child: CustomPaint(painter: _MiniRoutePainter(index: index)),
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
                      const SizedBox(height: 14),
                      trace,
                    ],
                  );
                }
                return Row(
                  children: [
                    number,
                    const SizedBox(width: 18),
                    Expanded(child: details),
                    const SizedBox(width: 18),
                    trace,
                    const SizedBox(width: 8),
                    const Icon(Icons.arrow_forward, color: _cobalt),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _RouteNumber extends StatelessWidget {
  const _RouteNumber({required this.index});

  final int index;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 50,
      height: 50,
      color: _cobalt,
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

class _RouteRowDetails extends StatelessWidget {
  const _RouteRowDetails({required this.route});

  final TourRoute route;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          route.title,
          style: const TextStyle(
            color: _ink,
            fontSize: 25,
            height: 1.05,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 7),
        Text(
          route.summary,
          style: const TextStyle(color: _mutedInk, fontSize: 15, height: 1.45),
        ),
        const SizedBox(height: 10),
        Text(
          '${route.durationMinutes} MIN  ·  ${route.distanceKilometers.toStringAsFixed(1)} KM  ·  ${route.stops.length} STOPS',
          style: const TextStyle(
            color: _cobalt,
            fontFamily: 'monospace',
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }
}

class _LinkRule extends StatelessWidget {
  const _LinkRule();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: _asphaltLight,
      padding: const EdgeInsets.all(18),
      child: const Wrap(
        spacing: 18,
        runSpacing: 10,
        children: [
          Text(
            '地址规则',
            style: TextStyle(color: _safetyYellow, fontWeight: FontWeight.w900),
          ),
          Text(
            '路线身份写进 path；模式和起点写进 query。链接不依赖登录、缓存或 extra。',
            style: TextStyle(color: Colors.white, height: 1.45),
          ),
        ],
      ),
    );
  }
}

class RouteDetailPage extends StatefulWidget {
  const RouteDetailPage({
    required this.route,
    required this.preference,
    required this.clipboard,
    required this.shareUrlBuilder,
    super.key,
  });

  final TourRoute route;
  final RoutePreference preference;
  final ShareClipboard clipboard;
  final ShareUrlBuilder shareUrlBuilder;

  @override
  State<RouteDetailPage> createState() => _RouteDetailPageState();
}

class _RouteDetailPageState extends State<RouteDetailPage> {
  late final TextEditingController _startController;
  String? _startError;
  bool _copied = false;

  @override
  void initState() {
    super.initState();
    _startController = TextEditingController(text: widget.preference.start);
  }

  @override
  void dispose() {
    _startController.dispose();
    super.dispose();
  }

  void _navigate(RoutePreference preference) {
    final uri = const RouteUrlCodec().encode(widget.route, preference);
    context.go(uri.toString());
  }

  void _changeMode(RouteMode mode) {
    _navigate(RoutePreference(mode: mode, start: widget.preference.start));
  }

  void _submitStart([String? value]) {
    final start = (value ?? _startController.text).trim();
    if (start.isEmpty) {
      setState(() => _startError = '起点不能为空；可以恢复为路线默认入口。');
      return;
    }
    if (start.runes.length > maxStartLength) {
      setState(() => _startError = '起点最多 $maxStartLength 个字符。');
      return;
    }
    setState(() => _startError = null);
    _navigate(RoutePreference(mode: widget.preference.mode, start: start));
  }

  Future<void> _copyLink() async {
    final location = GoRouterState.of(context).uri;
    await widget.clipboard.copy(widget.shareUrlBuilder(location));
    if (!mounted) return;
    setState(() => _copied = true);
  }

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    return Scaffold(
      body: SafeArea(
        child: CustomPaint(
          painter: const _RoadMarkPainter(),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 42),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1240),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _DetailHeader(
                      route: widget.route,
                      preference: widget.preference,
                      copied: _copied,
                      onCopy: _copyLink,
                    ),
                    const SizedBox(height: 18),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final wide = constraints.maxWidth >= 940;
                        final cueSheet = _CueSheet(
                          route: widget.route,
                          preference: widget.preference,
                          animationDuration: reduceMotion
                              ? Duration.zero
                              : const Duration(milliseconds: 280),
                        );
                        final controls = _PreferencePanel(
                          route: widget.route,
                          preference: widget.preference,
                          startController: _startController,
                          startError: _startError,
                          onModeChanged: _changeMode,
                          onStartSubmitted: _submitStart,
                        );
                        if (!wide) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              controls,
                              const SizedBox(height: 18),
                              cueSheet,
                            ],
                          );
                        }
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(flex: 7, child: cueSheet),
                            const SizedBox(width: 18),
                            Expanded(flex: 3, child: controls),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DetailHeader extends StatelessWidget {
  const _DetailHeader({
    required this.route,
    required this.preference,
    required this.copied,
    required this.onCopy,
  });

  final TourRoute route;
  final RoutePreference preference;
  final bool copied;
  final Future<void> Function() onCopy;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: _safetyYellow,
      padding: const EdgeInsets.all(18),
      child: Wrap(
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 18,
        runSpacing: 14,
        children: [
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 12,
            runSpacing: 10,
            children: [
              IconButton(
                key: const ValueKey('back-to-routes'),
                tooltip: '返回路线列表',
                onPressed: () => context.go('/'),
                style: IconButton.styleFrom(
                  backgroundColor: _ink,
                  foregroundColor: Colors.white,
                  shape: const RoundedRectangleBorder(),
                  minimumSize: const Size(48, 48),
                ),
                icon: const Icon(Icons.arrow_back),
              ),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 620),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      route.title,
                      style: const TextStyle(
                        color: _ink,
                        fontSize: 32,
                        height: 1,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.8,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${preference.mode.label}模式 · 从${preference.start}出发',
                      style: const TextStyle(
                        color: _ink,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 12,
            runSpacing: 10,
            children: [
              Semantics(
                key: const ValueKey('copy-status'),
                liveRegion: true,
                label: copied ? '链接已复制' : '链接尚未复制',
                child: Text(
                  copied ? '已复制，可在新标签打开' : '链接只依赖当前 URL',
                  style: const TextStyle(
                    color: _ink,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              FilledButton.icon(
                key: const ValueKey('copy-link'),
                onPressed: onCopy,
                style: FilledButton.styleFrom(
                  backgroundColor: _ink,
                  foregroundColor: Colors.white,
                ),
                icon: Icon(copied ? Icons.check : Icons.link),
                label: Text(copied ? '已复制链接' : '复制完整链接'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PreferencePanel extends StatelessWidget {
  const _PreferencePanel({
    required this.route,
    required this.preference,
    required this.startController,
    required this.startError,
    required this.onModeChanged,
    required this.onStartSubmitted,
  });

  final TourRoute route;
  final RoutePreference preference;
  final TextEditingController startController;
  final String? startError;
  final ValueChanged<RouteMode> onModeChanged;
  final ValueChanged<String> onStartSubmitted;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: _cobalt,
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            '调整分享内容',
            style: TextStyle(
              color: Colors.white,
              fontSize: 25,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            '每次有效修改都会写回地址栏。浏览器返回可以回到上一次选择。',
            style: TextStyle(color: Color(0xFFE2E8FF), height: 1.45),
          ),
          const SizedBox(height: 20),
          const Text(
            '行进模式',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: RouteMode.values.map((mode) {
              final selected = mode == preference.mode;
              return Semantics(
                selected: selected,
                button: true,
                child: selected
                    ? FilledButton(
                        key: ValueKey('mode-${mode.id}'),
                        onPressed: () => onModeChanged(mode),
                        style: FilledButton.styleFrom(
                          backgroundColor: _safetyYellow,
                          foregroundColor: _ink,
                        ),
                        child: Text(mode.label),
                      )
                    : OutlinedButton(
                        key: ValueKey('mode-${mode.id}'),
                        onPressed: () => onModeChanged(mode),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          side: const BorderSide(color: Colors.white),
                        ),
                        child: Text(mode.label),
                      ),
              );
            }).toList(),
          ),
          const SizedBox(height: 18),
          const Text(
            '自定义起点',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 8),
          TextField(
            key: const ValueKey('start-field'),
            controller: startController,
            maxLength: maxStartLength,
            textInputAction: TextInputAction.done,
            onSubmitted: onStartSubmitted,
            style: const TextStyle(color: _ink),
            decoration: InputDecoration(
              hintText: '输入路线起点',
              helperText: '按 Enter 把起点写入 URL',
              errorText: startError,
              hintStyle: const TextStyle(color: _mutedInk),
              helperStyle: const TextStyle(color: Colors.white),
              counterStyle: const TextStyle(color: Colors.white70),
              errorStyle: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
              filled: true,
              fillColor: _sheetBright,
              border: const OutlineInputBorder(borderRadius: BorderRadius.zero),
              focusedBorder: const OutlineInputBorder(
                borderRadius: BorderRadius.zero,
                borderSide: BorderSide(color: _safetyYellow, width: 3),
              ),
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            '路线内起点',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 8),
          ...route.stops
              .take(3)
              .map(
                (stop) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: TextButton(
                    onPressed: () {
                      startController.text = stop;
                      onStartSubmitted(stop);
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.white,
                      alignment: Alignment.centerLeft,
                      minimumSize: const Size(48, 48),
                      shape: const RoundedRectangleBorder(),
                      side: BorderSide(
                        color: stop == preference.start
                            ? _safetyYellow
                            : Colors.white54,
                        width: stop == preference.start ? 2 : 1,
                      ),
                    ),
                    child: Text(stop),
                  ),
                ),
              ),
        ],
      ),
    );
  }
}

class _CueSheet extends StatelessWidget {
  const _CueSheet({
    required this.route,
    required this.preference,
    required this.animationDuration,
  });

  final TourRoute route;
  final RoutePreference preference;
  final Duration animationDuration;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: _sheetBright,
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 26),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.end,
            spacing: 20,
            runSpacing: 12,
            children: [
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      route.id.toUpperCase(),
                      style: const TextStyle(
                        color: _cobalt,
                        fontFamily: 'monospace',
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      route.summary,
                      style: const TextStyle(
                        color: _ink,
                        fontSize: 24,
                        height: 1.15,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
              _ManifestStamp(
                label: preference.mode.id.toUpperCase(),
                value: '${route.durationMinutes}′',
              ),
            ],
          ),
          const SizedBox(height: 18),
          SizedBox(
            height: 190,
            child: Semantics(
              label: '${route.title}路线示意，共 ${route.stops.length} 个站点',
              image: true,
              child: ExcludeSemantics(
                child: AnimatedSwitcher(
                  duration: animationDuration,
                  child: SizedBox.expand(
                    key: ValueKey('${route.id}-${preference.mode.id}'),
                    child: CustomPaint(
                      painter: _CueRoutePainter(mode: preference.mode),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const Divider(color: _ink, height: 28),
          ...route.stops.indexed.map(
            (entry) => _CueStop(
              number: entry.$1 + 1,
              stop: entry.$2,
              start: entry.$2 == preference.start,
              last: entry.$1 == route.stops.length - 1,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            color: _sheet,
            padding: const EdgeInsets.all(14),
            child: Text(
              preference.mode.note,
              style: const TextStyle(color: _mutedInk, height: 1.45),
            ),
          ),
        ],
      ),
    );
  }
}

class _CueStop extends StatelessWidget {
  const _CueStop({
    required this.number,
    required this.stop,
    required this.start,
    required this.last,
  });

  final int number;
  final String stop;
  final bool start;
  final bool last;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '第 $number 站，$stop${start ? '，当前起点' : ''}',
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  color: start ? _safetyYellow : _cobalt,
                  alignment: Alignment.center,
                  child: Text(
                    '$number',
                    style: TextStyle(
                      color: start ? _ink : Colors.white,
                      fontFamily: 'monospace',
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                if (!last) Container(width: 2, height: 22, color: _cobalt),
              ],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 3),
                child: Text(
                  stop,
                  style: TextStyle(
                    color: _ink,
                    fontSize: 17,
                    fontWeight: start ? FontWeight.w900 : FontWeight.w600,
                  ),
                ),
              ),
            ),
            if (start)
              Container(
                color: _safetyYellow,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                child: const Text(
                  '起点',
                  style: TextStyle(color: _ink, fontWeight: FontWeight.w900),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class RouteLinkErrorPage extends StatelessWidget {
  const RouteLinkErrorPage({required this.result, super.key});

  final InvalidRouteLink result;

  @override
  Widget build(BuildContext context) {
    final copy = _errorCopy(result);
    return _ErrorScaffold(
      title: copy.$1,
      body: copy.$2,
      detail: GoRouterState.of(context).uri.toString(),
    );
  }
}

class UnmatchedRoutePage extends StatelessWidget {
  const UnmatchedRoutePage({required this.uri, super.key});

  final Uri uri;

  @override
  Widget build(BuildContext context) {
    return _ErrorScaffold(
      title: '没有匹配的页面',
      body: '这个地址不属于路线列表或路线详情。请回到安全入口重新选择。',
      detail: uri.toString(),
    );
  }
}

class _ErrorScaffold extends StatelessWidget {
  const _ErrorScaffold({
    required this.title,
    required this.body,
    required this.detail,
  });

  final String title;
  final String body;
  final String detail;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(18),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: Container(
                color: _sheetBright,
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      color: _errorRed,
                      padding: const EdgeInsets.all(14),
                      child: const Text(
                        '链接无法恢复',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    const SizedBox(height: 22),
                    Text(
                      title,
                      style: const TextStyle(
                        color: _ink,
                        fontSize: 30,
                        height: 1.05,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      body,
                      style: const TextStyle(color: _mutedInk, height: 1.5),
                    ),
                    const SizedBox(height: 18),
                    SelectableText(
                      detail,
                      style: const TextStyle(
                        color: _cobalt,
                        fontFamily: 'monospace',
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 22),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: FilledButton.icon(
                        key: const ValueKey('return-home'),
                        onPressed: () => context.go('/'),
                        icon: const Icon(Icons.route),
                        label: const Text('返回路线列表'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

(String, String) _errorCopy(InvalidRouteLink result) => switch (result.issue) {
  RouteLinkIssue.unmatchedPath => (
    '路线地址结构不完整',
    '路线详情应使用 /routes/路线ID。请回到列表重新选择。',
  ),
  RouteLinkIssue.unknownRoute => (
    '找不到路线“${result.routeId}”',
    '路线 ID 可能已经写错。固定路线数据中没有这一项。',
  ),
  RouteLinkIssue.duplicateParameter => (
    '参数“${result.parameter}”出现了多次',
    '同一个偏好只能保留一个值。删除重复参数后再打开。',
  ),
  RouteLinkIssue.unsupportedParameter => (
    '不支持参数“${result.parameter}”',
    '这个项目只读取 mode 和 start。删除未知参数后再打开。',
  ),
  RouteLinkIssue.invalidMode => (
    '行进模式“${result.value}”无效',
    'mode 只能是 balanced、quiet 或 fast。',
  ),
  RouteLinkIssue.emptyStart => ('起点不能为空', '删除 start 参数即可使用路线默认入口。'),
  RouteLinkIssue.startTooLong => (
    '起点名称太长',
    'start 最多 $maxStartLength 个字符。缩短名称后再打开。',
  ),
};

class _ManifestStamp extends StatelessWidget {
  const _ManifestStamp({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(border: Border.all(color: _ink, width: 2)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: _ink,
              fontFamily: 'monospace',
              fontSize: 11,
              fontWeight: FontWeight.w900,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: _ink,
              fontFamily: 'monospace',
              fontSize: 22,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _RoadMarkPainter extends CustomPainter {
  const _RoadMarkPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF303638)
      ..strokeWidth = 1;
    for (var y = 24.0; y < size.height; y += 48) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _MiniRoutePainter extends CustomPainter {
  const _MiniRoutePainter({required this.index});

  final int index;

  @override
  void paint(Canvas canvas, Size size) {
    final line = Paint()
      ..color = _cobalt
      ..strokeWidth = 5
      ..style = PaintingStyle.stroke;
    final path = Path()
      ..moveTo(8, size.height * 0.72)
      ..cubicTo(
        size.width * 0.24,
        size.height * (0.1 + index * 0.08),
        size.width * 0.62,
        size.height * (0.92 - index * 0.12),
        size.width - 8,
        size.height * 0.28,
      );
    canvas.drawPath(path, line);
    final stop = Paint()..color = _safetyYellow;
    final metric = path.computeMetrics().first;
    for (final fraction in const [0.06, 0.34, 0.66, 0.94]) {
      final point = metric
          .getTangentForOffset(metric.length * fraction)!
          .position;
      canvas.drawRect(
        Rect.fromCenter(center: point, width: 10, height: 10),
        stop,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _MiniRoutePainter oldDelegate) =>
      oldDelegate.index != index;
}

class _CueRoutePainter extends CustomPainter {
  const _CueRoutePainter({required this.mode});

  final RouteMode mode;

  @override
  void paint(Canvas canvas, Size size) {
    final grid = Paint()
      ..color = const Color(0xFFD2C8A9)
      ..strokeWidth = 1;
    for (var x = 0.0; x <= size.width; x += 36) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), grid);
    }
    for (var y = 0.0; y <= size.height; y += 36) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), grid);
    }

    final path = Path()
      ..moveTo(18, size.height - 26)
      ..cubicTo(
        size.width * 0.18,
        size.height * 0.2,
        size.width * 0.42,
        size.height * 0.88,
        size.width * 0.58,
        size.height * 0.42,
      )
      ..cubicTo(
        size.width * 0.72,
        size.height * 0.02,
        size.width * 0.84,
        size.height * 0.74,
        size.width - 18,
        28,
      );
    canvas.drawPath(
      path,
      Paint()
        ..color = _cobalt
        ..strokeWidth = mode == RouteMode.fast ? 7 : 5
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.square,
    );

    final marker = Paint()..color = _safetyYellow;
    final metric = path.computeMetrics().first;
    for (final fraction in const [0.04, 0.26, 0.5, 0.73, 0.96]) {
      final point = metric
          .getTangentForOffset(metric.length * fraction)!
          .position;
      canvas.drawRect(
        Rect.fromCenter(
          center: point,
          width: mode == RouteMode.quiet ? 16 : 13,
          height: mode == RouteMode.quiet ? 16 : 13,
        ),
        marker,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _CueRoutePainter oldDelegate) =>
      oldDelegate.mode != mode;
}
