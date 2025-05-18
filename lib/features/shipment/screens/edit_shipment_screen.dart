import 'package:flutter/material.dart';
import 'package:logistics_demo/features/shipment/model/shipment_tracking.dart';
import 'package:logistics_demo/services/shipment_service.dart';
import 'package:logistics_demo/services/refresh_service.dart';
import 'package:logistics_demo/theme/palette.dart';
import 'package:logistics_demo/util/responsive.dart';
import 'package:logistics_demo/widgets/gradient_button.dart';
import 'package:logistics_demo/widgets/custom_text.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class EditShipmentScreen extends StatefulWidget {
  final ShipmentTracking shipment;

  const EditShipmentScreen({super.key, required this.shipment});

  @override
  State<EditShipmentScreen> createState() => _EditShipmentScreenState();
}

class _EditShipmentScreenState extends State<EditShipmentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _shipmentService = ShipmentService();
  final _refreshService = RefreshService();

  // Form fields
  late final TextEditingController _customerNameController;
  late final TextEditingController _customerAddressController;
  late final TextEditingController _customerMobileController;
  late final TextEditingController _sourceController;
  late final TextEditingController _destinationController;
  late final TextEditingController _driverNameController;
  late final TextEditingController _driverMobileController;
  final cardBackgroundColor = Palette.cardBackgroundColor;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Initialize controllers with existing shipment data
    _customerNameController = TextEditingController(
      text: widget.shipment.customerName,
    );
    _customerAddressController = TextEditingController(
      text: widget.shipment.customerAddress,
    );
    _customerMobileController = TextEditingController(
      text: widget.shipment.customerMobile,
    );
    _sourceController = TextEditingController(text: widget.shipment.source);
    _destinationController = TextEditingController(
      text: widget.shipment.destination,
    );
    _driverNameController = TextEditingController(
      text: widget.shipment.driverName,
    );
    _driverMobileController = TextEditingController(
      text: widget.shipment.driverMobile,
    );
  }

  @override
  void dispose() {
    _customerNameController.dispose();
    _customerAddressController.dispose();
    _customerMobileController.dispose();
    _sourceController.dispose();
    _destinationController.dispose();
    _driverNameController.dispose();
    _driverMobileController.dispose();
    super.dispose();
  }

  Future<void> _updateShipment() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final updatedShipment = ShipmentTracking(
        shipmentId: widget.shipment.shipmentId,
        customerName: _customerNameController.text,
        customerAddress: _customerAddressController.text,
        customerMobile: _customerMobileController.text,
        source: _sourceController.text,
        destination: _destinationController.text,
        driverName:
            _driverNameController.text.isEmpty
                ? 'Not Assigned'
                : _driverNameController.text,
        driverMobile:
            _driverMobileController.text.isEmpty
                ? 'Not Available'
                : _driverMobileController.text,
        status: widget.shipment.status,
        shipmentDate: widget.shipment.shipmentDate,
        deliveryDate: widget.shipment.deliveryDate,
        trackingSteps: [
          ...widget.shipment.trackingSteps,
          TrackingStep(
            status: widget.shipment.status.toString().split('.').last,
            timestamp: DateTime.now(),
            location: _sourceController.text,
            description: AppLocalizations.of(context)!.statusUpdateMessage(
              widget.shipment.status.toString().split('.').last,
            ),
          ),
        ],
      );

      final success = await _shipmentService.updateShipment(updatedShipment);

      if (!mounted) return;

      if (success) {
        _refreshService.notifyRefresh();
        // Pop back to the dashboard
        Navigator.of(context).popUntil((route) => route.isFirst);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: CustomText(
              text: AppLocalizations.of(context)!.updateSuccess,
              style: CustomText.bodyStyle,
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: CustomText(
              text: AppLocalizations.of(context)!.updateError,
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
            text: AppLocalizations.of(context)!.updateError,
            style: CustomText.errorStyle,
          ),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    String? Function(String?)? validator,
  }) {
    final isDesktop = Responsive.isDesktop(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        validator: validator,
        style: TextStyle(color: Colors.white, fontSize: isDesktop ? 16 : 14),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            color: Colors.grey,
            fontSize: isDesktop ? 15 : 14,
          ),
          enabledBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.grey),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Palette.gradient1),
          ),
          errorBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.red),
          ),
          focusedErrorBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.red),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = Responsive.isDesktop(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final horizontalPadding = isDesktop ? screenWidth * 0.1 : 16.0;
    final localizations = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Palette.backgroundColor,
      appBar: AppBar(
        backgroundColor: cardBackgroundColor,
        title: CustomText(
          text: localizations.updateShipment,
          style: CustomText.titleStyle,
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: horizontalPadding,
          vertical: isDesktop ? 24 : 16,
        ),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Customer Information Section
              CustomText(
                text: localizations.customerInformation,
                style: CustomText.titleStyle,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                label: localizations.customerName,
                controller: _customerNameController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return localizations.enterCustomerName;
                  }
                  return null;
                },
              ),
              _buildTextField(
                label: localizations.customerAddress,
                controller: _customerAddressController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return localizations.enterCustomerAddress;
                  }
                  return null;
                },
              ),
              _buildTextField(
                label: localizations.customerMobile,
                controller: _customerMobileController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return localizations.enterCustomerMobile;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Shipment Information Section
              CustomText(
                text: localizations.shipmentInformation,
                style: CustomText.titleStyle,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                label: localizations.sourceLocation,
                controller: _sourceController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return localizations.enterSourceLocation;
                  }
                  return null;
                },
              ),
              _buildTextField(
                label: localizations.destinationLocation,
                controller: _destinationController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return localizations.enterDestinationLocation;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Driver Information Section
              CustomText(
                text: localizations.driverInformation,
                style: CustomText.titleStyle,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                label: localizations.driverName,
                controller: _driverNameController,
              ),
              _buildTextField(
                label: localizations.driverMobile,
                controller: _driverMobileController,
              ),
              const SizedBox(height: 32),

              // Update Button
              SizedBox(
                width: double.infinity,
                child: GradientButton(
                  isLoading: _isLoading,
                  onPressed: _updateShipment,
                  label: localizations.updateShipment,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
