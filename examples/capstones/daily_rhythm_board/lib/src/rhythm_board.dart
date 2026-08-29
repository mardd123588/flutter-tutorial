import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'rhythm_data.dart';

const _sand = Color(0xFFF4E9D1);
const _paper = Color(0xFFFFF9ED);
const _ink = Color(0xFF22352C);
const _terracotta = Color(0xFFC95436);
const _sun = Color(0xFFD99B18);
const _water = Color(0xFF54767A);

// #region app
class DailyRhythmApp extends StatelessWidget {
  const DailyRhythmApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: '今日节奏板',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: _terracotta,
          brightness: Brightness.light,
          surface: _paper,
        ),
        scaffoldBackgroundColor: _sand,
        fontFamily: 'sans-serif',
        textTheme: const TextTheme(
          displayLarge: TextStyle(
            color: _ink,
            fontSize: 54,
            height: 1.02,
            fontWeight: FontWeight.w700,
            letterSpacing: -2.2,
          ),
          headlineMedium: TextStyle(
            color: _ink,
            fontSize: 27,
            height: 1.15,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.7,
          ),
          bodyLarge: TextStyle(color: _ink, fontSize: 17, height: 1.65),
          bodyMedium: TextStyle(
            color: Color(0xFF526158),
            fontSize: 15,
            height: 1.55,
          ),
          labelLarge: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
        ),
      ),
      home: const RhythmBoardPage(),
    );
  }
}
// #endregion app

// #region local-state
class RhythmBoardPage extends StatefulWidget {
  const RhythmBoardPage({super.key});

  @override
  State<RhythmBoardPage> createState() => _RhythmBoardPageState();
}

class _RhythmBoardPageState extends State<RhythmBoardPage> {
  var _selectedIndex = 1;

  @override
  Widget build(BuildContext context) {
    final selectedEntry = dailyRhythm[_selectedIndex];

    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 980;

            return SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: isWide ? 56 : 20,
                vertical: isWide ? 42 : 24,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1380),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const _DayHeader(),
                      const SizedBox(height: 42),
                      if (isWide)
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 11,
                              child: _SundialPanel(entry: selectedEntry),
                            ),
                            const SizedBox(width: 42),
                            Expanded(
                              flex: 8,
                              child: _RhythmList(
                                selectedIndex: _selectedIndex,
                                onSelected: _selectEntry,
                              ),
                            ),
                          ],
                        )
                      else ...[
                        _SundialPanel(entry: selectedEntry),
                        const SizedBox(height: 28),
                        _RhythmList(
                          selectedIndex: _selectedIndex,
                          onSelected: _selectEntry,
                        ),
                      ],
                      const SizedBox(height: 34),
                      _SelectedEntry(entry: selectedEntry),
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

  void _selectEntry(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }
}
// #endregion local-state

// #region day-header
class _DayHeader extends StatelessWidget {
  const _DayHeader();

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.spaceBetween,
      crossAxisAlignment: WrapCrossAlignment.end,
      spacing: 28,
      runSpacing: 18,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('今日节奏板', style: Theme.of(context).textTheme.displayLarge),
            const SizedBox(height: 12),
            Text('让一天有明暗，也有停顿。', style: Theme.of(context).textTheme.bodyLarge),
          ],
        ),
        const _DateStamp(),
      ],
    );
  }
}
// #endregion day-header

class _DateStamp extends StatelessWidget {
  const _DateStamp();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(color: _ink),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        child: Text(
          '八月二十九日 · 星期六',
          style: Theme.of(context).textTheme.labelLarge
              ?.copyWith(color: _paper, letterSpacing: 0.8),
        ),
      ),
    );
  }
}

class _SundialPanel extends StatelessWidget {
  const _SundialPanel({required this.entry});

