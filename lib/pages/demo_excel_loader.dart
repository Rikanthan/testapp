import 'package:file_picker/file_picker.dart';
import 'package:excel/excel.dart';
import 'package:flutter/foundation.dart'; // for kIsWeb
import 'dart:typed_data'; // for Uint8List
import 'dart:math';
import '../models/demo_measurement.dart';

Future<List<DemoMeasurement>> pickExcelFileFromPhone() async {
  final result = await FilePicker.platform.pickFiles(
    type: FileType.custom,
    allowedExtensions: ['xlsx'],
  );

  if (result == null) throw Exception('No file selected');

  final bytes = kIsWeb
      ? result.files.single.bytes
      : await result.files.single.readStream!.fold<Uint8List>(
    Uint8List(0),
        (previous, element) => Uint8List.fromList([...previous, ...element]),
  );

  if (bytes == null) throw Exception('Failed to read file bytes');

  final excel = Excel.decodeBytes(bytes);
  final sheet = excel.tables[excel.tables.keys.first];
  if (sheet == null) throw Exception('No sheet found in Excel file');

  final measurements = <DemoMeasurement>[];
  double micDistance = 0.03; // default fallback

  for (var row in sheet.rows.skip(1)) {
    if (row.length < 5) continue;

    final freq = double.tryParse(row[0]?.value.toString() ?? '');
    final p1No = double.tryParse(row[1]?.value.toString() ?? '');
    final p2No = double.tryParse(row[2]?.value.toString() ?? '');
    final p1Yes = double.tryParse(row[3]?.value.toString() ?? '');
    final p2Yes = double.tryParse(row[4]?.value.toString() ?? '');

    if (freq == null || p1No == null || p2No == null || p1Yes == null || p2Yes == null) continue;

    final absorptionNo = calculateSimplifiedAbsorption(p1No, p2No);
    final absorptionYes = calculateSimplifiedAbsorption(p1Yes, p2Yes);

    measurements.add(DemoMeasurement(
      frequency: freq,
      p1: p1No,
      p2: p2No,
      micDistance: micDistance,
      absorption: absorptionNo,
      sourceType: 'withoutSignal',
    ));

    measurements.add(DemoMeasurement(
      frequency: freq,
      p1: p1Yes,
      p2: p2Yes,
      micDistance: micDistance,
      absorption: absorptionYes,
      sourceType: 'withSignal',
    ));
  }

  return measurements;
}

// ✅ Simplified absorption formula: α = 1 - (P2 / P1)^2
double calculateSimplifiedAbsorption(double p1, double p2) {
  if (p1 == 0) return 0;
  final ratio = p2 / p1;
  return 1 - (pow(ratio, 2) as double);
}
