import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'plant_data.dart';

const _forest = Color(0xFF23352D);
const _deepForest = Color(0xFF14221C);
const _verdigris = Color(0xFF3F7162);
const _verdigrisDark = Color(0xFF294D42);
const _fog = Color(0xFFE8E7DC);
const _mineral = Color(0xFFF5F0DF);
const _ink = Color(0xFF18201C);
const _copper = Color(0xFFC08345);
const _copperDark = Color(0xFF74431F);
const _vermilion = Color(0xFFC84D36);
const _quiet = Color(0xFF66726A);

class PlantCareDeskApp extends StatelessWidget {
  const PlantCareDeskApp({super.key, this.controller});

  final PlantCareController? controller;

  @override
  Widget build(BuildContext context) {
    const square = RoundedRectangleBorder();

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: '植物照护台',
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: _deepForest,
        colorScheme: ColorScheme.fromSeed(
          seedColor: _verdigris,
          brightness: Brightness.light,
          surface: _mineral,
        ),
        focusColor: _copper,
        textSelectionTheme: const TextSelectionThemeData(
          cursorColor: _vermilion,
          selectionColor: Color(0x553F7162),
          selectionHandleColor: _vermilion,
        ),
        filledButtonTheme: const FilledButtonThemeData(
          style: ButtonStyle(shape: WidgetStatePropertyAll(square)),
        ),
        outlinedButtonTheme: const OutlinedButtonThemeData(
          style: ButtonStyle(shape: WidgetStatePropertyAll(square)),
        ),
        iconButtonTheme: const IconButtonThemeData(
          style: ButtonStyle(shape: WidgetStatePropertyAll(square)),
        ),
      ),
      home: PlantCareDeskScreen(controller: controller),
    );
  }
}

// #region plant-care-scope
class PlantCareScope extends InheritedNotifier<PlantCareController> {
  const PlantCareScope({
    super.key,
    required PlantCareController controller,
    required super.child,
  }) : super(notifier: controller);

  static PlantCareController of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<PlantCareScope>();
    assert(scope != null, 'PlantCareScope not found in context');
    return scope!.notifier!;
  }
}
// #endregion plant-care-scope

// #region controller-ownership
class PlantCareDeskScreen extends StatefulWidget {
  const PlantCareDeskScreen({super.key, this.controller});

  final PlantCareController? controller;

  @override
  State<PlantCareDeskScreen> createState() => _PlantCareDeskScreenState();
}

class _PlantCareDeskScreenState extends State<PlantCareDeskScreen> {
  late final PlantCareController _controller;
  late final bool _ownsController;

  @override
  void initState() {
    super.initState();
    _ownsController = widget.controller == null;
    _controller = widget.controller ?? PlantCareController();
  }

  @override
  void dispose() {
    if (_ownsController) {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PlantCareScope(
      controller: _controller,
      child: const Scaffold(body: SafeArea(child: _PlantCareView())),
    );
  }
}
// #endregion controller-ownership

class _PlantCareView extends StatelessWidget {
  const _PlantCareView();

