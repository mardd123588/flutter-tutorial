import 'package:json_annotation/json_annotation.dart';

import 'event.dart';

part 'event_dto.g.dart';

// #region generated-event-dto
@JsonSerializable()
class CityEventDto {
  const CityEventDto({
    required this.id,
    required this.title,
    required this.venue,
    required this.district,
    required this.startsAt,
    required this.priceLabel,
    required this.summary,
    required this.tags,
    required this.signal,
  });

  factory CityEventDto.fromJson(Map<String, Object?> json) =>
      _$CityEventDtoFromJson(json);

  final String id;
  final String title;
  final String venue;
  final String district;
  @JsonKey(name: 'starts_at')
  final DateTime startsAt;
  @JsonKey(name: 'price_label')
  final String priceLabel;
  final String summary;
  final List<String> tags;
  final int signal;

  Map<String, Object?> toJson() => _$CityEventDtoToJson(this);

  CityEvent toDomain() {
    return CityEvent(
      id: id,
      title: title,
      venue: venue,
      district: district,
      startsAt: startsAt,
      priceLabel: priceLabel,
      summary: summary,
      tags: List.unmodifiable(tags),
      signal: signal,
    );
  }
}
// #endregion generated-event-dto
