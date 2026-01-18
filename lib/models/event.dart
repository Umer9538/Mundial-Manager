class Event {
  final String id;
  final String name;
  final String venueId;
  final DateTime startDate;
  final DateTime endDate;
  final int capacity;
  final String status; // planned, active, completed
  final String? description;

  Event({
    required this.id,
    required this.name,
    required this.venueId,
    required this.startDate,
    required this.endDate,
    required this.capacity,
    required this.status,
    this.description,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id: json['id'] as String,
      name: json['name'] as String,
      venueId: json['venueId'] as String,
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
      capacity: json['capacity'] as int,
      status: json['status'] as String,
      description: json['description'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'venueId': venueId,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'capacity': capacity,
      'status': status,
      'description': description,
    };
  }

  // Check if event is currently active
  bool get isActive {
    final now = DateTime.now();
    return now.isAfter(startDate) && now.isBefore(endDate) && status == 'active';
  }

  // Check if event is upcoming
  bool get isUpcoming {
    return DateTime.now().isBefore(startDate) && status == 'planned';
  }

  // Check if event is completed
  bool get isCompleted {
    return DateTime.now().isAfter(endDate) || status == 'completed';
  }

  // Get duration in hours
  int get durationInHours {
    return endDate.difference(startDate).inHours;
  }
}
