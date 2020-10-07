import 'package:flutter/material.dart';

class SensorDataWithLabel extends StatelessWidget {
  final IconData icon;
  final String label;
  final String data;

  SensorDataWithLabel(this.icon, this.label, this.data);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Icon(icon, color: Colors.teal),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              label,
              style: Theme.of(context)
                  .textTheme
                  .title
                  .copyWith(color: Colors.teal),
            ),
          ),
        ),
        Container(
          width: 50,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Text(
              data,
              style: Theme.of(context).textTheme.subtitle,
              textAlign: TextAlign.right,
            ),
          ),
        ),
      ],
    );
  }
}
