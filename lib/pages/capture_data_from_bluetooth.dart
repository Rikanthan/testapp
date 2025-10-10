import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:testapp/pages/db_help.dart';

class BluetoothScreen extends StatefulWidget {
  const BluetoothScreen({super.key});

  @override
  State<BluetoothScreen> createState() => _BluetoothScreenState();
}

class _BluetoothScreenState extends State<BluetoothScreen> {
  List<ScanResult> scanResults = [];
  BluetoothDevice? connectedDevice;
  List<BluetoothService> services = [];
  String receivedValue = "";

  @override
  void initState() {
    super.initState();
    startScan();
  }

  Future<void> _getDataFromBlueToothAndSave(double p2) async {
    String material = "Ble_Material";
    double frequency = 4000.34;
    double p1 = 1000;

    double reflectionCoefficient = p2 / p1;
    double calculatedAbsorption =
        1 - (reflectionCoefficient * reflectionCoefficient);
    calculatedAbsorption = calculatedAbsorption.clamp(0.0, 1.0);

    await DBHelper.instance.insertMeasurement({
      'material': material,
      'frequency': frequency,
      'p1': p1,
      'p2': p2,
      'absorption': calculatedAbsorption,
      'createdAt': DateTime.now().toIso8601String(),
    });
  }

  void startScan() async {
    setState(() => scanResults.clear());

    await FlutterBluePlus.startScan(
      timeout: const Duration(seconds: 5),
      withServices: [
        // ✅ Filter to specific services if you know them
        Guid('0000aaa1-0000-1000-8000-aabbccddeeff'),
        Guid('0000aaa0-0000-1000-8000-aabbccddeeff'),
      ],
    );

    FlutterBluePlus.scanResults.listen((results) {
      setState(() {
        scanResults = results;
      });
    });

    FlutterBluePlus.isScanning.listen((scanning) {
      if (!scanning) {
        FlutterBluePlus.stopScan();
      }
    });
  }

  Future<void> connectToDevice(BluetoothDevice device) async {
    try {
      print("🔗 Connecting to ${device.remoteId.str} ...");

      await device.connect(
        license: License.free, // ✅ required in flutter_blue_plus 2.x
        timeout: const Duration(seconds: 15),
        autoConnect: false,
      );

      // ✅ request larger MTU after connection (instead of in connect)
      try {
        await device.requestMtu(512);
        print("📡 MTU set to 512");
      } catch (e) {
        print("⚠️ MTU request failed: $e");
      }

      setState(() {
        connectedDevice = device;
      });

      services = await device.discoverServices();

      for (var service in services) {
        print("🟦 Service: ${service.uuid}");
        for (var c in service.characteristics) {
          print("   🔹 Characteristic: ${c.uuid}");
          print("      props: read=${c.properties.read}, "
              "write=${c.properties.write}, "
              "notify=${c.properties.notify}, "
              "indicate=${c.properties.indicate}");
          if (c.properties.read) {
            try {
              await c.read(timeout: 20);
              c.lastValueStream.listen((value) {
                setState(() {
                  receivedValue = String.fromCharCodes(value);
                });
                print("📥 Read from ${c.uuid}: $receivedValue");
              });
            } catch (e) {
              print("❌ Failed to enable read on ${c.uuid}: $e");
            }
          }

          // Auto-subscribe if notify supported
          if (c.properties.notify || c.properties.indicate) {
            try {
              await c.setNotifyValue(true);
              c.lastValueStream.listen((value) async {
                setState(() {
                  receivedValue = String.fromCharCodes(value);
                });
                await _getDataFromBlueToothAndSave(receivedValue as double);
                print("📥 Notify from ${c.uuid}: $receivedValue");
              });
            } catch (e) {
              print("❌ Failed to enable notify on ${c.uuid}: $e");
            }
          }
        }
      }
    } catch (e) {
      print("❌ Error: $e");
    }
  }

  Future<void> readCharacteristic(
      BluetoothCharacteristic characteristic) async {
    try {
      var value = await characteristic.read();
      setState(() {
        receivedValue = String.fromCharCodes(value);
      });
      await _getDataFromBlueToothAndSave(receivedValue as double);
      print("🔎 Read from ${characteristic.uuid}: $receivedValue");
    } catch (e) {
      print("❌ Read error: $e");
    }
  }

  Future<void> writeCharacteristic(
      BluetoothCharacteristic characteristic, String data) async {
    try {
      await characteristic.write(utf8.encode(data), withoutResponse: false);
      print("✍️ Wrote '$data' to ${characteristic.uuid}");
    } catch (e) {
      print("❌ Write error: $e");
    }
  }

  Future<void> disconnect() async {
    await connectedDevice?.disconnect();
    setState(() {
      connectedDevice = null;
      services.clear();
      receivedValue = "";
    });
    print("🔌 Disconnected");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("BLE Explorer"),
        actions: [
          if (connectedDevice != null)
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: disconnect,
            )
        ],
      ),
      body: connectedDevice == null
          ? ListView.builder(
              itemCount: scanResults.length,
              itemBuilder: (context, index) {
                final result = scanResults[index];
                final name = result.device.platformName.isNotEmpty
                    ? result.device.platformName
                    : result.device.remoteId.str;
                return ListTile(
                  title: Text(name),
                  subtitle: Text(result.device.remoteId.str),
                  onTap: () => connectToDevice(result.device),
                );
              },
            )
          : ListView(
              children: [
                ListTile(
                  title: Text("Connected: ${connectedDevice!.platformName}"),
                  subtitle: Text(connectedDevice!.remoteId.str),
                ),
                const Divider(),
                ...services.expand((s) => s.characteristics).map(
                      (c) => ListTile(
                        title: Text("Characteristic: ${c.uuid}"),
                        subtitle: Text("Last value: $receivedValue"),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (c.properties.read)
                              IconButton(
                                icon: const Icon(Icons.download),
                                onPressed: () => readCharacteristic(c),
                              ),
                            if (c.properties.write)
                              IconButton(
                                icon: const Icon(Icons.upload),
                                onPressed: () =>
                                    writeCharacteristic(c, "Hello"),
                              ),
                            if (c.properties.notify || c.properties.indicate)
                              const Icon(Icons.notifications_active,
                                  color: Colors.green),
                          ],
                        ),
                      ),
                    ),
              ],
            ),
      floatingActionButton: connectedDevice == null
          ? FloatingActionButton(
              onPressed: startScan, child: const Icon(Icons.search))
          : null,
    );
  }
}
