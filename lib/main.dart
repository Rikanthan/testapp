import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
//import 'package:testapp/pages/AbsorptionGraphStatic.dart';
import 'package:testapp/pages/GraphAbsorption.dart';
import 'package:testapp/pages/Input.dart';
import 'package:testapp/pages/TableAbsorption.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  if (!kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.windows ||
          defaultTargetPlatform == TargetPlatform.linux ||
          defaultTargetPlatform == TargetPlatform.macOS)) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'AbsorbCalc',
        theme: ThemeData(
          // This is the theme of your application.
          //
          // TRY THIS: Try running your application with "flutter run". You'll see
          // the application has a purple toolbar. Then, without quitting the app,
          // try changing the seedColor in the colorScheme below to Colors.green
          // and then invoke "hot reload" (save your changes or press the "hot
          // reload" button in a Flutter-supported IDE, or press "r" if you used
          // the command line to start the app).
          //
          // Notice that the counter didn't reset back to zero; the application
          // state is not lost during the reload. To reset the state, use hot
          // restart instead.
          //
          // This works for code too, not just values: Most code changes can be
          // tested with just a hot reload.
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        ),
        home: HomePage());
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});
  void _showProjectInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('About the Project'),
        content: const Text(
          'This mobile app is part of an impedance tube project for measuring sound absorption coefficients of materials. '
          'It uses the Transfer Function Method, where microphone input is processed to compute the reflection factor and ultimately the absorption coefficient. '
          'Since the physical tube is not constructed yet, inputs are currently entered manually. The app allows you to input parameters, calculate results, view a table and graph, and compare them with reference values.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const SizedBox.shrink(), // keeps space so title stays left
        title: const Text(
          'AbsorpCalc',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 40,
            fontFamily: 'OpenSans',
            color: Color(0xFF1A237E),
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Calculate and visualize the sound absorption of materials using the Impedance Tube Method',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            const Text(
              'Using the Transfer Function Method, this app helps you calculate the sound absorption coefficient of materials quickly and accurately.',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {
                // Navigate to next page (Input Page)
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => InputPage()));
              },
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                textStyle: const TextStyle(fontSize: 18),
              ),
              child: const Text('Start Measurement'),
            ),
            const SizedBox(height: 20),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Navigate to next page (Input Page)
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AbsorptionTableScreen(
                      material: 'Default Material',
                      frequency: 1000,
                      p1: 1.0,
                      p2: 0.5,
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                textStyle: const TextStyle(fontSize: 18),
              ),
              child: const Text('View Calculations'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Navigate to next page (Input Page)
                // Navigator.push(context,
                //     MaterialPageRoute(builder: (context)=>
                //         AbsorptionGraphStatic()
                //     )
                // );
              },
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                textStyle: const TextStyle(fontSize: 18),
              ),
              child: const Text('Show Graph'),
            ),
            const Spacer(),
            IconButton(
              icon: const Icon(Icons.info_outline, size: 30),
              onPressed: () => _showProjectInfo(context),
              tooltip: 'About the Project',
            ),
          ],
        ),
      ),
    );
  }
}
