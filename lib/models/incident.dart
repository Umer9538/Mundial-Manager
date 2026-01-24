import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:latlong2/latlong.dart';

class Incident {
  final String id;
  final String eventId;
  final String reportedBy; // userId
  final String reportedByName;
  final LatLng location;
  final String type; // medical, security, overcrowding, other
  final String description;
  final String severity; // low, medium, high, critical
  final String status; // reported, dispatched, on-site, resolved
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? assignedTo; // userId (emergency services)
  final String? assignedToName;
  final String? resolutionNotes;
  final List<String>? imageUrls;

  Incident({
    required this.id,
    required this.eventId,
    required this.reportedBy,
    required this.reportedByName,
    required this.location,
    required this.type,
    required this.description,
    required this.severity,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.assignedTo,
    this.assignedToName,
    this.resolutionNotes,
    this.imageUrls,
  });

  static DateTime _parseDateTime(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value) ?? DateTime.now();
    return DateTime.now();
  }

  factory Incident.fromJson(Map<String, dynamic> json) {
    return Incident(
      id: json['id'] as String,
      eventId: json['eventId'] as String,
      reportedBy: json['reportedBy'] as String,
      reportedByName: json['reportedByName'] as String,
      location: LatLng(
        (json['latitude'] as num).toDouble(),
        (json['longitude'] as num).toDouble(),
      ),
      type: json['type'] as String,
      description: json['description'] as String,
      severity: json['severity'] as String,
      status: json['status'] as String,
      createdAt: _parseDateTime(json['createdAt']),
      updatedAt: _parseDateTime(json['updatedAt']),
      assignedTo: json['assignedTo'] as String?,
      assignedToName: json['assignedToName'] as String?,
      resolutionNotes: json['resolutionNotes'] as String?,
      imageUrls: (json['imageUrls'] as List?)?.cast<String>(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'eventId': eventId,
      'reportedBy': reportedBy,
      'reportedByName': reportedByName,
      'latitude': location.latitude,
      'longitude': location.longitude,
      'type': type,
      'description': description,
      'severity': severity,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'assignedTo': assignedTo,
      'assignedToName': assignedToName,
      'resolutionNotes': resolutionNotes,
      'imageUrls': imageUrls,
    };
  }

  // Copy with method
  Incident copyWith({
    String? id,
    String? eventId,
    String? reportedBy,
    String? reportedByName,
    LatLng? location,
    String? type,
    String? description,
    String? severity,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? assignedTo,
    String? assignedToName,
    String? resolutionNotes,
    List<String>? imageUrls,
  }) {
    return Incident(
      id: id ?? this.id,
      eventId: eventId ?? this.eventId,
      reportedBy: reportedBy ?? this.reportedBy,
      reportedByName: reportedByName ?? this.reportedByName,
      location: location ?? this.location,
      type: type ?? this.type,
      description: description ?? this.description,
      severity: severity ?? this.severity,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      assignedTo: assignedTo ?? this.assignedTo,
      assignedToName: assignedToName ?? this.assignedToName,
      resolutionNotes: resolutionNotes ?? this.resolutionNotes,
      imageUrls: imageUrls ?? this.imageUrls,
    );
  }

  // Get type display name
  String get typeDisplayName {
    switch (type) {
      case 'medical':
        return 'Medical Emergency';
      case 'security':
        return 'Security Issue';
      case 'overcrowding':
        return 'Overcrowding';
      case 'other':
        return 'Other';
      default:
        return type;
    }
  }

  // Get status display name
  String get statusDisplayName {
    switch (status) {
      case 'reported':
        return 'Reported';
      case 'dispatched':
        return 'Dispatched';
      case 'on-site':
        return 'On Site';
      case 'resolved':
        return 'Resolved';
      default:
        return status;
    }
  }

  // Check if incident is active
  bool get isActive {
    return status != 'resolved';
  }

  // Get time since creation
  Duration get timeSinceCreation {
    return DateTime.now().difference(createdAt);
  }
}
