// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'invoice_line.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$InvoiceLine {

 int get id; int get invoiceId;/// Position of the bar in the invoice: 1, 2, 3...
 int get barNumber;/// Market base price at the time the line was entered.
 double get basePrice;/// Weight of the bar in grams, in air ("Poids brut").
 double get grossWeight;/// Weight of the bar submerged in water ("Eaux") — hydrostatic method.
 double get waterWeight;/// grossWeight / waterWeight, truncated to 2 decimals.
 double get density;/// Gold purity, derived from density. Always displayed in red.
 double get carat;/// Price per gram for this bar ("U/BASE").
 double get unitPrice;/// Line total: unitPrice × grossWeight ("Montant").
 double get amount; DateTime? get syncedAt;
/// Create a copy of InvoiceLine
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$InvoiceLineCopyWith<InvoiceLine> get copyWith => _$InvoiceLineCopyWithImpl<InvoiceLine>(this as InvoiceLine, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is InvoiceLine&&(identical(other.id, id) || other.id == id)&&(identical(other.invoiceId, invoiceId) || other.invoiceId == invoiceId)&&(identical(other.barNumber, barNumber) || other.barNumber == barNumber)&&(identical(other.basePrice, basePrice) || other.basePrice == basePrice)&&(identical(other.grossWeight, grossWeight) || other.grossWeight == grossWeight)&&(identical(other.waterWeight, waterWeight) || other.waterWeight == waterWeight)&&(identical(other.density, density) || other.density == density)&&(identical(other.carat, carat) || other.carat == carat)&&(identical(other.unitPrice, unitPrice) || other.unitPrice == unitPrice)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.syncedAt, syncedAt) || other.syncedAt == syncedAt));
}


@override
int get hashCode => Object.hash(runtimeType,id,invoiceId,barNumber,basePrice,grossWeight,waterWeight,density,carat,unitPrice,amount,syncedAt);

@override
String toString() {
  return 'InvoiceLine(id: $id, invoiceId: $invoiceId, barNumber: $barNumber, basePrice: $basePrice, grossWeight: $grossWeight, waterWeight: $waterWeight, density: $density, carat: $carat, unitPrice: $unitPrice, amount: $amount, syncedAt: $syncedAt)';
}


}

/// @nodoc
abstract mixin class $InvoiceLineCopyWith<$Res>  {
  factory $InvoiceLineCopyWith(InvoiceLine value, $Res Function(InvoiceLine) _then) = _$InvoiceLineCopyWithImpl;
@useResult
$Res call({
 int id, int invoiceId, int barNumber, double basePrice, double grossWeight, double waterWeight, double density, double carat, double unitPrice, double amount, DateTime? syncedAt
});




}
/// @nodoc
class _$InvoiceLineCopyWithImpl<$Res>
    implements $InvoiceLineCopyWith<$Res> {
  _$InvoiceLineCopyWithImpl(this._self, this._then);

  final InvoiceLine _self;
  final $Res Function(InvoiceLine) _then;

/// Create a copy of InvoiceLine
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? invoiceId = null,Object? barNumber = null,Object? basePrice = null,Object? grossWeight = null,Object? waterWeight = null,Object? density = null,Object? carat = null,Object? unitPrice = null,Object? amount = null,Object? syncedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,invoiceId: null == invoiceId ? _self.invoiceId : invoiceId // ignore: cast_nullable_to_non_nullable
as int,barNumber: null == barNumber ? _self.barNumber : barNumber // ignore: cast_nullable_to_non_nullable
as int,basePrice: null == basePrice ? _self.basePrice : basePrice // ignore: cast_nullable_to_non_nullable
as double,grossWeight: null == grossWeight ? _self.grossWeight : grossWeight // ignore: cast_nullable_to_non_nullable
as double,waterWeight: null == waterWeight ? _self.waterWeight : waterWeight // ignore: cast_nullable_to_non_nullable
as double,density: null == density ? _self.density : density // ignore: cast_nullable_to_non_nullable
as double,carat: null == carat ? _self.carat : carat // ignore: cast_nullable_to_non_nullable
as double,unitPrice: null == unitPrice ? _self.unitPrice : unitPrice // ignore: cast_nullable_to_non_nullable
as double,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as double,syncedAt: freezed == syncedAt ? _self.syncedAt : syncedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [InvoiceLine].
extension InvoiceLinePatterns on InvoiceLine {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _InvoiceLine value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _InvoiceLine() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _InvoiceLine value)  $default,){
final _that = this;
switch (_that) {
case _InvoiceLine():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _InvoiceLine value)?  $default,){
final _that = this;
switch (_that) {
case _InvoiceLine() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  int invoiceId,  int barNumber,  double basePrice,  double grossWeight,  double waterWeight,  double density,  double carat,  double unitPrice,  double amount,  DateTime? syncedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _InvoiceLine() when $default != null:
return $default(_that.id,_that.invoiceId,_that.barNumber,_that.basePrice,_that.grossWeight,_that.waterWeight,_that.density,_that.carat,_that.unitPrice,_that.amount,_that.syncedAt);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  int invoiceId,  int barNumber,  double basePrice,  double grossWeight,  double waterWeight,  double density,  double carat,  double unitPrice,  double amount,  DateTime? syncedAt)  $default,) {final _that = this;
switch (_that) {
case _InvoiceLine():
return $default(_that.id,_that.invoiceId,_that.barNumber,_that.basePrice,_that.grossWeight,_that.waterWeight,_that.density,_that.carat,_that.unitPrice,_that.amount,_that.syncedAt);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  int invoiceId,  int barNumber,  double basePrice,  double grossWeight,  double waterWeight,  double density,  double carat,  double unitPrice,  double amount,  DateTime? syncedAt)?  $default,) {final _that = this;
switch (_that) {
case _InvoiceLine() when $default != null:
return $default(_that.id,_that.invoiceId,_that.barNumber,_that.basePrice,_that.grossWeight,_that.waterWeight,_that.density,_that.carat,_that.unitPrice,_that.amount,_that.syncedAt);case _:
  return null;

}
}

}

