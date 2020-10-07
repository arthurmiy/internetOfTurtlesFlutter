import 'dart:math';

import 'package:flutter/material.dart';
import 'package:internetofturtles/scripts/blemanager.dart';
import 'package:internetofturtles/threed/object3d.dart';
import 'package:internetofturtles/type_classes/device_data.dart';

class ThreeDScreen extends StatefulWidget {
  static const String rout = '/threedScreen';

  @override
  _ThreeDScreenState createState() => _ThreeDScreenState();
}

class _ThreeDScreenState extends State<ThreeDScreen> {
  double angleX = 0;
  double angleY = 0;
  double angleZ = 0;

  double ax = 0;
  double ay = 0;
  double az = 0;

  bool reading = false;
  bool monitoring = false;
  bool started = false;
  bool shouldRefresh = false;

  @override
  void initState() {
    monitoring = false;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (!monitoring) {
      monitorCharacteristics();
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Orientação'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          OutlineButton(
            child: (started) ? Text('Parar') : Text('Iniciar'),
            onPressed: (started)
                ? () {
                    setState(() {
                      started = false;
                    });
                  }
                : () {
                    setState(() {
                      started = true;
                    });
                    refreshGraphPrior();
                  },
          ),
          Expanded(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.only(right: 100.0),
                child: Object3D(
                  angleX,
                  angleY,
                  angleZ,
                  false,
                  size: Size(200.0, 200.0),
                  zoom: 60, //60.0,
                  path: "assets/tt.obj",
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> refreshGraphPrior() async {
    setState(() {
      reading = true;
    });

//    try {
    await BleManager()
        .deviceData
        .services[2]
        .characteristics[4]
        .characteristic
        .write([0x03]);
    //await Future.delayed(Duration(milliseconds: 500), () => {});
//    } catch (err) {
//      print('err $err');
//    }
    //counter4Refresh = 0;
    print("okkkkk");
    if (shouldRefresh) {
      setState(() {});
      update3DModel();
      shouldRefresh = false;
    }

    reading = false;

    if (started) {
      await Future.delayed(
          Duration(milliseconds: 10), () => refreshGraphPrior());
    }
  }

  void refreshChar1(List<int> value) {
    int val = value[1] * 256 * 256 + value[2] * 256 + value[3];
    ax = (val <= 32767)
        ? (0.00006135 * (val))
        : (0.00006135 * (val - 2 * 32768));
    shouldRefresh = true;
  }

  void refreshChar2(List<int> value) {
    int val = value[1] * 256 * 256 + value[2] * 256 + value[3];
    ay = (val <= 32767)
        ? (0.00006135 * (val))
        : (0.00006135 * (val - 2 * 32768));
    shouldRefresh = true;
  }

  void refreshChar3(List<int> value) {
    int val = value[1] * 256 * 256 + value[2] * 256 + value[3];
    az = (val <= 32767)
        ? (0.00006135 * (val))
        : (0.00006135 * (val - 2 * 32768));
    shouldRefresh = true;
  }

  Future<void> monitorCharacteristics() async {
    monitoring = true;
    try {
      await BleManager()
          .deviceData
          .services[2]
          .characteristics[0]
          .characteristic
          .setNotifyValue(true);
      BleManager()
          .deviceData
          .services[2]
          .characteristics[0]
          .characteristic
          .value
          .listen((value) {
        refreshChar1(value);
      });
    } catch (err) {
      print(err);
      try {
        await BleManager()
            .deviceData
            .services[2]
            .characteristics[0]
            .characteristic
            .setNotifyValue(false);
        monitoring = false;
      } catch (err) {}
    }

    try {
      await BleManager()
          .deviceData
          .services[2]
          .characteristics[1]
          .characteristic
          .setNotifyValue(true);
      BleManager()
          .deviceData
          .services[2]
          .characteristics[1]
          .characteristic
          .value
          .listen((value) {
        refreshChar2(value);
      });
    } catch (err) {
      print(err);
      try {
        await BleManager()
            .deviceData
            .services[2]
            .characteristics[1]
            .characteristic
            .setNotifyValue(false);
        monitoring = false;
      } catch (err) {}
    }

    try {
      await BleManager()
          .deviceData
          .services[2]
          .characteristics[2]
          .characteristic
          .setNotifyValue(true);
      BleManager()
          .deviceData
          .services[2]
          .characteristics[2]
          .characteristic
          .value
          .listen((value) {
        refreshChar3(value);
      });
    } catch (err) {
      print(err);
      try {
        await BleManager()
            .deviceData
            .services[2]
            .characteristics[2]
            .characteristic
            .setNotifyValue(false);
        monitoring = false;
      } catch (err) {}
    }
  }

  void update3DModel() {
    double taz = (ax * 100).floor() / 100;
    double tax = (ay * 100).floor() / 100;
    double tay = (az * 100).floor() / 100;

    double module = sqrt(tax * tax + tay * tay + taz * taz);
    if ((module - 1).abs() < 0.1) {
      if (tax.abs() + tay.abs() < 0.1) {
        setState(() {
          angleZ = 0;
        });
      } else {
        setState(() {
          angleZ = (asin(taz / module)) * 180 / pi;
          angleX = (asin(tax / module)) * 180 / pi;
        });
      }
      if (tay < 0) {
        setState(() {
          angleZ = -angleZ;
          angleX = 180 - angleX;
        });
      }
    }
  }
}
