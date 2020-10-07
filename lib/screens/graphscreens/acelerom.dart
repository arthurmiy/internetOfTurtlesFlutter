import 'dart:async';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:internetofturtles/type_classes/device_data.dart';
import 'package:internetofturtles/ui_components/gaph_area.dart';
import 'package:internetofturtles/ui_components/graph_data_line.dart';
import 'package:internetofturtles/ui_components/sensordataicon.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

class Accelerometer extends StatefulWidget {
  static const String rout = '/acc';
  @override
  _AccelerometerState createState() => _AccelerometerState();
}

class _AccelerometerState extends State<Accelerometer> {
  BleDevice deviceData;

  bool monitoring = false;
  bool loopActivated = true;

  //always the same

  int mode = 2;

  bool timerOn = false;

  int totalTime = -1;
  Duration timeStep = Duration(seconds: 1);
  int timeCounter = 0;
  double timePercent = 0;

  bool LEDon = false;

  int temperature = 0;
  int moisture = 0;
  int pressure = 0;
  int brightness = 0;
  int uvLevel = 0;
  bool reading = false;

  int graphXMaxValue = 1;
  int graphXMinValue = 0;
  int graphXLabelStep = 1;
  int graphYMaxValue = 1;
  int graphYMinValue = 0;
  int graphYLabelStep = 1;

  int graphXMaxValue2 = 1;
  int graphXMinValue2 = 0;
  int graphXLabelStep2 = 1;
  int graphYMaxValue2 = 1;
  int graphYMinValue2 = 0;
  int graphYLabelStep2 = 1;

  int graphXMaxValue3 = 1;
  int graphXMinValue3 = 0;
  int graphXLabelStep3 = 1;
  int graphYMaxValue3 = 1;
  int graphYMinValue3 = 0;
  int graphYLabelStep3 = 1;

  List<FlSpot> graphAccelDataX = [FlSpot(0, 0)];
  List<FlSpot> graphMagDataX = [FlSpot(0, 0)];
  List<FlSpot> graphGyrDataX = [FlSpot(0, 0)];

  List<FlSpot> graphAccelDataY = [FlSpot(0, 0)];
  List<FlSpot> graphMagDataY = [FlSpot(0, 0)];
  List<FlSpot> graphGyrDataY = [FlSpot(0, 0)];

  List<FlSpot> graphAccelDataZ = [FlSpot(0, 0)];
  List<FlSpot> graphMagDataZ = [FlSpot(0, 0)];
  List<FlSpot> graphGyrDataZ = [FlSpot(0, 0)];

  int initialTime;

  Future<void> Wait2Refresh() async {
    await Future.delayed(Duration(seconds: 2), () {});
    refreshAll();
  }

  @override
  void initState() {
    initialTime = DateTime.now().millisecondsSinceEpoch;
  }

