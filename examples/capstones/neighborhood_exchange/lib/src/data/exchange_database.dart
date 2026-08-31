import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import '../domain/exchange_models.dart';
import 'exchange_storage_service.dart';

part 'exchange_database.g.dart';

class ExchangeListingRecords extends Table {
  TextColumn get listingId => text()();
  TextColumn get origin => text()();
  TextColumn get title => text()();
  TextColumn get description => text()();
  TextColumn get category => text()();
  TextColumn get neighborhood => text()();
  TextColumn get handoffMethod => text()();
  TextColumn get availableWindowId => text()();
  IntColumn get totalQuantity => integer()();
  IntColumn get remainingQuantity => integer()();
  TextColumn get ownerId => text()();
  TextColumn get ownerDisplayName => text()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get completedAt => dateTime().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {listingId};
}

class ExchangeClaimRecords extends Table {
  TextColumn get listingId => text()();
  TextColumn get claimantId => text()();
  DateTimeColumn get claimedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {listingId, claimantId};
}

class ExchangeSettings extends Table {
  TextColumn get settingKey => text()();
  TextColumn get settingValue => text()();

  @override
  Set<Column<Object>> get primaryKey => {settingKey};
}

@DriftDatabase(
  tables: [ExchangeListingRecords, ExchangeClaimRecords, ExchangeSettings],
)
class ExchangeDatabase extends _$ExchangeDatabase
    implements ExchangeStorageService {
  ExchangeDatabase(super.executor);

  ExchangeDatabase.defaults()
    : super(
        driftDatabase(
          name: 'neighborhood_exchange',
          web: DriftWebOptions(
            sqlite3Wasm: Uri.parse('sqlite3.wasm'),
            driftWorker: Uri.parse('drift_worker.js'),
          ),
        ),
      );

  @override
  int get schemaVersion => 1;

  @override
  Future<void> ensureSeeded(List<ExchangeListing> listings) {
    return transaction(() async {
      final marker =
          await (select(exchangeSettings)
                ..where((row) => row.settingKey.equals('fixture-seed-v1')))
              .getSingleOrNull();
      if (marker != null) return;
      await batch((batch) {
        batch.insertAll(
          exchangeListingRecords,
          listings.map(_listingCompanion).toList(),
        );
        batch.insert(
          exchangeSettings,
          ExchangeSettingsCompanion.insert(
            settingKey: 'fixture-seed-v1',
            settingValue: '48',
          ),
        );
      });
    });
  }

  @override
  Stream<StoredExchangeSnapshot> watchSnapshot() {
    final listingStream = (select(
      exchangeListingRecords,
    )..orderBy([(row) => OrderingTerm.desc(row.createdAt)])).watch();
    return listingStream.asyncMap((rows) async {
      final claims = await select(exchangeClaimRecords).get();
      return StoredExchangeSnapshot(
        listings: rows.map(_listingFromRecord).toList(growable: false),
        claims: claims.map(_claimFromRecord).toList(growable: false),
      );
    });
  }

  @override
  Future<StoredExchangeSnapshot> readSnapshot() async {
    final listings = await (select(
      exchangeListingRecords,
    )..orderBy([(row) => OrderingTerm.desc(row.createdAt)])).get();
    final claims = await select(exchangeClaimRecords).get();
    return StoredExchangeSnapshot(
      listings: listings.map(_listingFromRecord).toList(growable: false),
      claims: claims.map(_claimFromRecord).toList(growable: false),
    );
  }

  @override
  Future<ExchangeListing?> findListing(String id) async {
    final row = await (select(
      exchangeListingRecords,
    )..where((record) => record.listingId.equals(id))).getSingleOrNull();
    return row == null ? null : _listingFromRecord(row);
  }

  @override
  Future<void> insertListing(ExchangeListing listing) {
    return into(exchangeListingRecords).insert(_listingCompanion(listing));
  }

  @override
  Future<ClaimWriteResult> claimOne({
    required String listingId,
    required String claimantId,
    required DateTime claimedAt,
  }) {
    return transaction(() async {
      final existingClaim =
          await (select(exchangeClaimRecords)..where(
                (record) =>
                    record.listingId.equals(listingId) &
                    record.claimantId.equals(claimantId),
              ))
              .getSingleOrNull();
      if (existingClaim != null) return ClaimWriteResult.alreadyClaimed;
      final listing =
          await (select(exchangeListingRecords)
                ..where((record) => record.listingId.equals(listingId)))
              .getSingleOrNull();
      if (listing == null) return ClaimWriteResult.notFound;
      if (listing.ownerId == claimantId) return ClaimWriteResult.ownListing;
      if (listing.completedAt != null || listing.remainingQuantity == 0) {
        return ClaimWriteResult.unavailable;
      }
      await into(exchangeClaimRecords).insert(
        ExchangeClaimRecordsCompanion.insert(
          listingId: listingId,
          claimantId: claimantId,
          claimedAt: claimedAt,
        ),
      );
      await (update(
        exchangeListingRecords,
      )..where((record) => record.listingId.equals(listingId))).write(
        ExchangeListingRecordsCompanion(
          remainingQuantity: Value(listing.remainingQuantity - 1),
          updatedAt: Value(claimedAt),
        ),
      );
      return ClaimWriteResult.claimed;
    });
  }

  @override
  Future<void> restoreFixtures(List<ExchangeListing> listings) {
    return transaction(() async {
      await delete(exchangeClaimRecords).go();
      await delete(exchangeListingRecords).go();
      await batch((batch) {
        batch.insertAll(
          exchangeListingRecords,
          listings.map(_listingCompanion).toList(),
        );
        batch.insert(
          exchangeSettings,
          ExchangeSettingsCompanion.insert(
            settingKey: 'fixture-seed-v1',
            settingValue: '48',
          ),
          mode: InsertMode.insertOrReplace,
        );
      });
    });
  }

  ExchangeListing _listingFromRecord(ExchangeListingRecord row) {
    return ExchangeListing(
      id: row.listingId,
      origin: ListingOrigin.values.byName(row.origin),
      title: row.title,
      description: row.description,
      category: ExchangeCategory.values.byName(row.category),
      neighborhood: Neighborhood.values.byName(row.neighborhood),
      handoffMethod: HandoffMethod.values.byName(row.handoffMethod),
      availableWindow: AvailableWindow.fromId(row.availableWindowId),
      totalQuantity: row.totalQuantity,
      remainingQuantity: row.remainingQuantity,
      ownerId: row.ownerId,
      ownerDisplayName: row.ownerDisplayName,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
      completedAt: row.completedAt,
    );
  }

  ExchangeClaim _claimFromRecord(ExchangeClaimRecord row) {
    return ExchangeClaim(
      listingId: row.listingId,
      claimantId: row.claimantId,
      claimedAt: row.claimedAt,
    );
  }

  ExchangeListingRecordsCompanion _listingCompanion(ExchangeListing listing) {
    return ExchangeListingRecordsCompanion.insert(
      listingId: listing.id,
      origin: listing.origin.name,
      title: listing.title,
      description: listing.description,
      category: listing.category.name,
      neighborhood: listing.neighborhood.name,
      handoffMethod: listing.handoffMethod.name,
      availableWindowId: listing.availableWindow.id,
      totalQuantity: listing.totalQuantity,
      remainingQuantity: listing.remainingQuantity,
      ownerId: listing.ownerId,
      ownerDisplayName: listing.ownerDisplayName,
      createdAt: listing.createdAt,
      updatedAt: listing.updatedAt,
      completedAt: Value(listing.completedAt),
    );
  }
}
