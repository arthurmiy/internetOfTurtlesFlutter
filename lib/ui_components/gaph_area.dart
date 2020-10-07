import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

LineChartData getChartArea(Color lightColor, int xStep, int yStep, int xMax,
    int xMin, int yMax, int yMin, List<LineChartBarData> data, int caseNumber) {
  return LineChartData(
    lineTouchData: LineTouchData(
      touchTooltipData: LineTouchTooltipData(
          tooltipBgColor: Colors.blueGrey.withOpacity(0.8),
          getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
            return touchedBarSpots.map((barSpot) {
              final flSpot = barSpot;

              return LineTooltipItem(
                '${flSpot.y}',
                TextStyle(color: flSpot.bar.colors[0]),
              );
            }).toList();
          }),
      touchCallback: (LineTouchResponse touchResponse) {
        print(touchResponse);
      },
      handleBuiltInTouches: true,
    ),
    gridData: const FlGridData(show: true, horizontalInterval: 100),
    titlesData: FlTitlesData(
      bottomTitles: SideTitles(
        showTitles: true,
        reservedSize: 22,
        textStyle: TextStyle(
          color: lightColor,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
        margin: 10,
        getTitles: (value) {
          int re = value.toInt() % xStep;
          if (re == 0) {
            //value multiple from step
            return (value / 1000).toString();
          }
          return '';
        },
      ),
      leftTitles: SideTitles(
        showTitles: true,
        textStyle: TextStyle(
          color: lightColor,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
        getTitles: (value) {
          int re = value.toInt() % yStep;
          if (re == 0) {
            //value multiple from step
            if (caseNumber == 1) {
              return ('$value');
            } else if (caseNumber == 2) {
              return (value * 100 * 7.6).toStringAsPrecision(1);
            } else if (caseNumber == 3) {
              return (value * 100).toStringAsPrecision(1);
            } else {
              return value.toString();
            }
          }
          return '';
        },
        margin: 8,
        reservedSize: 30,
      ),
    ),
    borderData: FlBorderData(
      show: true,
      border: Border(
        bottom: BorderSide(
          color: lightColor,
          width: 4,
        ),
        left: BorderSide(
          color: Colors.transparent,
        ),
        right: BorderSide(
          color: Colors.transparent,
        ),
        top: BorderSide(
          color: Colors.transparent,
        ),
      ),
    ),
    minX: xMin.toDouble(),
    maxX: xMax.toDouble(),
    maxY: yMax.toDouble(),
    minY: yMin.toDouble(),
    lineBarsData: data,
  );
}
