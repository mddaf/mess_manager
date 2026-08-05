// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'member_balance.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_MemberBalance _$MemberBalanceFromJson(Map<String, dynamic> json) =>
    _MemberBalance(
      memberId: json['memberId'] as String,
      memberName: json['memberName'] as String,
      totalMeals: (json['totalMeals'] as num).toDouble(),
      totalCost: (json['totalCost'] as num).toDouble(),
      totalDeposit: (json['totalDeposit'] as num).toDouble(),
      balance: (json['balance'] as num).toDouble(),
    );

Map<String, dynamic> _$MemberBalanceToJson(_MemberBalance instance) =>
    <String, dynamic>{
      'memberId': instance.memberId,
      'memberName': instance.memberName,
      'totalMeals': instance.totalMeals,
      'totalCost': instance.totalCost,
      'totalDeposit': instance.totalDeposit,
      'balance': instance.balance,
    };
