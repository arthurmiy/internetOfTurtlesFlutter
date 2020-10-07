import 'package:async_loader/async_loader.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:internetofturtles/screens/GraphPage.dart';
import 'package:internetofturtles/screens/MidScreen.dart';
import 'package:internetofturtles/screens/threedorientationscreen.dart';
import 'package:internetofturtles/scripts/blemanager.dart';
import 'package:internetofturtles/scripts/sharedPrefFunctions.dart';

import 'package:internetofturtles/type_classes/characterdata.dart';
import 'package:internetofturtles/type_classes/device.dart';
import 'package:internetofturtles/type_classes/device_data.dart';
import 'package:internetofturtles/type_classes/service_data.dart';

import 'infopulga.dart';

class LoadingScreen extends StatefulWidget {
  static const String rout = '/loading';
  @override
  _LoadingScreenState createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  int screenDestination = 0;
  String screenMsg = "Verificando conexão";

  GlobalKey<AsyncLoaderState> _asyncLoaderState =
      new GlobalKey<AsyncLoaderState>();

  BleDevice deviceData;

  reload() {
    _asyncLoaderState.currentState.reloadState();
  }

  @override
  Widget build(BuildContext context) {
    final DeviceData args = ModalRoute.of(context).settings.arguments;

    if (BleManager().hasData()) {
      alreadyConnectedAction();
      return Scaffold(
          appBar: AppBar(
            title: Text(args.device.name),
          ),
          body: Center(
            child: Text(screenMsg),
          ));
    }

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
            BleDevice temp = data as BleDevice;
            if (screenDestination == 0) {
              //tela de dados
              Future.delayed(
                  Duration(milliseconds: 300),
                  () => Navigator.popAndPushNamed(context, InfoPulga.rout,
                      arguments: temp));
            } else if (screenDestination == 1) {
              //tela de gráficos
              Future.delayed(
                  Duration(milliseconds: 300),
                  () => Navigator.popAndPushNamed(context, GraphPage.rout,
                      arguments: temp));
            } else if (screenDestination == 2) {
              //orientação 3d
              Future.delayed(
                  Duration(milliseconds: 300),
                  () => Navigator.popAndPushNamed(context, ThreeDScreen.rout,
                      arguments: temp));
            } else if (screenDestination == 3) {
              //menu de seleção
              Future.delayed(
                  Duration(milliseconds: 300),
                  () => Navigator.popAndPushNamed(context, MidScreen.rout,
                      arguments: temp));
            }

            return Container();
          }),
    );
  }

  Future<BleDevice> refreshBleData(BluetoothDevice device) async {
    try {
      await device.connect();
    } catch (e) {
      setState(() {
        screenMsg = 'Problema de conexão';
        BleManager().dispose();
      });
    }

    try {
      screenDestination = await retrieveDefaultScreen(DEFAULT_SCREEN_SP_ROUT);
    } catch (e) {
      screenDestination = 0;
    }

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

    BleManager().deviceData = deviceData;
    return deviceData;
  }

  Future<void> alreadyConnectedAction() async {
    try {
      await BleManager()
          .deviceData
          .services[2]
          .characteristics[4]
          .characteristic
          .write([0x01], withoutResponse: true);
    } catch (err) {
      print(err.toString());
      setState(() {
        screenMsg = 'Problema de conexão';
        BleManager().dispose();
      });
      return;
    }

    try {
      screenDestination = await retrieveDefaultScreen(DEFAULT_SCREEN_SP_ROUT);
    } catch (e) {}

    if (screenDestination == 0) {
      //tela de dados
      Future.delayed(Duration(milliseconds: 300),
          () => Navigator.popAndPushNamed(context, InfoPulga.rout));
    } else if (screenDestination == 1) {
      //tela de gráficos
      Future.delayed(Duration(milliseconds: 300),
          () => Navigator.popAndPushNamed(context, GraphPage.rout));
    } else if (screenDestination == 2) {
      //orientação 3d
      Future.delayed(Duration(milliseconds: 300),
          () => Navigator.popAndPushNamed(context, ThreeDScreen.rout));
    } else if (screenDestination == 3) {
      //menu de seleção
      Future.delayed(Duration(milliseconds: 300),
          () => Navigator.popAndPushNamed(context, MidScreen.rout));
    }
  }
}
