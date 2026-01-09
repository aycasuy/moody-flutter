import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:untitled8/MainScreens/welcome_screen.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedSplashScreen(
      duration: 3500,
      backgroundColor: Colors.amberAccent,
      splashIconSize: 3000,
      splash: Stack(
        alignment: Alignment.center,
        children: [

          Center(child: Lottie.asset('assets/Animation - 1746894628763.json')),

          Positioned(
            bottom: 120,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color.fromRGBO(255, 255, 255, 0.3),
                    const Color.fromRGBO(255, 255, 255, 0.1),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: const Color.fromRGBO(255, 255, 255, 0.2),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color.fromRGBO(0, 0, 0, 0.2),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: ShaderMask(
                shaderCallback: (bounds) => LinearGradient(
                  colors: const [Colors.white, Color(0xFFBBDEFB)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ).createShader(bounds),
                child: Text(
                  'MOODY',
                  style: TextStyle(
                    fontSize: 42,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.5,
                    fontFamily: 'Poppins',
                    height: 1.2,
                  ),
                ),
              ),
            ),
          ),

          // Subtitle
          Positioned(
            bottom: 60,
            child: Text(
              'Her gün bir his, her his bir hikâye!',
              style: TextStyle(
                color: const Color.fromRGBO(5, 0, 0, 0.9019607843137255),
                fontSize: 18,
                letterSpacing: 4,
                fontWeight: FontWeight.w300,
              ),
            ),
          ),
        ],
      ),
      nextScreen: const WelcomeScreen(),
    );
  }
}
