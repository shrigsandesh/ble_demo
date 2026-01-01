import 'package:ble_demo/cubit/ble_notification_cubit.dart';
import 'package:ble_demo/service_locator.dart';
import 'package:ble_demo/services/ble_notification_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';

class ConnectedDevicePage extends StatefulWidget {
  final QualifiedCharacteristic characteristic;

  const ConnectedDevicePage({super.key, required this.characteristic});

  @override
  State<ConnectedDevicePage> createState() => _ConnectedDevicePageState();
}

class _ConnectedDevicePageState extends State<ConnectedDevicePage> {
  late final BleNotificationCubit _notificationCubit;

  @override
  void initState() {
    super.initState();
    // Get BLE service from locator
    final bleService = BleNotificationService(
      Locator.get<FlutterReactiveBle>(),
    );
    _notificationCubit = BleNotificationCubit(bleService);

    // Subscribe to the characteristic
    _notificationCubit.subscribeToCharacteristic(widget.characteristic);
  }

  @override
  void dispose() {
    _notificationCubit.unsubscribe();
    _notificationCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Connected Device")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: BlocBuilder<BleNotificationCubit, List<int>>(
          bloc: _notificationCubit,
          builder: (context, data) {
            if (data.isEmpty) {
              return const Center(child: Text("No data received yet."));
            }
            return ListView(
              children: [
                Text("Raw Notification Data:"),
                const SizedBox(height: 8),
                Text(data.toString()),
                const SizedBox(height: 16),
                // Example: Show bytes as hex
                Text("Hex:"),
                const SizedBox(height: 8),
                Text(
                  data
                      .map((e) => e.toRadixString(16).padLeft(2, '0'))
                      .join(" "),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
