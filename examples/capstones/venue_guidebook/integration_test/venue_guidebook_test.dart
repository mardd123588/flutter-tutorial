import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:venue_guidebook/src/venue_guide_controller.dart';
import 'package:venue_guidebook/src/venue_guidebook_app.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'finds a place, opens its deep link, and keeps it on locale change',
    (tester) async {
      final controller = VenueGuideController();
      final router = createVenueGuideRouter(controller: controller);
      addTearDown(router.dispose);
      addTearDown(controller.dispose);
      await tester.pumpWidget(
        VenueGuidebookApp(controller: controller, router: router),
      );
      await tester.pumpAndSettle();

      await tester.sendKeyEvent(LogicalKeyboardKey.slash);
      await tester.pump();
      await tester.enterText(
        find.byKey(const ValueKey('venue-search-field')),
        '中庭',
      );
      await tester.pump();

      await tester.tap(find.byKey(const ValueKey('open-venue-atrium')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('detail-floor-2')));
      await tester.pumpAndSettle();
      expect(
        router.routeInformationProvider.value.uri.toString(),
        '/venues/atrium?floor=2',
      );

      await tester.tap(find.byKey(const ValueKey('locale-toggle')));
      await tester.pumpAndSettle();
      expect(find.text('Central Atrium'), findsOneWidget);
      expect(
        router.routeInformationProvider.value.uri.toString(),
        '/venues/atrium?floor=2',
      );
    },
  );
}
