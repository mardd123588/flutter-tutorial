import 'package:city_event_radar/src/event_feed.dart';
import 'package:city_event_radar/src/event_fixture.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('hand-written envelope and generated DTO parse the same fixture', () {
    final feed = EventFeed.fromJsonString(fixturePayload());

    expect(feed.events, hasLength(6));
    expect(feed.events.first.title, '河岸听觉散步');
    expect(feed.events.first.tags, contains('声音'));
  });

  test('unknown fields are ignored', () {
    final source = fixturePayload().replaceFirst(
      '"events":',
      '"unknown":"kept out of the model","events":',
    );

    expect(EventFeed.fromJsonString(source).events, hasLength(6));
  });

  test('a missing generated field becomes a located format error', () {
    final source = fixturePayload().replaceFirst('"venue":"东岸旧泵站",', '');

    expect(
      () => EventFeed.fromJsonString(source),
      throwsA(
        isA<FormatException>().having(
          (error) => error.message,
          'message',
          contains('events[0] 解析失败'),
        ),
      ),
    );
  });
}
