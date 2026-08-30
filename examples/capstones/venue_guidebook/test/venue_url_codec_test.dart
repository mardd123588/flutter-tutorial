import 'package:flutter_test/flutter_test.dart';
import 'package:venue_guidebook/src/venue_data.dart';
import 'package:venue_guidebook/src/venue_url_codec.dart';

void main() {
  const codec = VenueUrlCodec();

  test('parses a stable place id and default floor', () {
    final result = codec.parse(Uri.parse('/venues/atrium'));

    expect(result, isA<ValidVenueLink>());
    final link = result as ValidVenueLink;
    expect(link.venue.id, 'atrium');
    expect(link.selection, const VenueSelection(floor: 1));
  });

  test('round-trips floor and tag through the query', () {
    final venue = venueById('atrium')!;
    const selection = VenueSelection(floor: 2, tag: VenueTag.accessible);

    final uri = codec.encode(venue, selection);
    final reparsed = codec.parse(uri) as ValidVenueLink;

    expect(uri.toString(), '/venues/atrium?floor=2&tag=accessible');
    expect(reparsed.selection, selection);
  });

  test('omits the default floor from the canonical URL', () {
    final venue = venueById('atrium')!;

    final uri = codec.encode(venue, const VenueSelection(floor: 1));

    expect(uri.toString(), '/venues/atrium');
  });

  test('rejects each illegal URL class separately', () {
    final cases = <String, VenueLinkIssue>{
      '/routes/atrium': VenueLinkIssue.unmatchedPath,
      '/venues/missing': VenueLinkIssue.unknownVenue,
      '/venues/atrium?floor=1&floor=2': VenueLinkIssue.duplicateParameter,
      '/venues/atrium?view=map': VenueLinkIssue.unsupportedParameter,
      '/venues/atrium?floor=two': VenueLinkIssue.invalidFloor,
      '/venues/atrium?floor=4': VenueLinkIssue.unavailableFloor,
      '/venues/atrium?tag=studio': VenueLinkIssue.invalidTag,
    };

    for (final entry in cases.entries) {
      final result = codec.parse(Uri.parse(entry.key));
      expect(result, isA<InvalidVenueLink>(), reason: entry.key);
      expect(
        (result as InvalidVenueLink).issue,
        entry.value,
        reason: entry.key,
      );
    }
  });
}
