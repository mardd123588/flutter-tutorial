import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'archive_theme.dart';

class ArchiveThumbnailPainter extends CustomPainter {
  const ArchiveThumbnailPainter({
    required this.seed,
    required this.collectionIndex,
  });

  final int seed;
  final int collectionIndex;

  @override
  void paint(Canvas canvas, Size size) {
    final random = math.Random(seed);
    final palette = [
      cyan,
      amber,
      plum,
      inkSoft,
      const Color(0xFF647B59),
      const Color(0xFF9C5A4F),
    ];
    final accent = palette[collectionIndex % palette.length];
    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = const Color(0xFFE8E0D3),
    );
    canvas.drawRect(
      Rect.fromLTWH(
        size.width * .08,
        size.height * .1,
        size.width * .84,
        size.height * .8,
      ),
      Paint()..color = paper,
    );
    final inkPaint = Paint()..color = ink.withValues(alpha: .82);
    for (var index = 0; index < 5; index++) {
      final width = size.width * (.36 + random.nextDouble() * .42);
      canvas.drawRect(
        Rect.fromLTWH(
          size.width * .16,
          size.height * (.2 + index * .12),
          width,
          2,
        ),
        inkPaint,
      );
    }
    canvas.drawRect(
      Rect.fromLTWH(
        size.width * .62,
        size.height * .58,
        size.width * .2,
        size.height * .2,
      ),
      Paint()..color = accent,
    );
  }

  @override
  bool shouldRepaint(ArchiveThumbnailPainter oldDelegate) =>
      oldDelegate.seed != seed ||
      oldDelegate.collectionIndex != collectionIndex;
}
