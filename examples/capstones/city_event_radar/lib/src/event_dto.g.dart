// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'event_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CityEventDto _$CityEventDtoFromJson(Map<String, dynamic> json) => CityEventDto(
  id: json['id'] as String,
  title: json['title'] as String,
  venue: json['venue'] as String,
  district: json['district'] as String,
  startsAt: DateTime.parse(json['starts_at'] as String),
  priceLabel: json['price_label'] as String,
  summary: json['summary'] as String,
  tags: (json['tags'] as List<dynamic>).map((e) => e as String).toList(),
  signal: (json['signal'] as num).toInt(),
);

Map<String, dynamic> _$CityEventDtoToJson(CityEventDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'venue': instance.venue,
      'district': instance.district,
      'starts_at': instance.startsAt.toIso8601String(),
      'price_label': instance.priceLabel,
      'summary': instance.summary,
      'tags': instance.tags,
      'signal': instance.signal,
    };
