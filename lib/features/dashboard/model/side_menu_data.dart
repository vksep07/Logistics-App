import 'package:logistics_demo/features/dashboard/enums/menu_items_enum.dart';
import 'package:logistics_demo/features/dashboard/model/menu_model.dart';

class SideMenuData {
  final menu = [
    MenuModel(type: MenuItems.dashboard),
    MenuModel(type: MenuItems.profile),
    MenuModel(type: MenuItems.liveTracking),
    MenuModel(type: MenuItems.settings),
    MenuModel(type: MenuItems.feedback),
    MenuModel(type: MenuItems.signOut),
  ];
}
