import 'package:latlong2/latlong.dart';

class Zone {
  final String id;
  final String venueId;
  final String name;
  final List<LatLng> boundaries;
  final int capacity;
  final String type; // entrance, seating, concourse, exit, fan_zone
  final String? description;

  Zone({
    required this.id,
    required this.venueId,
    required this.name,
    required this.boundaries,
    required this.capacity,
    required this.type,
    this.description,
  });

  factory Zone.fromJson(Map<String, dynamic> json) {
    final boundariesJson = json['boundaries'] as List;
    final boundaries = boundariesJson.map((b) {
      return LatLng(b['lat'] as double, b['lng'] as double);
    }).toList();

    return Zone(
      id: json['id'] as String,
      venueId: json['venueId'] as String,
      name: json['name'] as String,
      boundaries: boundaries,
      capacity: json['capacity'] as int,
      type: json['type'] as String,
      description: json['description'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'venueId': venueId,
      'name': name,
      'boundaries': boundaries.map((b) => {'lat': b.latitude, 'lng': b.longitude}).toList(),
      'capacity': capacity,
      'type': type,
      'description': description,
    };
  }

  // Get zone center point
  LatLng get center {
    if (boundaries.isEmpty) {
      return LatLng(0, 0);
    }

    double sumLat = 0;
    double sumLng = 0;

    for (var point in boundaries) {
      sumLat += point.latitude;
      sumLng += point.longitude;
    }

    return LatLng(
      sumLat / boundaries.length,
      sumLng / boundaries.length,
    );
  }

  // Get zone area (approximate, in square meters)
  double get approximateArea {
    // Simplified calculation for demo purposes
    return capacity.toDouble() * 0.5; // Assume 0.5 m² per person capacity
  }
}
