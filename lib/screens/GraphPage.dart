import 'package:flutter/material.dart';

class GraphPage extends StatefulWidget {
  static const String rout = '/GraphPage';
  @override
  _GraphPageState createState() => _GraphPageState();
}

class _GraphPageState extends State<GraphPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Visualização Gráfica'), //todo implement actual page
      ),
    );
  }
}
