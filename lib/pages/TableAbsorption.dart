import 'package:flutter/material.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:testapp/pages/GraphAbsorption.dart';
import 'package:testapp/pages/db_help.dart';

class AbsorptionTableScreen extends StatefulWidget {
  final String material;
  final double frequency;
  final double p1;
  final double p2;
  final double x1;
  final double k;
  final double absorption;
  final String mode;

  const AbsorptionTableScreen({
    required this.material,
    required this.frequency,
    required this.p1,
    required this.p2,
    required this.x1,
    required this.k,
    required this.absorption,
    required this.mode,
  });

  @override
  State<AbsorptionTableScreen> createState() => _AbsorptionTableScreenState();
}

class _AbsorptionTableScreenState extends State<AbsorptionTableScreen> {
  late double absorption;
  List<Map<String, dynamic>> _allMeasurements = [];

  void _showExportOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Choose Export Format',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.table_chart),
              title: const Text('Export as CSV'),
              onTap: () {
                Navigator.pop(context);
                _exportAsCSV();
              },
            ),
            ListTile(
              leading: const Icon(Icons.picture_as_pdf),
              title: const Text('Export as PDF'),
              onTap: () {
                Navigator.pop(context);
                _exportAsPDF();
              },
            ),
            ListTile(
              leading: const Icon(Icons.image),
              title: const Text('Export as Image'),
              onTap: () {
                Navigator.pop(context);
                _exportAsImage();
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _exportAsCSV() async {
    final directory = await getApplicationDocumentsDirectory();
    final filePath =
        '${directory.path}/absorption_data_${DateTime.now().toIso8601String()}.csv';
    final file = File(filePath);

    // Build CSV manually
    final buffer = StringBuffer();
    buffer.writeln('Material,Frequency,P1,P2,Absorption,CreatedAt');

    for (var entry in _allMeasurements) {
      buffer.writeln(
          '${entry['material']},${entry['frequency']},${entry['p1']},${entry['p2']},${entry['absorption']},${entry['createdAt']}');
    }

    await file.writeAsString(buffer.toString());
    await _showExportConfirmation(filePath);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('CSV exported successfully')),
    );
  }

  Future<void> _exportAsPDF() async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('PDF export coming soon!')),
    );
  }

  Future<void> _exportAsImage() async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Image export coming soon!')),
    );
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _calculateAndSave();
    });
  }

  Future<void> _calculateAndSave() async {
    double reflectionCoefficient = widget.p2 / widget.p1;
    double calculatedAbsorption =
        1 - (reflectionCoefficient * reflectionCoefficient);
    absorption = calculatedAbsorption.clamp(0.0, 1.0);

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
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('All data cleared')),
    );
  }

  Future<void> _showExportConfirmation(String filePath) async {
    final folderPath = filePath.substring(0, filePath.lastIndexOf('/'));

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Export Successful'),
        content: Text('File saved to:\n$filePath'),
        actions: [
          TextButton(
            onPressed: () async {
              final result = await OpenFile.open(folderPath);
              if (result.type != ResultType.done) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Could not open folder')),
                );
              }
              Navigator.pop(ctx);
            },
            child: const Text('Open Folder'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final latest = _allMeasurements.isNotEmpty ? _allMeasurements.first : null;

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
              Text(
                'The absorption coefficient for "${widget.material}" at '
                '${widget.frequency.toStringAsFixed(1)} Hz is ${absorption.toStringAsFixed(3)}.',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              if (latest != null)
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
                        DataCell(Text(latest['material'] ?? '')),
                        DataCell(Text(
                            (latest['frequency'] ?? 0.0).toStringAsFixed(1))),
                        DataCell(
                            Text((latest['p1'] ?? 0.0).toStringAsFixed(3))),
                        DataCell(
                            Text((latest['p2'] ?? 0.0).toStringAsFixed(3))),
                        DataCell(Text(
                            (latest['absorption'] ?? 0.0).toStringAsFixed(3))),
                      ],
                    ),
                  ],
                ),
              const SizedBox(height: 30),
              if (latest != null)
                Text(
                  'The absorption coefficient for "${latest['material']}" at '
                  '${latest['frequency'].toStringAsFixed(1)} Hz is ${latest['absorption'].toStringAsFixed(3)}.',
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
              Column(
                children: [
                  const SizedBox(height: 24),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  title: const Text('Confirm Delete'),
                                  content: const Text(
                                      'Are you sure you want to clear all stored data?'),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(ctx),
                                      child: const Text('Cancel'),
                                    ),
                                    TextButton(
                                      onPressed: () async {
                                        Navigator.pop(ctx);
                                        await _clearAll();
                                      },
                                      child: const Text('Yes'),
                                    ),
                                  ],
                                ),
                              );
                            },
                            icon: const Icon(Icons.delete),
                            label: const Text('Clear All Data'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => _showExportOptions(context),
                            icon: const Icon(Icons.upload_file),
                            label: const Text('Export'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blueAccent,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
