import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  final String id;
  final String channelId;
  final String senderId;
  final String senderName;
  final String senderRole; // organizer, security, emergency
  final String content;
  final String type; // text, alert, incident_update
  final String? relatedIncidentId;
  final bool isRead;
  final List<String> readBy;
  final DateTime createdAt;

  Message({
    required this.id,
    required this.channelId,
    required this.senderId,
    required this.senderName,
    required this.senderRole,
    required this.content,
    this.type = 'text',
    this.relatedIncidentId,
    this.isRead = false,
    this.readBy = const [],
    required this.createdAt,
  });

  static DateTime _parseDateTime(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value) ?? DateTime.now();
    return DateTime.now();
  }

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'] as String,
      channelId: json['channelId'] as String,
      senderId: json['senderId'] as String,
      senderName: json['senderName'] as String,
      senderRole: json['senderRole'] as String,
      content: json['content'] as String,
      type: json['type'] as String? ?? 'text',
      relatedIncidentId: json['relatedIncidentId'] as String?,
      isRead: json['isRead'] as bool? ?? false,
      readBy: (json['readBy'] as List?)?.cast<String>() ?? [],
      createdAt: _parseDateTime(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'channelId': channelId,
      'senderId': senderId,
      'senderName': senderName,
      'senderRole': senderRole,
      'content': content,
      'type': type,
      'relatedIncidentId': relatedIncidentId,
      'isRead': isRead,
      'readBy': readBy,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  // Get type display name
  String get typeDisplayName {
    switch (type) {
      case 'text':
        return 'Message';
      case 'alert':
        return 'Alert';
      case 'incident_update':
        return 'Incident Update';
      default:
        return type;
    }
  }

  // Get role display name
  String get roleDisplayName {
    switch (senderRole) {
      case 'organizer':
        return 'Organizer';
      case 'security':
        return 'Security';
      case 'emergency':
        return 'Emergency';
      default:
        return senderRole;
    }
  }

  // Get time ago string
  String get timeAgo {
    final duration = DateTime.now().difference(createdAt);
    if (duration.inMinutes < 1) return 'Just now';
    if (duration.inMinutes < 60) return '${duration.inMinutes}m ago';
    if (duration.inHours < 24) return '${duration.inHours}h ago';
    return '${duration.inDays}d ago';
  }

  // Check if message is an alert type
  bool get isAlert => type == 'alert';

  // Check if message is an incident update
  bool get isIncidentUpdate => type == 'incident_update';
}
