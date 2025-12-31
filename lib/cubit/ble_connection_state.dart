enum BleConnectionStatus {
  initial,
  connecting,
  connected,
  disconnected,
  failure,
}

class BleConnectionState {
  final BleConnectionStatus status;
  final String? deviceId;
  final String? error;

  const BleConnectionState({required this.status, this.deviceId, this.error});

  factory BleConnectionState.initial() {
    return const BleConnectionState(status: BleConnectionStatus.initial);
  }

  BleConnectionState copyWith({
    BleConnectionStatus? status,
    String? deviceId,
    String? error,
  }) {
    return BleConnectionState(
      status: status ?? this.status,
      deviceId: deviceId ?? this.deviceId,
      error: error,
    );
  }
}
