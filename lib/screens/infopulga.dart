import 'dart:async';

import 'dart:math';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:internetofturtles/scripts/blemanager.dart';
import 'package:internetofturtles/scripts/constants.dart';
import 'package:internetofturtles/threed/object3d.dart';
import 'package:internetofturtles/type_classes/characterdata.dart';
import 'package:internetofturtles/type_classes/device_data.dart';
import 'package:internetofturtles/type_classes/pulga.dart';
import 'package:internetofturtles/type_classes/service_data.dart';
import 'package:internetofturtles/ui_components/gaph_area.dart';
import 'package:internetofturtles/ui_components/graph_data_line.dart';
import 'package:internetofturtles/ui_components/sensordataicon.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

class InfoPulga extends StatefulWidget {
  static const String rout = '/info_pulga';
  @override
  _InfoPulgaState createState() => _InfoPulgaState();
}

class _InfoPulgaState extends State<InfoPulga> {
  //Controle de gráfico
  bool showAccelerometer;
  bool showMagnet;
  bool showGyro;

  //Controle de monitoramento e atualização do ble
  bool monitoring = false;
  bool loopActivated = false;
  bool timerOn = false;

  int totalTime = -1;
  Duration timeStep = Duration(milliseconds: 100);
  int timeCounter = 0;
  double timePercent = 0;

  bool ledOn = false;

  int counter4Refresh = 0;

  Pulga pulga = Pulga();

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

  List<int> oldValue = [];
  int oldTime = 0;

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

  String dropdownValue = opt1Manual;

  double angleX = 0;
  double angleY = 0;
  double angleZ = 0;

  @override
  void initState() {
    super.initState();
    showAccelerometer = true;
    showGyro = false;
    showMagnet = false;
    initialTime = DateTime.now().millisecondsSinceEpoch;
  }

