import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';

class BleScanState {
  final bool isScanning;
  final List<DiscoveredDevice> devices;
  final String? error;

  const BleScanState({
    required this.isScanning,
    required this.devices,
    this.error,
  });

  factory BleScanState.initial() =>
      const BleScanState(isScanning: false, devices: []);
}

extension BleScanStateX on BleScanState {
  BleScanState copyWith({
    bool? isScanning,
    List<DiscoveredDevice>? devices,
    String? error,
  }) {
    return BleScanState(
      isScanning: isScanning ?? this.isScanning,
      devices: devices ?? this.devices,
      error: error ?? this.error,
    );
  }
}
