// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'exchange_database.dart';

// ignore_for_file: type=lint
class $ExchangeListingRecordsTable extends ExchangeListingRecords
    with TableInfo<$ExchangeListingRecordsTable, ExchangeListingRecord> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ExchangeListingRecordsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _listingIdMeta = const VerificationMeta(
    'listingId',
  );
  @override
  late final GeneratedColumn<String> listingId = GeneratedColumn<String>(
    'listing_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _originMeta = const VerificationMeta('origin');
  @override
  late final GeneratedColumn<String> origin = GeneratedColumn<String>(
    'origin',
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
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _categoryMeta = const VerificationMeta(
    'category',
  );
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
    'category',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _neighborhoodMeta = const VerificationMeta(
    'neighborhood',
  );
  @override
  late final GeneratedColumn<String> neighborhood = GeneratedColumn<String>(
    'neighborhood',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _handoffMethodMeta = const VerificationMeta(
    'handoffMethod',
  );
  @override
  late final GeneratedColumn<String> handoffMethod = GeneratedColumn<String>(
    'handoff_method',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _availableWindowIdMeta = const VerificationMeta(
    'availableWindowId',
  );
  @override
  late final GeneratedColumn<String> availableWindowId =
      GeneratedColumn<String>(
        'available_window_id',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _totalQuantityMeta = const VerificationMeta(
    'totalQuantity',
  );
  @override
  late final GeneratedColumn<int> totalQuantity = GeneratedColumn<int>(
    'total_quantity',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _remainingQuantityMeta = const VerificationMeta(
    'remainingQuantity',
  );
  @override
  late final GeneratedColumn<int> remainingQuantity = GeneratedColumn<int>(
    'remaining_quantity',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ownerIdMeta = const VerificationMeta(
    'ownerId',
  );
  @override
  late final GeneratedColumn<String> ownerId = GeneratedColumn<String>(
    'owner_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ownerDisplayNameMeta = const VerificationMeta(
    'ownerDisplayName',
  );
  @override
  late final GeneratedColumn<String> ownerDisplayName = GeneratedColumn<String>(
    'owner_display_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _completedAtMeta = const VerificationMeta(
    'completedAt',
  );
  @override
  late final GeneratedColumn<DateTime> completedAt = GeneratedColumn<DateTime>(
    'completed_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    listingId,
    origin,
    title,
    description,
    category,
    neighborhood,
    handoffMethod,
    availableWindowId,
    totalQuantity,
    remainingQuantity,
    ownerId,
    ownerDisplayName,
    createdAt,
    updatedAt,
    completedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'exchange_listing_records';
  @override
  VerificationContext validateIntegrity(
    Insertable<ExchangeListingRecord> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('listing_id')) {
      context.handle(
        _listingIdMeta,
        listingId.isAcceptableOrUnknown(data['listing_id']!, _listingIdMeta),
      );
    } else if (isInserting) {
      context.missing(_listingIdMeta);
    }
    if (data.containsKey('origin')) {
      context.handle(
        _originMeta,
        origin.isAcceptableOrUnknown(data['origin']!, _originMeta),
      );
    } else if (isInserting) {
      context.missing(_originMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_descriptionMeta);
    }
    if (data.containsKey('category')) {
      context.handle(
        _categoryMeta,
        category.isAcceptableOrUnknown(data['category']!, _categoryMeta),
      );
    } else if (isInserting) {
      context.missing(_categoryMeta);
    }
    if (data.containsKey('neighborhood')) {
      context.handle(
        _neighborhoodMeta,
        neighborhood.isAcceptableOrUnknown(
          data['neighborhood']!,
          _neighborhoodMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_neighborhoodMeta);
    }
    if (data.containsKey('handoff_method')) {
      context.handle(
        _handoffMethodMeta,
        handoffMethod.isAcceptableOrUnknown(
          data['handoff_method']!,
          _handoffMethodMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_handoffMethodMeta);
    }
    if (data.containsKey('available_window_id')) {
      context.handle(
        _availableWindowIdMeta,
        availableWindowId.isAcceptableOrUnknown(
          data['available_window_id']!,
          _availableWindowIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_availableWindowIdMeta);
    }
    if (data.containsKey('total_quantity')) {
      context.handle(
        _totalQuantityMeta,
        totalQuantity.isAcceptableOrUnknown(
          data['total_quantity']!,
          _totalQuantityMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_totalQuantityMeta);
    }
    if (data.containsKey('remaining_quantity')) {
      context.handle(
        _remainingQuantityMeta,
        remainingQuantity.isAcceptableOrUnknown(
          data['remaining_quantity']!,
          _remainingQuantityMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_remainingQuantityMeta);
    }
    if (data.containsKey('owner_id')) {
      context.handle(
        _ownerIdMeta,
        ownerId.isAcceptableOrUnknown(data['owner_id']!, _ownerIdMeta),
      );
    } else if (isInserting) {
      context.missing(_ownerIdMeta);
    }
    if (data.containsKey('owner_display_name')) {
      context.handle(
        _ownerDisplayNameMeta,
        ownerDisplayName.isAcceptableOrUnknown(
          data['owner_display_name']!,
          _ownerDisplayNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_ownerDisplayNameMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('completed_at')) {
      context.handle(
        _completedAtMeta,
        completedAt.isAcceptableOrUnknown(
          data['completed_at']!,
          _completedAtMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {listingId};
  @override
  ExchangeListingRecord map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ExchangeListingRecord(
      listingId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}listing_id'],
      )!,
      origin: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}origin'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      )!,
      category: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category'],
      )!,
      neighborhood: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}neighborhood'],
      )!,
      handoffMethod: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}handoff_method'],
      )!,
      availableWindowId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}available_window_id'],
      )!,
      totalQuantity: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}total_quantity'],
      )!,
      remainingQuantity: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}remaining_quantity'],
      )!,
      ownerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}owner_id'],
      )!,
      ownerDisplayName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}owner_display_name'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      completedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}completed_at'],
      ),
    );
  }

  @override
  $ExchangeListingRecordsTable createAlias(String alias) {
    return $ExchangeListingRecordsTable(attachedDatabase, alias);
  }
}

