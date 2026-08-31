import 'dart:async';

import 'package:neighborhood_exchange/src/data/exchange_repository.dart';
import 'package:neighborhood_exchange/src/data/exchange_storage_service.dart';
import 'package:neighborhood_exchange/src/data/fixture_exchange_service.dart';
import 'package:neighborhood_exchange/src/domain/exchange_models.dart';
import 'package:neighborhood_exchange/src/platform/resource_share_service.dart';

class FakeExchangeRepository implements ExchangeRepository {
  FakeExchangeRepository({List<ExchangeListing>? listings})
    : listings = [...(listings ?? fixtureExchangeListings.take(12))];

  final List<ExchangeListing> listings;
  final Set<String> claimedIds = {};
  var publishCalls = 0;
  var claimCalls = 0;

  @override
  Future<ExchangeResult<ExchangeListing>> claim(String id) async {
    claimCalls += 1;
    final index = listings.indexWhere((listing) => listing.id == id);
    if (index == -1) {
      return ExchangeFailureResult(
        ExchangeNotFoundFailure(id, localOnly: id.startsWith('local-')),
      );
    }
    final listing = listings[index];
    if (!listing.canBeClaimedBy(localUserId)) {
      return const ExchangeFailureResult(
        ExchangeClaimFailure(ClaimWriteResult.unavailable),
      );
    }
    claimedIds.add(id);
    final claimed = listing.copyWith(
      remainingQuantity: listing.remainingQuantity - 1,
      claimedByCurrentUser: true,
    );
    listings[index] = claimed;
    return ExchangeSuccess(claimed);
  }

  @override
  Future<ExchangeResult<ExchangeListing>> find(String id) async {
    final listing = listings.where((item) => item.id == id).firstOrNull;
    if (listing == null) {
      return ExchangeFailureResult(
        ExchangeNotFoundFailure(id, localOnly: id.startsWith('local-')),
      );
    }
    return ExchangeSuccess(
      listing.copyWith(claimedByCurrentUser: claimedIds.contains(id)),
    );
  }

  @override
  Future<ExchangeResult<void>> load() async => const ExchangeSuccess(null);

  @override
  Future<ExchangeResult<ExchangeListing>> publish(PublishDraft draft) async {
    publishCalls += 1;
    final errors = draft.validate();
    if (errors.isNotEmpty) {
      return ExchangeFailureResult(ExchangeValidationFailure(errors));
    }
    final now = DateTime.utc(2026, 8, 31, 12);
    final quantity = int.parse(draft.quantityText);
    final listing = ExchangeListing(
      id: 'local-widget-$publishCalls',
      origin: ListingOrigin.local,
      title: draft.title.trim(),
      description: draft.description.trim(),
      category: draft.category,
      neighborhood: draft.neighborhood,
      handoffMethod: draft.handoffMethod,
      availableWindow: draft.availableWindow,
      totalQuantity: quantity,
      remainingQuantity: quantity,
      ownerId: localUserId,
      ownerDisplayName: localUserDisplayName,
      createdAt: now,
      updatedAt: now,
    );
    listings.add(listing);
    return ExchangeSuccess(listing);
  }

  @override
  Future<ExchangeResult<void>> restoreDemoData() async {
    listings
      ..clear()
      ..addAll(fixtureExchangeListings.take(12));
    claimedIds.clear();
    return const ExchangeSuccess(null);
  }

  @override
  Stream<ExchangeResult<List<ExchangeListing>>> watch(ExchangeQuery query) {
    final visible = listings
        .map(
          (listing) => listing.copyWith(
            claimedByCurrentUser: claimedIds.contains(listing.id),
          ),
        )
        .toList(growable: false);
    return Stream.value(ExchangeSuccess(query.apply(visible)));
  }
}

class RecordingShareService implements ResourceShareService {
  String? lastLink;

  @override
  Future<void> copyLink(String link) async {
    lastLink = link;
  }
}