  @override
  Widget build(BuildContext context) {
    if (!monitoring) {
      monitorCharacteristics();
    }
    deviceData = ModalRoute.of(context).settings.arguments;

    Widget img = Container();
    int counter = 1;

    //2 cases: simple and complete layout
    Wait2Refresh();

    if (deviceData.services[2].characteristics.length > 0) {
      //todo correct length
      //Complete Layout
      return Scaffold(
          appBar: AppBar(
            title: Text('Acelerômetro'),
          ),
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: AspectRatio(
                    aspectRatio: 0.6,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius:
                            const BorderRadius.all(Radius.circular(18)),
                        gradient: LinearGradient(
                          colors: [
                            Color(Theme.of(context)
                                .colorScheme
                                .primaryVariant
                                .value),
                            Color(Theme.of(context)
                                .colorScheme
                                .secondaryVariant
                                .value),
                          ],
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                        ),
                      ),
                      child: Stack(
                        children: <Widget>[
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: <Widget>[
                              const SizedBox(
                                height: 10,
                              ),
                              const SizedBox(
                                height: 37,
                              ),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                      right: 16.0, left: 6.0),
                                  child: LineChart(getChartArea(
                                      Colors.white,
                                      graphXLabelStep,
                                      graphYLabelStep,
                                      graphXMaxValue,
                                      graphXMinValue,
                                      graphYMaxValue,
                                      graphYMinValue,
                                      getlinesForChart(graphAccelDataX,
                                          graphAccelDataY, graphAccelDataZ),
                                      1)),
                                ),
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ));
    } else {
      //simple Layout
      return Scaffold(
        appBar: AppBar(
          title: Text(deviceData.device.name),
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 60),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              img,
              Column(
                children: <Widget>[],
              ),
            ],
          ),
        ),
      );
    }
  }

  void refreshChar1(List<int> value) {
    FlSpot tmp = getNewData(value[0], graphAccelDataX.last.x.toInt(),
        graphXMaxValue, graphYMaxValue, graphXLabelStep, graphYLabelStep, mode);
    if (tmp != null) {
      graphAccelDataX.add(tmp);
    }

    //setState(() {});
    // mode1++;
  }

  void refreshChar2(List<int> value) {
    FlSpot tmp = getNewData(value[0], graphAccelDataY.last.x.toInt(),
        graphXMaxValue, graphYMaxValue, graphXLabelStep, graphYLabelStep, mode);
    if (tmp != null) {
      graphAccelDataY.add(tmp);
    }

    //setState(() {});
  }

  void refreshChar3(List<int> value) {
    FlSpot tmp = getNewData(value[0], graphAccelDataZ.last.x.toInt(),
        graphXMaxValue, graphYMaxValue, graphXLabelStep, graphYLabelStep, mode);
    if (tmp != null) {
      graphAccelDataZ.add(tmp);
    }
  }

  FlSpot getNewData(int value, int lastX, int xmax, int ymax, int xstep,
      int ystep, int mode) {
    if (value > 0) {
      //acc

      FlSpot tmp = FlSpot(
          (DateTime.now().millisecondsSinceEpoch - initialTime) / 1000,
          value.toDouble());
      refreshLabelLimits(value, xmax, ymax, xstep, ystep, mode);
      return tmp;
    }
    return null;
  }

  Future<void> refreshLabelLimits(
      int value, int xmax, int ymax, int xstep, int ystep, int _mode) async {
    int graphXMaxValueN = xmax;
    int graphXLabelStepN = xstep;
    int graphYMaxValueN = ymax;
    int graphYLabelStepN = ystep;

    if (value > graphYMaxValueN) {
      graphYMaxValueN = value;
    }
    graphXMaxValueN =
        (DateTime.now().millisecondsSinceEpoch - initialTime) ~/ 1000;
    if (graphXMaxValueN > 10 * graphXLabelStepN) {
      graphXLabelStepN = (graphXMaxValueN ~/ 5);
      graphXLabelStepN = graphXLabelStepN ~/ 1000;
      if (graphXLabelStepN > 0) {
        graphXLabelStepN = graphXLabelStepN * 1000;
      } else {
        graphXLabelStepN = 1000;
      }
    }
    if (graphYMaxValueN > 10 * graphYLabelStepN) {
      graphYLabelStepN = graphYMaxValueN ~/ 5;
      if (graphYLabelStepN == 0) {
        graphYLabelStepN = 1;
      }
    }

    graphXMaxValue = graphXMaxValueN;
    graphXLabelStep = graphXLabelStepN;
    graphYMaxValue = graphYMaxValueN;
    graphYLabelStep = graphYLabelStepN;
  }

  Future<void> refreshAll() async {
    setState(() {
      reading = true;
    });

    await deviceData.services[2].characteristics[4].characteristic
        .write([0x03]);

    if (loopActivated) {
      setState(() {});
      refreshAll();
    }
  }

  Future<void> monitorCharacteristics() async {
    await deviceData.services[2].characteristics[0].characteristic
        .setNotifyValue(true);
    deviceData.services[2].characteristics[0].characteristic.value
        .listen((value) {
      refreshChar1(value);
    });

    await deviceData.services[2].characteristics[1].characteristic
        .setNotifyValue(true);
    deviceData.services[2].characteristics[1].characteristic.value
        .listen((value) {
      refreshChar2(value);
    });

    await deviceData.services[2].characteristics[2].characteristic
        .setNotifyValue(true);
    deviceData.services[2].characteristics[2].characteristic.value
        .listen((value) {
      refreshChar3(value);
    });
  }
}
