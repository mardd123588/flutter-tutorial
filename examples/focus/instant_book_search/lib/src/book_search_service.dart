import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import 'book.dart';

abstract interface class BookSearchService {
  Future<List<Book>> search(String query);
}

class BookSearchException implements Exception {
  const BookSearchException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() => message;
}

// #region injectable-http-service
class HttpBookSearchService implements BookSearchService {
  const HttpBookSearchService({
    required this._client,
    this.timeout = const Duration(seconds: 4),
  });

  final http.Client _client;
  final Duration timeout;

  @override
  Future<List<Book>> search(String query) async {
    final uri = Uri.https('fixture.invalid', '/books', {'q': query});
    late final http.Response response;

    try {
      response = await _client.get(uri).timeout(timeout);
    } on TimeoutException {
      throw const BookSearchException('请求超时，请重试');
    } on http.ClientException catch (error) {
      throw BookSearchException('网络请求失败：${error.message}');
    }

    if (response.statusCode != 200) {
      throw BookSearchException(
        '服务暂时不可用（HTTP ${response.statusCode}）',
        statusCode: response.statusCode,
      );
    }

    try {
      final decoded = jsonDecode(response.body);
      if (decoded is! Map<String, Object?>) {
        throw const FormatException('响应根节点必须是对象');
      }
      final items = decoded['items'];
      if (items is! List<Object?>) {
        throw const FormatException('items 必须是数组');
      }
      return items
          .map((item) {
            if (item is! Map<String, Object?>) {
              throw const FormatException('items 中的条目必须是对象');
            }
            return Book.fromJson(item);
          })
          .toList(growable: false);
    } on FormatException catch (error) {
      throw BookSearchException('响应格式错误：${error.message}');
    } on JsonUnsupportedObjectError catch (error) {
      throw BookSearchException('响应格式错误：${error.toString()}');
    }
  }
}
// #endregion injectable-http-service

class FixtureBookClient extends http.BaseClient {
  FixtureBookClient({this.defaultDelay = const Duration(milliseconds: 260)});

  final Duration defaultDelay;
  final Map<String, int> _attempts = <String, int>{};

  static const _books = <Map<String, Object?>>[
    {
      'id': 'river-atlas',
      'title': '河流档案的十二种读法',
      'author': '林岫',
      'year': 2023,
      'shelf': 'N-14',
      'note': '从水文记录、口述史与旧地图交叉读取一条河。',
    },
    {
      'id': 'river-night',
      'title': '夜航河道图',
      'author': '余湛',
      'year': 2019,
      'shelf': 'T-08',
      'note': '一册关于渡口灯号与沿岸声音的田野笔记。',
    },
    {
      'id': 'star-repair',
      'title': '星图修复手册',
      'author': '周鹤龄',
      'year': 2021,
      'shelf': 'A-03',
      'note': '辨认旧星图的纸张、墨色与缺损标记。',
    },
    {
      'id': 'signal-retry',
      'title': '断线以后：信号重连笔记',
      'author': '程野',
      'year': 2024,
      'shelf': 'C-11',
      'note': '把失败、重试与重复消息放进同一套记录方法。',
    },
    {
      'id': 'paper-weather',
      'title': '纸上天气站',
      'author': '闻青',
      'year': 2020,
      'shelf': 'M-06',
      'note': '用风向、云量和气压制作一册城市天气日志。',
    },
  ];

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    final query = request.url.queryParameters['q']?.trim() ?? '';
    final attempt = (_attempts[query] ?? 0) + 1;
    _attempts[query] = attempt;

    await Future<void>.delayed(_delayFor(query));

    if (query == '断线' && attempt == 1) {
      return http.StreamedResponse(
        Stream.value(utf8.encode('{"message":"fixture unavailable"}')),
        503,
        headers: const {'content-type': 'application/json; charset=utf-8'},
      );
    }

    final normalized = query.toLowerCase();
    final matches = query == '无结果'
        ? const <Map<String, Object?>>[]
        : _books
              .where((book) {
                final haystack =
                    '${book['title']} ${book['author']} ${book['note']}'
                        .toLowerCase();
                return normalized.isEmpty || haystack.contains(normalized);
              })
              .toList(growable: false);
    final body = jsonEncode({'query': query, 'items': matches});

    return http.StreamedResponse(
      Stream.value(utf8.encode(body)),
      200,
      headers: const {'content-type': 'application/json; charset=utf-8'},
    );
  }

  Duration _delayFor(String query) {
    return switch (query) {
      '星' => const Duration(milliseconds: 850),
      '河' => const Duration(milliseconds: 120),
      '断线' => const Duration(milliseconds: 180),
      _ => defaultDelay,
    };
  }
}
