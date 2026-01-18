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

  // Create user from JSON
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      email: json['email'] as String,
      name: json['name'] as String,
      role: json['role'] as String,
      phoneNumber: json['phoneNumber'] as String?,
      profileImageUrl: json['profileImageUrl'] as String?,
      assignedZone: json['assignedZone'] as String?,
      locationSharingEnabled: json['locationSharingEnabled'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
      lastLogin: json['lastLogin'] != null
          ? DateTime.parse(json['lastLogin'] as String)
          : null,
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
