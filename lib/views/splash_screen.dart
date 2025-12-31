import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:weather_app/views/colors.dart';
import 'package:weather_app/views/home_screen.dart';
import 'package:weather_app/views/myElevatedButton.dart';

class SplashScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _SplaschScreenState();
  }
}

class _SplaschScreenState extends State<SplashScreen> {
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(const Duration(seconds: 3), _navigateToHome);
  }

  void _navigateToHome() {
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const HomeScreen()),
    );
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            width: size.width,
            padding: const EdgeInsets.symmetric(vertical: 90, horizontal: 24),
            child: Column(
              children: [
                Text(
                  'Discover The\n Weather in Your City',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.roboto(
                    textStyle: const TextStyle(
                      color: Colors.white,
                      fontSize: 35,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                Image.asset(
                  'assets/images/weatherGirl.png',
                  height: size.height * 0.45,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 32),
                Text(
                  'Get to know your weather map and\n forecast ahead of everyone to plan your perfect day.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.lato(
                    textStyle: const TextStyle(
                      color: Colors.white70,
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                Myelevatedbutton(
                  ontap: () {
                    _timer.cancel();
                    _navigateToHome();
                  },
                  text: "Get started",
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
