// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'invoice.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$Invoice {

 int get id; String get invoiceNumber; DateTime get issueDate; String get location;/// Reference market price ("Base"), shared by every line of this invoice.
 double get basePrice; InvoiceStatus get status; int get barCount; double get totalGrossWeight; double get totalWaterWeight; double get totalAmount; DateTime get createdAt; DateTime get updatedAt;
/// Create a copy of Invoice
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$InvoiceCopyWith<Invoice> get copyWith => _$InvoiceCopyWithImpl<Invoice>(this as Invoice, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Invoice&&(identical(other.id, id) || other.id == id)&&(identical(other.invoiceNumber, invoiceNumber) || other.invoiceNumber == invoiceNumber)&&(identical(other.issueDate, issueDate) || other.issueDate == issueDate)&&(identical(other.location, location) || other.location == location)&&(identical(other.basePrice, basePrice) || other.basePrice == basePrice)&&(identical(other.status, status) || other.status == status)&&(identical(other.barCount, barCount) || other.barCount == barCount)&&(identical(other.totalGrossWeight, totalGrossWeight) || other.totalGrossWeight == totalGrossWeight)&&(identical(other.totalWaterWeight, totalWaterWeight) || other.totalWaterWeight == totalWaterWeight)&&(identical(other.totalAmount, totalAmount) || other.totalAmount == totalAmount)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}


@override
int get hashCode => Object.hash(runtimeType,id,invoiceNumber,issueDate,location,basePrice,status,barCount,totalGrossWeight,totalWaterWeight,totalAmount,createdAt,updatedAt);

