import 'package:flutter/material.dart';

class ModeSelectionPage extends StatelessWidget {
  const ModeSelectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFE6E6FA), // Light purple theme
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Choose Calculation Mode',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF6A5ACD), // Slightly deeper purple
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              buildModeButton(
                context,
                icon: Icons.edit,
                label: 'Manual Input',
                mode: 'manual',
              ),
              const SizedBox(height: 20),
              buildModeButton(
                context,
                icon: Icons.bluetooth,
                label: 'Real-Time via Bluetooth',
                mode: 'realtime',
              ),
              const SizedBox(height: 20),
              buildModeButton(
                context,
                icon: Icons.videogame_asset,
                label: 'Demo Mode',
                mode: 'demo',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildModeButton(BuildContext context,
      {required IconData icon, required String label, required String mode}) {
    return ElevatedButton.icon(
      icon: Icon(icon, size: 28),
      label: Text(label, style: TextStyle(fontSize: 20)),
      style: ElevatedButton.styleFrom(
        backgroundColor: Color(0xFFB19CD9),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        elevation: 5,
      ),
      onPressed: () {
        //Navigator.pushNamed(context, '/input', arguments: mode);
        Navigator.pushNamed(context, '/blueTooth');
      },
    );
  }
}
