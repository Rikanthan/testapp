import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:testapp/pages/GraphAbsorption.dart';
import 'package:testapp/pages/TableAbsorption.dart';
import 'package:testapp/pages/db_help.dart';
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

  @override
  void dispose() {
    materialController.dispose();
    frequencyController.dispose();
    p1Controller.dispose();
    p2Controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Input Parameters'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            buildTextField('Material Name', materialController,
                isNumber: false),
            buildTextField('Frequency (Hz)', frequencyController),
            buildTextField('Mic 1 Pressure (P1)', p1Controller),
            buildTextField('Mic 2 Pressure (P2)', p2Controller),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () async {
                String material = materialController.text;
                double frequency =
                    double.tryParse(frequencyController.text) ?? 0.0;
                double p1 = double.tryParse(p1Controller.text) ?? 0.0;
                double p2 = double.tryParse(p2Controller.text) ?? 0.0;

                if (material.isEmpty || frequency == 0 || p1 == 0 || p2 == 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Please enter all input values')),
                  );
                  return;
                }
                double reflectionCoefficient = p2 / p1;
                double absorption =
                    1 - (reflectionCoefficient * reflectionCoefficient);
                absorption = absorption.clamp(0.0, 1.0);
                // Pass data to Calculation Page (you'll create this next)
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AbsorptionTableScreen(
                      material: material,
                      frequency: frequency,
                      p1: p1,
                      p2: p2,
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                textStyle: const TextStyle(fontSize: 18),
              ),
              child: const Text('Calculate Absorption'),
            ),
          ],
        ),
      ),
    );
  }

  // Collect user inputs
  // double micSpacing = double.parse(micSpacingController.text);
  // double distanceSample = double.parse(distanceSampleController.text);
  // double tubeDiameter = double.parse(tubeDiameterController.text);
  // int freqMin = int.parse(freqMinController.text);
  // int freqMax = int.parse(freqMaxController.text);
  // int samplingRate = int.parse(samplingRateController.text);

  // List<double> absorptionList = [];
  //calculateAbsorptionCoefficient(...);

// Convert List into JSON String
  //String absorptionJson = jsonEncode(absorptionList);

// Now save it into database
  // Map<String, dynamic> data = {
  //   'micSpacing': micSpacing,
  //   'distanceSample': distanceSample,
  //   'tubeDiameter': tubeDiameter,
  //   'freqMin': freqMin,
  //   'freqMax': freqMax,
  //   'samplingRate': samplingRate,
  //   'absorptionCoefficients': absorptionJson,
  //   'createdAt': DateTime.now().toIso8601String(),
  // };

  //await DBHelper.instance.insertMeasurement(data);

  Widget buildTextField(String label, TextEditingController controller,
      {bool isNumber = true}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: TextField(
        controller: controller,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }
}
