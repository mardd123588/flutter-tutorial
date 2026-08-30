import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../l10n/app_localizations.dart';
import 'supporting_pages.dart';
import 'venue_guide_controller.dart';
import 'venue_shell.dart';
import 'venue_url_codec.dart';
import 'venues_page.dart';

const guideCobalt = Color(0xFF1238C7);
const guideCobaltDeep = Color(0xFF08227F);
const guideChartreuse = Color(0xFFD8FF3E);
const guidePaper = Color(0xFFF4EDCF);
const guidePaperBright = Color(0xFFFFF9E7);
const guideInk = Color(0xFF111827);
const guideMutedInk = Color(0xFF4B5363);
const guideRule = Color(0xFFB8B08F);
const guideError = Color(0xFFB6322A);

// #region venue-guide-router
GoRouter createVenueGuideRouter({
  required VenueGuideController controller,
  String initialLocation = '/',
}) {
  const codec = VenueUrlCodec();
  return GoRouter(
    initialLocation: initialLocation,
    redirect: (context, state) => state.uri.path == '/' ? '/venues' : null,
    routes: [
      ShellRoute(
        builder: (context, state, child) => VenueShell(
          key: const ValueKey('venue-shell'),
          controller: controller,
          uri: state.uri,
          child: child,
        ),
        routes: [
          GoRoute(
            path: '/venues',
            builder: (context, state) => VenuesPage(controller: controller),
          ),
          GoRoute(
            path: '/venues/:venueId',
            builder: (context, state) {
              final result = codec.parse(state.uri);
              return switch (result) {
                ValidVenueLink() => VenueDetailPage(
                  key: ValueKey(state.uri.toString()),
                  venue: result.venue,
                  selection: result.selection,
                ),
                InvalidVenueLink() => VenueLinkErrorPage(result: result),
              };
            },
          ),
          GoRoute(
            path: '/routes',
            builder: (context, state) => const GuideRoutesPage(),
          ),
          GoRoute(
            path: '/about',
            builder: (context, state) => const GuideAboutPage(),
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) => UnmatchedGuidePage(uri: state.uri),
  );
}
// #endregion venue-guide-router

class VenueGuidebookApp extends StatelessWidget {
  const VenueGuidebookApp({
    required this.controller,
    required this.router,
    this.textDirectionOverride,
    super.key,
  });

  final VenueGuideController controller;
  final GoRouter router;
  final TextDirection? textDirectionOverride;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        return MaterialApp.router(
          debugShowCheckedModeBanner: false,
          onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
          locale: controller.locale,
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          routerConfig: router,
          theme: _guideTheme(),
          builder: (context, child) {
            final content = child ?? const SizedBox.shrink();
            final direction = textDirectionOverride;
            return direction == null
                ? content
                : Directionality(textDirection: direction, child: content);
          },
        );
      },
    );
  }
}

ThemeData _guideTheme() {
  final scheme = ColorScheme.fromSeed(
    seedColor: guideCobalt,
    brightness: Brightness.light,
    surface: guidePaper,
    error: guideError,
  );
  const squareShape = RoundedRectangleBorder();
  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: guidePaper,
    canvasColor: guidePaperBright,
    focusColor: guideChartreuse.withValues(alpha: 0.42),
    hoverColor: guideChartreuse.withValues(alpha: 0.24),
    dividerColor: guideRule,
    textSelectionTheme: const TextSelectionThemeData(
      cursorColor: guideCobalt,
      selectionColor: Color(0x66D8FF3E),
      selectionHandleColor: guideCobalt,
    ),
    inputDecorationTheme: const InputDecorationTheme(
      filled: true,
      fillColor: guidePaperBright,
      border: OutlineInputBorder(borderRadius: BorderRadius.zero),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.zero,
        borderSide: BorderSide(color: guideInk),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.zero,
        borderSide: BorderSide(color: guideChartreuse, width: 3),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size(48, 48),
        backgroundColor: guideCobalt,
        foregroundColor: Colors.white,
        shape: squareShape,
        textStyle: const TextStyle(fontWeight: FontWeight.w800),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(48, 48),
        foregroundColor: guideInk,
        shape: squareShape,
        side: const BorderSide(color: guideInk),
        textStyle: const TextStyle(fontWeight: FontWeight.w800),
      ),
    ),
    iconButtonTheme: IconButtonThemeData(
      style: IconButton.styleFrom(
        minimumSize: const Size(48, 48),
        shape: squareShape,
      ),
    ),
    dialogTheme: const DialogThemeData(
      backgroundColor: guidePaperBright,
      shape: squareShape,
    ),
  );
}
