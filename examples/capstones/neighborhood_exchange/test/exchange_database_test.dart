import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:neighborhood_exchange/src/data/exchange_database.dart';
import 'package:neighborhood_exchange/src/data/exchange_storage_service.dart';
import 'package:neighborhood_exchange/src/data/fixture_exchange_service.dart';
import 'package:neighborhood_exchange/src/domain/exchange_models.dart';

void main() {
  late ExchangeDatabase database;

  setUp(() {
    database = ExchangeDatabase(NativeDatabase.memory());
  });

  tearDown(() => database.close());

  test('seeds fixtures once without replacing local data', () async {
    await database.ensureSeeded(fixtureExchangeListings);
    await database.insertListing(_localListing());
    await database.ensureSeeded(fixtureExchangeListings);

    final snapshot = await database.readSnapshot();
    expect(snapshot.listings, hasLength(49));
    expect(
      snapshot.listings.where(
        (listing) => listing.origin == ListingOrigin.local,
      ),
      hasLength(1),
    );
  });

  test('claim transaction is idempotent and decrements one unit', () async {
    await database.ensureSeeded(fixtureExchangeListings);
    final listing = fixtureExchangeListings.firstWhere(
      (item) => item.remainingQuantity > 1 && item.ownerId != localUserId,
    );
    final first = await database.claimOne(
      listingId: listing.id,
      claimantId: localUserId,
      claimedAt: DateTime.utc(2026, 8, 31, 10),
    );
    final second = await database.claimOne(
      listingId: listing.id,
      claimantId: localUserId,
      claimedAt: DateTime.utc(2026, 8, 31, 11),
    );

    expect(first, ClaimWriteResult.claimed);
    expect(second, ClaimWriteResult.alreadyClaimed);
    final stored = await database.findListing(listing.id);
    expect(stored!.remainingQuantity, listing.remainingQuantity - 1);
    expect(
      (await database.readSnapshot()).claims.where(
        (claim) => claim.listingId == listing.id,
      ),
      hasLength(1),
    );
  });

  test('claim rejects own, unavailable, and unknown listings', () async {
    await database.ensureSeeded(fixtureExchangeListings);
    await database.insertListing(_localListing());
    final unavailable = fixtureExchangeListings.firstWhere(
      (listing) => listing.status != ExchangeStatus.available,
    );

    expect(
      await database.claimOne(
        listingId: 'local-test',
        claimantId: localUserId,
        claimedAt: DateTime.utc(2026, 8, 31),
      ),
      ClaimWriteResult.ownListing,
    );
    expect(
      await database.claimOne(
        listingId: unavailable.id,
        claimantId: localUserId,
        claimedAt: DateTime.utc(2026, 8, 31),
      ),
      ClaimWriteResult.unavailable,
    );
    expect(
      await database.claimOne(
        listingId: 'missing',
        claimantId: localUserId,
        claimedAt: DateTime.utc(2026, 8, 31),
      ),
      ClaimWriteResult.notFound,
    );
  });

  test('restore removes local listings and claims', () async {
    await database.ensureSeeded(fixtureExchangeListings);
    await database.insertListing(_localListing());
    final claimable = fixtureExchangeListings.firstWhere(
      (listing) => listing.canBeClaimedBy(localUserId),
    );
    await database.claimOne(
      listingId: claimable.id,
      claimantId: localUserId,
      claimedAt: DateTime.utc(2026, 8, 31),
    );

    await database.restoreFixtures(fixtureExchangeListings);
    final snapshot = await database.readSnapshot();
    expect(snapshot.listings, hasLength(48));
    expect(snapshot.claims, isEmpty);
    expect(
      snapshot.listings.any((listing) => listing.origin == ListingOrigin.local),
      isFalse,
    );
  });
}

ExchangeListing _localListing() {
  final now = DateTime.utc(2026, 8, 31);
  return ExchangeListing(
    id: 'local-test',
    origin: ListingOrigin.local,
    title: '本地折叠桌',
    description: '只用于测试。',
    category: ExchangeCategory.eventKit,
    neighborhood: Neighborhood.qinghe,
    handoffMethod: HandoffMethod.dutyDesk,
    availableWindow: AvailableWindow.values.first,
    totalQuantity: 1,
    remainingQuantity: 1,
    ownerId: localUserId,
    ownerDisplayName: localUserDisplayName,
    createdAt: now,
    updatedAt: now,
  );
}
