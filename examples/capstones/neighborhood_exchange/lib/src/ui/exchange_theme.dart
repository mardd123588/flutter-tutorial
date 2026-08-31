import 'package:flutter/material.dart';

const exchangeInk = Color(0xFF20352E);
const exchangeInkSoft = Color(0xFF3D5149);
const exchangeBoard = Color(0xFFE5DDC7);
const exchangePaper = Color(0xFFFFF9E9);
const exchangePaperMuted = Color(0xFFF3EBD7);
const exchangeRust = Color(0xFFA9422D);
const exchangeGreen = Color(0xFF3F684C);
const exchangeGreenSoft = Color(0xFFDCE7CE);
const exchangeGold = Color(0xFFC18A2D);
const exchangeBlue = Color(0xFF315E66);
const exchangeRule = Color(0xFF7B7365);
const exchangeError = Color(0xFFA52F2F);

ThemeData buildExchangeTheme() {
  const controlShape = RoundedRectangleBorder(
    borderRadius: BorderRadius.all(Radius.circular(8)),
  );
  final scheme = ColorScheme.fromSeed(
    seedColor: exchangeGreen,
    brightness: Brightness.light,
    primary: exchangeGreen,
    onPrimary: Colors.white,
    secondary: exchangeRust,
    onSecondary: Colors.white,
    error: exchangeError,
    surface: exchangePaper,
    onSurface: exchangeInk,
  );
  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: exchangeBoard,
    canvasColor: exchangePaper,
    dividerColor: exchangeRule,
    focusColor: exchangeGold.withValues(alpha: 0.34),
    hoverColor: exchangeGreen.withValues(alpha: 0.12),
    textSelectionTheme: const TextSelectionThemeData(
      cursorColor: exchangeRust,
      selectionColor: Color(0x663F684C),
      selectionHandleColor: exchangeRust,
    ),
    textTheme: const TextTheme(
      displaySmall: TextStyle(
        fontFamily: 'Georgia',
        fontSize: 40,
        height: 1.02,
        fontWeight: FontWeight.w800,
        letterSpacing: -1.1,
      ),
      headlineMedium: TextStyle(
        fontFamily: 'Georgia',
        fontSize: 29,
        height: 1.08,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.5,
      ),
      headlineSmall: TextStyle(
        fontSize: 23,
        height: 1.12,
        fontWeight: FontWeight.w800,
      ),
      titleLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
      titleMedium: TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
      bodyLarge: TextStyle(fontSize: 16, height: 1.48),
      bodyMedium: TextStyle(fontSize: 14, height: 1.45),
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
        side: const BorderSide(color: exchangeInk, width: 1.2),
        foregroundColor: exchangeInk,
        textStyle: const TextStyle(fontWeight: FontWeight.w800),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        minimumSize: const Size(48, 48),
        foregroundColor: exchangeInk,
        textStyle: const TextStyle(fontWeight: FontWeight.w800),
      ),
    ),
    inputDecorationTheme: const InputDecorationTheme(
      filled: true,
      fillColor: exchangePaper,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(8)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(8)),
        borderSide: BorderSide(color: exchangeRule),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(8)),
        borderSide: BorderSide(color: exchangeGold, width: 3),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(8)),
        borderSide: BorderSide(color: exchangeError, width: 2),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(8)),
        borderSide: BorderSide(color: exchangeError, width: 3),
      ),
    ),
    dialogTheme: const DialogThemeData(
      backgroundColor: exchangePaper,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: exchangePaper,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
    ),
    scrollbarTheme: ScrollbarThemeData(
      thumbColor: WidgetStateProperty.all(exchangeRule),
      trackColor: WidgetStateProperty.all(exchangePaperMuted),
      thickness: WidgetStateProperty.all(9),
      radius: const Radius.circular(3),
    ),
  );
}
