import 'package:ble_demo/helpers/ble_helper.dart';
import 'package:ble_demo/ui/connected_device_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';

class ServiceSelectionPage extends StatelessWidget {
  final DiscoveredDevice device;
  final List<Service> services;

  const ServiceSelectionPage({
    super.key,
    required this.device,
    required this.services,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(device.name.isNotEmpty ? device.name : 'Unknown Device'),
        backgroundColor: Colors.cyan,
      ),
      body: services.isEmpty
          ? const Center(child: Text('No services found'))
          : ListView.builder(
              itemCount: services.length,
              itemBuilder: (context, index) {
                final service = services[index];
                final serviceName = BleUuidHelper.getServiceName(service.id);
                final serviceUuid = BleUuidHelper.formatUuid(service.id);

                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  elevation: 0,
                  color: Colors.grey[100],
                  child: ExpansionTile(
                    tilePadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    childrenPadding: EdgeInsets.zero,
                    title: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          serviceName,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Text(
                              'UUID: ',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                            Expanded(
                              child: Text(
                                serviceUuid,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    children: [
                      // Characteristics list
                      ...service.characteristics.map((char) {
                        final charName = BleUuidHelper.getCharacteristicName(
                          char.id,
                        );
                        final charUuid = char.id.toString();

                        // Build properties string
                        List<String> properties = [];
                        if (char.isNotifiable) properties.add('NOTIFY');
                        if (char.isReadable) properties.add('READ');
                        if (char.isWritableWithResponse) {
                          properties.add('WRITE');
                        }
                        if (char.isWritableWithoutResponse) {
                          properties.add('WRITE NO RESPONSE');
                        }
                        if (char.isIndicatable) properties.add('INDICATE');

                        return InkWell(
                          onTap: () {
                            final characteristic = QualifiedCharacteristic(
                              serviceId: service.id,
                              characteristicId: char.id,
                              deviceId: device.id,
                            );

                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ConnectedDevicePage(
                                  characteristic: characteristic,
                                  charName: charName,
                                ),
                              ),
                            );
                          },
                          borderRadius: BorderRadius.circular(8),
                          splashColor: Colors.blue.withValues(alpha: 0.2),
                          highlightColor: Colors.blue.withValues(alpha: .1),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border(
                                top: BorderSide(
                                  color: Colors.grey[300]!,
                                  width: 1,
                                ),
                              ),
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: .02),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Left info column
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const SizedBox(height: 4),
                                      // Hint text
                                      const Text(
                                        'Tap to view data',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.blueAccent,
                                          fontStyle: FontStyle.italic,
                                        ),
                                      ),
                                      Text(
                                        charName,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          color: Colors.black87,
                                          fontWeight: FontWeight
                                              .bold, // bolder to show importance
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          const Text(
                                            'UUID: ',
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.grey,
                                            ),
                                          ),
                                          Expanded(
                                            child: Text(
                                              charUuid,
                                              overflow: TextOverflow.visible,
                                              style: const TextStyle(
                                                fontSize: 14,
                                                color: Colors.black87,
                                              ),
                                              maxLines: 2,
                                            ),
                                          ),
                                        ],
                                      ),
                                      if (properties.isNotEmpty) ...[
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            const Text(
                                              'Properties: ',
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.grey,
                                              ),
                                            ),
                                            Expanded(
                                              child: Text(
                                                properties.join(', '),
                                                style: const TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.black87,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                                // Right chevron icon to indicate clickability
                                const Icon(
                                  Icons.chevron_right,
                                  color: Colors.grey,
                                  size: 24,
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
