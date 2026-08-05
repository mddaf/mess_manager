// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_profile.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_UserProfile _$UserProfileFromJson(Map<String, dynamic> json) => _UserProfile(
  uid: json['uid'] as String,
  name: json['name'] as String,
  email: json['email'] as String,
  avatarUrl: json['avatarUrl'] as String?,
  messIds:
      (json['messIds'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  fcmTokens:
      (json['fcmTokens'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  locale: json['locale'] as String? ?? 'en',
  themeMode: json['themeMode'] as String? ?? 'system',
  createdAt: json['createdAt'] == null
      ? null
      : DateTime.parse(json['createdAt'] as String),
);

Map<String, dynamic> _$UserProfileToJson(_UserProfile instance) =>
    <String, dynamic>{
      'uid': instance.uid,
      'name': instance.name,
      'email': instance.email,
      'avatarUrl': instance.avatarUrl,
      'messIds': instance.messIds,
      'fcmTokens': instance.fcmTokens,
      'locale': instance.locale,
      'themeMode': instance.themeMode,
      'createdAt': instance.createdAt?.toIso8601String(),
    };
