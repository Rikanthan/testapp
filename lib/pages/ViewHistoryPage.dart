import 'package:flutter/material.dart';
import 'package:testapp/pages/TableAbsorption.dart';
import 'package:testapp/pages/db_help.dart';

class ViewHistoryPage extends StatefulWidget {
  const ViewHistoryPage({super.key});

  @override
  State<ViewHistoryPage> createState() => _ViewHistoryPageState();
}

class _ViewHistoryPageState extends State<ViewHistoryPage> {
  List<Map<String, dynamic>> _allMeasurements = [];

  @override
  void initState() {
    super.initState();
    _loadMeasurements();
  }

  Future<void> _loadMeasurements() async {
    final data = await DBHelper.instance.getAllMeasurements();
    setState(() {
      _allMeasurements = data;
    });
  }

  Future<void> _clearAll() async {
    await DBHelper.instance.clearAll();
    await _loadMeasurements();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Stored Measurements')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ElevatedButton.icon(
              onPressed: _clearAll,
              icon: const Icon(Icons.delete),
              label: const Text('Clear All Data'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: _allMeasurements.isEmpty
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
                        DataCell(Text((entry['frequency'] ?? 0.0).toStringAsFixed(1))),
                        DataCell(Text((entry['p1'] ?? 0.0).toStringAsFixed(3))),
                        DataCell(Text((entry['p2'] ?? 0.0).toStringAsFixed(3))),
                        DataCell(Text((entry['absorption'] ?? 0.0).toStringAsFixed(3))),
                        DataCell(Text(entry['createdAt']?.split('T').first ?? '')),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
