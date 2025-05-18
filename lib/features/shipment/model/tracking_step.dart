class TrackingStep {
  final String status;
  final DateTime timestamp;
  final String location;
  final String description;

  TrackingStep({
    required this.status,
    required this.timestamp,
    required this.location,
    required this.description,
  });

  factory TrackingStep.fromJson(Map<String, dynamic> json) {
    String normalizeStatus(String status) {
      // Convert in_transit to inTransit for consistency
      if (status.toLowerCase() == 'in_transit') {
        return 'inTransit';
      }
      return status;
    }

    return TrackingStep(
      status: normalizeStatus(json['status']),
      timestamp: DateTime.parse(json['timestamp']),
      location: json['location'],
      description: json['description'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'timestamp': timestamp.toIso8601String(),
      'location': location,
      'description': description,
    };
  }
}