  @override
  Widget build(BuildContext context) {
    final controller = PlantCareScope.of(context);

    return CustomPaint(
      painter: const _ConservatoryBackdropPainter(),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final pagePadding = constraints.maxWidth < 480 ? 14.0 : 28.0;
          final isWide = constraints.maxWidth >= 1050;
          final bench = _CareBench(
            filter: controller.filter,
            plants: controller.visiblePlants,
            onFilterChanged: controller.setFilter,
            onWater: controller.waterPlant,
          );
          final register = _ActionRegister(
            message: controller.message,
            canUndo: controller.canUndo,
            onUndo: controller.undoLastCare,
          );

          return SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(
              pagePadding,
              pagePadding,
              pagePadding,
              48,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _StatusRail(
                  totalCount: controller.plants.length,
                  needsCareCount: controller.needsCareCount,
                ),
                const SizedBox(height: 18),
                if (isWide)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(flex: 7, child: bench),
                      const SizedBox(width: 20),
                      SizedBox(width: 330, child: register),
                    ],
                  )
                else ...[
                  bench,
                  const SizedBox(height: 18),
                  register,
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}

class _StatusRail extends StatelessWidget {
  const _StatusRail({required this.totalCount, required this.needsCareCount});

  final int totalCount;
  final int needsCareCount;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: const _OxidizedPlatePainter(accent: true),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(26, 24, 26, 26),
        child: Wrap(
          spacing: 32,
          runSpacing: 18,
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.end,
          children: [
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 590),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '植物照护台',
                    style: TextStyle(
                      color: _mineral,
                      fontFamily: 'serif',
                      fontSize: 40,
                      height: 0.96,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -1.2,
                      shadows: [
                        Shadow(
                          color: Color(0x99000000),
                          offset: Offset(2, 3),
                          blurRadius: 6,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 14),
                  Text(
                    '先处理缺水记录，再检查读数与叶片观察。每次操作都保留一次可撤销快照。',
                    style: TextStyle(color: _fog, height: 1.5, fontSize: 15),
                  ),
                ],
              ),
            ),
            _ObservationCounter(
              totalCount: totalCount,
              needsCareCount: needsCareCount,
            ),
          ],
        ),
      ),
    );
  }
}

class _ObservationCounter extends StatelessWidget {
  const _ObservationCounter({
    required this.totalCount,
    required this.needsCareCount,
  });

  final int totalCount;
  final int needsCareCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 300),
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 13),
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(color: _copper),
          bottom: BorderSide(color: _copper),
        ),
      ),
      child: Text(
        '教学示例数据 · $totalCount 份记录 · $needsCareCount 项待照护',
        style: const TextStyle(
          color: _mineral,
          fontFamily: 'monospace',
          fontWeight: FontWeight.w800,
          height: 1.45,
        ),
      ),
    );
  }
}

class _CareBench extends StatelessWidget {
  const _CareBench({
    required this.filter,
    required this.plants,
    required this.onFilterChanged,
    required this.onWater,
  });

  final PlantFilter filter;
  final List<PlantRecord> plants;
  final ValueChanged<PlantFilter> onFilterChanged;
  final ValueChanged<String> onWater;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: const _OxidizedPlatePainter(),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              color: _forest,
              padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '照护工作台',
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'serif',
                      fontSize: 23,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final option in PlantFilter.values)
                        ChoiceChip(
                          key: ValueKey('filter-${option.name}'),
                          label: Text(option.label),
                          selected: filter == option,
                          onSelected: (_) => onFilterChanged(option),
                          selectedColor: _mineral,
                          backgroundColor: _deepForest,
                          labelStyle: TextStyle(
                            color: filter == option ? _ink : _fog,
                            fontWeight: FontWeight.w800,
                          ),
                          side: BorderSide(
                            color: filter == option ? _copper : _verdigris,
                          ),
                          shape: const RoundedRectangleBorder(),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            if (plants.isEmpty)
              const _EmptyBench()
            else
              // #region keyed-plant-list
              Column(
                children: [
                  for (final plant in plants)
                    _PlantInstrument(
                      key: ValueKey(plant.id),
                      plant: plant,
                      onWater: () => onWater(plant.id),
                    ),
                ],
              ),
            // #endregion keyed-plant-list
          ],
        ),
      ),
    );
  }
}

class _EmptyBench extends StatelessWidget {
  const _EmptyBench();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: const _MineralPaperPainter(),
      child: const Padding(
        padding: EdgeInsets.all(24),
        child: Text(
          '当前筛选下没有记录。可以切换筛选条件，或撤销刚才的照护操作。',
          style: TextStyle(color: _ink, fontSize: 16, height: 1.5),
        ),
      ),
    );
  }
}

class _PlantInstrument extends StatefulWidget {
  const _PlantInstrument({
    super.key,
    required this.plant,
    required this.onWater,
  });

