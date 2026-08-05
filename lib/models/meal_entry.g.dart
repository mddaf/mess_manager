// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'meal_entry.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_MealEntry _$MealEntryFromJson(Map<String, dynamic> json) => _MealEntry(
  id: json['id'] as String,
  memberId: json['memberId'] as String,
  date: json['date'] as String,
  breakfast: (json['breakfast'] as num?)?.toDouble() ?? 0.0,
  lunch: (json['lunch'] as num?)?.toDouble() ?? 0.0,
  dinner: (json['dinner'] as num?)?.toDouble() ?? 0.0,
  locked: json['locked'] as bool? ?? false,
  updatedAt: json['updatedAt'] == null
      ? null
      : DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$MealEntryToJson(_MealEntry instance) =>
    <String, dynamic>{
      'id': instance.id,
      'memberId': instance.memberId,
      'date': instance.date,
      'breakfast': instance.breakfast,
      'lunch': instance.lunch,
      'dinner': instance.dinner,
      'locked': instance.locked,
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };
