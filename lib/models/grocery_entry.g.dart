// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'grocery_entry.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_GroceryEntry _$GroceryEntryFromJson(Map<String, dynamic> json) =>
    _GroceryEntry(
      id: json['id'] as String,
      purchasedBy: json['purchasedBy'] as String,
      purchaserName: json['purchaserName'] as String,
      description: json['description'] as String,
      amount: (json['amount'] as num).toDouble(),
      ocrExtractedAmount: (json['ocrExtractedAmount'] as num?)?.toDouble(),
      date: json['date'] as String,
      receiptUrl: json['receiptUrl'] as String?,
      items:
          (json['items'] as List<dynamic>?)
              ?.map((e) => GroceryItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      status: json['status'] as String? ?? 'approved',
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$GroceryEntryToJson(_GroceryEntry instance) =>
    <String, dynamic>{
      'id': instance.id,
      'purchasedBy': instance.purchasedBy,
      'purchaserName': instance.purchaserName,
      'description': instance.description,
      'amount': instance.amount,
      'ocrExtractedAmount': instance.ocrExtractedAmount,
      'date': instance.date,
      'receiptUrl': instance.receiptUrl,
      'items': instance.items,
      'status': instance.status,
      'createdAt': instance.createdAt?.toIso8601String(),
    };
