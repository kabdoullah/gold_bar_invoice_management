// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $InvoicesTable extends Invoices
    with TableInfo<$InvoicesTable, InvoiceRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $InvoicesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _invoiceNumberMeta = const VerificationMeta(
    'invoiceNumber',
  );
  @override
  late final GeneratedColumn<String> invoiceNumber = GeneratedColumn<String>(
    'invoice_number',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _issueDateMeta = const VerificationMeta(
    'issueDate',
  );
  @override
  late final GeneratedColumn<DateTime> issueDate = GeneratedColumn<DateTime>(
    'issue_date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _locationMeta = const VerificationMeta(
    'location',
  );
  @override
  late final GeneratedColumn<String> location = GeneratedColumn<String>(
    'location',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('Bamako'),
  );
  static const VerificationMeta _basePriceMeta = const VerificationMeta(
    'basePrice',
  );
  @override
  late final GeneratedColumn<double> basePrice = GeneratedColumn<double>(
    'base_price',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('draft'),
  );
  static const VerificationMeta _barCountMeta = const VerificationMeta(
    'barCount',
  );
  @override
  late final GeneratedColumn<int> barCount = GeneratedColumn<int>(
    'bar_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _totalGrossWeightMeta = const VerificationMeta(
    'totalGrossWeight',
  );
  @override
  late final GeneratedColumn<double> totalGrossWeight = GeneratedColumn<double>(
    'total_gross_weight',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _totalWaterWeightMeta = const VerificationMeta(
    'totalWaterWeight',
  );
  @override
  late final GeneratedColumn<double> totalWaterWeight = GeneratedColumn<double>(
    'total_water_weight',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _totalAmountMeta = const VerificationMeta(
    'totalAmount',
  );
  @override
  late final GeneratedColumn<double> totalAmount = GeneratedColumn<double>(
    'total_amount',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
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
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
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
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    invoiceNumber,
    issueDate,
    location,
    basePrice,
    status,
    barCount,
    totalGrossWeight,
    totalWaterWeight,
    totalAmount,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'invoices';
  @override
  VerificationContext validateIntegrity(
    Insertable<InvoiceRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('invoice_number')) {
      context.handle(
        _invoiceNumberMeta,
        invoiceNumber.isAcceptableOrUnknown(
          data['invoice_number']!,
          _invoiceNumberMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_invoiceNumberMeta);
    }
    if (data.containsKey('issue_date')) {
      context.handle(
        _issueDateMeta,
        issueDate.isAcceptableOrUnknown(data['issue_date']!, _issueDateMeta),
      );
    } else if (isInserting) {
      context.missing(_issueDateMeta);
    }
    if (data.containsKey('location')) {
      context.handle(
        _locationMeta,
        location.isAcceptableOrUnknown(data['location']!, _locationMeta),
      );
    }
    if (data.containsKey('base_price')) {
      context.handle(
        _basePriceMeta,
        basePrice.isAcceptableOrUnknown(data['base_price']!, _basePriceMeta),
      );
    } else if (isInserting) {
      context.missing(_basePriceMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('bar_count')) {
      context.handle(
        _barCountMeta,
        barCount.isAcceptableOrUnknown(data['bar_count']!, _barCountMeta),
      );
    }
    if (data.containsKey('total_gross_weight')) {
      context.handle(
        _totalGrossWeightMeta,
        totalGrossWeight.isAcceptableOrUnknown(
          data['total_gross_weight']!,
          _totalGrossWeightMeta,
        ),
      );
    }
    if (data.containsKey('total_water_weight')) {
      context.handle(
        _totalWaterWeightMeta,
        totalWaterWeight.isAcceptableOrUnknown(
          data['total_water_weight']!,
          _totalWaterWeightMeta,
        ),
      );
    }
    if (data.containsKey('total_amount')) {
      context.handle(
        _totalAmountMeta,
        totalAmount.isAcceptableOrUnknown(
          data['total_amount']!,
          _totalAmountMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  InvoiceRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return InvoiceRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      invoiceNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}invoice_number'],
      )!,
      issueDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}issue_date'],
      )!,
      location: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}location'],
      )!,
      basePrice: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}base_price'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      barCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}bar_count'],
      )!,
      totalGrossWeight: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}total_gross_weight'],
      )!,
      totalWaterWeight: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}total_water_weight'],
      )!,
      totalAmount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}total_amount'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $InvoicesTable createAlias(String alias) {
    return $InvoicesTable(attachedDatabase, alias);
  }
}

class InvoiceRow extends DataClass implements Insertable<InvoiceRow> {
  final int id;
  final String invoiceNumber;
  final DateTime issueDate;
  final String location;
  final double basePrice;

