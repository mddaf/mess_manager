import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../core/constants.dart';
import '../../models/user_profile.dart';

class AuthRepository {
  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;
  final GoogleSignIn _googleSignIn;

  AuthRepository({
    FirebaseAuth? firebaseAuth,
    FirebaseFirestore? firestore,
    GoogleSignIn? googleSignIn,
  })  : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance,
        _googleSignIn = googleSignIn ?? GoogleSignIn();

  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  User? get currentUser => _firebaseAuth.currentUser;

  ActionCodeSettings get _actionCodeSettings => ActionCodeSettings(
        url: 'https://meal-manager-844f5.web.app',
        handleCodeInApp: true,
      );

  Future<UserProfile?> getCurrentUserProfile() async {
    final user = currentUser;
    if (user == null) return null;

    try {
      final doc = await _firestore
          .collection(AppConstants.collectionUsers)
          .doc(user.uid)
          .get();

      if (doc.exists) {
        return UserProfile.fromFirestore(doc, null);
      }
    } catch (_) {}

    final newProfile = UserProfile(
      uid: user.uid,
      name: user.displayName ?? user.email?.split('@').first ?? 'Mess Member',
      email: user.email ?? '',
      avatarUrl: user.photoURL,
      createdAt: DateTime.now(),
    );

    try {
      await _firestore
          .collection(AppConstants.collectionUsers)
          .doc(user.uid)
          .set(UserProfile.toFirestore(newProfile, null));
    } catch (_) {}

    return newProfile;
  }

  Future<UserCredential> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    return await _firebaseAuth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  Future<UserCredential> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String name,
  }) async {
    final credential = await _firebaseAuth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );

    final uid = credential.user!.uid;
    final userProfile = UserProfile(
      uid: uid,
      name: name.trim(),
      email: email.trim(),
      createdAt: DateTime.now(),
    );

    try {
      await _firestore
          .collection(AppConstants.collectionUsers)
          .doc(uid)
          .set(UserProfile.toFirestore(userProfile, null));

      await credential.user!.updateDisplayName(name.trim());
    } catch (e) {
      debugPrint('UserProfile set error: $e');
    }

    try {
      // Trigger Email Verification Link with ActionCodeSettings redirect
      await credential.user!.sendEmailVerification(_actionCodeSettings);
    } catch (e) {
      debugPrint('Email verification error: $e');
    }

    return credential;
  }

  /// Sends password reset email link with ActionCodeSettings
  Future<void> sendPasswordResetEmail(String email) async {
    await _firebaseAuth.sendPasswordResetEmail(
      email: email.trim(),
      actionCodeSettings: _actionCodeSettings,
    );
  }

  /// Resends email verification link to logged-in user
  Future<void> sendEmailVerification() async {
    final user = currentUser;
    if (user != null) {
      await user.sendEmailVerification(_actionCodeSettings);
    }
  }

  /// Requests email change verification to new email
  Future<void> verifyBeforeUpdateEmail(String newEmail) async {
    final user = currentUser;
    if (user != null) {
      await user.verifyBeforeUpdateEmail(newEmail.trim(), _actionCodeSettings);
    }
  }

  Future<UserCredential?> signInWithGoogle() async {
    if (kIsWeb) {
      final GoogleAuthProvider googleProvider = GoogleAuthProvider();
      return await _firebaseAuth.signInWithPopup(googleProvider);
    } else {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      return await _firebaseAuth.signInWithCredential(credential);
    }
  }

  /// Bind / Link current authenticated user with a Google Account
  Future<void> linkGoogleAccount() async {
    final user = currentUser;
    if (user == null) return;

    if (kIsWeb) {
      final GoogleAuthProvider googleProvider = GoogleAuthProvider();
      await user.linkWithPopup(googleProvider);
    } else {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return;
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      await user.linkWithCredential(credential);
    }

    await _firestore
        .collection(AppConstants.collectionUsers)
        .doc(user.uid)
        .update({
      'avatarUrl': user.photoURL,
    });
  }

  Future<void> signOut() async {
    try {
      if (!kIsWeb) {
        await _googleSignIn.signOut();
      }
    } catch (_) {}
    await _firebaseAuth.signOut();
  }
}
