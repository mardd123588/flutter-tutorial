import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../domain/exchange_models.dart';
import 'exchange_theme.dart';

class ExchangeHeader extends StatelessWidget {
  const ExchangeHeader({super.key, this.showBack = false, this.onBack});

  final bool showBack;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: exchangeInk,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final compact = constraints.maxWidth < 640;
              final identity = Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (showBack)
                    IconButton(
                      tooltip: '返回资源列表',
                      onPressed: onBack,
                      color: exchangePaper,
                      icon: const Icon(Icons.arrow_back),
                    ),
                  const _ExchangeMark(),
                  const SizedBox(width: 12),
                  Flexible(
                    child: Text(
                      '邻里资源交换站',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: exchangePaper,
                        fontFamily: 'Georgia',
                      ),
                    ),
                  ),
                ],
              );
              final actions = Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  TextButton.icon(
                    key: const ValueKey('about-preview'),
                    onPressed: () => context.go('/about'),
                    style: TextButton.styleFrom(foregroundColor: exchangePaper),
                    icon: const Icon(Icons.info_outline),
                    label: const Text('预览边界'),
                  ),
                  FilledButton.icon(
                    key: const ValueKey('publish-listing'),
                    onPressed: () => context.go('/publish'),
                    style: FilledButton.styleFrom(
                      backgroundColor: exchangeRust,
                      foregroundColor: Colors.white,
                    ),
                    icon: const Icon(Icons.add),
                    label: const Text('发布资源'),
                  ),
                ],
              );
              if (compact) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [identity, const SizedBox(height: 10), actions],
                );
              }
              return Row(
                children: [
                  Expanded(child: identity),
                  const SizedBox(width: 18),
                  actions,
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _ExchangeMark extends StatelessWidget {
  const _ExchangeMark();

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '邻里资源交换站标志',
      child: SizedBox(
        width: 38,
        height: 38,
        child: CustomPaint(painter: _ExchangeMarkPainter()),
      ),
    );
  }
}

class _ExchangeMarkPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paperPaint = Paint()..color = exchangePaper;
    final rustPaint = Paint()..color = exchangeRust;
    final greenPaint = Paint()..color = exchangeGreenSoft;
    canvas.drawRect(Rect.fromLTWH(3, 5, 25, 27), paperPaint);
    canvas.drawRect(Rect.fromLTWH(8, 0, 25, 27), greenPaint);
    canvas.drawRect(Rect.fromLTWH(13, 10, 22, 25), rustPaint);
    canvas.drawRect(Rect.fromLTWH(17, 14, 14, 2), paperPaint);
    canvas.drawRect(Rect.fromLTWH(17, 20, 10, 2), paperPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class NoticeCard extends StatelessWidget {
  const NoticeCard({
    super.key,
    required this.listing,
    required this.onOpen,
    this.grid = false,
    this.selected = false,
  });

  final ExchangeListing listing;
  final VoidCallback onOpen;
  final bool grid;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final semanticLabel =
        '${listing.title}，${listing.neighborhood.label}，'
        '${listing.status.label}，剩余 ${listing.remainingQuantity} 份';
    return Semantics(
      button: true,
      selected: selected,
      label: semanticLabel,
      child: Material(
        color: selected ? exchangeGreenSoft : exchangePaper,
        elevation: selected ? 6 : 2,
        shadowColor: exchangeInk.withValues(alpha: 0.24),
        borderRadius: BorderRadius.circular(2),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          key: ValueKey('listing-${listing.id}'),
          onTap: onOpen,
          focusColor: exchangeGold.withValues(alpha: 0.3),
          child: grid ? _gridBody(context) : _listBody(context),
        ),
      ),
    );
  }

  Widget _listBody(BuildContext context) {
    if (MediaQuery.sizeOf(context).width < 420) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _NoticeBody(listing: listing),
          SizedBox(
            height: 62,
            child: CustomPaint(
              foregroundPainter: const _PerforationPainter(vertical: false),
              child: _ClaimSlip(listing: listing, horizontal: true),
            ),
          ),
        ],
      );
    }
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(child: _NoticeBody(listing: listing)),
          SizedBox(
            width: 104,
            child: CustomPaint(
              foregroundPainter: _PerforationPainter(vertical: true),
              child: _ClaimSlip(listing: listing),
            ),
          ),
        ],
      ),
    );
  }

  Widget _gridBody(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(child: _NoticeBody(listing: listing, dense: true)),
        SizedBox(
          height: 74,
          child: CustomPaint(
            foregroundPainter: _PerforationPainter(vertical: false),
            child: _ClaimSlip(listing: listing, horizontal: true),
          ),
        ),
      ],
    );
  }
}

