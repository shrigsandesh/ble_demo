import 'dart:async';
import 'dart:developer';

import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';

class BleNotificationService {
  final FlutterReactiveBle _ble;
  StreamSubscription<List<int>>? _subscription;
  final StreamController<List<int>> _controller = StreamController.broadcast();

  BleNotificationService(this._ble);

  void subscribe(QualifiedCharacteristic characteristic) {
    _subscription?.cancel();

    _subscription = _ble
        .subscribeToCharacteristic(characteristic)
        .listen(
          (data) {
            _controller.add(data);
          },
          onError: (error) {
            log("BLE subscription error: $error");
          },
        );
  }

  Future<List<int>> read(QualifiedCharacteristic characteristic) {
    return _ble.readCharacteristic(characteristic);
  }

  /// Stop notifications
  void unsubscribe() {
    _subscription?.cancel();
    _subscription = null;
    _controller.add([]);
  }

  Stream<List<int>> get stream => _controller.stream;

  void dispose() {
    _subscription?.cancel();
    _controller.close();
  }
}
