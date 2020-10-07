import 'package:flutter/material.dart';
import 'package:internetofturtles/type_classes/device_data.dart';

class BleManager {
  static BleManager _instance;
  BleDevice deviceData;

  factory BleManager() {
    _instance ??= BleManager._create();
    return _instance;
  }

  bool hasData() => (deviceData != null);

  BleManager._create();

  void dispose() {
    _instance = null;
  }

  Future<void> reconect() async {
    if (deviceData != null) {
      deviceData.device.disconnect();
      await deviceData.device.connect();
    }
  }
}
