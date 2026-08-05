// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'grocery_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_GroceryItem _$GroceryItemFromJson(Map<String, dynamic> json) => _GroceryItem(
  name: json['name'] as String,
  quantity: (json['quantity'] as num?)?.toDouble() ?? 1.0,
  unit: json['unit'] as String? ?? 'kg',
  price: (json['price'] as num).toDouble(),
);

Map<String, dynamic> _$GroceryItemToJson(_GroceryItem instance) =>
    <String, dynamic>{
      'name': instance.name,
      'quantity': instance.quantity,
      'unit': instance.unit,
      'price': instance.price,
    };
