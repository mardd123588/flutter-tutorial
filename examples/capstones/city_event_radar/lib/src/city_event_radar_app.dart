import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'event.dart';
import 'event_local_store.dart';
import 'event_preferences.dart';
import 'event_radar_controller.dart';
import 'event_service.dart';

const _night = Color(0xFF102326);
const _nightDeep = Color(0xFF081416);
const _survey = Color(0xFF9FC7B5);
const _cyan = Color(0xFF68B7C4);
const _sodium = Color(0xFFE39A36);
const _paper = Color(0xFFF1E8CF);
const _paperMuted = Color(0xFFD8CFB8);
const _ink = Color(0xFF182120);
const _danger = Color(0xFFC94A3D);
const _dangerInk = Color(0xFF8F2F27);

class CityEventRadarApp extends StatelessWidget {
  const CityEventRadarApp({
    required this.service,
    required this.preferences,
    required this.localStore,
    this.networkControl,
    this.ownsSavedStore = false,
    this.debounceDuration = const Duration(milliseconds: 320),
    this.now,
    super.key,
  });

  final EventService service;
  final EventPreferenceStore preferences;
  final EventLocalStore localStore;
  final NetworkModeControl? networkControl;
  final bool ownsSavedStore;
  final Duration debounceDuration;
  final DateTime Function()? now;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: '城市活动雷达',
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: _nightDeep,
        colorScheme: ColorScheme.fromSeed(
          seedColor: _sodium,
          brightness: Brightness.dark,
          surface: _night,
        ),
        textSelectionTheme: const TextSelectionThemeData(
          cursorColor: _sodium,
          selectionColor: Color(0x6668B7C4),
          selectionHandleColor: _sodium,
        ),
        focusColor: _sodium,
      ),
      home: CityEventRadarDesk(
        service: service,
        preferences: preferences,
        localStore: localStore,
        networkControl: networkControl,
        ownsSavedStore: ownsSavedStore,
        debounceDuration: debounceDuration,
        now: now,
      ),
    );
  }
}

class CityEventRadarDesk extends StatefulWidget {
  const CityEventRadarDesk({
    required this.service,
    required this.preferences,
    required this.localStore,
    required this.ownsSavedStore,
    required this.debounceDuration,
    this.networkControl,
    this.now,
    super.key,
  });

  final EventService service;
  final EventPreferenceStore preferences;
  final EventLocalStore localStore;
  final NetworkModeControl? networkControl;
  final bool ownsSavedStore;
  final Duration debounceDuration;
  final DateTime Function()? now;

  @override
  State<CityEventRadarDesk> createState() => _CityEventRadarDeskState();
}

class _CityEventRadarDeskState extends State<CityEventRadarDesk> {
  late final EventRadarController _controller;
  late final TextEditingController _searchController;
  late bool _online;

  @override
  void initState() {
    super.initState();
    _online = widget.networkControl?.online ?? true;
    _searchController = TextEditingController();
    _controller = EventRadarController(
      service: widget.service,
      preferences: widget.preferences,
      localStore: widget.localStore,
      debounceDuration: widget.debounceDuration,
      now: widget.now,
    );
    unawaited(_controller.initialize());
  }

  @override
  void dispose() {
    _searchController.dispose();
    _controller.dispose();
    if (widget.ownsSavedStore) unawaited(widget.localStore.close());
    super.dispose();
  }

