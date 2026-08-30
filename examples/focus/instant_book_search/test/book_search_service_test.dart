import 'dart:async';
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:instant_book_search/src/book_search_service.dart';

void main() {
  test('parses a successful response and ignores unknown fields', () async {
    final client = MockClient((request) async {
      expect(request.url.queryParameters['q'], '河');
      return http.Response.bytes(
        utf8.encode(
          '''{"items":[{"id":"river","title":"河流索引","author":"林岫","year":2023,"shelf":"N-14","note":"教学记录","unknown":true}]}''',
        ),
        200,
        headers: const {'content-type': 'application/json; charset=utf-8'},
      );
    });
    final service = HttpBookSearchService(client: client);

    final books = await service.search('河');

    expect(books.single.title, '河流索引');
  });

  test('turns a non-200 response into a status-aware error', () async {
    final service = HttpBookSearchService(
      client: MockClient((request) async => http.Response('{}', 503)),
    );

    await expectLater(
      service.search('河'),
      throwsA(
        isA<BookSearchException>().having(
          (error) => error.statusCode,
          'statusCode',
          503,
        ),
      ),
    );
  });

  test('reports malformed JSON as a recoverable decode error', () async {
    final service = HttpBookSearchService(
      client: MockClient((request) async => http.Response('{bad json', 200)),
    );

    await expectLater(
      service.search('河'),
      throwsA(
        isA<BookSearchException>().having(
          (error) => error.message,
          'message',
          contains('响应格式错误'),
        ),
      ),
    );
  });

  test('converts a timeout into a retryable error', () async {
    final completer = Completer<http.Response>();
    final service = HttpBookSearchService(
      client: MockClient((request) => completer.future),
      timeout: const Duration(milliseconds: 1),
    );

    await expectLater(
      service.search('河'),
      throwsA(
        isA<BookSearchException>().having(
          (error) => error.message,
          'message',
          '请求超时，请重试',
        ),
      ),
    );
  });
}
