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

void main() {
  if (!kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.windows ||
          defaultTargetPlatform == TargetPlatform.linux ||
          defaultTargetPlatform == TargetPlatform.macOS)) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  // Register license for flutter_blue_plus so it appears in the app's Licenses/About list.
  // You can replace the string below with the full license text (or load it from an asset).
  LicenseRegistry.addLicense(() async* {
    yield LicenseEntryWithLineBreaks(
      ['flutter_blue_plus'],
      'flutter_blue_plus\n\n'
      'This app uses the flutter_blue_plus package to connect via Bluetooth Low Energy (BLE).\n'
      'Source: https://pub.dev/packages/flutter_blue_plus\n'
      'License: BSD-3-Clause',
    );
  });

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
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF9C27B0)),
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
