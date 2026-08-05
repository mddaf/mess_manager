// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'deposit.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Deposit _$DepositFromJson(Map<String, dynamic> json) => _Deposit(
  id: json['id'] as String,
  memberId: json['memberId'] as String,
  memberName: json['memberName'] as String,
  amount: (json['amount'] as num).toDouble(),
  date: json['date'] as String,
  note: json['note'] as String? ?? '',
  createdAt: json['createdAt'] == null
      ? null
      : DateTime.parse(json['createdAt'] as String),
);

Map<String, dynamic> _$DepositToJson(_Deposit instance) => <String, dynamic>{
  'id': instance.id,
  'memberId': instance.memberId,
  'memberName': instance.memberName,
  'amount': instance.amount,
  'date': instance.date,
  'note': instance.note,
  'createdAt': instance.createdAt?.toIso8601String(),
};