@override
String toString() {
  return 'Invoice(id: $id, invoiceNumber: $invoiceNumber, issueDate: $issueDate, location: $location, basePrice: $basePrice, status: $status, barCount: $barCount, totalGrossWeight: $totalGrossWeight, totalWaterWeight: $totalWaterWeight, totalAmount: $totalAmount, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $InvoiceCopyWith<$Res>  {
  factory $InvoiceCopyWith(Invoice value, $Res Function(Invoice) _then) = _$InvoiceCopyWithImpl;
@useResult
$Res call({
 int id, String invoiceNumber, DateTime issueDate, String location, double basePrice, InvoiceStatus status, int barCount, double totalGrossWeight, double totalWaterWeight, double totalAmount, DateTime createdAt, DateTime updatedAt
});




}
/// @nodoc
class _$InvoiceCopyWithImpl<$Res>
    implements $InvoiceCopyWith<$Res> {
  _$InvoiceCopyWithImpl(this._self, this._then);

  final Invoice _self;
  final $Res Function(Invoice) _then;

/// Create a copy of Invoice
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? invoiceNumber = null,Object? issueDate = null,Object? location = null,Object? basePrice = null,Object? status = null,Object? barCount = null,Object? totalGrossWeight = null,Object? totalWaterWeight = null,Object? totalAmount = null,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,invoiceNumber: null == invoiceNumber ? _self.invoiceNumber : invoiceNumber // ignore: cast_nullable_to_non_nullable
as String,issueDate: null == issueDate ? _self.issueDate : issueDate // ignore: cast_nullable_to_non_nullable
as DateTime,location: null == location ? _self.location : location // ignore: cast_nullable_to_non_nullable
as String,basePrice: null == basePrice ? _self.basePrice : basePrice // ignore: cast_nullable_to_non_nullable
as double,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as InvoiceStatus,barCount: null == barCount ? _self.barCount : barCount // ignore: cast_nullable_to_non_nullable
as int,totalGrossWeight: null == totalGrossWeight ? _self.totalGrossWeight : totalGrossWeight // ignore: cast_nullable_to_non_nullable
as double,totalWaterWeight: null == totalWaterWeight ? _self.totalWaterWeight : totalWaterWeight // ignore: cast_nullable_to_non_nullable
as double,totalAmount: null == totalAmount ? _self.totalAmount : totalAmount // ignore: cast_nullable_to_non_nullable
as double,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [Invoice].
extension InvoicePatterns on Invoice {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Invoice value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Invoice() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Invoice value)  $default,){
final _that = this;
switch (_that) {
case _Invoice():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Invoice value)?  $default,){
final _that = this;
switch (_that) {
case _Invoice() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String invoiceNumber,  DateTime issueDate,  String location,  double basePrice,  InvoiceStatus status,  int barCount,  double totalGrossWeight,  double totalWaterWeight,  double totalAmount,  DateTime createdAt,  DateTime updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Invoice() when $default != null:
return $default(_that.id,_that.invoiceNumber,_that.issueDate,_that.location,_that.basePrice,_that.status,_that.barCount,_that.totalGrossWeight,_that.totalWaterWeight,_that.totalAmount,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String invoiceNumber,  DateTime issueDate,  String location,  double basePrice,  InvoiceStatus status,  int barCount,  double totalGrossWeight,  double totalWaterWeight,  double totalAmount,  DateTime createdAt,  DateTime updatedAt)  $default,) {final _that = this;
switch (_that) {
case _Invoice():
return $default(_that.id,_that.invoiceNumber,_that.issueDate,_that.location,_that.basePrice,_that.status,_that.barCount,_that.totalGrossWeight,_that.totalWaterWeight,_that.totalAmount,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String invoiceNumber,  DateTime issueDate,  String location,  double basePrice,  InvoiceStatus status,  int barCount,  double totalGrossWeight,  double totalWaterWeight,  double totalAmount,  DateTime createdAt,  DateTime updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _Invoice() when $default != null:
return $default(_that.id,_that.invoiceNumber,_that.issueDate,_that.location,_that.basePrice,_that.status,_that.barCount,_that.totalGrossWeight,_that.totalWaterWeight,_that.totalAmount,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc


class _Invoice extends Invoice {
  const _Invoice({required this.id, required this.invoiceNumber, required this.issueDate, required this.location, required this.basePrice, required this.status, required this.barCount, required this.totalGrossWeight, required this.totalWaterWeight, required this.totalAmount, required this.createdAt, required this.updatedAt}): super._();
  

@override final  int id;
@override final  String invoiceNumber;
@override final  DateTime issueDate;
@override final  String location;
/// Reference market price ("Base"), shared by every line of this invoice.
@override final  double basePrice;
@override final  InvoiceStatus status;
@override final  int barCount;
@override final  double totalGrossWeight;
@override final  double totalWaterWeight;
@override final  double totalAmount;
@override final  DateTime createdAt;
@override final  DateTime updatedAt;

/// Create a copy of Invoice
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$InvoiceCopyWith<_Invoice> get copyWith => __$InvoiceCopyWithImpl<_Invoice>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Invoice&&(identical(other.id, id) || other.id == id)&&(identical(other.invoiceNumber, invoiceNumber) || other.invoiceNumber == invoiceNumber)&&(identical(other.issueDate, issueDate) || other.issueDate == issueDate)&&(identical(other.location, location) || other.location == location)&&(identical(other.basePrice, basePrice) || other.basePrice == basePrice)&&(identical(other.status, status) || other.status == status)&&(identical(other.barCount, barCount) || other.barCount == barCount)&&(identical(other.totalGrossWeight, totalGrossWeight) || other.totalGrossWeight == totalGrossWeight)&&(identical(other.totalWaterWeight, totalWaterWeight) || other.totalWaterWeight == totalWaterWeight)&&(identical(other.totalAmount, totalAmount) || other.totalAmount == totalAmount)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}


@override
int get hashCode => Object.hash(runtimeType,id,invoiceNumber,issueDate,location,basePrice,status,barCount,totalGrossWeight,totalWaterWeight,totalAmount,createdAt,updatedAt);

@override
String toString() {
  return 'Invoice(id: $id, invoiceNumber: $invoiceNumber, issueDate: $issueDate, location: $location, basePrice: $basePrice, status: $status, barCount: $barCount, totalGrossWeight: $totalGrossWeight, totalWaterWeight: $totalWaterWeight, totalAmount: $totalAmount, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$InvoiceCopyWith<$Res> implements $InvoiceCopyWith<$Res> {
  factory _$InvoiceCopyWith(_Invoice value, $Res Function(_Invoice) _then) = __$InvoiceCopyWithImpl;
@override @useResult
$Res call({
 int id, String invoiceNumber, DateTime issueDate, String location, double basePrice, InvoiceStatus status, int barCount, double totalGrossWeight, double totalWaterWeight, double totalAmount, DateTime createdAt, DateTime updatedAt
});




}
/// @nodoc
class __$InvoiceCopyWithImpl<$Res>
    implements _$InvoiceCopyWith<$Res> {
  __$InvoiceCopyWithImpl(this._self, this._then);

  final _Invoice _self;
  final $Res Function(_Invoice) _then;

/// Create a copy of Invoice
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? invoiceNumber = null,Object? issueDate = null,Object? location = null,Object? basePrice = null,Object? status = null,Object? barCount = null,Object? totalGrossWeight = null,Object? totalWaterWeight = null,Object? totalAmount = null,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_Invoice(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,invoiceNumber: null == invoiceNumber ? _self.invoiceNumber : invoiceNumber // ignore: cast_nullable_to_non_nullable
as String,issueDate: null == issueDate ? _self.issueDate : issueDate // ignore: cast_nullable_to_non_nullable
as DateTime,location: null == location ? _self.location : location // ignore: cast_nullable_to_non_nullable
as String,basePrice: null == basePrice ? _self.basePrice : basePrice // ignore: cast_nullable_to_non_nullable
as double,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as InvoiceStatus,barCount: null == barCount ? _self.barCount : barCount // ignore: cast_nullable_to_non_nullable
as int,totalGrossWeight: null == totalGrossWeight ? _self.totalGrossWeight : totalGrossWeight // ignore: cast_nullable_to_non_nullable
as double,totalWaterWeight: null == totalWaterWeight ? _self.totalWaterWeight : totalWaterWeight // ignore: cast_nullable_to_non_nullable
as double,totalAmount: null == totalAmount ? _self.totalAmount : totalAmount // ignore: cast_nullable_to_non_nullable
as double,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
