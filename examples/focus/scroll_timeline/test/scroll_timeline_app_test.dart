import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scroll_timeline/src/scroll_timeline_app.dart';
import 'package:scroll_timeline/src/timeline_data.dart';
import 'package:scroll_timeline/src/timeline_providers.dart';

void main() {
  // #region timeline-lazy-test
  testWidgets('shows the archive controls without building every event', (
    tester,
  ) async {
    await _setSurface(tester, const Size(1440, 900));
    await tester.pumpWidget(const ProviderScope(child: ScrollTimelineApp()));
    await tester.pump();

    expect(find.text('河岸修复六十年'), findsOneWidget);
    for (final topic in TimelineTopic.values) {
      expect(find.text(topic.label), findsAtLeastNWidgets(1));
    }
    expect(find.text(timelineEras.last.title), findsWidgets);
    expect(find.text(timelineEvents.last.title), findsNothing);
  });
  // #endregion timeline-lazy-test

  testWidgets('combines topic filters and restores the complete archive', (
    tester,
  ) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    await _pumpTimeline(tester, container: container);

    await tester.tap(find.byKey(const ValueKey('topic-ecology')));
    await tester.pump();
    expect(container.read(filteredTimelineProvider), hasLength(18));
    expect(find.text('已选 1 个主题'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('topic-community')));
    await tester.pump();
    expect(container.read(filteredTimelineProvider), hasLength(36));
    expect(find.text('已选 2 个主题'), findsOneWidget);

    await tester.tap(find.text('恢复全部'));
    await tester.pump();
    expect(container.read(filteredTimelineProvider), hasLength(72));
    expect(find.text('当前显示全部主题'), findsOneWidget);
  });

  testWidgets('directory jump moves focus to the requested era', (
    tester,
  ) async {
    await _pumpTimeline(tester);

    await tester.tap(
      find.byKey(const ValueKey('directory-shared-stewardship')),
    );
    await tester.pumpAndSettle();

    final focus = tester.widget<Focus>(
      find.byKey(const ValueKey('era-focus-shared-stewardship')),
    );
    expect(focus.focusNode?.hasFocus, isTrue);
    expect(find.text('共治试验'), findsWidgets);
  });

  // #region timeline-semantics-test
  testWidgets('exposes era and event summaries to assistive technology', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    await _pumpTimeline(tester);

    expect(
      tester
          .getSemantics(
            find.byKey(const ValueKey('era-semantics-blocked-river')),
          )
          .flagsCollection
          .isHeader,
      isTrue,
    );
    expect(
      tester
          .getSemantics(
            find.byKey(const ValueKey('event-semantics-blocked-river-01')),
          )
          .label,
      contains('1965 年，最后一班摆渡靠岸，生态复原'),
    );
    semantics.dispose();
  });
  // #endregion timeline-semantics-test

  for (final size in const [Size(320, 720), Size(768, 900), Size(1440, 900)]) {
    testWidgets('stays usable at ${size.width} by ${size.height}', (
      tester,
    ) async {
      await _setSurface(tester, size);
      await _pumpTimeline(tester);

      expect(find.byKey(const ValueKey('timeline-scroll')), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('supports 200 percent text and reduced motion on a narrow view', (
    tester,
  ) async {
    await _setSurface(tester, const Size(320, 720));
    await _pumpTimeline(
      tester,
      mediaQueryData: const MediaQueryData(
        textScaler: TextScaler.linear(2),
        disableAnimations: true,
      ),
    );

    expect(find.byKey(const ValueKey('timeline-scroll')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  // #region timeline-golden-tests
  testWidgets('matches the wide opening golden', (tester) async {
    await _setSurface(tester, const Size(1440, 900));
    await _pumpTimeline(tester);

    await expectLater(
      find.byType(ScrollTimelineApp),
      matchesGoldenFile(_platformGolden('goldens/scroll_timeline_wide.png')),
    );
  });

  testWidgets('matches the compact middle-era golden', (tester) async {
    await _setSurface(tester, const Size(320, 720));
    await _pumpTimeline(tester);
    await tester.scrollUntilVisible(
      find.byKey(const ValueKey('era-focus-wetland-link')),
      520,
      scrollable: find
          .descendant(
            of: find.byKey(const ValueKey('timeline-scroll')),
            matching: find.byType(Scrollable),
          )
          .first,
    );
    await tester.pumpAndSettle();

    await expectLater(
      find.byType(ScrollTimelineApp),
      matchesGoldenFile(_platformGolden('goldens/scroll_timeline_compact.png')),
    );
  });
  // #endregion timeline-golden-tests
}

String _platformGolden(String path) {
  return Platform.isLinux ? path.replaceFirst('.png', '_linux.png') : path;
}

Future<void> _pumpTimeline(
  WidgetTester tester, {
  ProviderContainer? container,
  MediaQueryData? mediaQueryData,
}) async {
  final app = MediaQuery(
    data: mediaQueryData ?? const MediaQueryData(),
    child: const ScrollTimelineApp(),
  );
  await tester.pumpWidget(
    container == null
        ? ProviderScope(child: app)
        : UncontrolledProviderScope(container: container, child: app),
  );
  await tester.pump();
}

Future<void> _setSurface(WidgetTester tester, Size size) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}
