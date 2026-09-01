import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:integration_test/integration_test.dart';
import 'package:neighborhood_exchange/src/data/exchange_database.dart';
import 'package:neighborhood_exchange/src/data/fixture_exchange_service.dart';
import 'package:neighborhood_exchange/src/state/exchange_providers.dart';
import 'package:neighborhood_exchange/src/ui/exchange_app.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('publishes, claims, and reopens browser-local state', (
    tester,
  ) async {
    var database = ExchangeDatabase.defaults();
    await database.restoreFixtures(fixtureExchangeListings);
    var router = createExchangeRouter(initialLocation: '/exchange');
    await _pumpApp(tester, database: database, router: router);

    await tester.tap(find.byKey(const ValueKey('publish-listing')));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const ValueKey('title-field')),
      '周末折叠野餐桌',
    );
    await tester.enterText(
      find.byKey(const ValueKey('description-field')),
      '桌面 120×60 厘米，适合四人活动，取用前请确认后备箱空间。',
    );
    await tester.enterText(find.byKey(const ValueKey('quantity-field')), '2');
    await tester.ensureVisible(find.byKey(const ValueKey('submit-listing')));
    await tester.tap(find.byKey(const ValueKey('submit-listing')));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);

    final localPath = router.routeInformationProvider.value.uri.path;
    expect(localPath, startsWith('/listings/local-'));
    final localListingId = Uri.parse(localPath).pathSegments.last;
    expect(find.byKey(ValueKey('detail-$localListingId')), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();
    router.dispose();
    await database.close();

    database = ExchangeDatabase.defaults();
    router = createExchangeRouter(initialLocation: localPath);
    await _pumpApp(tester, database: database, router: router);
    expect(tester.takeException(), isNull);
    expect(find.byKey(ValueKey('detail-$localListingId')), findsOneWidget);

    router.go('/listings/r-001');
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byKey(const ValueKey('claim-listing')));
    await tester.tap(find.byKey(const ValueKey('claim-listing')));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.byKey(const ValueKey('claim-success')), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();
    router.dispose();
    await database.close();

    database = ExchangeDatabase.defaults();
    router = createExchangeRouter(initialLocation: '/listings/r-001');
    await _pumpApp(tester, database: database, router: router);
    expect(tester.takeException(), isNull);
    expect(find.text('我已认领'), findsWidgets);

    router.dispose();
    await database.close();
  });
}

Future<void> _pumpApp(
  WidgetTester tester, {
  required ExchangeDatabase database,
  required GoRouter router,
}) async {
  await tester.pumpWidget(
    ProviderScope(
      retry: noExchangeRetry,
      overrides: [exchangeStorageServiceProvider.overrideWithValue(database)],
      child: NeighborhoodExchangeApp(router: router),
    ),
  );
  await tester.pumpAndSettle();
}
