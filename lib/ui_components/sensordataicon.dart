import 'package:flutter/material.dart';

class SensorDataIcon extends StatelessWidget {
  final IconData icon;
  final String data;
  final String toolTip;

  SensorDataIcon(this.icon, this.data, this.toolTip);

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: toolTip,
      child: Padding(
        padding: const EdgeInsets.only(top: 8, bottom: 8, left: 15, right: 15),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Icon(icon, color: Colors.teal),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Text(
                  data,
                  style: Theme.of(context).textTheme.title,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
