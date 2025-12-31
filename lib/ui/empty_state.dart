import 'package:flutter/material.dart';

class EmptyState extends StatelessWidget {
  const EmptyState({super.key, required this.isScanning});

  final bool isScanning;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isScanning ? Icons.bluetooth_searching : Icons.bluetooth,
            size: 64,
            color: isScanning ? Colors.blue : Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            isScanning
                ? 'Scanning for devices...'
                : 'Tap search to find nearby devices',
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
          if (isScanning) ...[
            const SizedBox(height: 16),
            const CircularProgressIndicator(),
          ],
        ],
      ),
    );
  }
}
