import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../l10n/app_localizations.dart';
import 'venue_data.dart';
import 'venue_guidebook_app.dart';
import 'venue_localizations.dart';
import 'venue_url_codec.dart';
import 'venues_page.dart';

class GuideRoutesPage extends StatelessWidget {
  const GuideRoutesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    return GuidePageFrame(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          GuideSectionHeader(
            title: strings.routeIndexTitle,
            body: strings.routeIndexBody,
          ),
          const SizedBox(height: 18),
          ...guideRoutes.indexed.map(
            (entry) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _GuideRouteRow(index: entry.$1, route: entry.$2),
            ),
          ),
        ],
      ),
    );
  }
}

class _GuideRouteRow extends StatelessWidget {
  const _GuideRouteRow({required this.index, required this.route});

  final int index;
  final GuideRoute route;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    return Container(
      color: index.isEven ? guidePaperBright : const Color(0xFFE7DFC0),
      padding: const EdgeInsets.all(18),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 720;
          final number = Container(
            width: 58,
            height: 58,
            color: guideChartreuse,
            alignment: Alignment.center,
            child: Text(
              '${index + 1}'.padLeft(2, '0'),
              style: const TextStyle(
                color: guideInk,
                fontFamily: 'monospace',
                fontSize: 20,
                fontWeight: FontWeight.w900,
              ),
            ),
          );
          final details = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                strings.guideRouteTitle(route),
                style: const TextStyle(
                  color: guideInk,
                  fontSize: 27,
                  height: 1.05,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                strings.guideRouteBody(route),
                style: const TextStyle(color: guideMutedInk, height: 1.45),
              ),
              const SizedBox(height: 12),
              Text(
                strings.routeStopCount(route.venueIds.length),
                style: const TextStyle(
                  color: guideCobalt,
                  fontFamily: 'monospace',
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final venueId in route.venueIds)
                    _RouteStop(venue: venueById(venueId)!),
                ],
              ),
            ],
          );
          if (compact) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [number, const SizedBox(height: 14), details],
            );
          }
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              number,
              const SizedBox(width: 18),
              Expanded(child: details),
              const SizedBox(width: 18),
              SizedBox(
                width: 190,
                height: 96,
                child: CustomPaint(painter: _RouteTracePainter(index: index)),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _RouteStop extends StatelessWidget {
  const _RouteStop({required this.venue});

  final Venue venue;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    return OutlinedButton.icon(
      key: ValueKey('route-stop-${venue.id}'),
      onPressed: () => context.go('/venues/${venue.id}'),
      icon: const Icon(Icons.crop_square, size: 16),
      label: Text(strings.venueName(venue)),
    );
  }
}

class _RouteTracePainter extends CustomPainter {
  const _RouteTracePainter({required this.index});

  final int index;

  @override
  void paint(Canvas canvas, Size size) {
    final routePaint = Paint()
      ..color = guideCobalt
      ..style = PaintingStyle.stroke
      ..strokeWidth = 7
      ..strokeCap = StrokeCap.square;
    final markerPaint = Paint()..color = guideChartreuse;
    final path = Path()
      ..moveTo(12, size.height * 0.72)
      ..lineTo(size.width * 0.36, size.height * (0.32 + index * 0.08))
      ..lineTo(size.width * 0.68, size.height * (0.72 - index * 0.1))
      ..lineTo(size.width - 12, size.height * 0.24);
    canvas.drawPath(path, routePaint);
    for (final point in [
      Offset(12, size.height * 0.72),
      Offset(size.width * 0.36, size.height * (0.32 + index * 0.08)),
      Offset(size.width * 0.68, size.height * (0.72 - index * 0.1)),
      Offset(size.width - 12, size.height * 0.24),
    ]) {
      canvas.drawRect(
        Rect.fromCenter(center: point, width: 16, height: 16),
        markerPaint,
      );
    }
  }

  @override
  bool shouldRepaint(_RouteTracePainter oldDelegate) =>
      oldDelegate.index != index;
}

