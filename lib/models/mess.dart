import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'mess.freezed.dart';
part 'mess.g.dart';

@freezed
abstract class Mess with _$Mess {
  const factory Mess({
    required String id,
    required String name,
    required String address,
    required String createdBy,
    required String inviteCode,
    @Default(22) int mealCutoffHour,
    @Default('৳') String currency,
    String? currentManagerId,
    DateTime? createdAt,
  }) = _Mess;

  factory Mess.fromJson(Map<String, dynamic> json) => _$MessFromJson(json);

  factory Mess.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data();
    if (data == null) throw Exception('Mess snapshot data is null');
    return Mess.fromJson({
      ...data,
      'id': snapshot.id,
      'createdAt': (data['createdAt'] as Timestamp?)?.toDate().toIso8601String(),
    });
  }

  static Map<String, dynamic> toFirestore(
    Mess mess,
    SetOptions? options,
  ) {
    final json = mess.toJson();
    if (mess.createdAt != null) {
      json['createdAt'] = Timestamp.fromDate(mess.createdAt!);
    }
    return json;
  }
}