class _NoticeBody extends StatelessWidget {
  const _NoticeBody({required this.listing, this.dense = false});

  final ExchangeListing listing;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    final largeText = MediaQuery.textScalerOf(context).scale(1) > 1.5;
    return Padding(
      padding: EdgeInsets.all(
        dense
            ? 14
            : largeText
            ? 16
            : 18,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: dense ? MainAxisSize.max : MainAxisSize.min,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              StatusLabel(listing.status),
              if (listing.origin == ListingOrigin.local)
                const _MiniLabel(label: '仅此浏览器', color: exchangeBlue),
              _MiniLabel(label: listing.category.label, color: exchangeInkSoft),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            listing.title,
            maxLines: dense ? 2 : 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            listing.description,
            maxLines: dense ? 3 : 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodyMedium
                ?.copyWith(color: exchangeInkSoft),
          ),
          if (dense) const Spacer() else SizedBox(height: largeText ? 10 : 14),
          Text(
            '${listing.neighborhood.label} · ${listing.availableWindow.label}',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.labelLarge
                ?.copyWith(color: exchangeInk),
          ),
        ],
      ),
    );
  }
}

class _ClaimSlip extends StatelessWidget {
  const _ClaimSlip({required this.listing, this.horizontal = false});

  final ExchangeListing listing;
  final bool horizontal;

  @override
  Widget build(BuildContext context) {
    final claimed = listing.claimedByCurrentUser;
    final background = claimed
        ? exchangeGold
        : listing.status == ExchangeStatus.available
        ? exchangeGreen
        : exchangePaperMuted;
    final foreground = background == exchangePaperMuted
        ? exchangeInk
        : Colors.white;
    final contents = [
      Icon(
        claimed ? Icons.check_circle : Icons.local_offer_outlined,
        color: foreground,
        size: 22,
      ),
      const SizedBox(width: 8, height: 8),
      Flexible(
        child: Text(
          claimed
              ? '我已认领'
              : listing.status == ExchangeStatus.available
              ? '余 ${listing.remainingQuantity} 份'
              : listing.status.label,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.labelLarge
              ?.copyWith(color: foreground),
        ),
      ),
    ];
    return ColoredBox(
      color: background,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: horizontal
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: contents,
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: contents,
              ),
      ),
    );
  }
}

class _PerforationPainter extends CustomPainter {
  const _PerforationPainter({required this.vertical});

  final bool vertical;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = exchangeRule
      ..strokeWidth = 1.2;
    const dash = 5.0;
    const gap = 5.0;
    final extent = vertical ? size.height : size.width;
    for (var offset = 0.0; offset < extent; offset += dash + gap) {
      if (vertical) {
        canvas.drawLine(Offset(0, offset), Offset(0, offset + dash), paint);
      } else {
        canvas.drawLine(Offset(offset, 0), Offset(offset + dash, 0), paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _PerforationPainter oldDelegate) {
    return oldDelegate.vertical != vertical;
  }
}

class StatusLabel extends StatelessWidget {
  const StatusLabel(this.status, {super.key});

  final ExchangeStatus status;

  @override
  Widget build(BuildContext context) {
    final color = switch (status) {
      ExchangeStatus.available => exchangeGreen,
      ExchangeStatus.reserved => exchangeRust,
      ExchangeStatus.completed => exchangeRule,
    };
    return _MiniLabel(label: status.label, color: color);
  }
}

class _MiniLabel extends StatelessWidget {
  const _MiniLabel({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelSmall
              ?.copyWith(color: Colors.white, fontWeight: FontWeight.w800),
        ),
      ),
    );
  }
}

class ExchangeStatePanel extends StatelessWidget {
  const ExchangeStatePanel({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.action,
    this.actionLabel,
    this.panelKey,
  });

  final IconData icon;
  final String title;
  final String message;
  final VoidCallback? action;
  final String? actionLabel;
  final Key? panelKey;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: Padding(
          key: panelKey,
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 42, color: exchangeRust),
              const SizedBox(height: 16),
              Text(title, style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 10),
              Text(message, textAlign: TextAlign.center),
              if (action != null && actionLabel != null) ...[
                const SizedBox(height: 20),
                FilledButton(onPressed: action, child: Text(actionLabel!)),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class DetailFact extends StatelessWidget {
  const DetailFact({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: exchangeGreen),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: Theme.of(context).textTheme.labelLarge),
              const SizedBox(height: 2),
              Text(value),
            ],
          ),
        ),
      ],
    );
  }
}
