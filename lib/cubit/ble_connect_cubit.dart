import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'ble_connection_state.dart';

class BleConnectionCubit extends Cubit<BleConnectionState> {
  final FlutterReactiveBle _ble;

  StreamSubscription<ConnectionStateUpdate>? _connectionSub;

  BleConnectionCubit(this._ble) : super(BleConnectionState.initial());

  /// Connect to a BLE device
  void connect(String deviceId) {
    emit(
      BleConnectionState(
        status: BleConnectionStatus.connecting,
        deviceId: deviceId,
      ),
    );

    _connectionSub?.cancel();

    _connectionSub = _ble
        .connectToDevice(
          id: deviceId,
          connectionTimeout: const Duration(seconds: 10),
        )
        .listen(
          (update) {
            _handleConnectionUpdate(update);
          },
          onError: (error) {
            emit(
              BleConnectionState(
                status: BleConnectionStatus.failure,
                deviceId: deviceId,
                error: error.toString(),
              ),
            );
          },
        );
  }

  void _handleConnectionUpdate(ConnectionStateUpdate update) {
    switch (update.connectionState) {
      case DeviceConnectionState.connecting:
        emit(
          BleConnectionState(
            status: BleConnectionStatus.connecting,
            deviceId: update.deviceId,
          ),
        );
        break;

      case DeviceConnectionState.connected:
        emit(
          BleConnectionState(
            status: BleConnectionStatus.connected,
            deviceId: update.deviceId,
          ),
        );
        break;

      case DeviceConnectionState.disconnecting:
      case DeviceConnectionState.disconnected:
        emit(
          BleConnectionState(
            status: BleConnectionStatus.disconnected,
            deviceId: update.deviceId,
          ),
        );
        break;
    }
  }

  /// Disconnect manually
  Future<void> disconnect() async {
    await _connectionSub?.cancel();
    _connectionSub = null;

    emit(
      BleConnectionState(
        status: BleConnectionStatus.disconnected,
        deviceId: state.deviceId,
      ),
    );
  }

  @override
  Future<void> close() {
    _connectionSub?.cancel();
    return super.close();
  }
}
