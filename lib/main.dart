import 'package:flutter/material.dart';
import 'package:internetofturtles/screens/GraphPage.dart';
import 'package:internetofturtles/screens/MidScreen.dart';
import 'package:internetofturtles/screens/about.dart';
import 'package:internetofturtles/screens/config.dart';
import 'package:internetofturtles/screens/graphscreens/acelerom.dart';
import 'package:internetofturtles/screens/home.dart';
import 'package:internetofturtles/Debug_and_tests/info.dart';
import 'package:internetofturtles/screens/infopulga.dart';
import 'package:internetofturtles/screens/loadingscreen.dart';
import 'package:internetofturtles/screens/threedorientationscreen.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Internet of Turtles',
      theme: ThemeData(
        primarySwatch: Colors.teal,
      ),
      darkTheme: ThemeData.dark(),
      initialRoute: '/',
      routes: {
        Home.rout: (context) => Home(),
        InfoPage.rout: (context) => InfoPage(),
        LoadingScreen.rout: (context) => LoadingScreen(),
        InfoPulga.rout: (context) => InfoPulga(),
        Accelerometer.rout: (context) => Accelerometer(),
        AboutScreen.rout: (context) => AboutScreen(),
        GraphPage.rout: (context) => GraphPage(),
        MidScreen.rout: (context) => MidScreen(),
        ConfigurationPage.rout: (context) => ConfigurationPage(),
        ThreeDScreen.rout: (context) => ThreeDScreen(),
      },
    );
  }
}
