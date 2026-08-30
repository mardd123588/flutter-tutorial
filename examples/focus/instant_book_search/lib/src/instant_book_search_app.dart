import 'dart:async';

import 'package:flutter/material.dart';

import 'book.dart';
import 'book_search_controller.dart';
import 'book_search_service.dart';

const _paper = Color(0xFFF2EBDD);
const _paperBright = Color(0xFFFFFBF2);
const _ink = Color(0xFF1C211F);
const _quietInk = Color(0xFF4F5753);
const _proofRed = Color(0xFFB9362B);
const _pencilBlue = Color(0xFF285C7C);
const _signalGold = Color(0xFFD6A739);
const _rule = Color(0xFFB9B1A3);

class InstantBookSearchApp extends StatelessWidget {
  const InstantBookSearchApp({
    required this.service,
    this.debounceDuration = const Duration(milliseconds: 320),
    super.key,
  });

  final BookSearchService service;
  final Duration debounceDuration;

  @override
  Widget build(BuildContext context) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: _proofRed,
      brightness: Brightness.light,
      surface: _paper,
    );
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: '即时书目检索',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: colorScheme,
        scaffoldBackgroundColor: _ink,
        textSelectionTheme: const TextSelectionThemeData(
          cursorColor: _proofRed,
          selectionColor: Color(0x55D6A739),
          selectionHandleColor: _proofRed,
        ),
        focusColor: _signalGold,
      ),
      home: BookSearchDesk(
        service: service,
        debounceDuration: debounceDuration,
      ),
    );
  }
}

class BookSearchDesk extends StatefulWidget {
  const BookSearchDesk({
    required this.service,
    required this.debounceDuration,
    super.key,
  });

  final BookSearchService service;
  final Duration debounceDuration;

  @override
  State<BookSearchDesk> createState() => _BookSearchDeskState();
}

class _BookSearchDeskState extends State<BookSearchDesk> {
  late final TextEditingController _textController;
  late final BookSearchController _searchController;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController();
    _searchController = BookSearchController(
      service: widget.service,
      debounceDuration: widget.debounceDuration,
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _runRaceDemo() async {
    _textController.text = '星';
    _textController.selection = TextSelection.collapsed(
      offset: _textController.text.length,
    );
    _searchController.updateQuery('星');
    await Future<void>.delayed(
      widget.debounceDuration + const Duration(milliseconds: 80),
    );
    if (!mounted) return;
    _textController.text = '河';
    _textController.selection = TextSelection.collapsed(
      offset: _textController.text.length,
    );
    _searchController.updateQuery('河');
  }

  void _useQuery(String query) {
    _textController.text = query;
    _textController.selection = TextSelection.collapsed(offset: query.length);
    _searchController.updateQuery(query);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: AnimatedBuilder(
          animation: _searchController,
          builder: (context, child) {
            return CustomPaint(
              painter: const _ProofGridPainter(),
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(18, 18, 18, 36),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1240),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _DeskHeader(controller: _searchController),
                        const SizedBox(height: 18),
                        _SearchComposer(
                          textController: _textController,
                          controller: _searchController,
                          onRaceDemo: _runRaceDemo,
                          onUseQuery: _useQuery,
                        ),
                        const SizedBox(height: 18),
                        LayoutBuilder(
                          builder: (context, constraints) {
                            final wide = constraints.maxWidth >= 900;
                            final proof = _ResultProof(
                              controller: _searchController,
                            );
                            final register = _RequestRegister(
                              controller: _searchController,
                            );
                            if (!wide) {
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  proof,
                                  const SizedBox(height: 18),
                                  register,
                                ],
                              );
                            }
                            return Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(flex: 7, child: proof),
                                const SizedBox(width: 18),
                                Expanded(flex: 3, child: register),
                              ],
                            );
                          },
                        ),
                      ],
                    ),
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

class _DeskHeader extends StatelessWidget {
  const _DeskHeader({required this.controller});

