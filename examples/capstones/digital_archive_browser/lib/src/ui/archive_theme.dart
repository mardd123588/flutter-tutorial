import 'package:flutter/material.dart';

const ink = Color(0xFF102A36);
const inkSoft = Color(0xFF294653);
const readingWhite = Color(0xFFF7F3EA);
const paper = Color(0xFFFFFCF5);
const cyan = Color(0xFF2F7F8F);
const cyanLight = Color(0xFFB9D9DB);
const amber = Color(0xFFC57A35);
const plum = Color(0xFF72536F);
const rule = Color(0xFFD4C9B9);

ThemeData buildArchiveTheme() {
  final scheme =
      ColorScheme.fromSeed(
        seedColor: cyan,
        surface: paper,
        brightness: Brightness.light,
      ).copyWith(
        primary: ink,
        secondary: amber,
        onPrimary: paper,
        onSecondary: ink,
        error: const Color(0xFFA4332C),
      );
  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: readingWhite,
    focusColor: amber,
    textTheme: const TextTheme(
      displayMedium: TextStyle(
        fontFamily: 'serif',
        fontSize: 42,
        height: 1.02,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.8,
      ),
      headlineMedium: TextStyle(
        fontFamily: 'serif',
        fontSize: 28,
        height: 1.1,
        fontWeight: FontWeight.w800,
      ),
      headlineSmall: TextStyle(
        fontSize: 20,
        height: 1.2,
        fontWeight: FontWeight.w800,
      ),
      bodyLarge: TextStyle(fontSize: 17, height: 1.5),
      bodyMedium: TextStyle(fontSize: 15, height: 1.45),
      labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
    ),
    inputDecorationTheme: const InputDecorationTheme(
      filled: true,
      fillColor: paper,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(10)),
        borderSide: BorderSide(color: rule),
      ),
    ),
  );
}
