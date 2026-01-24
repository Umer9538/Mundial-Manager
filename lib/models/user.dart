import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String id;
  final String email;
  final String name;
  final String role; // fan, organizer, security, emergency
  final String? phoneNumber;
  final String? profileImageUrl;
  final String? assignedZone; // For security personnel
  final bool locationSharingEnabled;
  final DateTime createdAt;
  final DateTime? lastLogin;

  User({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
    this.phoneNumber,
    this.profileImageUrl,
    this.assignedZone,
    this.locationSharingEnabled = false,
    required this.createdAt,
    this.lastLogin,
  });

  // Helper to parse DateTime from various formats (Firestore Timestamp, String, or DateTime)
  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    return null;
  }

  // Create user from JSON/Firestore document
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      email: json['email'] as String,
      name: json['name'] as String,
      role: json['role'] as String,
      phoneNumber: json['phoneNumber'] as String? ?? json['phone'] as String?,
      profileImageUrl: json['profileImageUrl'] as String?,
      assignedZone: json['assignedZone'] as String?,
      locationSharingEnabled: json['locationSharingEnabled'] as bool? ?? false,
      createdAt: _parseDateTime(json['createdAt']) ?? DateTime.now(),
      lastLogin: _parseDateTime(json['lastLogin']),
    );
  }

  // Convert user to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'role': role,
      'phoneNumber': phoneNumber,
      'profileImageUrl': profileImageUrl,
      'assignedZone': assignedZone,
      'locationSharingEnabled': locationSharingEnabled,
      'createdAt': createdAt.toIso8601String(),
      'lastLogin': lastLogin?.toIso8601String(),
    };
  }

  // Copy with method
  User copyWith({
    String? id,
    String? email,
    String? name,
    String? role,
    String? phoneNumber,
    String? profileImageUrl,
    String? assignedZone,
    bool? locationSharingEnabled,
    DateTime? createdAt,
    DateTime? lastLogin,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      role: role ?? this.role,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      assignedZone: assignedZone ?? this.assignedZone,
      locationSharingEnabled: locationSharingEnabled ?? this.locationSharingEnabled,
      createdAt: createdAt ?? this.createdAt,
      lastLogin: lastLogin ?? this.lastLogin,
    );
  }

  // Get role display name
  String get roleDisplayName {
    switch (role) {
      case 'fan':
        return 'Fan';
      case 'organizer':
        return 'Event Organizer';
      case 'security':
        return 'Security Team';
      case 'emergency':
        return 'Emergency Services';
      default:
        return 'User';
    }
  }
}
