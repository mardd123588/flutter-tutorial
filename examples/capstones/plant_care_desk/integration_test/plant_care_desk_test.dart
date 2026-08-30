import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:plant_care_desk/src/plant_care_desk.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('records filtered care and restores the previous record', (
    tester,
  ) async {
    await tester.pumpWidget(const PlantCareDeskApp());
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('filter-needsCare')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('water-ficus-lyrata')));
    await tester.pumpAndSettle();

    expect(find.text('琴叶榕'), findsNothing);
    expect(find.textContaining('琴叶榕已浇水：24% → 66%'), findsOneWidget);

    await tester.tap(find.byKey(const Key('undo-care')));
    await tester.pumpAndSettle();

    expect(find.text('琴叶榕'), findsOneWidget);
    expect(find.textContaining('已撤销：琴叶榕恢复到 24%'), findsOneWidget);
  });
}
