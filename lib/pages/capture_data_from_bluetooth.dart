import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

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

  void startScan() async {
    setState(() => scanResults.clear());

    await FlutterBluePlus.startScan(
        timeout: const Duration(seconds: 5),
        withServices: [Guid('0000aaa1-0000-1000-8000-aabbccddeeff')]);

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
        license: License.free, // ✅ Required in 2.x
        timeout: const Duration(seconds: 15),
        mtu: 512,
        autoConnect: false,
      );

      setState(() {
        connectedDevice = device;
      });

      services = await device.discoverServices();

      for (var service in services) {
        print("Service: ${service.uuid}");
        for (var c in service.characteristics) {
          print("  Characteristic: ${c.uuid}");
          print("    props: read=${c.properties.read}, "
              "write=${c.properties.write}, "
              "notify=${c.properties.notify}");

          // Auto-subscribe if notify supported
          if (c.properties.notify) {
            await c.setNotifyValue(true);
            c.lastValueStream.listen((value) {
              setState(() {
                receivedValue = String.fromCharCodes(value);
              });
              print("📡 Notify from ${c.uuid}: $value");
            });
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
                                onPressed: () => writeCharacteristic(
                                    c, "Hello"), // test write
                              ),
                            if (c.properties.notify)
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
