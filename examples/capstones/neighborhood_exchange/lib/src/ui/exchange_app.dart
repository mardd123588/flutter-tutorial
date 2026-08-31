import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../data/exchange_repository.dart';
import '../state/exchange_providers.dart';
import 'exchange_browse_page.dart';
import 'exchange_components.dart';
import 'exchange_detail_page.dart';
import 'exchange_publish_page.dart';
import 'exchange_theme.dart';

GoRouter createExchangeRouter({String initialLocation = '/exchange'}) {
  return GoRouter(
    initialLocation: initialLocation,
    routes: [
      GoRoute(path: '/', redirect: (context, state) => '/exchange'),
      GoRoute(
        path: '/exchange',
        builder: (context, state) => ExchangeBrowsePage(uri: state.uri),
      ),
      GoRoute(
        path: '/listings/:listingId',
        builder: (context, state) => ExchangeListingRoutePage(
          listingId: state.pathParameters['listingId']!,
          uri: state.uri,
        ),
      ),
      GoRoute(
        path: '/publish',
        builder: (context, state) => const ExchangePublishPage(),
      ),
      GoRoute(
        path: '/about',
        builder: (context, state) => const ExchangeAboutPage(),
      ),
    ],
    errorBuilder: (context, state) => const _RouteErrorPage(),
  );
}

class NeighborhoodExchangeApp extends StatelessWidget {
  const NeighborhoodExchangeApp({
    super.key,
    required this.router,
    this.builder,
  });

  final GoRouter router;
  final TransitionBuilder? builder;

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: '邻里资源交换站',
      theme: buildExchangeTheme(),
      routerConfig: router,
      builder: builder,
    );
  }
}

class ExchangeListingRoutePage extends StatelessWidget {
  const ExchangeListingRoutePage({
    super.key,
    required this.listingId,
    required this.uri,
  });

  final String listingId;
  final Uri uri;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 1100) {
          return ExchangeBrowsePage(uri: uri, selectedListingId: listingId);
        }
        return ExchangeDetailPage(listingId: listingId, uri: uri);
      },
    );
  }
}

class ExchangeAboutPage extends ConsumerWidget {
  const ExchangeAboutPage({super.key});

  static const appEnvironment = String.fromEnvironment(
    'APP_ENV',
    defaultValue: 'local',
  );
  static const contentVersion = String.fromEnvironment(
    'CONTENT_VERSION',
    defaultValue: 'working-tree',
  );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Column(
        children: [
          ExchangeHeader(showBack: true, onBack: () => context.go('/exchange')),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 760),
                    child: Material(
                      color: exchangePaper,
                      borderRadius: BorderRadius.circular(14),
                      child: Padding(
                        padding: const EdgeInsets.all(28),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '这是一座静态演示站',
                              style: Theme.of(context).textTheme.displaySmall,
                            ),
                            const SizedBox(height: 18),
                            const Text(
                              '48 条内置资源随构建发布，所以固定链接能在其他浏览器恢复。你发布的资源和认领结果只写入当前浏览器，不会同步给邻居，也不代表社区的实时库存。',
                            ),
                            const SizedBox(height: 24),
                            const DetailFact(
                              icon: Icons.public,
                              label: '跨浏览器可恢复',
                              value: '仅限编号为 r-001 至 r-048 的内置资源。',
                            ),
                            const SizedBox(height: 16),
                            const DetailFact(
                              icon: Icons.storage_outlined,
                              label: '仅此浏览器',
                              value: '本地发布、认领和恢复演示数据。',
                            ),
                            const SizedBox(height: 16),
                            const DetailFact(
                              icon: Icons.shield_outlined,
                              label: '没有秘密',
                              value: '构建环境和版本会公开显示；客户端不保存 token 或私钥。',
                            ),
                            const Divider(height: 40),
                            Text(
                              '公开构建信息',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const SizedBox(height: 12),
                            SelectableText('APP_ENV=$appEnvironment'),
                            SelectableText('CONTENT_VERSION=$contentVersion'),
                            const SizedBox(height: 24),
                            Wrap(
                              spacing: 10,
                              runSpacing: 10,
                              children: [
                                FilledButton.icon(
                                  onPressed: () => context.go('/exchange'),
                                  icon: const Icon(Icons.view_list_outlined),
                                  label: const Text('返回资源公告板'),
                                ),
                                OutlinedButton.icon(
                                  key: const ValueKey('restore-demo-data'),
                                  onPressed: () => _restore(context, ref),
                                  icon: const Icon(Icons.restart_alt),
                                  label: const Text('恢复演示数据'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _restore(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('恢复 48 条内置资源？'),
        content: const Text('当前浏览器里的本地发布和认领记录会被删除。这个操作不会影响其他浏览器。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          FilledButton(
            key: const ValueKey('confirm-restore-demo-data'),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('确认恢复'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    final result = await ref.read(exchangeRepositoryProvider).restoreDemoData();
    if (!context.mounted) return;
    final message = switch (result) {
      ExchangeSuccess<void>() => '已恢复 48 条内置资源。',
      ExchangeFailureResult<void>() => '恢复失败，请重新加载后再试。',
    };
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }
}

class _RouteErrorPage extends StatelessWidget {
  const _RouteErrorPage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ExchangeStatePanel(
        icon: Icons.signpost_outlined,
        title: '这个入口不存在',
        message: '地址没有对应页面。资源和筛选没有被修改。',
        actionLabel: '返回资源公告板',
        action: () => context.go('/exchange'),
      ),
    );
  }
}
