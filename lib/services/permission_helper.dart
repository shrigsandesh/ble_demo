import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';

class BlePermissionHelper {
  static Future<bool> requestBlePermissions() async {
    if (!Platform.isAndroid) return true;

    final androidInfo = await DeviceInfoPlugin().androidInfo;
    final sdkInt = androidInfo.version.sdkInt;

    if (sdkInt >= 31) {
      final scan = await Permission.bluetoothScan.request();
      final connect = await Permission.bluetoothConnect.request();

      return scan.isGranted && connect.isGranted;
    } else {
      final location = await Permission.locationWhenInUse.request();
      return location.isGranted;
    }
  }
}
