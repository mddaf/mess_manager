// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'mess.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Mess {

 String get id; String get name; String get address; String get createdBy; String get inviteCode; int get mealCutoffHour; String get currency; String? get currentManagerId; DateTime? get createdAt;
/// Create a copy of Mess
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MessCopyWith<Mess> get copyWith => _$MessCopyWithImpl<Mess>(this as Mess, _$identity);

  /// Serializes this Mess to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Mess&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.address, address) || other.address == address)&&(identical(other.createdBy, createdBy) || other.createdBy == createdBy)&&(identical(other.inviteCode, inviteCode) || other.inviteCode == inviteCode)&&(identical(other.mealCutoffHour, mealCutoffHour) || other.mealCutoffHour == mealCutoffHour)&&(identical(other.currency, currency) || other.currency == currency)&&(identical(other.currentManagerId, currentManagerId) || other.currentManagerId == currentManagerId)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,address,createdBy,inviteCode,mealCutoffHour,currency,currentManagerId,createdAt);

@override
String toString() {
  return 'Mess(id: $id, name: $name, address: $address, createdBy: $createdBy, inviteCode: $inviteCode, mealCutoffHour: $mealCutoffHour, currency: $currency, currentManagerId: $currentManagerId, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $MessCopyWith<$Res>  {
  factory $MessCopyWith(Mess value, $Res Function(Mess) _then) = _$MessCopyWithImpl;
@useResult
$Res call({
 String id, String name, String address, String createdBy, String inviteCode, int mealCutoffHour, String currency, String? currentManagerId, DateTime? createdAt
});




}
/// @nodoc
class _$MessCopyWithImpl<$Res>
    implements $MessCopyWith<$Res> {
  _$MessCopyWithImpl(this._self, this._then);

  final Mess _self;
  final $Res Function(Mess) _then;

/// Create a copy of Mess
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? address = null,Object? createdBy = null,Object? inviteCode = null,Object? mealCutoffHour = null,Object? currency = null,Object? currentManagerId = freezed,Object? createdAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,address: null == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as String,createdBy: null == createdBy ? _self.createdBy : createdBy // ignore: cast_nullable_to_non_nullable
as String,inviteCode: null == inviteCode ? _self.inviteCode : inviteCode // ignore: cast_nullable_to_non_nullable
as String,mealCutoffHour: null == mealCutoffHour ? _self.mealCutoffHour : mealCutoffHour // ignore: cast_nullable_to_non_nullable
as int,currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String,currentManagerId: freezed == currentManagerId ? _self.currentManagerId : currentManagerId // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [Mess].
extension MessPatterns on Mess {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Mess value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Mess() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Mess value)  $default,){
final _that = this;
switch (_that) {
case _Mess():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Mess value)?  $default,){
final _that = this;
switch (_that) {
case _Mess() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String address,  String createdBy,  String inviteCode,  int mealCutoffHour,  String currency,  String? currentManagerId,  DateTime? createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Mess() when $default != null:
return $default(_that.id,_that.name,_that.address,_that.createdBy,_that.inviteCode,_that.mealCutoffHour,_that.currency,_that.currentManagerId,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String address,  String createdBy,  String inviteCode,  int mealCutoffHour,  String currency,  String? currentManagerId,  DateTime? createdAt)  $default,) {final _that = this;
switch (_that) {
case _Mess():
return $default(_that.id,_that.name,_that.address,_that.createdBy,_that.inviteCode,_that.mealCutoffHour,_that.currency,_that.currentManagerId,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String address,  String createdBy,  String inviteCode,  int mealCutoffHour,  String currency,  String? currentManagerId,  DateTime? createdAt)?  $default,) {final _that = this;
switch (_that) {
case _Mess() when $default != null:
return $default(_that.id,_that.name,_that.address,_that.createdBy,_that.inviteCode,_that.mealCutoffHour,_that.currency,_that.currentManagerId,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Mess implements Mess {
  const _Mess({required this.id, required this.name, required this.address, required this.createdBy, required this.inviteCode, this.mealCutoffHour = 22, this.currency = '৳', this.currentManagerId, this.createdAt});
  factory _Mess.fromJson(Map<String, dynamic> json) => _$MessFromJson(json);

@override final  String id;
@override final  String name;
@override final  String address;
@override final  String createdBy;
@override final  String inviteCode;
@override@JsonKey() final  int mealCutoffHour;
@override@JsonKey() final  String currency;
@override final  String? currentManagerId;
@override final  DateTime? createdAt;

/// Create a copy of Mess
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MessCopyWith<_Mess> get copyWith => __$MessCopyWithImpl<_Mess>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MessToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Mess&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.address, address) || other.address == address)&&(identical(other.createdBy, createdBy) || other.createdBy == createdBy)&&(identical(other.inviteCode, inviteCode) || other.inviteCode == inviteCode)&&(identical(other.mealCutoffHour, mealCutoffHour) || other.mealCutoffHour == mealCutoffHour)&&(identical(other.currency, currency) || other.currency == currency)&&(identical(other.currentManagerId, currentManagerId) || other.currentManagerId == currentManagerId)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,address,createdBy,inviteCode,mealCutoffHour,currency,currentManagerId,createdAt);

@override
String toString() {
  return 'Mess(id: $id, name: $name, address: $address, createdBy: $createdBy, inviteCode: $inviteCode, mealCutoffHour: $mealCutoffHour, currency: $currency, currentManagerId: $currentManagerId, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$MessCopyWith<$Res> implements $MessCopyWith<$Res> {
  factory _$MessCopyWith(_Mess value, $Res Function(_Mess) _then) = __$MessCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String address, String createdBy, String inviteCode, int mealCutoffHour, String currency, String? currentManagerId, DateTime? createdAt
});




}
/// @nodoc
class __$MessCopyWithImpl<$Res>
    implements _$MessCopyWith<$Res> {
  __$MessCopyWithImpl(this._self, this._then);

  final _Mess _self;
  final $Res Function(_Mess) _then;

/// Create a copy of Mess
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? address = null,Object? createdBy = null,Object? inviteCode = null,Object? mealCutoffHour = null,Object? currency = null,Object? currentManagerId = freezed,Object? createdAt = freezed,}) {
  return _then(_Mess(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,address: null == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as String,createdBy: null == createdBy ? _self.createdBy : createdBy // ignore: cast_nullable_to_non_nullable
as String,inviteCode: null == inviteCode ? _self.inviteCode : inviteCode // ignore: cast_nullable_to_non_nullable
as String,mealCutoffHour: null == mealCutoffHour ? _self.mealCutoffHour : mealCutoffHour // ignore: cast_nullable_to_non_nullable
as int,currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String,currentManagerId: freezed == currentManagerId ? _self.currentManagerId : currentManagerId // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