class ExchangeListingRecord extends DataClass
    implements Insertable<ExchangeListingRecord> {
  final String listingId;
  final String origin;
  final String title;
  final String description;
  final String category;
  final String neighborhood;
  final String handoffMethod;
  final String availableWindowId;
  final int totalQuantity;
  final int remainingQuantity;
  final String ownerId;
  final String ownerDisplayName;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? completedAt;
  const ExchangeListingRecord({
    required this.listingId,
    required this.origin,
    required this.title,
    required this.description,
    required this.category,
    required this.neighborhood,
    required this.handoffMethod,
    required this.availableWindowId,
    required this.totalQuantity,
    required this.remainingQuantity,
    required this.ownerId,
    required this.ownerDisplayName,
    required this.createdAt,
    required this.updatedAt,
    this.completedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['listing_id'] = Variable<String>(listingId);
    map['origin'] = Variable<String>(origin);
    map['title'] = Variable<String>(title);
    map['description'] = Variable<String>(description);
    map['category'] = Variable<String>(category);
    map['neighborhood'] = Variable<String>(neighborhood);
    map['handoff_method'] = Variable<String>(handoffMethod);
    map['available_window_id'] = Variable<String>(availableWindowId);
    map['total_quantity'] = Variable<int>(totalQuantity);
    map['remaining_quantity'] = Variable<int>(remainingQuantity);
    map['owner_id'] = Variable<String>(ownerId);
    map['owner_display_name'] = Variable<String>(ownerDisplayName);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || completedAt != null) {
      map['completed_at'] = Variable<DateTime>(completedAt);
    }
    return map;
  }

  ExchangeListingRecordsCompanion toCompanion(bool nullToAbsent) {
    return ExchangeListingRecordsCompanion(
      listingId: Value(listingId),
      origin: Value(origin),
      title: Value(title),
      description: Value(description),
      category: Value(category),
      neighborhood: Value(neighborhood),
      handoffMethod: Value(handoffMethod),
      availableWindowId: Value(availableWindowId),
      totalQuantity: Value(totalQuantity),
      remainingQuantity: Value(remainingQuantity),
      ownerId: Value(ownerId),
      ownerDisplayName: Value(ownerDisplayName),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      completedAt: completedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(completedAt),
    );
  }

  factory ExchangeListingRecord.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ExchangeListingRecord(
      listingId: serializer.fromJson<String>(json['listingId']),
      origin: serializer.fromJson<String>(json['origin']),
      title: serializer.fromJson<String>(json['title']),
      description: serializer.fromJson<String>(json['description']),
      category: serializer.fromJson<String>(json['category']),
      neighborhood: serializer.fromJson<String>(json['neighborhood']),
      handoffMethod: serializer.fromJson<String>(json['handoffMethod']),
      availableWindowId: serializer.fromJson<String>(json['availableWindowId']),
      totalQuantity: serializer.fromJson<int>(json['totalQuantity']),
      remainingQuantity: serializer.fromJson<int>(json['remainingQuantity']),
      ownerId: serializer.fromJson<String>(json['ownerId']),
      ownerDisplayName: serializer.fromJson<String>(json['ownerDisplayName']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      completedAt: serializer.fromJson<DateTime?>(json['completedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'listingId': serializer.toJson<String>(listingId),
      'origin': serializer.toJson<String>(origin),
      'title': serializer.toJson<String>(title),
      'description': serializer.toJson<String>(description),
      'category': serializer.toJson<String>(category),
      'neighborhood': serializer.toJson<String>(neighborhood),
      'handoffMethod': serializer.toJson<String>(handoffMethod),
      'availableWindowId': serializer.toJson<String>(availableWindowId),
      'totalQuantity': serializer.toJson<int>(totalQuantity),
      'remainingQuantity': serializer.toJson<int>(remainingQuantity),
      'ownerId': serializer.toJson<String>(ownerId),
      'ownerDisplayName': serializer.toJson<String>(ownerDisplayName),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'completedAt': serializer.toJson<DateTime?>(completedAt),
    };
  }

  ExchangeListingRecord copyWith({
    String? listingId,
    String? origin,
    String? title,
    String? description,
    String? category,
    String? neighborhood,
    String? handoffMethod,
    String? availableWindowId,
    int? totalQuantity,
    int? remainingQuantity,
    String? ownerId,
    String? ownerDisplayName,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> completedAt = const Value.absent(),
  }) => ExchangeListingRecord(
    listingId: listingId ?? this.listingId,
    origin: origin ?? this.origin,
    title: title ?? this.title,
    description: description ?? this.description,
    category: category ?? this.category,
    neighborhood: neighborhood ?? this.neighborhood,
    handoffMethod: handoffMethod ?? this.handoffMethod,
    availableWindowId: availableWindowId ?? this.availableWindowId,
    totalQuantity: totalQuantity ?? this.totalQuantity,
    remainingQuantity: remainingQuantity ?? this.remainingQuantity,
    ownerId: ownerId ?? this.ownerId,
    ownerDisplayName: ownerDisplayName ?? this.ownerDisplayName,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    completedAt: completedAt.present ? completedAt.value : this.completedAt,
  );
  ExchangeListingRecord copyWithCompanion(
    ExchangeListingRecordsCompanion data,
  ) {
    return ExchangeListingRecord(
      listingId: data.listingId.present ? data.listingId.value : this.listingId,
      origin: data.origin.present ? data.origin.value : this.origin,
      title: data.title.present ? data.title.value : this.title,
      description: data.description.present
          ? data.description.value
          : this.description,
      category: data.category.present ? data.category.value : this.category,
      neighborhood: data.neighborhood.present
          ? data.neighborhood.value
          : this.neighborhood,
      handoffMethod: data.handoffMethod.present
          ? data.handoffMethod.value
          : this.handoffMethod,
      availableWindowId: data.availableWindowId.present
          ? data.availableWindowId.value
          : this.availableWindowId,
      totalQuantity: data.totalQuantity.present
          ? data.totalQuantity.value
          : this.totalQuantity,
      remainingQuantity: data.remainingQuantity.present
          ? data.remainingQuantity.value
          : this.remainingQuantity,
      ownerId: data.ownerId.present ? data.ownerId.value : this.ownerId,
      ownerDisplayName: data.ownerDisplayName.present
          ? data.ownerDisplayName.value
          : this.ownerDisplayName,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      completedAt: data.completedAt.present
          ? data.completedAt.value
          : this.completedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ExchangeListingRecord(')
          ..write('listingId: $listingId, ')
          ..write('origin: $origin, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('category: $category, ')
          ..write('neighborhood: $neighborhood, ')
          ..write('handoffMethod: $handoffMethod, ')
          ..write('availableWindowId: $availableWindowId, ')
          ..write('totalQuantity: $totalQuantity, ')
          ..write('remainingQuantity: $remainingQuantity, ')
          ..write('ownerId: $ownerId, ')
          ..write('ownerDisplayName: $ownerDisplayName, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('completedAt: $completedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    listingId,
    origin,
    title,
    description,
    category,
    neighborhood,
    handoffMethod,
    availableWindowId,
    totalQuantity,
    remainingQuantity,
    ownerId,
    ownerDisplayName,
    createdAt,
    updatedAt,
    completedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ExchangeListingRecord &&
          other.listingId == this.listingId &&
          other.origin == this.origin &&
          other.title == this.title &&
          other.description == this.description &&
          other.category == this.category &&
          other.neighborhood == this.neighborhood &&
          other.handoffMethod == this.handoffMethod &&
          other.availableWindowId == this.availableWindowId &&
          other.totalQuantity == this.totalQuantity &&
          other.remainingQuantity == this.remainingQuantity &&
          other.ownerId == this.ownerId &&
          other.ownerDisplayName == this.ownerDisplayName &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.completedAt == this.completedAt);
}

class ExchangeListingRecordsCompanion
    extends UpdateCompanion<ExchangeListingRecord> {
  final Value<String> listingId;
  final Value<String> origin;
  final Value<String> title;
  final Value<String> description;
  final Value<String> category;
  final Value<String> neighborhood;
  final Value<String> handoffMethod;
  final Value<String> availableWindowId;
  final Value<int> totalQuantity;
  final Value<int> remainingQuantity;
  final Value<String> ownerId;
  final Value<String> ownerDisplayName;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> completedAt;
  final Value<int> rowid;
  const ExchangeListingRecordsCompanion({
    this.listingId = const Value.absent(),
    this.origin = const Value.absent(),
    this.title = const Value.absent(),
    this.description = const Value.absent(),
    this.category = const Value.absent(),
    this.neighborhood = const Value.absent(),
    this.handoffMethod = const Value.absent(),
    this.availableWindowId = const Value.absent(),
    this.totalQuantity = const Value.absent(),
    this.remainingQuantity = const Value.absent(),
    this.ownerId = const Value.absent(),
    this.ownerDisplayName = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ExchangeListingRecordsCompanion.insert({
    required String listingId,
    required String origin,
    required String title,
    required String description,
    required String category,
    required String neighborhood,
    required String handoffMethod,
    required String availableWindowId,
    required int totalQuantity,
    required int remainingQuantity,
    required String ownerId,
    required String ownerDisplayName,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.completedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : listingId = Value(listingId),
       origin = Value(origin),
       title = Value(title),
       description = Value(description),
       category = Value(category),
       neighborhood = Value(neighborhood),
       handoffMethod = Value(handoffMethod),
       availableWindowId = Value(availableWindowId),
       totalQuantity = Value(totalQuantity),
       remainingQuantity = Value(remainingQuantity),
       ownerId = Value(ownerId),
       ownerDisplayName = Value(ownerDisplayName),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<ExchangeListingRecord> custom({
    Expression<String>? listingId,
    Expression<String>? origin,
    Expression<String>? title,
    Expression<String>? description,
    Expression<String>? category,
    Expression<String>? neighborhood,
    Expression<String>? handoffMethod,
    Expression<String>? availableWindowId,
    Expression<int>? totalQuantity,
    Expression<int>? remainingQuantity,
    Expression<String>? ownerId,
    Expression<String>? ownerDisplayName,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? completedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (listingId != null) 'listing_id': listingId,
      if (origin != null) 'origin': origin,
      if (title != null) 'title': title,
      if (description != null) 'description': description,
      if (category != null) 'category': category,
      if (neighborhood != null) 'neighborhood': neighborhood,
      if (handoffMethod != null) 'handoff_method': handoffMethod,
      if (availableWindowId != null) 'available_window_id': availableWindowId,
      if (totalQuantity != null) 'total_quantity': totalQuantity,
      if (remainingQuantity != null) 'remaining_quantity': remainingQuantity,
      if (ownerId != null) 'owner_id': ownerId,
      if (ownerDisplayName != null) 'owner_display_name': ownerDisplayName,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (completedAt != null) 'completed_at': completedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ExchangeListingRecordsCompanion copyWith({
    Value<String>? listingId,
    Value<String>? origin,
    Value<String>? title,
    Value<String>? description,
    Value<String>? category,
    Value<String>? neighborhood,
    Value<String>? handoffMethod,
    Value<String>? availableWindowId,
    Value<int>? totalQuantity,
    Value<int>? remainingQuantity,
    Value<String>? ownerId,
    Value<String>? ownerDisplayName,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? completedAt,
    Value<int>? rowid,
  }) {
    return ExchangeListingRecordsCompanion(
      listingId: listingId ?? this.listingId,
      origin: origin ?? this.origin,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      neighborhood: neighborhood ?? this.neighborhood,
      handoffMethod: handoffMethod ?? this.handoffMethod,
      availableWindowId: availableWindowId ?? this.availableWindowId,
      totalQuantity: totalQuantity ?? this.totalQuantity,
      remainingQuantity: remainingQuantity ?? this.remainingQuantity,
      ownerId: ownerId ?? this.ownerId,
      ownerDisplayName: ownerDisplayName ?? this.ownerDisplayName,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      completedAt: completedAt ?? this.completedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (listingId.present) {
      map['listing_id'] = Variable<String>(listingId.value);
    }
    if (origin.present) {
      map['origin'] = Variable<String>(origin.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (neighborhood.present) {
      map['neighborhood'] = Variable<String>(neighborhood.value);
    }
    if (handoffMethod.present) {
      map['handoff_method'] = Variable<String>(handoffMethod.value);
    }
    if (availableWindowId.present) {
      map['available_window_id'] = Variable<String>(availableWindowId.value);
    }
    if (totalQuantity.present) {
      map['total_quantity'] = Variable<int>(totalQuantity.value);
    }
    if (remainingQuantity.present) {
      map['remaining_quantity'] = Variable<int>(remainingQuantity.value);
    }
    if (ownerId.present) {
      map['owner_id'] = Variable<String>(ownerId.value);
    }
    if (ownerDisplayName.present) {
      map['owner_display_name'] = Variable<String>(ownerDisplayName.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (completedAt.present) {
      map['completed_at'] = Variable<DateTime>(completedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ExchangeListingRecordsCompanion(')
          ..write('listingId: $listingId, ')
          ..write('origin: $origin, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('category: $category, ')
          ..write('neighborhood: $neighborhood, ')
          ..write('handoffMethod: $handoffMethod, ')
          ..write('availableWindowId: $availableWindowId, ')
          ..write('totalQuantity: $totalQuantity, ')
          ..write('remainingQuantity: $remainingQuantity, ')
          ..write('ownerId: $ownerId, ')
          ..write('ownerDisplayName: $ownerDisplayName, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('completedAt: $completedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ExchangeClaimRecordsTable extends ExchangeClaimRecords
    with TableInfo<$ExchangeClaimRecordsTable, ExchangeClaimRecord> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ExchangeClaimRecordsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _listingIdMeta = const VerificationMeta(
    'listingId',
  );
  @override
  late final GeneratedColumn<String> listingId = GeneratedColumn<String>(
    'listing_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _claimantIdMeta = const VerificationMeta(
    'claimantId',
  );
  @override
  late final GeneratedColumn<String> claimantId = GeneratedColumn<String>(
    'claimant_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _claimedAtMeta = const VerificationMeta(
    'claimedAt',
  );
  @override
  late final GeneratedColumn<DateTime> claimedAt = GeneratedColumn<DateTime>(
    'claimed_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [listingId, claimantId, claimedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'exchange_claim_records';
  @override
  VerificationContext validateIntegrity(
    Insertable<ExchangeClaimRecord> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('listing_id')) {
      context.handle(
        _listingIdMeta,
        listingId.isAcceptableOrUnknown(data['listing_id']!, _listingIdMeta),
      );
    } else if (isInserting) {
      context.missing(_listingIdMeta);
    }
    if (data.containsKey('claimant_id')) {
      context.handle(
        _claimantIdMeta,
        claimantId.isAcceptableOrUnknown(data['claimant_id']!, _claimantIdMeta),
      );
    } else if (isInserting) {
      context.missing(_claimantIdMeta);
    }
    if (data.containsKey('claimed_at')) {
      context.handle(
        _claimedAtMeta,
        claimedAt.isAcceptableOrUnknown(data['claimed_at']!, _claimedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_claimedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {listingId, claimantId};
  @override
  ExchangeClaimRecord map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ExchangeClaimRecord(
      listingId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}listing_id'],
      )!,
      claimantId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}claimant_id'],
      )!,
      claimedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}claimed_at'],
      )!,
    );
  }

  @override
  $ExchangeClaimRecordsTable createAlias(String alias) {
    return $ExchangeClaimRecordsTable(attachedDatabase, alias);
  }
}

class ExchangeClaimRecord extends DataClass
    implements Insertable<ExchangeClaimRecord> {
  final String listingId;
  final String claimantId;
  final DateTime claimedAt;
  const ExchangeClaimRecord({
    required this.listingId,
    required this.claimantId,
    required this.claimedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['listing_id'] = Variable<String>(listingId);
    map['claimant_id'] = Variable<String>(claimantId);
    map['claimed_at'] = Variable<DateTime>(claimedAt);
    return map;
  }

  ExchangeClaimRecordsCompanion toCompanion(bool nullToAbsent) {
    return ExchangeClaimRecordsCompanion(
      listingId: Value(listingId),
      claimantId: Value(claimantId),
      claimedAt: Value(claimedAt),
    );
  }

  factory ExchangeClaimRecord.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ExchangeClaimRecord(
      listingId: serializer.fromJson<String>(json['listingId']),
      claimantId: serializer.fromJson<String>(json['claimantId']),
      claimedAt: serializer.fromJson<DateTime>(json['claimedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'listingId': serializer.toJson<String>(listingId),
      'claimantId': serializer.toJson<String>(claimantId),
      'claimedAt': serializer.toJson<DateTime>(claimedAt),
    };
  }

  ExchangeClaimRecord copyWith({
    String? listingId,
    String? claimantId,
    DateTime? claimedAt,
  }) => ExchangeClaimRecord(
    listingId: listingId ?? this.listingId,
    claimantId: claimantId ?? this.claimantId,
    claimedAt: claimedAt ?? this.claimedAt,
  );
  ExchangeClaimRecord copyWithCompanion(ExchangeClaimRecordsCompanion data) {
    return ExchangeClaimRecord(
      listingId: data.listingId.present ? data.listingId.value : this.listingId,
      claimantId: data.claimantId.present
          ? data.claimantId.value
          : this.claimantId,
      claimedAt: data.claimedAt.present ? data.claimedAt.value : this.claimedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ExchangeClaimRecord(')
          ..write('listingId: $listingId, ')
          ..write('claimantId: $claimantId, ')
          ..write('claimedAt: $claimedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(listingId, claimantId, claimedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ExchangeClaimRecord &&
          other.listingId == this.listingId &&
          other.claimantId == this.claimantId &&
          other.claimedAt == this.claimedAt);
}

class ExchangeClaimRecordsCompanion
    extends UpdateCompanion<ExchangeClaimRecord> {
  final Value<String> listingId;
  final Value<String> claimantId;
  final Value<DateTime> claimedAt;
  final Value<int> rowid;
  const ExchangeClaimRecordsCompanion({
    this.listingId = const Value.absent(),
    this.claimantId = const Value.absent(),
    this.claimedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ExchangeClaimRecordsCompanion.insert({
    required String listingId,
    required String claimantId,
    required DateTime claimedAt,
    this.rowid = const Value.absent(),
  }) : listingId = Value(listingId),
       claimantId = Value(claimantId),
       claimedAt = Value(claimedAt);
  static Insertable<ExchangeClaimRecord> custom({
    Expression<String>? listingId,
    Expression<String>? claimantId,
    Expression<DateTime>? claimedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (listingId != null) 'listing_id': listingId,
      if (claimantId != null) 'claimant_id': claimantId,
      if (claimedAt != null) 'claimed_at': claimedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ExchangeClaimRecordsCompanion copyWith({
    Value<String>? listingId,
    Value<String>? claimantId,
    Value<DateTime>? claimedAt,
    Value<int>? rowid,
  }) {
    return ExchangeClaimRecordsCompanion(
      listingId: listingId ?? this.listingId,
      claimantId: claimantId ?? this.claimantId,
      claimedAt: claimedAt ?? this.claimedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (listingId.present) {
      map['listing_id'] = Variable<String>(listingId.value);
    }
    if (claimantId.present) {
      map['claimant_id'] = Variable<String>(claimantId.value);
    }
    if (claimedAt.present) {
      map['claimed_at'] = Variable<DateTime>(claimedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ExchangeClaimRecordsCompanion(')
          ..write('listingId: $listingId, ')
          ..write('claimantId: $claimantId, ')
          ..write('claimedAt: $claimedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ExchangeSettingsTable extends ExchangeSettings
    with TableInfo<$ExchangeSettingsTable, ExchangeSetting> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ExchangeSettingsTable(this.attachedDatabase, [this._alias]);
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
  static const String $name = 'exchange_settings';
  @override
  VerificationContext validateIntegrity(
    Insertable<ExchangeSetting> instance, {
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
  ExchangeSetting map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ExchangeSetting(
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
  $ExchangeSettingsTable createAlias(String alias) {
    return $ExchangeSettingsTable(attachedDatabase, alias);
  }
}

class ExchangeSetting extends DataClass implements Insertable<ExchangeSetting> {
  final String settingKey;
  final String settingValue;
  const ExchangeSetting({required this.settingKey, required this.settingValue});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['setting_key'] = Variable<String>(settingKey);
    map['setting_value'] = Variable<String>(settingValue);
    return map;
  }

  ExchangeSettingsCompanion toCompanion(bool nullToAbsent) {
    return ExchangeSettingsCompanion(
      settingKey: Value(settingKey),
      settingValue: Value(settingValue),
    );
  }

  factory ExchangeSetting.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ExchangeSetting(
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

  ExchangeSetting copyWith({String? settingKey, String? settingValue}) =>
      ExchangeSetting(
        settingKey: settingKey ?? this.settingKey,
        settingValue: settingValue ?? this.settingValue,
      );
  ExchangeSetting copyWithCompanion(ExchangeSettingsCompanion data) {
    return ExchangeSetting(
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
    return (StringBuffer('ExchangeSetting(')
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
      (other is ExchangeSetting &&
          other.settingKey == this.settingKey &&
          other.settingValue == this.settingValue);
}

class ExchangeSettingsCompanion extends UpdateCompanion<ExchangeSetting> {
  final Value<String> settingKey;
  final Value<String> settingValue;
  final Value<int> rowid;
  const ExchangeSettingsCompanion({
    this.settingKey = const Value.absent(),
    this.settingValue = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ExchangeSettingsCompanion.insert({
    required String settingKey,
    required String settingValue,
    this.rowid = const Value.absent(),
  }) : settingKey = Value(settingKey),
       settingValue = Value(settingValue);
  static Insertable<ExchangeSetting> custom({
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

  ExchangeSettingsCompanion copyWith({
    Value<String>? settingKey,
    Value<String>? settingValue,
    Value<int>? rowid,
  }) {
    return ExchangeSettingsCompanion(
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
    return (StringBuffer('ExchangeSettingsCompanion(')
          ..write('settingKey: $settingKey, ')
          ..write('settingValue: $settingValue, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$ExchangeDatabase extends GeneratedDatabase {
  _$ExchangeDatabase(QueryExecutor e) : super(e);
  $ExchangeDatabaseManager get managers => $ExchangeDatabaseManager(this);
  late final $ExchangeListingRecordsTable exchangeListingRecords =
      $ExchangeListingRecordsTable(this);
  late final $ExchangeClaimRecordsTable exchangeClaimRecords =
      $ExchangeClaimRecordsTable(this);
  late final $ExchangeSettingsTable exchangeSettings = $ExchangeSettingsTable(
    this,
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    exchangeListingRecords,
    exchangeClaimRecords,
    exchangeSettings,
  ];
}

typedef $$ExchangeListingRecordsTableCreateCompanionBuilder =
    ExchangeListingRecordsCompanion Function({
      required String listingId,
      required String origin,
      required String title,
      required String description,
      required String category,
      required String neighborhood,
      required String handoffMethod,
      required String availableWindowId,
      required int totalQuantity,
      required int remainingQuantity,
      required String ownerId,
      required String ownerDisplayName,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<DateTime?> completedAt,
      Value<int> rowid,
    });
typedef $$ExchangeListingRecordsTableUpdateCompanionBuilder =
    ExchangeListingRecordsCompanion Function({
      Value<String> listingId,
      Value<String> origin,
      Value<String> title,
      Value<String> description,
      Value<String> category,
      Value<String> neighborhood,
      Value<String> handoffMethod,
      Value<String> availableWindowId,
      Value<int> totalQuantity,
      Value<int> remainingQuantity,
      Value<String> ownerId,
      Value<String> ownerDisplayName,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> completedAt,
      Value<int> rowid,
    });

class $$ExchangeListingRecordsTableFilterComposer
    extends Composer<_$ExchangeDatabase, $ExchangeListingRecordsTable> {
  $$ExchangeListingRecordsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get listingId => $composableBuilder(
    column: $table.listingId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get origin => $composableBuilder(
    column: $table.origin,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get neighborhood => $composableBuilder(
    column: $table.neighborhood,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get handoffMethod => $composableBuilder(
    column: $table.handoffMethod,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get availableWindowId => $composableBuilder(
    column: $table.availableWindowId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get totalQuantity => $composableBuilder(
    column: $table.totalQuantity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get remainingQuantity => $composableBuilder(
    column: $table.remainingQuantity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ownerId => $composableBuilder(
    column: $table.ownerId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ownerDisplayName => $composableBuilder(
    column: $table.ownerDisplayName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ExchangeListingRecordsTableOrderingComposer
    extends Composer<_$ExchangeDatabase, $ExchangeListingRecordsTable> {
  $$ExchangeListingRecordsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get listingId => $composableBuilder(
    column: $table.listingId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get origin => $composableBuilder(
    column: $table.origin,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get neighborhood => $composableBuilder(
    column: $table.neighborhood,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get handoffMethod => $composableBuilder(
    column: $table.handoffMethod,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get availableWindowId => $composableBuilder(
    column: $table.availableWindowId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get totalQuantity => $composableBuilder(
    column: $table.totalQuantity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get remainingQuantity => $composableBuilder(
    column: $table.remainingQuantity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ownerId => $composableBuilder(
    column: $table.ownerId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ownerDisplayName => $composableBuilder(
    column: $table.ownerDisplayName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ExchangeListingRecordsTableAnnotationComposer
    extends Composer<_$ExchangeDatabase, $ExchangeListingRecordsTable> {
  $$ExchangeListingRecordsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get listingId =>
      $composableBuilder(column: $table.listingId, builder: (column) => column);

  GeneratedColumn<String> get origin =>
      $composableBuilder(column: $table.origin, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<String> get neighborhood => $composableBuilder(
    column: $table.neighborhood,
    builder: (column) => column,
  );

  GeneratedColumn<String> get handoffMethod => $composableBuilder(
    column: $table.handoffMethod,
    builder: (column) => column,
  );

  GeneratedColumn<String> get availableWindowId => $composableBuilder(
    column: $table.availableWindowId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get totalQuantity => $composableBuilder(
    column: $table.totalQuantity,
    builder: (column) => column,
  );

  GeneratedColumn<int> get remainingQuantity => $composableBuilder(
    column: $table.remainingQuantity,
    builder: (column) => column,
  );

  GeneratedColumn<String> get ownerId =>
      $composableBuilder(column: $table.ownerId, builder: (column) => column);

  GeneratedColumn<String> get ownerDisplayName => $composableBuilder(
    column: $table.ownerDisplayName,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => column,
  );
}

class $$ExchangeListingRecordsTableTableManager
    extends
        RootTableManager<
          _$ExchangeDatabase,
          $ExchangeListingRecordsTable,
          ExchangeListingRecord,
          $$ExchangeListingRecordsTableFilterComposer,
          $$ExchangeListingRecordsTableOrderingComposer,
          $$ExchangeListingRecordsTableAnnotationComposer,
          $$ExchangeListingRecordsTableCreateCompanionBuilder,
          $$ExchangeListingRecordsTableUpdateCompanionBuilder,
          (
            ExchangeListingRecord,
            BaseReferences<
              _$ExchangeDatabase,
              $ExchangeListingRecordsTable,
              ExchangeListingRecord
            >,
          ),
          ExchangeListingRecord,
          PrefetchHooks Function()
        > {
  $$ExchangeListingRecordsTableTableManager(
    _$ExchangeDatabase db,
    $ExchangeListingRecordsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ExchangeListingRecordsTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$ExchangeListingRecordsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$ExchangeListingRecordsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> listingId = const Value.absent(),
                Value<String> origin = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> description = const Value.absent(),
                Value<String> category = const Value.absent(),
                Value<String> neighborhood = const Value.absent(),
                Value<String> handoffMethod = const Value.absent(),
                Value<String> availableWindowId = const Value.absent(),
                Value<int> totalQuantity = const Value.absent(),
                Value<int> remainingQuantity = const Value.absent(),
                Value<String> ownerId = const Value.absent(),
                Value<String> ownerDisplayName = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> completedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ExchangeListingRecordsCompanion(
                listingId: listingId,
                origin: origin,
                title: title,
                description: description,
                category: category,
                neighborhood: neighborhood,
                handoffMethod: handoffMethod,
                availableWindowId: availableWindowId,
                totalQuantity: totalQuantity,
                remainingQuantity: remainingQuantity,
                ownerId: ownerId,
                ownerDisplayName: ownerDisplayName,
                createdAt: createdAt,
                updatedAt: updatedAt,
                completedAt: completedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String listingId,
                required String origin,
                required String title,
                required String description,
                required String category,
                required String neighborhood,
                required String handoffMethod,
                required String availableWindowId,
                required int totalQuantity,
                required int remainingQuantity,
                required String ownerId,
                required String ownerDisplayName,
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<DateTime?> completedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ExchangeListingRecordsCompanion.insert(
                listingId: listingId,
                origin: origin,
                title: title,
                description: description,
                category: category,
                neighborhood: neighborhood,
                handoffMethod: handoffMethod,
                availableWindowId: availableWindowId,
                totalQuantity: totalQuantity,
                remainingQuantity: remainingQuantity,
                ownerId: ownerId,
                ownerDisplayName: ownerDisplayName,
                createdAt: createdAt,
                updatedAt: updatedAt,
                completedAt: completedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ExchangeListingRecordsTableProcessedTableManager =
    ProcessedTableManager<
      _$ExchangeDatabase,
      $ExchangeListingRecordsTable,
      ExchangeListingRecord,
      $$ExchangeListingRecordsTableFilterComposer,
      $$ExchangeListingRecordsTableOrderingComposer,
      $$ExchangeListingRecordsTableAnnotationComposer,
      $$ExchangeListingRecordsTableCreateCompanionBuilder,
      $$ExchangeListingRecordsTableUpdateCompanionBuilder,
      (
        ExchangeListingRecord,
        BaseReferences<
          _$ExchangeDatabase,
          $ExchangeListingRecordsTable,
          ExchangeListingRecord
        >,
      ),
      ExchangeListingRecord,
      PrefetchHooks Function()
    >;
typedef $$ExchangeClaimRecordsTableCreateCompanionBuilder =
    ExchangeClaimRecordsCompanion Function({
      required String listingId,
      required String claimantId,
      required DateTime claimedAt,
      Value<int> rowid,
    });
typedef $$ExchangeClaimRecordsTableUpdateCompanionBuilder =
    ExchangeClaimRecordsCompanion Function({
      Value<String> listingId,
      Value<String> claimantId,
      Value<DateTime> claimedAt,
      Value<int> rowid,
    });

class $$ExchangeClaimRecordsTableFilterComposer
    extends Composer<_$ExchangeDatabase, $ExchangeClaimRecordsTable> {
  $$ExchangeClaimRecordsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get listingId => $composableBuilder(
    column: $table.listingId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get claimantId => $composableBuilder(
    column: $table.claimantId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get claimedAt => $composableBuilder(
    column: $table.claimedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ExchangeClaimRecordsTableOrderingComposer
    extends Composer<_$ExchangeDatabase, $ExchangeClaimRecordsTable> {
  $$ExchangeClaimRecordsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get listingId => $composableBuilder(
    column: $table.listingId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get claimantId => $composableBuilder(
    column: $table.claimantId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get claimedAt => $composableBuilder(
    column: $table.claimedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ExchangeClaimRecordsTableAnnotationComposer
    extends Composer<_$ExchangeDatabase, $ExchangeClaimRecordsTable> {
  $$ExchangeClaimRecordsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get listingId =>
      $composableBuilder(column: $table.listingId, builder: (column) => column);

  GeneratedColumn<String> get claimantId => $composableBuilder(
    column: $table.claimantId,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get claimedAt =>
      $composableBuilder(column: $table.claimedAt, builder: (column) => column);
}

class $$ExchangeClaimRecordsTableTableManager
    extends
        RootTableManager<
          _$ExchangeDatabase,
          $ExchangeClaimRecordsTable,
          ExchangeClaimRecord,
          $$ExchangeClaimRecordsTableFilterComposer,
          $$ExchangeClaimRecordsTableOrderingComposer,
          $$ExchangeClaimRecordsTableAnnotationComposer,
          $$ExchangeClaimRecordsTableCreateCompanionBuilder,
          $$ExchangeClaimRecordsTableUpdateCompanionBuilder,
          (
            ExchangeClaimRecord,
            BaseReferences<
              _$ExchangeDatabase,
              $ExchangeClaimRecordsTable,
              ExchangeClaimRecord
            >,
          ),
          ExchangeClaimRecord,
          PrefetchHooks Function()
        > {
  $$ExchangeClaimRecordsTableTableManager(
    _$ExchangeDatabase db,
    $ExchangeClaimRecordsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ExchangeClaimRecordsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ExchangeClaimRecordsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$ExchangeClaimRecordsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> listingId = const Value.absent(),
                Value<String> claimantId = const Value.absent(),
                Value<DateTime> claimedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ExchangeClaimRecordsCompanion(
                listingId: listingId,
                claimantId: claimantId,
                claimedAt: claimedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String listingId,
                required String claimantId,
                required DateTime claimedAt,
                Value<int> rowid = const Value.absent(),
              }) => ExchangeClaimRecordsCompanion.insert(
                listingId: listingId,
                claimantId: claimantId,
                claimedAt: claimedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ExchangeClaimRecordsTableProcessedTableManager =
    ProcessedTableManager<
      _$ExchangeDatabase,
      $ExchangeClaimRecordsTable,
      ExchangeClaimRecord,
      $$ExchangeClaimRecordsTableFilterComposer,
      $$ExchangeClaimRecordsTableOrderingComposer,
      $$ExchangeClaimRecordsTableAnnotationComposer,
      $$ExchangeClaimRecordsTableCreateCompanionBuilder,
      $$ExchangeClaimRecordsTableUpdateCompanionBuilder,
      (
        ExchangeClaimRecord,
        BaseReferences<
          _$ExchangeDatabase,
          $ExchangeClaimRecordsTable,
          ExchangeClaimRecord
        >,
      ),
      ExchangeClaimRecord,
      PrefetchHooks Function()
    >;
typedef $$ExchangeSettingsTableCreateCompanionBuilder =
    ExchangeSettingsCompanion Function({
      required String settingKey,
      required String settingValue,
      Value<int> rowid,
    });
typedef $$ExchangeSettingsTableUpdateCompanionBuilder =
    ExchangeSettingsCompanion Function({
      Value<String> settingKey,
      Value<String> settingValue,
      Value<int> rowid,
    });

class $$ExchangeSettingsTableFilterComposer
    extends Composer<_$ExchangeDatabase, $ExchangeSettingsTable> {
  $$ExchangeSettingsTableFilterComposer({
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

class $$ExchangeSettingsTableOrderingComposer
    extends Composer<_$ExchangeDatabase, $ExchangeSettingsTable> {
  $$ExchangeSettingsTableOrderingComposer({
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

class $$ExchangeSettingsTableAnnotationComposer
    extends Composer<_$ExchangeDatabase, $ExchangeSettingsTable> {
  $$ExchangeSettingsTableAnnotationComposer({
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

class $$ExchangeSettingsTableTableManager
    extends
        RootTableManager<
          _$ExchangeDatabase,
          $ExchangeSettingsTable,
          ExchangeSetting,
          $$ExchangeSettingsTableFilterComposer,
          $$ExchangeSettingsTableOrderingComposer,
          $$ExchangeSettingsTableAnnotationComposer,
          $$ExchangeSettingsTableCreateCompanionBuilder,
          $$ExchangeSettingsTableUpdateCompanionBuilder,
          (
            ExchangeSetting,
            BaseReferences<
              _$ExchangeDatabase,
              $ExchangeSettingsTable,
              ExchangeSetting
            >,
          ),
          ExchangeSetting,
          PrefetchHooks Function()
        > {
  $$ExchangeSettingsTableTableManager(
    _$ExchangeDatabase db,
    $ExchangeSettingsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ExchangeSettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ExchangeSettingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ExchangeSettingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> settingKey = const Value.absent(),
                Value<String> settingValue = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ExchangeSettingsCompanion(
                settingKey: settingKey,
                settingValue: settingValue,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String settingKey,
                required String settingValue,
                Value<int> rowid = const Value.absent(),
              }) => ExchangeSettingsCompanion.insert(
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

typedef $$ExchangeSettingsTableProcessedTableManager =
    ProcessedTableManager<
      _$ExchangeDatabase,
      $ExchangeSettingsTable,
      ExchangeSetting,
      $$ExchangeSettingsTableFilterComposer,
      $$ExchangeSettingsTableOrderingComposer,
      $$ExchangeSettingsTableAnnotationComposer,
      $$ExchangeSettingsTableCreateCompanionBuilder,
      $$ExchangeSettingsTableUpdateCompanionBuilder,
      (
        ExchangeSetting,
        BaseReferences<
          _$ExchangeDatabase,
          $ExchangeSettingsTable,
          ExchangeSetting
        >,
      ),
      ExchangeSetting,
      PrefetchHooks Function()
    >;

class $ExchangeDatabaseManager {
  final _$ExchangeDatabase _db;
  $ExchangeDatabaseManager(this._db);
  $$ExchangeListingRecordsTableTableManager get exchangeListingRecords =>
      $$ExchangeListingRecordsTableTableManager(
        _db,
        _db.exchangeListingRecords,
      );
  $$ExchangeClaimRecordsTableTableManager get exchangeClaimRecords =>
      $$ExchangeClaimRecordsTableTableManager(_db, _db.exchangeClaimRecords);
  $$ExchangeSettingsTableTableManager get exchangeSettings =>
      $$ExchangeSettingsTableTableManager(_db, _db.exchangeSettings);
}
