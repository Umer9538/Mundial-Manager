import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import '../models/crowd_dataset_record.dart';

/// Service that loads and analyzes the Hajj & Umrah crowd management dataset.
/// Provides realistic crowd patterns for simulation and threshold derivation.
class DatasetService {
  static DatasetService? _instance;
  static DatasetService get instance => _instance ??= DatasetService._();

  DatasetService._();

  List<CrowdDatasetRecord> _records = [];
  bool _isLoaded = false;
  final Random _random = Random();

  // Pre-computed groups by density level
  List<CrowdDatasetRecord> _lowDensityRecords = [];
  List<CrowdDatasetRecord> _mediumDensityRecords = [];
  List<CrowdDatasetRecord> _highDensityRecords = [];

  // Pre-computed statistics
  Map<String, dynamic> _statistics = {};

  bool get isLoaded => _isLoaded;
  List<CrowdDatasetRecord> get allRecords => _records;
  Map<String, dynamic> get statistics => _statistics;

  /// Load and parse the CSV dataset from bundled assets.
  Future<void> initialize() async {
    if (_isLoaded) return;

    try {
      final csvString = await rootBundle.loadString(
        'assets/data/hajj_umrah_crowd_management_dataset.csv',
      );

      final lines = csvString.split('\n');
      if (lines.length < 2) return;

      // Skip header line
      _records = [];
      for (int i = 1; i < lines.length; i++) {
        final line = lines[i].trim();
        if (line.isEmpty) continue;

        final fields = line.split(',');
        if (fields.length >= 30) {
          try {
            _records.add(CrowdDatasetRecord.fromCsvRow(fields));
          } catch (e) {
            // Skip malformed rows
          }
        }
      }

      // Group by density level
      _lowDensityRecords = _records.where((r) => r.crowdDensity == 'Low').toList();
      _mediumDensityRecords = _records.where((r) => r.crowdDensity == 'Medium').toList();
      _highDensityRecords = _records.where((r) => r.crowdDensity == 'High').toList();

      // Compute statistics
      _computeStatistics();

      _isLoaded = true;
      debugPrint('Dataset loaded: ${_records.length} records');
      debugPrint('  Low: ${_lowDensityRecords.length}, Medium: ${_mediumDensityRecords.length}, High: ${_highDensityRecords.length}');
    } catch (e) {
      debugPrint('Error loading dataset: $e');
    }
  }

