import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:logistics_demo/features/shipment/model/shipment_tracking.dart';
import 'package:logistics_demo/features/shipment/widgets/shipment_tracking_item.dart';
import 'package:logistics_demo/theme/palette.dart';
import 'package:logistics_demo/util/responsive.dart';
import 'package:logistics_demo/features/shipment/widgets/shipment_table_web.dart';
import 'package:logistics_demo/features/shipment/screens/shipment_list_screen.dart';
import 'package:logistics_demo/widgets/custom_text.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ShipmentTrackingList extends StatelessWidget {
  final List<ShipmentTracking> shipments;
  final Function(ShipmentTracking) onDelete;
  final Function(ShipmentTracking) onUpdate;
  final Function(ShipmentTracking) onViewDetails;
  final bool? isShowHeader;

  const ShipmentTrackingList({
    super.key,
    required this.shipments,
    required this.onDelete,
    required this.onUpdate,
    required this.onViewDetails,
    this.isShowHeader = true,
  });

  List<ShipmentTracking> get recentShipments {
    // Filter out delivered shipments and sort by date
    final nonDelivered =
        shipments.where((s) => s.status != ShipmentStatus.delivered).toList();

    // Sort by shipment date, most recent first
    nonDelivered.sort((a, b) => b.shipmentDate.compareTo(a.shipmentDate));

    // Return up to 5 most recent shipments
    return nonDelivered.take(5).toList();
  }

  void _navigateToAllShipments(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => ShipmentListScreen(
              title: localizations.allActiveShipments,
              showAllExceptDelivered: true,
            ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = Responsive.isDesktop(context);
    final localizations = AppLocalizations.of(context)!;

    if (isDesktop) {
      return ShipmentTableWeb(
        shipments: shipments,
        onDelete: onDelete,
        onUpdate: onUpdate,
        onViewDetails: onViewDetails,
      );
    }

    final recents = recentShipments;
    final cardBackgroundColor = Palette.cardBackgroundColor;
    final isShowHeader = this.isShowHeader ?? true;
    return Container(
      margin: const EdgeInsets.only(top: 24),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: cardBackgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isShowHeader)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CustomText(
                  text: localizations.recentShipments,
                  style: CustomText.titleStyle.copyWith(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () => _navigateToAllShipments(context),
                  child: CustomText(
                    text: localizations.viewAll,
                    style: CustomText.bodyStyle.copyWith(
                      color: Palette.gradient2,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          const SizedBox(height: 24),
          if (recents.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: CustomText(
                  text: localizations.noPendingShipments,
                  style: CustomText.bodyStyle.copyWith(
                    color: Colors.grey,
                    fontSize: 16,
                  ),
                ),
              ),
            )
          else
            ...recents.map(
              (shipment) => ShipmentTrackingItem(
                shipment: shipment,
                onDelete: onDelete,
                onUpdate: onUpdate,
                onViewDetails: onViewDetails,
              ),
            ),
        ],
      ),
    );
  }
}
