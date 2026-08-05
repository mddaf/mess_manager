import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/constants.dart';
import '../../models/mess.dart';
import '../../models/member.dart';
import '../../models/settlement.dart';
import '../../models/member_balance.dart';

class MessRepository {
  final FirebaseFirestore _firestore;

  MessRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  String _generateInviteCode() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final random = Random();
    return List.generate(6, (index) => chars[random.nextInt(chars.length)]).join();
  }

  Future<Mess> createMess({
    required String name,
    required String address,
    required String userId,
    required String userName,
    required String userEmail,
  }) async {
    final messDoc = _firestore.collection(AppConstants.collectionMesses).doc();
    final inviteCode = _generateInviteCode();

    final mess = Mess(
      id: messDoc.id,
      name: name.trim(),
      address: address.trim(),
      createdBy: userId,
      inviteCode: inviteCode,
      currentManagerId: userId,
      createdAt: DateTime.now(),
    );

    await messDoc.set(Mess.toFirestore(mess, null));

    // Creator is Admin and initial Manager (Auto-approved)
    final member = Member(
      id: userId,
      userId: userId,
      name: userName,
      email: userEmail,
      role: 'admin',
      status: 'approved',
      joinedAt: DateTime.now(),
    );

    await messDoc
        .collection(AppConstants.collectionMembers)
        .doc(userId)
        .set(Member.toFirestore(member, null));

    // Update global user doc messIds
    await _firestore
        .collection(AppConstants.collectionUsers)
        .doc(userId)
        .update({
      'messIds': FieldValue.arrayUnion([messDoc.id]),
    });

    return mess;
  }

  /// Create an email-bound invite code
  Future<String> createEmailInvite({
    required String messId,
    required String targetEmail,
    required String invitedByUserId,
    required String invitedByRole, // 'admin' or 'member'
  }) async {
    final inviteCode = _generateInviteCode();
    await _firestore
        .collection(AppConstants.collectionMesses)
        .doc(messId)
        .collection('invites')
        .doc(targetEmail.trim().toLowerCase())
        .set({
      'targetEmail': targetEmail.trim().toLowerCase(),
      'inviteCode': inviteCode,
      'invitedBy': invitedByUserId,
      'invitedByRole': invitedByRole,
      'createdAt': FieldValue.serverTimestamp(),
    });

    return inviteCode;
  }

  Future<Mess?> joinMessWithInviteCode({
    required String inviteCode,
    required String userId,
    required String userName,
    required String userEmail,
  }) async {
    final cleanCode = inviteCode.trim().toUpperCase();
    final cleanEmail = userEmail.trim().toLowerCase();

    final query = await _firestore
        .collection(AppConstants.collectionMesses)
        .where('inviteCode', isEqualTo: cleanCode)
        .limit(1)
        .get();

    if (query.docs.isEmpty) return null;

    final messDoc = query.docs.first;
    final mess = Mess.fromFirestore(messDoc, null);

    // Check email-specific invite if available
    String memberStatus = 'approved'; // Default if admin general code
    final inviteDoc = await messDoc.reference
        .collection('invites')
        .doc(cleanEmail)
        .get();

    if (inviteDoc.exists) {
      final data = inviteDoc.data()!;
      final role = data['invitedByRole'] as String? ?? 'admin';
      // Members adding invites require Admin Approval
      if (role == 'member') {
        memberStatus = 'pending';
      }
    }

    // Check if already a member
    final existingMember = await messDoc.reference
        .collection(AppConstants.collectionMembers)
        .doc(userId)
        .get();

    if (existingMember.exists) return mess;

    final member = Member(
      id: userId,
      userId: userId,
      name: userName,
      email: userEmail,
      role: 'member',
      status: memberStatus,
      joinedAt: DateTime.now(),
    );

    await messDoc.reference
        .collection(AppConstants.collectionMembers)
        .doc(userId)
        .set(Member.toFirestore(member, null));

    await _firestore
        .collection(AppConstants.collectionUsers)
        .doc(userId)
        .update({
      'messIds': FieldValue.arrayUnion([mess.id]),
    });

    return mess;
  }

  Stream<Mess?> watchMess(String messId) {
    return _firestore
        .collection(AppConstants.collectionMesses)
        .doc(messId)
        .snapshots()
        .map((doc) => doc.exists ? Mess.fromFirestore(doc, null) : null);
  }

  Stream<List<Member>> watchMembers(String messId) {
    return _firestore
        .collection(AppConstants.collectionMesses)
        .doc(messId)
        .collection(AppConstants.collectionMembers)
        .orderBy('joinedAt')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Member.fromFirestore(doc, null))
            .toList());
  }

  /// Admin edits Mess Profile (Name, Address, Cutoff Hour)
  Future<void> updateMessDetails({
    required String messId,
    required String name,
    required String address,
    required int mealCutoffHour,
  }) async {
    await _firestore
        .collection(AppConstants.collectionMesses)
        .doc(messId)
        .update({
      'name': name.trim(),
      'address': address.trim(),
      'mealCutoffHour': mealCutoffHour,
    });
  }

  /// Member requests profile name change (Requires Admin Approval)
  Future<void> requestMemberNameUpdate({
    required String messId,
    required String memberId,
    required String newName,
  }) async {
    await _firestore
        .collection(AppConstants.collectionMesses)
        .doc(messId)
        .collection(AppConstants.collectionMembers)
        .doc(memberId)
        .update({'pendingName': newName.trim()});
  }

  /// Admin approves member join
  Future<void> approveMemberJoin({
    required String messId,
    required String memberId,
  }) async {
    await _firestore
        .collection(AppConstants.collectionMesses)
        .doc(messId)
        .collection(AppConstants.collectionMembers)
        .doc(memberId)
        .update({'status': 'approved'});
  }

  /// Admin rejects member join
  Future<void> rejectMemberJoin({
    required String messId,
    required String memberId,
  }) async {
    await removeMember(messId: messId, memberId: memberId);
  }

  /// Admin approves member profile edit
  Future<void> approveMemberNameUpdate({
    required String messId,
    required String memberId,
    required String approvedName,
  }) async {
    final batch = _firestore.batch();
    batch.update(
      _firestore
          .collection(AppConstants.collectionMesses)
          .doc(messId)
          .collection(AppConstants.collectionMembers)
          .doc(memberId),
      {
        'name': approvedName.trim(),
        'pendingName': FieldValue.delete(),
      },
    );
    batch.update(
      _firestore.collection(AppConstants.collectionUsers).doc(memberId),
      {'name': approvedName.trim()},
    );
    await batch.commit();
  }

  /// Admin rejects member profile edit
  Future<void> rejectMemberNameUpdate({
    required String messId,
    required String memberId,
  }) async {
    await _firestore
        .collection(AppConstants.collectionMesses)
        .doc(messId)
        .collection(AppConstants.collectionMembers)
        .doc(memberId)
        .update({'pendingName': FieldValue.delete()});
  }

  /// Assign a new manager for this mess
  Future<void> rotateManager({
    required String messId,
    required String newManagerId,
  }) async {
    await _firestore
        .collection(AppConstants.collectionMesses)
        .doc(messId)
        .update({'currentManagerId': newManagerId});
  }

  /// Promote a member to admin role
  Future<void> promoteToAdmin({
    required String messId,
    required String memberId,
  }) async {
    await _firestore
        .collection(AppConstants.collectionMesses)
        .doc(messId)
        .collection(AppConstants.collectionMembers)
        .doc(memberId)
        .update({'role': 'admin'});
  }

  /// Helper: delete all docs in a sub-collection using chunked batches (max 400 per batch)
  Future<void> _deleteSubCollection(
      DocumentReference messRef, String subCollection) async {
    QuerySnapshot snapshot;
    do {
      snapshot = await messRef.collection(subCollection).limit(400).get();
      if (snapshot.docs.isEmpty) break;
      final batch = _firestore.batch();
      for (final doc in snapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
    } while (snapshot.docs.length == 400);
  }

  /// Delete mess and ALL its sub-collections completely from Firestore
  Future<void> deleteMess({
    required String messId,
    required String userId,
  }) async {
    final messRef =
        _firestore.collection(AppConstants.collectionMesses).doc(messId);

    // 1. Remove messId from all member user docs (separate batch)
    final members =
        await messRef.collection(AppConstants.collectionMembers).get();
    final userBatch = _firestore.batch();
    for (final doc in members.docs) {
      userBatch.update(
        _firestore.collection(AppConstants.collectionUsers).doc(doc.id),
        {'messIds': FieldValue.arrayRemove([messId])},
      );
    }
    await userBatch.commit();

    // 2. Delete all sub-collections (chunked to stay under 500-doc batch limit)
    await _deleteSubCollection(messRef, AppConstants.collectionMembers);
    await _deleteSubCollection(messRef, AppConstants.collectionMealEntries);
    await _deleteSubCollection(messRef, AppConstants.collectionGroceryEntries);
    await _deleteSubCollection(messRef, AppConstants.collectionDeposits);
    await _deleteSubCollection(messRef, AppConstants.collectionSettlements);
    await _deleteSubCollection(messRef, 'invites');

    // 3. Delete the mess document itself
    await messRef.delete();
  }

  /// Leave a mess — removes only the leaving user.
  /// If they are the last approved member, the entire mess is deleted.
  Future<void> leaveMess({
    required String messId,
    required String userId,
  }) async {
    final messRef =
        _firestore.collection(AppConstants.collectionMesses).doc(messId);

    // Count remaining approved members
    final membersSnap = await messRef
        .collection(AppConstants.collectionMembers)
        .where('status', isEqualTo: 'approved')
        .get();

    if (membersSnap.docs.length <= 1) {
      // Last member leaving → delete the entire mess
      await deleteMess(messId: messId, userId: userId);
      return;
    }

    // Otherwise just remove this member
    await removeMember(messId: messId, memberId: userId);
  }

  /// Open New Month: Calculates settlement for ending month, archives it,
  /// carries forward unpaid dues to openingDues of each member, and updates activeMonth!
  Future<Settlement> openNewMonth({
    required String messId,
    required String currentMonth,
    required String nextMonth,
  }) async {
    final messRef = _firestore.collection(AppConstants.collectionMesses).doc(messId);

    // 1. Fetch approved groceries for currentMonth
    final start = '$currentMonth-01';
    final end = '$currentMonth-31';
    final groceriesSnap = await messRef
        .collection(AppConstants.collectionGroceryEntries)
        .where('date', isGreaterThanOrEqualTo: start)
        .where('date', isLessThanOrEqualTo: end)
        .get();

    double totalGroceryCost = 0.0;
    for (final doc in groceriesSnap.docs) {
      if (doc.data()['status'] == 'approved') {
        totalGroceryCost += (doc.data()['amount'] as num? ?? 0.0).toDouble();
      }
    }

    // 2. Fetch meal entries for currentMonth
    final mealsSnap = await messRef
        .collection(AppConstants.collectionMealEntries)
        .where('date', isGreaterThanOrEqualTo: start)
        .where('date', isLessThanOrEqualTo: end)
        .get();

    double totalMessMeals = 0.0;
    final Map<String, double> memberMealCounts = {};
    for (final doc in mealsSnap.docs) {
      final data = doc.data();
      final memberId = (data['memberId'] ?? data['userId']) as String? ?? '';
      final b = (data['breakfast'] as num? ?? 0.0).toDouble();
      final l = (data['lunch'] as num? ?? 0.0).toDouble();
      final d = (data['dinner'] as num? ?? 0.0).toDouble();
      final count = b + l + d;
      totalMessMeals += count;
      memberMealCounts[memberId] = (memberMealCounts[memberId] ?? 0.0) + count;
    }

    final double mealRate = totalMessMeals > 0 ? totalGroceryCost / totalMessMeals : 0.0;

    // 3. Fetch approved deposits for currentMonth
    final depositsSnap = await messRef
        .collection(AppConstants.collectionDeposits)
        .where('date', isGreaterThanOrEqualTo: start)
        .where('date', isLessThanOrEqualTo: end)
        .get();

    final Map<String, double> memberDeposits = {};
    for (final doc in depositsSnap.docs) {
      if (doc.data()['status'] == 'approved') {
        final memberId = (doc.data()['memberId'] ?? doc.data()['userId']) as String? ?? '';
        final amount = (doc.data()['amount'] as num? ?? 0.0).toDouble();
        memberDeposits[memberId] = (memberDeposits[memberId] ?? 0.0) + amount;
      }
    }

    // 4. Fetch all members and calculate balances
    final membersSnap = await messRef
        .collection(AppConstants.collectionMembers)
        .where('status', isEqualTo: 'approved')
        .get();

    final List<MemberBalance> memberBalances = [];
    final batch = _firestore.batch();

    for (final doc in membersSnap.docs) {
      final member = Member.fromFirestore(doc, null);
      final mMeals = memberMealCounts[member.userId] ?? 0.0;
      final mDeposit = memberDeposits[member.userId] ?? 0.0;
      final mCost = mMeals * mealRate;
      final openingDues = member.openingDues;

      // Net balance = Deposit - Cost - Opening Dues
      final netBalance = mDeposit - mCost - openingDues;

      memberBalances.add(MemberBalance(
        memberId: member.userId,
        memberName: member.name,
        totalMeals: mMeals,
        totalCost: mCost,
        totalDeposit: mDeposit,
        balance: netBalance,
      ));

      // Carry forward negative balance as new openingDues for next month!
      final newOpeningDues = netBalance < 0 ? netBalance.abs() : 0.0;

      // Update member doc in Firestore: reset totalDeposit for new month and update openingDues
      batch.update(doc.reference, {
        'openingDues': newOpeningDues,
        'totalDeposit': 0.0,
      });
    }

    // Save settlement document under settlements subcollection
    final settlementDoc = messRef.collection(AppConstants.collectionSettlements).doc(currentMonth);
    final settlement = Settlement(
      id: currentMonth,
      month: currentMonth,
      totalGroceryCost: totalGroceryCost,
      totalMeals: totalMessMeals,
      mealRate: mealRate,
      memberBalances: memberBalances,
      status: 'settled',
      calculatedAt: DateTime.now(),
    );

    batch.set(settlementDoc, Settlement.toFirestore(settlement, null));

    // Update activeMonth on Mess doc
    batch.update(messRef, {'activeMonth': nextMonth});

    await batch.commit();

    return settlement;
  }

  /// Check total unpaid dues for a user across all messes they belong to
  Future<double> getUserTotalDues(String userId) async {
    final userDoc = await _firestore.collection(AppConstants.collectionUsers).doc(userId).get();
    if (!userDoc.exists) return 0.0;

    final messIds = List<String>.from(userDoc.data()?['messIds'] ?? []);
    double totalDues = 0.0;

    for (final messId in messIds) {
      final memberDoc = await _firestore
          .collection(AppConstants.collectionMesses)
          .doc(messId)
          .collection(AppConstants.collectionMembers)
          .doc(userId)
          .get();

      if (memberDoc.exists) {
        final member = Member.fromFirestore(memberDoc, null);
        if (member.openingDues > 0) {
          totalDues += member.openingDues;
        }
      }
    }

    return totalDues;
  }

  /// Check if any member in the mess has outstanding dues
  Future<bool> hasAnyMemberDuesInMess(String messId) async {
    final membersSnap = await _firestore
        .collection(AppConstants.collectionMesses)
        .doc(messId)
        .collection(AppConstants.collectionMembers)
        .get();

    for (final doc in membersSnap.docs) {
      final member = Member.fromFirestore(doc, null);
      if (member.openingDues > 0) return true;
    }

    return false;
  }

  Future<void> removeMember({
    required String messId,
    required String memberId,
  }) async {
    final batch = _firestore.batch();
    batch.delete(
      _firestore
          .collection(AppConstants.collectionMesses)
          .doc(messId)
          .collection(AppConstants.collectionMembers)
          .doc(memberId),
    );
    batch.update(
      _firestore.collection(AppConstants.collectionUsers).doc(memberId),
      {
        'messIds': FieldValue.arrayRemove([messId])
      },
    );
    await batch.commit();
  }
}