  void _computeStatistics() {
    if (_records.isEmpty) return;

    // --- Crowd Density distribution (Column 3) ---
    final lowEmergencyRate = _avgWhere(_lowDensityRecords, (r) => r.emergencyEvent ? 1.0 : 0.0);
    final medEmergencyRate = _avgWhere(_mediumDensityRecords, (r) => r.emergencyEvent ? 1.0 : 0.0);
    final highEmergencyRate = _avgWhere(_highDensityRecords, (r) => r.emergencyEvent ? 1.0 : 0.0);

    // --- Health Condition analysis (Column 13) ---
    final healthIssueTypes = ['Heatstroke', 'Fainting', 'Injured', 'Dehydration'];
    final highHealthRate = _highDensityRecords.isEmpty ? 0.0
        : _highDensityRecords.where((r) => healthIssueTypes.contains(r.healthCondition)).length /
            _highDensityRecords.length;

    // --- Distance Between People (Column 24) ---
    final lowAvgDistance = _avgWhere(_lowDensityRecords, (r) => r.distanceBetweenPeopleM);
    final medAvgDistance = _avgWhere(_mediumDensityRecords, (r) => r.distanceBetweenPeopleM);
    final highAvgDistance = _avgWhere(_highDensityRecords, (r) => r.distanceBetweenPeopleM);

    // --- Movement Speed (Column 4) ---
    final lowAvgSpeed = _avgWhere(_lowDensityRecords, (r) => r.movementSpeed);
    final highAvgSpeed = _avgWhere(_highDensityRecords, (r) => r.movementSpeed);

    // --- Crowd Morale (Column 21) ---
    final highNegativeMorale = _highDensityRecords.isEmpty ? 0.0
        : _highDensityRecords.where((r) => r.crowdMorale == 'Negative').length /
            _highDensityRecords.length;

    // --- Temperature (Column 7) ---
    final avgTemperature = _avgWhere(_records, (r) => r.temperature);
    final maxTemperature = _records.fold<double>(0, (m, r) => r.temperature > m ? r.temperature : m);

    // --- Sound Level dB (Column 8) ---
    final avgSoundLevel = _avgWhere(_records, (r) => r.soundLevelDb);

    // --- Location_Lat / Location_Long (Columns 1-2) ---
    final avgLat = _avgWhere(_records, (r) => r.locationLat);
    final avgLong = _avgWhere(_records, (r) => r.locationLong);
    final minLat = _records.fold<double>(90, (m, r) => r.locationLat < m ? r.locationLat : m);
    final maxLat = _records.fold<double>(-90, (m, r) => r.locationLat > m ? r.locationLat : m);
    final minLong = _records.fold<double>(180, (m, r) => r.locationLong < m ? r.locationLong : m);
    final maxLong = _records.fold<double>(-180, (m, r) => r.locationLong > m ? r.locationLong : m);

    // --- Queue Time (Column 12) ---
    final avgQueueTime = _avgWhere(_records, (r) => r.queueTimeMinutes);

    // --- Security Checkpoint Wait (Column 18) ---
    final avgSecurityWait = _avgWhere(_records, (r) => r.securityCheckpointWaitTime);

    // --- Waiting Time for Transport (Column 17) ---
    final avgTransportWait = _avgWhere(_records, (r) => r.waitingTimeForTransport);

    // --- Time Spent at Location (Column 26) ---
    final avgTimeSpent = _avgWhere(_records, (r) => r.timeSpentAtLocationMinutes);

    // --- Satisfaction Rating (Column 28) ---
    final avgSatisfaction = _avgWhere(_records, (r) => r.satisfactionRating.toDouble());

    // --- Perceived Safety Rating (Column 29) ---
    final avgSafety = _avgWhere(_records, (r) => r.perceivedSafetyRating.toDouble());

    // --- Fatigue Level (Column 10) by density ---
    final highFatigueRate = _highDensityRecords.isEmpty ? 0.0
        : _highDensityRecords.where((r) => r.fatigueLevel == 'High').length /
            _highDensityRecords.length;

    // --- Stress Level (Column 11) by density ---
    final highStressRate = _highDensityRecords.isEmpty ? 0.0
        : _highDensityRecords.where((r) => r.stressLevel == 'High').length /
            _highDensityRecords.length;

    // --- AR System Interaction (Column 9) ---
    final arCompletedRate = _records.isEmpty ? 0.0
        : _records.where((r) => r.arSystemInteraction == 'Completed').length / _records.length;

    // --- AR Navigation Success (Column 27) ---
    final arNavSuccessRate = _records.isEmpty ? 0.0
        : _records.where((r) => r.arNavigationSuccess).length / _records.length;

    // --- Interaction Frequency (Column 23) ---
    final avgInteractionFreq = _avgWhere(_records, (r) => r.interactionFrequency.toDouble());

    // --- Risk Score (composite from multiple columns) ---
    final avgRiskScore = _avgWhere(_records, (r) => r.riskScore);
    final highDensityAvgRisk = _avgWhere(_highDensityRecords, (r) => r.riskScore);

    _statistics = {
      // Record counts
      'totalRecords': _records.length,
      'lowCount': _lowDensityRecords.length,
      'mediumCount': _mediumDensityRecords.length,
      'highCount': _highDensityRecords.length,
      // Emergency (Col 19) rates per density level (Col 3)
      'lowEmergencyRate': lowEmergencyRate,
      'mediumEmergencyRate': medEmergencyRate,
      'highEmergencyRate': highEmergencyRate,
      // Health (Col 13)
      'highHealthIssueRate': highHealthRate,
      // Distance (Col 24)
      'lowAvgDistance': lowAvgDistance,
      'mediumAvgDistance': medAvgDistance,
      'highAvgDistance': highAvgDistance,
      // Movement Speed (Col 4)
      'lowAvgSpeed': lowAvgSpeed,
      'highAvgSpeed': highAvgSpeed,
      // Morale (Col 21)
      'highNegativeMoraleRate': highNegativeMorale,
      // Temperature (Col 7)
      'avgTemperature': avgTemperature,
      'maxTemperature': maxTemperature,
      // Sound (Col 8)
      'avgSoundLevel': avgSoundLevel,
      // Location (Cols 1-2)
      'avgLat': avgLat,
      'avgLong': avgLong,
      'latRange': '${minLat.toStringAsFixed(4)} - ${maxLat.toStringAsFixed(4)}',
      'longRange': '${minLong.toStringAsFixed(4)} - ${maxLong.toStringAsFixed(4)}',
      // Queue & Wait times (Cols 12, 17, 18)
      'avgQueueTime': avgQueueTime,
      'avgSecurityWait': avgSecurityWait,
      'avgTransportWait': avgTransportWait,
      // Time at location (Col 26)
      'avgTimeSpent': avgTimeSpent,
      // Ratings (Cols 28, 29)
      'avgSatisfaction': avgSatisfaction,
      'avgSafetyRating': avgSafety,
      // Fatigue & Stress (Cols 10, 11) at high density
      'highFatigueRate': highFatigueRate,
      'highStressRate': highStressRate,
      // AR system (Cols 9, 27)
      'arCompletedRate': arCompletedRate,
      'arNavSuccessRate': arNavSuccessRate,
      // Interaction (Col 23)
      'avgInteractionFrequency': avgInteractionFreq,
      // Composite risk score (uses Cols 3,7,10,11,13,19,24)
      'avgRiskScore': avgRiskScore,
      'highDensityAvgRisk': highDensityAvgRisk,
    };
  }

