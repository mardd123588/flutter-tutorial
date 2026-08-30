class CityEvent {
  const CityEvent({
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

  final String id;
  final String title;
  final String venue;
  final String district;
  final DateTime startsAt;
  final String priceLabel;
  final String summary;
  final List<String> tags;
  final int signal;

  bool matches(String query) {
    final normalized = query.trim().toLowerCase();
    if (normalized.isEmpty) return true;
    return '$title $venue $district $summary ${tags.join(' ')}'
        .toLowerCase()
        .contains(normalized);
  }
}
