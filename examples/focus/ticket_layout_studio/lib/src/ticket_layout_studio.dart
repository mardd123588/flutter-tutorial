import 'package:flutter/material.dart';
import 'package:ticket_layout_studio/src/ticket_data.dart';

const _ink = Color(0xFF111820);
const _paper = Color(0xFFF7F0DD);
const _scannerBlue = Color(0xFF0D2B4A);
const _routeBlue = Color(0xFF1646A0);
const _signalYellow = Color(0xFFF4C64E);
const _mutedInk = Color(0xFF44505A);

class TicketLayoutStudioApp extends StatelessWidget {
  const TicketLayoutStudioApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: '票券排版器',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: _routeBlue,
          brightness: Brightness.light,
          surface: _paper,
        ),
        scaffoldBackgroundColor: _scannerBlue,
        textTheme: ThemeData.light().textTheme.apply(
          bodyColor: _ink,
          displayColor: _ink,
        ),
        focusColor: _signalYellow,
      ),
      home: const TicketLayoutStudioPage(),
    );
  }
}

class TicketLayoutStudioPage extends StatefulWidget {
  const TicketLayoutStudioPage({super.key});

  @override
  State<TicketLayoutStudioPage> createState() => _TicketLayoutStudioPageState();
}

class _TicketLayoutStudioPageState extends State<TicketLayoutStudioPage> {
  TicketFormat _format = TicketFormat.gate;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final useColumns = constraints.maxWidth >= 980;
            final content = useColumns
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Expanded(flex: 2, child: _StudioBrief()),
                      Expanded(flex: 5, child: _TicketStage(format: _format)),
                    ],
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const _StudioBrief(),
                      _TicketStage(format: _format),
                    ],
                  );

            return SingleChildScrollView(
              padding: EdgeInsets.all(useColumns ? 32 : 18),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight - (useColumns ? 64 : 36),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _StudioHeader(
                      format: _format,
                      onChanged: (format) => setState(() => _format = format),
                    ),
                    const SizedBox(height: 24),
                    content,
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _StudioHeader extends StatelessWidget {
  const _StudioHeader({required this.format, required this.onChanged});

  final TicketFormat format;
  final ValueChanged<TicketFormat> onChanged;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 24,
      runSpacing: 18,
      alignment: WrapAlignment.spaceBetween,
      crossAxisAlignment: WrapCrossAlignment.end,
      children: [
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '票券排版器',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 36,
                  height: 1,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -1.2,
                ),
              ),
              SizedBox(height: 10),
              Text(
                '改变可用宽度，观察主区、票根和标签如何重新排布。',
                style: TextStyle(color: Color(0xFFC8D6E5), fontSize: 16),
              ),
            ],
          ),
        ),
        _FormatSelector(format: format, onChanged: onChanged),
      ],
    );
  }
}

class _FormatSelector extends StatelessWidget {
  const _FormatSelector({required this.format, required this.onChanged});

  final TicketFormat format;
  final ValueChanged<TicketFormat> onChanged;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '票面宽度',
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          for (final option in TicketFormat.values)
            OutlinedButton(
              onPressed: () => onChanged(option),
              style: OutlinedButton.styleFrom(
                backgroundColor: option == format ? _signalYellow : null,
                foregroundColor: option == format ? _ink : Colors.white,
                side: BorderSide(
                  color: option == format
                      ? _signalYellow
                      : const Color(0xFF7590AA),
                ),
                shape: const RoundedRectangleBorder(),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
              ),
              child: Text(option.label),
            ),
        ],
      ),
    );
  }
}

class _StudioBrief extends StatelessWidget {
  const _StudioBrief();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(22, 24, 22, 28),
      color: _signalYellow,
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'LAYOUT CHECK',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.6,
            ),
          ),
          SizedBox(height: 30),
          Text(
            '先看约束，再选组件。',
            style: TextStyle(
              fontSize: 28,
              height: 1.05,
              fontWeight: FontWeight.w800,
            ),
          ),
          SizedBox(height: 18),
          Text(
            '宽度足够时，Row 把主区和票根排成一行；空间不足时，Column 让票根落到底部。标签始终交给 Wrap。',
            style: TextStyle(fontSize: 16, height: 1.55),
          ),
          SizedBox(height: 28),
          _Rule(label: '430+', value: '横向票根'),
          _Rule(label: '<430', value: '纵向票根'),
          _Rule(label: 'TAGS', value: '按空间换行'),
        ],
      ),
    );
  }
}

class _Rule extends StatelessWidget {
  const _Rule({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Row(
        children: [
          SizedBox(
            width: 64,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
          const Expanded(child: Divider(color: _ink, thickness: 1)),
          const SizedBox(width: 12),
          Text(value),
        ],
      ),
    );
  }
}

// #region constraint-stage
class _TicketStage extends StatelessWidget {
  const _TicketStage({required this.format});

