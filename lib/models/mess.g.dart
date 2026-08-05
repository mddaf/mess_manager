// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mess.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Mess _$MessFromJson(Map<String, dynamic> json) => _Mess(
  id: json['id'] as String,
  name: json['name'] as String,
  address: json['address'] as String,
  createdBy: json['createdBy'] as String,
  inviteCode: json['inviteCode'] as String,
  mealCutoffHour: (json['mealCutoffHour'] as num?)?.toInt() ?? 22,
  currency: json['currency'] as String? ?? '৳',
  activeMonth: json['activeMonth'] as String? ?? '',
  currentManagerId: json['currentManagerId'] as String?,
  createdAt: json['createdAt'] == null
      ? null
      : DateTime.parse(json['createdAt'] as String),
);

Map<String, dynamic> _$MessToJson(_Mess instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'address': instance.address,
  'createdBy': instance.createdBy,
  'inviteCode': instance.inviteCode,
  'mealCutoffHour': instance.mealCutoffHour,
  'currency': instance.currency,
  'activeMonth': instance.activeMonth,
  'currentManagerId': instance.currentManagerId,
  'createdAt': instance.createdAt?.toIso8601String(),
};
