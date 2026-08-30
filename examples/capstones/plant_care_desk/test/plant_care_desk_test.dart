import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plant_care_desk/src/plant_care_desk.dart';
import 'package:plant_care_desk/src/plant_data.dart';

void main() {
  testWidgets('filters, records care, and restores it with undo', (
    tester,
  ) async {
    await tester.pumpWidget(const PlantCareDeskApp());
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('filter-needsCare')));
    await tester.pumpAndSettle();
    expect(find.text('琴叶榕'), findsOneWidget);
    expect(find.text('直立迷迭香'), findsNothing);

    await tester.tap(find.byKey(const ValueKey('water-ficus-lyrata')));
    await tester.pumpAndSettle();
    expect(find.text('琴叶榕'), findsNothing);
    expect(find.textContaining('琴叶榕已浇水：24% → 66%'), findsOneWidget);

    await tester.ensureVisible(find.byKey(const Key('undo-care')));
    await tester.tap(find.byKey(const Key('undo-care')));
    await tester.pumpAndSettle();
    expect(find.text('琴叶榕'), findsOneWidget);
    expect(find.textContaining('已撤销：琴叶榕恢复到 24%'), findsOneWidget);
  });

  // #region keyed-state-test
  testWidgets('keeps expanded state with the same plant after reordering', (
    tester,
  ) async {
    await tester.pumpWidget(const PlantCareDeskApp());
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('expand-ficus-lyrata')));
    await tester.pump();
    expect(
      find.byKey(const ValueKey('observation-ficus-lyrata')),
      findsOneWidget,
    );

    await tester.tap(find.byKey(const ValueKey('water-ficus-lyrata')));
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey('observation-ficus-lyrata')),
      findsOneWidget,
    );
    expect(find.byKey(const ValueKey('observation-asplenium')), findsNothing);
  });
  // #endregion keyed-state-test

  // #region animation-test
  testWidgets('implicit gauge visits start, middle, and end values', (
    tester,
  ) async {
    final controller = PlantCareController();
    await tester.pumpWidget(PlantCareDeskApp(controller: controller));
    await tester.pumpAndSettle();

    controller.waterPlant('ficus-lyrata');
    await tester.pump();
    expect(_fillFactor(tester, 'ficus-lyrata'), closeTo(0.24, 0.01));

    await tester.pump(const Duration(milliseconds: 240));
    final middle = _fillFactor(tester, 'ficus-lyrata');
    expect(middle, greaterThan(0.24));
    expect(middle, lessThan(0.66));

    await tester.pumpAndSettle();
    expect(_fillFactor(tester, 'ficus-lyrata'), closeTo(0.66, 0.01));
    controller.dispose();
  });

  testWidgets('explicit receipt restarts then reaches full opacity', (
    tester,
  ) async {
    final controller = PlantCareController();
    await tester.pumpWidget(PlantCareDeskApp(controller: controller));
    await tester.pumpAndSettle();

    controller.waterPlant('ficus-lyrata');
    await tester.pump();
    expect(_receiptOpacity(tester), 0);

    await tester.pump(const Duration(milliseconds: 180));
    expect(_receiptOpacity(tester), inExclusiveRange(0, 1));

    await tester.pumpAndSettle();
    expect(_receiptOpacity(tester), 1);
    controller.dispose();
  });
  // #endregion animation-test

  // #region reduced-motion-test
  testWidgets('reduced motion renders final states immediately', (
    tester,
  ) async {
    final controller = PlantCareController();
    tester.platformDispatcher.accessibilityFeaturesTestValue =
        const FakeAccessibilityFeatures(disableAnimations: true);
    addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);
    await tester.pumpWidget(PlantCareDeskApp(controller: controller));
    await tester.pumpAndSettle();

    controller.waterPlant('ficus-lyrata');
    await tester.pump();

    expect(find.byKey(const Key('receipt-fade')), findsNothing);
    expect(_fillFactor(tester, 'ficus-lyrata'), closeTo(0.66, 0.01));
    controller.dispose();
  });
  // #endregion reduced-motion-test

  testWidgets('exposes plant state and the operation receipt to semantics', (
    tester,
  ) async {
    final semanticsHandle = tester.ensureSemantics();
    await tester.pumpWidget(const PlantCareDeskApp());
    await tester.pumpAndSettle();

    final plant = tester.getSemantics(
      find.byWidgetPredicate(
        (widget) =>
            widget is Semantics &&
            widget.properties.label == '琴叶榕，东窗 02，湿度 24%，目标 45%',
      ),
    );
    final receipt = tester.getSemantics(
      find.byWidgetPredicate(
        (widget) => widget is Semantics && widget.properties.liveRegion == true,
      ),
    );

    expect(plant.label, contains('琴叶榕'));
    expect(receipt.flagsCollection.isLiveRegion, isTrue);
    semanticsHandle.dispose();
  });

  testWidgets('fits a 320 by 720 viewport at 200 percent text scale', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 720);
    tester.view.devicePixelRatio = 1;
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(tester.view.reset);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

    await tester.pumpWidget(const PlantCareDeskApp());
    await tester.pumpAndSettle();

    expect(find.text('植物照护台'), findsOneWidget);
    expect(find.text('琴叶榕'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

double _fillFactor(WidgetTester tester, String plantId) {
  return tester
      .widget<FractionallySizedBox>(
        find.byKey(ValueKey('moisture-fill-$plantId')),
      )
      .widthFactor!;
}

double _receiptOpacity(WidgetTester tester) {
  return tester
      .widget<FadeTransition>(find.byKey(const Key('receipt-fade')))
      .opacity
      .value;
}
