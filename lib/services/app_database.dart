import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:logistics_demo/features/shipment/model/shipment_tracking.dart';

class AppDatabase {
  static final AppDatabase _instance = AppDatabase._internal();
  factory AppDatabase() => _instance;
  AppDatabase._internal();

  static const String _shipmentBoxName = 'shipmentsBox';
  static const String _adminBoxName = 'adminBox';

  Future<void> init() async {
    await Hive.initFlutter();
    await Hive.openBox<Map>(_shipmentBoxName);
    await Hive.openBox<Map>(_adminBoxName);
  }

  Box<Map> get _shipmentBox => Hive.box<Map>(_shipmentBoxName);
  Box<Map> get _adminBox => Hive.box<Map>(_adminBoxName);

  // Admin Operations
  Future<bool> createAdmin(String email, String password, String name) async {
    try {
      await _adminBox.put(email, {
        'email': email,
        'password': password,
        'name': name,
      });
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> validateAdmin(String email, String password) async {
    final admin = _adminBox.get(email);
    return admin != null && admin['password'] == password;
  }

  // Shipment Operations
  Future<void> insertShipment(ShipmentTracking shipment) async {
    await _shipmentBox.put(shipment.shipmentId, {
      'shipmentId': shipment.shipmentId,
      'customerName': shipment.customerName,
      'customerAddress': shipment.customerAddress,
      'customerMobile': shipment.customerMobile,
      'source': shipment.source,
      'destination': shipment.destination,
      'driverName': shipment.driverName,
      'driverMobile': shipment.driverMobile,
      'status': shipment.status.toString(),
      'shipmentDate': shipment.shipmentDate.toIso8601String(),
      'deliveryDate': shipment.deliveryDate?.toIso8601String(),
      'trackingSteps': jsonEncode(
        shipment.trackingSteps.map((e) => e.toJson()).toList(),
      ),
    });
  }

  Future<List<ShipmentTracking>> getAllShipments() async {
    return _shipmentBox.values.map((map) {
      final List<dynamic> trackingSteps = jsonDecode(map['trackingSteps']);
      final normalizedSteps =
          trackingSteps.map((step) {
            var stepMap = Map<String, dynamic>.from(step);
            if (stepMap['status'].toString().toLowerCase() == 'in_transit') {
              stepMap['status'] = 'inTransit';
            }
            return stepMap;
          }).toList();

      return ShipmentTracking.fromJson({
        ...map,
        'tracking_steps': normalizedSteps,
      });
    }).toList();
  }

  Future<ShipmentTracking?> getShipment(String shipmentId) async {
    final map = _shipmentBox.get(shipmentId);
    if (map == null) return null;

    final List<dynamic> trackingSteps = jsonDecode(map['trackingSteps']);
    final normalizedSteps =
        trackingSteps.map((step) {
          var stepMap = Map<String, dynamic>.from(step);
          if (stepMap['status'].toString().toLowerCase() == 'in_transit') {
            stepMap['status'] = 'inTransit';
          }
          return stepMap;
        }).toList();

    return ShipmentTracking.fromJson({
      ...map,
      'tracking_steps': normalizedSteps,
    });
  }

  Future<void> updateShipment(ShipmentTracking shipment) async {
    await insertShipment(shipment);
  }

  Future<void> deleteShipment(String shipmentId) async {
    await _shipmentBox.delete(shipmentId);
  }

  Future<void> importShipmentsFromJson(List<ShipmentTracking> shipments) async {
    for (var shipment in shipments) {
      await insertShipment(shipment);
    }
  }
}
