import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:logistics_demo/features/shipment/model/shipment_tracking.dart';
import 'package:logistics_demo/services/shipment_service.dart';
import 'package:logistics_demo/services/refresh_service.dart';
import 'package:logistics_demo/theme/palette.dart';
import 'package:logistics_demo/util/responsive.dart';
import 'package:logistics_demo/widgets/custom_card_widget.dart';
import 'package:logistics_demo/features/shipment/screens/shipment_list_screen.dart';

class ActivityDetailsCard extends StatefulWidget {
  const ActivityDetailsCard({super.key});

  @override
  State<ActivityDetailsCard> createState() => _ActivityDetailsCardState();
}

class _ActivityDetailsCardState extends State<ActivityDetailsCard> {
  final ShipmentService _shipmentService = ShipmentService();
  final RefreshService _refreshService = RefreshService();
  List<ShipmentTracking> _shipments = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadShipments();
    _refreshService.refreshStream.listen((_) {
      _loadShipments();
    });
  }

  Future<void> _loadShipments() async {
    setState(() => _isLoading = true);
    try {
      final shipments = await _shipmentService.getAllShipments();
      // Sort shipments by date, newest first
      shipments.sort((a, b) {
        // Convert dates to UTC for consistent comparison
        final aDate = a.shipmentDate.toUtc();
        final bDate = b.shipmentDate.toUtc();
        return bDate.compareTo(aDate); // Newest first
      });
      if (mounted) {
        setState(() {
          _shipments = shipments;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error loading shipments: $e');
      }
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _navigateToShipmentList(
    BuildContext context, {
    required String title,
    List<ShipmentStatus>? filterStatus,
    bool showAllExceptDelivered = false,
  }) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => ShipmentListScreen(
              title: title,
              filterStatus: filterStatus,
              showAllExceptDelivered: showAllExceptDelivered,
            ),
      ),
    );
  }

  ActivityData _getActivityData(int index) {
    switch (index) {
      case 0:
        return ActivityData(
          title: 'Total Shipments',
          value: _shipments.length.toString(),
          icon: Icons.local_shipping_outlined,
          color: Palette.gradient1,
          onTap:
              (context) =>
                  _navigateToShipmentList(context, title: 'All Shipments'),
        );
      case 1:
        return ActivityData(
          title: 'Delivered',
          value:
              _shipments
                  .where((s) => s.status == ShipmentStatus.delivered)
                  .length
                  .toString(),
          icon: Icons.check_circle_outline,
          color: Colors.green,
          onTap:
              (context) => _navigateToShipmentList(
                context,
                title: 'Delivered Shipments',
                filterStatus: [ShipmentStatus.delivered],
              ),
        );
      case 2:
        return ActivityData(
          title: 'Pending',
          value:
              _shipments
                  .where((s) => s.status == ShipmentStatus.pending)
                  .length
                  .toString(),
          icon: Icons.pending_outlined,
          color: Palette.gradient2,
          onTap:
              (context) => _navigateToShipmentList(
                context,
                title: 'Pending Shipments',
                filterStatus: [ShipmentStatus.pending],
              ),
        );
      case 3:
        return ActivityData(
          title: 'In Transit',
          value:
              _shipments
                  .where((s) => s.status == ShipmentStatus.inTransit)
                  .length
                  .toString(),
          icon: Icons.local_shipping_outlined,
          color: Palette.gradient3,
          onTap:
              (context) => _navigateToShipmentList(
                context,
                title: 'In Transit',
                filterStatus: [ShipmentStatus.inTransit],
              ),
        );
      default:
        throw Exception('Invalid index');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return GridView.builder(
      itemCount: 4,
      shrinkWrap: true,
      physics: const ScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: Responsive.isMobile(context) ? 2 : 4,
        crossAxisSpacing: Responsive.isMobile(context) ? 12 : 15,
        mainAxisSpacing: 12.0,
        childAspectRatio: Responsive.isMobile(context) ? 1.5 : 1,
      ),
      itemBuilder: (context, index) {
        final data = _getActivityData(index);
        return CustomCard(
          child: InkWell(
            onTap: () => data.onTap?.call(context),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(data.icon, color: data.color, size: 28),
                Padding(
                  padding: const EdgeInsets.only(top: 15, bottom: 4),
                  child: Text(
                    data.value,
                    style: TextStyle(
                      fontSize: 18,
                      color: data.color,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      data.title,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Palette.whiteColor,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Icon(
                      Icons.info_outline,
                      // ignore: deprecated_member_use
                      color: Palette.whiteColor.withOpacity(0.5),
                      size: 15,
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class ActivityData {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final Function(BuildContext)? onTap;

  ActivityData({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    this.onTap,
  });
}
