import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_profile.freezed.dart';
part 'user_profile.g.dart';

@freezed
abstract class UserProfile with _$UserProfile {
  const factory UserProfile({
    required String uid,
    required String name,
    required String email,
    String? avatarUrl,
    @Default([]) List<String> messIds,
    @Default([]) List<String> fcmTokens,
    @Default('en') String locale,
    @Default('system') String themeMode,
    DateTime? createdAt,
  }) = _UserProfile;

  factory UserProfile.fromJson(Map<String, dynamic> json) =>
      _$UserProfileFromJson(json);

  factory UserProfile.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data();
    if (data == null) {
      throw Exception('UserProfile snapshot contains null data');
    }
    return UserProfile.fromJson({
      ...data,
      'uid': snapshot.id,
      'createdAt': (data['createdAt'] as Timestamp?)?.toDate().toIso8601String(),
    });
  }

  static Map<String, dynamic> toFirestore(
    UserProfile user,
    SetOptions? options,
  ) {
    final json = user.toJson();
    if (user.createdAt != null) {
      json['createdAt'] = Timestamp.fromDate(user.createdAt!);
    }
    return json;
  }
}