class GuideAboutPage extends StatelessWidget {
  const GuideAboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    return GuidePageFrame(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          GuideSectionHeader(
            title: strings.aboutTitle,
            body: strings.aboutBody,
          ),
          const SizedBox(height: 18),
          LayoutBuilder(
            builder: (context, constraints) {
              final split = constraints.maxWidth >= 760;
              final keyboard = _AboutPanel(
                icon: Icons.keyboard_alt_outlined,
                title: strings.keyboardTitle,
                body: strings.keyboardBody,
              );
              final accessibility = _AboutPanel(
                icon: Icons.accessibility_new,
                title: strings.accessibilityTitle,
                body: strings.accessibilityBody,
              );
              if (!split) {
                return Column(
                  children: [
                    keyboard,
                    const SizedBox(height: 12),
                    accessibility,
                  ],
                );
              }
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: keyboard),
                  const SizedBox(width: 12),
                  Expanded(child: accessibility),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _AboutPanel extends StatelessWidget {
  const _AboutPanel({
    required this.icon,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: guidePaperBright,
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            color: guideChartreuse,
            alignment: Alignment.center,
            child: Icon(icon, size: 28, color: guideInk),
          ),
          const SizedBox(height: 18),
          Text(
            title,
            style: const TextStyle(
              color: guideInk,
              fontSize: 26,
              height: 1.05,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            body,
            style: const TextStyle(color: guideMutedInk, height: 1.55),
          ),
        ],
      ),
    );
  }
}

class VenueLinkErrorPage extends StatelessWidget {
  const VenueLinkErrorPage({required this.result, super.key});

  final InvalidVenueLink result;

  String _message(AppLocalizations strings) => switch (result.issue) {
    VenueLinkIssue.unknownVenue => strings.unknownVenueError(
      result.venueId ?? '',
    ),
    VenueLinkIssue.invalidFloor => strings.invalidFloorError,
    VenueLinkIssue.unavailableFloor => strings.unavailableFloorError(
      result.floor ?? 0,
    ),
    VenueLinkIssue.invalidTag => strings.invalidTagError(result.value ?? ''),
    VenueLinkIssue.duplicateParameter => strings.duplicateParameterError(
      result.parameter ?? '',
    ),
    VenueLinkIssue.unsupportedParameter => strings.unsupportedParameterError(
      result.parameter ?? '',
    ),
    VenueLinkIssue.unmatchedPath => strings.unmatchedBody,
  };

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    return GuidePageFrame(
      child: _ErrorNotice(
        title: strings.linkErrorTitle,
        body: _message(strings),
        actionLabel: strings.repairLink,
        onPressed: () => context.go('/venues'),
      ),
    );
  }
}

class UnmatchedGuidePage extends StatelessWidget {
  const UnmatchedGuidePage({required this.uri, super.key});

  final Uri uri;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    return Scaffold(
      body: GuidePageFrame(
        child: _ErrorNotice(
          title: strings.unmatchedTitle,
          body: '${strings.unmatchedBody}\n${uri.toString()}',
          actionLabel: strings.repairLink,
          onPressed: () => context.go('/venues'),
        ),
      ),
    );
  }
}

class _ErrorNotice extends StatelessWidget {
  const _ErrorNotice({
    required this.title,
    required this.body,
    required this.actionLabel,
    required this.onPressed,
  });

  final String title;
  final String body;
  final String actionLabel;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      liveRegion: true,
      child: Container(
        color: guidePaperBright,
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              color: guideError,
              padding: const EdgeInsets.all(12),
              child: const Icon(Icons.link_off, color: Colors.white, size: 32),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              style: const TextStyle(
                color: guideInk,
                fontSize: 32,
                height: 1.05,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              body,
              style: const TextStyle(color: guideMutedInk, height: 1.55),
            ),
            const SizedBox(height: 20),
            FilledButton(onPressed: onPressed, child: Text(actionLabel)),
          ],
        ),
      ),
    );
  }
}
