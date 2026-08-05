import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'member_balance.dart';

part 'settlement.freezed.dart';
part 'settlement.g.dart';

@freezed
@JsonSerializable(explicitToJson: true)
abstract class Settlement with _$Settlement {
  const factory Settlement({
    required String id,
    required String month, // YYYY-MM
    required double totalGroceryCost,
    required double totalMeals,
    required double mealRate,
    @Default([]) List<MemberBalance> memberBalances,
    @Default('pending') String status, // pending, settled
    DateTime? calculatedAt,
  }) = _Settlement;

  factory Settlement.fromJson(Map<String, dynamic> json) =>
      _$SettlementFromJson(json);

  factory Settlement.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data();
    if (data == null) throw Exception('Settlement snapshot data is null');
    return Settlement.fromJson({
      ...data,
      'id': snapshot.id,
      'calculatedAt':
          (data['calculatedAt'] as Timestamp?)?.toDate().toIso8601String(),
    });
  }

  static Map<String, dynamic> toFirestore(
    Settlement settlement,
    SetOptions? options,
  ) {
    final json = settlement.toJson();
    json['memberBalances'] =
        settlement.memberBalances.map((b) => b.toJson()).toList();
    if (settlement.calculatedAt != null) {
      json['calculatedAt'] = Timestamp.fromDate(settlement.calculatedAt!);
    }
    return json;
  }
}
