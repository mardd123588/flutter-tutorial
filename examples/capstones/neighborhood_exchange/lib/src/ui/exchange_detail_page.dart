import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../data/exchange_repository.dart';
import '../data/exchange_storage_service.dart';
import '../domain/exchange_models.dart';
import '../domain/exchange_url_codec.dart';
import '../state/exchange_providers.dart';
import 'exchange_components.dart';
import 'exchange_theme.dart';

class ExchangeDetailPage extends StatelessWidget {
  const ExchangeDetailPage({
    super.key,
    required this.listingId,
    required this.uri,
  });

  final String listingId;
  final Uri uri;

  @override
  Widget build(BuildContext context) {
    final query = const ExchangeUrlCodec().parse(uri);
    final backLocation = const ExchangeUrlCodec().encode(
      path: '/exchange',
      query: query,
    );
    return Scaffold(
      body: Column(
        children: [
          ExchangeHeader(
            showBack: true,
            onBack: () => context.go(backLocation.toString()),
          ),
          Expanded(
            child: ExchangeDetailPanel(
              listingId: listingId,
              query: query,
              standalone: true,
            ),
          ),
        ],
      ),
    );
  }
}

class ExchangeDetailPanel extends ConsumerWidget {
  const ExchangeDetailPanel({
    super.key,
    required this.listingId,
    required this.query,
    this.standalone = false,
  });

  final String listingId;
  final ExchangeQuery query;
  final bool standalone;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detail = ref.watch(exchangeListingProvider(listingId));
    return ColoredBox(
      color: standalone ? exchangeBoard : exchangePaperMuted,
      child: detail.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => ExchangeStatePanel(
          icon: Icons.sync_problem,
          title: '详情暂时打不开',
          message: '浏览器没有完成本地数据读取。可以重新加载这条记录。',
          actionLabel: '重新加载',
          action: () => ref.invalidate(exchangeListingProvider(listingId)),
        ),
        data: (result) => switch (result) {
          ExchangeSuccess<ExchangeListing>(:final value) => _ListingDetail(
            listing: value,
            query: query,
            standalone: standalone,
          ),
          ExchangeFailureResult<ExchangeListing>(:final failure) =>
            _DetailFailure(failure: failure, query: query),
        },
      ),
    );
  }
}

class _ListingDetail extends ConsumerWidget {
  const _ListingDetail({
    required this.listing,
    required this.query,
    required this.standalone,
  });

