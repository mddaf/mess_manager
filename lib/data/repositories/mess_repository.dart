import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/constants.dart';
import '../../models/mess.dart';
import '../../models/member.dart';

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
