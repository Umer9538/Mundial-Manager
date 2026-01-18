import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Initialize notifications
  Future<void> initialize() async {
    // Request permission
    final settings = await _messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: true,
      provisional: false,
      sound: true,
    );

    if (kDebugMode) {
      print('Notification permission status: ${settings.authorizationStatus}');
    }

    // Get FCM token
    final token = await _messaging.getToken();
    if (kDebugMode) {
      print('FCM Token: $token');
    }

    // Listen to token refresh
    _messaging.onTokenRefresh.listen((newToken) {
      if (kDebugMode) {
        print('FCM Token refreshed: $newToken');
      }
      // Update token in Firestore if user is logged in
      _updateTokenInFirestore(newToken);
    });

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Handle background messages (when app is opened from notification)
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);

    // Check for initial message (app opened from terminated state)
    final initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      _handleMessageOpenedApp(initialMessage);
    }
  }

  // Get FCM token
  Future<String?> getToken() async {
    return await _messaging.getToken();
  }

  // Subscribe to topic
  Future<void> subscribeToTopic(String topic) async {
    await _messaging.subscribeToTopic(topic);
    if (kDebugMode) {
      print('Subscribed to topic: $topic');
    }
  }

  // Unsubscribe from topic
  Future<void> unsubscribeFromTopic(String topic) async {
    await _messaging.unsubscribeFromTopic(topic);
    if (kDebugMode) {
      print('Unsubscribed from topic: $topic');
    }
  }

  // Subscribe to role-based topics
  Future<void> subscribeToRoleTopics(String role) async {
    // Subscribe to general and role-specific topics
    await subscribeToTopic('all');
    await subscribeToTopic(role);

    // Role-specific subscriptions
    switch (role) {
      case 'organizer':
        await subscribeToTopic('staff');
        await subscribeToTopic('alerts_high');
        await subscribeToTopic('alerts_critical');
        break;
      case 'security':
        await subscribeToTopic('staff');
        await subscribeToTopic('security_alerts');
        await subscribeToTopic('incidents');
        break;
      case 'emergency':
        await subscribeToTopic('staff');
        await subscribeToTopic('emergency_alerts');
        await subscribeToTopic('incidents_critical');
        break;
      case 'fan':
        await subscribeToTopic('fan_alerts');
        break;
    }
  }

  // Unsubscribe from all topics
  Future<void> unsubscribeFromAllTopics(String role) async {
    await unsubscribeFromTopic('all');
    await unsubscribeFromTopic(role);
    await unsubscribeFromTopic('staff');
    await unsubscribeFromTopic('alerts_high');
    await unsubscribeFromTopic('alerts_critical');
    await unsubscribeFromTopic('security_alerts');
    await unsubscribeFromTopic('incidents');
    await unsubscribeFromTopic('emergency_alerts');
    await unsubscribeFromTopic('incidents_critical');
    await unsubscribeFromTopic('fan_alerts');
  }

  // Save FCM token to Firestore
  Future<void> saveTokenToFirestore(String userId, String token) async {
    await _firestore.collection('users').doc(userId).update({
      'fcmToken': token,
      'fcmTokenUpdatedAt': FieldValue.serverTimestamp(),
    });
  }

  // Update token in Firestore (called on token refresh)
  Future<void> _updateTokenInFirestore(String token) async {
    // This should be called with the current user ID
    // Implementation depends on how you manage auth state
  }

  // Handle foreground message
  void _handleForegroundMessage(RemoteMessage message) {
    if (kDebugMode) {
      print('Foreground message received:');
      print('Title: ${message.notification?.title}');
      print('Body: ${message.notification?.body}');
      print('Data: ${message.data}');
    }

    // You can show a local notification or update UI here
    // For now, we'll just log the message
  }

  // Handle message when app is opened from notification
  void _handleMessageOpenedApp(RemoteMessage message) {
    if (kDebugMode) {
      print('App opened from notification:');
      print('Title: ${message.notification?.title}');
      print('Body: ${message.notification?.body}');
      print('Data: ${message.data}');
    }

    // Navigate to appropriate screen based on message data
    final data = message.data;
    if (data.containsKey('type')) {
      switch (data['type']) {
        case 'incident':
          // Navigate to incident details
          break;
        case 'alert':
          // Navigate to alerts screen
          break;
        case 'crowd_warning':
          // Navigate to map/zone view
          break;
      }
    }
  }

  // Create a notification document in Firestore (for in-app notifications)
  Future<void> createNotification({
    required String userId,
    required String title,
    required String body,
    required String type,
    Map<String, dynamic>? data,
  }) async {
    await _firestore.collection('notifications').add({
      'userId': userId,
      'title': title,
      'body': body,
      'type': type,
      'data': data,
      'isRead': false,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // Get user notifications
  Stream<QuerySnapshot> getUserNotifications(String userId) {
    return _firestore
        .collection('notifications')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .limit(50)
        .snapshots();
  }

  // Mark notification as read
  Future<void> markNotificationAsRead(String notificationId) async {
    await _firestore.collection('notifications').doc(notificationId).update({
      'isRead': true,
      'readAt': FieldValue.serverTimestamp(),
    });
  }

  // Mark all notifications as read
  Future<void> markAllNotificationsAsRead(String userId) async {
    final batch = _firestore.batch();
    final notifications = await _firestore
        .collection('notifications')
        .where('userId', isEqualTo: userId)
        .where('isRead', isEqualTo: false)
        .get();

    for (final doc in notifications.docs) {
      batch.update(doc.reference, {
        'isRead': true,
        'readAt': FieldValue.serverTimestamp(),
      });
    }

    await batch.commit();
  }

  // Delete old notifications (cleanup)
  Future<void> deleteOldNotifications(String userId, {int daysOld = 30}) async {
    final cutoffDate = DateTime.now().subtract(Duration(days: daysOld));
    final batch = _firestore.batch();

    final oldNotifications = await _firestore
        .collection('notifications')
        .where('userId', isEqualTo: userId)
        .where('createdAt', isLessThan: Timestamp.fromDate(cutoffDate))
        .get();

    for (final doc in oldNotifications.docs) {
      batch.delete(doc.reference);
    }

    await batch.commit();
  }
}
