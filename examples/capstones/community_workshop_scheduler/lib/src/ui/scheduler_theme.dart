import 'package:flutter/material.dart';

const dispatchInk = Color(0xFF131B1E);
const dispatchInkSoft = Color(0xFF263238);
const dispatchBlue = Color(0xFF17547A);
const dispatchBlueDeep = Color(0xFF0D344E);
const dispatchEnamel = Color(0xFFF0E6D2);
const dispatchPaper = Color(0xFFFFFAEF);
const dispatchGreen = Color(0xFF4FD18B);
const dispatchOrange = Color(0xFFF39A43);
const dispatchRed = Color(0xFFB43A32);
const dispatchSteel = Color(0xFF64757B);
const dispatchRule = Color(0xFF9AA4A5);

ThemeData buildSchedulerTheme() {
  const controlShape = RoundedRectangleBorder(
    borderRadius: BorderRadius.all(Radius.circular(6)),
  );
  final scheme = ColorScheme.fromSeed(
    seedColor: dispatchBlue,
    brightness: Brightness.light,
    primary: dispatchBlue,
    onPrimary: Colors.white,
    secondary: dispatchGreen,
    onSecondary: dispatchInk,
    error: dispatchRed,
    surface: dispatchPaper,
    onSurface: dispatchInk,
  );
  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: dispatchEnamel,
    canvasColor: dispatchPaper,
    dividerColor: dispatchRule,
    focusColor: dispatchGreen.withValues(alpha: 0.36),
    hoverColor: dispatchGreen.withValues(alpha: 0.16),
    textSelectionTheme: const TextSelectionThemeData(
      cursorColor: dispatchBlue,
      selectionColor: Color(0x664FD18B),
      selectionHandleColor: dispatchBlue,
    ),
    textTheme: const TextTheme(
      displaySmall: TextStyle(
        fontFamily: 'Georgia',
        fontSize: 42,
        height: 0.98,
        fontWeight: FontWeight.w800,
        letterSpacing: -1.2,
      ),
      headlineSmall: TextStyle(
        fontSize: 25,
        height: 1.08,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.4,
      ),
      titleMedium: TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
      bodyLarge: TextStyle(fontSize: 16, height: 1.45),
      bodyMedium: TextStyle(fontSize: 14, height: 1.42),
      labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size(48, 48),
        shape: controlShape,
        textStyle: const TextStyle(fontWeight: FontWeight.w800),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(48, 48),
        shape: controlShape,
        side: const BorderSide(color: dispatchInk),
        foregroundColor: dispatchInk,
        textStyle: const TextStyle(fontWeight: FontWeight.w800),
      ),
    ),
    inputDecorationTheme: const InputDecorationTheme(
      filled: true,
      fillColor: dispatchPaper,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(6)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(6)),
        borderSide: BorderSide(color: dispatchInkSoft),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(6)),
        borderSide: BorderSide(color: dispatchGreen, width: 3),
      ),
    ),
    cardTheme: const CardThemeData(
      color: dispatchPaper,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(8)),
      ),
    ),
    dialogTheme: const DialogThemeData(
      backgroundColor: dispatchPaper,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(8)),
      ),
    ),
    scrollbarTheme: ScrollbarThemeData(
      thumbColor: WidgetStateProperty.all(dispatchSteel),
      trackColor: WidgetStateProperty.all(dispatchEnamel),
      thickness: WidgetStateProperty.all(10),
      radius: const Radius.circular(2),
    ),
  );
}
