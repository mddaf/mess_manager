import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/constants.dart';
import '../../models/settlement.dart';
import '../../models/member_balance.dart';
import '../services/api_service.dart';

class SettlementRepository {
  final FirebaseFirestore _firestore;
  final ApiService _apiService;

  SettlementRepository({
    FirebaseFirestore? firestore,
    ApiService? apiService,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _apiService = apiService ?? ApiService();

  Stream<Settlement?> watchSettlement({
    required String messId,
    required String month, // YYYY-MM
  }) {
    return _firestore
        .collection(AppConstants.collectionMesses)
        .doc(messId)
        .collection(AppConstants.collectionSettlements)
        .doc(month)
        .snapshots()
        .map((doc) => doc.exists ? Settlement.fromFirestore(doc, null) : null);
  }

  /// Calculates settlement locally or via REST API, ensuring high availability
  Future<Settlement> calculateSettlement({
    required String messId,
    required String month,
  }) async {
    try {
      // Try calling REST API first
      return await _apiService.calculateAndStoreSettlement(
        messId: messId,
        month: month,
      );
    } catch (_) {
      // Fallback: Perform local calculation & transaction in Firestore
      return await _calculateLocally(messId, month);
    }
  }

  Future<Settlement> _calculateLocally(String messId, String month) async {
    final start = '$month-01';
    final end = '$month-31';

    // 1. Fetch groceries
    final groceriesSnap = await _firestore
        .collection(AppConstants.collectionMesses)
        .doc(messId)
        .collection(AppConstants.collectionGroceryEntries)
        .where('date', isGreaterThanOrEqualTo: start)
        .where('date', isLessThanOrEqualTo: end)
        .get();

    double totalGroceryCost = 0.0;
    for (final doc in groceriesSnap.docs) {
      totalGroceryCost += (doc.data()['amount'] as num).toDouble();
    }

    // 2. Fetch meals
    final mealsSnap = await _firestore
        .collection(AppConstants.collectionMesses)
        .doc(messId)
        .collection(AppConstants.collectionMealEntries)
        .where('date', isGreaterThanOrEqualTo: start)
        .where('date', isLessThanOrEqualTo: end)
        .get();

    final Map<String, double> memberMeals = {};
    double totalMeals = 0.0;

    for (final doc in mealsSnap.docs) {
      final data = doc.data();
      final mId = data['memberId'] as String;
      final b = (data['breakfast'] as num).toDouble();
      final l = (data['lunch'] as num).toDouble();
      final d = (data['dinner'] as num).toDouble();
      final dayMeals = b + l + d;

      memberMeals[mId] = (memberMeals[mId] ?? 0.0) + dayMeals;
      totalMeals += dayMeals;
    }

    final mealRate = totalMeals > 0 ? (totalGroceryCost / totalMeals) : 0.0;

    // 3. Fetch members & deposits
    final membersSnap = await _firestore
        .collection(AppConstants.collectionMesses)
        .doc(messId)
        .collection(AppConstants.collectionMembers)
        .get();

    final depositsSnap = await _firestore
        .collection(AppConstants.collectionMesses)
        .doc(messId)
        .collection(AppConstants.collectionDeposits)
        .where('date', isGreaterThanOrEqualTo: start)
        .where('date', isLessThanOrEqualTo: end)
        .get();

    final Map<String, double> memberDeposits = {};
    for (final doc in depositsSnap.docs) {
      final data = doc.data();
      final mId = data['memberId'] as String;
      final amt = (data['amount'] as num).toDouble();
      memberDeposits[mId] = (memberDeposits[mId] ?? 0.0) + amt;
    }

    final List<MemberBalance> balances = [];

    for (final doc in membersSnap.docs) {
      final mData = doc.data();
      final mId = doc.id;
      final name = mData['name'] as String;

      final mCount = memberMeals[mId] ?? 0.0;
      final cost = mCount * mealRate;
      final deposit = memberDeposits[mId] ?? (mData['totalDeposit'] as num).toDouble();
      final balance = deposit - cost;

      balances.add(MemberBalance(
        memberId: mId,
        memberName: name,
        totalMeals: mCount,
        totalCost: cost,
        totalDeposit: deposit,
        balance: balance,
      ));
    }

    final settlement = Settlement(
      id: month,
      month: month,
      totalGroceryCost: totalGroceryCost,
      totalMeals: totalMeals,
      mealRate: mealRate,
      memberBalances: balances,
      status: 'pending',
      calculatedAt: DateTime.now(),
    );

    // Write to Firestore
    await _firestore
        .collection(AppConstants.collectionMesses)
        .doc(messId)
        .collection(AppConstants.collectionSettlements)
        .doc(month)
        .set(Settlement.toFirestore(settlement, null));

    return settlement;
  }

  Future<void> markSettled({
    required String messId,
    required String month,
  }) async {
    await _firestore
        .collection(AppConstants.collectionMesses)
        .doc(messId)
        .collection(AppConstants.collectionSettlements)
        .doc(month)
        .update({'status': 'settled'});
  }
}
