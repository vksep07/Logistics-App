import 'package:flutter/material.dart';
import 'package:logistics_demo/features/shipment/model/shipment_tracking.dart';
import 'package:logistics_demo/theme/palette.dart';
import 'package:logistics_demo/services/shipment_service.dart';
import 'package:logistics_demo/features/shipment/widgets/shipment_tracking_item.dart';
import 'package:logistics_demo/util/responsive.dart';
import 'package:logistics_demo/features/shipment/widgets/shipment_table_web.dart';
import 'package:logistics_demo/widgets/custom_text.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ShipmentListScreen extends StatefulWidget {
  final String title;
  final List<ShipmentStatus>? filterStatus;
  final bool showAllExceptDelivered;

  const ShipmentListScreen({
    super.key,
    required this.title,
    this.filterStatus,
    this.showAllExceptDelivered = false,
  });

  @override
  State<ShipmentListScreen> createState() => _ShipmentListScreenState();
}

class _ShipmentListScreenState extends State<ShipmentListScreen> {
  final _shipmentService = ShipmentService();
  List<ShipmentTracking> _shipments = [];
  bool _isLoading = true;
  final cardBackgroundColor = Palette.cardBackgroundColor;

  @override
  void initState() {
    super.initState();
    _loadShipments();
  }

  Future<void> _loadShipments() async {
    try {
      final allShipments = await _shipmentService.getAllShipments();
      setState(() {
        if (widget.showAllExceptDelivered) {
          _shipments =
              allShipments
                  .where((s) => s.status != ShipmentStatus.delivered)
                  .toList();
        } else if (widget.filterStatus != null) {
          _shipments =
              allShipments
                  .where((s) => widget.filterStatus!.contains(s.status))
                  .toList();
        } else {
          _shipments = allShipments;
        }
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: CustomText(
            text: AppLocalizations.of(context)!.failedToLoadShipments,
            style: CustomText.errorStyle,
          ),
          backgroundColor: Colors.red,
        ),
      );
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _handleDelete(ShipmentTracking shipment) async {
    try {
      final success = await _shipmentService.deleteShipment(
        shipment.shipmentId,
      );
      if (!mounted) return;

      if (success) {
        _loadShipments();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: CustomText(
              text: AppLocalizations.of(context)!.deleteSuccess,
              style: CustomText.bodyStyle,
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: CustomText(
              text: AppLocalizations.of(context)!.deleteError,
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
            text: AppLocalizations.of(context)!.deleteError,
            style: CustomText.errorStyle,
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _handleUpdate(ShipmentTracking shipment) {
    _loadShipments();
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = Responsive.isDesktop(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final horizontalPadding = isDesktop ? screenWidth * 0.1 : 16.0;
    final localizations = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Colors.black87,
      appBar: AppBar(
        backgroundColor: cardBackgroundColor,
        title: CustomText(
          text: widget.title,
          style: CustomText.titleStyle.copyWith(fontSize: isDesktop ? 24 : 20),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _shipments.isEmpty
              ? Center(
                child: CustomText(
                  text: localizations.noShipmentsFound,
                  style: CustomText.bodyStyle.copyWith(
                    color: Colors.grey,
                    fontSize: isDesktop ? 18 : 16,
                  ),
                ),
              )
              : Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: horizontalPadding,
                  vertical: isDesktop ? 24 : 16,
                ),
                child:
                    isDesktop
                        ? ShipmentTableWeb(
                          shipments: _shipments,
                          onDelete: _handleDelete,
                          onUpdate: _handleUpdate,
                          onViewDetails: (shipment) {},
                        )
                        : ListView.builder(
                          padding: EdgeInsets.zero,
                          itemCount: _shipments.length,
                          itemBuilder: (context, index) {
                            final shipment = _shipments[index];
                            return ShipmentTrackingItem(
                              shipment: shipment,
                              onDelete: _handleDelete,
                              onUpdate: _handleUpdate,
                            );
                          },
                        ),
              ),
    );
  }
}