  void chooseGraph(int graphIndex) {
    if (graphIndex == 0) {
      showAccelerometer = true;
      showMagnet = false;
      showGyro = false;
    } else if (graphIndex == 2) {
      showAccelerometer = false;
      showMagnet = true;
      showGyro = false;
    } else {
      showAccelerometer = false;
      showMagnet = false;
      showGyro = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!monitoring) {
      monitorCharacteristics();
    }

    Widget img = Container();

    //2 cases: simple and complete layout

    if (BleManager().deviceData.services[2].characteristics.length > 0) {
      //todo correct length
      //Complete Layout
      return Scaffold(
        appBar: AppBar(
          title: Text(BleManager().deviceData.device.name),
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              LinearPercentIndicator(
                percent: timePercent,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 8.0, top: 8),
                child: Text(
                  'Atualizar:',
                  style: Theme.of(context)
                      .textTheme
                      .title
                      .copyWith(color: Theme.of(context).accentColor),
                ),
              ),
              Row(
                children: <Widget>[
                  SizedBox(
                    width: 10,
                  ),
                  Expanded(
                    child: DropdownButton<String>(
                      isExpanded: true,
                      value: dropdownValue,
                      onChanged: (String newValue) {
                        setState(() {
                          dropdownValue = newValue;
                          if (newValue == opt1Manual) {
                            loopActivated = false;
                            totalTime = -1;
                            timeCounter = 0;
                            timePercent = 0;
                          } else if (newValue == opt2fastest) {
                            totalTime = -1;
                            timeCounter = 0;
                            timePercent = 0;
                            loopActivated = true;
                            refreshGraphPrior();
                          } else if (newValue == opt3each15s) {
                            loopActivated = false;
                            totalTime = 15;
                            timeCounter = 0;
                            timePercent = 0;
                            if (!timerOn) {
                              timerCounter();
                            }
                          } else if (newValue == opt4each1m) {
                            loopActivated = false;
                            totalTime = 60;
                            timeCounter = 0;
                            timePercent = 0;
                            if (!timerOn) {
                              timerCounter();
                            }
                          } else if (newValue == opt5each5m) {
                            loopActivated = false;
                            totalTime = 300;
                            timeCounter = 0;
                            timePercent = 0;
                            if (!timerOn) {
                              timerCounter();
                            }
                          }
                        });
                      },
                      hint: Text('Atualizar:'),
                      disabledHint: Text('Atualizar:'),
                      items: <String>[
                        opt1Manual,
                        opt2fastest,
                        opt3each15s,
                        opt4each1m,
                        opt5each5m,
                      ].map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),
                  ),
                  (dropdownValue == 'Manualmente')
                      ? IconButton(
                          icon: (reading)
                              ? CircularProgressIndicator()
                              : Icon(
                                  Icons.refresh,
                                ),
                          onPressed: (reading)
                              ? null
                              : () {
                                  refreshAll();
                                },
                        )
                      : Container(),
                  SizedBox(
                    width: 10,
                  ),
                ],
              ),
              Column(
                children: <Widget>[
                  SizedBox(
                    height: 10,
                  ),
                  IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        IntrinsicWidth(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: <Widget>[
                              (pulga.voltage > 2760)
                                  ? SensorDataIcon(
                                      Icons.battery_full, '100%', 'Bateria')
                                  : (pulga.voltage < 2060)
                                      ? SensorDataIcon(
                                          Icons.battery_alert, '0%', 'Bateria')
                                      : SensorDataIcon(
                                          Icons.battery_full,
                                          '${((pulga.voltage - 2060) / 7).round()}%',
                                          'Tensão'),
                              SensorDataIcon(
                                  FontAwesomeIcons.solarPanel,
                                  '${(pulga.solar / 1000).toStringAsPrecision(2)} V',
                                  'Painel Solar'),
                              SensorDataIcon(
                                  FontAwesomeIcons.thermometerThreeQuarters,
                                  '${pulga.temperature} °C',
                                  'Temperatura'),
                              SensorDataIcon(FontAwesomeIcons.tint,
                                  '${pulga.moisture} %', 'Umidade'),
                              SensorDataIcon(FontAwesomeIcons.weight,
                                  '${pulga.pressure}', 'Pressão'),
                              SensorDataIcon(Icons.wb_incandescent,
                                  '${pulga.brightness}', 'Luminosidade'),
                              SensorDataIcon(Icons.wb_sunny, '${pulga.uvLevel}',
                                  'Nível UV'),
                              Padding(
                                padding: const EdgeInsets.only(left: 8.0),
                                child: OutlineButton(
                                  onPressed: () {
                                    setState(() {
                                      ledOn = !ledOn;
                                      BleManager()
                                          .deviceData
                                          .services[2]
                                          .characteristics[3]
                                          .characteristic
                                          .write((ledOn) ? [0x01] : [0x00]);
                                    });
                                  },
                                  child: Text('LED'),
                                ),
                              ),
                            ],
                          ),
                        ),
                        VerticalDivider(),
                        Expanded(
                          child: Object3D(
                            angleX,
                            angleY,
                            angleZ,
                            ledOn,
                            size: Size(200.0, 200.0),
                            zoom: 40, //60.0,
                            path: "assets/tt.obj",
                          ),
                        ),
                      ],
                    ),
                  ),
                  Divider(),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: AspectRatio(
                      aspectRatio: 1.1,
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
                                    child: LineChart(
                                      showAccelerometer
                                          ? getChartArea(
                                              Colors.white,
                                              graphXLabelStep,
                                              graphYLabelStep,
                                              graphXMaxValue,
                                              graphXMinValue,
                                              graphYMaxValue,
                                              graphYMinValue,
                                              getlinesForChart(
                                                  graphAccelDataX,
                                                  graphAccelDataY,
                                                  graphAccelDataZ),
                                              1)
                                          : showGyro
                                              ? getChartArea(
                                                  Colors.white,
                                                  graphXLabelStep2,
                                                  graphYLabelStep2,
                                                  graphXMaxValue2,
                                                  graphXMinValue2,
                                                  graphYMaxValue2,
                                                  graphYMinValue2,
                                                  getlinesForChart(
                                                      graphGyrDataX,
                                                      graphGyrDataY,
                                                      graphGyrDataZ),
                                                  2)
                                              : getChartArea(
                                                  Colors.white,
                                                  graphXLabelStep3,
                                                  graphYLabelStep3,
                                                  graphXMaxValue3,
                                                  graphXMinValue3,
                                                  graphYMaxValue3,
                                                  graphYMinValue3,
                                                  getlinesForChart(
                                                      graphMagDataX,
                                                      graphMagDataY,
                                                      graphMagDataZ),
                                                  3),
                                      swapAnimationDuration:
                                          Duration(milliseconds: 250),
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                              ],
                            ),
                            Row(
                              children: <Widget>[
                                IconButton(
                                  icon: Icon(
                                    FontAwesomeIcons.tachometerAlt,
                                    color: Colors.white.withOpacity(
                                        showAccelerometer ? 1.0 : 0.5),
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      chooseGraph(0);
                                    });
                                  },
                                ),
                                IconButton(
                                  icon: Icon(
                                    FontAwesomeIcons.magnet,
                                    color: Colors.white
                                        .withOpacity(showMagnet ? 1.0 : 0.5),
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      chooseGraph(2);
                                    });
                                  },
                                ),
                                IconButton(
                                  icon: Icon(
                                    FontAwesomeIcons.globe,
                                    color: Colors.white
                                        .withOpacity(showGyro ? 1.0 : 0.5),
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      chooseGraph(1);
                                    });
                                  },
                                ),
                                Expanded(
                                  child: FittedBox(
                                    child: Row(
                                      children: <Widget>[
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(right: 8.0),
                                          child: Text(
                                            showAccelerometer
                                                ? 'Acelerômetro'
                                                : showGyro
                                                    ? 'Giroscópio'
                                                    : 'Magnetômetro',
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 26,
                                                fontWeight: FontWeight.bold,
                                                letterSpacing: 2),
                                            textAlign: TextAlign.right,
                                          ),
                                        ),
                                        IconButton(
                                          icon: Icon(
                                            Icons.clear,
                                            color: Colors.white,
                                          ),
                                          onPressed: () {
//                                            Navigator.pushNamed(
//                                                context, Accelerometer.rout,
//                                                arguments: deviceData);
                                            initialTime = DateTime.now()
                                                .millisecondsSinceEpoch;
                                            if (showAccelerometer) {
                                              graphXLabelStep = 1;
                                              graphYLabelStep = 1;
                                              graphXMaxValue = 1;
                                              graphXMinValue = 0;
                                              graphYMaxValue = graphAccelDataX
                                                      .last.y
                                                      .toInt() +
                                                  1;
                                              graphYMinValue = graphAccelDataX
                                                      .last.y
                                                      .toInt() -
                                                  1;

                                              graphAccelDataX = [FlSpot(0, 0)];
                                              graphAccelDataY = [FlSpot(0, 0)];
                                              graphAccelDataZ = [FlSpot(0, 0)];

                                              setState(() {});
                                            } else if (showMagnet) {
                                              graphXLabelStep3 = 1;
                                              graphYLabelStep3 = 1;
                                              graphXMaxValue3 = 1;
                                              graphXMinValue3 = 0;
                                              graphYMaxValue3 =
                                                  graphMagDataX.last.y.toInt() +
                                                      1;
                                              graphYMinValue3 =
                                                  graphMagDataX.last.y.toInt() -
                                                      1;
                                              graphMagDataX = [FlSpot(0, 0)];
                                              graphMagDataY = [FlSpot(0, 0)];
                                              graphMagDataZ = [FlSpot(0, 0)];
                                              setState(() {});
                                            } else if (showGyro) {
                                              graphXLabelStep2 = 1;
                                              graphYLabelStep2 = 1;
                                              graphXMaxValue2 = 1;
                                              graphXMinValue2 = 0;
                                              graphYMaxValue2 =
                                                  graphGyrDataX.last.y.toInt() +
                                                      1;
                                              graphYMinValue2 =
                                                  graphGyrDataX.last.y.toInt() -
                                                      1;

                                              graphGyrDataX = [FlSpot(0, 0)];
                                              graphGyrDataY = [FlSpot(0, 0)];
                                              graphGyrDataZ = [FlSpot(0, 0)];
                                            }
                                          },
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    } else {
      //simple Layout
      return Scaffold(
        appBar: AppBar(
          title: Text(BleManager().deviceData.device.name),
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
    print('###############1  $value');
    int mode = value[0] - 1;
    if (mode == 0) {
      pulga.temperature = value[1] * 256 * 256 + value[2] * 256 + value[3];
      print('temperatura ${pulga.temperature}');
    } else if (mode == 1) {
      pulga.brightness = value[1] * 256 * 256 + value[2] * 256 + value[3];
      print('brilho ${pulga.brightness}');
    } else if (mode == 2) {
      int val = value[1] * 256 * 256 + value[2] * 256 + value[3];

      FlSpot tmp = getNewData(
          (val <= 32767)
              ? (0.00006135 * (val))
              : (0.00006135 * (val - 2 * 32768)),
          graphAccelDataX.last.x.toInt(),
          graphXMaxValue,
          graphYMaxValue,
          graphXLabelStep,
          graphYLabelStep,
          mode,
          graphYMinValue);
      if (tmp != null) {
        graphAccelDataX.add(tmp);
      }
    } else if (mode == 3) {
      int val = value[1] * 256 * 256 + value[2] * 256 + value[3];
      //gyr
      FlSpot tmp = getNewData(
          (val <= 32767) ? (0.0076 * (val)) : (0.0076 * (val - 2 * 32768)),
          graphGyrDataX.last.x.toInt(),
          graphXMaxValue2,
          graphYMaxValue2,
          graphXLabelStep2,
          graphYLabelStep2,
          mode,
          graphYMinValue2);
      if (tmp != null) {
        graphGyrDataX.add(tmp);
      }
    } else if (mode == 4) {
      int val = value[1] * 256 * 256 + value[2] * 256 + value[3];
      //mag
      FlSpot tmp = getNewData(
          (val <= 32767) ? val * 0.001 : 0.001 * (val - 2 * 32768),
          graphMagDataX.last.x.toInt(),
          graphXMaxValue3,
          graphYMaxValue3,
          graphXLabelStep3,
          graphYLabelStep3,
          mode,
          graphYMinValue3);
      if (tmp != null) {
        graphMagDataX.add(tmp);
      }
    } else if (mode == 5) {
      //tensão
      pulga.voltage = value[1] * 256 * 256 + value[2] * 256 + value[3];
      //voltage = voltage * 10;
      print('${pulga.voltage}');
    }
    //setState(() {});
    // mode1++;
  }

  void refreshChar2(List<int> value) {
    print('###############2  $value');

    if (oldValue != value &&
        DateTime.now().millisecondsSinceEpoch - oldTime > 5000) {
      oldValue = value;
      oldTime = DateTime.now().millisecondsSinceEpoch;

      int mode = value[0] - 1;
      if (mode == 0) {
        pulga.pressure = value[1] * 256 * 256 + value[2] * 256 + value[3];
      } else if (mode == 1) {
        pulga.uvLevel = value[1] * 256 * 256 + value[2] * 256 + value[3];
      } else if (mode == 2) {
        int val = value[1] * 256 * 256 + value[2] * 256 + value[3];
        FlSpot tmp = getNewData(
            (val <= 32767)
                ? (0.00006135 * (val))
                : (0.00006135 * (val - 2 * 32768)),
            graphAccelDataY.last.x.toInt(),
            graphXMaxValue,
            graphYMaxValue,
            graphXLabelStep,
            graphYLabelStep,
            mode,
            graphYMinValue);
        if (tmp != null) {
          graphAccelDataY.add(tmp);
        }
      } else if (mode == 3) {
        int val = value[1] * 256 * 256 + value[2] * 256 + value[3];
        FlSpot tmp = getNewData(
            (val <= 32767) ? (0.0076 * (val)) : (0.0076 * (val - 2 * 32768)),
            graphGyrDataY.last.x.toInt(),
            graphXMaxValue2,
            graphYMaxValue2,
            graphXLabelStep2,
            graphYLabelStep2,
            mode,
            graphYMinValue2);
        if (tmp != null) {
          graphGyrDataY.add(tmp);
        }
      } else if (mode == 4) {
        int val = value[1] * 256 * 256 + value[2] * 256 + value[3];
        FlSpot tmp = getNewData(
            (val <= 32767) ? val * 0.001 : 0.001 * (val - 2 * 32768),
            graphGyrDataZ.last.x.toInt(),
            graphXMaxValue3,
            graphYMaxValue3,
            graphXLabelStep3,
            graphYLabelStep3,
            mode,
            graphYMinValue3);
        if (tmp != null) {
          graphGyrDataY.add(tmp);
        }
      } else if (mode == 6) {
        //tensão
        pulga.solar = value[1] * 256 * 256 + value[2] * 256 + value[3];
        //voltage = voltage * 10;
        print('solar ${pulga.solar}');
      }
      // mode2++;

      //setState(() {});
    }
  }

  void refreshChar3(List<int> value) {
    print('###############3  $value');

    int mode = value[0] - 1;
    if (mode == 0) {
      pulga.moisture = value[1] * 256 * 256 + value[2] * 256 + value[3];
      print('moisture ${value[0]}');
    } else if (mode == 1) {
    } else if (mode == 2) {
      int val = value[1] * 256 * 256 + value[2] * 256 + value[3];
      FlSpot tmp = getNewData(
          (val <= 32767)
              ? (0.00006135 * (val))
              : (0.00006135 * (val - 2 * 32768)),
          graphAccelDataZ.last.x.toInt(),
          graphXMaxValue,
          graphYMaxValue,
          graphXLabelStep,
          graphYLabelStep,
          mode,
          graphYMinValue);
      if (tmp != null) {
        graphAccelDataZ.add(tmp);
      }
    } else if (mode == 3) {
      int val = value[1] * 256 * 256 + value[2] * 256 + value[3];
      FlSpot tmp = getNewData(
          (val <= 32767) ? (0.0076 * (val)) : (0.0076 * (val - 2 * 32768)),
          graphGyrDataZ.last.x.toInt(),
          graphXMaxValue2,
          graphYMaxValue2,
          graphXLabelStep2,
          graphYLabelStep2,
          mode,
          graphYMinValue2);
      if (tmp != null) {
        graphGyrDataZ.add(tmp);
      }
    } else if (mode == 4) {
      int val = value[1] * 256 * 256 + value[2] * 256 + value[3];
      FlSpot tmp = getNewData(
          (val <= 32767) ? val * 0.001 : 0.001 * (val - 2 * 32768),
          graphMagDataZ.last.x.toInt(),
          graphXMaxValue3,
          graphYMaxValue3,
          graphXLabelStep3,
          graphYLabelStep3,
          mode,
          graphYMinValue3);
      if (tmp != null) {
        graphMagDataZ.add(tmp);
      }
    }
    //setState(() {});
    // mode3++;
  }

  FlSpot getNewData(double value, int lastX, int xmax, int ymax, int xstep,
      int ystep, int mode, int ymin) {
    if ((DateTime.now().millisecondsSinceEpoch - initialTime) ~/ 1000 !=
        lastX.toInt()) {
      //acc

      FlSpot tmp = FlSpot(
          (DateTime.now().millisecondsSinceEpoch - initialTime) / 1000,
          value.toDouble());
      refreshLabelLimits(value.floor(), xmax, ymax, xstep, ystep, mode, ymin);
      update3DModel();
      return tmp;
    }
    return null;
  }

  Future<void> refreshLabelLimits(int value, int xmax, int ymax, int xstep,
      int ystep, int _mode, int ymin) async {
    int graphXMaxValueN = xmax;
    int graphXLabelStepN = xstep;
    int graphYMaxValueN = ymax;
    int graphYLabelStepN = ystep;
    int graphYMinValueN = ymin;

    if (value + 1 > graphYMaxValueN) {
      graphYMaxValueN = value + 1;
    }
    if (value - 1 < graphYMinValueN) {
      graphYMinValueN = value - 1;
      print('changed to $value');
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
    if (_mode == 2) {
      graphXMaxValue = graphXMaxValueN;
      graphXLabelStep = graphXLabelStepN;
      graphYMaxValue = graphYMaxValueN;
      graphYLabelStep = graphYLabelStepN;
      graphYMinValue = graphYMinValueN;
      if (this.mounted) {
        setState(() {});
      }
    } else if (_mode == 3) {
      graphXMaxValue2 = graphXMaxValueN;
      graphXLabelStep2 = graphXLabelStepN;
      graphYMaxValue2 = graphYMaxValueN;
      graphYLabelStep2 = graphYLabelStepN;
      graphYMinValue2 = graphYMinValueN;
      if (this.mounted) {
        setState(() {});
      }
    } else if (_mode == 4) {
      graphXMaxValue3 = graphXMaxValueN;
      graphXLabelStep3 = graphXLabelStepN;
      graphYMaxValue3 = graphYMaxValueN;
      graphYLabelStep3 = graphYLabelStepN;
      graphYMinValue3 = graphYMinValueN;
      if (this.mounted) {
        setState(() {});
      }
    }
  }

  Future<void> refreshAll() async {
    setState(() {
      reading = true;
    });

//    Duration durTemp = Duration(milliseconds: 200);

    try {
      await BleManager()
          .deviceData
          .services[2]
          .characteristics[4]
          .characteristic
          .write([0x01], withoutResponse: false);
//      await Future.delayed(durTemp, () => {});

      await BleManager()
          .deviceData
          .services[2]
          .characteristics[4]
          .characteristic
          .write([0x02], withoutResponse: false);
//      await Future.delayed(durTemp, () => {});

      await BleManager()
          .deviceData
          .services[2]
          .characteristics[4]
          .characteristic
          .write([0x03], withoutResponse: false);
//      await Future.delayed(durTemp, () => {});

      await BleManager()
          .deviceData
          .services[2]
          .characteristics[4]
          .characteristic
          .write([0x04], withoutResponse: false);
//      await Future.delayed(durTemp, () => {});

      await BleManager()
          .deviceData
          .services[2]
          .characteristics[4]
          .characteristic
          .write([0x05], withoutResponse: false);
//      await Future.delayed(durTemp, () => {});

      await BleManager()
          .deviceData
          .services[2]
          .characteristics[4]
          .characteristic
          .write([0x06], withoutResponse: false);
//      await Future.delayed(durTemp, () => {});

      await BleManager()
          .deviceData
          .services[2]
          .characteristics[4]
          .characteristic
          .write([0x07], withoutResponse: false);
//      await Future.delayed(durTemp, () => {});
    } catch (err) {
      print(err.toString());
      await BleManager().deviceData.device.disconnect();
      await BleManager().deviceData.device.connect();
    }
    if (loopActivated) {
      setState(() {});
      refreshAll();
    } else {
      setState(() {
        reading = false;
      });
    }
  }

  Future<void> refreshGraphPrior() async {
    setState(() {
      reading = true;
    });

    counter4Refresh++;

    Duration durTemp = Duration(milliseconds: 100);

    try {
      if (counter4Refresh == 1) {
        print('#########1');
        await BleManager()
            .deviceData
            .services[2]
            .characteristics[4]
            .characteristic
            .write([0x01], withoutResponse: false);
//        await Future.delayed(durTemp, () => {});
      } else if (counter4Refresh == 2) {
        print('#########2');

        await BleManager()
            .deviceData
            .services[2]
            .characteristics[4]
            .characteristic
            .write([0x02], withoutResponse: false);
//        await Future.delayed(durTemp, () => {});
      } else if (counter4Refresh == 3) {
        print('#########3');

        await BleManager()
            .deviceData
            .services[2]
            .characteristics[4]
            .characteristic
            .write([0x06], withoutResponse: false);
        counter4Refresh = 0;
//        await Future.delayed(durTemp, () => {});
      }

      if (showAccelerometer) {
        print('#########4');

        await BleManager()
            .deviceData
            .services[2]
            .characteristics[4]
            .characteristic
            .write([0x03], withoutResponse: false);
//        await Future.delayed(durTemp, () => {});

        //counter4Refresh = 0;
      } else if (showGyro) {
        print('#########5');

        await BleManager()
            .deviceData
            .services[2]
            .characteristics[4]
            .characteristic
            .write([0x04], withoutResponse: false);
//        await Future.delayed(durTemp, () => {});
      } else if (showMagnet) {
        print('#########6');

        await BleManager()
            .deviceData
            .services[2]
            .characteristics[4]
            .characteristic
            .write([0x05], withoutResponse: false);
//        await Future.delayed(durTemp, () => {});
      }
    } catch (err) {
      print(err);
      await BleManager().deviceData.device.disconnect();
      try {
        await BleManager().deviceData.device.connect();
      } catch (e) {}

      BleManager().deviceData = BleDevice(BleManager().deviceData.device);
      List<BluetoothService> services =
          await BleManager().deviceData.device.discoverServices();
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
        BleManager().deviceData.addService(tmpServ);
      }
    }

    setState(() {});
    if (loopActivated) {
      refreshGraphPrior();
    } else {
      // setState(() {
      reading = false;
      // });
    }
  }

  Future<void> monitorCharacteristics() async {
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
      await BleManager().reconect();
      monitoring = false;
      monitorCharacteristics();
      return;
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
    } catch (err) {}

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
    } catch (err) {}

    monitoring = true;
  }

  Future<void> timerCounter() async {
    timerOn = true;
    await Future.delayed(timeStep, () => {});
    timerOn = false;
    timerAction();
  }

  void timerAction() {
    if (totalTime > 0) {
      if (totalTime < timeCounter) {
        timeCounter = 0;
        refreshAll();
      } else {
        setState(() {
          timePercent = timeCounter / totalTime;
        });
        timeCounter++;
      }

      timerCounter();
    }
  }

  void update3DModel() {
    double az = (graphAccelDataX.last.y * 100).floor() / 100;
    double ax = (graphAccelDataY.last.y * 100).floor() / 100;
    double ay = (graphAccelDataZ.last.y * 100).floor() / 100;

    double module = sqrt(ax * ax + ay * ay + az * az);
    if ((module - 1).abs() < 0.1) {
      if (ax.abs() + ay.abs() < 0.1) {
        angleZ = 0;
      } else {
        angleZ = (asin(az / module)) * 180 / pi;
        angleX = (asin(ax / module)) * 180 / pi;
      }
      if (ay < 0) {
        angleZ = -angleZ;
        angleX = 180 - angleX;
      }
    }
  }
}
