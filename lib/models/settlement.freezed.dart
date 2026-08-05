// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'settlement.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Settlement {

 String get id; String get month;// YYYY-MM
 double get totalGroceryCost; double get totalMeals; double get mealRate; List<MemberBalance> get memberBalances; String get status;// pending, settled
 DateTime? get calculatedAt;
/// Create a copy of Settlement
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SettlementCopyWith<Settlement> get copyWith => _$SettlementCopyWithImpl<Settlement>(this as Settlement, _$identity);

  /// Serializes this Settlement to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Settlement&&(identical(other.id, id) || other.id == id)&&(identical(other.month, month) || other.month == month)&&(identical(other.totalGroceryCost, totalGroceryCost) || other.totalGroceryCost == totalGroceryCost)&&(identical(other.totalMeals, totalMeals) || other.totalMeals == totalMeals)&&(identical(other.mealRate, mealRate) || other.mealRate == mealRate)&&const DeepCollectionEquality().equals(other.memberBalances, memberBalances)&&(identical(other.status, status) || other.status == status)&&(identical(other.calculatedAt, calculatedAt) || other.calculatedAt == calculatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,month,totalGroceryCost,totalMeals,mealRate,const DeepCollectionEquality().hash(memberBalances),status,calculatedAt);

@override
String toString() {
  return 'Settlement(id: $id, month: $month, totalGroceryCost: $totalGroceryCost, totalMeals: $totalMeals, mealRate: $mealRate, memberBalances: $memberBalances, status: $status, calculatedAt: $calculatedAt)';
}


}