  final BookSearchController controller;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: _proofRed,
        boxShadow: [
          BoxShadow(
            color: Color(0x66000000),
            offset: Offset(0, 10),
            blurRadius: 24,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
        child: Wrap(
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.end,
          spacing: 24,
          runSpacing: 18,
          children: [
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '即时书目检索',
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      color: _paperBright,
                      fontFamily: 'serif',
                      fontWeight: FontWeight.w900,
                      height: 0.98,
                      letterSpacing: -1.2,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    '像校对请求一样给每次检索编号。慢响应可以晚到，但不能改写新查询。',
                    style: TextStyle(
                      color: _paperBright,
                      fontSize: 16,
                      height: 1.45,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            _RequestStamp(
              label: 'ACTIVE REQUEST',
              value: controller.activeRequest == 0
                  ? '—'
                  : '#${controller.activeRequest.toString().padLeft(2, '0')}',
              dark: true,
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchComposer extends StatelessWidget {
  const _SearchComposer({
    required this.textController,
    required this.controller,
    required this.onRaceDemo,
    required this.onUseQuery,
  });

  final TextEditingController textController;
  final BookSearchController controller;
  final Future<void> Function() onRaceDemo;
  final ValueChanged<String> onUseQuery;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(color: _paper),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              key: const ValueKey('search-field'),
              controller: textController,
              onChanged: controller.updateQuery,
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                labelText: '书名、作者或主题',
                hintText: '输入“河”；输入“断线”可测试失败与重试',
                labelStyle: const TextStyle(color: _quietInk),
                hintStyle: const TextStyle(color: Color(0xFF676D69)),
                filled: true,
                fillColor: _paperBright,
                prefixIcon: const Icon(Icons.search, color: _pencilBlue),
                suffixIcon: textController.text.isEmpty
                    ? null
                    : IconButton(
                        tooltip: '清空查询',
                        onPressed: () {
                          textController.clear();
                          controller.updateQuery('');
                        },
                        icon: const Icon(Icons.close),
                      ),
                enabledBorder: const OutlineInputBorder(
                  borderRadius: BorderRadius.zero,
                  borderSide: BorderSide(color: _ink),
                ),
                focusedBorder: const OutlineInputBorder(
                  borderRadius: BorderRadius.zero,
                  borderSide: BorderSide(color: _proofRed, width: 3),
                ),
              ),
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                FilledButton.icon(
                  key: const ValueKey('race-demo'),
                  onPressed: onRaceDemo,
                  style: FilledButton.styleFrom(
                    backgroundColor: _ink,
                    foregroundColor: _paperBright,
                    shape: const RoundedRectangleBorder(),
                    minimumSize: const Size(0, 48),
                  ),
                  icon: const Icon(Icons.swap_horiz),
                  label: const Text('运行竞态演示'),
                ),
                _QueryShortcut(label: '空结果', onTap: () => onUseQuery('无结果')),
                _QueryShortcut(label: '失败后重试', onTap: () => onUseQuery('断线')),
                const Text(
                  '教学 fixture：星 850ms · 河 120ms',
                  style: TextStyle(
                    color: _quietInk,
                    fontFamily: 'monospace',
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _QueryShortcut extends StatelessWidget {
  const _QueryShortcut({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        foregroundColor: _ink,
        side: const BorderSide(color: _ink),
        shape: const RoundedRectangleBorder(),
        minimumSize: const Size(0, 48),
      ),
      child: Text(label),
    );
  }
}

class _ResultProof extends StatelessWidget {
  const _ResultProof({required this.controller});

  final BookSearchController controller;

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: _paperBright,
        boxShadow: [
          BoxShadow(
            color: Color(0x44000000),
            offset: Offset(0, 12),
            blurRadius: 30,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 26),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                const Expanded(
                  child: Text(
                    '检索校样',
                    style: TextStyle(
                      color: _ink,
                      fontFamily: 'serif',
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                Text(
                  controller.results.isEmpty
                      ? 'NO. —'
                      : '${controller.results.length} 条',
                  style: const TextStyle(
                    color: _pencilBlue,
                    fontFamily: 'monospace',
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
            const Divider(color: _ink, height: 24),
            Semantics(
              liveRegion: true,
              label: _statusText(controller),
              child: AnimatedSwitcher(
                duration: reduceMotion
                    ? Duration.zero
                    : const Duration(milliseconds: 240),
                switchInCurve: Curves.easeOutCubic,
                child: _ResultBody(
                  key: ValueKey(
                    '${controller.phase}-${controller.settledQuery}-${controller.activeRequest}',
                  ),
                  controller: controller,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ResultBody extends StatelessWidget {
  const _ResultBody({required this.controller, super.key});

  final BookSearchController controller;

  @override
  Widget build(BuildContext context) {
    if (controller.phase == BookSearchPhase.idle) {
      return const _ProofMessage(
        mark: '待校',
        title: '先写一个查询',
        body: '结果区会同时展示加载、空数据、成功、失败和保留旧结果。',
      );
    }

    if (controller.phase == BookSearchPhase.failure) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _ProofMessage(
            mark: '退回',
            title: controller.errorMessage ?? '检索失败',
            body: controller.results.isEmpty
                ? '当前没有可保留的旧结果。'
                : '旧结果仍在下方，错误不会把它们清空。',
          ),
          const SizedBox(height: 14),
          Align(
            alignment: Alignment.centerLeft,
            child: FilledButton(
              key: const ValueKey('retry-search'),
              onPressed: controller.retry,
              style: FilledButton.styleFrom(
                backgroundColor: _proofRed,
                foregroundColor: _paperBright,
                shape: const RoundedRectangleBorder(),
                minimumSize: const Size(120, 48),
              ),
              child: const Text('重试当前查询'),
            ),
          ),
          if (controller.results.isNotEmpty) ...[
            const SizedBox(height: 18),
            ...controller.results.map(_BookProofRow.new),
          ],
        ],
      );
    }

    if (controller.phase == BookSearchPhase.empty) {
      return _ProofMessage(
        mark: '空白',
        title: '没有匹配“${controller.settledQuery}”的书目',
        body: '空结果是一次成功响应，不要把它写成网络错误。',
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (controller.phase == BookSearchPhase.loading)
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Row(
              children: [
                const SizedBox.square(
                  dimension: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    color: _proofRed,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    controller.keepsPreviousResults
                        ? '正在检索“${controller.query}”，先保留“${controller.settledQuery}”的结果。'
                        : '正在检索“${controller.query}”…',
                    style: const TextStyle(
                      color: _quietInk,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        if (controller.results.isEmpty)
          const _ProofMessage(
            mark: '在途',
            title: '请求已经发出',
            body: '防抖结束后才会分配请求编号。',
          )
        else
          ...controller.results.map(_BookProofRow.new),
      ],
    );
  }
}

class _BookProofRow extends StatelessWidget {
  const _BookProofRow(this.book);

  final Book book;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: ValueKey('result-book-${book.id}'),
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: _paper,
        border: Border.fromBorderSide(BorderSide(color: _rule)),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final narrow = constraints.maxWidth < 520;
          final metadata = _BookMetadata(book: book);
          final details = Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  book.title,
                  style: const TextStyle(
                    color: _ink,
                    fontFamily: 'serif',
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  book.note,
                  style: const TextStyle(
                    color: _quietInk,
                    fontSize: 15,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          );
          if (narrow) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [details, const SizedBox(height: 14), metadata],
            );
          }
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [details, const SizedBox(width: 20), metadata],
          );
        },
      ),
    );
  }
}

class _BookMetadata extends StatelessWidget {
  const _BookMetadata({required this.book});

  final Book book;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 138),
      padding: const EdgeInsets.all(10),
      color: _pencilBlue,
      child: Text(
        '${book.author}\n${book.year}\n架位 ${book.shelf}',
        style: const TextStyle(
          color: _paperBright,
          fontFamily: 'monospace',
          fontWeight: FontWeight.w800,
          height: 1.5,
        ),
      ),
    );
  }
}

class _ProofMessage extends StatelessWidget {
  const _ProofMessage({
    required this.mark,
    required this.title,
    required this.body,
  });

  final String mark;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: const BoxDecoration(
        color: _paper,
        border: Border.fromBorderSide(BorderSide(color: _rule)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Transform.rotate(
            angle: -0.035,
            alignment: Alignment.centerLeft,
            child: DecoratedBox(
              decoration: BoxDecoration(border: Border.all(color: _proofRed)),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                child: Text(
                  mark,
                  style: const TextStyle(
                    color: _proofRed,
                    fontFamily: 'monospace',
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            title,
            style: const TextStyle(
              color: _ink,
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),
          Text(body, style: const TextStyle(color: _quietInk, height: 1.45)),
        ],
      ),
    );
  }
}

class _RequestRegister extends StatelessWidget {
  const _RequestRegister({required this.controller});

  final BookSearchController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const ValueKey('request-status'),
      color: _pencilBlue,
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            '请求登记簿',
            style: TextStyle(
              color: _paperBright,
              fontFamily: 'serif',
              fontSize: 26,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            '每次真正发出的请求都有编号。只接纳当前编号的响应。',
            style: TextStyle(color: _paperBright, height: 1.45),
          ),
          const SizedBox(height: 18),
          _RegisterLine(
            label: '当前查询',
            value: controller.query.isEmpty ? '—' : controller.query,
          ),
          _RegisterLine(
            label: '已结算查询',
            value: controller.settledQuery.isEmpty
                ? '—'
                : controller.settledQuery,
          ),
          _RegisterLine(
            label: '忽略的旧响应',
            value: '${controller.ignoredResponseCount}',
            highlight: controller.ignoredResponseCount > 0,
          ),
          const SizedBox(height: 18),
          _RequestStamp(label: 'STATE', value: _phaseLabel(controller.phase)),
          const SizedBox(height: 18),
          const Divider(color: _paperBright),
          const SizedBox(height: 10),
          const Text(
            '固定书目与延迟都是教学示例。这个项目不会访问真实图书服务。',
            style: TextStyle(
              color: Color(0xFFE4EDF2),
              fontSize: 13,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}

class _RegisterLine extends StatelessWidget {
  const _RegisterLine({
    required this.label,
    required this.value,
    this.highlight = false,
  });

  final String label;
  final String value;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(color: Color(0xFFD9E5EB)),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            value,
            style: TextStyle(
              color: _paperBright,
              fontFamily: 'monospace',
              fontWeight: FontWeight.w900,
              fontSize: 17,
              decoration: highlight ? TextDecoration.underline : null,
              decorationColor: _signalGold,
              decorationThickness: 2,
            ),
          ),
        ],
      ),
    );
  }
}

class _RequestStamp extends StatelessWidget {
  const _RequestStamp({
    required this.label,
    required this.value,
    this.dark = false,
  });

  final String label;
  final String value;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    final borderColor = dark ? _paperBright : _signalGold;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(border: Border.all(color: borderColor)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: _paperBright,
              fontFamily: 'monospace',
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: _paperBright,
              fontFamily: 'monospace',
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProofGridPainter extends CustomPainter {
  const _ProofGridPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF313735)
      ..strokeWidth = 1;
    const gap = 48.0;
    for (var x = 0.0; x < size.width; x += gap) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (var y = 0.0; y < size.height; y += gap) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

String _phaseLabel(BookSearchPhase phase) => switch (phase) {
  BookSearchPhase.idle => 'WAITING',
  BookSearchPhase.loading => 'IN FLIGHT',
  BookSearchPhase.success => 'ACCEPTED',
  BookSearchPhase.empty => 'EMPTY',
  BookSearchPhase.failure => 'RETURNED',
};

String _statusText(BookSearchController controller) =>
    switch (controller.phase) {
      BookSearchPhase.idle => '等待输入查询',
      BookSearchPhase.loading =>
        controller.keepsPreviousResults
            ? '正在检索 ${controller.query}，保留旧结果'
            : '正在检索 ${controller.query}',
      BookSearchPhase.success =>
        '${controller.settledQuery} 返回 ${controller.results.length} 条结果',
      BookSearchPhase.empty => '${controller.settledQuery} 没有结果',
      BookSearchPhase.failure => controller.errorMessage ?? '检索失败',
    };
