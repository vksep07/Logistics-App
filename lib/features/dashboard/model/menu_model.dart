import 'package:flutter/material.dart';
import 'package:logistics_demo/features/dashboard/enums/menu_items_enum.dart';

class MenuModel {
  final IconData icon;
  final String title;
  final String route;
  final bool isLogout;
  final MenuItems type;
  MenuModel({required this.type})
    : icon = type.icon,
      title = type.title,
      route = type.route,
      isLogout = type.isLogout;
}
