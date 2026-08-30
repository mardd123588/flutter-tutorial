enum TicketFormat { pocket, gate, panoramic }

extension TicketFormatLabel on TicketFormat {
  String get label => switch (this) {
    TicketFormat.pocket => '窄票',
    TicketFormat.gate => '标准票',
    TicketFormat.panoramic => '宽票',
  };

  String get measurement => switch (this) {
    TicketFormat.pocket => '360 mm',
    TicketFormat.gate => '520 mm',
    TicketFormat.panoramic => '680 mm',
  };
}

class TicketMetrics {
  const TicketMetrics({
    required this.targetWidth,
    required this.horizontalPadding,
    required this.stubWidth,
  });

  final double targetWidth;
  final double horizontalPadding;
  final double stubWidth;
}

TicketMetrics metricsFor(TicketFormat format) => switch (format) {
  TicketFormat.pocket => const TicketMetrics(
    targetWidth: 360,
    horizontalPadding: 20,
    stubWidth: 112,
  ),
  TicketFormat.gate => const TicketMetrics(
    targetWidth: 520,
    horizontalPadding: 24,
    stubWidth: 124,
  ),
  TicketFormat.panoramic => const TicketMetrics(
    targetWidth: 680,
    horizontalPadding: 28,
    stubWidth: 136,
  ),
};

// #region constraint-policy
double ticketWidthFor({
  required double availableWidth,
  required TicketFormat format,
}) {
  if (availableWidth <= 0) return 0;
  return metricsFor(format).targetWidth.clamp(0, availableWidth).toDouble();
}

bool usesStackedStub(double ticketWidth) => ticketWidth < 430;
// #endregion constraint-policy
