import 'package:flutter/material.dart';

import 'duty_data.dart';

const _stone = Color(0xFF2E322E);
const _deepStone = Color(0xFF171A18);
const _zinc = Color(0xFFC9C8BF);
const _zincLight = Color(0xFFE2E0D7);
const _zincDark = Color(0xFF686B65);
const _proofPaper = Color(0xFFF2EBD9);
const _ink = Color(0xFF1A1D1A);
const _oxide = Color(0xFFA43C2B);
const _proofBlue = Color(0xFF2C6670);

class SortableDutyBoardApp extends StatelessWidget {
  const SortableDutyBoardApp({super.key});

  @override
  Widget build(BuildContext context) {
    const square = RoundedRectangleBorder();

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: '可排序值班板',
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: _stone,
        colorScheme: ColorScheme.fromSeed(
          seedColor: _oxide,
          brightness: Brightness.dark,
          surface: _stone,
        ),
        focusColor: _proofBlue,
        textSelectionTheme: const TextSelectionThemeData(
          cursorColor: _oxide,
          selectionColor: Color(0x554A8D98),
          selectionHandleColor: _oxide,
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
        inputDecorationTheme: const InputDecorationTheme(
          filled: true,
          fillColor: Color(0xFFF8F3E6),
          labelStyle: TextStyle(color: Color(0xFF4B514B)),
          floatingLabelStyle: TextStyle(color: _proofBlue),
          border: OutlineInputBorder(borderRadius: BorderRadius.zero),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.zero,
            borderSide: BorderSide(color: _zincDark),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.zero,
            borderSide: BorderSide(color: _proofBlue, width: 2),
          ),
        ),
      ),
      home: const SortableDutyBoardScreen(),
    );
  }
}

class SortableDutyBoardScreen extends StatefulWidget {
  const SortableDutyBoardScreen({super.key});

  @override
  State<SortableDutyBoardScreen> createState() =>
      _SortableDutyBoardScreenState();
}

class _SortableDutyBoardScreenState extends State<SortableDutyBoardScreen> {
  List<DutyMember> _members = seedDutyMembers;
  String _status = '当前顺序已装版，行内状态由成员身份固定。';

  void _reorder(int oldIndex, int newIndex) {
    final movedMember = _members[oldIndex];
    setState(() {
      _members = reorderDutyMembers(_members, oldIndex, newIndex);
      final currentIndex = _members.indexOf(movedMember) + 1;
      _status = '${movedMember.name}已移到第 $currentIndex 位，交接内容保持不变。';
    });
  }

