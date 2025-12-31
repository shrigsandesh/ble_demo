import 'package:ble_demo/cubit/ble_connect_cubit.dart';
import 'package:ble_demo/services/ble_scan_service.dart';
import 'package:ble_demo/cubit/ble_scan_cubit.dart';
import 'package:ble_demo/cubit/ble_scan_state.dart';
import 'package:ble_demo/service_locator.dart';
import 'package:ble_demo/services/permission_helper.dart';
import 'package:ble_demo/ui/device_list_tile.dart';
import 'package:ble_demo/ui/empty_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  final ble = FlutterReactiveBle();
  final scanService = BleScanService(ble);
  final scanCubit = BleScanCubit(scanService);
  final connectCubit = BleConnectionCubit(ble);

  Locator.register<FlutterReactiveBle>(ble);
  Locator.register<BleScanService>(scanService);
  Locator.register<BleScanCubit>(scanCubit);
  Locator.register<BleConnectionCubit>(connectCubit);
  runApp(const BLEDemoApp());
}

class BLEDemoApp extends StatelessWidget {
  const BLEDemoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BLE Demo',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const BLEHomePage(),
    );
  }
}

class BLEHomePage extends StatefulWidget {
  const BLEHomePage({super.key});

  @override
  State<BLEHomePage> createState() => _BLEHomePageState();
}

class _BLEHomePageState extends State<BLEHomePage> {
  final cubit = Locator.get<BleScanCubit>();
  final connectCubit = Locator.get<BleConnectionCubit>();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: cubit,
      child: BlocConsumer<BleScanCubit, BleScanState>(
        listener: (context, state) {
          if (state.error != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error: ${state.error}'),
                backgroundColor: Colors.red,
                duration: const Duration(seconds: 3),
              ),
            );
          }
        },
        builder: (context, state) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Bluetooth Devices'),
              actions: [
                if (state.isScanning)
                  IconButton(
                    icon: const Icon(Icons.stop),
                    onPressed: () {
                      print('Stop scan button pressed');
                      cubit.stopScan();
                    },
                    tooltip: 'Stop Scan',
                  )
                else
                  IconButton(
                    icon: const Icon(Icons.search),
                    onPressed: () async {
                      final granted =
                          await BlePermissionHelper.requestBlePermissions();
                      if (!granted) return;

                      final locationOn =
                          await Permission.location.serviceStatus.isEnabled;
                      if (!locationOn) {
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Turn ON location')),
                        );
                        return;
                      }

                      cubit.startScan();
                    },
                    tooltip: 'Start Scan',
                  ),
              ],
            ),
            body: state.devices.isEmpty
                ? EmptyState(isScanning: state.isScanning)
                : Column(
                    children: [
                      Expanded(
                        child: ListView.builder(
                          itemCount: state.devices.length,
                          padding: const EdgeInsets.only(top: 8),
                          itemBuilder: (context, index) {
                            final device = state.devices[index];

                            return BlocProvider.value(
                              value: connectCubit,
                              child: DeviceListTile(
                                key: ValueKey(device.id),
                                device: device,
                                onTap: () {
                                  // TODO: navigate to detail screen
                                },
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
          );
        },
      ),
    );
  }
}
