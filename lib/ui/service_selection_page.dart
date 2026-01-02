import 'package:ble_demo/helpers/ble_helper.dart';
import 'package:ble_demo/ui/inline_characterstics_detail.dart';
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
                return ExpansionTile(
                  childrenPadding: EdgeInsets.zero,

                  title: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        serviceName,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Row(
                        children: [
                          const Text(
                            'UUID: ',
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                          Expanded(
                            child: Text(
                              serviceUuid,
                              style: const TextStyle(
                                fontSize: 12,
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

                        child: Container(
                          padding: const EdgeInsets.only(left: 20),

                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      charName,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.black87,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        const Text(
                                          'UUID: ',
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
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
                                              fontWeight: FontWeight.w700,
                                              fontSize: 12,
                                            ),
                                          ),
                                          Expanded(
                                            child: Text(
                                              properties.join(', '),
                                              style: TextStyle(fontSize: 12),
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 4),

                                      //update this section.
                                      InlineCharacteristicDetails(
                                        characteristic: QualifiedCharacteristic(
                                          serviceId: service.id,
                                          characteristicId: char.id,
                                          deviceId: device.id,
                                        ),
                                        isNotifiable: char.isNotifiable,
                                        isReadable: char.isReadable,
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  ],
                );
              },
            ),
    );
  }
}
