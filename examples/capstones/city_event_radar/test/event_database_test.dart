import 'dart:io';

import 'package:city_event_radar/src/event.dart';
import 'package:city_event_radar/src/event_cache.dart';
import 'package:city_event_radar/src/event_database.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite3/sqlite3.dart' as sqlite;

void main() {
  test(
    'toggleSaved updates the watched relation inside one transaction',
    () async {
      final database = EventDatabase(NativeDatabase.memory());
      addTearDown(database.close);
      final values = <Set<String>>[];
      final subscription = database.watchSavedIds().listen(values.add);
      addTearDown(subscription.cancel);

      await pumpEventQueue();
      await database.toggleSaved(sampleEvent);
      await pumpEventQueue();

      expect(values.last, contains(sampleEvent.id));
      final tags = await database.select(database.savedEventTags).get();
      expect(tags.map((row) => row.tag), containsAll(sampleEvent.tags));

      await database.toggleSaved(sampleEvent);
      await pumpEventQueue();

      expect(values.last, isEmpty);
      expect(await database.select(database.savedEventTags).get(), isEmpty);

      final cache = CachedEventFeed(
        rawJson: '{"events":[]}',
        savedAt: DateTime(2026, 8, 30, 10),
      );
      await database.writeCache(cache);
      expect((await database.readCache())?.savedAt, cache.savedAt);
    },
  );

  test(
    'migrates a version 1 database and preserves existing favorites',
    () async {
      final directory = await Directory.systemTemp.createTemp(
        'radar-migration-',
      );
      addTearDown(() => directory.delete(recursive: true));
      final file = File(
        '${directory.path}${Platform.pathSeparator}radar.sqlite',
      );
      final legacy = sqlite.sqlite3.open(file.path);
      legacy.execute('''
      CREATE TABLE saved_events (
        event_id TEXT NOT NULL PRIMARY KEY,
        title TEXT NOT NULL
      );
    ''');
      legacy.execute(
        "INSERT INTO saved_events (event_id, title) VALUES ('legacy', '旧记录')",
      );
      legacy.execute('PRAGMA user_version = 1;');
      legacy.close();

      final database = EventDatabase(NativeDatabase(file));
      addTearDown(database.close);
      final rows = await database.select(database.savedEvents).get();
      final columns = await database
          .customSelect('PRAGMA table_info(saved_events)')
          .get();

      expect(rows.single.eventId, 'legacy');
      expect(
        columns.map((row) => row.read<String>('name')),
        contains('saved_at'),
      );
      expect(
        await database.customSelect('SELECT * FROM saved_event_tags').get(),
        isEmpty,
      );
      expect(
        await database.customSelect('SELECT * FROM event_caches').get(),
        isEmpty,
      );
    },
  );
}

final sampleEvent = CityEvent(
  id: 'event-1',
  title: '河岸听觉散步',
  venue: '东岸旧泵站',
  district: '东岸',
  startsAt: DateTime(2026, 9, 5, 18, 30),
  priceLabel: '预约免费',
  summary: '教学记录',
  tags: ['步行', '声音'],
  signal: 86,
);
