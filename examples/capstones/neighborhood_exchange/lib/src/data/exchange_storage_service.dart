import '../domain/exchange_models.dart';

class StoredExchangeSnapshot {
  const StoredExchangeSnapshot({required this.listings, required this.claims});

  final List<ExchangeListing> listings;
  final List<ExchangeClaim> claims;
}

enum ClaimWriteResult {
  claimed,
  alreadyClaimed,
  ownListing,
  unavailable,
  notFound,
}

abstract interface class ExchangeStorageService {
  Future<void> ensureSeeded(List<ExchangeListing> listings);

  Stream<StoredExchangeSnapshot> watchSnapshot();

  Future<StoredExchangeSnapshot> readSnapshot();

  Future<ExchangeListing?> findListing(String id);

  Future<void> insertListing(ExchangeListing listing);

  Future<ClaimWriteResult> claimOne({
    required String listingId,
    required String claimantId,
    required DateTime claimedAt,
  });

  Future<void> restoreFixtures(List<ExchangeListing> listings);
}
