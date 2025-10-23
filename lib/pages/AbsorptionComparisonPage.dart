import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/demo_measurement.dart';

class AbsorptionComparisonPage extends StatefulWidget {
  final List<DemoMeasurement> demoData;

  const AbsorptionComparisonPage({super.key, required this.demoData});

  @override
  State<AbsorptionComparisonPage> createState() => _AbsorptionComparisonPageState();
}

class _AbsorptionComparisonPageState extends State<AbsorptionComparisonPage> {
  bool showOriginalCurves = false;

  @override
  Widget build(BuildContext context) {
    final withSignalMap = {
      for (var m in widget.demoData.where((m) => m.sourceType == 'withSignal'))
        m.frequency: m.absorption ?? 0
    };

    final withoutSignalMap = {
      for (var m in widget.demoData.where((m) => m.sourceType == 'withoutSignal'))
        m.frequency: m.absorption ?? 0
    };

    final differenceCurve = <FlSpot>[];
    for (var freq in withSignalMap.keys) {
      if (withoutSignalMap.containsKey(freq)) {
        final diff = withSignalMap[freq]! - withoutSignalMap[freq]!;
        differenceCurve.add(FlSpot(freq, diff));
      }
    }

    final referenceFoamCurve = [
      FlSpot(125, 0.15),
      FlSpot(250, 0.35),
      FlSpot(500, 0.65),
      FlSpot(1000, 0.85),
      FlSpot(2000, 0.95),
    ];

    final originalWithCurve = widget.demoData
        .where((m) => m.sourceType == 'withSignal')
        .map((m) => FlSpot(m.frequency, m.absorption ?? 0))
        .toList();

    final originalWithoutCurve = widget.demoData
        .where((m) => m.sourceType == 'withoutSignal')
        .map((m) => FlSpot(m.frequency, m.absorption ?? 0))
        .toList();

    final lines = [
      LineChartBarData(
        spots: differenceCurve,
        isCurved: true,
        color: Colors.purple,
        dotData: FlDotData(show: false),
      ),
      LineChartBarData(
        spots: referenceFoamCurve,
        isCurved: true,
        color: Colors.green,
        isStrokeCapRound: true,
        dashArray: [6, 4],
        dotData: FlDotData(show: false),
      ),
      if (showOriginalCurves)
        LineChartBarData(
          spots: originalWithCurve,
          isCurved: true,
          color: Colors.blue.withOpacity(0.4),
          dotData: FlDotData(show: false),
        ),
      if (showOriginalCurves)
        LineChartBarData(
          spots: originalWithoutCurve,
          isCurved: true,
          color: Colors.orange.withOpacity(0.4),
          dotData: FlDotData(show: false),
        ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text('Absorption Comparison'),
        backgroundColor: Color(0xFF6A5ACD),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 16,
              children: [
                LegendItem(color: Colors.purple, label: 'Difference Curve'),
                LegendItem(color: Colors.green, label: 'Reference Foam'),
                if (showOriginalCurves) LegendItem(color: Colors.blue, label: 'With Signal'),
                if (showOriginalCurves) LegendItem(color: Colors.orange, label: 'No Signal'),
              ],
            ),
            SizedBox(height: 12),
            SwitchListTile(
              title: Text('Show Original Curves'),
              value: showOriginalCurves,
              onChanged: (val) => setState(() => showOriginalCurves = val),
            ),
            SizedBox(height: 12),
            Expanded(
              child: LineChart(
                LineChartData(
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: true),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: true),
                    ),
                  ),
                  lineBarsData: lines,
                  gridData: FlGridData(show: true),
                  borderData: FlBorderData(show: true),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class LegendItem extends StatelessWidget {
  final Color color;
  final String label;

  const LegendItem({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 16, height: 16, color: color),
        SizedBox(width: 4),
        Text(label, style: TextStyle(fontSize: 12)),
      ],
    );
  }
}
