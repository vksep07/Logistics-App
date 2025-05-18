import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:logistics_demo/features/shipment/model/shipment_tracking.dart';
import 'package:logistics_demo/services/shipment_service.dart';
import 'package:logistics_demo/theme/palette.dart';
import 'package:logistics_demo/theme/spacing.dart';
import 'package:logistics_demo/util/responsive.dart';
import 'dart:math';

import 'package:logistics_demo/widgets/gradient_button.dart';
import 'package:logistics_demo/widgets/custom_text_field.dart';
import 'package:logistics_demo/widgets/custom_text.dart';

class CreateShipmentScreen extends StatefulWidget {
  const CreateShipmentScreen({super.key});

  @override
  State<CreateShipmentScreen> createState() => _CreateShipmentScreenState();
}

class _CreateShipmentScreenState extends State<CreateShipmentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _shipmentService = ShipmentService();

  // Form fields
  final _customerNameController = TextEditingController();
  final _customerAddressController = TextEditingController();
  final _customerMobileController = TextEditingController();
  final _sourceController = TextEditingController();
  final _destinationController = TextEditingController();
  final _driverNameController = TextEditingController();
  final _driverMobileController = TextEditingController();
  final cardBackgroundColor = Palette.cardBackgroundColor;

  bool _isLoading = false;

  String _generateTrackingNumber() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random();
    final result =
        List.generate(6, (index) => chars[random.nextInt(chars.length)]).join();
    return result;
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

  @override
  Widget build(BuildContext context) {
    final isDesktop = Responsive.isDesktop(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final horizontalPadding = isDesktop ? screenWidth * 0.1 : 16.0;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Colors.black87,
      appBar: AppBar(
        backgroundColor: cardBackgroundColor,
        title: CustomText(
          text: l10n.createShipmentTitle,
          style: CustomText.titleStyle,
          isDesktop: isDesktop,
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
          child:
              isDesktop ? _buildDesktopLayout(l10n) : _buildMobileLayout(l10n),
        ),
      ),
    );
  }

  Widget _buildDesktopLayout(AppLocalizations l10n) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildFormSection(l10n.customerInformation, [
                _buildTextField(
                  label: l10n.customerName,
                  controller: _customerNameController,
                  validationKey: 'customerName',
                ),
                _buildTextField(
                  label: l10n.customerAddress,
                  controller: _customerAddressController,
                  validationKey: 'customerAddress',
                ),
                _buildTextField(
                  label: l10n.customerMobile,
                  controller: _customerMobileController,
                  validationKey: 'customerMobile',
                ),
              ]),
              const SizedBox(height: 24),
              _buildFormSection(l10n.driverInformation, [
                _buildTextField(
                  label: l10n.driverName,
                  controller: _driverNameController,
                  validator: null, // Optional field
                ),
                _buildTextField(
                  label: l10n.driverMobile,
                  controller: _driverMobileController,
                  validator: null, // Optional field
                ),
              ]),
            ],
          ),
        ),
        const SizedBox(width: 32),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildFormSection(l10n.shipmentInformation, [
                _buildTextField(
                  label: l10n.sourceLocation,
                  controller: _sourceController,
                  validationKey: 'sourceLocation',
                ),
                _buildTextField(
                  label: l10n.destinationLocation,
                  controller: _destinationController,
                  validationKey: 'destinationLocation',
                ),
              ]),
              const SizedBox(height: 32),
              Center(
                child: SizedBox(
                  width: double.infinity,
                  child: GradientButton(
                    isLoading: _isLoading,
                    onPressed: () {
                      if (!_isLoading) _createShipment();
                    },
                    label: l10n.createShipmentButton,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMobileLayout(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFormSection(l10n.customerInformation, [
          _buildTextField(
            label: l10n.customerName,
            controller: _customerNameController,
            validationKey: 'customerName',
          ),
          _buildTextField(
            label: l10n.customerAddress,
            controller: _customerAddressController,
            validationKey: 'customerAddress',
          ),
          _buildTextField(
            label: l10n.customerMobile,
            controller: _customerMobileController,
            validationKey: 'customerMobile',
          ),
        ]),
        const SizedBox(height: 16),
        _buildFormSection(l10n.shipmentInformation, [
          _buildTextField(
            label: l10n.sourceLocation,
            controller: _sourceController,
            validationKey: 'sourceLocation',
          ),
          _buildTextField(
            label: l10n.destinationLocation,
            controller: _destinationController,
            validationKey: 'destinationLocation',
          ),
        ]),
        const SizedBox(height: 16),
        _buildFormSection(l10n.driverInformation, [
          _buildTextField(
            label: l10n.driverName,
            controller: _driverNameController,
            validator: null, // Optional field
          ),
          _buildTextField(
            label: l10n.driverMobile,
            controller: _driverMobileController,
            validator: null, // Optional field
          ),
        ]),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: GradientButton(
            isLoading: _isLoading,
            onPressed: () {
              if (!_isLoading) _createShipment();
            },
            label: l10n.createShipmentButton,
          ),
        ),
      ],
    );
  }

  Widget _buildFormSection(String title, List<Widget> children) {
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

  String _getValidationMessage(String field) {
    final l10n = AppLocalizations.of(context)!;
    switch (field) {
      case 'customerName':
        return l10n.enterCustomerName;
      case 'customerAddress':
        return l10n.enterCustomerAddress;
      case 'customerMobile':
        return l10n.enterCustomerMobile;
      case 'sourceLocation':
        return l10n.enterSourceLocation;
      case 'destinationLocation':
        return l10n.enterDestinationLocation;
      default:
        return l10n.generalError;
    }
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    String? Function(String?)? validator,
    String? validationKey,
  }) {
    final isDesktop = Responsive.isDesktop(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: Spacing.space16),
      child: CustomTextField(
        controller: controller,
        labelText: label,
        validator:
            validator ??
            (value) {
              if (value == null || value.isEmpty) {
                return _getValidationMessage(validationKey ?? '');
              }
              return null;
            },
        isDesktop: isDesktop,
      ),
    );
  }

  Future<void> _createShipment() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final shipment = ShipmentTracking(
        shipmentId: _generateTrackingNumber(),
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
        status: ShipmentStatus.pending,
        shipmentDate: DateTime.now(),
        trackingSteps: [
          TrackingStep(
            status: 'pending',
            timestamp: DateTime.now(),
            location: _sourceController.text,
            description: 'Shipment registered',
          ),
        ],
      );

      final success = await _shipmentService.addShipment(shipment);

      if (!mounted) return;

      if (success) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: CustomText(
              text: AppLocalizations.of(context)!.shipmentCreatedSuccess,
              style: CustomText.bodyStyle,
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: CustomText(
              text: AppLocalizations.of(context)!.shipmentCreatedError,
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
            text: AppLocalizations.of(context)!.generalError,
            style: CustomText.errorStyle,
          ),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}
