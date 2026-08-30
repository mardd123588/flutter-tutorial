import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:route_share_card/src/route_share_card_app.dart';
import 'package:route_share_card/src/share_clipboard.dart';

void main() {
  testWidgets('opens a route and writes mode changes to the URL', (
    tester,
  ) async {
    final router = createRouteShareRouter();
    addTearDown(router.dispose);
    await tester.pumpWidget(RouteShareCardApp(router: router));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('open-route-museum-loop')));
    await tester.pumpAndSettle();
    expect(
      router.routeInformationProvider.value.uri.path,
      '/routes/museum-loop',
    );

    await tester.tap(find.byKey(const ValueKey('mode-quiet')));
    await tester.pumpAndSettle();
    expect(
      router.routeInformationProvider.value.uri.queryParameters['mode'],
      'quiet',
    );
    expect(find.text('安静模式 · 从旧仓库入口出发'), findsOneWidget);
  });

  testWidgets('restores a deep link without extra state', (tester) async {
    final router = createRouteShareRouter(
      initialLocation: '/routes/museum-loop?mode=fast&start=北门%20服务台',
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(RouteShareCardApp(router: router));
    await tester.pumpAndSettle();

    expect(find.text('博物馆环线'), findsOneWidget);
    expect(find.text('快速模式 · 从北门 服务台出发'), findsOneWidget);
    expect(find.text('北门 服务台'), findsOneWidget);
  });

  testWidgets('copies a complete URL and announces success', (tester) async {
    final clipboard = MemoryClipboard();
    final router = createRouteShareRouter(
      initialLocation: '/routes/museum-loop?mode=quiet',
      clipboard: clipboard,
      shareUrlBuilder: (location) =>
          'https://example.test/flutter-tutorial/previews/route-share-card/#$location',
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(RouteShareCardApp(router: router));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('copy-link')));
    await tester.pump();

    expect(
      clipboard.text,
      'https://example.test/flutter-tutorial/previews/route-share-card/#/routes/museum-loop?mode=quiet',
    );
    expect(find.text('已复制，可在新标签打开'), findsOneWidget);
    final semantics = tester.getSemantics(
      find.byKey(const ValueKey('copy-status')),
    );
    expect(semantics.label, contains('链接已复制'));
  });

  testWidgets('explains domain and unmatched URL errors', (tester) async {
    final domainRouter = createRouteShareRouter(
      initialLocation: '/routes/museum-loop?mode=unknown',
    );
    addTearDown(domainRouter.dispose);
    await tester.pumpWidget(RouteShareCardApp(router: domainRouter));
    await tester.pumpAndSettle();
    expect(find.text('行进模式“unknown”无效'), findsOneWidget);
    expect(find.textContaining('balanced、quiet 或 fast'), findsOneWidget);

    final unmatchedRouter = GoRouter(
      initialLocation: '/not-a-route',
      routes: [
        GoRoute(path: '/', builder: (context, state) => const SizedBox()),
      ],
      errorBuilder: (context, state) => UnmatchedRoutePage(uri: state.uri),
    );
    addTearDown(unmatchedRouter.dispose);
    await tester.pumpWidget(RouteShareCardApp(router: unmatchedRouter));
    await tester.pumpAndSettle();
    expect(find.text('没有匹配的页面'), findsOneWidget);
  });

  testWidgets('fits 320 by 720 at 200 percent text scale', (tester) async {
    tester.view.physicalSize = const Size(320, 720);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final router = createRouteShareRouter(
      initialLocation: '/routes/museum-loop?mode=quiet',
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(textScaler: TextScaler.linear(2)),
        child: RouteShareCardApp(router: router),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('博物馆环线'), findsOneWidget);
    expect(find.byKey(const ValueKey('copy-link')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('removes the cue transition when animations are disabled', (
    tester,
  ) async {
    final router = createRouteShareRouter(
      initialLocation: '/routes/museum-loop',
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(disableAnimations: true),
        child: RouteShareCardApp(router: router),
      ),
    );
    await tester.pumpAndSettle();

    final switcher = tester.widget<AnimatedSwitcher>(
      find.byType(AnimatedSwitcher),
    );
    expect(switcher.duration, Duration.zero);
  });
}

class MemoryClipboard implements ShareClipboard {
  String? text;

  @override
  Future<void> copy(String text) async {
    this.text = text;
  }
}
