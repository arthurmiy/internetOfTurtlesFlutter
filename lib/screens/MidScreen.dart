import 'package:flutter/material.dart';
import 'package:internetofturtles/screens/GraphPage.dart';
import 'package:internetofturtles/screens/infopulga.dart';
import 'package:internetofturtles/screens/threedorientationscreen.dart';
import 'package:internetofturtles/type_classes/device_data.dart';

class MidScreen extends StatelessWidget {
  static const String rout = '/midScreen';

  BleDevice deviceData;

  @override
  Widget build(BuildContext context) {
    deviceData = ModalRoute.of(context).settings.arguments as BleDevice;
    return Scaffold(
      appBar: AppBar(
        title: Text('Navegar'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            OutlineButton(
                child: Text('Tela de dados'),
                onPressed: () {

                  Navigator.pushNamed(context, InfoPulga.rout);
                }),
            OutlineButton(
                child: Text('Tela de gráfico'),
                onPressed: () {
                  Navigator.pushNamed(context, GraphPage.rout);
                }),
            OutlineButton(
                child: Text('Tela de orientação 3D'),
                onPressed: () {
                  Navigator.pushNamed(context, ThreeDScreen.rout);
                }),
          ],
        ),
      ),
    );
  }
}