  final PlantRecord plant;
  final VoidCallback onWater;

  @override
  State<_PlantInstrument> createState() => _PlantInstrumentState();
}

class _PlantInstrumentState extends State<_PlantInstrument> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final plant = widget.plant;

    return Semantics(
      container: true,
      label:
          '${plant.name}，${plant.zone}，湿度 ${plant.moisture}%，目标 ${plant.targetMoisture}%',
      child: Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: CustomPaint(
          painter: _InstrumentFramePainter(needsCare: plant.needsCare),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 14),
            child: CustomPaint(
              painter: const _MineralPaperPainter(),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final isWide = constraints.maxWidth >= 650;
                    final identity = _PlantIdentity(plant: plant);
                    final gauge = _MoistureGauge(
                      plantId: plant.id,
                      moisture: plant.moisture,
                      target: plant.targetMoisture,
                    );
                    final controls = _PlantControls(
                      plant: plant,
                      expanded: _expanded,
                      onToggle: () => setState(() => _expanded = !_expanded),
                      onWater: widget.onWater,
                    );

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (isWide)
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              SizedBox(width: 184, child: identity),
                              const SizedBox(width: 18),
                              Expanded(child: gauge),
                              const SizedBox(width: 18),
                              SizedBox(width: 190, child: controls),
                            ],
                          )
                        else ...[
                          identity,
                          const SizedBox(height: 16),
                          gauge,
                          const SizedBox(height: 16),
                          controls,
                        ],
                        if (_expanded) ...[
                          const SizedBox(height: 16),
                          Container(
                            key: ValueKey('observation-${plant.id}'),
                            padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
                            decoration: const BoxDecoration(
                              border: Border(
                                top: BorderSide(color: _copper, width: 2),
                              ),
                            ),
                            child: Text(
                              plant.observation,
                              style: const TextStyle(color: _ink, height: 1.5),
                            ),
                          ),
                        ],
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PlantIdentity extends StatelessWidget {
  const _PlantIdentity({required this.plant});

  final PlantRecord plant;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          plant.name,
          style: const TextStyle(
            color: _ink,
            fontFamily: 'serif',
            fontSize: 25,
            height: 1,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 9),
        Text(
          plant.zone.toUpperCase(),
          style: const TextStyle(
            color: _quiet,
            fontFamily: 'monospace',
            fontSize: 12,
            fontWeight: FontWeight.w900,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 14),
        _ServiceStamp(needsCare: plant.needsCare),
      ],
    );
  }
}

class _ServiceStamp extends StatelessWidget {
  const _ServiceStamp({required this.needsCare});

