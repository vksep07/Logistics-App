import 'package:flutter/foundation.dart';
import 'package:logistics_demo/features/shipment/model/shipment_tracking.dart';
import 'package:logistics_demo/services/app_database.dart';

class ShipmentService {
  final AppDatabase _appDatabase = AppDatabase();
  static final ShipmentService _instance = ShipmentService._internal();

  factory ShipmentService() => _instance;

  ShipmentService._internal();

  Future<void> initializeData() async {
    try {
      // Check if we already have data
      final existingShipments = await getAllShipments();
      if (existingShipments.isEmpty) {
        // Use dummy data for initialization
        final shipments = ShipmentTrackingData.getDummyData();
        // Import data into SQLite database
        await _appDatabase.importShipmentsFromJson(shipments);
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error initializing data: $e');
      }
      rethrow;
    }
  }

  Future<List<ShipmentTracking>> getAllShipments() async {
    try {
      final shipments = await _appDatabase.getAllShipments();
      // Double-check sorting in memory to ensure newest first
      shipments.sort((a, b) => b.shipmentDate.compareTo(a.shipmentDate));
      return shipments;
    } catch (e) {
      if (kDebugMode) {
        print('Error getting shipments: $e');
      }
      return [];
    }
  }

  Future<List<ShipmentTracking>> searchShipments(String query) async {
    try {
      final shipments = await getAllShipments();
      final lowercaseQuery = query.toLowerCase();
      return shipments
          .where(
            (shipment) =>
                shipment.shipmentId.toLowerCase().contains(lowercaseQuery) ||
                shipment.customerName.toLowerCase().contains(lowercaseQuery) ||
                shipment.trackingNumber.toLowerCase().contains(lowercaseQuery),
          )
          .toList();
    } catch (e) {
      if (kDebugMode) {
        print('Error searching shipments: $e');
      }
      return [];
    }
  }

  Future<ShipmentTracking?> getShipment(String shipmentId) async {
    return await _appDatabase.getShipment(shipmentId);
  }

  Future<bool> updateShipment(ShipmentTracking shipment) async {
    try {
      await _appDatabase.updateShipment(shipment);
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Error updating shipment: $e');
      }
      return false;
    }
  }

  Future<bool> deleteShipment(String shipmentId) async {
    try {
      await _appDatabase.deleteShipment(shipmentId);
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Error deleting shipment: $e');
      }
      return false;
    }
  }

  Future<bool> addShipment(ShipmentTracking shipment) async {
    try {
      await _appDatabase.insertShipment(shipment);
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Error adding shipment: $e');
      }
      return false;
    }
  }
}
