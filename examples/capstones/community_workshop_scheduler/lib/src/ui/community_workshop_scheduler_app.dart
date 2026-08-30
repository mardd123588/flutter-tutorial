import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'schedule_board_page.dart';
import 'scheduler_theme.dart';
import 'session_pages.dart';

GoRouter createWorkshopSchedulerRouter({String initialLocation = '/schedule'}) {
  return GoRouter(
    initialLocation: initialLocation,
    routes: [
      GoRoute(path: '/', redirect: (context, state) => '/schedule'),
      GoRoute(
        path: '/schedule',
        builder: (context, state) => ScheduleBoardPage(uri: state.uri),
      ),
      GoRoute(
        path: '/new',
        builder: (context, state) => WorkshopEditorPage(uri: state.uri),
      ),
      GoRoute(
        path: '/sessions/:sessionId/edit',
        builder: (context, state) => WorkshopEditorPage(
          uri: state.uri,
          sessionId: state.pathParameters['sessionId'],
        ),
      ),
      GoRoute(
        path: '/sessions/:sessionId',
        builder: (context, state) =>
            SessionDetailPage(sessionId: state.pathParameters['sessionId']!),
      ),
    ],
    errorBuilder: (context, state) => SchedulerRouteErrorPage(uri: state.uri),
  );
}

class CommunityWorkshopSchedulerApp extends StatelessWidget {
  const CommunityWorkshopSchedulerApp({required this.router, super.key});

  final GoRouter router;

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: '社区工坊排期台',
      debugShowCheckedModeBanner: false,
      theme: buildSchedulerTheme(),
      routerConfig: router,
    );
  }
}

class SchedulerRouteErrorPage extends StatelessWidget {
  const SchedulerRouteErrorPage({required this.uri, super.key});

  final Uri uri;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.route_outlined, size: 48),
                const SizedBox(height: 18),
                Text(
                  '没有这张排期页',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 10),
                Text('地址“$uri”无法识别。返回排期台后，已保存的本地排期不会丢失。'),
                const SizedBox(height: 20),
                FilledButton.icon(
                  onPressed: () => context.go('/schedule'),
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('返回排期台'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