  Future<void> _setOnline(bool value) async {
    final control = widget.networkControl;
    if (control == null) return;
    control.setOnline(value);
    setState(() => _online = value);
    await _controller.refresh();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 36),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1320),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _RadarHeader(
                        controller: _controller,
                        online: _online,
                        onOnlineChanged: widget.networkControl == null
                            ? null
                            : _setOnline,
                      ),
                      if (_controller.warning != null) ...[
                        const SizedBox(height: 12),
                        _FallbackNotice(message: _controller.warning!),
                      ],
                      const SizedBox(height: 16),
                      _ControlDeck(
                        textController: _searchController,
                        controller: _controller,
                      ),
                      const SizedBox(height: 16),
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final wide = constraints.maxWidth >= 980;
                          final scan = _RadarScan(controller: _controller);
                          final ledger = _DispatchLedger(
                            controller: _controller,
                          );
                          if (!wide) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                _CompactProvenance(controller: _controller),
                                const SizedBox(height: 16),
                                scan,
                                const SizedBox(height: 16),
                                ledger,
                              ],
                            );
                          }
                          return Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(flex: 7, child: scan),
                              const SizedBox(width: 16),
                              Expanded(flex: 3, child: ledger),
                            ],
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                      _EventManifest(controller: _controller),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _RadarHeader extends StatelessWidget {
  const _RadarHeader({
    required this.controller,
    required this.online,
    required this.onOnlineChanged,
  });

  final EventRadarController controller;
  final bool online;
  final ValueChanged<bool>? onOnlineChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: _survey,
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
      child: Wrap(
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 24,
        runSpacing: 16,
        children: [
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '城市活动雷达',
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                    color: _ink,
                    fontFamily: 'serif',
                    fontWeight: FontWeight.w900,
                    height: 0.98,
                    letterSpacing: -1.2,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  '把活动源、缓存时间和本地收藏放在同一张值班图上。离线时仍能看见数据来自哪里。',
                  style: TextStyle(
                    color: _ink,
                    fontSize: 16,
                    height: 1.45,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            color: _night,
            child: Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 8,
              children: [
                Text(
                  online ? '在线 fixture' : '模拟离线',
                  style: const TextStyle(
                    color: _paper,
                    fontFamily: 'monospace',
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Switch(
                  key: const ValueKey('network-switch'),
                  value: online,
                  onChanged: onOnlineChanged,
                  activeTrackColor: _sodium,
                  activeThumbColor: _night,
                  inactiveTrackColor: _danger,
                  inactiveThumbColor: _paper,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FallbackNotice extends StatelessWidget {
  const _FallbackNotice({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      liveRegion: true,
      child: Container(
        key: const ValueKey('fallback-notice'),
        color: _danger,
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            const Icon(Icons.cloud_off, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  height: 1.4,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ControlDeck extends StatelessWidget {
  const _ControlDeck({required this.textController, required this.controller});

  final TextEditingController textController;
  final EventRadarController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: _night,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            key: const ValueKey('event-search-field'),
            controller: textController,
            onChanged: controller.updateQuery,
            decoration: InputDecoration(
              labelText: '搜索活动、场地或标签',
              hintText: '试试“夜”或“河”',
              labelStyle: const TextStyle(color: _paperMuted),
              hintStyle: const TextStyle(color: Color(0xFFB9C7C2)),
              filled: true,
              fillColor: _nightDeep,
              prefixIcon: const Icon(Icons.radar, color: _cyan),
              suffixIcon: textController.text.isEmpty
                  ? null
                  : IconButton(
                      tooltip: '清空搜索',
                      onPressed: () {
                        textController.clear();
                        controller.updateQuery('');
                      },
                      icon: const Icon(Icons.close),
                    ),
              enabledBorder: const OutlineInputBorder(
                borderRadius: BorderRadius.zero,
                borderSide: BorderSide(color: _cyan),
              ),
              focusedBorder: const OutlineInputBorder(
                borderRadius: BorderRadius.zero,
                borderSide: BorderSide(color: _sodium, width: 3),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              for (final district in const ['全部', '东岸', '老城', '西站'])
                _DistrictButton(
                  district: district,
                  selected: controller.district == district,
                  onPressed: () => controller.setDistrict(district),
                ),
              FilterChip(
                key: const ValueKey('saved-only'),
                selected: controller.savedOnly,
                onSelected: controller.setSavedOnly,
                showCheckmark: false,
                avatar: Icon(
                  controller.savedOnly ? Icons.bookmark : Icons.bookmark_border,
                  size: 18,
                ),
                label: const Text('只看收藏'),
                shape: const RoundedRectangleBorder(),
                side: const BorderSide(color: _paperMuted),
                selectedColor: _sodium,
                backgroundColor: _nightDeep,
                labelStyle: TextStyle(
                  color: controller.savedOnly ? _ink : _paper,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DistrictButton extends StatelessWidget {
  const _DistrictButton({
    required this.district,
    required this.selected,
    required this.onPressed,
  });

  final String district;
  final bool selected;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      key: ValueKey('district-$district'),
      onPressed: onPressed,
      style: TextButton.styleFrom(
        foregroundColor: selected ? _ink : _paper,
        backgroundColor: selected ? _sodium : _nightDeep,
        shape: const RoundedRectangleBorder(),
        side: BorderSide(color: selected ? _sodium : _paperMuted),
        minimumSize: const Size(72, 48),
      ),
      child: Text(district),
    );
  }
}

class _RadarScan extends StatelessWidget {
  const _RadarScan({required this.controller});

  final EventRadarController controller;

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    final events = controller.visibleEvents;
    return Container(
      color: _night,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  '城市扫描面',
                  style: TextStyle(
                    color: _paper,
                    fontFamily: 'serif',
                    fontSize: 27,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              if (controller.phase == RadarPhase.loading)
                const SizedBox.square(
                  dimension: 20,
                  child: CircularProgressIndicator(
                    color: _sodium,
                    strokeWidth: 3,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 14),
          Semantics(
            label: '雷达示意图，当前显示 ${events.length} 个活动信号',
            child: AspectRatio(
              aspectRatio: 1.65,
              child: TweenAnimationBuilder<double>(
                key: ValueKey(
                  '${events.map((event) => event.id).join()}-${controller.source}',
                ),
                duration: reduceMotion
                    ? Duration.zero
                    : const Duration(milliseconds: 720),
                curve: Curves.easeOutCubic,
                tween: Tween(begin: 0, end: 1),
                builder: (context, progress, child) {
                  return CustomPaint(
                    painter: _CityRadarPainter(
                      events: events,
                      progress: progress,
                    ),
                    child: child,
                  );
                },
                child: const SizedBox.expand(),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 16,
            runSpacing: 8,
            children: const [
              _LegendDot(color: _sodium, label: '活动信号'),
              _LegendDot(color: _cyan, label: '扫描范围'),
              _LegendDot(color: _survey, label: '分区线'),
            ],
          ),
        ],
      ),
    );
  }
}

class _CityRadarPainter extends CustomPainter {
  const _CityRadarPainter({required this.events, required this.progress});

  final List<CityEvent> events;
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width * 0.53, size.height * 0.5);
    final radius = math.min(size.width, size.height) * 0.42;
    final grid = Paint()
      ..color = _cyan.withValues(alpha: 0.42)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    final roads = Paint()
      ..color = _survey.withValues(alpha: 0.7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    final sweep = Paint()
      ..color = _sodium.withValues(alpha: 0.2)
      ..style = PaintingStyle.fill;

    for (var ring = 1; ring <= 4; ring += 1) {
      canvas.drawCircle(center, radius * ring / 4, grid);
    }
    canvas.drawLine(Offset(center.dx, 0), Offset(center.dx, size.height), grid);
    canvas.drawLine(Offset(0, center.dy), Offset(size.width, center.dy), grid);

    final cityPath = Path()
      ..moveTo(size.width * 0.08, size.height * 0.72)
      ..cubicTo(
        size.width * 0.25,
        size.height * 0.58,
        size.width * 0.32,
        size.height * 0.18,
        size.width * 0.56,
        size.height * 0.3,
      )
      ..cubicTo(
        size.width * 0.73,
        size.height * 0.39,
        size.width * 0.77,
        size.height * 0.8,
        size.width * 0.94,
        size.height * 0.62,
      );
    canvas.drawPath(cityPath, roads);

    final sweepPath = Path()
      ..moveTo(center.dx, center.dy)
      ..arcTo(
        Rect.fromCircle(center: center, radius: radius),
        -math.pi / 2,
        math.pi * 1.35 * progress,
        false,
      )
      ..close();
    canvas.drawPath(sweepPath, sweep);

    for (var index = 0; index < events.length; index += 1) {
      final event = events[index];
      final angle = (index * 2.25 + event.signal / 100) % (math.pi * 2);
      final distance = radius * (0.35 + (event.signal % 50) / 100);
      final point =
          center + Offset(math.cos(angle), math.sin(angle)) * distance;
      final signal = Paint()
        ..color = _sodium
        ..style = PaintingStyle.fill;
      canvas.drawCircle(point, 4 + event.signal / 35, signal);
      canvas.drawCircle(
        point,
        10 + event.signal / 25,
        Paint()
          ..color = _sodium.withValues(alpha: 0.45)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _CityRadarPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.events != events;
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 12, height: 12, color: color),
        const SizedBox(width: 7),
        Text(label, style: const TextStyle(color: _paperMuted)),
      ],
    );
  }
}

class _DispatchLedger extends StatelessWidget {
  const _DispatchLedger({required this.controller});

  final EventRadarController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: _paper,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            '数据值班簿',
            style: TextStyle(
              color: _ink,
              fontFamily: 'serif',
              fontSize: 26,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 14),
          _LedgerRow(label: '来源', value: _sourceLabel(controller.source)),
          _LedgerRow(label: '更新时间', value: controller.freshnessLabel),
          _LedgerRow(
            label: '可见活动',
            value: '${controller.visibleEvents.length}',
          ),
          _LedgerRow(label: '本地收藏', value: '${controller.savedIds.length}'),
          _LedgerRow(
            label: '忽略旧响应',
            value: '${controller.ignoredResponseCount}',
            alert: controller.ignoredResponseCount > 0,
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            key: const ValueKey('refresh-events'),
            onPressed: controller.refresh,
            style: FilledButton.styleFrom(
              backgroundColor: _ink,
              foregroundColor: _paper,
              minimumSize: const Size.fromHeight(48),
              shape: const RoundedRectangleBorder(),
            ),
            icon: const Icon(Icons.refresh),
            label: const Text('刷新当前查询'),
          ),
          const SizedBox(height: 16),
          const Text(
            '活动、场地、时间、价格和信号值均为教学示例。网络由本地 fixture 模拟。',
            style: TextStyle(color: Color(0xFF46504D), height: 1.45),
          ),
        ],
      ),
    );
  }
}

class _CompactProvenance extends StatelessWidget {
  const _CompactProvenance({required this.controller});

  final EventRadarController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: _paper,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Wrap(
        spacing: 22,
        runSpacing: 8,
        children: [
          Text(
            '来源  ${_sourceLabel(controller.source)}',
            style: const TextStyle(
              color: _ink,
              fontFamily: 'monospace',
              fontWeight: FontWeight.w900,
            ),
          ),
          Text(
            '更新时间  ${controller.freshnessLabel}',
            style: const TextStyle(
              color: _ink,
              fontFamily: 'monospace',
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _LedgerRow extends StatelessWidget {
  const _LedgerRow({
    required this.label,
    required this.value,
    this.alert = false,
  });

  final String label;
  final String value;
  final bool alert;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 11),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: _paperMuted)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(color: Color(0xFF4B5552)),
            ),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: TextStyle(
                color: alert ? _dangerInk : _ink,
                fontFamily: 'monospace',
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EventManifest extends StatelessWidget {
  const _EventManifest({required this.controller});

  final EventRadarController controller;

  @override
  Widget build(BuildContext context) {
    final events = controller.visibleEvents;
    return Container(
      color: _paper,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  '活动调度单',
                  style: TextStyle(
                    color: _ink,
                    fontFamily: 'serif',
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              Text(
                '${events.length} SIGNALS',
                style: const TextStyle(
                  color: _dangerInk,
                  fontFamily: 'monospace',
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const Divider(color: _ink, height: 24),
          if (events.isEmpty)
            const _EmptyManifest()
          else
            ...events.map(
              (event) => _EventDispatchRow(
                event: event,
                saved: controller.savedIds.contains(event.id),
                onToggleSaved: () => controller.toggleSaved(event),
              ),
            ),
        ],
      ),
    );
  }
}

class _EmptyManifest extends StatelessWidget {
  const _EmptyManifest();

  @override
  Widget build(BuildContext context) {
    return Semantics(
      liveRegion: true,
      child: Container(
        padding: const EdgeInsets.all(22),
        color: _paperMuted,
        child: const Text(
          '当前搜索、分区和收藏条件没有交集。清空其中一个条件再试。',
          style: TextStyle(
            color: _ink,
            fontSize: 17,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}

class _EventDispatchRow extends StatelessWidget {
  const _EventDispatchRow({
    required this.event,
    required this.saved,
    required this.onToggleSaved,
  });

  final CityEvent event;
  final bool saved;
  final VoidCallback onToggleSaved;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: ValueKey('event-${event.id}'),
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: const BoxDecoration(
        color: Color(0xFFF8F1DE),
        border: Border.fromBorderSide(BorderSide(color: _paperMuted)),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final narrow = constraints.maxWidth < 640;
          final dateBlock = _DateBlock(event: event);
          final details = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 8,
                runSpacing: 6,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(
                    event.title,
                    style: const TextStyle(
                      color: _ink,
                      fontFamily: 'serif',
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      height: 1.1,
                    ),
                  ),
                  _SignalMark(value: event.signal),
                ],
              ),
              const SizedBox(height: 7),
              Text(
                '${event.venue} · ${event.district} · ${event.priceLabel}',
                style: const TextStyle(
                  color: _ink,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 7),
              Text(
                event.summary,
                style: const TextStyle(color: Color(0xFF46504D), height: 1.45),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: event.tags
                    .map(
                      (tag) => Text(
                        '#$tag',
                        style: const TextStyle(
                          color: _dangerInk,
                          fontFamily: 'monospace',
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    )
                    .toList(growable: false),
              ),
            ],
          );
          final action = IconButton.filled(
            key: ValueKey('save-${event.id}'),
            tooltip: saved ? '取消收藏 ${event.title}' : '收藏 ${event.title}',
            onPressed: onToggleSaved,
            style: IconButton.styleFrom(
              backgroundColor: saved ? _sodium : _night,
              foregroundColor: saved ? _ink : _paper,
              shape: const RoundedRectangleBorder(),
              minimumSize: const Size(48, 48),
            ),
            icon: Icon(saved ? Icons.bookmark : Icons.bookmark_border),
          );

          if (narrow) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [dateBlock, const Spacer(), action],
                ),
                const SizedBox(height: 14),
                details,
              ],
            );
          }
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              dateBlock,
              const SizedBox(width: 18),
              Expanded(child: details),
              const SizedBox(width: 14),
              action,
            ],
          );
        },
      ),
    );
  }
}

class _DateBlock extends StatelessWidget {
  const _DateBlock({required this.event});

  final CityEvent event;

  @override
  Widget build(BuildContext context) {
    final date = event.startsAt;
    return Container(
      width: 82,
      padding: const EdgeInsets.all(9),
      color: _night,
      child: Text(
        '${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')}\n${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}',
        style: const TextStyle(
          color: _paper,
          fontFamily: 'monospace',
          fontSize: 16,
          fontWeight: FontWeight.w900,
          height: 1.45,
        ),
      ),
    );
  }
}

class _SignalMark extends StatelessWidget {
  const _SignalMark({required this.value});

  final int value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
      color: _sodium,
      child: Text(
        'SIG $value',
        style: const TextStyle(
          color: _ink,
          fontFamily: 'monospace',
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

String _sourceLabel(RadarSource source) => switch (source) {
  RadarSource.network => '网络 fixture',
  RadarSource.freshCache => '新鲜缓存',
  RadarSource.staleCache => '过期缓存',
  RadarSource.bundledFixture => '内置 fixture',
};
