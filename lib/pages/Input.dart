import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:testapp/pages/GraphAbsorption.dart';
import 'package:testapp/pages/TableAbsorption.dart';

import 'db_help.dart';

class InputPage extends StatefulWidget {
  const InputPage();

  @override
  State<InputPage> createState() => _InputPageState();
}

class _InputPageState extends State<InputPage> {
  final TextEditingController micSpacingController = TextEditingController();
  final TextEditingController distanceSampleController = TextEditingController();
  final TextEditingController tubeDiameterController = TextEditingController();
  final TextEditingController freqMinController = TextEditingController();
  final TextEditingController freqMaxController = TextEditingController();
  final TextEditingController samplingRateController = TextEditingController();

  @override
  void dispose() {
    micSpacingController.dispose();
    distanceSampleController.dispose();
    tubeDiameterController.dispose();
    freqMinController.dispose();
    freqMaxController.dispose();
    samplingRateController.dispose();
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
            buildTextField('Microphone Spacing (m)', micSpacingController),
            buildTextField('Distance to Sample (m)', distanceSampleController),
            buildTextField('Tube Diameter (m)', tubeDiameterController),
            buildTextField('Minimum Frequency (Hz)', freqMinController),
            buildTextField('Maximum Frequency (Hz)', freqMaxController),
            buildTextField('Sampling Rate (Hz)', samplingRateController),
            const SizedBox(height: 30),
            ElevatedButton(
    onPressed: () async {
      // double micSpacing = double.parse(micSpacingController.text);
      // double distanceSample = double.parse(distanceSampleController.text);
      // double tubeDiameter = double.parse(tubeDiameterController.text);
      // int freqMin = int.parse(freqMinController.text);
      // int freqMax = int.parse(freqMaxController.text);
      // int samplingRate = int.parse(samplingRateController.text);

      List<double> absorptionList = [];
      //calculateAbsorptionCoefficient(...);

// Convert List into JSON String
      String absorptionJson = jsonEncode(absorptionList);

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
      Navigator.push(context,
          MaterialPageRoute(builder: (context)=>
              AbsorptionTableScreen()
              )
      );
    },
    style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                textStyle: const TextStyle(fontSize: 18),
              ),
              child: const Text('Calculate Absorption'),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildTextField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }
}

