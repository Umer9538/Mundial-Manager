import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/crowd_density.dart';
import '../models/zone.dart';
import '../services/database_service.dart';
import '../core/config/environment.dart';
import '../core/utils/dummy_data.dart';

class CrowdProvider with ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<CrowdDensity> _crowdData = [];
  List<Zone> _zones = [];
  bool _isLoading = false;
  String? _errorMessage;
  DateTime? _lastUpdated;
  StreamSubscription<QuerySnapshot>? _crowdSubscription;
  StreamSubscription<QuerySnapshot>? _zonesSubscription;
  String? _currentEventId;

  List<CrowdDensity> get crowdData => _crowdData;
  List<Zone> get allZones => _zones;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
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
        'totalCapacity': 0,
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
      'occupancyPercentage': totalCapacity > 0
          ? (totalPopulation / totalCapacity * 100).round()
          : 0,
      'criticalZones': criticalZones.length,
      'highDensityZones': highDensityZones.length,
      'safeZones': safeZones.length,
      'averageDensity': averageDensity,
    };
  }

  // Initialize crowd data
  Future<void> initialize({String? eventId}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _currentEventId = eventId;

      // Try to load from Firestore first
      if (eventId != null) {
        await _loadZonesFromFirestore();
        await _loadCrowdDataFromFirestore(eventId);
      }

      // Fallback to dummy data only in development mode
      if (_crowdData.isEmpty && AppConfig.useDummyDataFallback) {
        _crowdData = DummyData.crowdDensityData;
        _zones = DummyData.zones;
      }

      _lastUpdated = DateTime.now();
    } catch (e) {
      _errorMessage = 'Failed to load crowd data';
      debugPrint('Error initializing crowd data: $e');
      if (AppConfig.useDummyDataFallback) {
        _crowdData = DummyData.crowdDensityData;
        _zones = DummyData.zones;
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load zones from Firestore
  Future<void> _loadZonesFromFirestore() async {
    try {
      final snapshot = await _firestore.collection('zones').get();
      if (snapshot.docs.isNotEmpty) {
        _zones = snapshot.docs.map((doc) {
          return Zone.fromJson({
            'id': doc.id,
            ...doc.data(),
          });
        }).toList();
      }
    } catch (e) {
      debugPrint('Error loading zones: $e');
    }
  }

  // Load crowd data from Firestore
  Future<void> _loadCrowdDataFromFirestore(String eventId) async {
    try {
      final densityMap = await _databaseService.getLatestCrowdDensityByZone(eventId);
      if (densityMap.isNotEmpty) {
        _crowdData = densityMap.values.toList();
      }
    } catch (e) {
      debugPrint('Error loading crowd data: $e');
    }
  }

  // Start real-time updates from Firestore
  void startRealTimeUpdates({String? eventId}) {
    _currentEventId = eventId ?? _currentEventId;

    if (_currentEventId != null) {
      // Listen to crowd density updates from Firestore
      _crowdSubscription?.cancel();
      _crowdSubscription = _firestore
          .collection('crowd_density')
          .where('eventId', isEqualTo: _currentEventId)
          .orderBy('timestamp', descending: true)
          .limit(50)
          .snapshots()
          .listen(
        (snapshot) => _processCrowdSnapshot(snapshot),
        onError: (e) {
          debugPrint('Crowd density stream error: $e');
          // Fall back to simulated updates if Firestore stream fails in dev
          if (AppConfig.enableSimulatedUpdates) {
            _startSimulatedUpdates();
          }
        },
      );

      // Listen to zone updates
      _zonesSubscription?.cancel();
      _zonesSubscription = _firestore
          .collection('zones')
          .snapshots()
          .listen(
        (snapshot) => _processZonesSnapshot(snapshot),
        onError: (e) => debugPrint('Zone stream error: $e'),
      );
    } else if (AppConfig.enableSimulatedUpdates) {
      // Use simulated updates only in development mode
      _startSimulatedUpdates();
    }
  }

  // Process crowd density snapshot
  void _processCrowdSnapshot(QuerySnapshot snapshot) {
    final Map<String, CrowdDensity> latestByZone = {};

    for (final doc in snapshot.docs) {
      final data = CrowdDensity.fromJson({
        'id': doc.id,
        ...doc.data() as Map<String, dynamic>,
      });
      if (!latestByZone.containsKey(data.zoneId)) {
        latestByZone[data.zoneId] = data;
      }
    }

    if (latestByZone.isNotEmpty) {
      _crowdData = latestByZone.values.toList();
      _lastUpdated = DateTime.now();
      _errorMessage = null;
      notifyListeners();
    }
  }

  // Process zones snapshot
  void _processZonesSnapshot(QuerySnapshot snapshot) {
    if (snapshot.docs.isNotEmpty) {
      _zones = snapshot.docs.map((doc) {
        return Zone.fromJson({
          'id': doc.id,
          ...doc.data() as Map<String, dynamic>,
        });
      }).toList();
      notifyListeners();
    }
  }

  // Start simulated updates (development mode only)
  Timer? _simulatedTimer;
  void _startSimulatedUpdates() {
    if (!AppConfig.enableSimulatedUpdates) return;
    _simulatedTimer?.cancel();
    _simulatedTimer = Timer.periodic(
      AppConfig.crowdUpdateInterval,
      (_) => _simulateUpdate(),
    );
  }

  // Simulate crowd density update
  void _simulateUpdate() {
    _crowdData = _crowdData.map((cd) => cd.simulateFluctuation()).toList();
    _lastUpdated = DateTime.now();
    notifyListeners();
  }

  // Stop real-time updates
  void stopRealTimeUpdates() {
    _crowdSubscription?.cancel();
    _crowdSubscription = null;
    _zonesSubscription?.cancel();
    _zonesSubscription = null;
    _simulatedTimer?.cancel();
    _simulatedTimer = null;
  }

  // Refresh crowd data
  Future<void> refresh() async {
    _isLoading = true;
    notifyListeners();

    try {
      if (_currentEventId != null) {
        await _loadCrowdDataFromFirestore(_currentEventId!);
      }

      if (_crowdData.isEmpty && AppConfig.useDummyDataFallback) {
        _crowdData = DummyData.crowdDensityData;
      }

      _lastUpdated = DateTime.now();
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Failed to refresh crowd data';
      debugPrint('Error refreshing crowd data: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Get zone by ID
  Zone? getZone(String zoneId) {
    try {
      return _zones.firstWhere((z) => z.id == zoneId);
    } catch (e) {
      if (AppConfig.useDummyDataFallback) {
        return DummyData.getZoneById(zoneId);
      }
      return null;
    }
  }

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
    stopRealTimeUpdates();
    super.dispose();
  }
}
