import 'package:flutter_blue/flutter_blue.dart';

class DeviceData {
  final BluetoothDevice _device;
  DeviceData(this._device);
  BluetoothDevice get device => _device;


}
