// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'member_balance.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$MemberBalance {

 String get memberId; String get memberName; double get totalMeals; double get totalCost; double get totalDeposit; double get balance;
/// Create a copy of MemberBalance
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MemberBalanceCopyWith<MemberBalance> get copyWith => _$MemberBalanceCopyWithImpl<MemberBalance>(this as MemberBalance, _$identity);

  /// Serializes this MemberBalance to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MemberBalance&&(identical(other.memberId, memberId) || other.memberId == memberId)&&(identical(other.memberName, memberName) || other.memberName == memberName)&&(identical(other.totalMeals, totalMeals) || other.totalMeals == totalMeals)&&(identical(other.totalCost, totalCost) || other.totalCost == totalCost)&&(identical(other.totalDeposit, totalDeposit) || other.totalDeposit == totalDeposit)&&(identical(other.balance, balance) || other.balance == balance));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,memberId,memberName,totalMeals,totalCost,totalDeposit,balance);

@override
String toString() {
  return 'MemberBalance(memberId: $memberId, memberName: $memberName, totalMeals: $totalMeals, totalCost: $totalCost, totalDeposit: $totalDeposit, balance: $balance)';
}


}

/// @nodoc
abstract mixin class $MemberBalanceCopyWith<$Res>  {
  factory $MemberBalanceCopyWith(MemberBalance value, $Res Function(MemberBalance) _then) = _$MemberBalanceCopyWithImpl;
@useResult
$Res call({
 String memberId, String memberName, double totalMeals, double totalCost, double totalDeposit, double balance
});




}
/// @nodoc
class _$MemberBalanceCopyWithImpl<$Res>
    implements $MemberBalanceCopyWith<$Res> {
  _$MemberBalanceCopyWithImpl(this._self, this._then);

  final MemberBalance _self;
  final $Res Function(MemberBalance) _then;

/// Create a copy of MemberBalance
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? memberId = null,Object? memberName = null,Object? totalMeals = null,Object? totalCost = null,Object? totalDeposit = null,Object? balance = null,}) {
  return _then(_self.copyWith(
memberId: null == memberId ? _self.memberId : memberId // ignore: cast_nullable_to_non_nullable
as String,memberName: null == memberName ? _self.memberName : memberName // ignore: cast_nullable_to_non_nullable
as String,totalMeals: null == totalMeals ? _self.totalMeals : totalMeals // ignore: cast_nullable_to_non_nullable
as double,totalCost: null == totalCost ? _self.totalCost : totalCost // ignore: cast_nullable_to_non_nullable
as double,totalDeposit: null == totalDeposit ? _self.totalDeposit : totalDeposit // ignore: cast_nullable_to_non_nullable
as double,balance: null == balance ? _self.balance : balance // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

}


/// Adds pattern-matching-related methods to [MemberBalance].
extension MemberBalancePatterns on MemberBalance {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MemberBalance value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MemberBalance() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MemberBalance value)  $default,){
final _that = this;
switch (_that) {
case _MemberBalance():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MemberBalance value)?  $default,){
final _that = this;
switch (_that) {
case _MemberBalance() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String memberId,  String memberName,  double totalMeals,  double totalCost,  double totalDeposit,  double balance)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MemberBalance() when $default != null:
return $default(_that.memberId,_that.memberName,_that.totalMeals,_that.totalCost,_that.totalDeposit,_that.balance);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String memberId,  String memberName,  double totalMeals,  double totalCost,  double totalDeposit,  double balance)  $default,) {final _that = this;
switch (_that) {
case _MemberBalance():
return $default(_that.memberId,_that.memberName,_that.totalMeals,_that.totalCost,_that.totalDeposit,_that.balance);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String memberId,  String memberName,  double totalMeals,  double totalCost,  double totalDeposit,  double balance)?  $default,) {final _that = this;
switch (_that) {
case _MemberBalance() when $default != null:
return $default(_that.memberId,_that.memberName,_that.totalMeals,_that.totalCost,_that.totalDeposit,_that.balance);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MemberBalance implements MemberBalance {
  const _MemberBalance({required this.memberId, required this.memberName, required this.totalMeals, required this.totalCost, required this.totalDeposit, required this.balance});
  factory _MemberBalance.fromJson(Map<String, dynamic> json) => _$MemberBalanceFromJson(json);

@override final  String memberId;
@override final  String memberName;
@override final  double totalMeals;
@override final  double totalCost;
@override final  double totalDeposit;
@override final  double balance;

/// Create a copy of MemberBalance
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MemberBalanceCopyWith<_MemberBalance> get copyWith => __$MemberBalanceCopyWithImpl<_MemberBalance>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MemberBalanceToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MemberBalance&&(identical(other.memberId, memberId) || other.memberId == memberId)&&(identical(other.memberName, memberName) || other.memberName == memberName)&&(identical(other.totalMeals, totalMeals) || other.totalMeals == totalMeals)&&(identical(other.totalCost, totalCost) || other.totalCost == totalCost)&&(identical(other.totalDeposit, totalDeposit) || other.totalDeposit == totalDeposit)&&(identical(other.balance, balance) || other.balance == balance));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,memberId,memberName,totalMeals,totalCost,totalDeposit,balance);

@override
String toString() {
  return 'MemberBalance(memberId: $memberId, memberName: $memberName, totalMeals: $totalMeals, totalCost: $totalCost, totalDeposit: $totalDeposit, balance: $balance)';
}


}

/// @nodoc
abstract mixin class _$MemberBalanceCopyWith<$Res> implements $MemberBalanceCopyWith<$Res> {
  factory _$MemberBalanceCopyWith(_MemberBalance value, $Res Function(_MemberBalance) _then) = __$MemberBalanceCopyWithImpl;
@override @useResult
$Res call({
 String memberId, String memberName, double totalMeals, double totalCost, double totalDeposit, double balance
});




}
/// @nodoc
class __$MemberBalanceCopyWithImpl<$Res>
    implements _$MemberBalanceCopyWith<$Res> {
  __$MemberBalanceCopyWithImpl(this._self, this._then);

  final _MemberBalance _self;
  final $Res Function(_MemberBalance) _then;

/// Create a copy of MemberBalance
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? memberId = null,Object? memberName = null,Object? totalMeals = null,Object? totalCost = null,Object? totalDeposit = null,Object? balance = null,}) {
  return _then(_MemberBalance(
memberId: null == memberId ? _self.memberId : memberId // ignore: cast_nullable_to_non_nullable
as String,memberName: null == memberName ? _self.memberName : memberName // ignore: cast_nullable_to_non_nullable
as String,totalMeals: null == totalMeals ? _self.totalMeals : totalMeals // ignore: cast_nullable_to_non_nullable
as double,totalCost: null == totalCost ? _self.totalCost : totalCost // ignore: cast_nullable_to_non_nullable
as double,totalDeposit: null == totalDeposit ? _self.totalDeposit : totalDeposit // ignore: cast_nullable_to_non_nullable
as double,balance: null == balance ? _self.balance : balance // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}

// dart format on
