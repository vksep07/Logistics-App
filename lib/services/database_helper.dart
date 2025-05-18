import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:logistics_demo/features/shipment/model/shipment_tracking.dart';
import 'dart:convert';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'logistics.db');
    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  Future<void> _onCreate(Database db, int version) async {
    // Create shipments table
    await db.execute('''
      CREATE TABLE shipments(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        shipmentId TEXT UNIQUE,
        customerName TEXT,
        customerAddress TEXT,
        customerMobile TEXT,
        source TEXT,
        destination TEXT,
        driverName TEXT,
        driverMobile TEXT,
        status TEXT,
        shipmentDate TEXT,
        deliveryDate TEXT,
        trackingSteps TEXT
      )
    ''');

    // Create admin table
    await db.execute('''
      CREATE TABLE admin(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        email TEXT UNIQUE,
        password TEXT,
        name TEXT
      )
    ''');
  }

  // Admin Operations
  Future<bool> createAdmin(String email, String password, String name) async {
    try {
      final db = await database;
      await db.insert('admin', {
        'email': email,
        'password': password,
        'name': name,
      }, conflictAlgorithm: ConflictAlgorithm.replace);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> validateAdmin(String email, String password) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'admin',
      where: 'email = ? AND password = ?',
      whereArgs: [email, password],
    );
    return maps.isNotEmpty;
  }

  // Shipment Operations
  Future<int> insertShipment(ShipmentTracking shipment) async {
    final db = await database;
    return await db.insert('shipments', {
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
        shipment.trackingSteps.map((step) => step.toJson()).toList(),
      ),
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<ShipmentTracking>> getAllShipments() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'shipments',
      orderBy: 'shipmentDate DESC', // Sort by date, newest first
    );
    return List.generate(maps.length, (i) {
      // Parse tracking steps and normalize status
      final List<dynamic> trackingSteps = jsonDecode(maps[i]['trackingSteps']);
      final normalizedTrackingSteps =
          trackingSteps.map((step) {
            var stepMap = Map<String, dynamic>.from(step);
            // Normalize status string
            if (stepMap['status'].toString().toLowerCase() == 'in_transit') {
              stepMap['status'] = 'inTransit';
            }
            return stepMap;
          }).toList();

      return ShipmentTracking.fromJson({
        ...maps[i],
        'tracking_steps': normalizedTrackingSteps,
      });
    });
  }

  Future<ShipmentTracking?> getShipment(String shipmentId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'shipments',
      where: 'shipmentId = ?',
      whereArgs: [shipmentId],
    );

    if (maps.isEmpty) return null;

    // Parse tracking steps and normalize status
    final List<dynamic> trackingSteps = jsonDecode(maps.first['trackingSteps']);
    final normalizedTrackingSteps =
        trackingSteps.map((step) {
          var stepMap = Map<String, dynamic>.from(step);
          // Normalize status string
          if (stepMap['status'].toString().toLowerCase() == 'in_transit') {
            stepMap['status'] = 'inTransit';
          }
          return stepMap;
        }).toList();

    return ShipmentTracking.fromJson({
      ...maps.first,
      'tracking_steps': normalizedTrackingSteps,
    });
  }

  Future<int> updateShipment(ShipmentTracking shipment) async {
    final db = await database;
    return await db.update(
      'shipments',
      {
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
          shipment.trackingSteps.map((step) => step.toJson()).toList(),
        ),
      },
      where: 'shipmentId = ?',
      whereArgs: [shipment.shipmentId],
    );
  }

  Future<int> deleteShipment(String shipmentId) async {
    final db = await database;
    return await db.delete(
      'shipments',
      where: 'shipmentId = ?',
      whereArgs: [shipmentId],
    );
  }

  // Import JSON data into database
  Future<void> importShipmentsFromJson(List<ShipmentTracking> shipments) async {
    final db = await database;
    await db.transaction((txn) async {
      for (var shipment in shipments) {
        await txn.insert('shipments', {
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
            shipment.trackingSteps.map((step) => step.toJson()).toList(),
          ),
        }, conflictAlgorithm: ConflictAlgorithm.replace);
      }
    });
  }
}
