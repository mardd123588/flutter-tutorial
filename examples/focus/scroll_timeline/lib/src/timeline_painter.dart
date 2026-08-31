import 'package:flutter/material.dart';

import 'timeline_theme.dart';

class TimelineProgressPainter extends CustomPainter {
  TimelineProgressPainter({required this.controller})
    : super(repaint: controller);

  final ScrollController controller;

  @override
  void paint(Canvas canvas, Size size) {
    final compact = size.width < 700;
    final x = compact ? 18.0 : 34.0;
    final top = compact ? 18.0 : 30.0;
    final bottom = size.height - top;
    final track = Paint()
      ..color = archiveRule.withValues(alpha: 0.72)
      ..strokeWidth = 2;
    final progressPaint = Paint()
      ..color = copper
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(Offset(x, top), Offset(x, bottom), track);

    var progress = 0.0;
    if (controller.hasClients && controller.position.maxScrollExtent > 0) {
      progress = (controller.offset / controller.position.maxScrollExtent)
          .clamp(0.0, 1.0);
    }
    final progressEnd = top + (bottom - top) * progress;
    canvas.drawLine(
      Offset(x, top),
      Offset(x, progressEnd.clamp(top, bottom)),
      progressPaint,
    );
    canvas.drawCircle(
      Offset(x, progressEnd.clamp(top, bottom)),
      7,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(TimelineProgressPainter oldDelegate) {
    return oldDelegate.controller != controller;
  }
}
