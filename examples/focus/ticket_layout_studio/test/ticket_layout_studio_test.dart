import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ticket_layout_studio/src/ticket_layout_studio.dart';

void main() {
  testWidgets('changes the preview format', (tester) async {
    await tester.pumpWidget(const TicketLayoutStudioApp());

    await tester.tap(find.widgetWithText(OutlinedButton, '宽票'));
    await tester.pump();

    final semantics = tester.getSemantics(
      find.byKey(const Key('ticket-preview')),
    );
    expect(semantics.label, contains('宽票'));
    expect(semantics.label, contains('680 mm'));
  });

  // #region narrow-layout-test
  testWidgets('fits a 320 by 720 viewport at 200 percent text scale', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 720);
    tester.view.devicePixelRatio = 1;
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(tester.view.reset);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

    await tester.pumpWidget(const TicketLayoutStudioApp());
    await tester.pumpAndSettle();

    expect(find.text('票券排版器'), findsOneWidget);
    expect(find.text('B—17'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
  // #endregion narrow-layout-test

  // #region golden-test
  testWidgets('renders the standard ticket consistently', (tester) async {
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const TicketLayoutStudioApp());
    await tester.pumpAndSettle();

    await expectLater(
      find.byType(TicketLayoutStudioPage),
      matchesGoldenFile('goldens/ticket-layout-studio.png'),
    );
  });
  // #endregion golden-test
}
