// ble_uuid_helper.dart
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';

class BleUuidHelper {
  // Standard service names
  static const Map<String, String> _serviceNames = {
    // Standard Bluetooth SIG Services
    '00001800-0000-1000-8000-00805f9b34fb': 'Generic Access',
    '00001801-0000-1000-8000-00805f9b34fb': 'Generic Attribute',
    '0000180a-0000-1000-8000-00805f9b34fb': 'Device Information',
    '0000180d-0000-1000-8000-00805f9b34fb': 'Heart Rate',
    '0000180f-0000-1000-8000-00805f9b34fb': 'Battery Service',
    '00001810-0000-1000-8000-00805f9b34fb': 'Blood Pressure',
    '00001812-0000-1000-8000-00805f9b34fb': 'Human Interface Device',
    '00001816-0000-1000-8000-00805f9b34fb': 'Cycling Speed and Cadence',
    '00001818-0000-1000-8000-00805f9b34fb': 'Cycling Power',
    '0000181a-0000-1000-8000-00805f9b34fb': 'Environmental Sensing',
    '00001809-0000-1000-8000-00805f9b34fb': 'Health Thermometer',
    '0000181c-0000-1000-8000-00805f9b34fb': 'User Data',
    '0000181d-0000-1000-8000-00805f9b34fb': 'Weight Scale',

    // Apple Services (these are the ones in your screenshot)
    'd0611e78-bbb4-4591-a5f8-487910ae4366': 'Apple Continuity Service',
    '9fa480e0-4967-4542-9390-d343dc5d04ae': 'Apple Nearby Service',
    '89d3502b-0f36-433a-8ef4-c502ad55f8dc': 'Apple Notification Center Service',
    '7905f431-b5ce-4e99-a40f-4b1e122d00d0': 'Apple Media Service',

    // Your custom service from the screenshot
    'c7b9a3e2-4f6d-4c8e-9f21-6b1d8a920000': 'Temperature Service (Flytechy)',
  };

  // Standard characteristic names
  static const Map<String, String> _characteristicNames = {
    // Generic Access
    '00002a00-0000-1000-8000-00805f9b34fb': 'Device Name',
    '00002a01-0000-1000-8000-00805f9b34fb': 'Appearance',
    '00002a04-0000-1000-8000-00805f9b34fb':
        'Peripheral Preferred Connection Parameters',
    '00002a05-0000-1000-8000-00805f9b34fb': 'Service Changed',

    // Device Information
    '00002a19-0000-1000-8000-00805f9b34fb': 'Battery Level',
    '00002a23-0000-1000-8000-00805f9b34fb': 'System ID',
    '00002a24-0000-1000-8000-00805f9b34fb': 'Model Number String',
    '00002a25-0000-1000-8000-00805f9b34fb': 'Serial Number String',
    '00002a26-0000-1000-8000-00805f9b34fb': 'Firmware Revision String',
    '00002a27-0000-1000-8000-00805f9b34fb': 'Hardware Revision String',
    '00002a28-0000-1000-8000-00805f9b34fb': 'Software Revision String',
    '00002a29-0000-1000-8000-00805f9b34fb': 'Manufacturer Name String',
    '00002a50-0000-1000-8000-00805f9b34fb': 'PnP ID',

    // Heart Rate
    '00002a37-0000-1000-8000-00805f9b34fb': 'Heart Rate Measurement',
    '00002a38-0000-1000-8000-00805f9b34fb': 'Body Sensor Location',
    '00002a39-0000-1000-8000-00805f9b34fb': 'Heart Rate Control Point',

    // Temperature-related characteristics
    '00002a1c-0000-1000-8000-00805f9b34fb': 'Temperature Measurement',
    '00002a1d-0000-1000-8000-00805f9b34fb': 'Temperature Type',
    '00002a1e-0000-1000-8000-00805f9b34fb': 'Intermediate Temperature',
    '00002a21-0000-1000-8000-00805f9b34fb': 'Measurement Interval',

    // Environmental Sensing
    '00002a6e-0000-1000-8000-00805f9b34fb': 'Temperature',
    '00002a6f-0000-1000-8000-00805f9b34fb': 'Humidity',
    '00002a76-0000-1000-8000-00805f9b34fb': 'UV Index',
    '00002a6d-0000-1000-8000-00805f9b34fb': 'Pressure',

    // Your custom characteristics from the screenshot
    'c7b9a3e2-4f6d-4c8e-9f21-6b1d8a920001': 'Temperature Reading (Flytechy)',
    'af0badb1-5b99-43cd-917a-a77bc549e3cc': 'Custom Characteristic',
  };

  static String getServiceName(Uuid serviceId) {
    final uuid = serviceId.toString().toLowerCase();
    return _serviceNames[uuid] ?? 'Unknown Service';
  }

  static String getCharacteristicName(Uuid charId) {
    final uuid = charId.toString().toLowerCase();
    return _characteristicNames[uuid] ?? 'Unknown Characteristic';
  }

  static String formatUuid(Uuid uuid) {
    final uuidStr = uuid.toString().toLowerCase();

    // Check if it's a 16-bit UUID (standard Bluetooth)
    if (uuidStr.contains('-0000-1000-8000-00805f9b34fb')) {
      // Extract the short form (0x prefix + first 4 characters after removing dashes)
      return '0x${uuidStr.substring(4, 8).toUpperCase()}';
    }

    // Return full UUID for custom services
    return uuidStr;
  }

  // Helper to check if a characteristic is temperature-related
  static bool isTemperatureCharacteristic(Uuid charId) {
    final uuid = charId.toString().toLowerCase();
    return uuid ==
            '00002a1c-0000-1000-8000-00805f9b34fb' || // Temperature Measurement
        uuid == '00002a1d-0000-1000-8000-00805f9b34fb' || // Temperature Type
        uuid ==
            '00002a1e-0000-1000-8000-00805f9b34fb' || // Intermediate Temperature
        uuid ==
            '00002a6e-0000-1000-8000-00805f9b34fb' || // Temperature (Environmental)
        uuid ==
            'c7b9a3e2-4f6d-4c8e-9f21-6b1d8a920001'; // Custom temp characteristic
  }
}
