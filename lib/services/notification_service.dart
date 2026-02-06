import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Callback type for handling notification navigation
typedef NotificationNavigationCallback = void Function(String type, String? referenceId);

class NotificationService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Optional navigation callback - set this from the app to enable deep linking
  NotificationNavigationCallback? onNavigationRequested;

  /// Store the last opened notification data for deferred handling
  Map<String, dynamic>? _pendingNavigationData;
  Map<String, dynamic>? get pendingNavigationData => _pendingNavigationData;

  void clearPendingNavigation() {
    _pendingNavigationData = null;
  }

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

    debugPrint('Notification permission status: ${settings.authorizationStatus}');

    // Get FCM token
    final token = await _messaging.getToken();
    debugPrint('FCM Token: ${token != null ? "obtained" : "null"}');

    // Listen to token refresh
    _messaging.onTokenRefresh.listen((newToken) {
      debugPrint('FCM Token refreshed');
      _updateTokenInFirestore(newToken);
    });

    // Handle foreground messages - show as overlay
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Handle background messages (when app is opened from notification)
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);

    // Check for initial message (app opened from terminated state)
    final initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      _handleMessageOpenedApp(initialMessage);
    }

    // Set foreground notification presentation options (iOS)
    await _messaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  // Get FCM token
  Future<String?> getToken() async {
    return await _messaging.getToken();
  }

  // Subscribe to topic
  Future<void> subscribeToTopic(String topic) async {
    await _messaging.subscribeToTopic(topic);
    debugPrint('Subscribed to topic: $topic');
  }

  // Unsubscribe from topic
  Future<void> unsubscribeFromTopic(String topic) async {
    await _messaging.unsubscribeFromTopic(topic);
    debugPrint('Unsubscribed from topic: $topic');
  }

  // Subscribe to role-based topics
  Future<void> subscribeToRoleTopics(String role) async {
    // Subscribe to general and role-specific topics
    await subscribeToTopic('all');
    await subscribeToTopic(role);
    await subscribeToTopic('general_announcements');

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
    await unsubscribeFromTopic('general_announcements');
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
    try {
      await _firestore.collection('users').doc(userId).update({
        'fcmToken': token,
        'fcmTokenUpdatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('Error saving FCM token: $e');
    }
  }

  // Update token in Firestore (called on token refresh)
  String? _currentUserId;
  void setCurrentUserId(String? userId) {
    _currentUserId = userId;
  }

  Future<void> _updateTokenInFirestore(String token) async {
    if (_currentUserId != null) {
      await saveTokenToFirestore(_currentUserId!, token);
    }
  }

  // Handle foreground message
  void _handleForegroundMessage(RemoteMessage message) {
    debugPrint('Foreground message: ${message.notification?.title}');

    // On iOS, the system will show the notification automatically due to
    // setForegroundNotificationPresentationOptions above.
    // On Android, FCM shows the notification automatically if there's
    // a notification payload. For data-only messages, you'd need
    // flutter_local_notifications.

    // Notify any listeners about the new message
    _onForegroundMessageCallback?.call(message);
  }

  /// Optional callback for foreground messages (e.g., to show in-app banners)
  void Function(RemoteMessage)? _onForegroundMessageCallback;
  set onForegroundMessage(void Function(RemoteMessage)? callback) {
    _onForegroundMessageCallback = callback;
  }

  // Handle message when app is opened from notification
  void _handleMessageOpenedApp(RemoteMessage message) {
    debugPrint('App opened from notification: ${message.notification?.title}');

    // Navigate to appropriate screen based on message data
    final data = message.data;
    final type = data['type'] as String?;
    final referenceId = data['referenceId'] as String?;

    if (type != null && onNavigationRequested != null) {
      onNavigationRequested!(type, referenceId);
    } else if (type != null) {
      // Store for deferred handling if no callback is set yet
      _pendingNavigationData = data;
    }
  }

  // Create a notification document in Firestore (for in-app notifications)
  Future<void> createNotification({
    required String userId,
    required String title,
    required String body,
    required String type,
    String? referenceId,
    Map<String, dynamic>? data,
  }) async {
    await _firestore.collection('notifications').add({
      'userId': userId,
      'title': title,
      'body': body,
      'type': type,
      'referenceId': referenceId,
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

  // Get unread notification count
  Stream<int> getUnreadCount(String userId) {
    return _firestore
        .collection('notifications')
        .where('userId', isEqualTo: userId)
        .where('isRead', isEqualTo: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }
}
