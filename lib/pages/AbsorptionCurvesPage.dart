import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/demo_measurement.dart';
import 'package:testapp/pages/AbsorptionComparisonPage.dart';
import 'dart:io';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';

class AbsorptionCurvesPage extends StatefulWidget {
  final List<DemoMeasurement> demoData;

  const AbsorptionCurvesPage({super.key, required this.demoData});

  @override
  State<AbsorptionCurvesPage> createState() => _AbsorptionCurvesPageState();
}

class _AbsorptionCurvesPageState extends State<AbsorptionCurvesPage> {
  bool showP1 = false;
  bool showP2 = false;

  @override
  Widget build(BuildContext context) {
    final withSignalCurve = widget.demoData
        .where((m) => m.sourceType == 'withSignal')
        .map((m) => FlSpot(m.frequency, m.absorption ?? 0))
        .toList();

    final withoutSignalCurve = widget.demoData
        .where((m) => m.sourceType == 'withoutSignal')
        .map((m) => FlSpot(m.frequency, m.absorption ?? 0))
        .toList();

    final p1Curve = widget.demoData.map((m) {
      return FlSpot(m.frequency, m.p1);
    }).toList();

    final p2Curve = widget.demoData.map((m) {
      return FlSpot(m.frequency, m.p2);
    }).toList();

    final lines = [
      LineChartBarData(
        spots: withSignalCurve,
        isCurved: true,
        color: Colors.blue,
        dotData: FlDotData(show: false),
      ),
      LineChartBarData(
        spots: withoutSignalCurve,
        isCurved: true,
        color: Colors.orange,
        dotData: FlDotData(show: false),
      ),
      if (showP1)
        LineChartBarData(
          spots: p1Curve,
          isCurved: true,
          color: Colors.red,
          dotData: FlDotData(show: false),
        ),
      if (showP2)
        LineChartBarData(
          spots: p2Curve,
          isCurved: true,
          color: Colors.purple,
          dotData: FlDotData(show: false),
        ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text('Absorption Curves'),
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
                LegendItem(color: Colors.blue, label: 'Absorption (With Signal)'),
                LegendItem(color: Colors.orange, label: 'Absorption (No Signal)'),
                if (showP1) LegendItem(color: Colors.red, label: 'Raw Signal (P1)'),
                if (showP2) LegendItem(color: Colors.purple, label: 'No Signal (P2)'),
              ],
            ),
            SizedBox(height: 12),
            SwitchListTile(
              title: Text('Show Raw Signal (P1)'),
              value: showP1,
              onChanged: (val) => setState(() => showP1 = val),
            ),
            SwitchListTile(
              title: Text('Show No Signal (P2)'),
              value: showP2,
              onChanged: (val) => setState(() => showP2 = val),
            ),
            SizedBox(height: 12),
            Expanded(
              child: LineChart(
                LineChartData(
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      axisNameWidget: Padding(
                        padding: EdgeInsets.only(right: 8),
                        child: Text('Absorption Coefficient'),
                      ),
                      sideTitles: SideTitles(showTitles: true),
                    ),
                    bottomTitles: AxisTitles(
                      axisNameWidget: Padding(
                        padding: EdgeInsets.only(top: 8),
                        child: Text('Frequency (Hz)'),
                      ),
                      sideTitles: SideTitles(showTitles: true),
                    ),
                  ),
                  lineBarsData: lines,
                  gridData: FlGridData(show: true),
                  borderData: FlBorderData(show: true),
                ),
              ),
            ),
            SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AbsorptionComparisonPage(demoData: widget.demoData),
                  ),
                );
              },
              child: Text('Compare with Reference'),
            ),
            SizedBox(height: 8),
            ElevatedButton(
              onPressed: () async {
                await exportAbsorptionData(widget.demoData);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('CSV exported to Downloads folder')),
                );
              },
              child: Text('Export Absorption Data'),
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

Future<void> exportAbsorptionData(List<DemoMeasurement> data) async {
  final grouped = <double, Map<String, DemoMeasurement>>{};

  for (var m in data) {
    grouped.putIfAbsent(m.frequency, () => {});
    if (m.sourceType != null) {
      grouped[m.frequency]![m.sourceType!] = m;
    }
  }

  final rows = [
    [
      'Frequency',
      'P1 (With)',
      'P2 (With)',
      'Absorption (With)',
      'P1 (Without)',
      'P2 (Without)',
      'Absorption (Without)',
      'Difference'
    ]
  ];

  for (var freq in grouped.keys.toList()..sort()) {
    final withM = grouped[freq]?['withSignal'];
    final withoutM = grouped[freq]?['withoutSignal'];

    if (withM == null || withoutM == null) continue;

    final diff = (withM.absorption ?? 0) - (withoutM.absorption ?? 0);

    rows.add([
      freq.toString(),
      withM.p1.toString(),
      withM.p2.toString(),
      withM.absorption != null ? withM.absorption!.toStringAsFixed(4) : '',
      withoutM.p1.toString(),
      withoutM.p2.toString(),
      withoutM.absorption != null ? withoutM.absorption!.toStringAsFixed(4) : '',
      diff.toStringAsFixed(4),
    ]);


  }

  final csvData = const ListToCsvConverter().convert(rows);
  final dir = await getDownloadsDirectory();
  final file = File('${dir!.path}/absorption_data.csv');
  await file.writeAsString(csvData);
}