  final bool needsCare;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _ServiceStampPainter(needsCare: needsCare),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(10, 7, 10, 8),
        child: Text(
          needsCare ? '待照护 · 低于目标' : '读数稳定',
          style: TextStyle(
            color: needsCare ? _vermilion : _verdigrisDark,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}

// #region implicit-moisture
class _MoistureGauge extends StatelessWidget {
  const _MoistureGauge({
    required this.plantId,
    required this.moisture,
    required this.target,
  });

  final String plantId;
  final int moisture;
  final int target;

  @override
  Widget build(BuildContext context) {
    final disableAnimations = MediaQuery.disableAnimationsOf(context);

    return TweenAnimationBuilder<double>(
      key: ValueKey('moisture-tween-$plantId'),
      tween: Tween<double>(end: moisture / 100),
      duration: disableAnimations
          ? Duration.zero
          : const Duration(milliseconds: 480),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Wrap(
              spacing: 12,
              runSpacing: 4,
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                const Text(
                  '土壤湿度表',
                  style: TextStyle(
                    color: _ink,
                    fontFamily: 'serif',
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  '目标 $target%',
                  style: const TextStyle(
                    color: _quiet,
                    fontFamily: 'monospace',
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 154,
              child: CustomPaint(
                painter: _MoistureDialPainter(
                  value: value,
                  target: target / 100,
                ),
                child: Align(
                  alignment: const Alignment(0, 0.34),
                  child: Text(
                    '${(value * 100).round()}%',
                    style: const TextStyle(
                      color: _ink,
                      fontFamily: 'monospace',
                      fontSize: 25,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 6),
            SizedBox(
              height: 26,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CustomPaint(painter: _SlideRulePainter(target: target / 100)),
                  FractionallySizedBox(
                    key: ValueKey('moisture-fill-$plantId'),
                    widthFactor: value,
                    alignment: Alignment.centerLeft,
                    child: const Align(
                      alignment: Alignment.topRight,
                      child: _CopperSliderMarker(),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
// #endregion implicit-moisture

class _CopperSliderMarker extends StatelessWidget {
  const _CopperSliderMarker();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 4,
      height: 22,
      decoration: const BoxDecoration(
        color: _copper,
        boxShadow: [
          BoxShadow(
            color: Color(0x66000000),
            offset: Offset(1, 2),
            blurRadius: 2,
          ),
        ],
      ),
    );
  }
}

class _PlantControls extends StatelessWidget {
  const _PlantControls({
    required this.plant,
    required this.expanded,
    required this.onToggle,
    required this.onWater,
  });

  final PlantRecord plant;
  final bool expanded;
  final VoidCallback onToggle;
  final VoidCallback onWater;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        OutlinedButton.icon(
          key: ValueKey('expand-${plant.id}'),
          onPressed: onToggle,
          icon: Icon(expanded ? Icons.expand_less : Icons.expand_more),
          label: Text(expanded ? '收起观察' : '查看观察'),
          style: OutlinedButton.styleFrom(foregroundColor: _forest),
        ),
        const SizedBox(height: 8),
        FilledButton.icon(
          key: ValueKey('water-${plant.id}'),
          onPressed: onWater,
          icon: const Icon(Icons.water_drop_outlined),
          label: const Text('记录浇水'),
          style: FilledButton.styleFrom(
            backgroundColor: _vermilion,
            foregroundColor: Colors.white,
          ),
        ),
      ],
    );
  }
}

class _ActionRegister extends StatelessWidget {
  const _ActionRegister({
    required this.message,
    required this.canUndo,
    required this.onUndo,
  });

  final String message;
  final bool canUndo;
  final VoidCallback onUndo;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: const _RegisterFramePainter(),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 26),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              '操作回执',
              style: TextStyle(
                color: _mineral,
                fontFamily: 'serif',
                fontSize: 24,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              '共享状态变化会通知整张工作台；回执只负责呈现这次变化。',
              style: TextStyle(color: _fog, height: 1.5),
            ),
            const SizedBox(height: 18),
            _CareReceipt(message: message),
            const SizedBox(height: 14),
            OutlinedButton.icon(
              key: const Key('undo-care'),
              onPressed: canUndo ? onUndo : null,
              icon: const Icon(Icons.undo),
              label: const Text('撤销上次照护'),
              style: OutlinedButton.styleFrom(
                foregroundColor: _mineral,
                disabledForegroundColor: _quiet,
                side: BorderSide(color: canUndo ? _copper : _quiet),
              ),
            ),
            const SizedBox(height: 28),
            const _RegisterRule(label: '状态源', value: 'ChangeNotifier'),
            const _RegisterRule(label: '子树依赖', value: 'InheritedNotifier'),
            const _RegisterRule(label: '行内身份', value: 'ValueKey(id)'),
            const _RegisterRule(label: '动效偏好', value: 'MediaQuery'),
          ],
        ),
      ),
    );
  }
}

// #region explicit-receipt
class _CareReceipt extends StatefulWidget {
  const _CareReceipt({required this.message});

  final String message;

  @override
  State<_CareReceipt> createState() => _CareReceiptState();
}

class _CareReceiptState extends State<_CareReceipt>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacity;
  late final Animation<Offset> _offset;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 360),
    );
    _opacity = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _offset = Tween<Offset>(
      begin: const Offset(0, 0.18),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
    _controller.forward();
  }

  @override
  void didUpdateWidget(covariant _CareReceipt oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.message != oldWidget.message) {
      _play();
    }
  }

