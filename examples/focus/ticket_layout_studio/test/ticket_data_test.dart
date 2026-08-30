import 'package:flutter_test/flutter_test.dart';
import 'package:ticket_layout_studio/src/ticket_data.dart';

void main() {
  group('ticketWidthFor', () {
    test('uses the format target when space is available', () {
      expect(
        ticketWidthFor(availableWidth: 900, format: TicketFormat.panoramic),
        680,
      );
    });

    test('never exceeds the incoming width', () {
      expect(
        ticketWidthFor(availableWidth: 318, format: TicketFormat.gate),
        318,
      );
    });
  });

  test('moves the stub below the main area under 430 pixels', () {
    expect(usesStackedStub(429), isTrue);
    expect(usesStackedStub(430), isFalse);
  });
}
