import 'package:ble_demo/cubit/ble_notification_cubit.dart';
import 'package:ble_demo/service_locator.dart';
import 'package:ble_demo/services/ble_notification_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';

class ConnectedDevicePage extends StatefulWidget {
  final QualifiedCharacteristic characteristic;
  final String charName;

  const ConnectedDevicePage({
    super.key,
    required this.characteristic,
    required this.charName,
  });

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
      appBar: AppBar(
        title: Text(widget.charName, style: const TextStyle(fontSize: 16)),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: BlocBuilder<BleNotificationCubit, List<int>>(
          bloc: _notificationCubit,
          builder: (context, data) {
            final hexValue = data
                .map((e) => e.toRadixString(16).padLeft(2, '0'))
                .join(" ");

            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Description
                  const Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 8.0,
                      vertical: 12,
                    ),
                    child: Text(
                      "Live updates should appear automatically.\n"
                      "For initial value, press the button below.",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 14, color: Colors.black54),
                    ),
                  ),

                  // Initial read button
                  ElevatedButton.icon(
                    onPressed: () {
                      _notificationCubit.readInitialValue(
                        widget.characteristic,
                      );
                    },
                    icon: const Icon(Icons.download),
                    label: const Text("Read Initial Value"),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  // Display BLE data if available
                  if (data.isNotEmpty) ...[
                    _infoCard(
                      title: "HEX VALUE",
                      value: hexValue.toUpperCase(),
                      valueSize: 26,
                      background: Colors.blue.shade50,
                    ),
                    const SizedBox(height: 20),
                    _infoCard(
                      title: "RAW BYTES",
                      value: data.toString(),
                      valueSize: 16,
                      background: Colors.grey.shade200,
                    ),
                  ],
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

Widget _infoCard({
  required String title,
  required String value,
  required Color background,
  double valueSize = 18,
}) {
  return Container(
    width: double.infinity,
    padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
    decoration: BoxDecoration(
      color: background,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: Colors.blueGrey.shade100),
    ),
    child: Column(
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
            color: Colors.black54,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          value,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: valueSize,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
      ],
    ),
  );
}
