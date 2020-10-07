import 'package:async_loader/async_loader.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:internetofturtles/type_classes/characterdata.dart';
import 'package:internetofturtles/type_classes/device.dart';
import 'package:internetofturtles/type_classes/service_data.dart';
import 'package:internetofturtles/ui_components/sensordatawithlabel.dart';

class InfoPage extends StatefulWidget {
  static const String rout = '/infos';
  @override
  _InfoPageState createState() => _InfoPageState();
}

class _InfoPageState extends State<InfoPage> {
  GlobalKey<AsyncLoaderState> _asyncLoaderState =
      new GlobalKey<AsyncLoaderState>();

  DeviceData deviceData;

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
          initState: () async => await getDeviceServices(args.device),
          renderLoad: () => Center(child: CircularProgressIndicator()),
          renderError: ([error]) =>
              Center(child: Text("Erro ao carregar dados")),
          renderSuccess: ({data}) {
            bool LEDon;
            List<List<int>> temp = data as List<List<int>>;
            List<Widget> wdTmp = [];
            Widget img = Container();
            int counter = 0;
            int counter2 = 0;
            for (List<int> i in temp) {
              if (i.length > 0) {
                if (i[0] >= 0) {
                  if (counter == 3) {
                    //i[0] contains the data
                    if (counter2 == 0) {
                      counter2++;
                      //temperatura
                      wdTmp.add(SensorDataWithLabel(
                          FontAwesomeIcons.thermometerThreeQuarters,
                          'Umidade:',
                          '${i[0]} °C'));
                    } else if (counter2 == 1) {
                      counter2++;
                      //umidade
                      wdTmp.add(SensorDataWithLabel(
                          FontAwesomeIcons.tint, 'Temperatura:', '${i[0]} %'));
                    } else if (counter2 == 2) {
                      counter2++;
                      //outro
                      wdTmp.add(SensorDataWithLabel(
                          Icons.brightness_6, 'Luminosidade:', '${i[0]}'));
                    } else if (counter2 == 3) {
                      //led
                      if (i[0] == 0) {
                        img = Image.asset('images/off.png');
                        LEDon = false;
                      } else {
                        img = Image.asset('images/on.png');
                        LEDon = true;
                      }
                    }
                  }
                } else {
                  //wdTmp.add(Divider());
                  counter += 1;
                }
              }
            }
            wdTmp.add(Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Align(
                alignment: Alignment.centerRight,
                child: OutlineButton(
                  child: Text('LED'),
                  onPressed: () {
                    if (LEDon) {
                      LEDon = false;
                      print('falseta');
                      changeledStatus(true, args.device);
                      Future.delayed(Duration(seconds: 1, milliseconds: 500),
                          () => reload());
                      // reload();
//                      setState(() {
//                        img = Image.asset('images/off.png');
//                      });
                      //_asyncLoaderState = new GlobalKey<AsyncLoaderState>();
                    } else {
                      print('vdd');

                      LEDon = true;
                      changeledStatus(false, args.device);
                      Future.delayed(Duration(seconds: 1, milliseconds: 500),
                          () => reload());
                      //reload();
//                      setState(() {
//                        img = Image.asset('images/on.png');
//                      });
                      //_asyncLoaderState = new GlobalKey<AsyncLoaderState>();
                    }
                  },
                ),
              ),
            ));
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 60),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  img,
                  Column(
                    children: wdTmp,
                  ),
                ],
              ),
            );
          }),
    );
  }

  Future<List<List<int>>> getDeviceServices(BluetoothDevice device) async {
    try {
      await device.connect();
    } catch (e) {}
    List<List<int>> listFinal = [];
    List<BluetoothService> services = await device.discoverServices();
    for (BluetoothService serv in services) {
      listFinal.add([-1]);
      var characteristics = serv.characteristics;
      for (BluetoothCharacteristic c in characteristics) {
        if (c.properties.read) {
          List<int> value = await c.read();
//          if (value.length != 1) {
//            var descriptors = c.descriptors;
//            for (BluetoothDescriptor d in descriptors) {
//              List<int> val = await d.read();
//              print('conteudo: $val');
//            }
//          }
          listFinal.add(value);
          //print(value);
        }
      }
    }

    //await device.disconnect();
    return listFinal;
  }

  Future<void> RefreshBleData(BluetoothDevice device) async {
    try {
      await device.connect();
    } catch (e) {}

    deviceData = DeviceData(device);

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
      }
    }
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

    // await device.disconnect();

    //
//    await device.connect();
//    if (cLED != null) {
//      if (value) {
//        cLED.write([0x00]);
//      } else {
//        cLED.write([0x01]);
//      }
//    }
//    await device.disconnect();
  }

//  void disconnectAll() async {
//    List<BluetoothDevice> tmpList;
//    tmpList = await FlutterBlue.instance.connectedDevices;
//    for (BluetoothDevice el in tmpList) {
//      el.disconnect();
//    }
//  }
//
//  @override
//  void dispose() {
//    disconnectAll();
//  }
}
