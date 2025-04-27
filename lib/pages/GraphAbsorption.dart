import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:math';

class AmplitudeFrequencyGraph extends StatefulWidget {
  const AmplitudeFrequencyGraph({super.key});

  @override
  State<AmplitudeFrequencyGraph> createState() => _AmplitudeFrequencyGraphState();
}

class _AmplitudeFrequencyGraphState extends State<AmplitudeFrequencyGraph> {
  final List<double> frequencyList = List.generate(100, (index) {
    return 100 + (index * (5000 - 100) / 99);
  });

  final List<double> incidentPressureList = [];

  @override
  void initState() {
    super.initState();
    // Set landscape mode
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
    ]);

    for (var freq in frequencyList) {
      double incident = 1.0 + 0.2 * sin(2 * pi * freq / 3000);
      incidentPressureList.add(incident);
    }
  }

  @override
  void dispose() {
    // Reset back to normal (portrait) when exiting
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Amplitude vs Frequency")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: LineChart(
          LineChartData(
            titlesData: FlTitlesData(
              leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true)),
              bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true)),
            ),
            borderData: FlBorderData(show: true),
            gridData: FlGridData(show: true),
            lineBarsData: [
              LineChartBarData(
                spots: List.generate(frequencyList.length, (index) {
                  return FlSpot(frequencyList[index], incidentPressureList[index]);
                }),
                isCurved: true,
                color: Colors.blue,
                barWidth: 2,
                dotData: FlDotData(show: false),
                belowBarData: BarAreaData(
                  show: true,
                  color: Colors.blue.withOpacity(0.3),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
