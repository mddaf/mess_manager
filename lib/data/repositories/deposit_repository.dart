import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/constants.dart';
import '../../models/deposit.dart';

class DepositRepository {
  final FirebaseFirestore _firestore;

  DepositRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  Stream<List<Deposit>> watchMonthlyDeposits({
    required String messId,
    required String monthPrefix, // YYYY-MM
  }) {
    final start = '$monthPrefix-01';
    final end = '$monthPrefix-31';

    return _firestore
        .collection(AppConstants.collectionMesses)
        .doc(messId)
        .collection(AppConstants.collectionDeposits)
        .where('date', isGreaterThanOrEqualTo: start)
        .where('date', isLessThanOrEqualTo: end)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Deposit.fromFirestore(doc, null))
            .toList());
  }

  Future<void> addDeposit({
    required String messId,
    required Deposit deposit,
  }) async {
    final docRef = _firestore
        .collection(AppConstants.collectionMesses)
        .doc(messId)
        .collection(AppConstants.collectionDeposits)
        .doc(deposit.id);

    await docRef.set(Deposit.toFirestore(deposit, null));

    // If initial status is approved (e.g. manager added it), increment totalDeposit
    if (deposit.status == 'approved') {
      await _firestore
          .collection(AppConstants.collectionMesses)
          .doc(messId)
          .collection(AppConstants.collectionMembers)
          .doc(deposit.memberId)
          .update({
        'totalDeposit': FieldValue.increment(deposit.amount),
      });
    }
  }

  Future<void> updateDepositStatus({
    required String messId,
    required String depositId,
    required String memberId,
    required double amount,
    required String newStatus, // 'approved', 'rejected'
    required String previousStatus,
  }) async {
    await _firestore
        .collection(AppConstants.collectionMesses)
        .doc(messId)
        .collection(AppConstants.collectionDeposits)
        .doc(depositId)
        .update({'status': newStatus});

    // Increment member totalDeposit when moving from pending/rejected -> approved
    if (newStatus == 'approved' && previousStatus != 'approved') {
      await _firestore
          .collection(AppConstants.collectionMesses)
          .doc(messId)
          .collection(AppConstants.collectionMembers)
          .doc(memberId)
          .update({
        'totalDeposit': FieldValue.increment(amount),
      });
    } else if (previousStatus == 'approved' && newStatus != 'approved') {
      // Revert deposit if previously approved and now rejected
      await _firestore
          .collection(AppConstants.collectionMesses)
          .doc(messId)
          .collection(AppConstants.collectionMembers)
          .doc(memberId)
          .update({
        'totalDeposit': FieldValue.increment(-amount),
      });
    }
  }
}
