import 'package:flutter/material.dart';

enum MenuItems {
  dashboard,
  profile,
  liveTracking,
  settings,
  feedback,
  signOut;

  String get title {
    switch (this) {
      case MenuItems.dashboard:
        return 'Dashboard';
      case MenuItems.profile:
        return 'Profile';
      case MenuItems.liveTracking:
        return 'Live Tracking';
      case MenuItems.settings:
        return 'Settings';
      case MenuItems.feedback:
        return 'Feedback';
      case MenuItems.signOut:
        return 'SignOut';
    }
  }

  IconData get icon {
    switch (this) {
      case MenuItems.dashboard:
        return Icons.dashboard_outlined;
      case MenuItems.profile:
        return Icons.person_outline;
      case MenuItems.liveTracking:
        return Icons.spatial_tracking_outlined;
      case MenuItems.settings:
        return Icons.settings_outlined;
      case MenuItems.feedback:
        return Icons.feedback;
      case MenuItems.signOut:
        return Icons.logout;
    }
  }

  String get route {
    switch (this) {
      case MenuItems.dashboard:
        return '/dashboard';
      case MenuItems.profile:
        return '/profile';
      case MenuItems.liveTracking:
        return '/liveTracking';
      case MenuItems.settings:
        return '/settings';
      case MenuItems.feedback:
        return '/feedback';
      case MenuItems.signOut:
        return '/logout';
    }
  }

  bool get isLogout => this == MenuItems.signOut;
}
