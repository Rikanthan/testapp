import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late AnimationController _logoController;
  late Animation<double> _rotationAnimation;
  late Animation<double> _scaleAnimation;
  late AnimationController _textController;
  late AnimationController _buttonController;

  @override
  void initState() {
    super.initState();

    _logoController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 2),
    );

    _rotationAnimation = Tween<double>(begin: 0, end: 2 * 3.1416).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.easeOut),
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.elasticOut),
    );

    _textController = AnimationController(vsync: this, duration: Duration(seconds: 1));
    _buttonController = AnimationController(vsync: this, duration: Duration(seconds: 1));

    _logoController.forward().then((_) {
      _textController.forward().then((_) {
        _buttonController.forward();
      });
    });
  }

  @override
  void dispose() {
    _logoController.dispose();
    _textController.dispose();
    _buttonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Light purple background
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedBuilder(
              animation: _logoController,
              builder: (context, child) {
                return Transform.rotate(
                  angle: _rotationAnimation.value,
                  child: Transform.scale(
                    scale: _scaleAnimation.value,
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Color(0xFFB19CD9).withOpacity(0.6),
                            blurRadius: 20,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child: Image.asset(
                          'assets/images/impedance_tube.png',
                          width: 200,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
            SizedBox(height: 30),
            FadeTransition(
              opacity: _textController,
              child: Text(
                'AbsorpCalc',
                style: TextStyle(
                  fontSize: 40,
                  fontFamily: 'Cursive',
                  color: Colors.purple,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(height: 50),
            FadeTransition(
              opacity: _buttonController,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFB19CD9),
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
                onPressed: () {
                  Navigator.pushNamed(context, '/mode');

                },
                child: Text(
                  'Mode',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF6A5ACD),
                  ),
                    textAlign: TextAlign.center,
                  ),

                  ),
                ),
          ],
        ),
      ),
    );
  }
}

