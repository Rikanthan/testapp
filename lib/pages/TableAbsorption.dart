import 'package:flutter/material.dart';
import 'package:testapp/pages/GraphAbsorption.dart';
import 'package:testapp/pages/db_help.dart';

class AbsorptionTableScreen extends StatefulWidget {
  final String material;
  final double frequency;
  final double p1;
  final double p2;

  const AbsorptionTableScreen({
    super.key,
    required this.material,
    required this.frequency,
    required this.p1,
    required this.p2,
  });

  @override
  State<AbsorptionTableScreen> createState() => _AbsorptionTableScreenState();
}

class _AbsorptionTableScreenState extends State<AbsorptionTableScreen> {
  late double absorption;
  List<Map<String, dynamic>> _allMeasurements = [];

  @override
  void initState() {
    super.initState();
    _calculateAndSave();
  }

  Future<void> _calculateAndSave() async {
    double reflectionCoefficient = widget.p2 / widget.p1;
    double calculatedAbsorption =
        1 - (reflectionCoefficient * reflectionCoefficient);
    calculatedAbsorption = calculatedAbsorption.clamp(0.0, 1.0);
    absorption = calculatedAbsorption;

    await DBHelper.instance.insertMeasurement({
      'material': widget.material,
      'frequency': widget.frequency,
      'p1': widget.p1,
      'p2': widget.p2,
      'absorption': absorption,
      'createdAt': DateTime.now().toIso8601String(),
    });

    await _loadMeasurements();
  }

  Future<void> _loadMeasurements() async {
    final data = await DBHelper.instance.getAllMeasurements();
    setState(() {
      _allMeasurements = data;
    });
  }

  Future<void> _clearAll() async {
    await DBHelper.instance.clearAll();
    setState(() {
      _allMeasurements = [];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Absorption Calculation"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                'Calculated Absorption Data',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              DataTable(
                columnSpacing: 20,
                columns: const [
                  DataColumn(label: Text('Material')),
                  DataColumn(label: Text('Frequency (Hz)')),
                  DataColumn(label: Text('P1')),
                  DataColumn(label: Text('P2')),
                  DataColumn(label: Text('Absorption')),
                ],
                rows: [
                  DataRow(
                    cells: [
                      DataCell(Text(widget.material)),
                      DataCell(Text(widget.frequency.toStringAsFixed(1))),
                      DataCell(Text(widget.p1.toStringAsFixed(3))),
                      DataCell(Text(widget.p2.toStringAsFixed(3))),
                      DataCell(Text(absorption.toStringAsFixed(3))),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 30),
              const Text(
                'Conclusion',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Text(
                'The absorption coefficient for "${widget.material}" at '
                '${widget.frequency.toStringAsFixed(1)} Hz is ${absorption.toStringAsFixed(3)}.',
                style: const TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AmplitudeFrequencyGraph(),
                    ),
                  );
                },
                child: const Text('View Graph'),
              ),
              const SizedBox(height: 40),
              const Divider(),
              const Text(
                'All Stored Measurements',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              _allMeasurements.isEmpty
                  ? const Text("No stored data.")
                  : SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        columnSpacing: 16,
                        columns: const [
                          DataColumn(label: Text('Material')),
                          DataColumn(label: Text('Freq')),
                          DataColumn(label: Text('P1')),
                          DataColumn(label: Text('P2')),
                          DataColumn(label: Text('Absorb')),
                          DataColumn(label: Text('Created')),
                        ],
                        rows: _allMeasurements.map((entry) {
                          return DataRow(
                            cells: [
                              DataCell(Text(entry['material'] ?? '')),
                              DataCell(Text((entry['frequency'] ?? 0.0)
                                  .toStringAsFixed(1))),
                              DataCell(Text(
                                  (entry['p1'] ?? 0.0).toStringAsFixed(3))),
                              DataCell(Text(
                                  (entry['p2'] ?? 0.0).toStringAsFixed(3))),
                              DataCell(Text((entry['absorption'] ?? 0.0)
                                  .toStringAsFixed(3))),
                              DataCell(Text(
                                  entry['createdAt']?.split('T').first ?? '')),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _clearAll,
                icon: const Icon(Icons.delete),
                label: const Text('Clear All Data'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
