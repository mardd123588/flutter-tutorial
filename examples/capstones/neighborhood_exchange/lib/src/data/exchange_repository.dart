import '../domain/exchange_models.dart';
import 'exchange_storage_service.dart';
import 'fixture_exchange_service.dart';

sealed class ExchangeResult<T> {
  const ExchangeResult();
}

class ExchangeSuccess<T> extends ExchangeResult<T> {
  const ExchangeSuccess(this.value);

  final T value;
}

class ExchangeFailureResult<T> extends ExchangeResult<T> {
  const ExchangeFailureResult(this.failure);

  final ExchangeFailure failure;
}

sealed class ExchangeFailure {
  const ExchangeFailure();
}

class ExchangeFixtureFailure extends ExchangeFailure {
  const ExchangeFixtureFailure();
}

class ExchangeStorageFailure extends ExchangeFailure {
  const ExchangeStorageFailure();
}

class ExchangeNotFoundFailure extends ExchangeFailure {
  const ExchangeNotFoundFailure(this.id, {required this.localOnly});

  final String id;
  final bool localOnly;
}

class ExchangeValidationFailure extends ExchangeFailure {
  const ExchangeValidationFailure(this.fieldErrors);

  final Map<String, String> fieldErrors;
}

class ExchangeClaimFailure extends ExchangeFailure {
  const ExchangeClaimFailure(this.reason);

  final ClaimWriteResult reason;
}

abstract interface class ExchangeRepository {
  Future<ExchangeResult<void>> load();

  Stream<ExchangeResult<List<ExchangeListing>>> watch(ExchangeQuery query);

  Future<ExchangeResult<ExchangeListing>> find(String id);

  Future<ExchangeResult<ExchangeListing>> publish(PublishDraft draft);

  Future<ExchangeResult<ExchangeListing>> claim(String id);

  Future<ExchangeResult<void>> restoreDemoData();
}

class LocalExchangeRepository implements ExchangeRepository {
  LocalExchangeRepository({
    required this.fixtureService,
    required this.storage,
    DateTime Function()? clock,
  }) : clock = clock ?? DateTime.now;

  final FixtureExchangeService fixtureService;
  final ExchangeStorageService storage;
  final DateTime Function() clock;
  List<ExchangeListing>? _fixtures;
  var _localSequence = 0;

  @override
  Future<ExchangeResult<void>> load() async {
    late final List<ExchangeListing> fixtures;
    try {
      fixtures = _fixtures ?? await fixtureService.load();
      _fixtures = fixtures;
    } on Exception {
      return const ExchangeFailureResult(ExchangeFixtureFailure());
    }
    try {
      await storage.ensureSeeded(fixtures);
      return const ExchangeSuccess(null);
    } on Exception {
      return const ExchangeFailureResult(ExchangeStorageFailure());
    }
  }

  @override
  Stream<ExchangeResult<List<ExchangeListing>>> watch(
    ExchangeQuery query,
  ) async* {
    final ready = await load();
    if (ready case ExchangeFailureResult<void>(:final failure)) {
      yield ExchangeFailureResult(failure);
      return;
    }
    try {
      await for (final snapshot in storage.watchSnapshot()) {
        final claimedIds = snapshot.claims
            .where((claim) => claim.claimantId == localUserId)
            .map((claim) => claim.listingId)
            .toSet();
        final listings = snapshot.listings
            .map(
              (listing) => listing.copyWith(
                claimedByCurrentUser: claimedIds.contains(listing.id),
              ),
            )
            .toList(growable: false);
        yield ExchangeSuccess(query.apply(listings));
      }
    } on Exception {
      yield const ExchangeFailureResult(ExchangeStorageFailure());
    }
  }

  @override
  Future<ExchangeResult<ExchangeListing>> find(String id) async {
    final ready = await load();
    if (ready case ExchangeFailureResult<void>(:final failure)) {
      return ExchangeFailureResult(failure);
    }
    try {
      final snapshot = await storage.readSnapshot();
      final listing = snapshot.listings
          .where((item) => item.id == id)
          .firstOrNull;
      if (listing == null) {
        return ExchangeFailureResult(
          ExchangeNotFoundFailure(id, localOnly: id.startsWith('local-')),
        );
      }
      final claimed = snapshot.claims.any(
        (claim) => claim.listingId == id && claim.claimantId == localUserId,
      );
      return ExchangeSuccess(listing.copyWith(claimedByCurrentUser: claimed));
    } on Exception {
      return const ExchangeFailureResult(ExchangeStorageFailure());
    }
  }

  @override
  Future<ExchangeResult<ExchangeListing>> publish(PublishDraft draft) async {
    final fieldErrors = draft.validate();
    if (fieldErrors.isNotEmpty) {
      return ExchangeFailureResult(ExchangeValidationFailure(fieldErrors));
    }
    final ready = await load();
    if (ready case ExchangeFailureResult<void>(:final failure)) {
      return ExchangeFailureResult(failure);
    }
    final now = clock().toUtc();
    _localSequence += 1;
    final quantity = int.parse(draft.quantityText.trim());
    final listing = ExchangeListing(
      id: 'local-${now.microsecondsSinceEpoch}-$_localSequence',
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
    try {
      await storage.insertListing(listing);
      return ExchangeSuccess(listing);
    } on Exception {
      return const ExchangeFailureResult(ExchangeStorageFailure());
    }
  }

  @override
  Future<ExchangeResult<ExchangeListing>> claim(String id) async {
    final ready = await load();
    if (ready case ExchangeFailureResult<void>(:final failure)) {
      return ExchangeFailureResult(failure);
    }
    try {
      final writeResult = await storage.claimOne(
        listingId: id,
        claimantId: localUserId,
        claimedAt: clock().toUtc(),
      );
      if (writeResult != ClaimWriteResult.claimed &&
          writeResult != ClaimWriteResult.alreadyClaimed) {
        return ExchangeFailureResult(ExchangeClaimFailure(writeResult));
      }
      return await find(id);
    } on Exception {
      return const ExchangeFailureResult(ExchangeStorageFailure());
    }
  }

  @override
  Future<ExchangeResult<void>> restoreDemoData() async {
    try {
      final fixtures = _fixtures ?? await fixtureService.load();
      _fixtures = fixtures;
      await storage.restoreFixtures(fixtures);
      return const ExchangeSuccess(null);
    } on Exception {
      return const ExchangeFailureResult(ExchangeStorageFailure());
    }
  }
}
