import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:neighborhood_exchange/src/data/fixture_exchange_service.dart';
import 'package:neighborhood_exchange/src/domain/exchange_models.dart';
import 'package:neighborhood_exchange/src/state/exchange_providers.dart';
import 'package:neighborhood_exchange/src/ui/exchange_app.dart';

import 'support/fake_exchange_repository.dart';

void main() {
  testWidgets('uses a three-part notice desk on wide screens', (tester) async {
    await _setSurface(tester, const Size(1440, 900));
    final harness = await _pumpExchange(tester);

    expect(find.byKey(const ValueKey('filter-ledger')), findsOneWidget);
    expect(find.byKey(const ValueKey('listing-list')), findsOneWidget);
    expect(find.text('待填写取用签'), findsOneWidget);
    expect(
      tester
          .getSemantics(find.byKey(const ValueKey('listing-result-status')))
          .label,
      contains('12 条演示资源'),
    );
    harness.dispose();
  });

  testWidgets('restores search and category from the URL', (tester) async {
    final harness = await _pumpExchange(
      tester,
      initialLocation: '/exchange?q=折叠&category=tools',
    );

    expect(find.text('折叠手推车'), findsOneWidget);
    expect(find.text('家用冲击钻'), findsNothing);
    expect(
      harness
          .router
          .routeInformationProvider
          .value
          .uri
          .queryParameters['category'],
      'tools',
    );
    harness.dispose();
  });

  testWidgets('opens compact filters and writes them to the URL', (
    tester,
  ) async {
    await _setSurface(tester, const Size(320, 720));
    final harness = await _pumpExchange(tester);

    expect(find.byKey(const ValueKey('filter-ledger')), findsNothing);
    await tester.tap(find.byKey(const ValueKey('open-filters')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('category-filter')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('园艺').last);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('apply-filters')));
    await tester.pumpAndSettle();

    expect(
      harness
          .router
          .routeInformationProvider
          .value
          .uri
          .queryParameters['category'],
      'garden',
    );
    harness.dispose();
  });

  testWidgets('claims a fixture and announces the browser-local result', (
    tester,
  ) async {
    final repository = FakeExchangeRepository();
    final target = repository.listings.firstWhere(
      (listing) => listing.canBeClaimedBy(localUserId),
    );
    final harness = await _pumpExchange(
      tester,
      repository: repository,
      initialLocation: '/listings/${target.id}',
    );

    await tester.tap(find.byKey(const ValueKey('claim-listing')));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('claim-success')), findsOneWidget);
    expect(find.textContaining('仅保存在当前浏览器'), findsOneWidget);
    expect(repository.claimCalls, 1);
    harness.dispose();
  });

  testWidgets('explains a browser-local link missing from this profile', (
    tester,
  ) async {
    final harness = await _pumpExchange(
      tester,
      initialLocation: '/listings/local-other-profile',
    );

    expect(find.byKey(const ValueKey('local-only-missing')), findsOneWidget);
    expect(find.text('这条记录属于另一个浏览器'), findsOneWidget);
    harness.dispose();
  });

  testWidgets('warns before copying a local listing link', (tester) async {
    final local = _localListing();
    final repository = FakeExchangeRepository(listings: [local]);
    final share = RecordingShareService();
    final harness = await _pumpExchange(
      tester,
      repository: repository,
      shareService: share,
      initialLocation: '/listings/${local.id}',
    );

    await tester.ensureVisible(find.byKey(const ValueKey('copy-listing-link')));
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey('copy-listing-link')));
    await tester.pumpAndSettle();
    expect(find.text('这个链接只在当前浏览器有完整内容'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('confirm-copy-local-link')));
    await tester.pumpAndSettle();
    expect(share.lastLink, contains('#/listings/local-widget-existing'));
    harness.dispose();
  });

  testWidgets('focuses a complete error summary before publishing', (
    tester,
  ) async {
    final repository = FakeExchangeRepository();
    final harness = await _pumpExchange(
      tester,
      repository: repository,
      initialLocation: '/publish',
    );

    await tester.ensureVisible(find.byKey(const ValueKey('submit-listing')));
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey('submit-listing')));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('publish-error-summary')), findsOneWidget);
    final focus = tester.widget<Focus>(
      find.byKey(const ValueKey('publish-error-summary-focus')),
    );
    expect(focus.focusNode?.hasFocus, isTrue);

    await tester.enterText(find.byKey(const ValueKey('title-field')), '折叠野餐桌');
    await tester.enterText(
      find.byKey(const ValueKey('description-field')),
      '桌面 120×60 厘米，取用前请确认后备箱空间。',
    );
    await tester.enterText(find.byKey(const ValueKey('quantity-field')), '2');
    await tester.ensureVisible(find.byKey(const ValueKey('submit-listing')));
    await tester.drag(find.byType(ListView).last, const Offset(0, -120));
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey('submit-listing')));
    await tester.pumpAndSettle();

    expect(
      harness.router.routeInformationProvider.value.uri.path,
      '/listings/local-widget-2',
    );
    expect(find.text('折叠野餐桌'), findsOneWidget);
    harness.dispose();
  });

  for (final size in const [Size(320, 720), Size(768, 900), Size(1440, 900)]) {
    testWidgets(
      'keeps browsing usable at ${size.width.toInt()} by ${size.height.toInt()}',
      (tester) async {
        await _setSurface(tester, size);
        final harness = await _pumpExchange(tester);
        expect(find.byKey(const ValueKey('publish-listing')), findsOneWidget);
        expect(
          find.byKey(const ValueKey('listing-result-status')),
          findsOneWidget,
        );
        expect(tester.takeException(), isNull);
        harness.dispose();
      },
    );
  }

  testWidgets(
    'supports 200 percent text and reduced motion on a narrow screen',
    (tester) async {
      await _setSurface(tester, const Size(320, 720));
      final harness = await _pumpExchange(
        tester,
        mediaQueryData: const MediaQueryData(
          textScaler: TextScaler.linear(2),
          disableAnimations: true,
        ),
      );
      expect(find.byKey(const ValueKey('listing-list')), findsOneWidget);
      expect(tester.takeException(), isNull);
      harness.dispose();
    },
  );

  testWidgets('removes the detail transition when motion is reduced', (
    tester,
  ) async {
    await _setSurface(tester, const Size(1440, 900));
    final harness = await _pumpExchange(
      tester,
      mediaQueryData: const MediaQueryData(disableAnimations: true),
    );

    final transition = tester.widget<AnimatedSwitcher>(
      find.byKey(const ValueKey('detail-transition')),
    );
    expect(transition.duration, Duration.zero);
    harness.dispose();
  });

  testWidgets('keeps primary tasks available in RTL', (tester) async {
    final harness = await _pumpExchange(
      tester,
      textDirection: TextDirection.rtl,
    );
    expect(find.byKey(const ValueKey('publish-listing')), findsOneWidget);
    expect(find.byKey(const ValueKey('listing-search')), findsOneWidget);
    expect(tester.takeException(), isNull);
    harness.dispose();
  });
}

