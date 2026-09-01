import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:venue_guidebook/src/venue_guide_controller.dart';
import 'package:venue_guidebook/src/venue_guidebook_app.dart';

void main() {
  testWidgets('uses a drawer on narrow screens and a rail on wide screens', (
    tester,
  ) async {
    await _setSurface(tester, const Size(320, 720));
    final narrow = await _pumpGuide(tester);

    expect(find.byKey(const ValueKey('wide-navigation-rail')), findsNothing);
    await tester.tap(find.byKey(const ValueKey('open-navigation')));
    await tester.pumpAndSettle();
    expect(
      find.byKey(const ValueKey('compact-navigation-drawer')),
      findsOneWidget,
    );

    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();
    final scaffold = tester.state<ScaffoldState>(find.byType(Scaffold).first);
    expect(scaffold.isDrawerOpen, isFalse);
    narrow.dispose();

    await _setSurface(tester, const Size(1440, 900));
    final wide = await _pumpGuide(tester);
    expect(find.byKey(const ValueKey('wide-navigation-rail')), findsOneWidget);
    expect(find.byKey(const ValueKey('open-navigation')), findsNothing);
    wide.dispose();
  });

  testWidgets('restores a place deep link and writes query changes', (
    tester,
  ) async {
    final harness = await _pumpGuide(
      tester,
      initialLocation: '/venues/atrium?floor=2',
    );

    expect(find.text('中央中庭'), findsOneWidget);
    expect(find.byKey(const ValueKey('floor-plan-2')), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('detail-tag-accessible')));
    await tester.pumpAndSettle();
    expect(
      harness.router.routeInformationProvider.value.uri.toString(),
      '/venues/atrium?floor=2&tag=accessible',
    );

    await tester.tap(find.byKey(const ValueKey('detail-floor-1')));
    await tester.pumpAndSettle();
    expect(
      harness.router.routeInformationProvider.value.uri.toString(),
      '/venues/atrium?tag=accessible',
    );
    harness.dispose();
  });

  // #region locale-preserves-task-test
  testWidgets('switches locale without changing URL, query, text, or focus', (
    tester,
  ) async {
    final harness = await _pumpGuide(tester);

    await tester.sendKeyEvent(LogicalKeyboardKey.slash);
    await tester.pump();
    final search = tester.widget<TextField>(
      find.byKey(const ValueKey('venue-search-field')),
    );
    expect(search.focusNode?.hasFocus, isTrue);

    await tester.enterText(
      find.byKey(const ValueKey('venue-search-field')),
      '材料',
    );
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey('locale-toggle')));
    await tester.pumpAndSettle();

    expect(
      harness.router.routeInformationProvider.value.uri.toString(),
      '/venues',
    );
    expect(find.text('Materials Hall'), findsOneWidget);
    expect(
      tester
          .widget<TextField>(find.byKey(const ValueKey('venue-search-field')))
          .controller
          ?.text,
      '材料',
    );
    expect(search.focusNode?.hasFocus, isTrue);
    harness.dispose();
  });
  // #endregion locale-preserves-task-test

  testWidgets('slash opens search from another shell destination', (
    tester,
  ) async {
    final harness = await _pumpGuide(tester, initialLocation: '/about');

    await tester.sendKeyEvent(LogicalKeyboardKey.slash);
    await tester.pumpAndSettle();

    expect(harness.router.routeInformationProvider.value.uri.path, '/venues');
    final search = tester.widget<TextField>(
      find.byKey(const ValueKey('venue-search-field')),
    );
    expect(search.focusNode?.hasFocus, isTrue);
    harness.dispose();
  });

  // #region semantics-contract-test
  testWidgets('announces result count and exposes only a floor-plan summary', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    final listHarness = await _pumpGuide(tester);
    final resultNode = tester.getSemantics(
      find.byKey(const ValueKey('venue-result-status')),
    );
    expect(resultNode.label, contains('找到 4 个地点'));
    listHarness.dispose();

    final detailHarness = await _pumpGuide(
      tester,
      initialLocation: '/venues/atrium?floor=2',
    );
    final planNode = tester.getSemantics(
      find.byKey(const ValueKey('floor-plan-semantics')),
    );
    expect(planNode.label, contains('2 层平面摘要'));
    expect(planNode.flagsCollection.isImage, isTrue);
    final room = find.byKey(const ValueKey('room-quietAlcove'));
    expect(room, findsOneWidget);
    await tester.ensureVisible(room);
    await tester.pump();
    await tester.tap(room);
    await tester.pump();
    expect(find.byKey(const ValueKey('room-selection-status')), findsOneWidget);
    detailHarness.dispose();
    semantics.dispose();
  });
  // #endregion semantics-contract-test

  testWidgets('removes floor transitions when animations are disabled', (
    tester,
  ) async {
    final harness = await _pumpGuide(
      tester,
      initialLocation: '/venues/atrium?floor=2',
      mediaQueryData: const MediaQueryData(disableAnimations: true),
    );

    final switcher = tester.widget<AnimatedSwitcher>(
      find.byKey(const ValueKey('floor-plan-switcher')),
    );
    expect(switcher.duration, Duration.zero);
    harness.dispose();
  });

  testWidgets('explains domain and unmatched URL errors', (tester) async {
    final invalid = await _pumpGuide(
      tester,
      initialLocation: '/venues/atrium?floor=8',
    );
    expect(find.text('这个地点不在 8 层。'), findsOneWidget);
    invalid.dispose();

    final unmatched = await _pumpGuide(
      tester,
      initialLocation: '/not-a-guide-page',
    );
    expect(find.text('没有匹配的页面'), findsOneWidget);
    unmatched.dispose();
  });

  // #region responsive-matrix-test
  for (final size in const [Size(320, 720), Size(768, 900), Size(1440, 900)]) {
    testWidgets(
      'stays usable at ${size.width.toInt()} by ${size.height.toInt()}',
      (tester) async {
        await _setSurface(tester, size);
        final harness = await _pumpGuide(tester);

        expect(
          find.byKey(const ValueKey('venue-search-field')),
          findsOneWidget,
        );
        expect(tester.takeException(), isNull);
        harness.dispose();
      },
    );
  }
  // #endregion responsive-matrix-test

  testWidgets('stays usable at 320 by 720 with 200 percent text', (
    tester,
  ) async {
    await _setSurface(tester, const Size(320, 720));
    final harness = await _pumpGuide(
      tester,
      mediaQueryData: const MediaQueryData(textScaler: TextScaler.linear(2)),
    );

    expect(find.byKey(const ValueKey('venue-search-field')), findsOneWidget);
    expect(tester.takeException(), isNull);
    harness.dispose();
  });

  testWidgets('keeps directional layout valid in the RTL test shell', (
    tester,
  ) async {
    await _setSurface(tester, const Size(768, 900));
    final harness = await _pumpGuide(
      tester,
      initialLocation: '/venues/atrium?floor=2',
      textDirection: TextDirection.rtl,
    );

    expect(find.text('中央中庭'), findsOneWidget);
    expect(find.byKey(const ValueKey('floor-plan-2')), findsOneWidget);
    expect(tester.takeException(), isNull);
    harness.dispose();
  });

  // #region venue-golden-tests
  testWidgets('matches the wide venue index golden', (tester) async {
    await _setSurface(tester, const Size(1440, 900));
    final harness = await _pumpGuide(tester);

    await expectLater(
      find.byType(VenueGuidebookApp),
      matchesGoldenFile(_platformGolden('goldens/venue_guidebook_wide.png')),
    );
    harness.dispose();
  });

  testWidgets('matches the compact detail golden', (tester) async {
    await _setSurface(tester, const Size(390, 844));
    final harness = await _pumpGuide(
      tester,
      initialLocation: '/venues/atrium?floor=2',
    );

    await expectLater(
      find.byType(VenueGuidebookApp),
      matchesGoldenFile(_platformGolden('goldens/venue_guidebook_compact.png')),
    );
    harness.dispose();
  });
  // #endregion venue-golden-tests
}

String _platformGolden(String path) {
  return Platform.isLinux ? path.replaceFirst('.png', '_linux.png') : path;
}

Future<void> _setSurface(WidgetTester tester, Size size) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

Future<_GuideHarness> _pumpGuide(
  WidgetTester tester, {
  String initialLocation = '/',
  Locale locale = const Locale('zh'),
  MediaQueryData? mediaQueryData,
  TextDirection? textDirection,
}) async {
  final controller = VenueGuideController(initialLocale: locale);
  final router = createVenueGuideRouter(
    controller: controller,
    initialLocation: initialLocation,
  );
  await tester.pumpWidget(
    MediaQuery(
      data: mediaQueryData ?? const MediaQueryData(),
      child: VenueGuidebookApp(
        controller: controller,
        router: router,
        textDirectionOverride: textDirection,
      ),
    ),
  );
  await tester.pumpAndSettle();
  return _GuideHarness(controller: controller, router: router);
}

class _GuideHarness {
  const _GuideHarness({required this.controller, required this.router});

  final VenueGuideController controller;
  final GoRouter router;

  void dispose() {
    router.dispose();
    controller.dispose();
  }
}
