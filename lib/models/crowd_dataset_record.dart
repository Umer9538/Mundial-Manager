/// A single record from the Hajj & Umrah Crowd Management Dataset (30 columns).
/// All 30 CSV columns are parsed and stored. Used to drive realistic crowd
/// density simulation, threshold analysis, and environment enrichment.
///
/// CSV Columns (index → field):
///   0: Timestamp, 1: Location_Lat, 2: Location_Long, 3: Crowd_Density,
///   4: Movement_Speed, 5: Activity_Type, 6: Weather_Conditions, 7: Temperature,
///   8: Sound_Level_dB, 9: AR_System_Interaction, 10: Fatigue_Level,
///   11: Stress_Level, 12: Queue_Time_minutes, 13: Health_Condition,
///   14: Age_Group, 15: Nationality, 16: Transport_Mode,
///   17: Waiting_Time_for_Transport, 18: Security_Checkpoint_Wait_Time,
///   19: Emergency_Event, 20: Incident_Type, 21: Crowd_Morale,
///   22: Pilgrim_Experience, 23: Interaction_Frequency,
///   24: Distance_Between_People_m, 25: Event_Type,
///   26: Time_Spent_at_Location_minutes, 27: AR_Navigation_Success,
///   28: Satisfaction_Rating, 29: Perceived_Safety_Rating
class CrowdDatasetRecord {
  // Column 0: Timestamp of the record
  final DateTime timestamp;

  // Columns 1-2: GPS coordinates (Mecca region: ~21.2-21.4°N, ~39.8-40.0°E)
  final double locationLat;
  final double locationLong;

  // Column 3: Crowd density classification (Low / Medium / High)
  final String crowdDensity;

  // Column 4: Pilgrim movement speed in meters/second (0.2-1.5)
  final double movementSpeed;

  // Column 5: Current activity (Tawaf / Prayer / Resting / Walking / Sa'i)
  final String activityType;

  // Column 6: Weather at the time (Clear / Cloudy / Rainy)
  final String weatherConditions;

  // Column 7: Ambient temperature in Celsius (30-45)
  final double temperature;

  // Column 8: Ambient sound level in decibels (60-89)
  final double soundLevelDb;

  // Column 9: AR system interaction status (Started / In Progress / Completed)
  final String arSystemInteraction;

  // Column 10: Fatigue level (Low / Medium / High)
  final String fatigueLevel;

  // Column 11: Stress level (Low / Medium / High)
  final String stressLevel;

  // Column 12: Queue/waiting time in minutes (0-60)
  final double queueTimeMinutes;

  // Column 13: Health condition (Normal / Heatstroke / Fainting / Injured / Dehydration)
  final String healthCondition;

  // Column 14: Age group (18-30 / 31-50 / 51-70 / 70+)
  final String ageGroup;

  // Column 15: Nationality (Saudi / Indian / Indonesian / Pakistani / Egyptian / Other)
  final String nationality;

  // Column 16: Transport mode (Bus / Walking / Car / Train)
  final String transportMode;

  // Column 17: Waiting time for transport in minutes
  final double waitingTimeForTransport;

  // Column 18: Security checkpoint wait time in minutes
  final double securityCheckpointWaitTime;

  // Column 19: Whether an emergency event occurred (Yes / No)
  final bool emergencyEvent;

  // Column 20: Type of incident (Lost Item / Theft / Unruly Behavior / Security Breach / Medical Emergency)
  final String incidentType;

  // Column 21: Overall crowd morale (Positive / Neutral / Negative)
  final String crowdMorale;

  // Column 22: Pilgrim experience level (First-Time / Experienced)
  final String pilgrimExperience;

  // Column 23: Interaction frequency (stops, rest periods) within a timeframe (0-10)
  final int interactionFrequency;

  // Column 24: Average distance between people in meters (0.5-2.5)
  final double distanceBetweenPeopleM;

  // Column 25: Event type at location (Religious Activity / Medical Emergency / Crowd Congestion / Transport Delay)
  final String eventType;

  // Column 26: Time spent at current location in minutes
  final double timeSpentAtLocationMinutes;

  // Column 27: Whether AR-guided navigation was successful (Yes / No)
  final bool arNavigationSuccess;

  // Column 28: Pilgrim satisfaction rating (1-5)
  final int satisfactionRating;

  // Column 29: Perceived safety rating (1-5)
  final int perceivedSafetyRating;

  CrowdDatasetRecord({
    required this.timestamp,
    required this.locationLat,
    required this.locationLong,
    required this.crowdDensity,
    required this.movementSpeed,
    required this.activityType,
    required this.weatherConditions,
    required this.temperature,
    required this.soundLevelDb,
    required this.arSystemInteraction,
    required this.fatigueLevel,
    required this.stressLevel,
    required this.queueTimeMinutes,
    required this.healthCondition,
    required this.ageGroup,
    required this.nationality,
    required this.transportMode,
    required this.waitingTimeForTransport,
    required this.securityCheckpointWaitTime,
    required this.emergencyEvent,
    required this.incidentType,
    required this.crowdMorale,
    required this.pilgrimExperience,
    required this.interactionFrequency,
    required this.distanceBetweenPeopleM,
    required this.eventType,
    required this.timeSpentAtLocationMinutes,
    required this.arNavigationSuccess,
    required this.satisfactionRating,
    required this.perceivedSafetyRating,
  });