Future<void> _setSurface(WidgetTester tester, Size size) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

Future<_ExchangeHarness> _pumpExchange(
  WidgetTester tester, {
  FakeExchangeRepository? repository,
  RecordingShareService? shareService,
  String initialLocation = '/exchange',
  MediaQueryData? mediaQueryData,
  TextDirection textDirection = TextDirection.ltr,
}) async {
  final resolvedRepository = repository ?? FakeExchangeRepository();
  final resolvedShare = shareService ?? RecordingShareService();
  final router = createExchangeRouter(initialLocation: initialLocation);
  await tester.pumpWidget(
    ProviderScope(
      retry: noExchangeRetry,
      overrides: [
        exchangeRepositoryProvider.overrideWithValue(resolvedRepository),
        resourceShareServiceProvider.overrideWithValue(resolvedShare),
      ],
      child: NeighborhoodExchangeApp(
        router: router,
        builder: (context, child) => MediaQuery(
          data: mediaQueryData ?? MediaQuery.of(context),
          child: Directionality(
            textDirection: textDirection,
            child: child ?? const SizedBox.shrink(),
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return _ExchangeHarness(router: router);
}

class _ExchangeHarness {
  const _ExchangeHarness({required this.router});

  final GoRouter router;

  void dispose() => router.dispose();
}

ExchangeListing _localListing() {
  final source = fixtureExchangeListings.first;
  return ExchangeListing(
    id: 'local-widget-existing',
    origin: ListingOrigin.local,
    title: '本地折叠桌',
    description: '只保存在当前浏览器。',
    category: source.category,
    neighborhood: source.neighborhood,
    handoffMethod: source.handoffMethod,
    availableWindow: source.availableWindow,
    totalQuantity: 1,
    remainingQuantity: 1,
    ownerId: localUserId,
    ownerDisplayName: localUserDisplayName,
    createdAt: source.createdAt,
    updatedAt: source.updatedAt,
  );
}
