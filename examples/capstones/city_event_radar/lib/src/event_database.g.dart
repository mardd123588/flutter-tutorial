// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'event_database.dart';

// ignore_for_file: type=lint
class $SavedEventsTable extends SavedEvents
    with TableInfo<$SavedEventsTable, SavedEvent> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SavedEventsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _eventIdMeta = const VerificationMeta(
    'eventId',
  );
  @override
  late final GeneratedColumn<String> eventId = GeneratedColumn<String>(
    'event_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _savedAtMeta = const VerificationMeta(
    'savedAt',
  );
  @override
  late final GeneratedColumn<DateTime> savedAt = GeneratedColumn<DateTime>(
    'saved_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [eventId, title, savedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'saved_events';
  @override
  VerificationContext validateIntegrity(
    Insertable<SavedEvent> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('event_id')) {
      context.handle(
        _eventIdMeta,
        eventId.isAcceptableOrUnknown(data['event_id']!, _eventIdMeta),
      );
    } else if (isInserting) {
      context.missing(_eventIdMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('saved_at')) {
      context.handle(
        _savedAtMeta,
        savedAt.isAcceptableOrUnknown(data['saved_at']!, _savedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {eventId};
  @override
  SavedEvent map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SavedEvent(
      eventId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}event_id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      savedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}saved_at'],
      ),
    );
  }

  @override
  $SavedEventsTable createAlias(String alias) {
    return $SavedEventsTable(attachedDatabase, alias);
  }
}

class SavedEvent extends DataClass implements Insertable<SavedEvent> {
  final String eventId;
  final String title;
  final DateTime? savedAt;
  const SavedEvent({required this.eventId, required this.title, this.savedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['event_id'] = Variable<String>(eventId);
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || savedAt != null) {
      map['saved_at'] = Variable<DateTime>(savedAt);
    }
    return map;
  }

  SavedEventsCompanion toCompanion(bool nullToAbsent) {
    return SavedEventsCompanion(
      eventId: Value(eventId),
      title: Value(title),
      savedAt: savedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(savedAt),
    );
  }

