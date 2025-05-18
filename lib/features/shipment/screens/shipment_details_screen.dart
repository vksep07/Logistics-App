// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:logistics_demo/features/shipment/model/shipment_tracking.dart';
import 'package:logistics_demo/theme/palette.dart';
import 'package:logistics_demo/features/shipment/screens/edit_shipment_screen.dart';
import 'package:logistics_demo/services/shipment_service.dart';
import 'package:logistics_demo/services/refresh_service.dart';
import 'package:logistics_demo/util/responsive.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:logistics_demo/widgets/custom_text.dart';

class ShipmentDetailsScreen extends StatefulWidget {
  final ShipmentTracking shipment;
  final VoidCallback? onShipmentUpdated;

  const ShipmentDetailsScreen({
    super.key,
    required this.shipment,
    this.onShipmentUpdated,
  });

  @override
  State<ShipmentDetailsScreen> createState() => _ShipmentDetailsScreenState();
}

class _ShipmentDetailsScreenState extends State<ShipmentDetailsScreen> {
  final _shipmentService = ShipmentService();
  final _refreshService = RefreshService();
  final cardBackgroundColor = Palette.cardBackgroundColor;
  bool _isLoading = false;

  String _formatDateTime(DateTime dateTime) {
    return DateFormat('dd MMMM yyyy, hh:mm a').format(dateTime);
  }

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
    final l10n = AppLocalizations.of(context)!;
    switch (status) {
      case ShipmentStatus.pending:
        return l10n.statusPending;
      case ShipmentStatus.inTransit:
        return l10n.statusInTransit;
      case ShipmentStatus.delivered:
        return l10n.statusDelivered;
      case ShipmentStatus.cancelled:
        return l10n.statusCancelled;
    }
  }

  Future<void> _handleEdit() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditShipmentScreen(shipment: widget.shipment),
      ),
    );

    if (result == true && widget.onShipmentUpdated != null) {
      widget.onShipmentUpdated!();
    }
  }

  Future<void> _handleDelete() async {
    final l10n = AppLocalizations.of(context)!;

    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: Palette.cardBackgroundColor,
            title: CustomText(
              text: l10n.deleteShipment,
              style: CustomText.titleStyle,
            ),
            content: CustomText(
              text: l10n.confirmDelete,
              style: CustomText.bodyStyle,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: CustomText(
                  text: l10n.cancel,
                  style: CustomText.bodyStyle,
                ),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: CustomText(
                  text: l10n.confirm,
                  style: CustomText.bodyStyle.copyWith(color: Colors.red),
                ),
              ),
            ],
          ),
    );

    if (confirmed != true) return;

    setState(() => _isLoading = true);

    try {
      final success = await _shipmentService.deleteShipment(
        widget.shipment.shipmentId,
      );
      if (!mounted) return;

      if (success) {
        _refreshService.notifyRefresh();
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: CustomText(
              text: l10n.deleteSuccess,
              style: CustomText.bodyStyle,
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: CustomText(
              text: l10n.deleteError,
              style: CustomText.errorStyle,
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: CustomText(
            text: l10n.generalError,
            style: CustomText.errorStyle,
          ),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = Responsive.isDesktop(context);
    Responsive.isTablet(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final horizontalPadding = isDesktop ? screenWidth * 0.1 : 16.0;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Colors.black87,
      appBar: AppBar(
        backgroundColor: cardBackgroundColor,
        title: CustomText(
          text: l10n.shipmentDetailsTitle,
          style: CustomText.titleStyle,
          isDesktop: isDesktop,
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (widget.shipment.status == ShipmentStatus.pending)
            Container(
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: _isLoading ? null : _handleDelete,
                tooltip: 'Delete Shipment',
              ),
            ),
          Container(
            margin: EdgeInsets.only(right: isDesktop ? 32 : 16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Palette.gradient1,
                  Palette.gradient2,
                  Palette.gradient3,
                ],
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: IconButton(
              icon: const Icon(Icons.edit, color: Colors.white),
              onPressed: _handleEdit,
              tooltip: 'Edit Shipment',
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: horizontalPadding,
          vertical: 16,
        ),
        child:
            isDesktop
                ? Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 3,
                      child: Column(
                        children: [
                          _buildStatusCard(),
                          const SizedBox(height: 16),
                          _buildSection('Customer Information', [
                            _buildInfoRow('Name', widget.shipment.customerName),
                            _buildInfoRow(
                              'Address',
                              widget.shipment.customerAddress,
                            ),
                            _buildInfoRow(
                              'Mobile',
                              widget.shipment.customerMobile,
                            ),
                          ]),
                          const SizedBox(height: 16),
                          _buildSection('Driver Information', [
                            _buildInfoRow('Name', widget.shipment.driverName),
                            _buildInfoRow(
                              'Mobile',
                              widget.shipment.driverMobile,
                            ),
                          ]),
                        ],
                      ),
                    ),
                    const SizedBox(width: 32),
                    Expanded(
                      flex: 4,
                      child: Column(
                        children: [
                          _buildSection('Shipment Information', [
                            _buildLocationTimeline(),
                            const SizedBox(height: 16),
                            _buildInfoRow(
                              'Shipment Date',
                              _formatDateTime(widget.shipment.shipmentDate),
                            ),
                            if (widget.shipment.deliveryDate != null)
                              _buildInfoRow(
                                'Delivery Date',
                                _formatDateTime(widget.shipment.deliveryDate!),
                              ),
                          ]),
                          const SizedBox(height: 16),
                          _buildSection('Tracking History', [
                            _buildFullTimeline(),
                          ]),
                        ],
                      ),
                    ),
                  ],
                )
                : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildStatusCard(),
                    const SizedBox(height: 16),
                    _buildSection('Customer Information', [
                      _buildInfoRow('Name', widget.shipment.customerName),
                      _buildInfoRow('Address', widget.shipment.customerAddress),
                      _buildInfoRow('Mobile', widget.shipment.customerMobile),
                    ]),
                    const SizedBox(height: 16),
                    _buildSection('Shipment Information', [
                      _buildLocationTimeline(),
                      const SizedBox(height: 16),
                      _buildInfoRow(
                        'Shipment Date',
                        _formatDateTime(widget.shipment.shipmentDate),
                      ),
                      if (widget.shipment.deliveryDate != null)
                        _buildInfoRow(
                          'Delivery Date',
                          _formatDateTime(widget.shipment.deliveryDate!),
                        ),
                    ]),
                    const SizedBox(height: 16),
                    _buildSection('Driver Information', [
                      _buildInfoRow('Name', widget.shipment.driverName),
                      _buildInfoRow('Mobile', widget.shipment.driverMobile),
                    ]),
                    const SizedBox(height: 16),
                    _buildSection('Tracking History', [_buildFullTimeline()]),
                  ],
                ),
      ),
    );
  }

  Widget _buildStatusCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardBackgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Tracking Number',
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.shipment.shipmentId,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: _getStatusColor(
                    widget.shipment.status,
                  ).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _getStatusText(widget.shipment.status),
                  style: TextStyle(
                    color: _getStatusColor(widget.shipment.status),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    final isDesktop = Responsive.isDesktop(context);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isDesktop ? 24 : 20),
      decoration: BoxDecoration(
        color: cardBackgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomText(
            text: title,
            style: CustomText.subtitleStyle,
            isDesktop: isDesktop,
          ),
          SizedBox(height: isDesktop ? 24 : 20),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    final isDesktop = Responsive.isDesktop(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: isDesktop ? 150 : 100,
            child: CustomText(
              text: label,
              style: CustomText.bodyStyle.copyWith(color: Colors.grey),
              isDesktop: isDesktop,
            ),
          ),
          Expanded(
            child: CustomText(
              text: value,
              style: CustomText.bodyStyle,
              isDesktop: isDesktop,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFullTimeline() {
    // Define all possible statuses in order
    final allStatuses = [
      ShipmentStatus.pending,
      ShipmentStatus.inTransit,
      ShipmentStatus.delivered,
    ];

    // Get the current status index
    int currentStatusIndex = allStatuses.indexOf(widget.shipment.status);
    if (currentStatusIndex == -1) {
      currentStatusIndex = 0; // For cancelled status
    }

    // Create a map of completed steps
    Map<ShipmentStatus, TrackingStep?> statusSteps = {};
    for (var step in widget.shipment.trackingSteps) {
      ShipmentStatus? stepStatus;
      switch (step.status.toLowerCase()) {
        case 'pending':
          stepStatus = ShipmentStatus.pending;
          break;
        case 'in_transit':
        case 'intransit':
          stepStatus = ShipmentStatus.inTransit;
          break;
        case 'delivered':
          stepStatus = ShipmentStatus.delivered;
          break;
      }
      if (stepStatus != null) {
        statusSteps[stepStatus] = step;
      }
    }

    // Build timeline items
    return Column(
      children:
          allStatuses.asMap().entries.map((entry) {
            final index = entry.key;
            final status = entry.value;
            final isCompleted =
                index <= currentStatusIndex &&
                widget.shipment.status != ShipmentStatus.cancelled;
            final step = statusSteps[status];

            final showWhiteLine = isCompleted && (index < currentStatusIndex);

            return _buildTimelineItem(
              step ??
                  TrackingStep(
                    status: status.toString().split('.').last,
                    timestamp: DateTime.now(),
                    location: '',
                    description: _getDefaultDescription(status),
                  ),
              index < allStatuses.length - 1,
              isActive: isCompleted,
              showWhiteLine: showWhiteLine,
            );
          }).toList(),
    );
  }

  String _getDefaultDescription(ShipmentStatus status) {
    switch (status) {
      case ShipmentStatus.pending:
        return 'Shipment registered';
      case ShipmentStatus.inTransit:
        return 'In transit to destination';
      case ShipmentStatus.delivered:
        return 'Delivered to recipient';
      case ShipmentStatus.cancelled:
        return 'Shipment cancelled';
    }
  }

  Widget _buildTimelineItem(
    TrackingStep step,
    bool showConnector, {
    bool isActive = true,
    bool showWhiteLine = false,
  }) {
    Color getStepStatusColor(String status, bool isActive) {
      if (!isActive) return Colors.grey.withOpacity(0.3);

      switch (status.toLowerCase()) {
        case 'pending':
          return Palette.gradient2;
        case 'intransit':
        case 'in_transit':
          return Palette.gradient1;
        case 'delivered':
          return Colors.green;
        case 'cancelled':
          return Colors.red;
        default:
          return Colors.grey;
      }
    }

    final statusColor = getStepStatusColor(step.status, isActive);

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 20,
            child: Column(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: statusColor,
                    shape: BoxShape.circle,
                  ),
                ),
                if (showConnector)
                  Expanded(
                    child: Container(
                      width: 2,
                      color:
                          showWhiteLine
                              ? Colors.white.withOpacity(0.7)
                              : Colors.grey.withOpacity(0.1),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  step.status.toUpperCase(),
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  step.description,
                  style: TextStyle(
                    color: isActive ? Colors.white : Colors.grey,
                    fontSize: 14,
                  ),
                ),
                if (step.location.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    '${step.location} - ${_formatDateTime(step.timestamp)}',
                    style: TextStyle(
                      color:
                          isActive ? Colors.grey : Colors.grey.withOpacity(0.5),
                      fontSize: 12,
                    ),
                  ),
                ],
                const SizedBox(height: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationTimeline() {
    return Row(
      children: [
        Expanded(
          child: Column(
            children: [
              _LocationMarker(
                color: Palette.gradient1,
                label: 'Source',
                location: widget.shipment.source,
              ),
              const SizedBox(height: 4),
              const _DottedLine(),
              const SizedBox(height: 4),
              _LocationMarker(
                color: Palette.gradient2,
                label: 'Destination',
                location: widget.shipment.destination,
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
    return Row(
      children: [
        SizedBox(width: 24, child: Icon(_getIcon(), color: color, size: 18)),
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
                  fontSize: 12,
                ),
              ),
              Text(
                location,
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                  color: Colors.white,
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
