import 'package:flutter/material.dart';

final lightTheme = ThemeData(
  primaryColor: Color(0xFF1a1a16),
  brightness: Brightness.light,
  colorScheme: ColorScheme.light(
    primary: Color.fromARGB(26, 255, 255, 255),
    secondary: Colors.white,
    surface: Colors.white30,
    onSecondary: Colors.black,
    onPrimary: Colors.white70,
  ),
);
final darkTheme = ThemeData(
  primaryColor: Color(0xFFFAFAFA),
  brightness: Brightness.dark,
  colorScheme: ColorScheme.dark(
    primary: Color.fromARGB(31, 0, 0, 0),
    secondary: Colors.black,
    surface: Colors.black38,
    onPrimary: Colors.black38,
  ),
);
