import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'meal_entry.freezed.dart';
part 'meal_entry.g.dart';

@freezed
abstract class MealEntry with _$MealEntry {
  const factory MealEntry({
    required String id,
    required String memberId,
    required String date, // YYYY-MM-DD
    @Default(0.0) double breakfast, // 0.0, 0.5, 1.0
    @Default(0.0) double lunch,     // 0.0, 0.5, 1.0
    @Default(0.0) double dinner,    // 0.0, 0.5, 1.0
    @Default(false) bool locked,
    DateTime? updatedAt,
  }) = _MealEntry;

  const MealEntry._();

  double get totalMealsToday => breakfast + lunch + dinner;

  factory MealEntry.fromJson(Map<String, dynamic> json) => _$MealEntryFromJson(json);

  factory MealEntry.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data();
    if (data == null) throw Exception('MealEntry snapshot data is null');
    return MealEntry.fromJson({
      ...data,
      'id': snapshot.id,
      'updatedAt': (data['updatedAt'] as Timestamp?)?.toDate().toIso8601String(),
    });
  }

  static Map<String, dynamic> toFirestore(
    MealEntry entry,
    SetOptions? options,
  ) {
    final json = entry.toJson();
    if (entry.updatedAt != null) {
      json['updatedAt'] = Timestamp.fromDate(entry.updatedAt!);
    }
    return json;
  }
}
