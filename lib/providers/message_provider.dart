import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/message.dart';

/// Represents a messaging channel
class Channel {
  final String id;
  final String name;
  final String description;
  final List<String> roles; // Which roles can access this channel
  DateTime? lastMessageAt;
  String? lastMessagePreview;
  int unreadCount;

  Channel({
    required this.id,
    required this.name,
    required this.description,
    required this.roles,
    this.lastMessageAt,
    this.lastMessagePreview,
    this.unreadCount = 0,
  });
}

class MessageProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<Channel> _channels = [];
  final Map<String, List<Message>> _messagesByChannel = {};
  String? _selectedChannelId;
  String? _currentUserRole;
  String? _currentUserId;
  bool _isLoading = false;
  String? _errorMessage;
  StreamSubscription<QuerySnapshot>? _messageSubscription;

  // Predefined channels
  static const List<Map<String, dynamic>> _predefinedChannels = [
    {
      'id': 'organizer-security',
      'name': 'Organizer - Security',
      'description': 'Communication between organizers and security team',
      'roles': ['organizer', 'security'],
    },
    {
      'id': 'organizer-emergency',
      'name': 'Organizer - Emergency',
      'description': 'Communication between organizers and emergency services',
      'roles': ['organizer', 'emergency'],
    },
    {
      'id': 'security-emergency',
      'name': 'Security - Emergency',
      'description': 'Communication between security and emergency teams',
      'roles': ['security', 'emergency'],
    },
    {
      'id': 'all-staff',
      'name': 'All Staff',
      'description': 'Broadcast channel for all staff members',
      'roles': ['organizer', 'security', 'emergency'],
    },
  ];

  // Getters
  List<Channel> get channels => _channels;
  String? get selectedChannelId => _selectedChannelId;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Get messages for the currently selected channel
  List<Message> get currentMessages {
    if (_selectedChannelId == null) return [];
    return _messagesByChannel[_selectedChannelId!] ?? [];
  }

  // Get messages for a specific channel
  List<Message> getMessagesForChannel(String channelId) {
    return _messagesByChannel[channelId] ?? [];
  }

  // Get channels accessible to current user role
  List<Channel> getChannels() {
    if (_currentUserRole == null) return [];
    return _channels
        .where((c) => c.roles.contains(_currentUserRole))
        .toList();
  }

  // Get total unread count across all channels
  int get totalUnreadCount {
    return getChannels().fold(0, (sum, c) => sum + c.unreadCount);
  }

  // Initialize message provider
  Future<void> initialize({
    required String userRole,
    required String userId,
  }) async {
    _isLoading = true;
    _currentUserRole = userRole;
    _currentUserId = userId;
    notifyListeners();

    try {
      // Initialize predefined channels filtered by role
      _channels = _predefinedChannels
          .where((c) => (c['roles'] as List).contains(userRole))
          .map((c) => Channel(
                id: c['id'] as String,
                name: c['name'] as String,
                description: c['description'] as String,
                roles: (c['roles'] as List).cast<String>(),
              ))
          .toList();

      // Load any custom channels from Firestore
      await _loadCustomChannels();

      // Load last messages for each channel
      for (final channel in _channels) {
        await _loadMessagesForChannel(channel.id, limit: 1);
        final messages = _messagesByChannel[channel.id];
        if (messages != null && messages.isNotEmpty) {
          channel.lastMessageAt = messages.first.createdAt;
          channel.lastMessagePreview = messages.first.content.length > 50
              ? '${messages.first.content.substring(0, 50)}...'
              : messages.first.content;
        }
      }

      // Select first channel by default
      if (_channels.isNotEmpty) {
        await selectChannel(_channels.first.id);
      }
    } catch (e) {
      _errorMessage = 'Failed to initialize messaging';
      debugPrint('Error initializing message provider: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load custom channels from Firestore
  Future<void> _loadCustomChannels() async {
    try {
      final snapshot = await _firestore
          .collection('channels')
          .where('roles', arrayContains: _currentUserRole)
          .get();

      for (final doc in snapshot.docs) {
        final data = doc.data();
        // Only add if not already a predefined channel
        if (!_channels.any((c) => c.id == doc.id)) {
          _channels.add(Channel(
            id: doc.id,
            name: data['name'] as String? ?? 'Channel',
            description: data['description'] as String? ?? '',
            roles: (data['roles'] as List?)?.cast<String>() ?? [],
          ));
        }
      }
    } catch (e) {
      debugPrint('Error loading custom channels: $e');
    }
  }

  // Load messages for a channel from Firestore
  Future<void> _loadMessagesForChannel(String channelId,
      {int limit = 50}) async {
    try {
      final snapshot = await _firestore
          .collection('messages')
          .where('channelId', isEqualTo: channelId)
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();

      final messages = snapshot.docs.map((doc) {
        return Message.fromJson({
          'id': doc.id,
          ...doc.data(),
        });
      }).toList();

      _messagesByChannel[channelId] = messages.reversed.toList();
    } catch (e) {
      debugPrint('Error loading messages for channel $channelId: $e');
      _messagesByChannel[channelId] = [];
    }
  }

  // Select a channel and start real-time listening
  Future<void> selectChannel(String channelId) async {
    _selectedChannelId = channelId;
    notifyListeners();

    // Load messages if not already loaded
    if (!_messagesByChannel.containsKey(channelId) ||
        (_messagesByChannel[channelId]?.isEmpty ?? true)) {
      await _loadMessagesForChannel(channelId);
    }

    // Mark messages as read
    await markAsRead(channelId);

    // Start real-time listener for this channel
    _startMessageListener(channelId);

    notifyListeners();
  }

  // Start real-time listener for a channel
  void _startMessageListener(String channelId) {
    _messageSubscription?.cancel();
    _messageSubscription = _firestore
        .collection('messages')
        .where('channelId', isEqualTo: channelId)
        .orderBy('createdAt', descending: true)
        .limit(100)
        .snapshots()
        .listen((snapshot) {
      final messages = snapshot.docs.map((doc) {
        return Message.fromJson({
          'id': doc.id,
          ...doc.data(),
        });
      }).toList();

      _messagesByChannel[channelId] = messages.reversed.toList();
      notifyListeners();
    });
  }

  // Send a message
  Future<bool> sendMessage({
    required String content,
    required String senderId,
    required String senderName,
    required String senderRole,
    String type = 'text',
    String? relatedIncidentId,
  }) async {
    if (_selectedChannelId == null) return false;

    try {
      final now = DateTime.now();
      final messageData = {
        'channelId': _selectedChannelId!,
        'senderId': senderId,
        'senderName': senderName,
        'senderRole': senderRole,
        'content': content,
        'type': type,
        'relatedIncidentId': relatedIncidentId,
        'isRead': false,
        'readBy': [senderId],
        'createdAt': FieldValue.serverTimestamp(),
      };

      final docRef = await _firestore.collection('messages').add(messageData);

      // Add to local list immediately for responsiveness
      final localMessage = Message(
        id: docRef.id,
        channelId: _selectedChannelId!,
        senderId: senderId,
        senderName: senderName,
        senderRole: senderRole,
        content: content,
        type: type,
        relatedIncidentId: relatedIncidentId,
        isRead: false,
        readBy: [senderId],
        createdAt: now,
      );

      _messagesByChannel[_selectedChannelId!] ??= [];
      _messagesByChannel[_selectedChannelId!]!.add(localMessage);

      // Update channel last message
      final channelIndex =
          _channels.indexWhere((c) => c.id == _selectedChannelId);
      if (channelIndex != -1) {
        _channels[channelIndex].lastMessageAt = now;
        _channels[channelIndex].lastMessagePreview = content.length > 50
            ? '${content.substring(0, 50)}...'
            : content;
      }

      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to send message: $e';
      notifyListeners();
      return false;
    }
  }

  // Mark messages in a channel as read
  Future<void> markAsRead(String channelId) async {
    if (_currentUserId == null) return;

    try {
      // Update unread count locally
      final channelIndex = _channels.indexWhere((c) => c.id == channelId);
      if (channelIndex != -1) {
        _channels[channelIndex].unreadCount = 0;
      }

      // Update in Firestore: add current user to readBy
      final unreadMessages = await _firestore
          .collection('messages')
          .where('channelId', isEqualTo: channelId)
          .where('isRead', isEqualTo: false)
          .get();

      final batch = _firestore.batch();
      for (final doc in unreadMessages.docs) {
        final readBy =
            (doc.data()['readBy'] as List?)?.cast<String>() ?? [];
        if (!readBy.contains(_currentUserId)) {
          batch.update(doc.reference, {
            'readBy': FieldValue.arrayUnion([_currentUserId]),
          });
        }
      }

      await batch.commit();
      notifyListeners();
    } catch (e) {
      debugPrint('Error marking messages as read: $e');
    }
  }

  // Create a custom channel
  Future<String?> createChannel({
    required String name,
    required String description,
    required List<String> roles,
  }) async {
    try {
      final docRef = await _firestore.collection('channels').add({
        'name': name,
        'description': description,
        'roles': roles,
        'createdAt': FieldValue.serverTimestamp(),
      });

      final newChannel = Channel(
        id: docRef.id,
        name: name,
        description: description,
        roles: roles,
      );

      _channels.add(newChannel);
      notifyListeners();
      return docRef.id;
    } catch (e) {
      _errorMessage = 'Failed to create channel: $e';
      notifyListeners();
      return null;
    }
  }

  // Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _messageSubscription?.cancel();
    super.dispose();
  }
}
