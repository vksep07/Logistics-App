// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:logistics_demo/features/shipment/model/shipment_tracking.dart';
import 'package:logistics_demo/theme/palette.dart';
import 'package:logistics_demo/util/responsive.dart';
import 'package:logistics_demo/features/shipment/screens/shipment_details_screen.dart';
import 'package:logistics_demo/util/string_utils.dart';

class ShipmentTrackingItem extends StatelessWidget {
  final ShipmentTracking shipment;
  final Function(ShipmentTracking)? onDelete;
  final Function(ShipmentTracking)? onUpdate;
  final Function(ShipmentTracking)? onViewDetails;
  final cardBackgroundColor = Palette.cardBackgroundColor;

  const ShipmentTrackingItem({
    super.key,
    required this.shipment,
    this.onDelete,
    this.onUpdate,
    this.onViewDetails,
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
    // Format: "15 July 25, 04:30 PM"
    return DateFormat('dd MMMM yy, hh:mm a').format(timestamp);
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = Responsive.isDesktop(context);
    final isMobile = Responsive.isMobile(context);

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ShipmentDetailsScreen(shipment: shipment),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: EdgeInsets.symmetric(
          vertical: isMobile ? 12 : 16,
          horizontal: isMobile ? 12 : 16,
        ),
        decoration: BoxDecoration(
          color: cardBackgroundColor.withOpacity(0.3),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.withOpacity(0.2), width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Tracking #${shipment.trackingNumber}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: isMobile ? 14 : 16,
                          color: Palette.whiteColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _formatTimestamp(shipment.shipmentDate),
                        style: TextStyle(
                          fontSize: isMobile ? 12 : 13,
                          color: Colors.grey[400],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusColor(shipment.status).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _getStatusText(shipment.status),
                    style: TextStyle(
                      color: _getStatusColor(shipment.status),
                      fontWeight: FontWeight.w600,
                      fontSize: isMobile ? 12 : 13,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Customer: ${shipment.customerName}',
              style: TextStyle(
                fontSize: isMobile ? 13 : 14,
                color: Colors.grey[400],
              ),
            ),
            const SizedBox(height: 12),
            if (isDesktop)
              Row(
                children: [
                  Expanded(flex: 2, child: _buildLocationInfo()),
                  const Expanded(flex: 3, child: SizedBox()),
                ],
              )
            else
              _buildLocationInfo(),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationInfo() {
    return Row(
      children: [
        Expanded(
          child: Column(
            children: [
              _LocationMarker(
                color: Palette.gradient1,
                label: 'Source',
                location: shipment.source,
              ),
              const SizedBox(height: 0),
              const _DottedLine(),
              const SizedBox(height: 0),
              _LocationMarker(
                color: Palette.gradient2,
                label: 'Destination',
                location: shipment.destination,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _LocationMarker extends StatelessWidget {
  final Color color;
  final String label;
  final String location;

  const _LocationMarker({
    required this.color,
    required this.label,
    required this.location,
  });

  IconData _getIcon() {
    return label.toLowerCase() == 'source'
        ? Icons.circle_outlined
        : Icons.location_on_outlined;
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = Responsive.isMobile(context);

    return Row(
      children: [
        SizedBox(
          width: 24,
          child: Icon(_getIcon(), color: color, size: isMobile ? 16 : 18),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w600,
                  fontSize: isMobile ? 11 : 12,
                ),
              ),
              Text(
                location,
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: isMobile ? 12 : 14,
                  color: Palette.whiteColor,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _DottedLine extends StatelessWidget {
  const _DottedLine();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 24,
          height: 30,
          child: Center(
            child: CustomPaint(
              painter: _DottedLinePainter(),
              size: const Size(2, 30),
            ),
          ),
        ),
        const Expanded(child: SizedBox()),
      ],
    );
  }
}

class _DottedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = Colors.grey[600]!
          ..strokeWidth = 1
          ..strokeCap = StrokeCap.round;

    const dashWidth = 3;
    const dashSpace = 3;
    double startY = 0;
    final endY = size.height;

    while (startY < endY) {
      canvas.drawLine(
        Offset(size.width / 2, startY),
        Offset(size.width / 2, startY + dashWidth),
        paint,
      );
      startY += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(_DottedLinePainter oldDelegate) => false;
}
