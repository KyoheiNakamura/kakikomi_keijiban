import 'package:flutter/material.dart';

class SplashPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Builder(builder: (context) {
        return Center(
          child: Image.asset(
            'lib/assets/images/splash_happy_transparent.png',
            scale: 6,
          ),
        );
      }),
    );
  }
}
