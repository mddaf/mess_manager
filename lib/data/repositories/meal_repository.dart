import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/constants.dart';
import '../../models/meal_entry.dart';

class MealRepository {
  final FirebaseFirestore _firestore;

  MealRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  Stream<List<MealEntry>> watchMealsForDate({
    required String messId,
    required String date, // YYYY-MM-DD
  }) {
    return _firestore
        .collection(AppConstants.collectionMesses)
        .doc(messId)
        .collection(AppConstants.collectionMealEntries)
        .where('date', isEqualTo: date)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => MealEntry.fromFirestore(doc, null))
            .toList());
  }

  Stream<List<MealEntry>> watchMonthlyMealsForMember({
    required String messId,
    required String memberId,
    required String monthPrefix, // YYYY-MM
  }) {
    final start = '$monthPrefix-01';
    final end = '$monthPrefix-31';

    return _firestore
        .collection(AppConstants.collectionMesses)
        .doc(messId)
        .collection(AppConstants.collectionMealEntries)
        .where('memberId', isEqualTo: memberId)
        .where('date', isGreaterThanOrEqualTo: start)
        .where('date', isLessThanOrEqualTo: end)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => MealEntry.fromFirestore(doc, null))
            .toList());
  }

  Future<void> updateMealEntry({
    required String messId,
    required String memberId,
    required String date,
    required double breakfast,
    required double lunch,
    required double dinner,
    bool locked = false,
  }) async {
    final docId = '${memberId}_$date';
    final docRef = _firestore
        .collection(AppConstants.collectionMesses)
        .doc(messId)
        .collection(AppConstants.collectionMealEntries)
        .doc(docId);

    final entry = MealEntry(
      id: docId,
      memberId: memberId,
      date: date,
      breakfast: breakfast,
      lunch: lunch,
      dinner: dinner,
      locked: locked,
      updatedAt: DateTime.now(),
    );

    await docRef.set(
      MealEntry.toFirestore(entry, null),
      SetOptions(merge: true),
    );
  }

  Future<void> setLockStatusForDate({
    required String messId,
    required String date,
    required bool locked,
  }) async {
    final query = await _firestore
        .collection(AppConstants.collectionMesses)
        .doc(messId)
        .collection(AppConstants.collectionMealEntries)
        .where('date', isEqualTo: date)
        .get();

    final batch = _firestore.batch();
    for (final doc in query.docs) {
      batch.update(doc.reference, {'locked': locked});
    }
    await batch.commit();
  }
}
