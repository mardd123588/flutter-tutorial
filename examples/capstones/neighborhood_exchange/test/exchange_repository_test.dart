import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:neighborhood_exchange/src/data/exchange_database.dart';
import 'package:neighborhood_exchange/src/data/exchange_repository.dart';
import 'package:neighborhood_exchange/src/data/fixture_exchange_service.dart';
import 'package:neighborhood_exchange/src/domain/exchange_models.dart';

void main() {
  late ExchangeDatabase database;
  late LocalExchangeRepository repository;

  setUp(() {
    database = ExchangeDatabase(NativeDatabase.memory());
    repository = LocalExchangeRepository(
      fixtureService: const DeterministicFixtureExchangeService(),
      storage: database,
      clock: () => DateTime.utc(2026, 8, 31, 12),
    );
  });

  tearDown(() => database.close());

  test('publishes a normalized browser-local listing', () async {
    final result = await repository.publish(_validDraft(title: '  折叠野餐桌  '));
    expect(result, isA<ExchangeSuccess<ExchangeListing>>());
    final listing = (result as ExchangeSuccess<ExchangeListing>).value;
    expect(listing.title, '折叠野餐桌');
    expect(listing.origin, ListingOrigin.local);
    expect(listing.ownerId, localUserId);
    expect((await database.findListing(listing.id))?.title, '折叠野餐桌');
  });

  test('returns field errors without writing an invalid listing', () async {
    final result = await repository.publish(_validDraft(title: ''));
    expect(result, isA<ExchangeFailureResult<ExchangeListing>>());
    final failure = (result as ExchangeFailureResult<ExchangeListing>).failure;
    expect(failure, isA<ExchangeValidationFailure>());
    expect((await database.readSnapshot()).listings, isEmpty);
  });

  test('claim returns the persisted current-user state', () async {
    final listing = fixtureExchangeListings.firstWhere(
      (item) => item.canBeClaimedBy(localUserId),
    );
    final result = await repository.claim(listing.id);
    expect(result, isA<ExchangeSuccess<ExchangeListing>>());
    final claimed = (result as ExchangeSuccess<ExchangeListing>).value;
    expect(claimed.claimedByCurrentUser, isTrue);
    expect(claimed.remainingQuantity, listing.remainingQuantity - 1);
  });

  test(
    'distinguishes a missing local link from an unknown fixture id',
    () async {
      final local = await repository.find('local-another-browser');
      final fixture = await repository.find('r-999');
      expect(
        (local as ExchangeFailureResult<ExchangeListing>).failure,
        isA<ExchangeNotFoundFailure>().having(
          (value) => value.localOnly,
          'localOnly',
          isTrue,
        ),
      );
      expect(
        (fixture as ExchangeFailureResult<ExchangeListing>).failure,
        isA<ExchangeNotFoundFailure>().having(
          (value) => value.localOnly,
          'localOnly',
          isFalse,
        ),
      );
    },
  );
}

PublishDraft _validDraft({required String title}) {
  return PublishDraft(
    title: title,
    description: '桌面 120×60 厘米，取用前请确认后备箱空间。',
    category: ExchangeCategory.eventKit,
    neighborhood: Neighborhood.nanyuan,
    handoffMethod: HandoffMethod.dutyDesk,
    availableWindow: AvailableWindow.values[2],
    quantityText: '1',
  );
}
