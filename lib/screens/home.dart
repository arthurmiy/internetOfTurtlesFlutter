import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:internetofturtles/screens/about.dart';
import 'package:internetofturtles/screens/config.dart';
import 'package:internetofturtles/screens/loadingscreen.dart';
import 'package:internetofturtles/scripts/blemanager.dart';
import 'package:internetofturtles/type_classes/device.dart';

class Home extends StatefulWidget {
  static const String rout = '/';
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<Widget> deviceList = [];
  StreamSubscription<List<ScanResult>> subscription;

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    FlutterBlue flutterBlue = FlutterBlue.instance;

    return Scaffold(
      appBar: AppBar(
        title: Text('Internet of Turtles'),
        actions: <Widget>[
          PopupMenuButton(
            icon: Icon(Icons.menu),
            itemBuilder: (context) => [
              PopupMenuItem(
                child: Text('Configurações'),
                value: 1,
              ),
              PopupMenuItem(
                child: Text('Sobre'),
                value: 2,
              ),
            ],
            onSelected: (a) {
              if (a == 1) {
                //config
                Navigator.pushNamed(context, ConfigurationPage.rout);
              } else if (a == 2) {
                //sobre
                Navigator.pushNamed(context, AboutScreen.rout);
              }
            },
          )
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(30.0),
            child: Image.asset('images/logo.png'),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: deviceList,
              ),
            ),
          ),
          Row(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Icon(
                  Icons.bluetooth,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: OutlineButton(
                    child: Text('Procurar Dispositivo'),
                    onPressed: () {
                      BluetoothFunction(flutterBlue);
                    },
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  Future<void> BluetoothFunction(FlutterBlue flutterBlue) async {
    List<BluetoothDevice> conList = await flutterBlue.connectedDevices;

    for (BluetoothDevice dev in conList) {
      dev.disconnect();
    }

    BleManager().dispose();

    flutterBlue.startScan(timeout: Duration(seconds: 4));

    if (subscription != null) {
      subscription.cancel();
      subscription = null;
    }
    // Listen to scan results
    subscription = flutterBlue.scanResults.listen((scanResult) {
      // do something with scan result
      deviceList = [];
      deviceList.add(Divider());
      for (ScanResult result in scanResult) {
        var device = result.device;
        print('${device.name} found! rssi: ${result.rssi}');

        if (device.name.length > 0 && device.type == BluetoothDeviceType.le) {
          deviceList.add(Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: FlatButton(
                  child: Text(device.name),
                  onPressed: () {
                    Navigator.pushNamed(context, LoadingScreen.rout,
                        arguments: DeviceData(device));
                  },
                ),
              ),
              Divider(),
            ],
          ));
        }
      }
      setState(() {});
    });

    // Stop scanning
    flutterBlue.stopScan();
  }
}