  final TicketFormat format;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF071D32),
      padding: const EdgeInsets.all(18),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = ticketWidthFor(
            availableWidth: constraints.maxWidth,
            format: format,
          );
          return Center(
            child: Semantics(
              key: const Key('ticket-preview'),
              container: true,
              label: '${format.label}，${format.measurement}，滨岸馆到北码头，04 号闸口',
              child: RepaintBoundary(
                child: SizedBox(
                  width: width,
                  child: _TravelTicket(format: format),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
// #endregion constraint-stage

// #region layout-switch
class _TravelTicket extends StatelessWidget {
  const _TravelTicket({required this.format});

  final TicketFormat format;

  @override
  Widget build(BuildContext context) {
    final metrics = metricsFor(format);
    return LayoutBuilder(
      builder: (context, constraints) {
        final stacked = usesStackedStub(constraints.maxWidth);
        final ticketBody = stacked
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _TicketMain(padding: metrics.horizontalPadding),
                  const _Perforation(axis: Axis.horizontal),
                  const _TicketStub(stacked: true),
                ],
              )
            : IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: _TicketMain(padding: metrics.horizontalPadding),
                    ),
                    const _Perforation(axis: Axis.vertical),
                    SizedBox(
                      width: metrics.stubWidth,
                      child: const _TicketStub(stacked: false),
                    ),
                  ],
                ),
              );

        return Stack(
          clipBehavior: Clip.none,
          children: [
            DecoratedBox(
              decoration: const BoxDecoration(
                color: _paper,
                boxShadow: [
                  BoxShadow(
                    color: Color(0x66000000),
                    offset: Offset(0, 18),
                    blurRadius: 34,
                  ),
                ],
              ),
              child: ticketBody,
            ),
            const Positioned(right: 14, top: -12, child: _GatePlaque()),
          ],
        );
      },
    );
  }
}
// #endregion layout-switch

// #region wrap-tags
class _TicketMain extends StatelessWidget {
  const _TicketMain({required this.padding});

  final double padding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(padding, 26, padding, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Wrap(
            alignment: WrapAlignment.spaceBetween,
            spacing: 12,
            runSpacing: 8,
            children: [
              Text(
                'BH-18',
                style: TextStyle(
                  color: _routeBlue,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.6,
                ),
              ),
              Text(
                '2026.09.12',
                style: TextStyle(
                  color: _mutedInk,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 34),
          const Text(
            '滨岸馆 → 北码头',
            style: TextStyle(
              fontSize: 26,
              height: 1.05,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.7,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            '潮线设计周 · 夜间场',
            style: TextStyle(color: _mutedInk, fontSize: 15),
          ),
          const SizedBox(height: 24),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: const [
              _TicketTag('晚场入场'),
              _TicketTag('B 区'),
              _TicketTag('18:40 开放'),
            ],
          ),
        ],
      ),
    );
  }
}
// #endregion wrap-tags

class _TicketTag extends StatelessWidget {
  const _TicketTag(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(border: Border.all(color: _ink)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
        child: Text(
          label,
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800),
        ),
      ),
    );
  }
}

class _GatePlaque extends StatelessWidget {
  const _GatePlaque();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: _routeBlue,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: const Text(
        'GATE 04',
        style: TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w900,
          letterSpacing: 1.1,
        ),
      ),
    );
  }
}

class _TicketStub extends StatelessWidget {
  const _TicketStub({required this.stacked});

  final bool stacked;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: stacked ? 20 : 16,
        vertical: stacked ? 16 : 26,
      ),
      child: stacked
          ? Row(
              children: [
                const Expanded(child: _StubDetails()),
                const SizedBox(width: 18),
                SizedBox(width: 92, child: _RoutingBars(horizontal: true)),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const _StubDetails(),
                const Spacer(),
                _RoutingBars(horizontal: false),
              ],
            ),
    );
  }
}

class _StubDetails extends StatelessWidget {
  const _StubDetails();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'SEAT',
          style: TextStyle(
            color: _mutedInk,
            fontSize: 10,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.4,
          ),
        ),
        SizedBox(height: 6),
        Text(
          'B—17',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
        ),
      ],
    );
  }
}

class _RoutingBars extends StatelessWidget {
  const _RoutingBars({required this.horizontal});

  final bool horizontal;

  @override
  Widget build(BuildContext context) {
    final bars = List<Widget>.generate(17, (index) {
      final thickness = switch (index % 4) {
        0 => 4.0,
        1 => 1.0,
        _ => 2.0,
      };
      return Container(
        width: horizontal ? thickness : null,
        height: horizontal ? 34 : thickness,
        color: _ink,
      );
    });

    return ExcludeSemantics(
      child: horizontal
          ? Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: bars,
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: bars,
            ),
    );
  }
}

class _Perforation extends StatelessWidget {
  const _Perforation({required this.axis});

  final Axis axis;

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: Container(
        width: axis == Axis.vertical ? 1 : null,
        height: axis == Axis.horizontal ? 1 : null,
        color: _mutedInk,
      ),
    );
  }
}
