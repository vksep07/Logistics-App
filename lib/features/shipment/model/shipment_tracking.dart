enum ShipmentStatus { pending, inTransit, delivered, cancelled }

class ShipmentTracking {
  final String shipmentId;
  final String customerName;
  final String customerAddress;
  final String customerMobile;
  final String source;
  final String destination;
  final String driverName;
  final String driverMobile;
  final ShipmentStatus status;
  final DateTime shipmentDate;
  final DateTime? deliveryDate;
  final List<TrackingStep> trackingSteps;

  // Add getter for backward compatibility
  String get trackingNumber => shipmentId;

  ShipmentTracking({
    required this.shipmentId,
    required this.customerName,
    required this.customerAddress,
    required this.customerMobile,
    required this.source,
    required this.destination,
    required this.driverName,
    required this.driverMobile,
    required this.status,
    required this.shipmentDate,
    this.deliveryDate,
    required this.trackingSteps,
  });

  Map<String, dynamic> toJson() {
    return {
      'shipmentId': shipmentId,
      'customerName': customerName,
      'customerAddress': customerAddress,
      'customerMobile': customerMobile,
      'source': source,
      'destination': destination,
      'driverName': driverName,
      'driverMobile': driverMobile,
      'status': status.toString().split('.').last,
      'shipmentDate': shipmentDate.toIso8601String(),
      'deliveryDate': deliveryDate?.toIso8601String(),
      'tracking_steps': trackingSteps.map((step) => step.toJson()).toList(),
    };
  }

