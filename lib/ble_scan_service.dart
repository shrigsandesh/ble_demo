import 'dart:async';

import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';

class BleScanService {
  BleScanService(this._ble);

  final FlutterReactiveBle _ble;
  StreamSubscription<DiscoveredDevice>? _subscription;

  Stream<DiscoveredDevice> startScan({required List<Uuid> withServices}) {
    return _ble.scanForDevices(
      withServices: withServices,
      scanMode: ScanMode.lowLatency,
      requireLocationServicesEnabled: true,
    );
  }

  void stopScan() {
    _subscription?.cancel();
    _subscription = null;
  }

  void setSubscription(StreamSubscription<DiscoveredDevice> sub) {
    _subscription = sub;
  }
}
