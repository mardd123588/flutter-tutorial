import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:ticket_layout_studio/src/ticket_layout_studio.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('switches from a standard ticket to a pocket ticket', (
    tester,
  ) async {
    await tester.pumpWidget(const TicketLayoutStudioApp());
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(OutlinedButton, '窄票'));
    await tester.pumpAndSettle();

    final semantics = tester.getSemantics(
      find.byKey(const Key('ticket-preview')),
    );
    expect(semantics.label, contains('窄票'));
    expect(semantics.label, contains('360 mm'));
  });
}