  /// Parse a single CSV row (split by comma) into a record.
  /// All 30 columns (fields[0] through fields[29]) are mapped.
  factory CrowdDatasetRecord.fromCsvRow(List<String> fields) {
    return CrowdDatasetRecord(
      timestamp: DateTime.tryParse(fields[0]) ?? DateTime.now(),       // Col 0
      locationLat: double.tryParse(fields[1]) ?? 0,                    // Col 1
      locationLong: double.tryParse(fields[2]) ?? 0,                   // Col 2
      crowdDensity: fields[3],                                         // Col 3
      movementSpeed: double.tryParse(fields[4]) ?? 0,                  // Col 4
      activityType: fields[5],                                         // Col 5
      weatherConditions: fields[6],                                    // Col 6
      temperature: double.tryParse(fields[7]) ?? 0,                    // Col 7
      soundLevelDb: double.tryParse(fields[8]) ?? 0,                   // Col 8
      arSystemInteraction: fields[9],                                  // Col 9
      fatigueLevel: fields[10],                                        // Col 10
      stressLevel: fields[11],                                         // Col 11
      queueTimeMinutes: double.tryParse(fields[12]) ?? 0,             // Col 12
      healthCondition: fields[13],                                     // Col 13
      ageGroup: fields[14],                                            // Col 14
      nationality: fields[15],                                         // Col 15
      transportMode: fields[16],                                       // Col 16
      waitingTimeForTransport: double.tryParse(fields[17]) ?? 0,      // Col 17
      securityCheckpointWaitTime: double.tryParse(fields[18]) ?? 0,   // Col 18
      emergencyEvent: fields[19].trim().toLowerCase() == 'yes',       // Col 19
      incidentType: fields[20],                                        // Col 20
      crowdMorale: fields[21],                                         // Col 21
      pilgrimExperience: fields[22],                                   // Col 22
      interactionFrequency: int.tryParse(fields[23]) ?? 0,            // Col 23
      distanceBetweenPeopleM: double.tryParse(fields[24]) ?? 0,       // Col 24
      eventType: fields[25],                                           // Col 25
      timeSpentAtLocationMinutes: double.tryParse(fields[26]) ?? 0,   // Col 26
      arNavigationSuccess: fields[27].trim().toLowerCase() == 'yes',  // Col 27
      satisfactionRating: int.tryParse(fields[28]) ?? 3,              // Col 28
      perceivedSafetyRating: int.tryParse(fields[29]) ?? 3,           // Col 29
    );
  }

  /// Convert dataset density level to people/m² estimate.
  /// Based on distanceBetweenPeopleM: density ~ 1 / (distance^2).
  double get estimatedDensityPerSqMeter {
    if (distanceBetweenPeopleM <= 0) return 0;
    return 1.0 / (distanceBetweenPeopleM * distanceBetweenPeopleM);
  }

  /// Map dataset Crowd_Density to app occupancy percentage range.
  /// Low -> 0-49%, Medium -> 50-74%, High -> 75-100%
  double get estimatedOccupancyPercent {
    switch (crowdDensity) {
      case 'Low':
        return 20 + (2.5 - distanceBetweenPeopleM.clamp(1.5, 2.5)) * 29;
      case 'Medium':
        return 50 + (1.5 - distanceBetweenPeopleM.clamp(0.8, 1.5)) * 34.3;
      case 'High':
        return 75 + (0.8 - distanceBetweenPeopleM.clamp(0.5, 0.8)) * 83.3;
      default:
        return 50;
    }
  }

  /// Whether this record represents a high-risk situation.
  /// Combines multiple dataset signals: high density + health issues + high stress.
  bool get isHighRisk {
    return crowdDensity == 'High' &&
        healthCondition != 'Normal' &&
        stressLevel == 'High';
  }

  /// Compute a composite risk score (0.0 - 1.0) from multiple dataset fields.
  /// Used by DatasetService statistics to evaluate zone danger levels.
  double get riskScore {
    double score = 0;

    // Density contribution (0-0.3)
    if (crowdDensity == 'High') {
      score += 0.3;
    } else if (crowdDensity == 'Medium') {
      score += 0.15;
    }

    // Distance between people contribution (0-0.2)
    // Closer distance = higher risk
    score += (2.5 - distanceBetweenPeopleM.clamp(0.5, 2.5)) / 2.0 * 0.2;

    // Health condition contribution (0-0.15)
    if (healthCondition == 'Heatstroke' || healthCondition == 'Fainting') {
      score += 0.15;
    } else if (healthCondition == 'Dehydration' || healthCondition == 'Injured') {
      score += 0.10;
    }

    // Stress & fatigue contribution (0-0.15)
    if (stressLevel == 'High') score += 0.075;
    if (fatigueLevel == 'High') score += 0.075;

    // Temperature contribution (0-0.1)
    // Higher temp = higher risk
    score += ((temperature - 30).clamp(0, 15) / 15.0) * 0.1;

    // Emergency event contribution (0-0.1)
    if (emergencyEvent) score += 0.1;

    return score.clamp(0.0, 1.0);
  }
}
