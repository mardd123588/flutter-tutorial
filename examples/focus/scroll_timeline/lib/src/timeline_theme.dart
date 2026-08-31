import 'package:flutter/material.dart';

const archiveCharcoal = Color(0xFF202725);
const archiveCharcoalSoft = Color(0xFF37423E);
const archivePaper = Color(0xFFF4EBDD);
const archivePaperBright = Color(0xFFFFFAF1);
const mineralBlue = Color(0xFF1E6675);
const mineralBlueDeep = Color(0xFF16434D);
const copper = Color(0xFFB76035);
const moss = Color(0xFF5D7258);
const archiveRule = Color(0xFFB9AC98);

ThemeData buildTimelineTheme() {
  final colorScheme =
      ColorScheme.fromSeed(
        seedColor: mineralBlue,
        brightness: Brightness.light,
        surface: archivePaperBright,
      ).copyWith(
        primary: mineralBlueDeep,
        secondary: copper,
        onPrimary: archivePaperBright,
        onSecondary: archivePaperBright,
        onSurface: archiveCharcoal,
        error: const Color(0xFFA4322A),
      );

  return ThemeData(
    useMaterial3: true,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: archivePaper,
    focusColor: copper,
    textSelectionTheme: const TextSelectionThemeData(
      cursorColor: copper,
      selectionColor: Color(0x55B76035),
      selectionHandleColor: copper,
    ),
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        fontFamily: 'serif',
        fontSize: 48,
        height: 0.98,
        fontWeight: FontWeight.w800,
        letterSpacing: -1.2,
      ),
      headlineLarge: TextStyle(
        fontFamily: 'serif',
        fontSize: 32,
        height: 1.05,
        fontWeight: FontWeight.w800,
      ),
      headlineSmall: TextStyle(
        fontSize: 22,
        height: 1.15,
        fontWeight: FontWeight.w800,
      ),
      bodyLarge: TextStyle(fontSize: 17, height: 1.55),
      bodyMedium: TextStyle(fontSize: 15, height: 1.5),
      labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
    ),
    chipTheme: const ChipThemeData(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(8)),
        side: BorderSide(color: archiveRule),
      ),
      selectedColor: mineralBlueDeep,
      checkmarkColor: archivePaperBright,
      labelStyle: TextStyle(fontWeight: FontWeight.w700),
      secondaryLabelStyle: TextStyle(
        color: archivePaperBright,
        fontWeight: FontWeight.w800,
      ),
    ),
  );
}
