// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'member.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Member _$MemberFromJson(Map<String, dynamic> json) => _Member(
  id: json['id'] as String,
  userId: json['userId'] as String,
  name: json['name'] as String,
  email: json['email'] as String,
  role: json['role'] as String? ?? 'member',
  avatarUrl: json['avatarUrl'] as String?,
  totalDeposit: (json['totalDeposit'] as num?)?.toDouble() ?? 0.0,
  openingDues: (json['openingDues'] as num?)?.toDouble() ?? 0.0,
  status: json['status'] as String? ?? 'approved',
  pendingName: json['pendingName'] as String?,
  joinedAt: json['joinedAt'] == null
      ? null
      : DateTime.parse(json['joinedAt'] as String),
);

Map<String, dynamic> _$MemberToJson(_Member instance) => <String, dynamic>{
  'id': instance.id,
  'userId': instance.userId,
  'name': instance.name,
  'email': instance.email,
  'role': instance.role,
  'avatarUrl': instance.avatarUrl,
  'totalDeposit': instance.totalDeposit,
  'openingDues': instance.openingDues,
  'status': instance.status,
  'pendingName': instance.pendingName,
  'joinedAt': instance.joinedAt?.toIso8601String(),
};
