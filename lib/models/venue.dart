import 'package:latlong2/latlong.dart';

class Venue {
  final String id;
  final String name;
  final String address;
  final LatLng coordinates;
  final int capacity;
  final String? description;

  Venue({
    required this.id,
    required this.name,
    required this.address,
    required this.coordinates,
    required this.capacity,
    this.description,
  });

  factory Venue.fromJson(Map<String, dynamic> json) {
    return Venue(
      id: json['id'] as String,
      name: json['name'] as String,
      address: json['address'] as String,
      coordinates: LatLng(
        json['latitude'] as double,
        json['longitude'] as double,
      ),
      capacity: json['capacity'] as int,
      description: json['description'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'latitude': coordinates.latitude,
      'longitude': coordinates.longitude,
      'capacity': capacity,
      'description': description,
    };
  }
}
