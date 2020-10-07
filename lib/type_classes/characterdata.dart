import 'package:flutter_blue/flutter_blue.dart';

class CharacteristicData {
  final BluetoothCharacteristic characteristic;
  final List<List<int>> data = [];
  CharacteristicData(this.characteristic);

  void addData(List<int> characteristic) {
    data.add(characteristic);
  }
}
