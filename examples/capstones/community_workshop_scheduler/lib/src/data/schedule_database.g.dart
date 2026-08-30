// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'schedule_database.dart';

// ignore_for_file: type=lint
class $ScheduleRecordsTable extends ScheduleRecords
    with TableInfo<$ScheduleRecordsTable, ScheduleRecord> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ScheduleRecordsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _entryIdMeta = const VerificationMeta(
    'entryId',
  );
  @override
  late final GeneratedColumn<String> entryId = GeneratedColumn<String>(
    'entry_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _workshopIdMeta = const VerificationMeta(
    'workshopId',
  );
  @override
  late final GeneratedColumn<String> workshopId = GeneratedColumn<String>(
    'workshop_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _instructorIdMeta = const VerificationMeta(
    'instructorId',
  );
  @override
  late final GeneratedColumn<String> instructorId = GeneratedColumn<String>(
    'instructor_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _venueIdMeta = const VerificationMeta(
    'venueId',
  );
  @override
  late final GeneratedColumn<String> venueId = GeneratedColumn<String>(
    'venue_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dayIdMeta = const VerificationMeta('dayId');
  @override
  late final GeneratedColumn<String> dayId = GeneratedColumn<String>(
    'day_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _startMinuteMeta = const VerificationMeta(
    'startMinute',
  );
  @override
  late final GeneratedColumn<int> startMinute = GeneratedColumn<int>(
    'start_minute',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _endMinuteMeta = const VerificationMeta(
    'endMinute',
  );
  @override
  late final GeneratedColumn<int> endMinute = GeneratedColumn<int>(
    'end_minute',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _expectedAttendeesMeta = const VerificationMeta(
    'expectedAttendees',
  );
  @override
  late final GeneratedColumn<int> expectedAttendees = GeneratedColumn<int>(
    'expected_attendees',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    entryId,
    workshopId,
    instructorId,
    venueId,
    dayId,
    startMinute,
    endMinute,
    expectedAttendees,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'schedule_records';
  @override
  VerificationContext validateIntegrity(
    Insertable<ScheduleRecord> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('entry_id')) {
      context.handle(
        _entryIdMeta,
        entryId.isAcceptableOrUnknown(data['entry_id']!, _entryIdMeta),
      );
    } else if (isInserting) {
      context.missing(_entryIdMeta);
    }
    if (data.containsKey('workshop_id')) {
      context.handle(
        _workshopIdMeta,
        workshopId.isAcceptableOrUnknown(data['workshop_id']!, _workshopIdMeta),
      );
    } else if (isInserting) {
      context.missing(_workshopIdMeta);
    }
    if (data.containsKey('instructor_id')) {
      context.handle(
        _instructorIdMeta,
        instructorId.isAcceptableOrUnknown(
          data['instructor_id']!,
          _instructorIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_instructorIdMeta);
    }
    if (data.containsKey('venue_id')) {
      context.handle(
        _venueIdMeta,
        venueId.isAcceptableOrUnknown(data['venue_id']!, _venueIdMeta),
      );
    } else if (isInserting) {
      context.missing(_venueIdMeta);
    }
    if (data.containsKey('day_id')) {
      context.handle(
        _dayIdMeta,
        dayId.isAcceptableOrUnknown(data['day_id']!, _dayIdMeta),
      );
    } else if (isInserting) {
      context.missing(_dayIdMeta);
    }
    if (data.containsKey('start_minute')) {
      context.handle(
        _startMinuteMeta,
        startMinute.isAcceptableOrUnknown(
          data['start_minute']!,
          _startMinuteMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_startMinuteMeta);
    }
    if (data.containsKey('end_minute')) {
      context.handle(
        _endMinuteMeta,
        endMinute.isAcceptableOrUnknown(data['end_minute']!, _endMinuteMeta),
      );
    } else if (isInserting) {
      context.missing(_endMinuteMeta);
    }
    if (data.containsKey('expected_attendees')) {
      context.handle(
        _expectedAttendeesMeta,
        expectedAttendees.isAcceptableOrUnknown(
          data['expected_attendees']!,
          _expectedAttendeesMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_expectedAttendeesMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {entryId};
  @override
  ScheduleRecord map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ScheduleRecord(
      entryId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entry_id'],
      )!,
      workshopId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}workshop_id'],
      )!,
      instructorId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}instructor_id'],
      )!,
      venueId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}venue_id'],
      )!,
      dayId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}day_id'],
      )!,
      startMinute: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}start_minute'],
      )!,
      endMinute: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}end_minute'],
      )!,
      expectedAttendees: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}expected_attendees'],
      )!,
    );
  }

  @override
  $ScheduleRecordsTable createAlias(String alias) {
    return $ScheduleRecordsTable(attachedDatabase, alias);
  }
}

