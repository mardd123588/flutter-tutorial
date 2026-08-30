import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import 'event_feed.dart';
import 'event_fixture.dart';

abstract interface class EventService {
  Future<EventFetch> fetch(String query);
}

abstract interface class NetworkModeControl {
  bool get online;
  void setOnline(bool value);
}

class EventServiceException implements Exception {
  const EventServiceException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() => message;
}

class EventFetch {
  const EventFetch({required this.feed, required this.rawJson});

  final EventFeed feed;
  final String rawJson;
}

class HttpEventService implements EventService {
  const HttpEventService({
    required this.client,
    this.timeout = const Duration(seconds: 5),
  });

  final http.Client client;
  final Duration timeout;

  @override
  Future<EventFetch> fetch(String query) async {
    final uri = Uri.https('fixture.invalid', '/city-events', {'q': query});
    late final http.Response response;
    try {
      response = await client.get(uri).timeout(timeout);
    } on TimeoutException {
      throw const EventServiceException('活动服务响应超时');
    } on http.ClientException catch (error) {
      throw EventServiceException('无法连接活动服务：${error.message}');
    }

    if (response.statusCode != 200) {
      throw EventServiceException(
        '活动服务返回 HTTP ${response.statusCode}',
        statusCode: response.statusCode,
      );
    }

    try {
      return EventFetch(
        feed: EventFeed.fromJsonString(response.body),
        rawJson: response.body,
      );
    } on FormatException catch (error) {
      throw EventServiceException('活动数据无法解析：${error.message}');
    }
  }
}

class FixtureEventClient extends http.BaseClient implements NetworkModeControl {
  FixtureEventClient([this._online = true]);

  bool _online;

  @override
  bool get online => _online;

  @override
  void setOnline(bool value) => _online = value;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    final query = request.url.queryParameters['q']?.trim() ?? '';
    await Future<void>.delayed(_delayFor(query));
    if (!_online) {
      throw http.ClientException('teaching fixture is offline');
    }
    final bytes = utf8.encode(fixturePayload(query: query));
    return http.StreamedResponse(
      Stream.value(bytes),
      200,
      headers: const {'content-type': 'application/json; charset=utf-8'},
    );
  }

  Duration _delayFor(String query) {
    return switch (query) {
      '夜' => const Duration(milliseconds: 760),
      '河' => const Duration(milliseconds: 120),
      _ => const Duration(milliseconds: 260),
    };
  }
}
