// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'invoice_line_preview.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$InvoiceLinePreview {

 double get density; double get carat; double get unitPrice; double get amount;
/// Create a copy of InvoiceLinePreview
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$InvoiceLinePreviewCopyWith<InvoiceLinePreview> get copyWith => _$InvoiceLinePreviewCopyWithImpl<InvoiceLinePreview>(this as InvoiceLinePreview, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is InvoiceLinePreview&&(identical(other.density, density) || other.density == density)&&(identical(other.carat, carat) || other.carat == carat)&&(identical(other.unitPrice, unitPrice) || other.unitPrice == unitPrice)&&(identical(other.amount, amount) || other.amount == amount));
}


@override
int get hashCode => Object.hash(runtimeType,density,carat,unitPrice,amount);

@override
String toString() {
  return 'InvoiceLinePreview(density: $density, carat: $carat, unitPrice: $unitPrice, amount: $amount)';
}


}

/// @nodoc
abstract mixin class $InvoiceLinePreviewCopyWith<$Res>  {
  factory $InvoiceLinePreviewCopyWith(InvoiceLinePreview value, $Res Function(InvoiceLinePreview) _then) = _$InvoiceLinePreviewCopyWithImpl;
@useResult
$Res call({
 double density, double carat, double unitPrice, double amount
});




}
/// @nodoc
class _$InvoiceLinePreviewCopyWithImpl<$Res>
    implements $InvoiceLinePreviewCopyWith<$Res> {
  _$InvoiceLinePreviewCopyWithImpl(this._self, this._then);

  final InvoiceLinePreview _self;
  final $Res Function(InvoiceLinePreview) _then;

/// Create a copy of InvoiceLinePreview
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? density = null,Object? carat = null,Object? unitPrice = null,Object? amount = null,}) {
  return _then(_self.copyWith(
density: null == density ? _self.density : density // ignore: cast_nullable_to_non_nullable
as double,carat: null == carat ? _self.carat : carat // ignore: cast_nullable_to_non_nullable
as double,unitPrice: null == unitPrice ? _self.unitPrice : unitPrice // ignore: cast_nullable_to_non_nullable
as double,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

}


/// Adds pattern-matching-related methods to [InvoiceLinePreview].
extension InvoiceLinePreviewPatterns on InvoiceLinePreview {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _InvoiceLinePreview value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _InvoiceLinePreview() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _InvoiceLinePreview value)  $default,){
final _that = this;
switch (_that) {
case _InvoiceLinePreview():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _InvoiceLinePreview value)?  $default,){
final _that = this;
switch (_that) {
case _InvoiceLinePreview() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( double density,  double carat,  double unitPrice,  double amount)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _InvoiceLinePreview() when $default != null:
return $default(_that.density,_that.carat,_that.unitPrice,_that.amount);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( double density,  double carat,  double unitPrice,  double amount)  $default,) {final _that = this;
switch (_that) {
case _InvoiceLinePreview():
return $default(_that.density,_that.carat,_that.unitPrice,_that.amount);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( double density,  double carat,  double unitPrice,  double amount)?  $default,) {final _that = this;
switch (_that) {
case _InvoiceLinePreview() when $default != null:
return $default(_that.density,_that.carat,_that.unitPrice,_that.amount);case _:
  return null;

}
}

}

/// @nodoc


class _InvoiceLinePreview implements InvoiceLinePreview {
  const _InvoiceLinePreview({required this.density, required this.carat, required this.unitPrice, required this.amount});
  

@override final  double density;
@override final  double carat;
@override final  double unitPrice;
@override final  double amount;

/// Create a copy of InvoiceLinePreview
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$InvoiceLinePreviewCopyWith<_InvoiceLinePreview> get copyWith => __$InvoiceLinePreviewCopyWithImpl<_InvoiceLinePreview>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _InvoiceLinePreview&&(identical(other.density, density) || other.density == density)&&(identical(other.carat, carat) || other.carat == carat)&&(identical(other.unitPrice, unitPrice) || other.unitPrice == unitPrice)&&(identical(other.amount, amount) || other.amount == amount));
}


@override
int get hashCode => Object.hash(runtimeType,density,carat,unitPrice,amount);

@override
String toString() {
  return 'InvoiceLinePreview(density: $density, carat: $carat, unitPrice: $unitPrice, amount: $amount)';
}


}

/// @nodoc
abstract mixin class _$InvoiceLinePreviewCopyWith<$Res> implements $InvoiceLinePreviewCopyWith<$Res> {
  factory _$InvoiceLinePreviewCopyWith(_InvoiceLinePreview value, $Res Function(_InvoiceLinePreview) _then) = __$InvoiceLinePreviewCopyWithImpl;
@override @useResult
$Res call({
 double density, double carat, double unitPrice, double amount
});




}
/// @nodoc
class __$InvoiceLinePreviewCopyWithImpl<$Res>
    implements _$InvoiceLinePreviewCopyWith<$Res> {
  __$InvoiceLinePreviewCopyWithImpl(this._self, this._then);

  final _InvoiceLinePreview _self;
  final $Res Function(_InvoiceLinePreview) _then;

/// Create a copy of InvoiceLinePreview
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? density = null,Object? carat = null,Object? unitPrice = null,Object? amount = null,}) {
  return _then(_InvoiceLinePreview(
density: null == density ? _self.density : density // ignore: cast_nullable_to_non_nullable
as double,carat: null == carat ? _self.carat : carat // ignore: cast_nullable_to_non_nullable
as double,unitPrice: null == unitPrice ? _self.unitPrice : unitPrice // ignore: cast_nullable_to_non_nullable
as double,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}

// dart format on