  factory ShipmentTracking.fromJson(Map<String, dynamic> json) {
    String statusStr = json['status'].toString().toLowerCase();
    // Remove the enum prefix if present
    statusStr = statusStr.replaceAll('shipmentstatus.', '');
    // Convert in_transit to inTransit
    if (statusStr == 'in_transit') {
      statusStr = 'inTransit';
    }

    return ShipmentTracking(
      shipmentId: json['shipmentId'] ?? json['tracking_number'],
      customerName: json['customerName'],
      customerAddress: json['customerAddress'],
      customerMobile: json['customerMobile'],
      source: json['source'],
      destination: json['destination'],
      driverName: json['driverName'],
      driverMobile: json['driverMobile'],
      status: ShipmentStatus.values.firstWhere(
        (e) => e.toString().split('.').last.toLowerCase() == statusStr,
      ),
      shipmentDate: DateTime.parse(json['shipmentDate']),
      deliveryDate:
          json['deliveryDate'] != null
              ? DateTime.parse(json['deliveryDate'])
              : null,
      trackingSteps:
          (json['tracking_steps'] as List? ?? [])
              .map((step) => TrackingStep.fromJson(step))
              .toList(),
    );
  }
}

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
    return TrackingStep(
      status: json['status'],
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

// Dummy data
class ShipmentTrackingData {
  static List<ShipmentTracking> getDummyData() {
    return [
      ShipmentTracking(
        shipmentId: 'TRK123456789',
        customerName: 'John Smith',
        customerAddress: '123 Main St, New York, USA',
        customerMobile: '+1 (555) 123-4567',
        source: 'New York, USA',
        destination: 'London, UK',
        driverName: 'Michael Johnson',
        driverMobile: '+1 (555) 123-4567',
        status: ShipmentStatus.inTransit,
        shipmentDate: DateTime(2024, 3, 1, 9, 30),
        deliveryDate: null,
        trackingSteps: [
          TrackingStep(
            status: 'pending',
            timestamp: DateTime(2024, 3, 1, 9, 30),
            location: 'New York, USA',
            description: 'Shipment registered',
          ),
          TrackingStep(
            status: 'shipped',
            timestamp: DateTime(2024, 3, 1, 10, 30),
            location: 'New York, USA',
            description: 'Shipment picked up by driver',
          ),
          TrackingStep(
            status: 'inTransit',
            timestamp: DateTime(2024, 3, 1, 11, 45),
            location: 'JFK Airport',
            description: 'In transit to destination',
          ),
        ],
      ),
      ShipmentTracking(
        shipmentId: 'TRK987654321',
        customerName: 'Emma Johnson',
        customerAddress: '456 Elm St, Paris, France',
        customerMobile: '+1 (555) 234-5678',
        source: 'Paris, France',
        destination: 'Berlin, Germany',
        driverName: 'Robert Davis',
        driverMobile: '+1 (555) 234-5678',
        status: ShipmentStatus.pending,
        shipmentDate: DateTime(2024, 2, 28, 14, 15),
        deliveryDate: null,
        trackingSteps: [
          TrackingStep(
            status: 'pending',
            timestamp: DateTime(2024, 2, 28, 14, 15),
            location: 'Paris, France',
            description: 'Shipment registered',
          ),
        ],
      ),
      ShipmentTracking(
        shipmentId: 'TRK456789123',
        customerName: 'Michael Brown',
        customerAddress: '789 Oak St, Tokyo, Japan',
        customerMobile: '+1 (555) 345-6789',
        source: 'Tokyo, Japan',
        destination: 'Sydney, Australia',
        driverName: 'William Chen',
        driverMobile: '+1 (555) 345-6789',
        status: ShipmentStatus.delivered,
        shipmentDate: DateTime(2024, 2, 25, 9, 45),
        deliveryDate: DateTime(2024, 2, 25, 18, 30),
        trackingSteps: [
          TrackingStep(
            status: 'pending',
            timestamp: DateTime(2024, 2, 25, 9, 45),
            location: 'Tokyo, Japan',
            description: 'Shipment registered',
          ),
          TrackingStep(
            status: 'shipped',
            timestamp: DateTime(2024, 2, 25, 10, 45),
            location: 'Tokyo, Japan',
            description: 'Shipment picked up by driver',
          ),
          TrackingStep(
            status: 'inTransit',
            timestamp: DateTime(2024, 2, 25, 14, 30),
            location: 'Narita Airport',
            description: 'In transit to destination',
          ),
          TrackingStep(
            status: 'delivered',
            timestamp: DateTime(2024, 2, 25, 18, 30),
            location: 'Sydney, Australia',
            description: 'Delivered to recipient',
          ),
        ],
      ),
      ShipmentTracking(
        shipmentId: 'TRK789123456',
        customerName: 'Sarah Wilson',
        customerAddress: '101 Pine St, Toronto, Canada',
        customerMobile: '+1 (555) 456-7890',
        source: 'Toronto, Canada',
        destination: 'Mexico City, Mexico',
        driverName: 'James Wilson',
        driverMobile: '+1 (555) 456-7890',
        status: ShipmentStatus.inTransit,
        shipmentDate: DateTime(2024, 2, 20, 10, 20),
        deliveryDate: null,
        trackingSteps: [
          TrackingStep(
            status: 'pending',
            timestamp: DateTime(2024, 2, 20, 10, 20),
            location: 'Toronto, Canada',
            description: 'Shipment registered',
          ),
          TrackingStep(
            status: 'shipped',
            timestamp: DateTime(2024, 2, 20, 11, 20),
            location: 'Toronto, Canada',
            description: 'Shipment picked up by driver',
          ),
        ],
      ),
      ShipmentTracking(
        shipmentId: 'TRK321654987',
        customerName: 'David Lee',
        customerAddress: '555 Maple St, Singapore',
        customerMobile: '+1 (555) 567-8901',
        source: 'Singapore',
        destination: 'Hong Kong',
        driverName: 'Thomas Anderson',
        driverMobile: '+1 (555) 567-8901',
        status: ShipmentStatus.inTransit,
        shipmentDate: DateTime(2024, 2, 15, 8, 0),
        deliveryDate: null,
        trackingSteps: [
          TrackingStep(
            status: 'pending',
            timestamp: DateTime(2024, 2, 15, 8, 0),
            location: 'Singapore',
            description: 'Shipment registered',
          ),
          TrackingStep(
            status: 'shipped',
            timestamp: DateTime(2024, 2, 15, 9, 0),
            location: 'Singapore',
            description: 'Shipment picked up by driver',
          ),
          TrackingStep(
            status: 'inTransit',
            timestamp: DateTime(2024, 2, 15, 10, 30),
            location: 'Singapore Airport',
            description: 'In transit to destination',
          ),
        ],
      ),
    ];
  }
}
