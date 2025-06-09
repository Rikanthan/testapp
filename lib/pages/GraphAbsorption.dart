import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:testapp/pages/db_help.dart';


class AmplitudeFrequencyGraph extends StatefulWidget {
  const AmplitudeFrequencyGraph({super.key});

  @override
  State<AmplitudeFrequencyGraph> createState() => _AmplitudeFrequencyGraphState();
}

class _AmplitudeFrequencyGraphState extends State<AmplitudeFrequencyGraph> {
  List<FlSpot> userSpots = [];
  List<FlSpot> referenceSpots = [];

  final List<double> referenceFrequencies = [
    100, 200, 300, 400, 500, 600, 700, 800, 900, 1000,
    1100, 1200, 1300, 1400, 1500, 1600, 1700, 1800, 1900, 2000,
    2100, 2200, 2300, 2400, 2500, 2600, 2700, 2800, 2900, 3000,
    3100, 3200, 3300, 3400, 3500, 3600, 3700, 3800, 3900, 4000,
    4100, 4200, 4300, 4400, 4500, 4600, 4700, 4800, 4900, 5000,
  ];

  final List<double> referenceAbsorptions = [
    0.18, 0.22, 0.26, 0.30, 0.34, 0.37, 0.39, 0.42, 0.44, 0.46,
    0.48, 0.50, 0.52, 0.54, 0.56, 0.57, 0.58, 0.59, 0.60, 0.61,
    0.62, 0.63, 0.64, 0.65, 0.66, 0.67, 0.68, 0.69, 0.70, 0.71,
    0.72, 0.73, 0.74, 0.75, 0.76, 0.77, 0.78, 0.79, 0.80, 0.81,
    0.82, 0.83, 0.84, 0.85, 0.86, 0.87, 0.88, 0.89, 0.90, 0.91,
  ];

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
    ]);
    loadUserData();
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    super.dispose();
  }

  Future<void> loadUserData() async {
    final data = await DBHelper.instance.getAllMeasurements();
    print("Fetched ${data.length} rows from database.");

    setState(() {
      userSpots = data.map((m) {
        return FlSpot(
          (m['frequency'] as num).toDouble(),
          (m['absorption'] as num).toDouble(),
        );
      }).toList();

      referenceSpots = List.generate(referenceFrequencies.length, (index) {
        return FlSpot(referenceFrequencies[index], referenceAbsorptions[index]);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Absorption Coefficient vs Frequency")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: LineChart(
                LineChartData(
          minX: 100,
          maxX: 5000,
          minY: 0,
          maxY: 1,

          titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: true),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: true),
                    ),
                  ),
                  borderData: FlBorderData(show: true),
                  gridData: FlGridData(show: true),
                  lineBarsData: [
                    LineChartBarData(
                      spots: userSpots,
                      isCurved: true,
                      color: Colors.blue,
                      barWidth: 3,
                      dotData: FlDotData(show: false),
                    ),
                    LineChartBarData(
                      spots: referenceSpots,
                      isCurved: true,
                      color: Colors.red,
                      barWidth: 2,
                      isStrokeCapRound: true,
                      dashArray: [6, 4],
                      dotData: FlDotData(show: false),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(children: [
                  Container(width: 20, height: 10, color: Colors.blue),
                  const SizedBox(width: 8),
                  const Text("User Data"),
                ]),
                const SizedBox(width: 20),
                Row(children: [
                  Container(width: 20, height: 10, color: Colors.red),
                  const SizedBox(width: 8),
                  const Text("Reference Curve"),
                ]),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
