import 'dart:developer';

import 'package:ble_demo/cubit/ble_connect_cubit.dart';
import 'package:ble_demo/cubit/ble_connection_state.dart';
import 'package:ble_demo/helpers/ble_helper.dart';
import 'package:ble_demo/service_locator.dart';
import 'package:ble_demo/ui/connected_device_page.dart';
import 'package:ble_demo/ui/service_selection_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';

class DeviceListTile extends StatelessWidget {
  final DiscoveredDevice device;

  const DeviceListTile({super.key, required this.device});

  void _showAlert(
    BuildContext context, {
    required VoidCallback onViewStream,
    required VoidCallback onViewDetails,
  }) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Choose an option'),

          actionsAlignment: MainAxisAlignment.spaceEvenly,
          actions: [
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).pop();
                onViewStream();
              },
              icon: const Icon(Icons.stream, size: 18),
              label: const Text('Stream'),
            ),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).pop();
                onViewDetails();
              },
              icon: const Icon(Icons.info_outline, size: 18),
              label: const Text('Details'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final signalColor = _getSignalColor(device.rssi);

    return BlocBuilder<BleConnectionCubit, BleConnectionState>(
      builder: (context, state) {
        final isConnected =
            state.status == BleConnectionStatus.connected &&
            state.deviceId == device.id;

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          elevation: 1,
          child: ListTile(
            onTap: () async {
              if (isConnected) {
                try {
                  final services = await Locator.get<BleConnectionCubit>()
                      .discoverServices(device.id);

                  if (!context.mounted) return;

                  if (services.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('No services found')),
                    );
                    return;
                  }

                  _showAlert(
                    context,
                    onViewStream: () {
                      final characteristic = QualifiedCharacteristic(
                        serviceId: Uuid.parse(
                          "c7b9a3e2-4f6d-4c8e-9f21-6b1d8a920000",
                        ),
                        characteristicId: Uuid.parse(
                          'c7b9a3e2-4f6d-4c8e-9f21-6b1d8a920001',
                        ),
                        deviceId: device.id,
                      );
                      final charName = BleUuidHelper.getCharacteristicName(
                        characteristic.characteristicId,
                      );
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ConnectedDevicePage(
                            characteristic: characteristic,
                            charName: charName,
                          ),
                        ),
                      );
                    },
                    onViewDetails: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ServiceSelectionPage(
                            device: device,
                            services: services,
                          ),
                        ),
                      );
                    },
                  );
                } catch (e) {
                  if (!context.mounted) return;
                  Navigator.pop(context);
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text('Error: $e')));
                }
              } else {
                // Show snackbar if device is not connected
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Device is not connected. Please pair first.',
                    ),
                  ),
                );
              }
            },
            leading: CircleAvatar(
              backgroundColor: signalColor.withValues(alpha: .2),
              child: Icon(Icons.bluetooth, color: signalColor, size: 24),
            ),
            title: Text(
              device.name.isEmpty ? 'Unknown Device' : device.name,
              style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(
                  device.id,
                  style: TextStyle(
                    fontSize: 12,
                    fontFamily: 'Courier',
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      _getSignalIcon(device.rssi),
                      size: 14,
                      color: signalColor,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${device.rssi} dBm',
                      style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                    ),
                  ],
                ),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                BlocBuilder<BleConnectionCubit, BleConnectionState>(
                  builder: (context, state) {
                    log(state.status.toString());
                    final isConnectingThisDevice =
                        state.status == BleConnectionStatus.connecting &&
                        state.deviceId == device.id;
                    if (isConnectingThisDevice) {
                      return const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      );
                    }
                    return OutlinedButton(
                      onPressed: () {
                        debugPrint('Pair pressed for ${device.id}');
                        switch (state.status) {
                          case BleConnectionStatus.connected:
                            context.read<BleConnectionCubit>().disconnect();
                            break;
                          case BleConnectionStatus.initial:
                          case BleConnectionStatus.disconnected:
                            context.read<BleConnectionCubit>().connect(
                              device.id,
                            );
                            break;
                          case BleConnectionStatus.failure:
                          case BleConnectionStatus.connecting:
                        }
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        visualDensity: VisualDensity.compact,
                      ),
                      child: Text(
                        isConnected ? "Connected" : 'Pair',
                        style: const TextStyle(fontSize: 12),
                      ),
                    );
                  },
                ),
                const SizedBox(width: 4),
                Icon(Icons.chevron_right, color: Colors.grey[400]),
              ],
            ),
            isThreeLine: true,
          ),
        );
      },
    );
  }

  Color _getSignalColor(int rssi) {
    if (rssi >= -60) return Colors.green;
    if (rssi >= -70) return Colors.orange;
    return Colors.red;
  }

  IconData _getSignalIcon(int rssi) {
    if (rssi >= -60) return Icons.signal_cellular_alt;
    if (rssi >= -70) return Icons.signal_cellular_alt_2_bar;
    return Icons.signal_cellular_alt_1_bar;
  }
}
