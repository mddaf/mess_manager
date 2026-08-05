// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settlement.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Settlement _$SettlementFromJson(Map<String, dynamic> json) => _Settlement(
  id: json['id'] as String,
  month: json['month'] as String,
  totalGroceryCost: (json['totalGroceryCost'] as num).toDouble(),
  totalMeals: (json['totalMeals'] as num).toDouble(),
  mealRate: (json['mealRate'] as num).toDouble(),
  memberBalances:
      (json['memberBalances'] as List<dynamic>?)
          ?.map((e) => MemberBalance.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  status: json['status'] as String? ?? 'pending',
  calculatedAt: json['calculatedAt'] == null
      ? null
      : DateTime.parse(json['calculatedAt'] as String),
);

Map<String, dynamic> _$SettlementToJson(_Settlement instance) =>
    <String, dynamic>{
      'id': instance.id,
      'month': instance.month,
      'totalGroceryCost': instance.totalGroceryCost,
      'totalMeals': instance.totalMeals,
      'mealRate': instance.mealRate,
      'memberBalances': instance.memberBalances.map((e) => e.toJson()).toList(),
      'status': instance.status,
      'calculatedAt': instance.calculatedAt?.toIso8601String(),
    };
