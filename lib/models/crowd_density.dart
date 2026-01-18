class CrowdDensity {
  final String zoneId;
  final String zoneName;
  final int currentPopulation;
  final int capacity;
  final double densityPerSqMeter; // people per m²
  final String status; // safe, moderate, high, critical
  final DateTime lastUpdated;

  CrowdDensity({
    required this.zoneId,
    required this.zoneName,
    required this.currentPopulation,
    required this.capacity,
    required this.densityPerSqMeter,
    required this.status,
    required this.lastUpdated,
  });

  factory CrowdDensity.fromJson(Map<String, dynamic> json) {
    return CrowdDensity(
      zoneId: json['zoneId'] as String,
      zoneName: json['zoneName'] as String,
      currentPopulation: json['currentPopulation'] as int,
      capacity: json['capacity'] as int,
      densityPerSqMeter: (json['densityPerSqMeter'] as num).toDouble(),
      status: json['status'] as String,
      lastUpdated: DateTime.parse(json['lastUpdated'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'zoneId': zoneId,
      'zoneName': zoneName,
      'currentPopulation': currentPopulation,
      'capacity': capacity,
      'densityPerSqMeter': densityPerSqMeter,
      'status': status,
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }

  // Copy with method
  CrowdDensity copyWith({
    String? zoneId,
    String? zoneName,
    int? currentPopulation,
    int? capacity,
    double? densityPerSqMeter,
    String? status,
    DateTime? lastUpdated,
  }) {
    return CrowdDensity(
      zoneId: zoneId ?? this.zoneId,
      zoneName: zoneName ?? this.zoneName,
      currentPopulation: currentPopulation ?? this.currentPopulation,
      capacity: capacity ?? this.capacity,
      densityPerSqMeter: densityPerSqMeter ?? this.densityPerSqMeter,
      status: status ?? this.status,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  // Get occupancy percentage
  double get occupancyPercentage {
    return (currentPopulation / capacity) * 100;
  }

  // Get rounded occupancy percentage
  int get occupancyPercentageRounded {
    return occupancyPercentage.round();
  }

  // Get status display name
  String get statusDisplayName {
    switch (status) {
      case 'safe':
        return 'Safe';
      case 'moderate':
        return 'Moderate';
      case 'high':
        return 'High Density';
      case 'critical':
        return 'Critical';
      default:
        return status;
    }
  }

  // Check if zone needs attention
  bool get needsAttention {
    return status == 'high' || status == 'critical';
  }

  // Check if zone is critical
  bool get isCritical {
    return status == 'critical';
  }

  // Get density status from people per m²
  static String getStatusFromDensity(double density) {
    if (density >= 4.6) {
      return 'critical';
    } else if (density >= 3.1) {
      return 'high';
    } else if (density >= 1.6) {
      return 'moderate';
    } else {
      return 'safe';
    }
  }

  // Create CrowdDensity from zone data
  factory CrowdDensity.fromZoneData({
    required String zoneId,
    required String zoneName,
    required int currentPopulation,
    required int capacity,
    required double areaInSqMeters,
  }) {
    final densityPerSqMeter = currentPopulation / areaInSqMeters;
    final status = getStatusFromDensity(densityPerSqMeter);

    return CrowdDensity(
      zoneId: zoneId,
      zoneName: zoneName,
      currentPopulation: currentPopulation,
      capacity: capacity,
      densityPerSqMeter: densityPerSqMeter,
      status: status,
      lastUpdated: DateTime.now(),
    );
  }

  // Simulate random density fluctuation (for demo)
  CrowdDensity simulateFluctuation() {
    // Random fluctuation between -5% and +5%
    final fluctuation = (0.9 + (0.2 * (DateTime.now().millisecond % 100) / 100));
    final newPopulation = (currentPopulation * fluctuation).round().clamp(0, capacity);
    final newDensity = newPopulation / (capacity * 0.5); // Assume 0.5 m² per capacity
    final newStatus = getStatusFromDensity(newDensity);

    return CrowdDensity(
      zoneId: zoneId,
      zoneName: zoneName,
      currentPopulation: newPopulation,
      capacity: capacity,
      densityPerSqMeter: newDensity,
      status: newStatus,
      lastUpdated: DateTime.now(),
    );
  }
}
