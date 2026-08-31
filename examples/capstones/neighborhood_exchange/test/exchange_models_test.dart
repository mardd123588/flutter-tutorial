import 'package:flutter_test/flutter_test.dart';
import 'package:neighborhood_exchange/src/data/fixture_exchange_service.dart';
import 'package:neighborhood_exchange/src/domain/exchange_models.dart';
import 'package:neighborhood_exchange/src/domain/exchange_url_codec.dart';

void main() {
  test('fixture has 48 stable ids across six neighborhoods and categories', () {
    expect(fixtureExchangeListings, hasLength(48));
    expect(fixtureExchangeListings.first.id, 'r-001');
    expect(fixtureExchangeListings.last.id, 'r-048');
    expect(
      fixtureExchangeListings.map((listing) => listing.neighborhood).toSet(),
      hasLength(6),
    );
    expect(
      fixtureExchangeListings.map((listing) => listing.category).toSet(),
      hasLength(6),
    );
  });

  test('status is derived from completion and remaining quantity', () {
    final available = fixtureExchangeListings.first;
    expect(available.status, ExchangeStatus.available);
    expect(
      available.copyWith(remainingQuantity: 0).status,
      ExchangeStatus.reserved,
    );
    final completed = fixtureExchangeListings.firstWhere(
      (listing) => listing.completedAt != null,
    );
    expect(completed.status, ExchangeStatus.completed);
  });

  test('query intersects filters and keeps a stable id tie breaker', () {
    final query = ExchangeQuery(
      search: '工具',
      category: ExchangeCategory.tools,
      sort: ExchangeSort.title,
    );
    final source = fixtureExchangeListings
        .where((listing) => listing.category == ExchangeCategory.tools)
        .map(
          (listing) => ExchangeListing(
            id: listing.id,
            origin: listing.origin,
            title: '${listing.title} 工具',
            description: listing.description,
            category: listing.category,
            neighborhood: listing.neighborhood,
            handoffMethod: listing.handoffMethod,
            availableWindow: listing.availableWindow,
            totalQuantity: listing.totalQuantity,
            remainingQuantity: listing.remainingQuantity,
            ownerId: listing.ownerId,
            ownerDisplayName: listing.ownerDisplayName,
            createdAt: listing.createdAt,
            updatedAt: listing.updatedAt,
          ),
        );
    final result = query.apply(source);
    expect(result, isNotEmpty);
    expect(
      result,
      orderedEquals(
        [...result]..sort((a, b) {
          final title = a.title.compareTo(b.title);
          return title != 0 ? title : a.id.compareTo(b.id);
        }),
      ),
    );
  });

  test('publish validation counts graphemes and quantity boundaries', () {
    final draft = PublishDraft(
      title: List.filled(41, '👨‍👩‍👧‍👦').join(),
      description: '',
      category: ExchangeCategory.tools,
      neighborhood: Neighborhood.qinghe,
      handoffMethod: HandoffMethod.locker,
      availableWindow: AvailableWindow.values.first,
      quantityText: '10',
    );
    expect(draft.validate(), containsPair('title', contains('40')));
    expect(draft.validate(), containsPair('quantity', contains('1 到 9')));
  });

  test('url codec normalizes invalid values and round trips known filters', () {
    const codec = ExchangeUrlCodec();
    final parsed = codec.parse(
      Uri.parse('/exchange?q=钻&category=tools&status=unknown&view=compactGrid'),
    );
    expect(parsed.search, '钻');
    expect(parsed.category, ExchangeCategory.tools);
    expect(parsed.status, isNull);
    expect(parsed.view, ExchangeView.compactGrid);
    expect(
      codec.encode(path: '/exchange', query: parsed).toString(),
      '/exchange?q=%E9%92%BB&category=tools&view=compactGrid',
    );
  });
}
