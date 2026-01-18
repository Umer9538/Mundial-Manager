import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/crowd_density.dart';
import '../models/zone.dart';
import '../core/utils/dummy_data.dart';
import '../core/constants/constants.dart';

class CrowdProvider with ChangeNotifier {
  List<CrowdDensity> _crowdData = [];
  bool _isLoading = false;
  Timer? _updateTimer;
  DateTime? _lastUpdated;

  List<CrowdDensity> get crowdData => _crowdData;
  bool get isLoading => _isLoading;
  DateTime? get lastUpdated => _lastUpdated;

  // Get crowd data for specific zone
  CrowdDensity? getZoneDensity(String zoneId) {
    try {
      return _crowdData.firstWhere((cd) => cd.zoneId == zoneId);
    } catch (e) {
      return null;
    }
  }

  // Get all critical zones
  List<CrowdDensity> get criticalZones {
    return _crowdData.where((cd) => cd.isCritical).toList();
  }

  // Get all high density zones
  List<CrowdDensity> get highDensityZones {
    return _crowdData.where((cd) => cd.needsAttention).toList();
  }

  // Get safe zones
  List<CrowdDensity> get safeZones {
    return _crowdData.where((cd) => cd.status == 'safe').toList();
  }

  // Get overall venue statistics
  Map<String, dynamic> get venueStats {
    if (_crowdData.isEmpty) {
      return {
        'totalPopulation': 0,
        'totalCapacity': DummyData.venue.capacity,
        'occupancyPercentage': 0,
        'criticalZones': 0,
        'highDensityZones': 0,
        'safeZones': 0,
        'averageDensity': 0.0,
      };
    }

    final totalPopulation = _crowdData.fold<int>(
      0,
      (sum, cd) => sum + cd.currentPopulation,
    );

    final totalCapacity = _crowdData.fold<int>(
      0,
      (sum, cd) => sum + cd.capacity,
    );

    final averageDensity = _crowdData.fold<double>(
      0.0,
      (sum, cd) => sum + cd.densityPerSqMeter,
    ) / _crowdData.length;

    return {
      'totalPopulation': totalPopulation,
      'totalCapacity': totalCapacity,
      'occupancyPercentage': (totalPopulation / totalCapacity * 100).round(),
      'criticalZones': criticalZones.length,
      'highDensityZones': highDensityZones.length,
      'safeZones': safeZones.length,
      'averageDensity': averageDensity,
    };
  }

  // Initialize crowd data
  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    try {
      await Future.delayed(const Duration(milliseconds: 500));
      _crowdData = DummyData.crowdDensityData;
      _lastUpdated = DateTime.now();
    } catch (e) {
      debugPrint('Error initializing crowd data: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Start real-time updates (simulated)
  void startRealTimeUpdates() {
    _updateTimer?.cancel();
    _updateTimer = Timer.periodic(
      AppConstants.crowdUpdateInterval,
      (_) => _simulateUpdate(),
    );
  }

  // Stop real-time updates
  void stopRealTimeUpdates() {
    _updateTimer?.cancel();
    _updateTimer = null;
  }

  // Simulate crowd density update
  void _simulateUpdate() {
    _crowdData = _crowdData.map((cd) => cd.simulateFluctuation()).toList();
    _lastUpdated = DateTime.now();
    notifyListeners();
  }

  // Refresh crowd data
  Future<void> refresh() async {
    _isLoading = true;
    notifyListeners();

    try {
      await Future.delayed(const Duration(milliseconds: 500));
      _crowdData = DummyData.crowdDensityData;
      _lastUpdated = DateTime.now();
    } catch (e) {
      debugPrint('Error refreshing crowd data: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Get zone by ID
  Zone? getZone(String zoneId) {
    return DummyData.getZoneById(zoneId);
  }

  // Get all zones
  List<Zone> get allZones => DummyData.zones;

  // Check if any zone needs immediate attention
  bool get hasUrgentZones {
    return criticalZones.isNotEmpty || highDensityZones.length >= 3;
  }

  // Get zones sorted by density (highest first)
  List<CrowdDensity> get zonesByDensity {
    final sorted = List<CrowdDensity>.from(_crowdData);
    sorted.sort((a, b) => b.densityPerSqMeter.compareTo(a.densityPerSqMeter));
    return sorted;
  }

  // Get zones sorted by occupancy (highest first)
  List<CrowdDensity> get zonesByOccupancy {
    final sorted = List<CrowdDensity>.from(_crowdData);
    sorted.sort((a, b) => b.occupancyPercentage.compareTo(a.occupancyPercentage));
    return sorted;
  }

  @override
  void dispose() {
    _updateTimer?.cancel();
    super.dispose();
  }
}
