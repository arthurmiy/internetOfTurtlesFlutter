import 'package:flutter_blue/flutter_blue.dart';
import 'package:internetofturtles/type_classes/service_data.dart';

class BleDevice {
  final BluetoothDevice device;
  final List<ServiceData> services=[];
  BleDevice (this.device);

  void addService(ServiceData service) {
    services.add(service);
  }



}