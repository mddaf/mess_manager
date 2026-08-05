import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'grocery_item.dart';

part 'grocery_entry.freezed.dart';
part 'grocery_entry.g.dart';

@freezed
abstract class GroceryEntry with _$GroceryEntry {
  const factory GroceryEntry({
    required String id,
    required String purchasedBy,
    required String purchaserName,
    required String description,
    required double amount,
    @Default('mess_fund') String paymentSource, // mess_fund, member_pocket, split
    @Default(0.0) double amountFromMess,
    @Default(0.0) double amountFromMember,
    double? ocrExtractedAmount,
    required String date, // YYYY-MM-DD
    String? receiptUrl,
    @Default([]) List<GroceryItem> items,
    @Default('approved') String status, // approved, pending, rejected
    DateTime? createdAt,
  }) = _GroceryEntry;

  factory GroceryEntry.fromJson(Map<String, dynamic> json) =>
      _$GroceryEntryFromJson(json);

  factory GroceryEntry.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data();
    if (data == null) throw Exception('GroceryEntry snapshot data is null');
    return GroceryEntry.fromJson({
      ...data,
      'id': snapshot.id,
      'createdAt': (data['createdAt'] as Timestamp?)?.toDate().toIso8601String(),
    });
  }

  static Map<String, dynamic> toFirestore(
    GroceryEntry entry,
    SetOptions? options,
  ) {
    final json = entry.toJson();
    json['items'] = entry.items.map((i) => i.toJson()).toList();
    if (entry.createdAt != null) {
      json['createdAt'] = Timestamp.fromDate(entry.createdAt!);
    }
    return json;
  }
}
