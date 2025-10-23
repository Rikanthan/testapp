import 'package:flutter/material.dart';
import 'package:testapp/pages/TableAbsorption.dart';
import 'dart:math';

import 'db_help.dart';


class InputPage extends StatefulWidget {
  const InputPage();

  @override
  State<InputPage> createState() => _InputPageState();
}

class _InputPageState extends State<InputPage> {
  final TextEditingController materialController = TextEditingController();
  final TextEditingController frequencyController = TextEditingController();
  final TextEditingController p1Controller = TextEditingController();
  final TextEditingController p2Controller = TextEditingController();
  final TextEditingController x1Controller = TextEditingController();

  late String mode;
  static const double speedOfSound = 343.0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    mode = ModalRoute.of(context)?.settings.arguments as String? ?? 'manual';

    if (mode == 'demo') {
      frequencyController.text = '1000';
      p1Controller.text = '1.2';
      p2Controller.text = '0.8';
      x1Controller.text = '0.05';
    }

    if (mode == 'realtime') {
      // Stub: Replace with Bluetooth logic later
      p1Controller.text = '1.5'; // Simulated
      p2Controller.text = '1.0'; // Simulated
    }
  }

  @override
  void dispose() {
    materialController.dispose();
    frequencyController.dispose();
    p1Controller.dispose();
    p2Controller.dispose();
    x1Controller.dispose();
    super.dispose();
  }

  Future<void> _clearAll() async {
    await DBHelper.instance.clearAll();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('All data cleared')),
    );
  }


  @override
  Widget build(BuildContext context) {
    bool isEditable = mode == 'manual';

    return Scaffold(
      appBar: AppBar(
        title: Text('Input Parameters (${mode.toUpperCase()})'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            buildTextField('Material Name', materialController, isNumber: false, enabled: true),
            buildTextField('Frequency (Hz)', frequencyController, enabled: isEditable),
            buildTextField('Mic 1 Pressure (P1)', p1Controller, enabled: isEditable),
            buildTextField('Mic 2 Pressure (P2)', p2Controller, enabled: isEditable),
            buildTextField('Distance to Mic 2 (x₁ in meters)', x1Controller, enabled: true),
            const SizedBox(height: 30),
    ElevatedButton(
    onPressed: () async {
    String material = materialController.text;
    double frequency = double.tryParse(frequencyController.text) ?? 0.0;
    double p1 = double.tryParse(p1Controller.text) ?? 0.0;
    double p2 = double.tryParse(p2Controller.text) ?? 0.0;
    double x1 = double.tryParse(x1Controller.text) ?? 0.0;

    if (material.isEmpty || frequency == 0 || p1 == 0 || p2 == 0 || x1 == 0) {
    ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('Please enter all input values')),
    );
    return;
    }

    const double c = 343.0;
    double k = (2 * pi * frequency) / c;
    double reflectionCoefficient = p2 / p1;
    double absorption = 1 - (reflectionCoefficient * reflectionCoefficient);
    absorption = absorption.clamp(0.0, 1.0);

    Navigator.push(
    context,
    MaterialPageRoute(
    builder: (context) => AbsorptionTableScreen(
    material: material,
    frequency: frequency,
    p1: p1,
    p2: p2,
    x1: x1,
    k: k,
    absorption: absorption,
    mode: mode,
    ),
    ),
    );
    },
    child: const Text('Calculate Absorption'),
    ),

    // Validation and navigation logic here
          ],
        ),
      ),
    );
  }

  Widget buildTextField(String label, TextEditingController controller,
      {bool isNumber = true, bool enabled = true}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: TextField(
        controller: controller,
        enabled: enabled,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }
}


