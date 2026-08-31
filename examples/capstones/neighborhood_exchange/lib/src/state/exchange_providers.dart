import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/exchange_database.dart';
import '../data/exchange_repository.dart';
import '../data/exchange_storage_service.dart';
import '../data/fixture_exchange_service.dart';
import '../domain/exchange_models.dart';
import '../platform/resource_share_service.dart';

final fixtureExchangeServiceProvider = Provider<FixtureExchangeService>(
  (ref) => const DeterministicFixtureExchangeService(),
);

final exchangeStorageServiceProvider = Provider<ExchangeStorageService>((ref) {
  final database = ExchangeDatabase.defaults();
  ref.onDispose(database.close);
  return database;
});

final exchangeRepositoryProvider = Provider<ExchangeRepository>((ref) {
  return LocalExchangeRepository(
    fixtureService: ref.watch(fixtureExchangeServiceProvider),
    storage: ref.watch(exchangeStorageServiceProvider),
  );
});

final resourceShareServiceProvider = Provider<ResourceShareService>(
  (ref) => const ClipboardResourceShareService(),
);

final exchangeListingsProvider = StreamProvider.autoDispose
    .family<ExchangeResult<List<ExchangeListing>>, ExchangeQuery>(
      (ref, query) => ref.watch(exchangeRepositoryProvider).watch(query),
      retry: noExchangeRetry,
    );

final exchangeListingProvider = FutureProvider.autoDispose
    .family<ExchangeResult<ExchangeListing>, String>(
      (ref, id) => ref.watch(exchangeRepositoryProvider).find(id),
      retry: noExchangeRetry,
    );

class PublishListingState {
  const PublishListingState({
    this.isSubmitting = false,
    this.fieldErrors = const {},
    this.failure,
    this.published,
  });

  final bool isSubmitting;
  final Map<String, String> fieldErrors;
  final ExchangeFailure? failure;
  final ExchangeListing? published;
}

final publishListingProvider =
    NotifierProvider.autoDispose<PublishListingController, PublishListingState>(
      PublishListingController.new,
      retry: noExchangeRetry,
    );

class PublishListingController extends Notifier<PublishListingState> {
  @override
  PublishListingState build() => const PublishListingState();

  Future<ExchangeResult<ExchangeListing>?> submit(PublishDraft draft) async {
    if (state.isSubmitting) return null;
    state = const PublishListingState(isSubmitting: true);
    final result = await ref.read(exchangeRepositoryProvider).publish(draft);
    if (!ref.mounted) return result;
    switch (result) {
      case ExchangeSuccess<ExchangeListing>(:final value):
        state = PublishListingState(published: value);
      case ExchangeFailureResult<ExchangeListing>(:final failure):
        state = PublishListingState(
          failure: failure,
          fieldErrors: switch (failure) {
            ExchangeValidationFailure(:final fieldErrors) => fieldErrors,
            _ => const {},
          },
        );
    }
    return result;
  }
}

class ClaimState {
  const ClaimState({this.activeListingId, this.successListingId, this.failure});

  final String? activeListingId;
  final String? successListingId;
  final ExchangeFailure? failure;
}

final claimListingProvider =
    NotifierProvider<ClaimListingController, ClaimState>(
      ClaimListingController.new,
      retry: noExchangeRetry,
    );

class ClaimListingController extends Notifier<ClaimState> {
  @override
  ClaimState build() => const ClaimState();

  Future<ExchangeResult<ExchangeListing>?> claim(String id) async {
    if (state.activeListingId != null) return null;
    state = ClaimState(activeListingId: id);
    final result = await ref.read(exchangeRepositoryProvider).claim(id);
    if (!ref.mounted) return result;
    switch (result) {
      case ExchangeSuccess<ExchangeListing>():
        state = ClaimState(successListingId: id);
        ref.invalidate(exchangeListingProvider(id));
      case ExchangeFailureResult<ExchangeListing>(:final failure):
        state = ClaimState(failure: failure);
    }
    return result;
  }
}

Duration? noExchangeRetry(int retryCount, Object error) => null;
