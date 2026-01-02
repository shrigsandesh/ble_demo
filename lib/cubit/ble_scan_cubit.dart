import 'dart:async';

import 'package:ble_demo/services/ble_scan_service.dart';
import 'package:ble_demo/cubit/ble_scan_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';

const int rssiThreshold = -100;
const String environmentServiceUUID = '0000fef3-0000-1000-8000-00805f9b34fb';
const String tempCharacteristicUUID = "c7b9a3e2-4f6d-4c8e-9f21-6b1d8a920001";

class BleScanCubit extends Cubit<BleScanState> {
  BleScanCubit(this._scanService) : super(BleScanState.initial());

  final BleScanService _scanService;
  StreamSubscription<DiscoveredDevice>? _scanSub;
  Timer? _timeoutTimer;
  Timer? _debounceTimer;

  final Map<String, DiscoveredDevice> _deviceCache = {};
  static const _debounceDuration = Duration(milliseconds: 500);

  void startScan({
    Duration timeout = const Duration(seconds: 2),
    String? stopWhenFoundId,
    bool filterByService = false,
  }) {
    if (state.isScanning) return;

    _deviceCache.clear();
    emit(state.copyWith(isScanning: true, devices: [], error: null));

    final services = filterByService
        ? [Uuid.parse(environmentServiceUUID)]
        : <Uuid>[];

    _scanSub = _scanService
        .startScan(withServices: services)
        .listen(
          (device) => _onDeviceFound(device, stopWhenFoundId),
          onError: (error) {
            emit(state.copyWith(error: error.toString(), isScanning: false));
            stopScan();
          },
        );

    _scanService.setSubscription(_scanSub!);

    _timeoutTimer?.cancel();
    _timeoutTimer = Timer(timeout, stopScan);
  }

  void _onDeviceFound(DiscoveredDevice device, String? stopWhenFoundId) {
    if (!_shouldIncludeDevice(device)) return;

    // Update cache
    _deviceCache[device.id] = device;

    // Debounce UI updates
    _debounceTimer?.cancel();
    _debounceTimer = Timer(_debounceDuration, _emitDevices);

    if (stopWhenFoundId != null && device.id == stopWhenFoundId) {
      stopScan();
    }
  }

  void _emitDevices() {
    final devices = _deviceCache.values.toList()
      ..sort((a, b) => b.rssi.compareTo(a.rssi));

    emit(state.copyWith(devices: devices));
  }

  bool _shouldIncludeDevice(DiscoveredDevice device) {
    if (device.rssi <= rssiThreshold) return false;

    // Check manufacturer data
    if (device.manufacturerData.isNotEmpty) {}

    // Check service data (some devices advertise service data)
    if (device.serviceData.isNotEmpty) {
      // Check if your service UUID is in service data
      final targetUuid = Uuid.parse(environmentServiceUUID);
      if (device.serviceData.containsKey(targetUuid)) {
        return true;
      }
    }

    return device.name.isNotEmpty;
  }

  void stopScan() {
    _timeoutTimer?.cancel();
    _timeoutTimer = null;

    _debounceTimer?.cancel();
    _debounceTimer = null;

    _scanSub?.cancel();
    _scanSub = null;

    _scanService.stopScan();

    // Emit final state
    _emitDevices();
    emit(state.copyWith(isScanning: false));
  }

  @override
  Future<void> close() {
    stopScan();
    _deviceCache.clear();
    return super.close();
  }
}