  final RhythmEntry entry;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '日晷指向${entry.time}，${entry.title}',
      image: true,
      excludeSemantics: true,
      child: AspectRatio(
        aspectRatio: 1.18,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: _paper,
            border: Border.all(color: _ink.withValues(alpha: 0.18)),
            boxShadow: const [
              BoxShadow(
                color: Color(0x1F22352C),
                offset: Offset(0, 18),
                blurRadius: 38,
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Stack(
              children: [
                const Positioned(top: 0, left: 0, child: _PanelLegend()),
                Positioned.fill(top: 48, child: _SundialFace(entry: entry)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PanelLegend extends StatelessWidget {
  const _PanelLegend();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const _LegendMark(color: _sun),
        const SizedBox(width: 8),
        Text('日光', style: Theme.of(context).textTheme.bodyMedium),
        const SizedBox(width: 18),
        const _LegendMark(color: _water),
        const SizedBox(width: 8),
        Text('停顿', style: Theme.of(context).textTheme.bodyMedium),
      ],
    );
  }
}

class _LegendMark extends StatelessWidget {
  const _LegendMark({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(width: 18, height: 3, child: ColoredBox(color: color));
  }
}

class _SundialFace extends StatelessWidget {
  const _SundialFace({required this.entry});

  final RhythmEntry entry;

  @override
  Widget build(BuildContext context) {
    final position = sundialPositionFor(entry);
    final angle = -math.pi * 0.42 + math.pi * 0.84 * position;

    return LayoutBuilder(
      builder: (context, constraints) {
        final needleLength = math.min(
          210.0,
          math.min(constraints.maxHeight * 0.9, constraints.maxWidth * 0.48),
        );
        final tickLength = math.min(
          198.0,
          math.min(constraints.maxHeight * 0.9, constraints.maxWidth * 0.44),
        );

        return Stack(
          alignment: Alignment.bottomCenter,
          children: [
            Align(
              alignment: Alignment.bottomCenter,
              child: FractionallySizedBox(
                widthFactor: 0.92,
                heightFactor: 0.84,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: _sun.withValues(alpha: 0.12),
                    border: Border.all(color: _sun, width: 2),
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(500),
                    ),
                  ),
                ),
              ),
            ),
            for (var index = 0; index < 9; index++)
              _SundialTick(index: index, length: tickLength),
            Align(
              alignment: Alignment.bottomCenter,
              child: Transform.rotate(
                angle: angle,
                alignment: Alignment.bottomCenter,
                child: SizedBox(
                  width: 4,
                  height: needleLength,
                  child: const ColoredBox(color: _terracotta),
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                width: 28,
                height: 28,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: _ink,
                ),
              ),
            ),
            Positioned(
              left: 4,
              bottom: 4,
              child: Text(
                '07:00',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
            Positioned(
              right: 4,
              bottom: 4,
              child: Text(
                '19:00',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          ],
        );
      },
    );
  }
}

class _SundialTick extends StatelessWidget {
  const _SundialTick({required this.index, required this.length});

  final int index;
  final double length;

  @override
  Widget build(BuildContext context) {
    final angle = -math.pi * 0.42 + math.pi * 0.105 * index;

    return Align(
      alignment: Alignment.bottomCenter,
      child: Transform.rotate(
        angle: angle,
        alignment: Alignment.bottomCenter,
        child: SizedBox(
          width: 2,
          height: length,
          child: Align(
            alignment: Alignment.topCenter,
            child: SizedBox(
              width: 2,
              height: index.isEven ? 18 : 10,
              child: const ColoredBox(color: _ink),
            ),
          ),
        ),
      ),
    );
  }
}

// #region rhythm-list
class _RhythmList extends StatelessWidget {
  const _RhythmList({required this.selectedIndex, required this.onSelected});

  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('今天的五个落点', style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 12),
        Text(
          '选择一个时段，日晷会转到对应刻度。',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 24),
        for (var index = 0; index < dailyRhythm.length; index++) ...[
          _RhythmEntryButton(
            entry: dailyRhythm[index],
            selected: index == selectedIndex,
            onPressed: () => onSelected(index),
          ),
          if (index != dailyRhythm.length - 1) const SizedBox(height: 10),
        ],
      ],
    );
  }
}
// #endregion rhythm-list

class _RhythmEntryButton extends StatelessWidget {
  const _RhythmEntryButton({
    required this.entry,
    required this.selected,
    required this.onPressed,
  });

  final RhythmEntry entry;
  final bool selected;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final accent = _toneColor(entry.tone);

    return Semantics(
      selected: selected,
      button: true,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          foregroundColor: selected ? _paper : _ink,
          backgroundColor: selected ? _ink : Colors.transparent,
          side: BorderSide(
            color: selected ? _ink : _ink.withValues(alpha: 0.32),
          ),
          shape: const RoundedRectangleBorder(),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 58,
              child: Text(
                entry.time,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: selected ? _paper : accent,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ),
            Container(width: 3, height: 30, color: selected ? _paper : accent),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                entry.title,
                style: Theme.of(context).textTheme.labelLarge
                    ?.copyWith(color: selected ? _paper : _ink),
              ),
            ),
            Text(
              '${entry.durationMinutes} 分',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: selected ? _paper.withValues(alpha: 0.78) : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SelectedEntry extends StatelessWidget {
  const _SelectedEntry({required this.entry});

  final RhythmEntry entry;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(color: _ink),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 24),
        child: Wrap(
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 32,
          runSpacing: 16,
          children: [
            SizedBox(
              width: 220,
              child: Text(
                '${entry.time} · ${entry.title}',
                style: Theme.of(context).textTheme.headlineMedium
                    ?.copyWith(color: _paper),
              ),
            ),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: Text(
                entry.description,
                key: const Key('selected-entry-description'),
                style: Theme.of(context).textTheme.bodyLarge
                    ?.copyWith(color: _paper.withValues(alpha: 0.9)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Color _toneColor(RhythmTone tone) {
  return switch (tone) {
    RhythmTone.rise => _sun,
    RhythmTone.focus => _terracotta,
    RhythmTone.pause => _water,
    RhythmTone.close => _ink,
  };
}
