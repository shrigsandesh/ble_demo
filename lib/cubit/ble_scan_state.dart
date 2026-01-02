import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';

class BleScanState {
  final bool isScanning;
  final List<DiscoveredDevice> devices;
  final Map<String, List<DiscoveredService>>? discoveredServices; // Add this

  final String? error;

  const BleScanState({
    required this.isScanning,
    required this.devices,
    this.error,
    this.discoveredServices,
  });

  factory BleScanState.initial() =>
      const BleScanState(isScanning: false, devices: []);
}

extension BleScanStateX on BleScanState {
  BleScanState copyWith({
    bool? isScanning,
    List<DiscoveredDevice>? devices,
    String? error,
    final Map<String, List<DiscoveredService>>? discoveredServices,
  }) {
    return BleScanState(
      isScanning: isScanning ?? this.isScanning,
      devices: devices ?? this.devices,
      error: error ?? this.error,
      discoveredServices: discoveredServices,
    );
  }
}