  /// Helper: compute average of a double-valued function over a list.
  double _avgWhere(List<CrowdDatasetRecord> list, double Function(CrowdDatasetRecord) fn) {
    if (list.isEmpty) return 0.0;
    return list.fold<double>(0, (s, r) => s + fn(r)) / list.length;
  }

  /// Get a random record matching the given density level.
  CrowdDatasetRecord? sampleRecord(String densityLevel) {
    final list = _getRecordsForLevel(densityLevel);
    if (list.isEmpty) return null;
    return list[_random.nextInt(list.length)];
  }

  /// Get records for a density level.
  List<CrowdDatasetRecord> getRecordsByDensity(String level) {
    return _getRecordsForLevel(level);
  }

  /// Get records that had emergency events.
  List<CrowdDatasetRecord> getEmergencyRecords() {
    return _records.where((r) => r.emergencyEvent).toList();
  }

  /// Get records by health condition.
  List<CrowdDatasetRecord> getRecordsByHealthCondition(String condition) {
    return _records.where((r) => r.healthCondition == condition).toList();
  }

  /// Get the emergency probability for a given density level.
  double getEmergencyProbability(String densityLevel) {
    final list = _getRecordsForLevel(densityLevel);
    if (list.isEmpty) return 0;
    return list.where((r) => r.emergencyEvent).length / list.length;
  }

  /// Map the dataset's density level to our app's 4-tier status.
  /// Uses the record's distance between people for finer granularity.
  static String mapToAppStatus(CrowdDatasetRecord record) {
    if (record.crowdDensity == 'High' && record.distanceBetweenPeopleM < 0.7) {
      return 'critical';
    } else if (record.crowdDensity == 'High') {
      return 'high';
    } else if (record.crowdDensity == 'Medium') {
      return 'moderate';
    } else {
      return 'safe';
    }
  }

  /// Simulate a density transition based on dataset patterns.
  /// Given a current occupancy %, returns a new occupancy % with realistic fluctuation.
  double simulateOccupancyChange(double currentOccupancy) {
    // Determine current density level from occupancy
    String level;
    if (currentOccupancy >= 75) {
      level = 'High';
    } else if (currentOccupancy >= 50) {
      level = 'Medium';
    } else {
      level = 'Low';
    }

    // Sample a record from that level
    final record = sampleRecord(level);
    if (record == null) return currentOccupancy;

    // Use dataset movement speed to determine fluctuation magnitude
    // Higher speed = more change (people moving in/out)
    final speedFactor = record.movementSpeed / 1.5; // Normalize to 0-1
    final maxChange = 5.0 * speedFactor; // Up to 5% change

    // Direction influenced by crowd morale and stress
    double directionBias = 0;
    if (record.crowdMorale == 'Negative' || record.stressLevel == 'High') {
      directionBias = -0.3; // Slight tendency to decrease (people leaving)
    } else if (record.crowdMorale == 'Positive') {
      directionBias = 0.2; // Slight tendency to increase
    }

    final change = (_random.nextDouble() * 2 - 1 + directionBias) * maxChange;
    return (currentOccupancy + change).clamp(5.0, 100.0);
  }

  /// Get a weather condition and temperature from dataset matching current density.
  Map<String, dynamic> getEnvironmentData(String densityLevel) {
    final record = sampleRecord(densityLevel);
    if (record == null) {
      return {'weather': 'Clear', 'temperature': 37.0};
    }
    return {
      'weather': record.weatherConditions,
      'temperature': record.temperature,
    };
  }

  /// Check if an emergency should trigger based on dataset probabilities.
  /// Returns the incident type if triggered, null otherwise.
  String? shouldTriggerEmergency(String densityLevel) {
    final record = sampleRecord(densityLevel);
    if (record == null) return null;

    // Use dataset's actual emergency rate
    if (record.emergencyEvent && _random.nextDouble() < 0.02) {
      // 2% chance per check when conditions match an emergency record
      return record.incidentType;
    }
    return null;
  }

  List<CrowdDatasetRecord> _getRecordsForLevel(String level) {
    switch (level) {
      case 'Low':
        return _lowDensityRecords;
      case 'Medium':
        return _mediumDensityRecords;
      case 'High':
        return _highDensityRecords;
      default:
        return _records;
    }
  }
}
