import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:testapp/pages/capture_data_from_bluetooth.dart';

// Page imports
import 'package:testapp/pages/splash_screen.dart';
import 'package:testapp/pages/ModeSelectionPage.dart';
import 'package:testapp/pages/Input.dart';
import 'package:testapp/pages/TableAbsorption.dart';
import 'package:testapp/pages/ViewHistoryPage.dart';
import 'package:testapp/pages/GraphAbsorption.dart';
import '../pages/demo_excel_loader.dart';
import '../pages/AbsorptionCurvesPage.dart';

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

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'AbsorpCalc',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Color(0xFF9C27B0)),
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => SplashScreen(),
        '/mode': (context) => ModeSelectionPage(),
        '/input': (context) => InputPage(),
        '/history': (context) => ViewHistoryPage(),
        '/graph': (context) => AmplitudeFrequencyGraph(),
        '/blueTooth': (context) => BluetoothScreen(),
      },
    );
  }
}
