import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';

class DeviceListTile extends StatelessWidget {
  final DiscoveredDevice device;
  final VoidCallback onTap;

  const DeviceListTile({super.key, required this.device, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      elevation: 1,
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: _getSignalColor(device.rssi).withOpacity(0.2),
          child: Icon(
            Icons.bluetooth,
            color: _getSignalColor(device.rssi),
            size: 24,
          ),
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
                  color: _getSignalColor(device.rssi),
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
        trailing: Icon(Icons.chevron_right, color: Colors.grey[400]),
        isThreeLine: true,
      ),
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
