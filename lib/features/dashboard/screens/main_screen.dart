import 'package:flutter/material.dart';
import 'package:logistics_demo/util/responsive.dart';
import 'package:logistics_demo/features/dashboard/widgets/dashboard_widget.dart';
import 'package:logistics_demo/features/dashboard/widgets/side_menu_widget.dart';
import 'package:logistics_demo/theme/palette.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Palette.backgroundColor,
      drawer: const Drawer(child: SideMenuWidget()),
      body: SafeArea(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (Responsive.isDesktop(context))
              const Expanded(flex: 2, child: SideMenuWidget()),
            const Expanded(flex: 10, child: DashboardWidget()),
          ],
        ),
      ),
    );
  }
}