  void _move(String memberId, int offset) {
    final member = _members.firstWhere((item) => item.id == memberId);
    setState(() {
      _members = moveDutyMember(_members, memberId, offset);
      final currentIndex =
          _members.indexWhere((item) => item.id == memberId) + 1;
      _status = '${member.name}已移到第 $currentIndex 位，交接内容保持不变。';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomPaint(
        painter: const _StoneSurfacePainter(),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth >= 980;
              final pagePadding = constraints.maxWidth < 480 ? 14.0 : 28.0;
              final proof = _ProofColumn(memberCount: _members.length);
              final galley = _ComposingGalley(
                members: _members,
                status: _status,
                onReorder: _reorder,
                onMove: _move,
              );

              return SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                  pagePadding,
                  pagePadding,
                  pagePadding,
                  48,
                ),
                child: isWide
                    ? Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(width: 310, child: proof),
                          const SizedBox(width: 28),
                          Expanded(child: galley),
                        ],
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [proof, const SizedBox(height: 24), galley],
                      ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _ProofColumn extends StatelessWidget {
  const _ProofColumn({required this.memberCount});

  final int memberCount;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: const _InkStonePainter(),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '可排序\n值班板',
              style: Theme.of(context).textTheme.displaySmall?.copyWith(
                color: _proofPaper,
                fontFamily: 'serif',
                fontWeight: FontWeight.w900,
                height: 0.94,
                letterSpacing: -1.1,
                shadows: const [
                  Shadow(
                    color: Color(0x88000000),
                    offset: Offset(2, 3),
                    blurRadius: 5,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),
            const _ProofSheet(
              child: Text(
                '把成员当作可移动铅字。顺序会改变，姓名对应的备注和确认状态不能换人。',
                style: TextStyle(color: _ink, height: 1.55, fontSize: 16),
              ),
            ),
            const SizedBox(height: 26),
            const _ProofRule(label: 'IDENTITY', value: 'ValueKey(member.id)'),
            const _ProofRule(label: 'LOCAL STATE', value: '备注 · 交接确认'),
            _ProofRule(label: 'SLUGS', value: '$memberCount 位成员'),
            const SizedBox(height: 18),
            const _SpecimenNotice(),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              color: _oxide,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: const Text(
                '可拖动，也可用上移 / 下移',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProofSheet extends StatelessWidget {
  const _ProofSheet({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: const _ProofPaperPainter(),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 20),
        child: child,
      ),
    );
  }
}

class _SpecimenNotice extends StatelessWidget {
  const _SpecimenNotice();

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(width: 6, height: 42, color: _oxide),
        const SizedBox(width: 10),
        const Expanded(
          child: Text(
            '人物、站点与班次均为教学示例数据',
            style: TextStyle(
              color: _zincLight,
              height: 1.4,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

class _ProofRule extends StatelessWidget {
  const _ProofRule({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: _zincDark)),
      ),
      child: Wrap(
        alignment: WrapAlignment.spaceBetween,
        spacing: 12,
        runSpacing: 4,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: _zinc,
              fontFamily: 'monospace',
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.2,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: _proofPaper,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _ComposingGalley extends StatelessWidget {
  const _ComposingGalley({
    required this.members,
    required this.status,
    required this.onReorder,
    required this.onMove,
  });

  final List<DutyMember> members;
  final String status;
  final ReorderCallback onReorder;
  final void Function(String memberId, int offset) onMove;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: const _ZincGalleyPainter(),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              color: _deepStone,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
              child: Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 16,
                runSpacing: 10,
                children: [
                  const Text(
                    '教学样张 · 东岸社区站 · 白班装版',
                    style: TextStyle(
                      color: _proofPaper,
                      fontFamily: 'serif',
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  Semantics(
                    liveRegion: true,
                    child: Text(
                      status,
                      key: const Key('board-status'),
                      style: const TextStyle(
                        color: _zincLight,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            // #region keyed-reorder-list
            ReorderableListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              buildDefaultDragHandles: false,
              itemCount: members.length,
              onReorderItem: onReorder,
              itemBuilder: (context, index) {
                final member = members[index];
                return _DutySlip(
                  key: ValueKey(member.id),
                  member: member,
                  index: index,
                  isFirst: index == 0,
                  isLast: index == members.length - 1,
                  onMoveUp: () => onMove(member.id, -1),
                  onMoveDown: () => onMove(member.id, 1),
                );
              },
            ),
            // #endregion keyed-reorder-list
          ],
        ),
      ),
    );
  }
}

class _DutySlip extends StatefulWidget {
  const _DutySlip({
    super.key,
    required this.member,
    required this.index,
    required this.isFirst,
    required this.isLast,
    required this.onMoveUp,
    required this.onMoveDown,
  });

  final DutyMember member;
  final int index;
  final bool isFirst;
  final bool isLast;
  final VoidCallback onMoveUp;
  final VoidCallback onMoveDown;

  @override
  State<_DutySlip> createState() => _DutySlipState();
}

class _DutySlipState extends State<_DutySlip> {
  late final TextEditingController _noteController;
  bool _checkedIn = false;

  @override
  void initState() {
    super.initState();
    _noteController = TextEditingController();
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final member = widget.member;

    return Semantics(
      container: true,
      label: '${member.name}，${member.callSign}，第 ${widget.index + 1} 位',
      child: Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: CustomPaint(
          painter: _ZincSlugPainter(checkedIn: _checkedIn),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(10, 10, 10, 12),
            child: CustomPaint(
              painter: const _ProofPaperPainter(),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final isWide = constraints.maxWidth >= 690;
                    final identity = _SlipIdentity(
                      member: member,
                      index: widget.index,
                    );
                    final note = TextField(
                      key: ValueKey('note-${member.id}'),
                      controller: _noteController,
                      maxLines: 2,
                      minLines: 1,
                      style: const TextStyle(color: _ink),
                      decoration: InputDecoration(
                        labelText: '${member.name}的交接备注',
                        hintText: '记录只属于这位成员的内容',
                      ),
                    );
                    final controls = _SlipControls(
                      member: member,
                      index: widget.index,
                      checkedIn: _checkedIn,
                      isFirst: widget.isFirst,
                      isLast: widget.isLast,
                      onCheckedInChanged: (value) {
                        setState(() => _checkedIn = value);
                      },
                      onMoveUp: widget.onMoveUp,
                      onMoveDown: widget.onMoveDown,
                    );

                    if (isWide) {
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(width: 190, child: identity),
                          const SizedBox(width: 16),
                          Expanded(child: note),
                          const SizedBox(width: 12),
                          SizedBox(width: 192, child: controls),
                        ],
                      );
                    }

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        identity,
                        const SizedBox(height: 14),
                        note,
                        const SizedBox(height: 12),
                        controls,
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

class _SlipIdentity extends StatelessWidget {
  const _SlipIdentity({required this.member, required this.index});

  final DutyMember member;
  final int index;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomPaint(
          painter: const _TypeBlockPainter(),
          child: SizedBox(
            width: 46,
            height: 46,
            child: Center(
              child: Text(
                '${index + 1}'.padLeft(2, '0'),
                style: const TextStyle(
                  color: _proofPaper,
                  fontFamily: 'monospace',
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                member.name,
                style: const TextStyle(
                  color: _ink,
                  fontFamily: 'serif',
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  height: 1,
                ),
              ),
              const SizedBox(height: 7),
              Text(
                '${member.callSign} · ${member.window}',
                style: const TextStyle(
                  color: Color(0xFF4C514C),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SlipControls extends StatelessWidget {
  const _SlipControls({
    required this.member,
    required this.index,
    required this.checkedIn,
    required this.isFirst,
    required this.isLast,
    required this.onCheckedInChanged,
    required this.onMoveUp,
    required this.onMoveDown,
  });

  final DutyMember member;
  final int index;
  final bool checkedIn;
  final bool isFirst;
  final bool isLast;
  final ValueChanged<bool> onCheckedInChanged;
  final VoidCallback onMoveUp;
  final VoidCallback onMoveDown;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Checkbox(
              value: checkedIn,
              shape: const RoundedRectangleBorder(),
              activeColor: _oxide,
              onChanged: (value) => onCheckedInChanged(value ?? false),
            ),
            Expanded(
              child: Text(
                checkedIn ? '交接已确认' : '等待交接',
                style: const TextStyle(
                  color: _ink,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            ReorderableDragStartListener(
              index: index,
              child: IconButton(
                key: ValueKey('drag-${member.id}'),
                tooltip: '拖动 ${member.name}',
                color: _ink,
                icon: const Icon(Icons.drag_indicator),
                onPressed: () {},
              ),
            ),
          ],
        ),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                key: ValueKey('move-up-${member.id}'),
                onPressed: isFirst ? null : onMoveUp,
                style: OutlinedButton.styleFrom(foregroundColor: _ink),
                child: const Text('上移'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: FilledButton(
                key: ValueKey('move-down-${member.id}'),
                onPressed: isLast ? null : onMoveDown,
                style: FilledButton.styleFrom(
                  backgroundColor: _proofBlue,
                  foregroundColor: Colors.white,
                ),
                child: const Text('下移'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _StoneSurfacePainter extends CustomPainter {
  const _StoneSurfacePainter();

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = _stone);
    final vein = Paint()
      ..color = const Color(0x18212622)
      ..strokeWidth = 1;
    for (var index = 0; index < 18; index++) {
      final y = (index * 67.0 + 19) % size.height;
      canvas.drawLine(Offset(0, y), Offset(size.width, y + 14), vein);
    }
    final pore = Paint()..color = const Color(0x24202521);
    for (var index = 0; index < 72; index++) {
      final x = (index * 83.0 + 11) % size.width;
      final y = (index * 47.0 + 31) % size.height;
      canvas.drawCircle(Offset(x, y), index.isEven ? 1.2 : 0.7, pore);
    }
  }

  @override
  bool shouldRepaint(covariant _StoneSurfacePainter oldDelegate) => false;
}

class _InkStonePainter extends CustomPainter {
  const _InkStonePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.drawRect(rect, Paint()..color = _deepStone);
    canvas.drawRect(
      Rect.fromLTWH(0, 0, 7, size.height),
      Paint()..color = _oxide,
    );
    canvas.drawLine(
      const Offset(18, 12),
      Offset(size.width - 14, 12),
      Paint()
        ..color = _zincDark
        ..strokeWidth = 1,
    );
    final inkBloom = Paint()
      ..shader =
          const RadialGradient(colors: [Color(0x552C6670), Color(0x00171A18)])
              .createShader(
                Rect.fromCircle(center: Offset(size.width, 0), radius: 170),
              );
    canvas.drawRect(rect, inkBloom);
  }

  @override
  bool shouldRepaint(covariant _InkStonePainter oldDelegate) => false;
}

class _ProofPaperPainter extends CustomPainter {
  const _ProofPaperPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.drawRect(rect, Paint()..color = _proofPaper);
    final fiber = Paint()
      ..color = const Color(0x1A7B715E)
      ..strokeWidth = 0.8;
    for (var index = 0; index < 14; index++) {
      final y = (index * 29.0 + 13) % size.height;
      final start = (index * 17.0) % 30;
      canvas.drawLine(
        Offset(start, y),
        Offset(size.width - ((index * 11.0) % 34), y + 1),
        fiber,
      );
    }
    final mark = Paint()
      ..color = _oxide
      ..strokeWidth = 1.4;
    canvas.drawLine(const Offset(8, 5), const Offset(8, 17), mark);
    canvas.drawLine(const Offset(2, 11), const Offset(14, 11), mark);
  }

  @override
  bool shouldRepaint(covariant _ProofPaperPainter oldDelegate) => false;
}

class _ZincGalleyPainter extends CustomPainter {
  const _ZincGalleyPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final metal = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [_zincLight, _zinc, _zincDark],
        stops: [0, 0.58, 1],
      ).createShader(rect);
    canvas.drawRect(rect, metal);
    final rail = Paint()
      ..color = const Color(0x88767971)
      ..strokeWidth = 2;
    canvas.drawLine(const Offset(7, 0), Offset(7, size.height), rail);
    canvas.drawLine(
      Offset(size.width - 7, 0),
      Offset(size.width - 7, size.height),
      rail,
    );
    final scratch = Paint()
      ..color = const Color(0x44767971)
      ..strokeWidth = 0.7;
    for (var index = 0; index < 18; index++) {
      final y = (index * 43.0 + 22) % size.height;
      canvas.drawLine(Offset(10, y), Offset(size.width - 10, y + 3), scratch);
    }
    _drawFastener(canvas, const Offset(9, 9));
    _drawFastener(canvas, Offset(size.width - 9, 9));
    _drawFastener(canvas, Offset(9, size.height - 9));
    _drawFastener(canvas, Offset(size.width - 9, size.height - 9));
  }

  void _drawFastener(Canvas canvas, Offset center) {
    canvas.drawCircle(center, 4.2, Paint()..color = _zincDark);
    canvas.drawLine(
      center.translate(-2.4, 0),
      center.translate(2.4, 0),
      Paint()
        ..color = _deepStone
        ..strokeWidth = 1,
    );
  }

  @override
  bool shouldRepaint(covariant _ZincGalleyPainter oldDelegate) => false;
}

class _ZincSlugPainter extends CustomPainter {
  const _ZincSlugPainter({required this.checkedIn});

  final bool checkedIn;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final metal = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [_zincLight, _zinc, _zincDark],
      ).createShader(rect);
    canvas.drawRect(rect, metal);
    canvas.drawRect(
      Rect.fromLTWH(0, 0, checkedIn ? 9 : 4, size.height),
      Paint()..color = checkedIn ? _oxide : _zincDark,
    );
    final groove = Paint()
      ..color = const Color(0x66767971)
      ..strokeWidth = 1;
    canvas.drawLine(
      Offset(12, size.height - 5),
      Offset(size.width - 8, size.height - 5),
      groove,
    );
  }

  @override
  bool shouldRepaint(covariant _ZincSlugPainter oldDelegate) {
    return oldDelegate.checkedIn != checkedIn;
  }
}

class _TypeBlockPainter extends CustomPainter {
  const _TypeBlockPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.drawRect(rect, Paint()..color = _ink);
    canvas.drawRect(
      rect.deflate(3),
      Paint()
        ..color = _zincDark
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );
    canvas.drawLine(
      Offset(4, size.height - 5),
      Offset(size.width - 4, size.height - 5),
      Paint()
        ..color = _oxide
        ..strokeWidth = 2,
    );
  }

  @override
  bool shouldRepaint(covariant _TypeBlockPainter oldDelegate) => false;
}
