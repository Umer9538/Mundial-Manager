class CrowdDensity {
  final String zoneId;
  final String zoneName;
  final int currentPopulation;
  final int capacity;
  final double densityPerSqMeter; // people per m²
  final String status; // safe, moderate, high, critical
  final DateTime lastUpdated;
  final double? temperature; // from dataset
  final String? weatherCondition; // from dataset
  final String? healthRisk; // dominant health risk from dataset

  CrowdDensity({
    required this.zoneId,
    required this.zoneName,
    required this.currentPopulation,
    required this.capacity,
    required this.densityPerSqMeter,
    required this.status,
    required this.lastUpdated,
    this.temperature,
    this.weatherCondition,
    this.healthRisk,
  });

  factory CrowdDensity.fromJson(Map<String, dynamic> json) {
    return CrowdDensity(
      zoneId: json['zoneId'] as String,
      zoneName: json['zoneName'] as String,
      currentPopulation: (json['currentPopulation'] ?? json['currentCount'] ?? 0) as int,
      capacity: json['capacity'] as int,
      densityPerSqMeter: (json['densityPerSqMeter'] as num).toDouble(),
      status: json['status'] as String,
      lastUpdated: json['lastUpdated'] != null
          ? DateTime.parse(json['lastUpdated'] as String)
          : DateTime.now(),
      temperature: json['temperature'] != null ? (json['temperature'] as num).toDouble() : null,
      weatherCondition: json['weatherCondition'] as String?,
      healthRisk: json['healthRisk'] as String?,
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
      if (temperature != null) 'temperature': temperature,
      if (weatherCondition != null) 'weatherCondition': weatherCondition,
      if (healthRisk != null) 'healthRisk': healthRisk,
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
    double? temperature,
    String? weatherCondition,
    String? healthRisk,
  }) {
    return CrowdDensity(
      zoneId: zoneId ?? this.zoneId,
      zoneName: zoneName ?? this.zoneName,
      currentPopulation: currentPopulation ?? this.currentPopulation,
      capacity: capacity ?? this.capacity,
      densityPerSqMeter: densityPerSqMeter ?? this.densityPerSqMeter,
      status: status ?? this.status,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      temperature: temperature ?? this.temperature,
      weatherCondition: weatherCondition ?? this.weatherCondition,
      healthRisk: healthRisk ?? this.healthRisk,
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

  // Get status from occupancy percentage (dataset-derived thresholds).
  // 50% -> moderate, 70% -> high, 85% -> critical, 95% -> emergency
  static String getStatusFromOccupancy(double occupancyPercent) {
    if (occupancyPercent >= 85) {
      return 'critical';
    } else if (occupancyPercent >= 70) {
      return 'high';
    } else if (occupancyPercent >= 50) {
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
    double? temperature,
    String? weatherCondition,
  }) {
    final densityPerSqMeter = currentPopulation / areaInSqMeters;
    final occupancy = capacity > 0 ? (currentPopulation / capacity * 100) : 0.0;
    // Use occupancy-based status (dataset-derived thresholds)
    final status = getStatusFromOccupancy(occupancy);

    return CrowdDensity(
      zoneId: zoneId,
      zoneName: zoneName,
      currentPopulation: currentPopulation,
      capacity: capacity,
      densityPerSqMeter: densityPerSqMeter,
      status: status,
      lastUpdated: DateTime.now(),
      temperature: temperature,
      weatherCondition: weatherCondition,
    );
  }

  // Simulate density fluctuation using dataset-driven occupancy logic.
  // Called by CrowdProvider when DatasetService provides new occupancy values.
  CrowdDensity simulateFluctuation({double? newOccupancyPercent}) {
    double occupancy;
    if (newOccupancyPercent != null) {
      occupancy = newOccupancyPercent;
    } else {
      // Fallback: small random fluctuation
      final fluctuation = (0.9 + (0.2 * (DateTime.now().millisecond % 100) / 100));
      occupancy = (currentPopulation * fluctuation / capacity * 100).clamp(5.0, 100.0);
    }

    final newPopulation = (capacity * occupancy / 100).round().clamp(0, capacity);
    final newDensity = newPopulation / (capacity * 0.5); // 0.5 m² per capacity unit
    final newStatus = getStatusFromOccupancy(occupancy);

    return CrowdDensity(
      zoneId: zoneId,
      zoneName: zoneName,
      currentPopulation: newPopulation,
      capacity: capacity,
      densityPerSqMeter: newDensity,
      status: newStatus,
      lastUpdated: DateTime.now(),
      temperature: temperature,
      weatherCondition: weatherCondition,
      healthRisk: healthRisk,
    );
  }
}
