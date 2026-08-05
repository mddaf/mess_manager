// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'meal_entry.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$MealEntry {

 String get id; String get memberId; String get date;// YYYY-MM-DD
 double get breakfast;// 0.0, 0.5, 1.0
 double get lunch;// 0.0, 0.5, 1.0
 double get dinner;// 0.0, 0.5, 1.0
 bool get locked; DateTime? get updatedAt;
/// Create a copy of MealEntry
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MealEntryCopyWith<MealEntry> get copyWith => _$MealEntryCopyWithImpl<MealEntry>(this as MealEntry, _$identity);

  /// Serializes this MealEntry to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MealEntry&&(identical(other.id, id) || other.id == id)&&(identical(other.memberId, memberId) || other.memberId == memberId)&&(identical(other.date, date) || other.date == date)&&(identical(other.breakfast, breakfast) || other.breakfast == breakfast)&&(identical(other.lunch, lunch) || other.lunch == lunch)&&(identical(other.dinner, dinner) || other.dinner == dinner)&&(identical(other.locked, locked) || other.locked == locked)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,memberId,date,breakfast,lunch,dinner,locked,updatedAt);

@override
String toString() {
  return 'MealEntry(id: $id, memberId: $memberId, date: $date, breakfast: $breakfast, lunch: $lunch, dinner: $dinner, locked: $locked, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $MealEntryCopyWith<$Res>  {
  factory $MealEntryCopyWith(MealEntry value, $Res Function(MealEntry) _then) = _$MealEntryCopyWithImpl;
@useResult
$Res call({
 String id, String memberId, String date, double breakfast, double lunch, double dinner, bool locked, DateTime? updatedAt
});




}
/// @nodoc
class _$MealEntryCopyWithImpl<$Res>
    implements $MealEntryCopyWith<$Res> {
  _$MealEntryCopyWithImpl(this._self, this._then);

  final MealEntry _self;
  final $Res Function(MealEntry) _then;

/// Create a copy of MealEntry
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? memberId = null,Object? date = null,Object? breakfast = null,Object? lunch = null,Object? dinner = null,Object? locked = null,Object? updatedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,memberId: null == memberId ? _self.memberId : memberId // ignore: cast_nullable_to_non_nullable
as String,date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as String,breakfast: null == breakfast ? _self.breakfast : breakfast // ignore: cast_nullable_to_non_nullable
as double,lunch: null == lunch ? _self.lunch : lunch // ignore: cast_nullable_to_non_nullable
as double,dinner: null == dinner ? _self.dinner : dinner // ignore: cast_nullable_to_non_nullable
as double,locked: null == locked ? _self.locked : locked // ignore: cast_nullable_to_non_nullable
as bool,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [MealEntry].
extension MealEntryPatterns on MealEntry {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MealEntry value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MealEntry() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MealEntry value)  $default,){
final _that = this;
switch (_that) {
case _MealEntry():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MealEntry value)?  $default,){
final _that = this;
switch (_that) {
case _MealEntry() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String memberId,  String date,  double breakfast,  double lunch,  double dinner,  bool locked,  DateTime? updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MealEntry() when $default != null:
return $default(_that.id,_that.memberId,_that.date,_that.breakfast,_that.lunch,_that.dinner,_that.locked,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String memberId,  String date,  double breakfast,  double lunch,  double dinner,  bool locked,  DateTime? updatedAt)  $default,) {final _that = this;
switch (_that) {
case _MealEntry():
return $default(_that.id,_that.memberId,_that.date,_that.breakfast,_that.lunch,_that.dinner,_that.locked,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String memberId,  String date,  double breakfast,  double lunch,  double dinner,  bool locked,  DateTime? updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _MealEntry() when $default != null:
return $default(_that.id,_that.memberId,_that.date,_that.breakfast,_that.lunch,_that.dinner,_that.locked,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MealEntry extends MealEntry {
  const _MealEntry({required this.id, required this.memberId, required this.date, this.breakfast = 0.0, this.lunch = 0.0, this.dinner = 0.0, this.locked = false, this.updatedAt}): super._();
  factory _MealEntry.fromJson(Map<String, dynamic> json) => _$MealEntryFromJson(json);

@override final  String id;
@override final  String memberId;
@override final  String date;
// YYYY-MM-DD
@override@JsonKey() final  double breakfast;
// 0.0, 0.5, 1.0
@override@JsonKey() final  double lunch;
// 0.0, 0.5, 1.0
@override@JsonKey() final  double dinner;
// 0.0, 0.5, 1.0
@override@JsonKey() final  bool locked;
@override final  DateTime? updatedAt;

/// Create a copy of MealEntry
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MealEntryCopyWith<_MealEntry> get copyWith => __$MealEntryCopyWithImpl<_MealEntry>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MealEntryToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MealEntry&&(identical(other.id, id) || other.id == id)&&(identical(other.memberId, memberId) || other.memberId == memberId)&&(identical(other.date, date) || other.date == date)&&(identical(other.breakfast, breakfast) || other.breakfast == breakfast)&&(identical(other.lunch, lunch) || other.lunch == lunch)&&(identical(other.dinner, dinner) || other.dinner == dinner)&&(identical(other.locked, locked) || other.locked == locked)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,memberId,date,breakfast,lunch,dinner,locked,updatedAt);

@override
String toString() {
  return 'MealEntry(id: $id, memberId: $memberId, date: $date, breakfast: $breakfast, lunch: $lunch, dinner: $dinner, locked: $locked, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$MealEntryCopyWith<$Res> implements $MealEntryCopyWith<$Res> {
  factory _$MealEntryCopyWith(_MealEntry value, $Res Function(_MealEntry) _then) = __$MealEntryCopyWithImpl;
@override @useResult
$Res call({
 String id, String memberId, String date, double breakfast, double lunch, double dinner, bool locked, DateTime? updatedAt
});




}
/// @nodoc
class __$MealEntryCopyWithImpl<$Res>
    implements _$MealEntryCopyWith<$Res> {
  __$MealEntryCopyWithImpl(this._self, this._then);

  final _MealEntry _self;
  final $Res Function(_MealEntry) _then;

/// Create a copy of MealEntry
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? memberId = null,Object? date = null,Object? breakfast = null,Object? lunch = null,Object? dinner = null,Object? locked = null,Object? updatedAt = freezed,}) {
  return _then(_MealEntry(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,memberId: null == memberId ? _self.memberId : memberId // ignore: cast_nullable_to_non_nullable
as String,date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as String,breakfast: null == breakfast ? _self.breakfast : breakfast // ignore: cast_nullable_to_non_nullable
as double,lunch: null == lunch ? _self.lunch : lunch // ignore: cast_nullable_to_non_nullable
as double,dinner: null == dinner ? _self.dinner : dinner // ignore: cast_nullable_to_non_nullable
as double,locked: null == locked ? _self.locked : locked // ignore: cast_nullable_to_non_nullable
as bool,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