class ScheduleRecord extends DataClass implements Insertable<ScheduleRecord> {
  final String entryId;
  final String workshopId;
  final String instructorId;
  final String venueId;
  final String dayId;
  final int startMinute;
  final int endMinute;
  final int expectedAttendees;
  const ScheduleRecord({
    required this.entryId,
    required this.workshopId,
    required this.instructorId,
    required this.venueId,
    required this.dayId,
    required this.startMinute,
    required this.endMinute,
    required this.expectedAttendees,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['entry_id'] = Variable<String>(entryId);
    map['workshop_id'] = Variable<String>(workshopId);
    map['instructor_id'] = Variable<String>(instructorId);
    map['venue_id'] = Variable<String>(venueId);
    map['day_id'] = Variable<String>(dayId);
    map['start_minute'] = Variable<int>(startMinute);
    map['end_minute'] = Variable<int>(endMinute);
    map['expected_attendees'] = Variable<int>(expectedAttendees);
    return map;
  }

  ScheduleRecordsCompanion toCompanion(bool nullToAbsent) {
    return ScheduleRecordsCompanion(
      entryId: Value(entryId),
      workshopId: Value(workshopId),
      instructorId: Value(instructorId),
      venueId: Value(venueId),
      dayId: Value(dayId),
      startMinute: Value(startMinute),
      endMinute: Value(endMinute),
      expectedAttendees: Value(expectedAttendees),
    );
  }

  factory ScheduleRecord.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ScheduleRecord(
      entryId: serializer.fromJson<String>(json['entryId']),
      workshopId: serializer.fromJson<String>(json['workshopId']),
      instructorId: serializer.fromJson<String>(json['instructorId']),
      venueId: serializer.fromJson<String>(json['venueId']),
      dayId: serializer.fromJson<String>(json['dayId']),
      startMinute: serializer.fromJson<int>(json['startMinute']),
      endMinute: serializer.fromJson<int>(json['endMinute']),
      expectedAttendees: serializer.fromJson<int>(json['expectedAttendees']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'entryId': serializer.toJson<String>(entryId),
      'workshopId': serializer.toJson<String>(workshopId),
      'instructorId': serializer.toJson<String>(instructorId),
      'venueId': serializer.toJson<String>(venueId),
      'dayId': serializer.toJson<String>(dayId),
      'startMinute': serializer.toJson<int>(startMinute),
      'endMinute': serializer.toJson<int>(endMinute),
      'expectedAttendees': serializer.toJson<int>(expectedAttendees),
    };
  }

  ScheduleRecord copyWith({
    String? entryId,
    String? workshopId,
    String? instructorId,
    String? venueId,
    String? dayId,
    int? startMinute,
    int? endMinute,
    int? expectedAttendees,
  }) => ScheduleRecord(
    entryId: entryId ?? this.entryId,
    workshopId: workshopId ?? this.workshopId,
    instructorId: instructorId ?? this.instructorId,
    venueId: venueId ?? this.venueId,
    dayId: dayId ?? this.dayId,
    startMinute: startMinute ?? this.startMinute,
    endMinute: endMinute ?? this.endMinute,
    expectedAttendees: expectedAttendees ?? this.expectedAttendees,
  );
  ScheduleRecord copyWithCompanion(ScheduleRecordsCompanion data) {
    return ScheduleRecord(
      entryId: data.entryId.present ? data.entryId.value : this.entryId,
      workshopId: data.workshopId.present
          ? data.workshopId.value
          : this.workshopId,
      instructorId: data.instructorId.present
          ? data.instructorId.value
          : this.instructorId,
      venueId: data.venueId.present ? data.venueId.value : this.venueId,
      dayId: data.dayId.present ? data.dayId.value : this.dayId,
      startMinute: data.startMinute.present
          ? data.startMinute.value
          : this.startMinute,
      endMinute: data.endMinute.present ? data.endMinute.value : this.endMinute,
      expectedAttendees: data.expectedAttendees.present
          ? data.expectedAttendees.value
          : this.expectedAttendees,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ScheduleRecord(')
          ..write('entryId: $entryId, ')
          ..write('workshopId: $workshopId, ')
          ..write('instructorId: $instructorId, ')
          ..write('venueId: $venueId, ')
          ..write('dayId: $dayId, ')
          ..write('startMinute: $startMinute, ')
          ..write('endMinute: $endMinute, ')
          ..write('expectedAttendees: $expectedAttendees')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    entryId,
    workshopId,
    instructorId,
    venueId,
    dayId,
    startMinute,
    endMinute,
    expectedAttendees,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ScheduleRecord &&
          other.entryId == this.entryId &&
          other.workshopId == this.workshopId &&
          other.instructorId == this.instructorId &&
          other.venueId == this.venueId &&
          other.dayId == this.dayId &&
          other.startMinute == this.startMinute &&
          other.endMinute == this.endMinute &&
          other.expectedAttendees == this.expectedAttendees);
}

class ScheduleRecordsCompanion extends UpdateCompanion<ScheduleRecord> {
  final Value<String> entryId;
  final Value<String> workshopId;
  final Value<String> instructorId;
  final Value<String> venueId;
  final Value<String> dayId;
  final Value<int> startMinute;
  final Value<int> endMinute;
  final Value<int> expectedAttendees;
  final Value<int> rowid;
  const ScheduleRecordsCompanion({
    this.entryId = const Value.absent(),
    this.workshopId = const Value.absent(),
    this.instructorId = const Value.absent(),
    this.venueId = const Value.absent(),
    this.dayId = const Value.absent(),
    this.startMinute = const Value.absent(),
    this.endMinute = const Value.absent(),
    this.expectedAttendees = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ScheduleRecordsCompanion.insert({
    required String entryId,
    required String workshopId,
    required String instructorId,
    required String venueId,
    required String dayId,
    required int startMinute,
    required int endMinute,
    required int expectedAttendees,
    this.rowid = const Value.absent(),
  }) : entryId = Value(entryId),
       workshopId = Value(workshopId),
       instructorId = Value(instructorId),
       venueId = Value(venueId),
       dayId = Value(dayId),
       startMinute = Value(startMinute),
       endMinute = Value(endMinute),
       expectedAttendees = Value(expectedAttendees);
  static Insertable<ScheduleRecord> custom({
    Expression<String>? entryId,
    Expression<String>? workshopId,
    Expression<String>? instructorId,
    Expression<String>? venueId,
    Expression<String>? dayId,
    Expression<int>? startMinute,
    Expression<int>? endMinute,
    Expression<int>? expectedAttendees,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (entryId != null) 'entry_id': entryId,
      if (workshopId != null) 'workshop_id': workshopId,
      if (instructorId != null) 'instructor_id': instructorId,
      if (venueId != null) 'venue_id': venueId,
      if (dayId != null) 'day_id': dayId,
      if (startMinute != null) 'start_minute': startMinute,
      if (endMinute != null) 'end_minute': endMinute,
      if (expectedAttendees != null) 'expected_attendees': expectedAttendees,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ScheduleRecordsCompanion copyWith({
    Value<String>? entryId,
    Value<String>? workshopId,
    Value<String>? instructorId,
    Value<String>? venueId,
    Value<String>? dayId,
    Value<int>? startMinute,
    Value<int>? endMinute,
    Value<int>? expectedAttendees,
    Value<int>? rowid,
  }) {
    return ScheduleRecordsCompanion(
      entryId: entryId ?? this.entryId,
      workshopId: workshopId ?? this.workshopId,
      instructorId: instructorId ?? this.instructorId,
      venueId: venueId ?? this.venueId,
      dayId: dayId ?? this.dayId,
      startMinute: startMinute ?? this.startMinute,
      endMinute: endMinute ?? this.endMinute,
      expectedAttendees: expectedAttendees ?? this.expectedAttendees,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (entryId.present) {
      map['entry_id'] = Variable<String>(entryId.value);
    }
    if (workshopId.present) {
      map['workshop_id'] = Variable<String>(workshopId.value);
    }
    if (instructorId.present) {
      map['instructor_id'] = Variable<String>(instructorId.value);
    }
    if (venueId.present) {
      map['venue_id'] = Variable<String>(venueId.value);
    }
    if (dayId.present) {
      map['day_id'] = Variable<String>(dayId.value);
    }
    if (startMinute.present) {
      map['start_minute'] = Variable<int>(startMinute.value);
    }
    if (endMinute.present) {
      map['end_minute'] = Variable<int>(endMinute.value);
    }
    if (expectedAttendees.present) {
      map['expected_attendees'] = Variable<int>(expectedAttendees.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ScheduleRecordsCompanion(')
          ..write('entryId: $entryId, ')
          ..write('workshopId: $workshopId, ')
          ..write('instructorId: $instructorId, ')
          ..write('venueId: $venueId, ')
          ..write('dayId: $dayId, ')
          ..write('startMinute: $startMinute, ')
          ..write('endMinute: $endMinute, ')
          ..write('expectedAttendees: $expectedAttendees, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ScheduleSettingsTable extends ScheduleSettings
    with TableInfo<$ScheduleSettingsTable, ScheduleSetting> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ScheduleSettingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _settingKeyMeta = const VerificationMeta(
    'settingKey',
  );
  @override
  late final GeneratedColumn<String> settingKey = GeneratedColumn<String>(
    'setting_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _settingValueMeta = const VerificationMeta(
    'settingValue',
  );
  @override
  late final GeneratedColumn<String> settingValue = GeneratedColumn<String>(
    'setting_value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [settingKey, settingValue];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'schedule_settings';
  @override
  VerificationContext validateIntegrity(
    Insertable<ScheduleSetting> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('setting_key')) {
      context.handle(
        _settingKeyMeta,
        settingKey.isAcceptableOrUnknown(data['setting_key']!, _settingKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_settingKeyMeta);
    }
    if (data.containsKey('setting_value')) {
      context.handle(
        _settingValueMeta,
        settingValue.isAcceptableOrUnknown(
          data['setting_value']!,
          _settingValueMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_settingValueMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {settingKey};
  @override
  ScheduleSetting map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ScheduleSetting(
      settingKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}setting_key'],
      )!,
      settingValue: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}setting_value'],
      )!,
    );
  }

  @override
  $ScheduleSettingsTable createAlias(String alias) {
    return $ScheduleSettingsTable(attachedDatabase, alias);
  }
}

class ScheduleSetting extends DataClass implements Insertable<ScheduleSetting> {
  final String settingKey;
  final String settingValue;
  const ScheduleSetting({required this.settingKey, required this.settingValue});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['setting_key'] = Variable<String>(settingKey);
    map['setting_value'] = Variable<String>(settingValue);
    return map;
  }

  ScheduleSettingsCompanion toCompanion(bool nullToAbsent) {
    return ScheduleSettingsCompanion(
      settingKey: Value(settingKey),
      settingValue: Value(settingValue),
    );
  }

  factory ScheduleSetting.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ScheduleSetting(
      settingKey: serializer.fromJson<String>(json['settingKey']),
      settingValue: serializer.fromJson<String>(json['settingValue']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'settingKey': serializer.toJson<String>(settingKey),
      'settingValue': serializer.toJson<String>(settingValue),
    };
  }

  ScheduleSetting copyWith({String? settingKey, String? settingValue}) =>
      ScheduleSetting(
        settingKey: settingKey ?? this.settingKey,
        settingValue: settingValue ?? this.settingValue,
      );
  ScheduleSetting copyWithCompanion(ScheduleSettingsCompanion data) {
    return ScheduleSetting(
      settingKey: data.settingKey.present
          ? data.settingKey.value
          : this.settingKey,
      settingValue: data.settingValue.present
          ? data.settingValue.value
          : this.settingValue,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ScheduleSetting(')
          ..write('settingKey: $settingKey, ')
          ..write('settingValue: $settingValue')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(settingKey, settingValue);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ScheduleSetting &&
          other.settingKey == this.settingKey &&
          other.settingValue == this.settingValue);
}

class ScheduleSettingsCompanion extends UpdateCompanion<ScheduleSetting> {
  final Value<String> settingKey;
  final Value<String> settingValue;
  final Value<int> rowid;
  const ScheduleSettingsCompanion({
    this.settingKey = const Value.absent(),
    this.settingValue = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ScheduleSettingsCompanion.insert({
    required String settingKey,
    required String settingValue,
    this.rowid = const Value.absent(),
  }) : settingKey = Value(settingKey),
       settingValue = Value(settingValue);
  static Insertable<ScheduleSetting> custom({
    Expression<String>? settingKey,
    Expression<String>? settingValue,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (settingKey != null) 'setting_key': settingKey,
      if (settingValue != null) 'setting_value': settingValue,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ScheduleSettingsCompanion copyWith({
    Value<String>? settingKey,
    Value<String>? settingValue,
    Value<int>? rowid,
  }) {
    return ScheduleSettingsCompanion(
      settingKey: settingKey ?? this.settingKey,
      settingValue: settingValue ?? this.settingValue,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (settingKey.present) {
      map['setting_key'] = Variable<String>(settingKey.value);
    }
    if (settingValue.present) {
      map['setting_value'] = Variable<String>(settingValue.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ScheduleSettingsCompanion(')
          ..write('settingKey: $settingKey, ')
          ..write('settingValue: $settingValue, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$ScheduleDatabase extends GeneratedDatabase {
  _$ScheduleDatabase(QueryExecutor e) : super(e);
  $ScheduleDatabaseManager get managers => $ScheduleDatabaseManager(this);
  late final $ScheduleRecordsTable scheduleRecords = $ScheduleRecordsTable(
    this,
  );
  late final $ScheduleSettingsTable scheduleSettings = $ScheduleSettingsTable(
    this,
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    scheduleRecords,
    scheduleSettings,
  ];
}

typedef $$ScheduleRecordsTableCreateCompanionBuilder =
    ScheduleRecordsCompanion Function({
      required String entryId,
      required String workshopId,
      required String instructorId,
      required String venueId,
      required String dayId,
      required int startMinute,
      required int endMinute,
      required int expectedAttendees,
      Value<int> rowid,
    });
typedef $$ScheduleRecordsTableUpdateCompanionBuilder =
    ScheduleRecordsCompanion Function({
      Value<String> entryId,
      Value<String> workshopId,
      Value<String> instructorId,
      Value<String> venueId,
      Value<String> dayId,
      Value<int> startMinute,
      Value<int> endMinute,
      Value<int> expectedAttendees,
      Value<int> rowid,
    });

class $$ScheduleRecordsTableFilterComposer
    extends Composer<_$ScheduleDatabase, $ScheduleRecordsTable> {
  $$ScheduleRecordsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get entryId => $composableBuilder(
    column: $table.entryId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get workshopId => $composableBuilder(
    column: $table.workshopId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get instructorId => $composableBuilder(
    column: $table.instructorId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get venueId => $composableBuilder(
    column: $table.venueId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get dayId => $composableBuilder(
    column: $table.dayId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get startMinute => $composableBuilder(
    column: $table.startMinute,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get endMinute => $composableBuilder(
    column: $table.endMinute,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get expectedAttendees => $composableBuilder(
    column: $table.expectedAttendees,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ScheduleRecordsTableOrderingComposer
    extends Composer<_$ScheduleDatabase, $ScheduleRecordsTable> {
  $$ScheduleRecordsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get entryId => $composableBuilder(
    column: $table.entryId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get workshopId => $composableBuilder(
    column: $table.workshopId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get instructorId => $composableBuilder(
    column: $table.instructorId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get venueId => $composableBuilder(
    column: $table.venueId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get dayId => $composableBuilder(
    column: $table.dayId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get startMinute => $composableBuilder(
    column: $table.startMinute,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get endMinute => $composableBuilder(
    column: $table.endMinute,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get expectedAttendees => $composableBuilder(
    column: $table.expectedAttendees,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ScheduleRecordsTableAnnotationComposer
    extends Composer<_$ScheduleDatabase, $ScheduleRecordsTable> {
  $$ScheduleRecordsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get entryId =>
      $composableBuilder(column: $table.entryId, builder: (column) => column);

  GeneratedColumn<String> get workshopId => $composableBuilder(
    column: $table.workshopId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get instructorId => $composableBuilder(
    column: $table.instructorId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get venueId =>
      $composableBuilder(column: $table.venueId, builder: (column) => column);

  GeneratedColumn<String> get dayId =>
      $composableBuilder(column: $table.dayId, builder: (column) => column);

  GeneratedColumn<int> get startMinute => $composableBuilder(
    column: $table.startMinute,
    builder: (column) => column,
  );

  GeneratedColumn<int> get endMinute =>
      $composableBuilder(column: $table.endMinute, builder: (column) => column);

  GeneratedColumn<int> get expectedAttendees => $composableBuilder(
    column: $table.expectedAttendees,
    builder: (column) => column,
  );
}

class $$ScheduleRecordsTableTableManager
    extends
        RootTableManager<
          _$ScheduleDatabase,
          $ScheduleRecordsTable,
          ScheduleRecord,
          $$ScheduleRecordsTableFilterComposer,
          $$ScheduleRecordsTableOrderingComposer,
          $$ScheduleRecordsTableAnnotationComposer,
          $$ScheduleRecordsTableCreateCompanionBuilder,
          $$ScheduleRecordsTableUpdateCompanionBuilder,
          (
            ScheduleRecord,
            BaseReferences<
              _$ScheduleDatabase,
              $ScheduleRecordsTable,
              ScheduleRecord
            >,
          ),
          ScheduleRecord,
          PrefetchHooks Function()
        > {
  $$ScheduleRecordsTableTableManager(
    _$ScheduleDatabase db,
    $ScheduleRecordsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ScheduleRecordsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ScheduleRecordsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ScheduleRecordsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> entryId = const Value.absent(),
                Value<String> workshopId = const Value.absent(),
                Value<String> instructorId = const Value.absent(),
                Value<String> venueId = const Value.absent(),
                Value<String> dayId = const Value.absent(),
                Value<int> startMinute = const Value.absent(),
                Value<int> endMinute = const Value.absent(),
                Value<int> expectedAttendees = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ScheduleRecordsCompanion(
                entryId: entryId,
                workshopId: workshopId,
                instructorId: instructorId,
                venueId: venueId,
                dayId: dayId,
                startMinute: startMinute,
                endMinute: endMinute,
                expectedAttendees: expectedAttendees,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String entryId,
                required String workshopId,
                required String instructorId,
                required String venueId,
                required String dayId,
                required int startMinute,
                required int endMinute,
                required int expectedAttendees,
                Value<int> rowid = const Value.absent(),
              }) => ScheduleRecordsCompanion.insert(
                entryId: entryId,
                workshopId: workshopId,
                instructorId: instructorId,
                venueId: venueId,
                dayId: dayId,
                startMinute: startMinute,
                endMinute: endMinute,
                expectedAttendees: expectedAttendees,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ScheduleRecordsTableProcessedTableManager =
    ProcessedTableManager<
      _$ScheduleDatabase,
      $ScheduleRecordsTable,
      ScheduleRecord,
      $$ScheduleRecordsTableFilterComposer,
      $$ScheduleRecordsTableOrderingComposer,
      $$ScheduleRecordsTableAnnotationComposer,
      $$ScheduleRecordsTableCreateCompanionBuilder,
      $$ScheduleRecordsTableUpdateCompanionBuilder,
      (
        ScheduleRecord,
        BaseReferences<
          _$ScheduleDatabase,
          $ScheduleRecordsTable,
          ScheduleRecord
        >,
      ),
      ScheduleRecord,
      PrefetchHooks Function()
    >;
typedef $$ScheduleSettingsTableCreateCompanionBuilder =
    ScheduleSettingsCompanion Function({
      required String settingKey,
      required String settingValue,
      Value<int> rowid,
    });
typedef $$ScheduleSettingsTableUpdateCompanionBuilder =
    ScheduleSettingsCompanion Function({
      Value<String> settingKey,
      Value<String> settingValue,
      Value<int> rowid,
    });

class $$ScheduleSettingsTableFilterComposer
    extends Composer<_$ScheduleDatabase, $ScheduleSettingsTable> {
  $$ScheduleSettingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get settingKey => $composableBuilder(
    column: $table.settingKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get settingValue => $composableBuilder(
    column: $table.settingValue,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ScheduleSettingsTableOrderingComposer
    extends Composer<_$ScheduleDatabase, $ScheduleSettingsTable> {
  $$ScheduleSettingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get settingKey => $composableBuilder(
    column: $table.settingKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get settingValue => $composableBuilder(
    column: $table.settingValue,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ScheduleSettingsTableAnnotationComposer
    extends Composer<_$ScheduleDatabase, $ScheduleSettingsTable> {
  $$ScheduleSettingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get settingKey => $composableBuilder(
    column: $table.settingKey,
    builder: (column) => column,
  );

  GeneratedColumn<String> get settingValue => $composableBuilder(
    column: $table.settingValue,
    builder: (column) => column,
  );
}

class $$ScheduleSettingsTableTableManager
    extends
        RootTableManager<
          _$ScheduleDatabase,
          $ScheduleSettingsTable,
          ScheduleSetting,
          $$ScheduleSettingsTableFilterComposer,
          $$ScheduleSettingsTableOrderingComposer,
          $$ScheduleSettingsTableAnnotationComposer,
          $$ScheduleSettingsTableCreateCompanionBuilder,
          $$ScheduleSettingsTableUpdateCompanionBuilder,
          (
            ScheduleSetting,
            BaseReferences<
              _$ScheduleDatabase,
              $ScheduleSettingsTable,
              ScheduleSetting
            >,
          ),
          ScheduleSetting,
          PrefetchHooks Function()
        > {
  $$ScheduleSettingsTableTableManager(
    _$ScheduleDatabase db,
    $ScheduleSettingsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ScheduleSettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ScheduleSettingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ScheduleSettingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> settingKey = const Value.absent(),
                Value<String> settingValue = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ScheduleSettingsCompanion(
                settingKey: settingKey,
                settingValue: settingValue,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String settingKey,
                required String settingValue,
                Value<int> rowid = const Value.absent(),
              }) => ScheduleSettingsCompanion.insert(
                settingKey: settingKey,
                settingValue: settingValue,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ScheduleSettingsTableProcessedTableManager =
    ProcessedTableManager<
      _$ScheduleDatabase,
      $ScheduleSettingsTable,
      ScheduleSetting,
      $$ScheduleSettingsTableFilterComposer,
      $$ScheduleSettingsTableOrderingComposer,
      $$ScheduleSettingsTableAnnotationComposer,
      $$ScheduleSettingsTableCreateCompanionBuilder,
      $$ScheduleSettingsTableUpdateCompanionBuilder,
      (
        ScheduleSetting,
        BaseReferences<
          _$ScheduleDatabase,
          $ScheduleSettingsTable,
          ScheduleSetting
        >,
      ),
      ScheduleSetting,
      PrefetchHooks Function()
    >;

class $ScheduleDatabaseManager {
  final _$ScheduleDatabase _db;
  $ScheduleDatabaseManager(this._db);
  $$ScheduleRecordsTableTableManager get scheduleRecords =>
      $$ScheduleRecordsTableTableManager(_db, _db.scheduleRecords);
  $$ScheduleSettingsTableTableManager get scheduleSettings =>
      $$ScheduleSettingsTableTableManager(_db, _db.scheduleSettings);
}
