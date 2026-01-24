import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:latlong2/latlong.dart';

class LocationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  StreamSubscription<Position>? _positionSubscription;
  String? _currentUserId;
  bool _isSharing = false;

  bool get isSharing => _isSharing;

  /// Check if location services are enabled and permissions granted
  Future<bool> checkPermissions() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return false;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return false;
    }

    return true;
  }

  /// Request location permissions
  Future<LocationPermission> requestPermission() async {
    return await Geolocator.requestPermission();
  }

  /// Get current position
  Future<Position?> getCurrentPosition() async {
    try {
      final hasPermission = await checkPermissions();
      if (!hasPermission) return null;

      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
    } catch (e) {
      debugPrint('Error getting current position: $e');
      return null;
    }
  }

  /// Get current position as LatLng
  Future<LatLng?> getCurrentLatLng() async {
    final position = await getCurrentPosition();
    if (position == null) return null;
    return LatLng(position.latitude, position.longitude);
  }

  /// Start sharing location (updates Firestore every 30 seconds)
  Future<bool> startSharing(String userId) async {
    final hasPermission = await checkPermissions();
    if (!hasPermission) return false;

    _currentUserId = userId;
    _isSharing = true;

    // Get initial position and save
    final position = await getCurrentPosition();
    if (position != null) {
      await _updateLocationInFirestore(position);
    }

    // Start listening for location updates
    _positionSubscription = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10, // Update every 10 meters
      ),
    ).listen(
      (Position position) {
        _updateLocationInFirestore(position);
      },
      onError: (error) {
        debugPrint('Location stream error: $error');
      },
    );

    return true;
  }

  /// Stop sharing location
  Future<void> stopSharing() async {
    _positionSubscription?.cancel();
    _positionSubscription = null;
    _isSharing = false;

    // Clear location from Firestore
    if (_currentUserId != null) {
      await _firestore.collection('users').doc(_currentUserId).update({
        'currentLocation': FieldValue.delete(),
        'locationUpdatedAt': FieldValue.delete(),
        'isSharingLocation': false,
      });
    }
  }

  /// Update location in Firestore
  Future<void> _updateLocationInFirestore(Position position) async {
    if (_currentUserId == null) return;

    try {
      await _firestore.collection('users').doc(_currentUserId).update({
        'currentLocation': GeoPoint(position.latitude, position.longitude),
        'locationUpdatedAt': FieldValue.serverTimestamp(),
        'isSharingLocation': true,
      });

      // Also add to location_history collection for crowd analysis
      await _firestore.collection('location_history').add({
        'userId': _currentUserId,
        'location': GeoPoint(position.latitude, position.longitude),
        'accuracy': position.accuracy,
        'speed': position.speed,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('Error updating location in Firestore: $e');
    }
  }

  /// Get distance between two points in meters
  double getDistance(LatLng from, LatLng to) {
    return Geolocator.distanceBetween(
      from.latitude,
      from.longitude,
      to.latitude,
      to.longitude,
    );
  }

  /// Dispose resources
  void dispose() {
    _positionSubscription?.cancel();
    _positionSubscription = null;
  }
}
