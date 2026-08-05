import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'deposit.freezed.dart';
part 'deposit.g.dart';

@freezed
abstract class Deposit with _$Deposit {
  const factory Deposit({
    required String id,
    required String memberId,
    required String memberName,
    required double amount,
    required String date, // YYYY-MM-DD
    @Default('') String note,
    DateTime? createdAt,
  }) = _Deposit;

  factory Deposit.fromJson(Map<String, dynamic> json) =>
      _$DepositFromJson(json);

  factory Deposit.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data();
    if (data == null) throw Exception('Deposit snapshot data is null');
    return Deposit.fromJson({
      ...data,
      'id': snapshot.id,
      'createdAt': (data['createdAt'] as Timestamp?)?.toDate().toIso8601String(),
    });
  }

  static Map<String, dynamic> toFirestore(
    Deposit deposit,
    SetOptions? options,
  ) {
    final json = deposit.toJson();
    if (deposit.createdAt != null) {
      json['createdAt'] = Timestamp.fromDate(deposit.createdAt!);
    }
    return json;
  }
}
