import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'archive_browser_page.dart';
import 'archive_compare_page.dart';
import 'archive_detail_page.dart';
import 'archive_theme.dart';

GoRouter createArchiveRouter({String initialLocation = '/archive'}) {
  return GoRouter(
    initialLocation: initialLocation,
    routes: [
      GoRoute(path: '/', redirect: (context, state) => '/archive'),
      GoRoute(
        path: '/archive',
        builder: (context, state) => ArchiveBrowserPage(uri: state.uri),
      ),
      GoRoute(
        path: '/records/:recordId',
        builder: (context, state) => ArchiveDetailPage(
          recordId: state.pathParameters['recordId']!,
          uri: state.uri,
        ),
      ),
      GoRoute(
        path: '/compare',
        builder: (context, state) => ArchiveComparePage(uri: state.uri),
      ),
    ],
    errorBuilder: (context, state) => const _RouteErrorPage(),
  );
}

class DigitalArchiveBrowserApp extends StatelessWidget {
  const DigitalArchiveBrowserApp({super.key, required this.router});

  final GoRouter router;

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: '数字档案浏览器',
      theme: buildArchiveTheme(),
      routerConfig: router,
    );
  }
}

class _RouteErrorPage extends StatelessWidget {
  const _RouteErrorPage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: FilledButton(
          onPressed: () => context.go('/archive'),
          child: const Text('返回数字档案'),
        ),
      ),
    );
  }
}
