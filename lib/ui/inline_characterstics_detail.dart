import 'package:ble_demo/cubit/ble_notification_cubit.dart';
import 'package:ble_demo/services/ble_notification_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';

import '../service_locator.dart';

class InlineCharacteristicDetails extends StatefulWidget {
  final QualifiedCharacteristic characteristic;

  final bool isNotifiable;
  final bool isReadable;

  const InlineCharacteristicDetails({
    super.key,
    required this.characteristic,
    required this.isNotifiable,
    required this.isReadable,
  });

  @override
  State<InlineCharacteristicDetails> createState() =>
      _InlineCharacteristicDetailsState();
}

class _InlineCharacteristicDetailsState
    extends State<InlineCharacteristicDetails> {
  late final BleNotificationCubit _notificationCubit;
  bool _isSubscribed = false;

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
    _isSubscribed = true;
  }

  @override
  void dispose() {
    _notificationCubit.unsubscribe();
    _notificationCubit.close();
    super.dispose();
  }

  void _toggleSubscription() {
    setState(() {
      if (_isSubscribed) {
        _notificationCubit.unsubscribe();
        _isSubscribed = false;
      } else {
        _notificationCubit.subscribeToCharacteristic(widget.characteristic);
        _isSubscribed = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isReadable && !widget.isNotifiable) return SizedBox.shrink();
    return BlocBuilder<BleNotificationCubit, List<int>>(
      bloc: _notificationCubit,
      builder: (context, data) {
        final hexValue = data.isEmpty
            ? ''
            : data
                  .map((e) => e.toRadixString(16).padLeft(2, '0'))
                  .join(' ')
                  .toUpperCase();

        return Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 4),
            Text(
              'Value: ',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
            ),
            Text(
              hexValue,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            ),
            Spacer(),
            if (widget.isReadable)
              IconButton(
                tooltip: 'Read initial value',
                icon: const Icon(Icons.download),
                onPressed: () {
                  _notificationCubit.readInitialValue(widget.characteristic);
                },
              ),
            if (widget.isNotifiable)
              IconButton(
                tooltip: _isSubscribed ? 'Unsubscribe' : 'Subscribe',
                icon: Icon(
                  _isSubscribed
                      ? Icons.notifications_active
                      : Icons.notifications_off,
                ),
                color: _isSubscribed ? Colors.blue : Colors.grey,
                onPressed: _toggleSubscription,
              ),
          ],
        );
      },
    );
  }
}
