import 'dart:ui';

import 'package:fl_chart/fl_chart.dart';

List<LineChartBarData> getlinesForChart(
    List<FlSpot> dataX, List<FlSpot> dataY, List<FlSpot> dataZ) {
  LineChartBarData lineChartBarData1 = LineChartBarData(
    spots: dataX,
    isCurved: false,
    colors: [
      Color(0xff4af699),
    ],
    barWidth: 2,
    isStrokeCapRound: true,
    dotData: FlDotData(
      show: false,
    ),
    belowBarData: BarAreaData(
      show: false,
    ),
  );
  final LineChartBarData lineChartBarData2 = LineChartBarData(
    spots: dataY,
    isCurved: false,
    colors: [
      Color(0xffaa4cfc),
    ],
    barWidth: 2,
    isStrokeCapRound: true,
    dotData: FlDotData(
      show: false,
    ),
    belowBarData: BarAreaData(show: false, colors: [
      Color(0x00aa4cfc),
    ]),
  );
  LineChartBarData lineChartBarData3 = LineChartBarData(
    spots: dataZ,
    isCurved: false,
    colors: const [
      Color(0xff27b6fc),
    ],
    barWidth: 2,
    isStrokeCapRound: true,
    dotData: const FlDotData(
      show: false,
    ),
    belowBarData: const BarAreaData(
      show: false,
    ),
  );
  return [
    lineChartBarData1,
    lineChartBarData2,
    lineChartBarData3,
  ];
}
