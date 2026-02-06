import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import '../core/theme/app_colors.dart';

class Facility {
  final String id;
  final String venueId;
  final String name;
  final String type; // restroom, food, first_aid, exit, info_desk, prayer_room
  final LatLng location;
  final String description;
  final bool isOpen;
  final int floor;

  Facility({
    required this.id,
    required this.venueId,
    required this.name,
    required this.type,
    required this.location,
    this.description = '',
    this.isOpen = true,
    this.floor = 0,
  });

  factory Facility.fromJson(Map<String, dynamic> json) {
    return Facility(
      id: json['id'] as String,
      venueId: json['venueId'] as String,
      name: json['name'] as String,
      type: json['type'] as String,
      location: LatLng(
        (json['latitude'] as num).toDouble(),
        (json['longitude'] as num).toDouble(),
      ),
      description: json['description'] as String? ?? '',
      isOpen: json['isOpen'] as bool? ?? true,
      floor: json['floor'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'venueId': venueId,
      'name': name,
      'type': type,
      'latitude': location.latitude,
      'longitude': location.longitude,
      'description': description,
      'isOpen': isOpen,
      'floor': floor,
    };
  }

  // Get type display name
  String get typeDisplayName {
    switch (type) {
      case 'restroom':
        return 'Restroom';
      case 'food':
        return 'Food & Beverage';
      case 'first_aid':
        return 'First Aid';
      case 'exit':
        return 'Exit';
      case 'info_desk':
        return 'Information Desk';
      case 'prayer_room':
        return 'Prayer Room';
      default:
        return type;
    }
  }

  /// Returns the appropriate icon for the given facility type.
  static IconData getIconForType(String type) {
    switch (type) {
      case 'restroom':
        return Icons.wc;
      case 'food':
        return Icons.restaurant;
      case 'first_aid':
        return Icons.local_hospital;
      case 'exit':
        return Icons.exit_to_app;
      case 'info_desk':
        return Icons.info_outline;
      case 'prayer_room':
        return Icons.mosque;
      default:
        return Icons.place;
    }
  }

  /// Returns the appropriate color for the given facility type.
  static Color getColorForType(String type) {
    switch (type) {
      case 'restroom':
        return AppColors.blue;
      case 'food':
        return AppColors.orange;
      case 'first_aid':
        return AppColors.red;
      case 'exit':
        return AppColors.green;
      case 'info_desk':
        return AppColors.softTealBlue;
      case 'prayer_room':
        return AppColors.coolSteelBlue;
      default:
        return AppColors.blueGrey;
    }
  }

  // Get icon for this facility's type
  IconData get icon => getIconForType(type);

  // Get color for this facility's type
  Color get color => getColorForType(type);
}
