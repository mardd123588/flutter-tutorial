import 'dart:convert';

import 'package:city_event_radar/src/event_fixture.dart';
import 'package:city_event_radar/src/event_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  test('injects the query and parses a successful fixture response', () async {
    final service = HttpEventService(
      client: MockClient((request) async {
        expect(request.url.queryParameters['q'], '河');
        return http.Response.bytes(
          utf8.encode(fixturePayload(query: '河')),
          200,
          headers: const {'content-type': 'application/json; charset=utf-8'},
        );
      }),
    );

    final result = await service.fetch('河');

    expect(result.feed.events.single.id, 'river-listening-walk');
  });

  test('keeps HTTP status in the service error', () async {
    final service = HttpEventService(
      client: MockClient((request) async => http.Response('{}', 503)),
    );

    await expectLater(
      service.fetch(''),
      throwsA(
        isA<EventServiceException>().having(
          (error) => error.statusCode,
          'statusCode',
          503,
        ),
      ),
    );
  });
}
