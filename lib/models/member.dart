import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'member.freezed.dart';
part 'member.g.dart';

@freezed
abstract class Member with _$Member {
  const factory Member({
    required String id,
    required String userId,
    required String name,
    required String email,
    @Default('member') String role, // admin, manager, member
    String? avatarUrl,
    @Default(0.0) double totalDeposit,
    @Default(0.0) double openingDues,
    @Default('approved') String status, // approved, pending, rejected
    String? pendingName,
    DateTime? joinedAt,
  }) = _Member;

  factory Member.fromJson(Map<String, dynamic> json) => _$MemberFromJson(json);

  factory Member.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data();
    if (data == null) throw Exception('Member snapshot data is null');
    return Member.fromJson({
      ...data,
      'id': snapshot.id,
      'joinedAt': (data['joinedAt'] as Timestamp?)?.toDate().toIso8601String(),
    });
  }

  static Map<String, dynamic> toFirestore(
    Member member,
    SetOptions? options,
  ) {
    final json = member.toJson();
    if (member.joinedAt != null) {
      json['joinedAt'] = Timestamp.fromDate(member.joinedAt!);
    }
    return json;
  }
}
