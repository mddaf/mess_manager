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
    final docRef = _firestore
        .collection(AppConstants.collectionMesses)
        .doc(messId)
        .collection(AppConstants.collectionGroceryEntries)
        .doc(entry.id);

    await docRef.set(GroceryEntry.toFirestore(entry, null));
  }

  Future<void> updateGroceryStatus({
    required String messId,
    required String entryId,
    required String status,
  }) async {
    await _firestore
        .collection(AppConstants.collectionMesses)
        .doc(messId)
        .collection(AppConstants.collectionGroceryEntries)
        .doc(entryId)
        .update({'status': status});
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
