import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:internetofturtles/Debug_and_tests/info.dart';
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
                      flutterBlue.startScan(timeout: Duration(seconds: 4));

                      if (subscription != null) {
                        subscription.cancel();
                        subscription = null;
                      }
                      // Listen to scan results
                      subscription =
                          flutterBlue.scanResults.listen((scanResult) {
                        // do something with scan result
                        deviceList = [];
                        deviceList.add(Divider());
                        for (ScanResult result in scanResult) {
                          var device = result.device;
                          print('${device.name} found! rssi: ${result.rssi}');

                          if (device.name.length > 0 &&
                              device.type == BluetoothDeviceType.le) {
                            deviceList.add(Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: <Widget>[
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8.0),
                                  child: FlatButton(
                                    child: Text(device.name),
                                    onPressed: () {
                                      Navigator.pushNamed(
                                          context, InfoPage.rout,
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
}