  void _play() {
    if (MediaQuery.maybeDisableAnimationsOf(context) ?? false) {
      _controller.value = 1;
    } else {
      _controller.forward(from: 0);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _controller.value = 1;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final receipt = Semantics(
      liveRegion: true,
      child: CustomPaint(
        key: const Key('care-message'),
        painter: const _MineralPaperPainter(stamped: true),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
          child: Text(
            widget.message,
            style: const TextStyle(
              color: _ink,
              fontWeight: FontWeight.w800,
              height: 1.45,
            ),
          ),
        ),
      ),
    );

    if (MediaQuery.disableAnimationsOf(context)) {
      return receipt;
    }

    return FadeTransition(
      key: const Key('receipt-fade'),
      opacity: _opacity,
      child: SlideTransition(position: _offset, child: receipt),
    );
  }
}
// #endregion explicit-receipt

class _RegisterRule extends StatelessWidget {
  const _RegisterRule({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: _verdigris)),
      ),
      child: Wrap(
        alignment: WrapAlignment.spaceBetween,
        spacing: 10,
        runSpacing: 4,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: _fog,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: _copper,
              fontFamily: 'monospace',
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _ConservatoryBackdropPainter extends CustomPainter {
  const _ConservatoryBackdropPainter();

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = _deepForest);
    final bar = Paint()
      ..color = const Color(0x1A6C8D7E)
      ..strokeWidth = 2;
    for (var index = 0; index < 12; index++) {
      final x = (index * 137.0 + 43) % size.width;
      canvas.drawLine(Offset(x, 0), Offset(x + 26, size.height), bar);
    }
    final bloom = Paint()
      ..shader =
          const RadialGradient(
            colors: [Color(0x334A826F), Color(0x0014221C)],
          ).createShader(
            Rect.fromCircle(center: Offset(size.width * 0.78, 0), radius: 420),
          );
    canvas.drawRect(Offset.zero & size, bloom);
  }

  @override
  bool shouldRepaint(covariant _ConservatoryBackdropPainter oldDelegate) {
    return false;
  }
}

class _OxidizedPlatePainter extends CustomPainter {
  const _OxidizedPlatePainter({this.accent = false});

  final bool accent;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final metal = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [_verdigris, _forest, _verdigrisDark],
        stops: [0, 0.56, 1],
      ).createShader(rect);
    canvas.drawRect(rect, metal);
    final oxidation = Paint()..color = const Color(0x245DB19A);
    for (var index = 0; index < 36; index++) {
      final x = (index * 79.0 + 13) % size.width;
      final y = (index * 47.0 + 29) % size.height;
      canvas.drawCircle(Offset(x, y), 1.4 + (index % 3), oxidation);
    }
    canvas.drawRect(
      Rect.fromLTWH(0, 0, accent ? 8 : 4, size.height),
      Paint()..color = accent ? _copper : _verdigrisDark,
    );
    _drawBolt(canvas, const Offset(10, 10));
    _drawBolt(canvas, Offset(size.width - 10, 10));
    _drawBolt(canvas, Offset(10, size.height - 10));
    _drawBolt(canvas, Offset(size.width - 10, size.height - 10));
  }

  void _drawBolt(Canvas canvas, Offset center) {
    canvas.drawCircle(center, 4.5, Paint()..color = _copperDark);
    canvas.drawCircle(center, 2.2, Paint()..color = _copper);
  }

  @override
  bool shouldRepaint(covariant _OxidizedPlatePainter oldDelegate) {
    return oldDelegate.accent != accent;
  }
}

class _InstrumentFramePainter extends CustomPainter {
  const _InstrumentFramePainter({required this.needsCare});