/// @nodoc
abstract mixin class $SettlementCopyWith<$Res>  {
  factory $SettlementCopyWith(Settlement value, $Res Function(Settlement) _then) = _$SettlementCopyWithImpl;
@useResult
$Res call({
 String id, String month, double totalGroceryCost, double totalMeals, double mealRate, List<MemberBalance> memberBalances, String status, DateTime? calculatedAt
});




}
/// @nodoc
class _$SettlementCopyWithImpl<$Res>
    implements $SettlementCopyWith<$Res> {
  _$SettlementCopyWithImpl(this._self, this._then);

  final Settlement _self;
  final $Res Function(Settlement) _then;

/// Create a copy of Settlement
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? month = null,Object? totalGroceryCost = null,Object? totalMeals = null,Object? mealRate = null,Object? memberBalances = null,Object? status = null,Object? calculatedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,month: null == month ? _self.month : month // ignore: cast_nullable_to_non_nullable
as String,totalGroceryCost: null == totalGroceryCost ? _self.totalGroceryCost : totalGroceryCost // ignore: cast_nullable_to_non_nullable
as double,totalMeals: null == totalMeals ? _self.totalMeals : totalMeals // ignore: cast_nullable_to_non_nullable
as double,mealRate: null == mealRate ? _self.mealRate : mealRate // ignore: cast_nullable_to_non_nullable
as double,memberBalances: null == memberBalances ? _self.memberBalances : memberBalances // ignore: cast_nullable_to_non_nullable
as List<MemberBalance>,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,calculatedAt: freezed == calculatedAt ? _self.calculatedAt : calculatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [Settlement].
extension SettlementPatterns on Settlement {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Settlement value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Settlement() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Settlement value)  $default,){
final _that = this;
switch (_that) {
case _Settlement():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Settlement value)?  $default,){
final _that = this;
switch (_that) {
case _Settlement() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String month,  double totalGroceryCost,  double totalMeals,  double mealRate,  List<MemberBalance> memberBalances,  String status,  DateTime? calculatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Settlement() when $default != null:
return $default(_that.id,_that.month,_that.totalGroceryCost,_that.totalMeals,_that.mealRate,_that.memberBalances,_that.status,_that.calculatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String month,  double totalGroceryCost,  double totalMeals,  double mealRate,  List<MemberBalance> memberBalances,  String status,  DateTime? calculatedAt)  $default,) {final _that = this;
switch (_that) {
case _Settlement():
return $default(_that.id,_that.month,_that.totalGroceryCost,_that.totalMeals,_that.mealRate,_that.memberBalances,_that.status,_that.calculatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String month,  double totalGroceryCost,  double totalMeals,  double mealRate,  List<MemberBalance> memberBalances,  String status,  DateTime? calculatedAt)?  $default,) {final _that = this;
switch (_that) {
case _Settlement() when $default != null:
return $default(_that.id,_that.month,_that.totalGroceryCost,_that.totalMeals,_that.mealRate,_that.memberBalances,_that.status,_that.calculatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Settlement implements Settlement {
  const _Settlement({required this.id, required this.month, required this.totalGroceryCost, required this.totalMeals, required this.mealRate, final  List<MemberBalance> memberBalances = const [], this.status = 'pending', this.calculatedAt}): _memberBalances = memberBalances;
  factory _Settlement.fromJson(Map<String, dynamic> json) => _$SettlementFromJson(json);

@override final  String id;
@override final  String month;
// YYYY-MM
@override final  double totalGroceryCost;
@override final  double totalMeals;
@override final  double mealRate;
 final  List<MemberBalance> _memberBalances;
@override@JsonKey() List<MemberBalance> get memberBalances {
  if (_memberBalances is EqualUnmodifiableListView) return _memberBalances;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_memberBalances);
}

@override@JsonKey() final  String status;
// pending, settled
@override final  DateTime? calculatedAt;

/// Create a copy of Settlement
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SettlementCopyWith<_Settlement> get copyWith => __$SettlementCopyWithImpl<_Settlement>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SettlementToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Settlement&&(identical(other.id, id) || other.id == id)&&(identical(other.month, month) || other.month == month)&&(identical(other.totalGroceryCost, totalGroceryCost) || other.totalGroceryCost == totalGroceryCost)&&(identical(other.totalMeals, totalMeals) || other.totalMeals == totalMeals)&&(identical(other.mealRate, mealRate) || other.mealRate == mealRate)&&const DeepCollectionEquality().equals(other._memberBalances, _memberBalances)&&(identical(other.status, status) || other.status == status)&&(identical(other.calculatedAt, calculatedAt) || other.calculatedAt == calculatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,month,totalGroceryCost,totalMeals,mealRate,const DeepCollectionEquality().hash(_memberBalances),status,calculatedAt);

@override
String toString() {
  return 'Settlement(id: $id, month: $month, totalGroceryCost: $totalGroceryCost, totalMeals: $totalMeals, mealRate: $mealRate, memberBalances: $memberBalances, status: $status, calculatedAt: $calculatedAt)';
}


}

/// @nodoc
abstract mixin class _$SettlementCopyWith<$Res> implements $SettlementCopyWith<$Res> {
  factory _$SettlementCopyWith(_Settlement value, $Res Function(_Settlement) _then) = __$SettlementCopyWithImpl;
@override @useResult
$Res call({
 String id, String month, double totalGroceryCost, double totalMeals, double mealRate, List<MemberBalance> memberBalances, String status, DateTime? calculatedAt
});




}
/// @nodoc
class __$SettlementCopyWithImpl<$Res>
    implements _$SettlementCopyWith<$Res> {
  __$SettlementCopyWithImpl(this._self, this._then);

  final _Settlement _self;
  final $Res Function(_Settlement) _then;

/// Create a copy of Settlement
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? month = null,Object? totalGroceryCost = null,Object? totalMeals = null,Object? mealRate = null,Object? memberBalances = null,Object? status = null,Object? calculatedAt = freezed,}) {
  return _then(_Settlement(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,month: null == month ? _self.month : month // ignore: cast_nullable_to_non_nullable
as String,totalGroceryCost: null == totalGroceryCost ? _self.totalGroceryCost : totalGroceryCost // ignore: cast_nullable_to_non_nullable
as double,totalMeals: null == totalMeals ? _self.totalMeals : totalMeals // ignore: cast_nullable_to_non_nullable
as double,mealRate: null == mealRate ? _self.mealRate : mealRate // ignore: cast_nullable_to_non_nullable
as double,memberBalances: null == memberBalances ? _self._memberBalances : memberBalances // ignore: cast_nullable_to_non_nullable
as List<MemberBalance>,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,calculatedAt: freezed == calculatedAt ? _self.calculatedAt : calculatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