  factory SavedEvent.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SavedEvent(
      eventId: serializer.fromJson<String>(json['eventId']),
      title: serializer.fromJson<String>(json['title']),
      savedAt: serializer.fromJson<DateTime?>(json['savedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'eventId': serializer.toJson<String>(eventId),
      'title': serializer.toJson<String>(title),
      'savedAt': serializer.toJson<DateTime?>(savedAt),
    };
  }

  SavedEvent copyWith({
    String? eventId,
    String? title,
    Value<DateTime?> savedAt = const Value.absent(),
  }) => SavedEvent(
    eventId: eventId ?? this.eventId,
    title: title ?? this.title,
    savedAt: savedAt.present ? savedAt.value : this.savedAt,
  );
  SavedEvent copyWithCompanion(SavedEventsCompanion data) {
    return SavedEvent(
      eventId: data.eventId.present ? data.eventId.value : this.eventId,
      title: data.title.present ? data.title.value : this.title,
      savedAt: data.savedAt.present ? data.savedAt.value : this.savedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SavedEvent(')
          ..write('eventId: $eventId, ')
          ..write('title: $title, ')
          ..write('savedAt: $savedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(eventId, title, savedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SavedEvent &&
          other.eventId == this.eventId &&
          other.title == this.title &&
          other.savedAt == this.savedAt);
}

class SavedEventsCompanion extends UpdateCompanion<SavedEvent> {
  final Value<String> eventId;
  final Value<String> title;
  final Value<DateTime?> savedAt;
  final Value<int> rowid;
  const SavedEventsCompanion({
    this.eventId = const Value.absent(),
    this.title = const Value.absent(),
    this.savedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SavedEventsCompanion.insert({
    required String eventId,
    required String title,
    this.savedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : eventId = Value(eventId),
       title = Value(title);
  static Insertable<SavedEvent> custom({
    Expression<String>? eventId,
    Expression<String>? title,
    Expression<DateTime>? savedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (eventId != null) 'event_id': eventId,
      if (title != null) 'title': title,
      if (savedAt != null) 'saved_at': savedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SavedEventsCompanion copyWith({
    Value<String>? eventId,
    Value<String>? title,
    Value<DateTime?>? savedAt,
    Value<int>? rowid,
  }) {
    return SavedEventsCompanion(
      eventId: eventId ?? this.eventId,
      title: title ?? this.title,
      savedAt: savedAt ?? this.savedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (eventId.present) {
      map['event_id'] = Variable<String>(eventId.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (savedAt.present) {
      map['saved_at'] = Variable<DateTime>(savedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SavedEventsCompanion(')
          ..write('eventId: $eventId, ')
          ..write('title: $title, ')
          ..write('savedAt: $savedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SavedEventTagsTable extends SavedEventTags
    with TableInfo<$SavedEventTagsTable, SavedEventTag> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SavedEventTagsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _eventIdMeta = const VerificationMeta(
    'eventId',
  );
  @override
  late final GeneratedColumn<String> eventId = GeneratedColumn<String>(
    'event_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _tagMeta = const VerificationMeta('tag');
  @override
  late final GeneratedColumn<String> tag = GeneratedColumn<String>(
    'tag',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [eventId, tag];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'saved_event_tags';
  @override
  VerificationContext validateIntegrity(
    Insertable<SavedEventTag> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('event_id')) {
      context.handle(
        _eventIdMeta,
        eventId.isAcceptableOrUnknown(data['event_id']!, _eventIdMeta),
      );
    } else if (isInserting) {
      context.missing(_eventIdMeta);
    }
    if (data.containsKey('tag')) {
      context.handle(
        _tagMeta,
        tag.isAcceptableOrUnknown(data['tag']!, _tagMeta),
      );
    } else if (isInserting) {
      context.missing(_tagMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {eventId, tag};
  @override
  SavedEventTag map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SavedEventTag(
      eventId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}event_id'],
      )!,
      tag: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tag'],
      )!,
    );
  }

  @override
  $SavedEventTagsTable createAlias(String alias) {
    return $SavedEventTagsTable(attachedDatabase, alias);
  }
}

class SavedEventTag extends DataClass implements Insertable<SavedEventTag> {
  final String eventId;
  final String tag;
  const SavedEventTag({required this.eventId, required this.tag});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['event_id'] = Variable<String>(eventId);
    map['tag'] = Variable<String>(tag);
    return map;
  }

  SavedEventTagsCompanion toCompanion(bool nullToAbsent) {
    return SavedEventTagsCompanion(eventId: Value(eventId), tag: Value(tag));
  }

  factory SavedEventTag.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SavedEventTag(
      eventId: serializer.fromJson<String>(json['eventId']),
      tag: serializer.fromJson<String>(json['tag']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'eventId': serializer.toJson<String>(eventId),
      'tag': serializer.toJson<String>(tag),
    };
  }

  SavedEventTag copyWith({String? eventId, String? tag}) =>
      SavedEventTag(eventId: eventId ?? this.eventId, tag: tag ?? this.tag);
  SavedEventTag copyWithCompanion(SavedEventTagsCompanion data) {
    return SavedEventTag(
      eventId: data.eventId.present ? data.eventId.value : this.eventId,
      tag: data.tag.present ? data.tag.value : this.tag,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SavedEventTag(')
          ..write('eventId: $eventId, ')
          ..write('tag: $tag')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(eventId, tag);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SavedEventTag &&
          other.eventId == this.eventId &&
          other.tag == this.tag);
}

class SavedEventTagsCompanion extends UpdateCompanion<SavedEventTag> {
  final Value<String> eventId;
  final Value<String> tag;
  final Value<int> rowid;
  const SavedEventTagsCompanion({
    this.eventId = const Value.absent(),
    this.tag = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SavedEventTagsCompanion.insert({
    required String eventId,
    required String tag,
    this.rowid = const Value.absent(),
  }) : eventId = Value(eventId),
       tag = Value(tag);
  static Insertable<SavedEventTag> custom({
    Expression<String>? eventId,
    Expression<String>? tag,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (eventId != null) 'event_id': eventId,
      if (tag != null) 'tag': tag,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SavedEventTagsCompanion copyWith({
    Value<String>? eventId,
    Value<String>? tag,
    Value<int>? rowid,
  }) {
    return SavedEventTagsCompanion(
      eventId: eventId ?? this.eventId,
      tag: tag ?? this.tag,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (eventId.present) {
      map['event_id'] = Variable<String>(eventId.value);
    }
    if (tag.present) {
      map['tag'] = Variable<String>(tag.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SavedEventTagsCompanion(')
          ..write('eventId: $eventId, ')
          ..write('tag: $tag, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $EventCachesTable extends EventCaches
    with TableInfo<$EventCachesTable, EventCache> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $EventCachesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _cacheKeyMeta = const VerificationMeta(
    'cacheKey',
  );
  @override
  late final GeneratedColumn<String> cacheKey = GeneratedColumn<String>(
    'cache_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _rawJsonMeta = const VerificationMeta(
    'rawJson',
  );
  @override
  late final GeneratedColumn<String> rawJson = GeneratedColumn<String>(
    'raw_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _savedAtMeta = const VerificationMeta(
    'savedAt',
  );
  @override
  late final GeneratedColumn<DateTime> savedAt = GeneratedColumn<DateTime>(
    'saved_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [cacheKey, rawJson, savedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'event_caches';
  @override
  VerificationContext validateIntegrity(
    Insertable<EventCache> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('cache_key')) {
      context.handle(
        _cacheKeyMeta,
        cacheKey.isAcceptableOrUnknown(data['cache_key']!, _cacheKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_cacheKeyMeta);
    }
    if (data.containsKey('raw_json')) {
      context.handle(
        _rawJsonMeta,
        rawJson.isAcceptableOrUnknown(data['raw_json']!, _rawJsonMeta),
      );
    } else if (isInserting) {
      context.missing(_rawJsonMeta);
    }
    if (data.containsKey('saved_at')) {
      context.handle(
        _savedAtMeta,
        savedAt.isAcceptableOrUnknown(data['saved_at']!, _savedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_savedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {cacheKey};
  @override
  EventCache map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return EventCache(
      cacheKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cache_key'],
      )!,
      rawJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}raw_json'],
      )!,
      savedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}saved_at'],
      )!,
    );
  }

  @override
  $EventCachesTable createAlias(String alias) {
    return $EventCachesTable(attachedDatabase, alias);
  }
}

class EventCache extends DataClass implements Insertable<EventCache> {
  final String cacheKey;
  final String rawJson;
  final DateTime savedAt;
  const EventCache({
    required this.cacheKey,
    required this.rawJson,
    required this.savedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['cache_key'] = Variable<String>(cacheKey);
    map['raw_json'] = Variable<String>(rawJson);
    map['saved_at'] = Variable<DateTime>(savedAt);
    return map;
  }

  EventCachesCompanion toCompanion(bool nullToAbsent) {
    return EventCachesCompanion(
      cacheKey: Value(cacheKey),
      rawJson: Value(rawJson),
      savedAt: Value(savedAt),
    );
  }

  factory EventCache.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return EventCache(
      cacheKey: serializer.fromJson<String>(json['cacheKey']),
      rawJson: serializer.fromJson<String>(json['rawJson']),
      savedAt: serializer.fromJson<DateTime>(json['savedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'cacheKey': serializer.toJson<String>(cacheKey),
      'rawJson': serializer.toJson<String>(rawJson),
      'savedAt': serializer.toJson<DateTime>(savedAt),
    };
  }

  EventCache copyWith({String? cacheKey, String? rawJson, DateTime? savedAt}) =>
      EventCache(
        cacheKey: cacheKey ?? this.cacheKey,
        rawJson: rawJson ?? this.rawJson,
        savedAt: savedAt ?? this.savedAt,
      );
  EventCache copyWithCompanion(EventCachesCompanion data) {
    return EventCache(
      cacheKey: data.cacheKey.present ? data.cacheKey.value : this.cacheKey,
      rawJson: data.rawJson.present ? data.rawJson.value : this.rawJson,
      savedAt: data.savedAt.present ? data.savedAt.value : this.savedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('EventCache(')
          ..write('cacheKey: $cacheKey, ')
          ..write('rawJson: $rawJson, ')
          ..write('savedAt: $savedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(cacheKey, rawJson, savedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is EventCache &&
          other.cacheKey == this.cacheKey &&
          other.rawJson == this.rawJson &&
          other.savedAt == this.savedAt);
}

class EventCachesCompanion extends UpdateCompanion<EventCache> {
  final Value<String> cacheKey;
  final Value<String> rawJson;
  final Value<DateTime> savedAt;
  final Value<int> rowid;
  const EventCachesCompanion({
    this.cacheKey = const Value.absent(),
    this.rawJson = const Value.absent(),
    this.savedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  EventCachesCompanion.insert({
    required String cacheKey,
    required String rawJson,
    required DateTime savedAt,
    this.rowid = const Value.absent(),
  }) : cacheKey = Value(cacheKey),
       rawJson = Value(rawJson),
       savedAt = Value(savedAt);
  static Insertable<EventCache> custom({
    Expression<String>? cacheKey,
    Expression<String>? rawJson,
    Expression<DateTime>? savedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (cacheKey != null) 'cache_key': cacheKey,
      if (rawJson != null) 'raw_json': rawJson,
      if (savedAt != null) 'saved_at': savedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  EventCachesCompanion copyWith({
    Value<String>? cacheKey,
    Value<String>? rawJson,
    Value<DateTime>? savedAt,
    Value<int>? rowid,
  }) {
    return EventCachesCompanion(
      cacheKey: cacheKey ?? this.cacheKey,
      rawJson: rawJson ?? this.rawJson,
      savedAt: savedAt ?? this.savedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (cacheKey.present) {
      map['cache_key'] = Variable<String>(cacheKey.value);
    }
    if (rawJson.present) {
      map['raw_json'] = Variable<String>(rawJson.value);
    }
    if (savedAt.present) {
      map['saved_at'] = Variable<DateTime>(savedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('EventCachesCompanion(')
          ..write('cacheKey: $cacheKey, ')
          ..write('rawJson: $rawJson, ')
          ..write('savedAt: $savedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$EventDatabase extends GeneratedDatabase {
  _$EventDatabase(QueryExecutor e) : super(e);
  $EventDatabaseManager get managers => $EventDatabaseManager(this);
  late final $SavedEventsTable savedEvents = $SavedEventsTable(this);
  late final $SavedEventTagsTable savedEventTags = $SavedEventTagsTable(this);
  late final $EventCachesTable eventCaches = $EventCachesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    savedEvents,
    savedEventTags,
    eventCaches,
  ];
}

typedef $$SavedEventsTableCreateCompanionBuilder =
    SavedEventsCompanion Function({
      required String eventId,
      required String title,
      Value<DateTime?> savedAt,
      Value<int> rowid,
    });
typedef $$SavedEventsTableUpdateCompanionBuilder =
    SavedEventsCompanion Function({
      Value<String> eventId,
      Value<String> title,
      Value<DateTime?> savedAt,
      Value<int> rowid,
    });

class $$SavedEventsTableFilterComposer
    extends Composer<_$EventDatabase, $SavedEventsTable> {
  $$SavedEventsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get eventId => $composableBuilder(
    column: $table.eventId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get savedAt => $composableBuilder(
    column: $table.savedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SavedEventsTableOrderingComposer
    extends Composer<_$EventDatabase, $SavedEventsTable> {
  $$SavedEventsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get eventId => $composableBuilder(
    column: $table.eventId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get savedAt => $composableBuilder(
    column: $table.savedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SavedEventsTableAnnotationComposer
    extends Composer<_$EventDatabase, $SavedEventsTable> {
  $$SavedEventsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get eventId =>
      $composableBuilder(column: $table.eventId, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<DateTime> get savedAt =>
      $composableBuilder(column: $table.savedAt, builder: (column) => column);
}

class $$SavedEventsTableTableManager
    extends
        RootTableManager<
          _$EventDatabase,
          $SavedEventsTable,
          SavedEvent,
          $$SavedEventsTableFilterComposer,
          $$SavedEventsTableOrderingComposer,
          $$SavedEventsTableAnnotationComposer,
          $$SavedEventsTableCreateCompanionBuilder,
          $$SavedEventsTableUpdateCompanionBuilder,
          (
            SavedEvent,
            BaseReferences<_$EventDatabase, $SavedEventsTable, SavedEvent>,
          ),
          SavedEvent,
          PrefetchHooks Function()
        > {
  $$SavedEventsTableTableManager(_$EventDatabase db, $SavedEventsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SavedEventsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SavedEventsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SavedEventsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> eventId = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<DateTime?> savedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SavedEventsCompanion(
                eventId: eventId,
                title: title,
                savedAt: savedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String eventId,
                required String title,
                Value<DateTime?> savedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SavedEventsCompanion.insert(
                eventId: eventId,
                title: title,
                savedAt: savedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SavedEventsTableProcessedTableManager =
    ProcessedTableManager<
      _$EventDatabase,
      $SavedEventsTable,
      SavedEvent,
      $$SavedEventsTableFilterComposer,
      $$SavedEventsTableOrderingComposer,
      $$SavedEventsTableAnnotationComposer,
      $$SavedEventsTableCreateCompanionBuilder,
      $$SavedEventsTableUpdateCompanionBuilder,
      (
        SavedEvent,
        BaseReferences<_$EventDatabase, $SavedEventsTable, SavedEvent>,
      ),
      SavedEvent,
      PrefetchHooks Function()
    >;
typedef $$SavedEventTagsTableCreateCompanionBuilder =
    SavedEventTagsCompanion Function({
      required String eventId,
      required String tag,
      Value<int> rowid,
    });
typedef $$SavedEventTagsTableUpdateCompanionBuilder =
    SavedEventTagsCompanion Function({
      Value<String> eventId,
      Value<String> tag,
      Value<int> rowid,
    });

class $$SavedEventTagsTableFilterComposer
    extends Composer<_$EventDatabase, $SavedEventTagsTable> {
  $$SavedEventTagsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get eventId => $composableBuilder(
    column: $table.eventId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tag => $composableBuilder(
    column: $table.tag,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SavedEventTagsTableOrderingComposer
    extends Composer<_$EventDatabase, $SavedEventTagsTable> {
  $$SavedEventTagsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get eventId => $composableBuilder(
    column: $table.eventId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tag => $composableBuilder(
    column: $table.tag,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SavedEventTagsTableAnnotationComposer
    extends Composer<_$EventDatabase, $SavedEventTagsTable> {
  $$SavedEventTagsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get eventId =>
      $composableBuilder(column: $table.eventId, builder: (column) => column);

  GeneratedColumn<String> get tag =>
      $composableBuilder(column: $table.tag, builder: (column) => column);
}

class $$SavedEventTagsTableTableManager
    extends
        RootTableManager<
          _$EventDatabase,
          $SavedEventTagsTable,
          SavedEventTag,
          $$SavedEventTagsTableFilterComposer,
          $$SavedEventTagsTableOrderingComposer,
          $$SavedEventTagsTableAnnotationComposer,
          $$SavedEventTagsTableCreateCompanionBuilder,
          $$SavedEventTagsTableUpdateCompanionBuilder,
          (
            SavedEventTag,
            BaseReferences<
              _$EventDatabase,
              $SavedEventTagsTable,
              SavedEventTag
            >,
          ),
          SavedEventTag,
          PrefetchHooks Function()
        > {
  $$SavedEventTagsTableTableManager(
    _$EventDatabase db,
    $SavedEventTagsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SavedEventTagsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SavedEventTagsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SavedEventTagsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> eventId = const Value.absent(),
                Value<String> tag = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SavedEventTagsCompanion(
                eventId: eventId,
                tag: tag,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String eventId,
                required String tag,
                Value<int> rowid = const Value.absent(),
              }) => SavedEventTagsCompanion.insert(
                eventId: eventId,
                tag: tag,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SavedEventTagsTableProcessedTableManager =
    ProcessedTableManager<
      _$EventDatabase,
      $SavedEventTagsTable,
      SavedEventTag,
      $$SavedEventTagsTableFilterComposer,
      $$SavedEventTagsTableOrderingComposer,
      $$SavedEventTagsTableAnnotationComposer,
      $$SavedEventTagsTableCreateCompanionBuilder,
      $$SavedEventTagsTableUpdateCompanionBuilder,
      (
        SavedEventTag,
        BaseReferences<_$EventDatabase, $SavedEventTagsTable, SavedEventTag>,
      ),
      SavedEventTag,
      PrefetchHooks Function()
    >;
typedef $$EventCachesTableCreateCompanionBuilder =
    EventCachesCompanion Function({
      required String cacheKey,
      required String rawJson,
      required DateTime savedAt,
      Value<int> rowid,
    });
typedef $$EventCachesTableUpdateCompanionBuilder =
    EventCachesCompanion Function({
      Value<String> cacheKey,
      Value<String> rawJson,
      Value<DateTime> savedAt,
      Value<int> rowid,
    });

class $$EventCachesTableFilterComposer
    extends Composer<_$EventDatabase, $EventCachesTable> {
  $$EventCachesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get cacheKey => $composableBuilder(
    column: $table.cacheKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get rawJson => $composableBuilder(
    column: $table.rawJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get savedAt => $composableBuilder(
    column: $table.savedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$EventCachesTableOrderingComposer
    extends Composer<_$EventDatabase, $EventCachesTable> {
  $$EventCachesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get cacheKey => $composableBuilder(
    column: $table.cacheKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get rawJson => $composableBuilder(
    column: $table.rawJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get savedAt => $composableBuilder(
    column: $table.savedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$EventCachesTableAnnotationComposer
    extends Composer<_$EventDatabase, $EventCachesTable> {
  $$EventCachesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get cacheKey =>
      $composableBuilder(column: $table.cacheKey, builder: (column) => column);

  GeneratedColumn<String> get rawJson =>
      $composableBuilder(column: $table.rawJson, builder: (column) => column);

  GeneratedColumn<DateTime> get savedAt =>
      $composableBuilder(column: $table.savedAt, builder: (column) => column);
}

class $$EventCachesTableTableManager
    extends
        RootTableManager<
          _$EventDatabase,
          $EventCachesTable,
          EventCache,
          $$EventCachesTableFilterComposer,
          $$EventCachesTableOrderingComposer,
          $$EventCachesTableAnnotationComposer,
          $$EventCachesTableCreateCompanionBuilder,
          $$EventCachesTableUpdateCompanionBuilder,
          (
            EventCache,
            BaseReferences<_$EventDatabase, $EventCachesTable, EventCache>,
          ),
          EventCache,
          PrefetchHooks Function()
        > {
  $$EventCachesTableTableManager(_$EventDatabase db, $EventCachesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$EventCachesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$EventCachesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$EventCachesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> cacheKey = const Value.absent(),
                Value<String> rawJson = const Value.absent(),
                Value<DateTime> savedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => EventCachesCompanion(
                cacheKey: cacheKey,
                rawJson: rawJson,
                savedAt: savedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String cacheKey,
                required String rawJson,
                required DateTime savedAt,
                Value<int> rowid = const Value.absent(),
              }) => EventCachesCompanion.insert(
                cacheKey: cacheKey,
                rawJson: rawJson,
                savedAt: savedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$EventCachesTableProcessedTableManager =
    ProcessedTableManager<
      _$EventDatabase,
      $EventCachesTable,
      EventCache,
      $$EventCachesTableFilterComposer,
      $$EventCachesTableOrderingComposer,
      $$EventCachesTableAnnotationComposer,
      $$EventCachesTableCreateCompanionBuilder,
      $$EventCachesTableUpdateCompanionBuilder,
      (
        EventCache,
        BaseReferences<_$EventDatabase, $EventCachesTable, EventCache>,
      ),
      EventCache,
      PrefetchHooks Function()
    >;

class $EventDatabaseManager {
  final _$EventDatabase _db;
  $EventDatabaseManager(this._db);
  $$SavedEventsTableTableManager get savedEvents =>
      $$SavedEventsTableTableManager(_db, _db.savedEvents);
  $$SavedEventTagsTableTableManager get savedEventTags =>
      $$SavedEventTagsTableTableManager(_db, _db.savedEventTags);
  $$EventCachesTableTableManager get eventCaches =>
      $$EventCachesTableTableManager(_db, _db.eventCaches);
}