  final bool needsCare;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final metal = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [_verdigris, _forest, _verdigrisDark],
      ).createShader(rect);
    canvas.drawRect(rect, metal);
    canvas.drawRect(
      Rect.fromLTWH(0, 0, needsCare ? 9 : 4, size.height),
      Paint()..color = needsCare ? _vermilion : _copper,
    );
    final scratch = Paint()
      ..color = const Color(0x356DB09C)
      ..strokeWidth = 0.8;
    for (var index = 0; index < 10; index++) {
      final y = (index * 31.0 + 13) % size.height;
      canvas.drawLine(Offset(10, y), Offset(size.width - 8, y + 2), scratch);
    }
  }

  @override
  bool shouldRepaint(covariant _InstrumentFramePainter oldDelegate) {
    return oldDelegate.needsCare != needsCare;
  }
}

class _MineralPaperPainter extends CustomPainter {
  const _MineralPaperPainter({this.stamped = false});

  final bool stamped;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.drawRect(rect, Paint()..color = _mineral);
    final fiber = Paint()
      ..color = const Color(0x1866726A)
      ..strokeWidth = 0.8;
    for (var index = 0; index < 16; index++) {
      final y = (index * 27.0 + 11) % size.height;
      canvas.drawLine(
        Offset((index * 9.0) % 24, y),
        Offset(size.width - ((index * 13.0) % 26), y + 1),
        fiber,
      );
    }
    if (stamped) {
      canvas.drawCircle(
        Offset(size.width - 20, 18),
        10,
        Paint()
          ..color = _vermilion
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
      canvas.drawLine(
        Offset(size.width - 27, 18),
        Offset(size.width - 13, 18),
        Paint()
          ..color = _vermilion
          ..strokeWidth = 1.4,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _MineralPaperPainter oldDelegate) {
    return oldDelegate.stamped != stamped;
  }
}

class _ServiceStampPainter extends CustomPainter {
  const _ServiceStampPainter({required this.needsCare});

  final bool needsCare;

  @override
  void paint(Canvas canvas, Size size) {
    final color = needsCare ? _vermilion : _verdigrisDark;
    canvas.drawRect(
      Offset.zero & size,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
    canvas.drawRect(
      (Offset.zero & size).deflate(3),
      Paint()
        ..color = color.withValues(alpha: 0.6)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );
  }

  @override
  bool shouldRepaint(covariant _ServiceStampPainter oldDelegate) {
    return oldDelegate.needsCare != needsCare;
  }
}

class _MoistureDialPainter extends CustomPainter {
  const _MoistureDialPainter({required this.value, required this.target});

  final double value;
  final double target;

  static const _startAngle = math.pi * 0.75;
  static const _sweepAngle = math.pi * 1.5;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height * 0.54);
    final radius = math.min(size.width * 0.38, size.height * 0.46);
    final dialRect = Rect.fromCircle(center: center, radius: radius + 12);
    final glass = Paint()
      ..shader = const RadialGradient(
        center: Alignment(-0.24, -0.34),
        colors: [Color(0xFFF7F8F0), Color(0xFFD6DDD6), Color(0xFF8FA49A)],
        stops: [0, 0.7, 1],
      ).createShader(dialRect);
    canvas.drawOval(dialRect, glass);
    canvas.drawOval(
      dialRect,
      Paint()
        ..color = _copperDark
        ..style = PaintingStyle.stroke
        ..strokeWidth = 5,
    );
    canvas.drawOval(
      dialRect.deflate(6),
      Paint()
        ..color = const Color(0x8893B1A5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );

    for (var tick = 0; tick <= 20; tick++) {
      final angle = _startAngle + _sweepAngle * (tick / 20);
      final isMajor = tick % 5 == 0;
      final outer = _pointOnCircle(center, radius, angle);
      final inner = _pointOnCircle(center, radius - (isMajor ? 14 : 8), angle);
      canvas.drawLine(
        inner,
        outer,
        Paint()
          ..color = _ink
          ..strokeWidth = isMajor ? 2 : 1,
      );
    }

    final targetAngle = _startAngle + _sweepAngle * target.clamp(0, 1);
    canvas.drawLine(
      _pointOnCircle(center, radius - 20, targetAngle),
      _pointOnCircle(center, radius + 2, targetAngle),
      Paint()
        ..color = _vermilion
        ..strokeWidth = 3,
    );

    final angle = _startAngle + _sweepAngle * value.clamp(0, 1);
    final needleEnd = _pointOnCircle(center, radius - 17, angle);
    canvas.drawLine(
      center.translate(2, 3),
      needleEnd.translate(2, 3),
      Paint()
        ..color = const Color(0x55000000)
        ..strokeWidth = 5
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawLine(
      center,
      needleEnd,
      Paint()
        ..color = _copper
        ..strokeWidth = 4
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawCircle(center, 8, Paint()..color = _copperDark);
    canvas.drawCircle(center, 4, Paint()..color = _copper);

    final condensation = Paint()..color = const Color(0x447B9A8E);
    for (var index = 0; index < 9; index++) {
      final x = center.dx - radius * 0.55 + (index * 19.0) % (radius * 1.1);
      final y = center.dy - radius * 0.54 + (index * 13.0) % (radius * 0.62);
      canvas.drawCircle(Offset(x, y), 1.4 + (index % 3), condensation);
    }
  }

  Offset _pointOnCircle(Offset center, double radius, double angle) {
    return Offset(
      center.dx + math.cos(angle) * radius,
      center.dy + math.sin(angle) * radius,
    );
  }

  @override
  bool shouldRepaint(covariant _MoistureDialPainter oldDelegate) {
    return oldDelegate.value != value || oldDelegate.target != target;
  }
}

class _SlideRulePainter extends CustomPainter {
  const _SlideRulePainter({required this.target});

  final double target;

  @override
  void paint(Canvas canvas, Size size) {
    final centerY = size.height / 2;
    canvas.drawLine(
      Offset(0, centerY),
      Offset(size.width, centerY),
      Paint()
        ..color = _quiet
        ..strokeWidth = 2,
    );
    final tickPaint = Paint()
      ..color = _quiet
      ..strokeWidth = 1;
    for (var tick = 0; tick <= 10; tick++) {
      final x = size.width * tick / 10;
      final height = tick % 5 == 0 ? 12.0 : 7.0;
      canvas.drawLine(
        Offset(x, centerY - height / 2),
        Offset(x, centerY + height / 2),
        tickPaint,
      );
    }
    final targetX = size.width * target.clamp(0, 1);
    canvas.drawLine(
      Offset(targetX, 2),
      Offset(targetX, size.height - 2),
      Paint()
        ..color = _vermilion
        ..strokeWidth = 2,
    );
  }

  @override
  bool shouldRepaint(covariant _SlideRulePainter oldDelegate) {
    return oldDelegate.target != target;
  }
}

class _RegisterFramePainter extends CustomPainter {
  const _RegisterFramePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.drawRect(rect, Paint()..color = _forest);
    canvas.drawRect(
      Rect.fromLTWH(0, 0, 6, size.height),
      Paint()..color = _copper,
    );
    final line = Paint()
      ..color = const Color(0x334D8C77)
      ..strokeWidth = 1;
    for (var index = 0; index < 18; index++) {
      final y = 74.0 + index * 27;
      if (y < size.height) {
        canvas.drawLine(Offset(12, y), Offset(size.width - 10, y), line);
      }
    }
    canvas.drawLine(
      const Offset(14, 14),
      Offset(size.width - 14, 14),
      Paint()
        ..color = _copperDark
        ..strokeWidth = 1,
    );
  }

  @override
  bool shouldRepaint(covariant _RegisterFramePainter oldDelegate) => false;
}
