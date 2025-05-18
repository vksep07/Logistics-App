import 'package:flutter/material.dart';
import 'package:logistics_demo/theme/palette.dart';
import 'package:logistics_demo/util/responsive.dart';
import 'package:logistics_demo/features/shipment/screens/create_shipment_screen.dart';
import 'package:logistics_demo/services/refresh_service.dart';
import 'package:logistics_demo/theme/spacing.dart';
import 'package:logistics_demo/widgets/custom_text.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class HeaderWidget extends StatelessWidget {
  final String title;
  final VoidCallback? onShipmentCreated;

  const HeaderWidget({super.key, required this.title, this.onShipmentCreated});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final refreshService = RefreshService();
    final cardBackgroundColor = Palette.cardBackgroundColor;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        if (!Responsive.isDesktop(context))
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: InkWell(
              onTap: () => Scaffold.of(context).openDrawer(),
              child: const Padding(
                padding: EdgeInsets.all(4.0),
                child: Icon(Icons.menu, color: Colors.grey, size: 25),
              ),
            ),
          ),

        const SizedBox(width: 16),
        CustomText(
          text: title,
          style: CustomText.titleStyle.copyWith(fontSize: Spacing.space24),
        ),
        ElevatedButton.icon(
          onPressed: () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const CreateShipmentScreen(),
              ),
            );
            if (result == true && onShipmentCreated != null) {
              refreshService.notifyRefresh();
              onShipmentCreated!();
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: cardBackgroundColor,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          icon: const Icon(Icons.add, color: Colors.white),
          label: CustomText(
            text: localizations.createShipment,
            style: CustomText.bodyStyle,
          ),
        ),
      ],
    );
  }
}
