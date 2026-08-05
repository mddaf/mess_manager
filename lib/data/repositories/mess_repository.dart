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

    // Creator is Admin and initial Manager
    final member = Member(
      id: userId,
      userId: userId,
      name: userName,
      email: userEmail,
      role: 'admin',
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

  Future<Mess?> joinMessWithInviteCode({
    required String inviteCode,
    required String userId,
    required String userName,
    required String userEmail,
  }) async {
    final query = await _firestore
        .collection(AppConstants.collectionMesses)
        .where('inviteCode', isEqualTo: inviteCode.trim().toUpperCase())
        .limit(1)
        .get();

    if (query.docs.isEmpty) return null;

    final messDoc = query.docs.first;
    final mess = Mess.fromFirestore(messDoc, null);

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

  Future<void> updateMemberRole({
    required String messId,
    required String memberId,
    required String role,
  }) async {
    await _firestore
        .collection(AppConstants.collectionMesses)
        .doc(messId)
        .collection(AppConstants.collectionMembers)
        .doc(memberId)
        .update({'role': role});
  }

  Future<void> setCurrentManager({
    required String messId,
    required String managerId,
  }) async {
    await _firestore
        .collection(AppConstants.collectionMesses)
        .doc(messId)
        .update({'currentManagerId': managerId});
  }

  /// Delete mess and all its sub-collections
  Future<void> deleteMess({
    required String messId,
    required String userId,
  }) async {
    final messRef =
        _firestore.collection(AppConstants.collectionMesses).doc(messId);

    // Delete all members sub-collection docs
    final members =
        await messRef.collection(AppConstants.collectionMembers).get();
    final batch = _firestore.batch();
    for (final doc in members.docs) {
      batch.delete(doc.reference);
      // Remove messId from each user's profile
      batch.update(
        _firestore.collection(AppConstants.collectionUsers).doc(doc.id),
        {
          'messIds': FieldValue.arrayRemove([messId])
        },
      );
    }

    // Delete meal entries sub-collection
    final meals = await messRef.collection('mealEntries').get();
    for (final doc in meals.docs) {
      batch.delete(doc.reference);
    }

    // Delete grocery entries sub-collection
    final groceries = await messRef.collection('groceryEntries').get();
    for (final doc in groceries.docs) {
      batch.delete(doc.reference);
    }

    // Delete the mess document itself
    batch.delete(messRef);

    await batch.commit();
  }

  /// Remove a single member from mess
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
