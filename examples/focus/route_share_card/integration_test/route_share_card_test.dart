import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:route_share_card/src/route_share_card_app.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('opens a route and updates its shareable preferences', (
    tester,
  ) async {
    final router = createRouteShareRouter();
    addTearDown(router.dispose);
    await tester.pumpWidget(RouteShareCardApp(router: router));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('open-route-museum-loop')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('mode-fast')));
    await tester.pumpAndSettle();

    expect(
      router.routeInformationProvider.value.uri.path,
      '/routes/museum-loop',
    );
    expect(
      router.routeInformationProvider.value.uri.queryParameters['mode'],
      'fast',
    );
    expect(find.text('快速模式 · 从旧仓库入口出发'), findsOneWidget);
  });
}
