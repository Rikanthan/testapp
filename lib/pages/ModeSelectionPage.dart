import 'package:flutter/material.dart';
import '../pages/demo_excel_loader.dart';
import '../pages/AbsorptionCurvesPage.dart';

class ModeSelectionPage extends StatefulWidget {
  const ModeSelectionPage({super.key});

  @override
  State<ModeSelectionPage> createState() => _ModeSelectionPageState();
}

class _ModeSelectionPageState extends State<ModeSelectionPage> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFE6E6FA),
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
                  color: Color(0xFF6A5ACD),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              buildModeButton(
                context,
                icon: Icons.edit,
                label: 'Manual Input',
                mode: 'manual',
                route: '/input',
              ),
              const SizedBox(height: 20),
              buildModeButton(context,
                  icon: Icons.bluetooth,
                  label: 'Real-Time via Bluetooth',
                  mode: 'realtime',
                  route: '/blueTooth'),
              const SizedBox(height: 20),
              buildModeButton(
                context,
                icon: Icons.videogame_asset,
                label: 'Demo Mode',
                mode: 'demo',
                route: '/demo',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildModeButton(BuildContext context,
      {required IconData icon,
      required String label,
      required String mode,
      required String route}) {
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
        Navigator.pushNamed(context, '/input', arguments: mode);
      },
    );
  }

  Widget buildDemoModeButton(BuildContext context) {
    return ElevatedButton.icon(
      icon: Icon(Icons.videogame_asset, size: 28),
      label: Text('Demo Mode', style: TextStyle(fontSize: 20)),
      style: ElevatedButton.styleFrom(
        backgroundColor: Color(0xFFB19CD9),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        elevation: 5,
      ),
      onPressed: _isLoading
          ? null
          : () async {
              setState(() => _isLoading = true);
              try {
                final demoData = await pickExcelFileFromPhone();

                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: Text('Proceed to Graph?'),
                    content: Text(
                        'Demo data loaded. Do you want to view the graph?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, false),
                        child: Text('Cancel'),
                      ),
                      ElevatedButton(
                        onPressed: () => Navigator.pop(ctx, true),
                        child: Text('Yes'),
                      ),
                    ],
                  ),
                );

                if (confirm == true) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AbsorptionCurvesPage(demoData: demoData),
                    ),
                  );
                }
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Failed to load Excel file: $e')),
                );
              } finally {
                setState(() => _isLoading = false);
              }
            },
    );
  }
}
