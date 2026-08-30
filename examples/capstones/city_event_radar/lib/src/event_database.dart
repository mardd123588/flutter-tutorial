import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import 'event.dart';
import 'event_cache.dart';
import 'event_local_store.dart';

part 'event_database.g.dart';

// #region drift-tables
class SavedEvents extends Table {
  TextColumn get eventId => text()();
  TextColumn get title => text()();
  DateTimeColumn get savedAt => dateTime().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {eventId};
}

class SavedEventTags extends Table {
  TextColumn get eventId => text()();
  TextColumn get tag => text()();

  @override
  Set<Column<Object>> get primaryKey => {eventId, tag};
}

class EventCaches extends Table {
  TextColumn get cacheKey => text()();
  TextColumn get rawJson => text()();
  DateTimeColumn get savedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {cacheKey};
}
// #endregion drift-tables

@DriftDatabase(tables: [SavedEvents, SavedEventTags, EventCaches])
class EventDatabase extends _$EventDatabase implements EventLocalStore {
  EventDatabase(super.executor);

  EventDatabase.defaults()
    : super(
        driftDatabase(
          name: 'city_event_radar',
          web: DriftWebOptions(
            sqlite3Wasm: Uri.parse('sqlite3.wasm'),
            driftWorker: Uri.parse('drift_worker.js'),
          ),
        ),
      );

  @override
  int get schemaVersion => 2;

  // #region drift-migration
  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (migrator) => migrator.createAll(),
      onUpgrade: (migrator, from, to) async {
        if (from < 2) {
          await migrator.addColumn(savedEvents, savedEvents.savedAt);
          await migrator.createTable(savedEventTags);
          await migrator.createTable(eventCaches);
        }
      },
    );
  }
  // #endregion drift-migration

  // #region drift-watch-and-transaction
  @override
  Stream<Set<String>> watchSavedIds() {
    return select(savedEvents)
        .watch()
        .map((rows) => rows.map((row) => row.eventId).toSet());
  }

  @override
  Future<void> toggleSaved(CityEvent event) {
    return transaction(() async {
      final existing = await (select(
        savedEvents,
      )..where((row) => row.eventId.equals(event.id))).getSingleOrNull();
      if (existing == null) {
        await into(savedEvents).insert(
          SavedEventsCompanion.insert(
            eventId: event.id,
            title: event.title,
            savedAt: Value(DateTime.now()),
          ),
        );
        await batch((batch) {
          batch.insertAll(
            savedEventTags,
            event.tags
                .map(
                  (tag) => SavedEventTagsCompanion.insert(
                    eventId: event.id,
                    tag: tag,
                  ),
                )
                .toList(growable: false),
          );
        });
      } else {
        await (delete(
          savedEventTags,
        )..where((row) => row.eventId.equals(event.id))).go();
        await (delete(
          savedEvents,
        )..where((row) => row.eventId.equals(event.id))).go();
      }
    });
  }
  // #endregion drift-watch-and-transaction

  // #region drift-cache
  @override
  Future<CachedEventFeed?> readCache() async {
    final row = await (select(
      eventCaches,
    )..where((cache) => cache.cacheKey.equals('event-feed'))).getSingleOrNull();
    if (row == null) return null;
    return CachedEventFeed(rawJson: row.rawJson, savedAt: row.savedAt);
  }

  @override
  Future<void> writeCache(CachedEventFeed value) {
    return into(eventCaches).insertOnConflictUpdate(
      EventCachesCompanion.insert(
        cacheKey: 'event-feed',
        rawJson: value.rawJson,
        savedAt: value.savedAt,
      ),
    );
  }
  // #endregion drift-cache
}
