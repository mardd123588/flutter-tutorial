import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:instant_book_search/src/book.dart';
import 'package:instant_book_search/src/book_search_service.dart';
import 'package:instant_book_search/src/instant_book_search_app.dart';

void main() {
  testWidgets('shows loading and then successful results', (tester) async {
    await tester.pumpWidget(
      InstantBookSearchApp(
        service: ImmediateBookSearchService(),
        debounceDuration: Duration.zero,
      ),
    );

    await tester.enterText(find.byKey(const ValueKey('search-field')), '河');
    await tester.pump();
    expect(find.textContaining('正在检索'), findsOneWidget);

    await tester.pumpAndSettle();
    expect(find.text('河流索引'), findsOneWidget);
    expect(find.byKey(const ValueKey('result-book-river')), findsOneWidget);
  });

  testWidgets('shows an empty response without calling it an error', (
    tester,
  ) async {
    await tester.pumpWidget(
      InstantBookSearchApp(
        service: ImmediateBookSearchService(),
        debounceDuration: Duration.zero,
      ),
    );

    await tester.enterText(find.byKey(const ValueKey('search-field')), '无结果');
    await tester.pumpAndSettle();

    expect(find.textContaining('没有匹配'), findsOneWidget);
    expect(find.textContaining('空结果是一次成功响应'), findsOneWidget);
  });

  testWidgets('keeps the layout usable at 320px and 200% text scale', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(640, 1440);
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(textScaler: TextScaler.linear(2)),
        child: InstantBookSearchApp(service: ImmediateBookSearchService()),
      ),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.byKey(const ValueKey('search-field')), findsOneWidget);
  });

  testWidgets('disables result transitions when animations are disabled', (
    tester,
  ) async {
    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(disableAnimations: true),
        child: InstantBookSearchApp(service: ImmediateBookSearchService()),
      ),
    );
    await tester.pumpAndSettle();

    final switcher = tester.widget<AnimatedSwitcher>(
      find.byType(AnimatedSwitcher),
    );
    expect(switcher.duration, Duration.zero);
  });
}

class ImmediateBookSearchService implements BookSearchService {
  @override
  Future<List<Book>> search(String query) async {
    await Future<void>.delayed(const Duration(milliseconds: 10));
    if (query == '无结果') return const [];
    return const [
      Book(
        id: 'river',
        title: '河流索引',
        author: '林岫',
        year: 2023,
        shelf: 'N-14',
        note: '教学记录',
      ),
    ];
  }
}
