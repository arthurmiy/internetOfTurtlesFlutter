import 'package:async_loader/async_loader.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:internetofturtles/type_classes/characterdata.dart';
import 'package:internetofturtles/type_classes/device.dart';
import 'package:internetofturtles/type_classes/device_data.dart';
import 'package:internetofturtles/type_classes/service_data.dart';
import 'package:internetofturtles/ui_components/sensordatawithlabel.dart';

class InfoPage extends StatefulWidget {
  static const String rout = '/info';
  @override
  _InfoPageState createState() => _InfoPageState();
}

class _InfoPageState extends State<InfoPage> {
  GlobalKey<AsyncLoaderState> _asyncLoaderState =
      new GlobalKey<AsyncLoaderState>();

  String testeLabel;

  BleDevice deviceData;

  reload() {
    _asyncLoaderState.currentState.reloadState();
  }

  @override
  Widget build(BuildContext context) {
    final DeviceData args = ModalRoute.of(context).settings.arguments;

    return Scaffold(
      appBar: AppBar(
        title: Text(args.device.name),
      ),
      body: AsyncLoader(
          key: _asyncLoaderState,
          initState: () async => await refreshBleData(args.device),
          renderLoad: () => Center(child: CircularProgressIndicator()),
          renderError: ([error]) =>
              Center(child: Text("Erro ao carregar dados")),
          renderSuccess: ({data}) {
            bool LEDon;
            BleDevice temp = data as BleDevice;
            List<Widget> wdTmp = [];
            Widget img = Container();

            int counter = 1;
            for (CharacteristicData cd in temp.services[2].characteristics) {
              if (cd.data.length > 0) {
                if (deviceData.device.name.toUpperCase().contains('PULG')) {
                  if (counter <= 3) {
                    wdTmp.add(SensorDataWithLabel(
                        FontAwesomeIcons.squareFull,
                        getLabels4Pulga(counter),
                        formatData4Pulga(counter, cd.data[0])));
                    counter++;
                  } else {
                    testeLabel = getLabels4Pulga(counter);
                    wdTmp.add(SensorDataWithLabel(FontAwesomeIcons.squareFull,
                        testeLabel, formatData4Pulga(counter, cd.data[0])));
                    counter++;
                  }
                } else {
                  wdTmp.add(SensorDataWithLabel(FontAwesomeIcons.squareFull,
                      counter.toString(), cd.data.toString()));
                  counter++;
                }
              }
            }

            wdTmp.add(RaisedButton(
              child: Text('ddddd'),
              onPressed: () {
                setState(() {
                  testeLabel = "working";
                  print('test');
                });
              },
            ));
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 60),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Column(
                    children: wdTmp,
                  ),
                ],
              ),
            );
          }),
    );
  }

  Future<BleDevice> refreshBleData(BluetoothDevice device) async {
    try {
      await device.connect();
    } catch (e) {}

    deviceData = BleDevice(device);

    List<BluetoothService> services = await device.discoverServices();
    for (BluetoothService serv in services) {
      ServiceData tmpServ = ServiceData(serv);
      var characteristics = serv.characteristics;
      for (BluetoothCharacteristic c in characteristics) {
        CharacteristicData tmpChar = CharacteristicData(c);
        if (c.properties.read) {
          List<int> value = await c.read();
          tmpChar.addData(value);
        }
        tmpServ.addCharacteristics(tmpChar);
      }
      deviceData.addService(tmpServ);
    }

    return deviceData;
  }

  void changeledStatus(bool valueB, BluetoothDevice device) async {
    //ait device.disconnect();
    // await device.connect();
    int counter = 0;
    List<List<int>> listFinal = [];
    List<BluetoothService> services = await device.discoverServices();
    for (BluetoothService serv in services) {
      listFinal.add([-1]);
      counter++;
      var characteristics = serv.characteristics;
      for (BluetoothCharacteristic c in characteristics) {
        if (c.properties.read) {
          List<int> value = await c.read();
          if (value.length == 1 && counter == 3) {
            if (valueB) {
              await c.write([0x00]);
              print('aquiiiii');
            } else {
              await c.write([0x01]);
              print('aquiiiii2');
            }
          }
          listFinal.add(value);
          print(value);
        }
      }
    }
  }

  String getLabels4Pulga(int index, {int current_case = 0}) {
    String answer = index.toString();
    if (current_case == 0) {
      //luminosidade, umidade e temperatura
      if (index == 1) {
        answer = 'Temperatura: ';
      }
      if (index == 2) {
        answer = 'Umidade: ';
      }
      if (index == 3) {
        answer = 'Luminosidade: ';
      }
    }
    return answer;
  }

  String formatData4Pulga(int index, List<int> data, {int current_case = 0}) {
    String answer = index.toString();
    if (current_case == 0) {
      //luminosidade, umidade e temperatura
      if (index == 1) {
        answer = '${data[0]} °C';
      }
      if (index == 2) {
        answer = '${data[0]} %';
      }
      if (index == 3) {
        answer = '${data[0]}';
      }
    }
    return answer;
  }
}
