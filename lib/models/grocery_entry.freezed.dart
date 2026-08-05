// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'grocery_entry.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$GroceryEntry {

 String get id; String get purchasedBy; String get purchaserName; String get description; double get amount; double? get ocrExtractedAmount; String get date;// YYYY-MM-DD
 String? get receiptUrl; List<GroceryItem> get items; String get status;// approved, pending, rejected
 DateTime? get createdAt;
/// Create a copy of GroceryEntry
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GroceryEntryCopyWith<GroceryEntry> get copyWith => _$GroceryEntryCopyWithImpl<GroceryEntry>(this as GroceryEntry, _$identity);

  /// Serializes this GroceryEntry to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GroceryEntry&&(identical(other.id, id) || other.id == id)&&(identical(other.purchasedBy, purchasedBy) || other.purchasedBy == purchasedBy)&&(identical(other.purchaserName, purchaserName) || other.purchaserName == purchaserName)&&(identical(other.description, description) || other.description == description)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.ocrExtractedAmount, ocrExtractedAmount) || other.ocrExtractedAmount == ocrExtractedAmount)&&(identical(other.date, date) || other.date == date)&&(identical(other.receiptUrl, receiptUrl) || other.receiptUrl == receiptUrl)&&const DeepCollectionEquality().equals(other.items, items)&&(identical(other.status, status) || other.status == status)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,purchasedBy,purchaserName,description,amount,ocrExtractedAmount,date,receiptUrl,const DeepCollectionEquality().hash(items),status,createdAt);

