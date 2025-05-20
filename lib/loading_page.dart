import 'package:flutter/material.dart';

class LoadingPage extends StatefulWidget {
  @override
  _LoadingPageState createState() => _LoadingPageState();
}

class _LoadingPageState extends State<LoadingPage>
    with TickerProviderStateMixin {
  late AnimationController _dropController;
  late Animation<double> _dropAnimation;
  late AnimationController _fadeController;
  late List<Animation<double>> _letterFadeAnimations;

  @override
  void initState() {
    super.initState();

    // Fuel drop animation (drops down)
    _dropController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 2),
    );

    _dropAnimation = Tween<double>(begin: -100.0, end: 0.0).animate(
      CurvedAnimation(parent: _dropController, curve: Curves.bounceOut),
    );

    _dropController.forward();

    // Letter fade-in animations (fueling effect)
    _fadeController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 2),
    );

    _letterFadeAnimations = List.generate(
      9, // Number of letters in "RAPID FILL"
      (index) => Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _fadeController,
          curve: Interval(index * 0.1, 1.0, curve: Curves.easeIn),
        ),
      ),
    );

    Future.delayed(Duration(milliseconds: 500), () {
      _fadeController.forward();
    });

    Future.delayed(Duration(seconds: 3), () {
      Navigator.pushReplacementNamed(context, '/register');
    });
  }

  @override
  void dispose() {
    _dropController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Changed from orange to black
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedBuilder(
              animation: _dropAnimation,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0, _dropAnimation.value),
                  child: Icon(
                    Icons.local_gas_station_rounded,
                    color: Colors.orange, // Changed from white to orange
                    size: 80,
                  ),
                );
              },
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                9,
                (index) => FadeTransition(
                  opacity: _letterFadeAnimations[index],
                  child: Text(
                    "RAPID FILL"[index],
                    style: TextStyle(
                      fontSize: 50,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange, // Changed from white to orange
                      letterSpacing: 2.0,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
