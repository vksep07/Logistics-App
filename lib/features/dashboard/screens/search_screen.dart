import 'package:flutter/material.dart';
import 'package:logistics_demo/features/shipment/model/shipment_tracking.dart';
import 'package:logistics_demo/theme/palette.dart';
import 'package:logistics_demo/services/shipment_service.dart';
import 'package:logistics_demo/theme/spacing.dart';
import 'package:logistics_demo/features/shipment/widgets/shipment_tracking_list.dart';
import 'package:logistics_demo/widgets/custom_text.dart';
import 'package:logistics_demo/features/shipment/screens/shipment_details_screen.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _searchController = TextEditingController();
  final _shipmentService = ShipmentService();
  final _minSearchLength = 3;
  List<ShipmentTracking> _searchResults = [];
  bool _isLoading = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _performSearch(String query) async {
    if (query.length < _minSearchLength) {
      setState(() {
        _searchResults = [];
        _isLoading = false;
      });
      return;
    }

    setState(() => _isLoading = true);

    try {
      final results = await _shipmentService.searchShipments(query);
      if (!mounted) return;
      setState(() {
        _searchResults = results;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: CustomText(
            text: AppLocalizations.of(context)!.searchError,
            style: CustomText.errorStyle,
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _handleDelete(ShipmentTracking shipment) async {
    try {
      final success = await _shipmentService.deleteShipment(
        shipment.shipmentId,
      );
      if (!mounted) return;

      if (success) {
        _performSearch(_searchController.text);
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

  Future<void> _handleUpdate(ShipmentTracking shipment) async {
    _performSearch(_searchController.text);
  }

  @override
  Widget build(BuildContext context) {
    final cardBackgroundColor = Palette.cardBackgroundColor;
    final localizations = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Palette.backgroundColor,
      appBar: AppBar(
        backgroundColor: cardBackgroundColor,
        title: CustomText(
          text: localizations.searchTitle,
          style: CustomText.titleStyle,
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(Spacing.space16),
            color: cardBackgroundColor,
            child: TextField(
              controller: _searchController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: localizations.searchHint(_minSearchLength),
                hintStyle: TextStyle(color: Colors.grey[400]),
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                suffixIcon:
                    _searchController.text.isNotEmpty
                        ? IconButton(
                          icon: const Icon(Icons.clear, color: Colors.grey),
                          onPressed: () {
                            _searchController.clear();
                            _performSearch('');
                          },
                        )
                        : null,
                filled: true,
                fillColor: Colors.grey[900],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(Spacing.space12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: Spacing.space16,
                  vertical: Spacing.space14,
                ),
              ),
              onChanged: _performSearch,
            ),
          ),
          Expanded(
            child:
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _searchController.text.length < _minSearchLength
                    ? Center(
                      child: CustomText(
                        text: localizations.searchMinCharsMessage(
                          _minSearchLength,
                        ),
                        style: CustomText.bodyStyle.copyWith(
                          color: Colors.grey,
                        ),
                      ),
                    )
                    : _searchResults.isEmpty
                    ? Center(
                      child: CustomText(
                        text: localizations.noShipmentsFound,
                        style: CustomText.bodyStyle.copyWith(
                          color: Colors.grey,
                        ),
                      ),
                    )
                    : ShipmentTrackingList(
                      shipments: _searchResults,
                      onDelete: _handleDelete,
                      onUpdate: _handleUpdate,
                      onViewDetails: (shipment) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) => ShipmentDetailsScreen(
                                  shipment: shipment,
                                  onShipmentUpdated:
                                      () => _handleUpdate(shipment),
                                ),
                          ),
                        );
                      },
                    ),
          ),
        ],
      ),
    );
  }
}
