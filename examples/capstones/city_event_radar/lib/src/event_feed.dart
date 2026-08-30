import 'dart:convert';

import 'event.dart';
import 'event_dto.dart';

class EventFeed {
  const EventFeed({required this.generatedAt, required this.events});

  factory EventFeed.fromJsonString(String source) {
    final decoded = jsonDecode(source);
    if (decoded is! Map<String, Object?>) {
      throw const FormatException('活动响应根节点必须是对象');
    }
    return EventFeed.fromJson(decoded);
  }

  // #region hand-written-feed-envelope
  factory EventFeed.fromJson(Map<String, Object?> json) {
    final generatedAtValue = json['generated_at'];
    final eventValues = json['events'];
    if (generatedAtValue is! String) {
      throw const FormatException('generated_at 必须是字符串');
    }
    if (eventValues is! List<Object?>) {
      throw const FormatException('events 必须是数组');
    }

    final generatedAt = DateTime.tryParse(generatedAtValue);
    if (generatedAt == null) {
      throw const FormatException('generated_at 不是有效时间');
    }

    final events = <CityEvent>[];
    for (var index = 0; index < eventValues.length; index += 1) {
      final value = eventValues[index];
      if (value is! Map<String, Object?>) {
        throw FormatException('events[$index] 必须是对象');
      }
      try {
        events.add(CityEventDto.fromJson(value).toDomain());
      } catch (error) {
        throw FormatException('events[$index] 解析失败：$error');
      }
    }

    return EventFeed(
      generatedAt: generatedAt,
      events: List.unmodifiable(events),
    );
  }
  // #endregion hand-written-feed-envelope

  final DateTime generatedAt;
  final List<CityEvent> events;

  EventFeed matching(String query) {
    return EventFeed(
      generatedAt: generatedAt,
      events: events
          .where((event) => event.matches(query))
          .toList(growable: false),
    );
  }
}
