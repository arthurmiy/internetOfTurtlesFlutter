import 'package:flutter_blue/flutter_blue.dart';
import 'package:internetofturtles/type_classes/characterdata.dart';

class ServiceData {
  final BluetoothService service;
  final List<CharacteristicData> characteristics=[];
 ServiceData (this.service);

  void addCharacteristics(CharacteristicData characteristic) {
    characteristics.add(characteristic);
  }



}