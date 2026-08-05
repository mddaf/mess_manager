// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'deposit.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Deposit {

 String get id; String get memberId; String get memberName; double get amount; String get date;// YYYY-MM-DD
 String get note; String get status;// approved, pending, rejected
 DateTime? get createdAt;
/// Create a copy of Deposit
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DepositCopyWith<Deposit> get copyWith => _$DepositCopyWithImpl<Deposit>(this as Deposit, _$identity);

  /// Serializes this Deposit to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Deposit&&(identical(other.id, id) || other.id == id)&&(identical(other.memberId, memberId) || other.memberId == memberId)&&(identical(other.memberName, memberName) || other.memberName == memberName)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.date, date) || other.date == date)&&(identical(other.note, note) || other.note == note)&&(identical(other.status, status) || other.status == status)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,memberId,memberName,amount,date,note,status,createdAt);

@override
String toString() {
  return 'Deposit(id: $id, memberId: $memberId, memberName: $memberName, amount: $amount, date: $date, note: $note, status: $status, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $DepositCopyWith<$Res>  {
  factory $DepositCopyWith(Deposit value, $Res Function(Deposit) _then) = _$DepositCopyWithImpl;
@useResult
$Res call({
 String id, String memberId, String memberName, double amount, String date, String note, String status, DateTime? createdAt
});




}
/// @nodoc
class _$DepositCopyWithImpl<$Res>
    implements $DepositCopyWith<$Res> {
  _$DepositCopyWithImpl(this._self, this._then);

  final Deposit _self;
  final $Res Function(Deposit) _then;

/// Create a copy of Deposit
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? memberId = null,Object? memberName = null,Object? amount = null,Object? date = null,Object? note = null,Object? status = null,Object? createdAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,memberId: null == memberId ? _self.memberId : memberId // ignore: cast_nullable_to_non_nullable
as String,memberName: null == memberName ? _self.memberName : memberName // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as double,date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as String,note: null == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [Deposit].
extension DepositPatterns on Deposit {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Deposit value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Deposit() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Deposit value)  $default,){
final _that = this;
switch (_that) {
case _Deposit():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Deposit value)?  $default,){
final _that = this;
switch (_that) {
case _Deposit() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String memberId,  String memberName,  double amount,  String date,  String note,  String status,  DateTime? createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Deposit() when $default != null:
return $default(_that.id,_that.memberId,_that.memberName,_that.amount,_that.date,_that.note,_that.status,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String memberId,  String memberName,  double amount,  String date,  String note,  String status,  DateTime? createdAt)  $default,) {final _that = this;
switch (_that) {
case _Deposit():
return $default(_that.id,_that.memberId,_that.memberName,_that.amount,_that.date,_that.note,_that.status,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String memberId,  String memberName,  double amount,  String date,  String note,  String status,  DateTime? createdAt)?  $default,) {final _that = this;
switch (_that) {
case _Deposit() when $default != null:
return $default(_that.id,_that.memberId,_that.memberName,_that.amount,_that.date,_that.note,_that.status,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Deposit implements Deposit {
  const _Deposit({required this.id, required this.memberId, required this.memberName, required this.amount, required this.date, this.note = '', this.status = 'approved', this.createdAt});
  factory _Deposit.fromJson(Map<String, dynamic> json) => _$DepositFromJson(json);

@override final  String id;
@override final  String memberId;
@override final  String memberName;
@override final  double amount;
@override final  String date;
// YYYY-MM-DD
@override@JsonKey() final  String note;
@override@JsonKey() final  String status;
// approved, pending, rejected
@override final  DateTime? createdAt;

/// Create a copy of Deposit
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DepositCopyWith<_Deposit> get copyWith => __$DepositCopyWithImpl<_Deposit>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DepositToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Deposit&&(identical(other.id, id) || other.id == id)&&(identical(other.memberId, memberId) || other.memberId == memberId)&&(identical(other.memberName, memberName) || other.memberName == memberName)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.date, date) || other.date == date)&&(identical(other.note, note) || other.note == note)&&(identical(other.status, status) || other.status == status)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,memberId,memberName,amount,date,note,status,createdAt);

@override
String toString() {
  return 'Deposit(id: $id, memberId: $memberId, memberName: $memberName, amount: $amount, date: $date, note: $note, status: $status, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$DepositCopyWith<$Res> implements $DepositCopyWith<$Res> {
  factory _$DepositCopyWith(_Deposit value, $Res Function(_Deposit) _then) = __$DepositCopyWithImpl;
@override @useResult
$Res call({
 String id, String memberId, String memberName, double amount, String date, String note, String status, DateTime? createdAt
});




}
/// @nodoc
class __$DepositCopyWithImpl<$Res>
    implements _$DepositCopyWith<$Res> {
  __$DepositCopyWithImpl(this._self, this._then);

  final _Deposit _self;
  final $Res Function(_Deposit) _then;

/// Create a copy of Deposit
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? memberId = null,Object? memberName = null,Object? amount = null,Object? date = null,Object? note = null,Object? status = null,Object? createdAt = freezed,}) {
  return _then(_Deposit(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,memberId: null == memberId ? _self.memberId : memberId // ignore: cast_nullable_to_non_nullable
as String,memberName: null == memberName ? _self.memberName : memberName // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as double,date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as String,note: null == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
