import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:instant_book_search/src/book.dart';
import 'package:instant_book_search/src/book_search_controller.dart';
import 'package:instant_book_search/src/book_search_service.dart';

void main() {
  test('a late response cannot overwrite the newer query', () async {
    final service = ControlledBookSearchService();
    final controller = BookSearchController(
      service: service,
      debounceDuration: Duration.zero,
    );

    final oldRequest = controller.searchNow('星');
    final newRequest = controller.searchNow('河');
    service.complete('河', const [riverBook]);
    await newRequest;
    service.complete('星', const [starBook]);
    await oldRequest;

    expect(controller.settledQuery, '河');
    expect(controller.results.single.id, 'river');
    expect(controller.ignoredResponseCount, 1);
    controller.dispose();
  });

  test(
    'keeps successful results visible while the next request loads',
    () async {
      final service = ControlledBookSearchService();
      final controller = BookSearchController(service: service);

      final first = controller.searchNow('河');
      service.complete('河', const [riverBook]);
      await first;
      final second = controller.searchNow('星');

      expect(controller.phase, BookSearchPhase.loading);
      expect(controller.keepsPreviousResults, isTrue);
      expect(controller.results.single.id, 'river');

      service.complete('星', const [starBook]);
      await second;
      controller.dispose();
    },
  );

  test('retry starts another request for the current query', () async {
    final service = ControlledBookSearchService();
    final controller = BookSearchController(service: service);

    final first = controller.searchNow('断线');
    service.fail('断线', const BookSearchException('暂时断线'));
    await first;
    expect(controller.phase, BookSearchPhase.failure);

    final retry = controller.retry();
    service.complete('断线', const [retryBook]);
    await retry;

    expect(controller.phase, BookSearchPhase.success);
    expect(controller.results.single.id, 'retry');
    controller.dispose();
  });
}

class ControlledBookSearchService implements BookSearchService {
  final Map<String, List<Completer<List<Book>>>> _requests = {};

  @override
  Future<List<Book>> search(String query) {
    final completer = Completer<List<Book>>();
    _requests.putIfAbsent(query, () => []).add(completer);
    return completer.future;
  }

  void complete(String query, List<Book> result) {
    _requests[query]!.removeAt(0).complete(result);
  }

  void fail(String query, Object error) {
    _requests[query]!.removeAt(0).completeError(error);
  }
}

const riverBook = Book(
  id: 'river',
  title: '河流索引',
  author: '林岫',
  year: 2023,
  shelf: 'N-14',
  note: '教学记录',
);

const starBook = Book(
  id: 'star',
  title: '星图修复手册',
  author: '周鹤龄',
  year: 2021,
  shelf: 'A-03',
  note: '教学记录',
);

const retryBook = Book(
  id: 'retry',
  title: '断线以后',
  author: '程野',
  year: 2024,
  shelf: 'C-11',
  note: '教学记录',
);
