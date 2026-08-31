import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../domain/archive_query.dart';
import '../state/archive_providers.dart';
import 'archive_theme.dart';

class ArchiveComparePage extends ConsumerWidget {
  const ArchiveComparePage({super.key, required this.uri});

  final Uri uri;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final comparison = ref.watch(archiveComparisonProvider);
    final records = ref.watch(archiveRecordsProvider);
    final query = ArchiveQuery.fromUri(uri);
    return Scaffold(
      appBar: AppBar(
        title: const Text('记录对照'),
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
          final selected = [
            for (final id in comparison.ids)
              ...values.where((record) => record.id == id),
          ];
          if (selected.length < 2) {
            return const Center(child: Text('至少加入两条记录才能开始对照。'));
          }
          return ListView(
            padding: const EdgeInsets.fromLTRB(24, 28, 24, 56),
            children: [
              Text('并排读出差异', style: Theme.of(context).textTheme.displayMedium),
              const SizedBox(height: 20),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columns: [
                    const DataColumn(label: Text('字段')),
                    for (final record in selected)
                      DataColumn(
                        label: SizedBox(width: 180, child: Text(record.title)),
                      ),
                  ],
                  rows: [
                    _row('年代', selected.map((record) => '${record.year}')),
                    _row(
                      '人物',
                      selected.map((record) => record.people.join('、')),
                    ),
                    _row('媒介', selected.map((record) => record.medium.label)),
                    _row('开放状态', selected.map((record) => record.access.label)),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  DataRow _row(String label, Iterable<String> values) {
    return DataRow(
      cells: [
        DataCell(
          Text(
            label,
            style: const TextStyle(color: cyan, fontWeight: FontWeight.w800),
          ),
        ),
        ...values.map((value) => DataCell(Text(value))),
      ],
    );
  }
}
