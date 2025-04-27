import 'package:flutter/material.dart';
import 'dart:math';

class AbsorptionTableScreen extends StatelessWidget {
  // Generate the data
  final List<double> frequencyList = List.generate(100, (index) {
    return 100 + (index * (5000 - 100) / 99);
  });

  final List<double> incidentPressureList = [];
  final List<double> reflectedPressureList = [];
  final List<double> absorptionCoefficientList = [];

  AbsorptionTableScreen({super.key}) {
    for (var freq in frequencyList) {
      double incident = 1.0 + 0.2 * sin(2 * pi * freq / 3000);
      double reflected = 0.5 + 0.1 * cos(2 * pi * freq / 2500);

      double reflectionCoefficient = reflected / incident;
      double absorption = 1 - (reflectionCoefficient * reflectionCoefficient);
      absorption = absorption.clamp(0.0, 1.0);

      incidentPressureList.add(incident);
      reflectedPressureList.add(reflected);
      absorptionCoefficientList.add(absorption);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Absorption Data Table")),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical, // allow horizontal scroll
        child: DataTable(
            columnSpacing: 10, // 👈 Reduce space between columns (default is 56)
            dataRowMinHeight: 30, // 👈 Optional: reduce row height
            dataRowMaxHeight: 40,
          columns: const [
            DataColumn(label: Text('Frequency\n(Hz)')),
            DataColumn(label: Text("Incident\n Pressure (Pa)")),
            DataColumn(label: Text('Reflected\nPressure (Pa)')),
            DataColumn(label: Text('Absorption\nCoefficient')),
          ],
          rows: List<DataRow>.generate(
            frequencyList.length,
            (index) => DataRow(
              cells: [
                DataCell(Text(frequencyList[index].toStringAsFixed(1))),
                DataCell(Text(incidentPressureList[index].toStringAsFixed(3))),
                DataCell(Text(reflectedPressureList[index].toStringAsFixed(3))),
                DataCell(Text(absorptionCoefficientList[index].toStringAsFixed(3))),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
