// ignore_for_file: deprecated_member_use

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:logistics_demo/features/dashboard/model/side_menu_data.dart';
import 'package:logistics_demo/theme/palette.dart';
import 'package:logistics_demo/features/auth/screens/login_screen.dart';
import 'package:logistics_demo/theme/spacing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:logistics_demo/widgets/custom_text.dart';
import 'package:logistics_demo/constants/image_constants.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class SideMenuWidget extends StatefulWidget {
  const SideMenuWidget({super.key});

  @override
  State<SideMenuWidget> createState() => _SideMenuWidgetState();
}

class _SideMenuWidgetState extends State<SideMenuWidget> {
  int selectedIndex = 0;
  final data = SideMenuData();

  void _handleMenuTap(int index, String route) {
    setState(() {
      selectedIndex = index;
    });

    if (route == '/dashboard') {
      if (!kIsWeb) Navigator.pop(context);
      return;
    }

    if (route == '/logout') {
      _showLogoutDialog();
    } else {
      if (!kIsWeb) Navigator.pop(context);
      _showSnackBar(data.menu[index].title);
    }
  }

  void _showLogoutDialog() {
    final localizations = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Palette.cardBackgroundColor,
          title: CustomText(
            text: localizations.logoutTitle,
            style: CustomText.titleStyle,
          ),
          content: CustomText(
            text: localizations.logoutMessage,
            style: CustomText.bodyStyle.copyWith(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: CustomText(
                text: localizations.cancel,
                style: CustomText.bodyStyle.copyWith(color: Colors.grey),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Palette.gradient1,
                    Palette.gradient2,
                    Palette.gradient3,
                  ],
                ),
                borderRadius: BorderRadius.circular(6),
              ),
              child: TextButton(
                onPressed: () {
                  _logout(context);
                },
                style: TextButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                ),
                child: CustomText(
                  text: localizations.logout,
                  style: CustomText.bodyStyle,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _logout(BuildContext context) {
    SharedPreferences.getInstance().then((prefs) {
      prefs.clear();
    });
    // Navigate to login screen
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 260,
      padding: const EdgeInsets.only(top: 80),
      height: double.infinity,
      color: Palette.cardBackgroundColor,
      child: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: data.menu.length,
              itemBuilder: (context, index) => buildMenuEntry(data, index),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    final localizations = AppLocalizations.of(context)!;

    return Container(
      padding: const EdgeInsets.all(Spacing.space10),
      child: Column(
        children: [
          Image.asset(ImageConstants.logoPath),
          CustomText(
            text: localizations.appSlogan,
            style: CustomText.bodyStyle.copyWith(
              fontSize: Spacing.space16,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildMenuEntry(SideMenuData data, int index) {
    final menuItem = data.menu[index];
    final isSelected = selectedIndex == index;

    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: Spacing.space12,
        vertical: Spacing.space4,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(Spacing.space10),
        gradient:
            isSelected
                ? LinearGradient(
                  colors: [
                    Palette.gradient1.withOpacity(0.1),
                    Palette.gradient2.withOpacity(0.1),
                    Palette.gradient3.withOpacity(0.1),
                  ],
                )
                : null,
      ),
      child: ListTile(
        onTap: () => _handleMenuTap(index, menuItem.route),
        leading: Icon(
          menuItem.icon,
          color:
              menuItem.isLogout
                  ? Colors.red[400]
                  : isSelected
                  ? Palette.gradient2
                  : Colors.grey[400],
          size: Spacing.space22,
        ),
        title: CustomText(
          text: menuItem.title,
          style: TextStyle(
            fontSize: Spacing.space14,
            color:
                menuItem.isLogout
                    ? Colors.red[400]
                    : isSelected
                    ? Colors.white
                    : Colors.grey[400],
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Spacing.space10),
        ),
        dense: true,
        visualDensity: const VisualDensity(
          horizontal: -Spacing.space4,
          vertical: -Spacing.space2,
        ),
      ),
    );
  }

  void _showSnackBar(String menuTitle) {
    final localizations = AppLocalizations.of(context)!;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: CustomText(
          text: localizations.comingSoon(menuTitle),
          style: CustomText.bodyStyle,
          textAlign: TextAlign.center,
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
