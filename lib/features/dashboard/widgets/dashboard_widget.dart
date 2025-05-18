import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:logistics_demo/features/shipment/model/shipment_tracking.dart';
import 'package:logistics_demo/services/app_database.dart';
import 'package:logistics_demo/theme/palette.dart';
import 'package:logistics_demo/features/dashboard/screens/search_screen.dart';
import 'package:logistics_demo/services/shipment_service.dart';
import 'package:logistics_demo/services/refresh_service.dart';
import 'package:logistics_demo/theme/spacing.dart';
import 'package:logistics_demo/util/responsive.dart';
import 'package:logistics_demo/features/shipment/widgets/activity_details_card.dart';
import 'package:logistics_demo/features/shipment/widgets/header_widget.dart';
import 'package:logistics_demo/features/shipment/widgets/shipment_tracking_list.dart';
import 'package:logistics_demo/features/shipment/widgets/shipment_table_web.dart';
import 'package:logistics_demo/widgets/custom_text.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class DashboardWidget extends StatefulWidget {
  const DashboardWidget({super.key});

  @override
  State<DashboardWidget> createState() => _DashboardWidgetState();
}

class _DashboardWidgetState extends State<DashboardWidget> {
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

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _loadShipments() async {
    setState(() => _isLoading = true);
    try {
      final shipments = await AppDatabase().getAllShipments();
      shipments.sort((a, b) {
        final aDate = a.shipmentDate.toUtc();
        final bDate = b.shipmentDate.toUtc();
        return bDate.compareTo(aDate);
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

  Future<void> _handleDelete(ShipmentTracking shipment) async {
    try {
      final success = await _shipmentService.deleteShipment(
        shipment.shipmentId,
      );
      if (!mounted) return;
      if (success) {
        _refreshService.notifyRefresh();
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

  Future<void> _handleUpdate(ShipmentTracking shipment) async {
    _refreshService.notifyRefresh();
  }

  void _handleViewDetails(ShipmentTracking shipment) {
    // Navigation is handled in the item widget
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final isDesktop = Responsive.isDesktop(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final gapFromTop = const SizedBox(height: Spacing.space18);

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? screenWidth * 0.02 : Spacing.space18,
      ),
      child: Column(
        children: [
          gapFromTop,
          HeaderWidget(
            title: localizations.dashboardTitle,
            onShipmentCreated: _loadShipments,
          ),
          gapFromTop,
          _searchWidget(),
          gapFromTop,
          if (_isLoading)
            const Expanded(child: Center(child: CircularProgressIndicator()))
          else if (isDesktop)
            Expanded(
              child: Column(
                children: [
                  CustomText(
                    text: localizations.activityOverview,
                    style: CustomText.titleStyle,
                  ),
                  const SizedBox(height: Spacing.space20),
                  const ActivityDetailsCard(),
                  gapFromTop,
                  Expanded(child: _buildShipmentList(context)),
                ],
              ),
            )
          else
            Expanded(
              child: ListView(
                children: [
                  CustomText(
                    text: localizations.activityOverview,
                    style: CustomText.titleStyle,
                  ),
                  gapFromTop,
                  const ActivityDetailsCard(),
                  gapFromTop,
                  _buildShipmentList(context),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildShipmentList(BuildContext context) {
    final isDesktop = Responsive.isDesktop(context);
    final localizations = AppLocalizations.of(context)!;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: isDesktop ? Palette.cardBackgroundColor : null,
        borderRadius: BorderRadius.circular(Spacing.space12),
      ),
      padding:
          isDesktop ? const EdgeInsets.all(Spacing.space20) : EdgeInsets.zero,
      child:
          isDesktop
              ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomText(
                    text: localizations.recentShipments,
                    style: CustomText.titleStyle,
                  ),
                  const SizedBox(height: Spacing.space20),
                  Expanded(
                    child: ShipmentTableWeb(
                      shipments: _shipments,
                      onDelete: _handleDelete,
                      onUpdate: _handleUpdate,
                      onViewDetails: _handleViewDetails,
                    ),
                  ),
                ],
              )
              : ShipmentTrackingList(
                shipments: _shipments,
                onDelete: _handleDelete,
                onUpdate: _handleUpdate,
                onViewDetails: _handleViewDetails,
              ),
    );
  }

  Widget _searchWidget() {
    final localizations = AppLocalizations.of(context)!;

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const SearchScreen()),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: Spacing.space16,
          vertical: Spacing.space12,
        ),
        decoration: BoxDecoration(
          color: Palette.cardBackgroundColor,
          borderRadius: BorderRadius.circular(Spacing.space12),
        ),
        child: Row(
          children: [
            const Icon(Icons.search, color: Colors.grey, size: Spacing.space20),
            const SizedBox(width: Spacing.space12),
            CustomText(
              text: localizations.searchShipments,
              style: CustomText.bodyStyle.copyWith(color: Colors.grey[400]),
            ),
          ],
        ),
      ),
    );
  }
}
