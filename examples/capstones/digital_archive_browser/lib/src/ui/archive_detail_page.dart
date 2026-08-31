import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../domain/archive_query.dart';
import '../state/archive_providers.dart';
import 'archive_theme.dart';
import 'archive_thumbnail_painter.dart';

class ArchiveDetailPage extends ConsumerWidget {
  const ArchiveDetailPage({
    super.key,
    required this.recordId,
    required this.uri,
  });

  final String recordId;
  final Uri uri;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final records = ref.watch(archiveRecordsProvider);
    final query = ArchiveQuery.fromUri(uri);
    return Scaffold(
      appBar: AppBar(
        title: const Text('档案详情'),
        leading: IconButton(
          tooltip: '返回结果',
          onPressed: () => context.go(query.toUri().toString()),
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: records.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => const Center(child: Text('档案暂时没有加载出来')),
        data: (values) {
          final matches = values.where((record) => record.id == recordId);
          if (matches.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '没有这条档案',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 12),
                  FilledButton(
                    onPressed: () => context.go(query.toUri().toString()),
                    child: const Text('返回档案列表'),
                  ),
                ],
              ),
            );
          }
          final record = matches.single;
          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(28, 30, 28, 56),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 860),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${record.year} · ${record.collection.label}',
                      style: const TextStyle(
                        color: cyan,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      record.title,
                      style: Theme.of(context).textTheme.displayMedium,
                    ),
                    const SizedBox(height: 24),
                    Semantics(
                      image: true,
                      label: '${record.title}的抽象档案缩略图',
                      child: SizedBox(
                        height: 260,
                        width: double.infinity,
                        child: CustomPaint(
                          painter: ArchiveThumbnailPainter(
                            seed: record.thumbnailSeed,
                            collectionIndex: record.collection.index,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 26),
                    Text(
                      record.summary,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 18),
                    Text('相关人物：${record.people.join('、')}'),
                    Text('媒介：${record.medium.label}'),
                    Text('开放状态：${record.access.label}'),
                    const SizedBox(height: 30),
                    FilledButton.icon(
                      onPressed: () => ref
                          .read(archiveComparisonProvider.notifier)
                          .add(
                            record.id,
                            values.map((value) => value.id).toSet(),
                          ),
                      icon: const Icon(Icons.compare_arrows),
                      label: const Text('加入对照'),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