/// @nodoc


class _InvoiceLine implements InvoiceLine {
  const _InvoiceLine({required this.id, required this.invoiceId, required this.barNumber, required this.basePrice, required this.grossWeight, required this.waterWeight, required this.density, required this.carat, required this.unitPrice, required this.amount, this.syncedAt});
  

@override final  int id;
@override final  int invoiceId;
/// Position of the bar in the invoice: 1, 2, 3...
@override final  int barNumber;
/// Market base price at the time the line was entered.
@override final  double basePrice;
/// Weight of the bar in grams, in air ("Poids brut").
@override final  double grossWeight;
/// Weight of the bar submerged in water ("Eaux") — hydrostatic method.
@override final  double waterWeight;
/// grossWeight / waterWeight, truncated to 2 decimals.
@override final  double density;
/// Gold purity, derived from density. Always displayed in red.
@override final  double carat;
/// Price per gram for this bar ("U/BASE").
@override final  double unitPrice;
/// Line total: unitPrice × grossWeight ("Montant").
@override final  double amount;
@override final  DateTime? syncedAt;

/// Create a copy of InvoiceLine
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$InvoiceLineCopyWith<_InvoiceLine> get copyWith => __$InvoiceLineCopyWithImpl<_InvoiceLine>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _InvoiceLine&&(identical(other.id, id) || other.id == id)&&(identical(other.invoiceId, invoiceId) || other.invoiceId == invoiceId)&&(identical(other.barNumber, barNumber) || other.barNumber == barNumber)&&(identical(other.basePrice, basePrice) || other.basePrice == basePrice)&&(identical(other.grossWeight, grossWeight) || other.grossWeight == grossWeight)&&(identical(other.waterWeight, waterWeight) || other.waterWeight == waterWeight)&&(identical(other.density, density) || other.density == density)&&(identical(other.carat, carat) || other.carat == carat)&&(identical(other.unitPrice, unitPrice) || other.unitPrice == unitPrice)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.syncedAt, syncedAt) || other.syncedAt == syncedAt));
}


@override
int get hashCode => Object.hash(runtimeType,id,invoiceId,barNumber,basePrice,grossWeight,waterWeight,density,carat,unitPrice,amount,syncedAt);

@override
String toString() {
  return 'InvoiceLine(id: $id, invoiceId: $invoiceId, barNumber: $barNumber, basePrice: $basePrice, grossWeight: $grossWeight, waterWeight: $waterWeight, density: $density, carat: $carat, unitPrice: $unitPrice, amount: $amount, syncedAt: $syncedAt)';
}


}

/// @nodoc
abstract mixin class _$InvoiceLineCopyWith<$Res> implements $InvoiceLineCopyWith<$Res> {
  factory _$InvoiceLineCopyWith(_InvoiceLine value, $Res Function(_InvoiceLine) _then) = __$InvoiceLineCopyWithImpl;
@override @useResult
$Res call({
 int id, int invoiceId, int barNumber, double basePrice, double grossWeight, double waterWeight, double density, double carat, double unitPrice, double amount, DateTime? syncedAt
});




}
/// @nodoc
class __$InvoiceLineCopyWithImpl<$Res>
    implements _$InvoiceLineCopyWith<$Res> {
  __$InvoiceLineCopyWithImpl(this._self, this._then);

  final _InvoiceLine _self;
  final $Res Function(_InvoiceLine) _then;

/// Create a copy of InvoiceLine
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? invoiceId = null,Object? barNumber = null,Object? basePrice = null,Object? grossWeight = null,Object? waterWeight = null,Object? density = null,Object? carat = null,Object? unitPrice = null,Object? amount = null,Object? syncedAt = freezed,}) {
  return _then(_InvoiceLine(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,invoiceId: null == invoiceId ? _self.invoiceId : invoiceId // ignore: cast_nullable_to_non_nullable
as int,barNumber: null == barNumber ? _self.barNumber : barNumber // ignore: cast_nullable_to_non_nullable
as int,basePrice: null == basePrice ? _self.basePrice : basePrice // ignore: cast_nullable_to_non_nullable
as double,grossWeight: null == grossWeight ? _self.grossWeight : grossWeight // ignore: cast_nullable_to_non_nullable
as double,waterWeight: null == waterWeight ? _self.waterWeight : waterWeight // ignore: cast_nullable_to_non_nullable
as double,density: null == density ? _self.density : density // ignore: cast_nullable_to_non_nullable
as double,carat: null == carat ? _self.carat : carat // ignore: cast_nullable_to_non_nullable
as double,unitPrice: null == unitPrice ? _self.unitPrice : unitPrice // ignore: cast_nullable_to_non_nullable
as double,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as double,syncedAt: freezed == syncedAt ? _self.syncedAt : syncedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
