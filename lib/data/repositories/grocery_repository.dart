import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import '../../core/constants.dart';
import '../../models/grocery_entry.dart';

class GroceryRepository {
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;

  GroceryRepository({
    FirebaseFirestore? firestore,
    FirebaseStorage? storage,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _storage = storage ?? FirebaseStorage.instance;

  Stream<List<GroceryEntry>> watchMonthlyGroceries({
    required String messId,
    required String monthPrefix, // YYYY-MM
  }) {
    final start = '$monthPrefix-01';
    final end = '$monthPrefix-31';

    return _firestore
        .collection(AppConstants.collectionMesses)
        .doc(messId)
        .collection(AppConstants.collectionGroceryEntries)
        .where('date', isGreaterThanOrEqualTo: start)
        .where('date', isLessThanOrEqualTo: end)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => GroceryEntry.fromFirestore(doc, null))
            .toList());
  }

  Future<String?> uploadReceiptPhoto({
    required String messId,
    required String imagePath,
    Uint8List? webBytes,
  }) async {
    final fileName = 'receipt_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final ref = _storage.ref().child('receipts/$messId/$fileName');

    if (kIsWeb && webBytes != null) {
      await ref.putData(webBytes);
    } else {
      await ref.putFile(File(imagePath));
    }

    return await ref.getDownloadURL();
  }

  Future<void> addGroceryEntry({
    required String messId,
    required GroceryEntry entry,
  }) async {
    final messRef = _firestore.collection(AppConstants.collectionMesses).doc(messId);
    final docRef = messRef.collection(AppConstants.collectionGroceryEntries).doc(entry.id);

    final batch = _firestore.batch();
    batch.set(docRef, GroceryEntry.toFirestore(entry, null));

    // If approved directly by Manager & member paid out of pocket, credit deposit
    if (entry.status == 'approved' && entry.amountFromMember > 0) {
      final depId = 'dep_groc_${entry.id}';
      final depRef = messRef.collection(AppConstants.collectionDeposits).doc(depId);
      final depositJson = {
        'id': depId,
        'memberId': entry.purchasedBy,
        'memberName': entry.purchaserName,
        'amount': entry.amountFromMember,
        'date': entry.date,
        'note': 'Grocery Reimbursement: ${entry.description}',
        'status': 'approved',
        'createdAt': FieldValue.serverTimestamp(),
      };
      batch.set(depRef, depositJson);
      batch.update(
        messRef.collection(AppConstants.collectionMembers).doc(entry.purchasedBy),
        {'totalDeposit': FieldValue.increment(entry.amountFromMember)},
      );
    }

    await batch.commit();
  }

  Future<void> updateGroceryStatus({
    required String messId,
    required String entryId,
    required String status,
  }) async {
    final messRef = _firestore.collection(AppConstants.collectionMesses).doc(messId);
    final entryRef = messRef.collection(AppConstants.collectionGroceryEntries).doc(entryId);

    if (status == 'approved') {
      final entrySnap = await entryRef.get();
      if (entrySnap.exists) {
        final entry = GroceryEntry.fromFirestore(entrySnap, null);
        final batch = _firestore.batch();
        batch.update(entryRef, {'status': 'approved'});

        if (entry.amountFromMember > 0) {
          final depId = 'dep_groc_${entry.id}';
          final depRef = messRef.collection(AppConstants.collectionDeposits).doc(depId);
          final depositJson = {
            'id': depId,
            'memberId': entry.purchasedBy,
            'memberName': entry.purchaserName,
            'amount': entry.amountFromMember,
            'date': entry.date,
            'note': 'Grocery Reimbursement: ${entry.description}',
            'status': 'approved',
            'createdAt': FieldValue.serverTimestamp(),
          };
          batch.set(depRef, depositJson);
          batch.update(
            messRef.collection(AppConstants.collectionMembers).doc(entry.purchasedBy),
            {'totalDeposit': FieldValue.increment(entry.amountFromMember)},
          );
        }

        await batch.commit();
        return;
      }
    }

    await entryRef.update({'status': status});
  }

  Future<void> updateGroceryEntry({
    required String messId,
    required GroceryEntry entry,
  }) async {
    await _firestore
        .collection(AppConstants.collectionMesses)
        .doc(messId)
        .collection(AppConstants.collectionGroceryEntries)
        .doc(entry.id)
        .set(GroceryEntry.toFirestore(entry, null), SetOptions(merge: true));
  }

  Future<void> deleteGroceryEntry({
    required String messId,
    required String entryId,
  }) async {
    await _firestore
        .collection(AppConstants.collectionMesses)
        .doc(messId)
        .collection(AppConstants.collectionGroceryEntries)
        .doc(entryId)
        .delete();
  }
}