@override
String toString() {
  return 'GroceryEntry(id: $id, purchasedBy: $purchasedBy, purchaserName: $purchaserName, description: $description, amount: $amount, ocrExtractedAmount: $ocrExtractedAmount, date: $date, receiptUrl: $receiptUrl, items: $items, status: $status, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $GroceryEntryCopyWith<$Res>  {
  factory $GroceryEntryCopyWith(GroceryEntry value, $Res Function(GroceryEntry) _then) = _$GroceryEntryCopyWithImpl;
@useResult
$Res call({
 String id, String purchasedBy, String purchaserName, String description, double amount, double? ocrExtractedAmount, String date, String? receiptUrl, List<GroceryItem> items, String status, DateTime? createdAt
});




}
/// @nodoc
class _$GroceryEntryCopyWithImpl<$Res>
    implements $GroceryEntryCopyWith<$Res> {
  _$GroceryEntryCopyWithImpl(this._self, this._then);

  final GroceryEntry _self;
  final $Res Function(GroceryEntry) _then;

/// Create a copy of GroceryEntry
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? purchasedBy = null,Object? purchaserName = null,Object? description = null,Object? amount = null,Object? ocrExtractedAmount = freezed,Object? date = null,Object? receiptUrl = freezed,Object? items = null,Object? status = null,Object? createdAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,purchasedBy: null == purchasedBy ? _self.purchasedBy : purchasedBy // ignore: cast_nullable_to_non_nullable
as String,purchaserName: null == purchaserName ? _self.purchaserName : purchaserName // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as double,ocrExtractedAmount: freezed == ocrExtractedAmount ? _self.ocrExtractedAmount : ocrExtractedAmount // ignore: cast_nullable_to_non_nullable
as double?,date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as String,receiptUrl: freezed == receiptUrl ? _self.receiptUrl : receiptUrl // ignore: cast_nullable_to_non_nullable
as String?,items: null == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as List<GroceryItem>,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [GroceryEntry].
extension GroceryEntryPatterns on GroceryEntry {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _GroceryEntry value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GroceryEntry() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _GroceryEntry value)  $default,){
final _that = this;
switch (_that) {
case _GroceryEntry():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _GroceryEntry value)?  $default,){
final _that = this;
switch (_that) {
case _GroceryEntry() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String purchasedBy,  String purchaserName,  String description,  double amount,  double? ocrExtractedAmount,  String date,  String? receiptUrl,  List<GroceryItem> items,  String status,  DateTime? createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GroceryEntry() when $default != null:
return $default(_that.id,_that.purchasedBy,_that.purchaserName,_that.description,_that.amount,_that.ocrExtractedAmount,_that.date,_that.receiptUrl,_that.items,_that.status,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String purchasedBy,  String purchaserName,  String description,  double amount,  double? ocrExtractedAmount,  String date,  String? receiptUrl,  List<GroceryItem> items,  String status,  DateTime? createdAt)  $default,) {final _that = this;
switch (_that) {
case _GroceryEntry():
return $default(_that.id,_that.purchasedBy,_that.purchaserName,_that.description,_that.amount,_that.ocrExtractedAmount,_that.date,_that.receiptUrl,_that.items,_that.status,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String purchasedBy,  String purchaserName,  String description,  double amount,  double? ocrExtractedAmount,  String date,  String? receiptUrl,  List<GroceryItem> items,  String status,  DateTime? createdAt)?  $default,) {final _that = this;
switch (_that) {
case _GroceryEntry() when $default != null:
return $default(_that.id,_that.purchasedBy,_that.purchaserName,_that.description,_that.amount,_that.ocrExtractedAmount,_that.date,_that.receiptUrl,_that.items,_that.status,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _GroceryEntry implements GroceryEntry {
  const _GroceryEntry({required this.id, required this.purchasedBy, required this.purchaserName, required this.description, required this.amount, this.ocrExtractedAmount, required this.date, this.receiptUrl, final  List<GroceryItem> items = const [], this.status = 'approved', this.createdAt}): _items = items;
  factory _GroceryEntry.fromJson(Map<String, dynamic> json) => _$GroceryEntryFromJson(json);

@override final  String id;
@override final  String purchasedBy;
@override final  String purchaserName;
@override final  String description;
@override final  double amount;
@override final  double? ocrExtractedAmount;
@override final  String date;
// YYYY-MM-DD
@override final  String? receiptUrl;
 final  List<GroceryItem> _items;
@override@JsonKey() List<GroceryItem> get items {
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_items);
}

@override@JsonKey() final  String status;
// approved, pending, rejected
@override final  DateTime? createdAt;

/// Create a copy of GroceryEntry
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GroceryEntryCopyWith<_GroceryEntry> get copyWith => __$GroceryEntryCopyWithImpl<_GroceryEntry>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$GroceryEntryToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GroceryEntry&&(identical(other.id, id) || other.id == id)&&(identical(other.purchasedBy, purchasedBy) || other.purchasedBy == purchasedBy)&&(identical(other.purchaserName, purchaserName) || other.purchaserName == purchaserName)&&(identical(other.description, description) || other.description == description)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.ocrExtractedAmount, ocrExtractedAmount) || other.ocrExtractedAmount == ocrExtractedAmount)&&(identical(other.date, date) || other.date == date)&&(identical(other.receiptUrl, receiptUrl) || other.receiptUrl == receiptUrl)&&const DeepCollectionEquality().equals(other._items, _items)&&(identical(other.status, status) || other.status == status)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,purchasedBy,purchaserName,description,amount,ocrExtractedAmount,date,receiptUrl,const DeepCollectionEquality().hash(_items),status,createdAt);

@override
String toString() {
  return 'GroceryEntry(id: $id, purchasedBy: $purchasedBy, purchaserName: $purchaserName, description: $description, amount: $amount, ocrExtractedAmount: $ocrExtractedAmount, date: $date, receiptUrl: $receiptUrl, items: $items, status: $status, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$GroceryEntryCopyWith<$Res> implements $GroceryEntryCopyWith<$Res> {
  factory _$GroceryEntryCopyWith(_GroceryEntry value, $Res Function(_GroceryEntry) _then) = __$GroceryEntryCopyWithImpl;
@override @useResult
$Res call({
 String id, String purchasedBy, String purchaserName, String description, double amount, double? ocrExtractedAmount, String date, String? receiptUrl, List<GroceryItem> items, String status, DateTime? createdAt
});




}
/// @nodoc
class __$GroceryEntryCopyWithImpl<$Res>
    implements _$GroceryEntryCopyWith<$Res> {
  __$GroceryEntryCopyWithImpl(this._self, this._then);

  final _GroceryEntry _self;
  final $Res Function(_GroceryEntry) _then;

/// Create a copy of GroceryEntry
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? purchasedBy = null,Object? purchaserName = null,Object? description = null,Object? amount = null,Object? ocrExtractedAmount = freezed,Object? date = null,Object? receiptUrl = freezed,Object? items = null,Object? status = null,Object? createdAt = freezed,}) {
  return _then(_GroceryEntry(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,purchasedBy: null == purchasedBy ? _self.purchasedBy : purchasedBy // ignore: cast_nullable_to_non_nullable
as String,purchaserName: null == purchaserName ? _self.purchaserName : purchaserName // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as double,ocrExtractedAmount: freezed == ocrExtractedAmount ? _self.ocrExtractedAmount : ocrExtractedAmount // ignore: cast_nullable_to_non_nullable
as double?,date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as String,receiptUrl: freezed == receiptUrl ? _self.receiptUrl : receiptUrl // ignore: cast_nullable_to_non_nullable
as String?,items: null == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<GroceryItem>,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
