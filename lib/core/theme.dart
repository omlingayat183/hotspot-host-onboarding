// lib/core/theme.dart
import 'package:flutter/material.dart';

ThemeData appTheme() => ThemeData(
  colorSchemeSeed: const Color(0xFF5B7FFF),
  useMaterial3: true,
  inputDecorationTheme: const InputDecorationTheme(
    filled: true, fillColor: Color(0xFFF6F7FB),
    border: OutlineInputBorder(borderSide: BorderSide(color: Color(0xFFE5E7EB))),
  ),
  scaffoldBackgroundColor: Colors.white,
);
