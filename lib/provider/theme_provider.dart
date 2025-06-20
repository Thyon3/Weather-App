import 'package:flutter/material.dart';
import 'package:riverpod/riverpod.dart';

class ThemeProvider extends Notifier<ThemeMode> {
  @override
  ThemeMode build() {
    return ThemeMode.light;
  }

  void toggleTheme() {
    state = state == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
  }
}

final themeProvider = NotifierProvider<ThemeProvider, ThemeMode>(
  () => ThemeProvider(),
);
