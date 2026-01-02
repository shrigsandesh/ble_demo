import 'dart:async';
import 'dart:developer';

import 'package:ble_demo/services/ble_notification_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';

class BleNotificationCubit extends Cubit<List<int>> {
  final BleNotificationService _service;
  StreamSubscription<List<int>>? _subscription;

  BleNotificationCubit(this._service) : super([]) {
    // Listen to service stream
    _subscription = _service.stream.listen((data) => emit(data));
  }

  void subscribeToCharacteristic(QualifiedCharacteristic characteristic) {
    _service.subscribe(characteristic);
  }

  void unsubscribe() {
    _service.unsubscribe();
  }

  Future<void> readInitialValue(QualifiedCharacteristic characteristic) async {
    try {
      final value = await _service.read(characteristic);
      emit(value);
    } catch (e) {
      log("Error reading characteristic: $e");
    }
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    _service.dispose();
    return super.close();
  }
}
