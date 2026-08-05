import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import '../../core/constants.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Handle background notification payload
  debugPrint('Handling background message: ${message.messageId}');
}

class NotificationService {
  final FirebaseMessaging _messaging;
  final FirebaseFirestore _firestore;

  NotificationService({
    FirebaseMessaging? messaging,
    FirebaseFirestore? firestore,
  })  : _messaging = messaging ?? FirebaseMessaging.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  /// Initializes FCM for Android, iOS, and Web
  Future<void> initializeNotificationService(String currentUserId) async {
    // 1. Request Notification Permission (Required for iOS & Web)
    final NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized ||
        settings.authorizationStatus == AuthorizationStatus.provisional) {
      debugPrint('FCM Notification permission granted.');

      // Set background handler
      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

      // 2. Fetch FCM Token (Supports Web VAPID Key, Android & iOS)
      String? token;
      if (kIsWeb) {
        token = await _messaging.getToken(
          vapidKey: AppConstants.webVapidKey.isNotEmpty ? AppConstants.webVapidKey : null,
        );
      } else {
        token = await _messaging.getToken();
      }

      if (token != null && currentUserId.isNotEmpty) {
        await _saveTokenToFirestore(currentUserId, token);
      }

      // Listen to token refresh
      _messaging.onTokenRefresh.listen((newToken) {
        if (currentUserId.isNotEmpty) {
          _saveTokenToFirestore(currentUserId, newToken);
        }
      });

      // 3. Listen to Foreground Messages
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        debugPrint('FCM Foreground Message received: ${message.notification?.title}');
      });
    } else {
      debugPrint('FCM Notification permission denied by user.');
    }
  }

  Future<void> _saveTokenToFirestore(String userId, String token) async {
    try {
      await _firestore.collection(AppConstants.collectionUsers).doc(userId).update({
        'fcmTokens': FieldValue.arrayUnion([token]),
      });
    } catch (e) {
      debugPrint('Error saving FCM token to Firestore: $e');
    }
  }
}