  final ExchangeListing listing;
  final ExchangeQuery query;
  final bool standalone;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final claimState = ref.watch(claimListingProvider);
    final isClaiming = claimState.activeListingId == listing.id;
    final claimSucceeded = claimState.successListingId == listing.id;
    final canClaim = listing.canBeClaimedBy(localUserId);
    return ListView(
      padding: EdgeInsets.all(standalone ? 24 : 20),
      children: [
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: Material(
              color: exchangePaper,
              elevation: standalone ? 3 : 0,
              shadowColor: exchangeInk.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(14),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        StatusLabel(listing.status),
                        if (listing.origin == ListingOrigin.local)
                          const Chip(
                            avatar: Icon(Icons.storage_outlined, size: 18),
                            label: Text('仅此浏览器'),
                          ),
                        Chip(label: Text(listing.category.label)),
                      ],
                    ),
                    const SizedBox(height: 18),
                    Text(
                      listing.title,
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 12),
                    Text(listing.description),
                    const Divider(height: 38),
                    DetailFact(
                      icon: Icons.inventory_2_outlined,
                      label: '剩余数量',
                      value:
                          '${listing.remainingQuantity} / ${listing.totalQuantity} 份',
                    ),
                    const SizedBox(height: 16),
                    DetailFact(
                      icon: Icons.schedule,
                      label: '可取时段',
                      value: listing.availableWindow.label,
                    ),
                    const SizedBox(height: 16),
                    DetailFact(
                      icon: Icons.place_outlined,
                      label: '片区与交接',
                      value:
                          '${listing.neighborhood.label} · ${listing.handoffMethod.label}',
                    ),
                    const SizedBox(height: 16),
                    DetailFact(
                      icon: Icons.person_outline,
                      label: '发布者',
                      value: listing.ownerDisplayName,
                    ),
                    if (listing.origin == ListingOrigin.local) ...[
                      const SizedBox(height: 22),
                      Material(
                        color: exchangeGreenSoft,
                        borderRadius: BorderRadius.circular(8),
                        child: const Padding(
                          padding: EdgeInsets.all(14),
                          child: Text('这条记录没有上传到服务器。其他浏览器打开链接时，只会看到本地数据说明。'),
                        ),
                      ),
                    ],
                    const SizedBox(height: 24),
                    Semantics(
                      liveRegion: true,
                      label: claimSucceeded
                          ? '认领成功。结果仅保存在当前浏览器。'
                          : _claimFailureMessage(claimState.failure),
                      child: claimSucceeded
                          ? const Text(
                              '已认领一份，结果仅保存在当前浏览器。',
                              key: ValueKey('claim-success'),
                              style: TextStyle(
                                color: exchangeGreen,
                                fontWeight: FontWeight.w800,
                              ),
                            )
                          : claimState.failure == null
                          ? const SizedBox.shrink()
                          : Text(
                              _claimFailureMessage(claimState.failure),
                              key: const ValueKey('claim-failure'),
                              style: const TextStyle(
                                color: exchangeError,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        FilledButton.icon(
                          key: const ValueKey('claim-listing'),
                          onPressed: canClaim && !isClaiming
                              ? () => ref
                                    .read(claimListingProvider.notifier)
                                    .claim(listing.id)
                              : null,
                          style: FilledButton.styleFrom(
                            backgroundColor: exchangeRust,
                          ),
                          icon: isClaiming
                              ? const SizedBox.square(
                                  dimension: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(Icons.local_offer_outlined),
                          label: Text(_claimActionLabel(listing, isClaiming)),
                        ),
                        OutlinedButton.icon(
                          key: const ValueKey('copy-listing-link'),
                          onPressed: () => _copyLink(context, ref),
                          icon: const Icon(Icons.link),
                          label: const Text('复制链接'),
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
    );
  }

  Future<void> _copyLink(BuildContext context, WidgetRef ref) async {
    if (listing.origin == ListingOrigin.local) {
      final shouldCopy = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('这个链接只在当前浏览器有完整内容'),
          content: const Text('其他浏览器没有这条本地记录，会显示说明页。仍要复制链接吗？'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('暂不复制'),
            ),
            FilledButton(
              key: const ValueKey('confirm-copy-local-link'),
              onPressed: () => Navigator.pop(context, true),
              child: const Text('仍然复制'),
            ),
          ],
        ),
      );
      if (shouldCopy != true || !context.mounted) return;
    }
    final route = const ExchangeUrlCodec().encode(
      path: '/listings/${listing.id}',
      query: query,
    );
    final link = Uri.base.replace(fragment: route.toString()).toString();
    await ref.read(resourceShareServiceProvider).copyLink(link);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          listing.origin == ListingOrigin.local
              ? '链接已复制；记录仍只在当前浏览器。'
              : '固定资源链接已复制。',
        ),
      ),
    );
  }
}

class _DetailFailure extends StatelessWidget {
  const _DetailFailure({required this.failure, required this.query});

  final ExchangeFailure failure;
  final ExchangeQuery query;

  @override
  Widget build(BuildContext context) {
    final notFound = failure is ExchangeNotFoundFailure
        ? failure as ExchangeNotFoundFailure
        : null;
    final localOnly = notFound?.localOnly ?? false;
    return ExchangeStatePanel(
      panelKey: ValueKey(localOnly ? 'local-only-missing' : 'missing-listing'),
      icon: localOnly ? Icons.storage_outlined : Icons.find_in_page_outlined,
      title: localOnly ? '这条记录属于另一个浏览器' : '找不到这条资源',
      message: localOnly
          ? '链接指向一条本地发布记录。静态站点没有共享后端，所以当前浏览器无法取得它。内置资源仍可正常浏览。'
          : '资源编号无效，或当前演示数据中没有这条记录。筛选条件仍然保留。',
      actionLabel: '返回资源公告板',
      action: () => context.go(
        const ExchangeUrlCodec()
            .encode(path: '/exchange', query: query)
            .toString(),
      ),
    );
  }
}

String _claimActionLabel(ExchangeListing listing, bool isClaiming) {
  if (isClaiming) return '正在认领';
  if (listing.claimedByCurrentUser) return '已经认领';
  if (listing.ownerId == localUserId) return '不能认领自己的资源';
  if (listing.status != ExchangeStatus.available) return listing.status.label;
  return '认领一份';
}

String _claimFailureMessage(ExchangeFailure? failure) {
  if (failure == null) return '';
  return switch (failure) {
    ExchangeClaimFailure(reason: ClaimWriteResult.ownListing) => '不能认领自己发布的资源。',
    ExchangeClaimFailure(reason: ClaimWriteResult.unavailable) =>
      '这条资源已经不能认领，请返回列表选择其他资源。',
    ExchangeClaimFailure(reason: ClaimWriteResult.notFound) => '这条资源已经不存在。',
    ExchangeStorageFailure() => '认领没有写入本地数据库，请重试。',
    _ => '认领没有完成，请重试。',
  };
}
