String formatStatus(String status) {
  // Handle special case for inTransit
  if (status.toLowerCase() == 'intransit' ||
      status.toLowerCase() == 'in_transit') {
    return 'In Transit';
  }

  // Split by dots to handle enum values (e.g., ShipmentStatus.pending)
  final parts = status.split('.');
  final lastPart = parts.last;

  // Capitalize first letter
  if (lastPart.isEmpty) return '';
  return lastPart[0].toUpperCase() + lastPart.substring(1).toLowerCase();
}