  /// 'draft' | 'saved' — see domain `InvoiceStatus.dbValue`.
  final String status;
  final int barCount;
  final double totalGrossWeight;
  final double totalWaterWeight;
  final double totalAmount;
  final DateTime createdAt;
  final DateTime updatedAt;
  const InvoiceRow({
    required this.id,
    required this.invoiceNumber,
    required this.issueDate,
    required this.location,
    required this.basePrice,
    required this.status,
    required this.barCount,
    required this.totalGrossWeight,
    required this.totalWaterWeight,
    required this.totalAmount,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['invoice_number'] = Variable<String>(invoiceNumber);
    map['issue_date'] = Variable<DateTime>(issueDate);
    map['location'] = Variable<String>(location);
    map['base_price'] = Variable<double>(basePrice);
    map['status'] = Variable<String>(status);
    map['bar_count'] = Variable<int>(barCount);
    map['total_gross_weight'] = Variable<double>(totalGrossWeight);
    map['total_water_weight'] = Variable<double>(totalWaterWeight);
    map['total_amount'] = Variable<double>(totalAmount);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  InvoicesCompanion toCompanion(bool nullToAbsent) {
    return InvoicesCompanion(
      id: Value(id),
      invoiceNumber: Value(invoiceNumber),
      issueDate: Value(issueDate),
      location: Value(location),
      basePrice: Value(basePrice),
      status: Value(status),
      barCount: Value(barCount),
      totalGrossWeight: Value(totalGrossWeight),
      totalWaterWeight: Value(totalWaterWeight),
      totalAmount: Value(totalAmount),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory InvoiceRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return InvoiceRow(
      id: serializer.fromJson<int>(json['id']),
      invoiceNumber: serializer.fromJson<String>(json['invoiceNumber']),
      issueDate: serializer.fromJson<DateTime>(json['issueDate']),
      location: serializer.fromJson<String>(json['location']),
      basePrice: serializer.fromJson<double>(json['basePrice']),
      status: serializer.fromJson<String>(json['status']),
      barCount: serializer.fromJson<int>(json['barCount']),
      totalGrossWeight: serializer.fromJson<double>(json['totalGrossWeight']),
      totalWaterWeight: serializer.fromJson<double>(json['totalWaterWeight']),
      totalAmount: serializer.fromJson<double>(json['totalAmount']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'invoiceNumber': serializer.toJson<String>(invoiceNumber),
      'issueDate': serializer.toJson<DateTime>(issueDate),
      'location': serializer.toJson<String>(location),
      'basePrice': serializer.toJson<double>(basePrice),
      'status': serializer.toJson<String>(status),
      'barCount': serializer.toJson<int>(barCount),
      'totalGrossWeight': serializer.toJson<double>(totalGrossWeight),
      'totalWaterWeight': serializer.toJson<double>(totalWaterWeight),
      'totalAmount': serializer.toJson<double>(totalAmount),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  InvoiceRow copyWith({
    int? id,
    String? invoiceNumber,
    DateTime? issueDate,
    String? location,
    double? basePrice,
    String? status,
    int? barCount,
    double? totalGrossWeight,
    double? totalWaterWeight,
    double? totalAmount,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => InvoiceRow(
    id: id ?? this.id,
    invoiceNumber: invoiceNumber ?? this.invoiceNumber,
    issueDate: issueDate ?? this.issueDate,
    location: location ?? this.location,
    basePrice: basePrice ?? this.basePrice,
    status: status ?? this.status,
    barCount: barCount ?? this.barCount,
    totalGrossWeight: totalGrossWeight ?? this.totalGrossWeight,
    totalWaterWeight: totalWaterWeight ?? this.totalWaterWeight,
    totalAmount: totalAmount ?? this.totalAmount,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  InvoiceRow copyWithCompanion(InvoicesCompanion data) {
    return InvoiceRow(
      id: data.id.present ? data.id.value : this.id,
      invoiceNumber: data.invoiceNumber.present
          ? data.invoiceNumber.value
          : this.invoiceNumber,
      issueDate: data.issueDate.present ? data.issueDate.value : this.issueDate,
      location: data.location.present ? data.location.value : this.location,
      basePrice: data.basePrice.present ? data.basePrice.value : this.basePrice,
      status: data.status.present ? data.status.value : this.status,
      barCount: data.barCount.present ? data.barCount.value : this.barCount,
      totalGrossWeight: data.totalGrossWeight.present
          ? data.totalGrossWeight.value
          : this.totalGrossWeight,
      totalWaterWeight: data.totalWaterWeight.present
          ? data.totalWaterWeight.value
          : this.totalWaterWeight,
      totalAmount: data.totalAmount.present
          ? data.totalAmount.value
          : this.totalAmount,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('InvoiceRow(')
          ..write('id: $id, ')
          ..write('invoiceNumber: $invoiceNumber, ')
          ..write('issueDate: $issueDate, ')
          ..write('location: $location, ')
          ..write('basePrice: $basePrice, ')
          ..write('status: $status, ')
          ..write('barCount: $barCount, ')
          ..write('totalGrossWeight: $totalGrossWeight, ')
          ..write('totalWaterWeight: $totalWaterWeight, ')
          ..write('totalAmount: $totalAmount, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    invoiceNumber,
    issueDate,
    location,
    basePrice,
    status,
    barCount,
    totalGrossWeight,
    totalWaterWeight,
    totalAmount,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is InvoiceRow &&
          other.id == this.id &&
          other.invoiceNumber == this.invoiceNumber &&
          other.issueDate == this.issueDate &&
          other.location == this.location &&
          other.basePrice == this.basePrice &&
          other.status == this.status &&
          other.barCount == this.barCount &&
          other.totalGrossWeight == this.totalGrossWeight &&
          other.totalWaterWeight == this.totalWaterWeight &&
          other.totalAmount == this.totalAmount &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class InvoicesCompanion extends UpdateCompanion<InvoiceRow> {
  final Value<int> id;
  final Value<String> invoiceNumber;
  final Value<DateTime> issueDate;
  final Value<String> location;
  final Value<double> basePrice;
  final Value<String> status;
  final Value<int> barCount;
  final Value<double> totalGrossWeight;
  final Value<double> totalWaterWeight;
  final Value<double> totalAmount;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const InvoicesCompanion({
    this.id = const Value.absent(),
    this.invoiceNumber = const Value.absent(),
    this.issueDate = const Value.absent(),
    this.location = const Value.absent(),
    this.basePrice = const Value.absent(),
    this.status = const Value.absent(),
    this.barCount = const Value.absent(),
    this.totalGrossWeight = const Value.absent(),
    this.totalWaterWeight = const Value.absent(),
    this.totalAmount = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  InvoicesCompanion.insert({
    this.id = const Value.absent(),
    required String invoiceNumber,
    required DateTime issueDate,
    this.location = const Value.absent(),
    required double basePrice,
    this.status = const Value.absent(),
    this.barCount = const Value.absent(),
    this.totalGrossWeight = const Value.absent(),
    this.totalWaterWeight = const Value.absent(),
    this.totalAmount = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  }) : invoiceNumber = Value(invoiceNumber),
       issueDate = Value(issueDate),
       basePrice = Value(basePrice);
  static Insertable<InvoiceRow> custom({
    Expression<int>? id,
    Expression<String>? invoiceNumber,
    Expression<DateTime>? issueDate,
    Expression<String>? location,
    Expression<double>? basePrice,
    Expression<String>? status,
    Expression<int>? barCount,
    Expression<double>? totalGrossWeight,
    Expression<double>? totalWaterWeight,
    Expression<double>? totalAmount,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (invoiceNumber != null) 'invoice_number': invoiceNumber,
      if (issueDate != null) 'issue_date': issueDate,
      if (location != null) 'location': location,
      if (basePrice != null) 'base_price': basePrice,
      if (status != null) 'status': status,
      if (barCount != null) 'bar_count': barCount,
      if (totalGrossWeight != null) 'total_gross_weight': totalGrossWeight,
      if (totalWaterWeight != null) 'total_water_weight': totalWaterWeight,
      if (totalAmount != null) 'total_amount': totalAmount,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  InvoicesCompanion copyWith({
    Value<int>? id,
    Value<String>? invoiceNumber,
    Value<DateTime>? issueDate,
    Value<String>? location,
    Value<double>? basePrice,
    Value<String>? status,
    Value<int>? barCount,
    Value<double>? totalGrossWeight,
    Value<double>? totalWaterWeight,
    Value<double>? totalAmount,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
  }) {
    return InvoicesCompanion(
      id: id ?? this.id,
      invoiceNumber: invoiceNumber ?? this.invoiceNumber,
      issueDate: issueDate ?? this.issueDate,
      location: location ?? this.location,
      basePrice: basePrice ?? this.basePrice,
      status: status ?? this.status,
      barCount: barCount ?? this.barCount,
      totalGrossWeight: totalGrossWeight ?? this.totalGrossWeight,
      totalWaterWeight: totalWaterWeight ?? this.totalWaterWeight,
      totalAmount: totalAmount ?? this.totalAmount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (invoiceNumber.present) {
      map['invoice_number'] = Variable<String>(invoiceNumber.value);
    }
    if (issueDate.present) {
      map['issue_date'] = Variable<DateTime>(issueDate.value);
    }
    if (location.present) {
      map['location'] = Variable<String>(location.value);
    }
    if (basePrice.present) {
      map['base_price'] = Variable<double>(basePrice.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (barCount.present) {
      map['bar_count'] = Variable<int>(barCount.value);
    }
    if (totalGrossWeight.present) {
      map['total_gross_weight'] = Variable<double>(totalGrossWeight.value);
    }
    if (totalWaterWeight.present) {
      map['total_water_weight'] = Variable<double>(totalWaterWeight.value);
    }
    if (totalAmount.present) {
      map['total_amount'] = Variable<double>(totalAmount.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('InvoicesCompanion(')
          ..write('id: $id, ')
          ..write('invoiceNumber: $invoiceNumber, ')
          ..write('issueDate: $issueDate, ')
          ..write('location: $location, ')
          ..write('basePrice: $basePrice, ')
          ..write('status: $status, ')
          ..write('barCount: $barCount, ')
          ..write('totalGrossWeight: $totalGrossWeight, ')
          ..write('totalWaterWeight: $totalWaterWeight, ')
          ..write('totalAmount: $totalAmount, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $InvoiceLinesTable extends InvoiceLines
    with TableInfo<$InvoiceLinesTable, InvoiceLineRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $InvoiceLinesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _invoiceIdMeta = const VerificationMeta(
    'invoiceId',
  );
  @override
  late final GeneratedColumn<int> invoiceId = GeneratedColumn<int>(
    'invoice_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES invoices (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _barNumberMeta = const VerificationMeta(
    'barNumber',
  );
  @override
  late final GeneratedColumn<int> barNumber = GeneratedColumn<int>(
    'bar_number',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _basePriceMeta = const VerificationMeta(
    'basePrice',
  );
  @override
  late final GeneratedColumn<double> basePrice = GeneratedColumn<double>(
    'base_price',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _grossWeightMeta = const VerificationMeta(
    'grossWeight',
  );
  @override
  late final GeneratedColumn<double> grossWeight = GeneratedColumn<double>(
    'gross_weight',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _waterWeightMeta = const VerificationMeta(
    'waterWeight',
  );
  @override
  late final GeneratedColumn<double> waterWeight = GeneratedColumn<double>(
    'water_weight',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _densityMeta = const VerificationMeta(
    'density',
  );
  @override
  late final GeneratedColumn<double> density = GeneratedColumn<double>(
    'density',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _caratMeta = const VerificationMeta('carat');
  @override
  late final GeneratedColumn<double> carat = GeneratedColumn<double>(
    'carat',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _unitPriceMeta = const VerificationMeta(
    'unitPrice',
  );
  @override
  late final GeneratedColumn<double> unitPrice = GeneratedColumn<double>(
    'unit_price',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<double> amount = GeneratedColumn<double>(
    'amount',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    invoiceId,
    barNumber,
    basePrice,
    grossWeight,
    waterWeight,
    density,
    carat,
    unitPrice,
    amount,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'invoice_lines';
  @override
  VerificationContext validateIntegrity(
    Insertable<InvoiceLineRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('invoice_id')) {
      context.handle(
        _invoiceIdMeta,
        invoiceId.isAcceptableOrUnknown(data['invoice_id']!, _invoiceIdMeta),
      );
    } else if (isInserting) {
      context.missing(_invoiceIdMeta);
    }
    if (data.containsKey('bar_number')) {
      context.handle(
        _barNumberMeta,
        barNumber.isAcceptableOrUnknown(data['bar_number']!, _barNumberMeta),
      );
    } else if (isInserting) {
      context.missing(_barNumberMeta);
    }
    if (data.containsKey('base_price')) {
      context.handle(
        _basePriceMeta,
        basePrice.isAcceptableOrUnknown(data['base_price']!, _basePriceMeta),
      );
    } else if (isInserting) {
      context.missing(_basePriceMeta);
    }
    if (data.containsKey('gross_weight')) {
      context.handle(
        _grossWeightMeta,
        grossWeight.isAcceptableOrUnknown(
          data['gross_weight']!,
          _grossWeightMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_grossWeightMeta);
    }
    if (data.containsKey('water_weight')) {
      context.handle(
        _waterWeightMeta,
        waterWeight.isAcceptableOrUnknown(
          data['water_weight']!,
          _waterWeightMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_waterWeightMeta);
    }
    if (data.containsKey('density')) {
      context.handle(
        _densityMeta,
        density.isAcceptableOrUnknown(data['density']!, _densityMeta),
      );
    } else if (isInserting) {
      context.missing(_densityMeta);
    }
    if (data.containsKey('carat')) {
      context.handle(
        _caratMeta,
        carat.isAcceptableOrUnknown(data['carat']!, _caratMeta),
      );
    } else if (isInserting) {
      context.missing(_caratMeta);
    }
    if (data.containsKey('unit_price')) {
      context.handle(
        _unitPriceMeta,
        unitPrice.isAcceptableOrUnknown(data['unit_price']!, _unitPriceMeta),
      );
    } else if (isInserting) {
      context.missing(_unitPriceMeta);
    }
    if (data.containsKey('amount')) {
      context.handle(
        _amountMeta,
        amount.isAcceptableOrUnknown(data['amount']!, _amountMeta),
      );
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  InvoiceLineRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return InvoiceLineRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      invoiceId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}invoice_id'],
      )!,
      barNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}bar_number'],
      )!,
      basePrice: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}base_price'],
      )!,
      grossWeight: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}gross_weight'],
      )!,
      waterWeight: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}water_weight'],
      )!,
      density: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}density'],
      )!,
      carat: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}carat'],
      )!,
      unitPrice: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}unit_price'],
      )!,
      amount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}amount'],
      )!,
    );
  }

  @override
  $InvoiceLinesTable createAlias(String alias) {
    return $InvoiceLinesTable(attachedDatabase, alias);
  }
}

class InvoiceLineRow extends DataClass implements Insertable<InvoiceLineRow> {
  final int id;

  /// Cascade delete: discarding a draft invoice removes its lines.
  final int invoiceId;

  /// Position of the bar in the invoice: 1, 2, 3...
  final int barNumber;
  final double basePrice;
  final double grossWeight;
  final double waterWeight;
  final double density;
  final double carat;
  final double unitPrice;
  final double amount;
  const InvoiceLineRow({
    required this.id,
    required this.invoiceId,
    required this.barNumber,
    required this.basePrice,
    required this.grossWeight,
    required this.waterWeight,
    required this.density,
    required this.carat,
    required this.unitPrice,
    required this.amount,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['invoice_id'] = Variable<int>(invoiceId);
    map['bar_number'] = Variable<int>(barNumber);
    map['base_price'] = Variable<double>(basePrice);
    map['gross_weight'] = Variable<double>(grossWeight);
    map['water_weight'] = Variable<double>(waterWeight);
    map['density'] = Variable<double>(density);
    map['carat'] = Variable<double>(carat);
    map['unit_price'] = Variable<double>(unitPrice);
    map['amount'] = Variable<double>(amount);
    return map;
  }

  InvoiceLinesCompanion toCompanion(bool nullToAbsent) {
    return InvoiceLinesCompanion(
      id: Value(id),
      invoiceId: Value(invoiceId),
      barNumber: Value(barNumber),
      basePrice: Value(basePrice),
      grossWeight: Value(grossWeight),
      waterWeight: Value(waterWeight),
      density: Value(density),
      carat: Value(carat),
      unitPrice: Value(unitPrice),
      amount: Value(amount),
    );
  }

  factory InvoiceLineRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return InvoiceLineRow(
      id: serializer.fromJson<int>(json['id']),
      invoiceId: serializer.fromJson<int>(json['invoiceId']),
      barNumber: serializer.fromJson<int>(json['barNumber']),
      basePrice: serializer.fromJson<double>(json['basePrice']),
      grossWeight: serializer.fromJson<double>(json['grossWeight']),
      waterWeight: serializer.fromJson<double>(json['waterWeight']),
      density: serializer.fromJson<double>(json['density']),
      carat: serializer.fromJson<double>(json['carat']),
      unitPrice: serializer.fromJson<double>(json['unitPrice']),
      amount: serializer.fromJson<double>(json['amount']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'invoiceId': serializer.toJson<int>(invoiceId),
      'barNumber': serializer.toJson<int>(barNumber),
      'basePrice': serializer.toJson<double>(basePrice),
      'grossWeight': serializer.toJson<double>(grossWeight),
      'waterWeight': serializer.toJson<double>(waterWeight),
      'density': serializer.toJson<double>(density),
      'carat': serializer.toJson<double>(carat),
      'unitPrice': serializer.toJson<double>(unitPrice),
      'amount': serializer.toJson<double>(amount),
    };
  }

  InvoiceLineRow copyWith({
    int? id,
    int? invoiceId,
    int? barNumber,
    double? basePrice,
    double? grossWeight,
    double? waterWeight,
    double? density,
    double? carat,
    double? unitPrice,
    double? amount,
  }) => InvoiceLineRow(
    id: id ?? this.id,
    invoiceId: invoiceId ?? this.invoiceId,
    barNumber: barNumber ?? this.barNumber,
    basePrice: basePrice ?? this.basePrice,
    grossWeight: grossWeight ?? this.grossWeight,
    waterWeight: waterWeight ?? this.waterWeight,
    density: density ?? this.density,
    carat: carat ?? this.carat,
    unitPrice: unitPrice ?? this.unitPrice,
    amount: amount ?? this.amount,
  );
  InvoiceLineRow copyWithCompanion(InvoiceLinesCompanion data) {
    return InvoiceLineRow(
      id: data.id.present ? data.id.value : this.id,
      invoiceId: data.invoiceId.present ? data.invoiceId.value : this.invoiceId,
      barNumber: data.barNumber.present ? data.barNumber.value : this.barNumber,
      basePrice: data.basePrice.present ? data.basePrice.value : this.basePrice,
      grossWeight: data.grossWeight.present
          ? data.grossWeight.value
          : this.grossWeight,
      waterWeight: data.waterWeight.present
          ? data.waterWeight.value
          : this.waterWeight,
      density: data.density.present ? data.density.value : this.density,
      carat: data.carat.present ? data.carat.value : this.carat,
      unitPrice: data.unitPrice.present ? data.unitPrice.value : this.unitPrice,
      amount: data.amount.present ? data.amount.value : this.amount,
    );
  }

  @override
  String toString() {
    return (StringBuffer('InvoiceLineRow(')
          ..write('id: $id, ')
          ..write('invoiceId: $invoiceId, ')
          ..write('barNumber: $barNumber, ')
          ..write('basePrice: $basePrice, ')
          ..write('grossWeight: $grossWeight, ')
          ..write('waterWeight: $waterWeight, ')
          ..write('density: $density, ')
          ..write('carat: $carat, ')
          ..write('unitPrice: $unitPrice, ')
          ..write('amount: $amount')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    invoiceId,
    barNumber,
    basePrice,
    grossWeight,
    waterWeight,
    density,
    carat,
    unitPrice,
    amount,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is InvoiceLineRow &&
          other.id == this.id &&
          other.invoiceId == this.invoiceId &&
          other.barNumber == this.barNumber &&
          other.basePrice == this.basePrice &&
          other.grossWeight == this.grossWeight &&
          other.waterWeight == this.waterWeight &&
          other.density == this.density &&
          other.carat == this.carat &&
          other.unitPrice == this.unitPrice &&
          other.amount == this.amount);
}

class InvoiceLinesCompanion extends UpdateCompanion<InvoiceLineRow> {
  final Value<int> id;
  final Value<int> invoiceId;
  final Value<int> barNumber;
  final Value<double> basePrice;
  final Value<double> grossWeight;
  final Value<double> waterWeight;
  final Value<double> density;
  final Value<double> carat;
  final Value<double> unitPrice;
  final Value<double> amount;
  const InvoiceLinesCompanion({
    this.id = const Value.absent(),
    this.invoiceId = const Value.absent(),
    this.barNumber = const Value.absent(),
    this.basePrice = const Value.absent(),
    this.grossWeight = const Value.absent(),
    this.waterWeight = const Value.absent(),
    this.density = const Value.absent(),
    this.carat = const Value.absent(),
    this.unitPrice = const Value.absent(),
    this.amount = const Value.absent(),
  });
  InvoiceLinesCompanion.insert({
    this.id = const Value.absent(),
    required int invoiceId,
    required int barNumber,
    required double basePrice,
    required double grossWeight,
    required double waterWeight,
    required double density,
    required double carat,
    required double unitPrice,
    required double amount,
  }) : invoiceId = Value(invoiceId),
       barNumber = Value(barNumber),
       basePrice = Value(basePrice),
       grossWeight = Value(grossWeight),
       waterWeight = Value(waterWeight),
       density = Value(density),
       carat = Value(carat),
       unitPrice = Value(unitPrice),
       amount = Value(amount);
  static Insertable<InvoiceLineRow> custom({
    Expression<int>? id,
    Expression<int>? invoiceId,
    Expression<int>? barNumber,
    Expression<double>? basePrice,
    Expression<double>? grossWeight,
    Expression<double>? waterWeight,
    Expression<double>? density,
    Expression<double>? carat,
    Expression<double>? unitPrice,
    Expression<double>? amount,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (invoiceId != null) 'invoice_id': invoiceId,
      if (barNumber != null) 'bar_number': barNumber,
      if (basePrice != null) 'base_price': basePrice,
      if (grossWeight != null) 'gross_weight': grossWeight,
      if (waterWeight != null) 'water_weight': waterWeight,
      if (density != null) 'density': density,
      if (carat != null) 'carat': carat,
      if (unitPrice != null) 'unit_price': unitPrice,
      if (amount != null) 'amount': amount,
    });
  }

  InvoiceLinesCompanion copyWith({
    Value<int>? id,
    Value<int>? invoiceId,
    Value<int>? barNumber,
    Value<double>? basePrice,
    Value<double>? grossWeight,
    Value<double>? waterWeight,
    Value<double>? density,
    Value<double>? carat,
    Value<double>? unitPrice,
    Value<double>? amount,
  }) {
    return InvoiceLinesCompanion(
      id: id ?? this.id,
      invoiceId: invoiceId ?? this.invoiceId,
      barNumber: barNumber ?? this.barNumber,
      basePrice: basePrice ?? this.basePrice,
      grossWeight: grossWeight ?? this.grossWeight,
      waterWeight: waterWeight ?? this.waterWeight,
      density: density ?? this.density,
      carat: carat ?? this.carat,
      unitPrice: unitPrice ?? this.unitPrice,
      amount: amount ?? this.amount,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (invoiceId.present) {
      map['invoice_id'] = Variable<int>(invoiceId.value);
    }
    if (barNumber.present) {
      map['bar_number'] = Variable<int>(barNumber.value);
    }
    if (basePrice.present) {
      map['base_price'] = Variable<double>(basePrice.value);
    }
    if (grossWeight.present) {
      map['gross_weight'] = Variable<double>(grossWeight.value);
    }
    if (waterWeight.present) {
      map['water_weight'] = Variable<double>(waterWeight.value);
    }
    if (density.present) {
      map['density'] = Variable<double>(density.value);
    }
    if (carat.present) {
      map['carat'] = Variable<double>(carat.value);
    }
    if (unitPrice.present) {
      map['unit_price'] = Variable<double>(unitPrice.value);
    }
    if (amount.present) {
      map['amount'] = Variable<double>(amount.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('InvoiceLinesCompanion(')
          ..write('id: $id, ')
          ..write('invoiceId: $invoiceId, ')
          ..write('barNumber: $barNumber, ')
          ..write('basePrice: $basePrice, ')
          ..write('grossWeight: $grossWeight, ')
          ..write('waterWeight: $waterWeight, ')
          ..write('density: $density, ')
          ..write('carat: $carat, ')
          ..write('unitPrice: $unitPrice, ')
          ..write('amount: $amount')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $InvoicesTable invoices = $InvoicesTable(this);
  late final $InvoiceLinesTable invoiceLines = $InvoiceLinesTable(this);
  late final InvoiceDao invoiceDao = InvoiceDao(this as AppDatabase);
  late final InvoiceLineDao invoiceLineDao = InvoiceLineDao(
    this as AppDatabase,
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [invoices, invoiceLines];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'invoices',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('invoice_lines', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $$InvoicesTableCreateCompanionBuilder =
    InvoicesCompanion Function({
      Value<int> id,
      required String invoiceNumber,
      required DateTime issueDate,
      Value<String> location,
      required double basePrice,
      Value<String> status,
      Value<int> barCount,
      Value<double> totalGrossWeight,
      Value<double> totalWaterWeight,
      Value<double> totalAmount,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });
typedef $$InvoicesTableUpdateCompanionBuilder =
    InvoicesCompanion Function({
      Value<int> id,
      Value<String> invoiceNumber,
      Value<DateTime> issueDate,
      Value<String> location,
      Value<double> basePrice,
      Value<String> status,
      Value<int> barCount,
      Value<double> totalGrossWeight,
      Value<double> totalWaterWeight,
      Value<double> totalAmount,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });

final class $$InvoicesTableReferences
    extends BaseReferences<_$AppDatabase, $InvoicesTable, InvoiceRow> {
  $$InvoicesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$InvoiceLinesTable, List<InvoiceLineRow>>
  _invoiceLinesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.invoiceLines,
    aliasName: 'invoices__id__invoice_lines__invoice_id',
  );

  $$InvoiceLinesTableProcessedTableManager get invoiceLinesRefs {
    final manager = $$InvoiceLinesTableTableManager(
      $_db,
      $_db.invoiceLines,
    ).filter((f) => f.invoiceId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_invoiceLinesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$InvoicesTableFilterComposer
    extends Composer<_$AppDatabase, $InvoicesTable> {
  $$InvoicesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get invoiceNumber => $composableBuilder(
    column: $table.invoiceNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get issueDate => $composableBuilder(
    column: $table.issueDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get location => $composableBuilder(
    column: $table.location,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get basePrice => $composableBuilder(
    column: $table.basePrice,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get barCount => $composableBuilder(
    column: $table.barCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get totalGrossWeight => $composableBuilder(
    column: $table.totalGrossWeight,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get totalWaterWeight => $composableBuilder(
    column: $table.totalWaterWeight,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get totalAmount => $composableBuilder(
    column: $table.totalAmount,
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

  Expression<bool> invoiceLinesRefs(
    Expression<bool> Function($$InvoiceLinesTableFilterComposer f) f,
  ) {
    final $$InvoiceLinesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.invoiceLines,
      getReferencedColumn: (t) => t.invoiceId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$InvoiceLinesTableFilterComposer(
            $db: $db,
            $table: $db.invoiceLines,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$InvoicesTableOrderingComposer
    extends Composer<_$AppDatabase, $InvoicesTable> {
  $$InvoicesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get invoiceNumber => $composableBuilder(
    column: $table.invoiceNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get issueDate => $composableBuilder(
    column: $table.issueDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get location => $composableBuilder(
    column: $table.location,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get basePrice => $composableBuilder(
    column: $table.basePrice,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get barCount => $composableBuilder(
    column: $table.barCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get totalGrossWeight => $composableBuilder(
    column: $table.totalGrossWeight,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get totalWaterWeight => $composableBuilder(
    column: $table.totalWaterWeight,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get totalAmount => $composableBuilder(
    column: $table.totalAmount,
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
}

class $$InvoicesTableAnnotationComposer
    extends Composer<_$AppDatabase, $InvoicesTable> {
  $$InvoicesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get invoiceNumber => $composableBuilder(
    column: $table.invoiceNumber,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get issueDate =>
      $composableBuilder(column: $table.issueDate, builder: (column) => column);

  GeneratedColumn<String> get location =>
      $composableBuilder(column: $table.location, builder: (column) => column);

  GeneratedColumn<double> get basePrice =>
      $composableBuilder(column: $table.basePrice, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<int> get barCount =>
      $composableBuilder(column: $table.barCount, builder: (column) => column);

  GeneratedColumn<double> get totalGrossWeight => $composableBuilder(
    column: $table.totalGrossWeight,
    builder: (column) => column,
  );

  GeneratedColumn<double> get totalWaterWeight => $composableBuilder(
    column: $table.totalWaterWeight,
    builder: (column) => column,
  );

  GeneratedColumn<double> get totalAmount => $composableBuilder(
    column: $table.totalAmount,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  Expression<T> invoiceLinesRefs<T extends Object>(
    Expression<T> Function($$InvoiceLinesTableAnnotationComposer a) f,
  ) {
    final $$InvoiceLinesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.invoiceLines,
      getReferencedColumn: (t) => t.invoiceId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$InvoiceLinesTableAnnotationComposer(
            $db: $db,
            $table: $db.invoiceLines,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$InvoicesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $InvoicesTable,
          InvoiceRow,
          $$InvoicesTableFilterComposer,
          $$InvoicesTableOrderingComposer,
          $$InvoicesTableAnnotationComposer,
          $$InvoicesTableCreateCompanionBuilder,
          $$InvoicesTableUpdateCompanionBuilder,
          (InvoiceRow, $$InvoicesTableReferences),
          InvoiceRow,
          PrefetchHooks Function({bool invoiceLinesRefs})
        > {
  $$InvoicesTableTableManager(_$AppDatabase db, $InvoicesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$InvoicesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$InvoicesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$InvoicesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> invoiceNumber = const Value.absent(),
                Value<DateTime> issueDate = const Value.absent(),
                Value<String> location = const Value.absent(),
                Value<double> basePrice = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<int> barCount = const Value.absent(),
                Value<double> totalGrossWeight = const Value.absent(),
                Value<double> totalWaterWeight = const Value.absent(),
                Value<double> totalAmount = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => InvoicesCompanion(
                id: id,
                invoiceNumber: invoiceNumber,
                issueDate: issueDate,
                location: location,
                basePrice: basePrice,
                status: status,
                barCount: barCount,
                totalGrossWeight: totalGrossWeight,
                totalWaterWeight: totalWaterWeight,
                totalAmount: totalAmount,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String invoiceNumber,
                required DateTime issueDate,
                Value<String> location = const Value.absent(),
                required double basePrice,
                Value<String> status = const Value.absent(),
                Value<int> barCount = const Value.absent(),
                Value<double> totalGrossWeight = const Value.absent(),
                Value<double> totalWaterWeight = const Value.absent(),
                Value<double> totalAmount = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => InvoicesCompanion.insert(
                id: id,
                invoiceNumber: invoiceNumber,
                issueDate: issueDate,
                location: location,
                basePrice: basePrice,
                status: status,
                barCount: barCount,
                totalGrossWeight: totalGrossWeight,
                totalWaterWeight: totalWaterWeight,
                totalAmount: totalAmount,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$InvoicesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({invoiceLinesRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (invoiceLinesRefs) db.invoiceLines],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (invoiceLinesRefs)
                    await $_getPrefetchedData<
                      InvoiceRow,
                      $InvoicesTable,
                      InvoiceLineRow
                    >(
                      currentTable: table,
                      referencedTable: $$InvoicesTableReferences
                          ._invoiceLinesRefsTable(db),
                      managerFromTypedResult: (p0) => $$InvoicesTableReferences(
                        db,
                        table,
                        p0,
                      ).invoiceLinesRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.invoiceId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$InvoicesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $InvoicesTable,
      InvoiceRow,
      $$InvoicesTableFilterComposer,
      $$InvoicesTableOrderingComposer,
      $$InvoicesTableAnnotationComposer,
      $$InvoicesTableCreateCompanionBuilder,
      $$InvoicesTableUpdateCompanionBuilder,
      (InvoiceRow, $$InvoicesTableReferences),
      InvoiceRow,
      PrefetchHooks Function({bool invoiceLinesRefs})
    >;
typedef $$InvoiceLinesTableCreateCompanionBuilder =
    InvoiceLinesCompanion Function({
      Value<int> id,
      required int invoiceId,
      required int barNumber,
      required double basePrice,
      required double grossWeight,
      required double waterWeight,
      required double density,
      required double carat,
      required double unitPrice,
      required double amount,
    });
typedef $$InvoiceLinesTableUpdateCompanionBuilder =
    InvoiceLinesCompanion Function({
      Value<int> id,
      Value<int> invoiceId,
      Value<int> barNumber,
      Value<double> basePrice,
      Value<double> grossWeight,
      Value<double> waterWeight,
      Value<double> density,
      Value<double> carat,
      Value<double> unitPrice,
      Value<double> amount,
    });

final class $$InvoiceLinesTableReferences
    extends BaseReferences<_$AppDatabase, $InvoiceLinesTable, InvoiceLineRow> {
  $$InvoiceLinesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $InvoicesTable _invoiceIdTable(_$AppDatabase db) =>
      db.invoices.createAlias('invoice_lines__invoice_id__invoices__id');

  $$InvoicesTableProcessedTableManager get invoiceId {
    final $_column = $_itemColumn<int>('invoice_id')!;

    final manager = $$InvoicesTableTableManager(
      $_db,
      $_db.invoices,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_invoiceIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$InvoiceLinesTableFilterComposer
    extends Composer<_$AppDatabase, $InvoiceLinesTable> {
  $$InvoiceLinesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get barNumber => $composableBuilder(
    column: $table.barNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get basePrice => $composableBuilder(
    column: $table.basePrice,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get grossWeight => $composableBuilder(
    column: $table.grossWeight,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get waterWeight => $composableBuilder(
    column: $table.waterWeight,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get density => $composableBuilder(
    column: $table.density,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get carat => $composableBuilder(
    column: $table.carat,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get unitPrice => $composableBuilder(
    column: $table.unitPrice,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnFilters(column),
  );

  $$InvoicesTableFilterComposer get invoiceId {
    final $$InvoicesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.invoiceId,
      referencedTable: $db.invoices,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$InvoicesTableFilterComposer(
            $db: $db,
            $table: $db.invoices,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$InvoiceLinesTableOrderingComposer
    extends Composer<_$AppDatabase, $InvoiceLinesTable> {
  $$InvoiceLinesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get barNumber => $composableBuilder(
    column: $table.barNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get basePrice => $composableBuilder(
    column: $table.basePrice,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get grossWeight => $composableBuilder(
    column: $table.grossWeight,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get waterWeight => $composableBuilder(
    column: $table.waterWeight,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get density => $composableBuilder(
    column: $table.density,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get carat => $composableBuilder(
    column: $table.carat,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get unitPrice => $composableBuilder(
    column: $table.unitPrice,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnOrderings(column),
  );

  $$InvoicesTableOrderingComposer get invoiceId {
    final $$InvoicesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.invoiceId,
      referencedTable: $db.invoices,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$InvoicesTableOrderingComposer(
            $db: $db,
            $table: $db.invoices,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$InvoiceLinesTableAnnotationComposer
    extends Composer<_$AppDatabase, $InvoiceLinesTable> {
  $$InvoiceLinesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get barNumber =>
      $composableBuilder(column: $table.barNumber, builder: (column) => column);

  GeneratedColumn<double> get basePrice =>
      $composableBuilder(column: $table.basePrice, builder: (column) => column);

  GeneratedColumn<double> get grossWeight => $composableBuilder(
    column: $table.grossWeight,
    builder: (column) => column,
  );

  GeneratedColumn<double> get waterWeight => $composableBuilder(
    column: $table.waterWeight,
    builder: (column) => column,
  );

  GeneratedColumn<double> get density =>
      $composableBuilder(column: $table.density, builder: (column) => column);

  GeneratedColumn<double> get carat =>
      $composableBuilder(column: $table.carat, builder: (column) => column);

  GeneratedColumn<double> get unitPrice =>
      $composableBuilder(column: $table.unitPrice, builder: (column) => column);

  GeneratedColumn<double> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  $$InvoicesTableAnnotationComposer get invoiceId {
    final $$InvoicesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.invoiceId,
      referencedTable: $db.invoices,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$InvoicesTableAnnotationComposer(
            $db: $db,
            $table: $db.invoices,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$InvoiceLinesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $InvoiceLinesTable,
          InvoiceLineRow,
          $$InvoiceLinesTableFilterComposer,
          $$InvoiceLinesTableOrderingComposer,
          $$InvoiceLinesTableAnnotationComposer,
          $$InvoiceLinesTableCreateCompanionBuilder,
          $$InvoiceLinesTableUpdateCompanionBuilder,
          (InvoiceLineRow, $$InvoiceLinesTableReferences),
          InvoiceLineRow,
          PrefetchHooks Function({bool invoiceId})
        > {
  $$InvoiceLinesTableTableManager(_$AppDatabase db, $InvoiceLinesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$InvoiceLinesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$InvoiceLinesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$InvoiceLinesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> invoiceId = const Value.absent(),
                Value<int> barNumber = const Value.absent(),
                Value<double> basePrice = const Value.absent(),
                Value<double> grossWeight = const Value.absent(),
                Value<double> waterWeight = const Value.absent(),
                Value<double> density = const Value.absent(),
                Value<double> carat = const Value.absent(),
                Value<double> unitPrice = const Value.absent(),
                Value<double> amount = const Value.absent(),
              }) => InvoiceLinesCompanion(
                id: id,
                invoiceId: invoiceId,
                barNumber: barNumber,
                basePrice: basePrice,
                grossWeight: grossWeight,
                waterWeight: waterWeight,
                density: density,
                carat: carat,
                unitPrice: unitPrice,
                amount: amount,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int invoiceId,
                required int barNumber,
                required double basePrice,
                required double grossWeight,
                required double waterWeight,
                required double density,
                required double carat,
                required double unitPrice,
                required double amount,
              }) => InvoiceLinesCompanion.insert(
                id: id,
                invoiceId: invoiceId,
                barNumber: barNumber,
                basePrice: basePrice,
                grossWeight: grossWeight,
                waterWeight: waterWeight,
                density: density,
                carat: carat,
                unitPrice: unitPrice,
                amount: amount,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$InvoiceLinesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({invoiceId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (invoiceId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.invoiceId,
                                referencedTable: $$InvoiceLinesTableReferences
                                    ._invoiceIdTable(db),
                                referencedColumn: $$InvoiceLinesTableReferences
                                    ._invoiceIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$InvoiceLinesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $InvoiceLinesTable,
      InvoiceLineRow,
      $$InvoiceLinesTableFilterComposer,
      $$InvoiceLinesTableOrderingComposer,
      $$InvoiceLinesTableAnnotationComposer,
      $$InvoiceLinesTableCreateCompanionBuilder,
      $$InvoiceLinesTableUpdateCompanionBuilder,
      (InvoiceLineRow, $$InvoiceLinesTableReferences),
      InvoiceLineRow,
      PrefetchHooks Function({bool invoiceId})
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$InvoicesTableTableManager get invoices =>
      $$InvoicesTableTableManager(_db, _db.invoices);
  $$InvoiceLinesTableTableManager get invoiceLines =>
      $$InvoiceLinesTableTableManager(_db, _db.invoiceLines);
}
