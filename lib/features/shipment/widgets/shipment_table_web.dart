// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:logistics_demo/features/shipment/model/shipment_tracking.dart';
import 'package:logistics_demo/theme/palette.dart';
import 'package:logistics_demo/features/shipment/screens/shipment_details_screen.dart';
import 'package:logistics_demo/features/shipment/screens/edit_shipment_screen.dart';
import 'package:logistics_demo/util/string_utils.dart';

class ShipmentTableWeb extends StatelessWidget {
  final List<ShipmentTracking> shipments;
  final Function(ShipmentTracking) onDelete;
  final Function(ShipmentTracking) onUpdate;
  final Function(ShipmentTracking) onViewDetails;
  final cardBackgroundColor = Palette.cardBackgroundColor;

  const ShipmentTableWeb({
    super.key,
    required this.shipments,
    required this.onDelete,
    required this.onUpdate,
    required this.onViewDetails,
  });

  Color _getStatusColor(ShipmentStatus status) {
    switch (status) {
      case ShipmentStatus.pending:
        return Palette.gradient2;
      case ShipmentStatus.inTransit:
        return Palette.gradient1;
      case ShipmentStatus.delivered:
        return Colors.green;
      case ShipmentStatus.cancelled:
        return Colors.red;
    }
  }

  String _getStatusText(ShipmentStatus status) {
    return formatStatus(status.toString());
  }

  String _formatTimestamp(DateTime timestamp) {
    return DateFormat('dd MMMM yy, hh:mm a').format(timestamp);
  }

  @override
  Widget build(BuildContext context) {
    // Sort shipments by date, newest first
    final sortedShipments = List<ShipmentTracking>.from(shipments)
      ..sort((a, b) {
        // Convert dates to UTC for consistent comparison
        final aDate = a.shipmentDate.toUtc();
        final bDate = b.shipmentDate.toUtc();
        return bDate.compareTo(aDate); // Newest first
      });

    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 300),
      decoration: BoxDecoration(
        color: cardBackgroundColor.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Container(
            color: Colors.grey.withOpacity(0.1),
            child: Row(
              children: [
                _buildHeaderCell('Track#', 'Tracking Number', flex: 2),
                _buildHeaderCell('Name', 'Customer Name', flex: 3),
                _buildHeaderCell('From', 'Source Location', flex: 2),
                _buildHeaderCell('To', 'Destination Location', flex: 2),
                _buildHeaderCell('Status', 'Shipment Status', flex: 2),
                _buildHeaderCell('Date', 'Last Updated', flex: 3),
                _buildHeaderCell('', 'Actions', flex: 1, isAction: true),
              ],
            ),
          ),
          Expanded(
            child: Scrollbar(
              child: ListView.builder(
                itemCount: sortedShipments.length,
                itemBuilder: (context, index) {
                  final shipment = sortedShipments[index];
                  return _buildDataRow(context, shipment);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderCell(
    String label,
    String tooltip, {
    required int flex,
    bool isAction = false,
  }) {
    return Expanded(
      flex: flex,
      child: Tooltip(
        message: tooltip,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
          child:
              isAction
                  ? const Icon(
                    Icons.more_horiz,
                    color: Palette.whiteColor,
                    size: 18,
                  )
                  : Text(
                    label,
                    style: const TextStyle(
                      color: Palette.whiteColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
        ),
      ),
    );
  }

  Widget _buildDataRow(BuildContext context, ShipmentTracking shipment) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey.withOpacity(0.1), width: 1),
        ),
      ),
      child: Row(
        children: [
          _buildDataCell(shipment.trackingNumber, flex: 2),
          _buildDataCell(shipment.customerName, flex: 3),
          _buildDataCell(shipment.source, flex: 2),
          _buildDataCell(shipment.destination, flex: 2),
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                decoration: BoxDecoration(
                  color: _getStatusColor(shipment.status).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  _getStatusText(shipment.status),
                  style: TextStyle(
                    color: _getStatusColor(shipment.status),
                    fontWeight: FontWeight.w600,
                    fontSize: 11,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
          _buildDataCell(_formatTimestamp(shipment.shipmentDate), flex: 3),
          Expanded(
            flex: 1,
            child: PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, color: Colors.grey, size: 18),
              itemBuilder:
                  (context) => [
                    const PopupMenuItem(
                      value: 'details',
                      child: Text('View Details'),
                    ),
                    const PopupMenuItem(value: 'edit', child: Text('Edit')),
                    const PopupMenuItem(value: 'delete', child: Text('Delete')),
                  ],
              onSelected: (String value) {
                switch (value) {
                  case 'details':
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => ShipmentDetailsScreen(
                              shipment: shipment,
                              onShipmentUpdated: () => onUpdate(shipment),
                            ),
                      ),
                    );
                    break;
                  case 'edit':
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => EditShipmentScreen(shipment: shipment),
                      ),
                    ).then((result) {
                      if (result == true) {
                        onUpdate(shipment);
                      }
                    });
                    break;
                  case 'delete':
                    onDelete(shipment);
                    break;
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDataCell(String text, {required int flex}) {
    return Expanded(
      flex: flex,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        child: Text(
          text,
          style: const TextStyle(color: Palette.whiteColor, fontSize: 11),
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}
