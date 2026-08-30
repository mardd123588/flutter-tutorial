import 'venue_data.dart';

const _allowedQueryParameters = {'floor', 'tag'};

enum VenueLinkIssue {
  unmatchedPath,
  unknownVenue,
  duplicateParameter,
  unsupportedParameter,
  invalidFloor,
  unavailableFloor,
  invalidTag,
}

sealed class VenueLinkResult {
  const VenueLinkResult();
}

class ValidVenueLink extends VenueLinkResult {
  const ValidVenueLink({required this.venue, required this.selection});

  final Venue venue;
  final VenueSelection selection;
}

class InvalidVenueLink extends VenueLinkResult {
  const InvalidVenueLink(
    this.issue, {
    this.venueId,
    this.parameter,
    this.value,
    this.floor,
  });

  final VenueLinkIssue issue;
  final String? venueId;
  final String? parameter;
  final String? value;
  final int? floor;
}

class VenueSelection {
  const VenueSelection({required this.floor, this.tag});

  final int floor;
  final VenueTag? tag;

  VenueSelection copyWith({int? floor, VenueTag? tag, bool clearTag = false}) {
    return VenueSelection(
      floor: floor ?? this.floor,
      tag: clearTag ? null : tag ?? this.tag,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is VenueSelection && other.floor == floor && other.tag == tag;
  }

  @override
  int get hashCode => Object.hash(floor, tag);
}

// #region venue-url-codec
class VenueUrlCodec {
  const VenueUrlCodec();

  VenueLinkResult parse(Uri uri) {
    final segments = uri.pathSegments;
    if (segments.length != 2 || segments.first != 'venues') {
      return const InvalidVenueLink(VenueLinkIssue.unmatchedPath);
    }

    final venueId = segments[1];
    final venue = venueById(venueId);
    if (venue == null) {
      return InvalidVenueLink(VenueLinkIssue.unknownVenue, venueId: venueId);
    }

    for (final parameter in uri.queryParametersAll.keys) {
      if (!_allowedQueryParameters.contains(parameter)) {
        return InvalidVenueLink(
          VenueLinkIssue.unsupportedParameter,
          venueId: venueId,
          parameter: parameter,
        );
      }
    }

    for (final entry in uri.queryParametersAll.entries) {
      if (entry.value.length != 1) {
        return InvalidVenueLink(
          VenueLinkIssue.duplicateParameter,
          venueId: venueId,
          parameter: entry.key,
        );
      }
    }

    final floorValue = uri.queryParameters['floor'];
    final floor = floorValue == null
        ? venue.floors.first
        : int.tryParse(floorValue);
    if (floor == null) {
      return InvalidVenueLink(
        VenueLinkIssue.invalidFloor,
        venueId: venueId,
        parameter: 'floor',
        value: floorValue,
      );
    }
    if (!venue.floors.contains(floor)) {
      return InvalidVenueLink(
        VenueLinkIssue.unavailableFloor,
        venueId: venueId,
        parameter: 'floor',
        floor: floor,
      );
    }

    final tagValue = uri.queryParameters['tag'];
    VenueTag? tag;
    if (tagValue != null) {
      tag = VenueTag.values
          .where((candidate) => candidate.id == tagValue)
          .firstOrNull;
      if (tag == null || !venue.tags.contains(tag)) {
        return InvalidVenueLink(
          VenueLinkIssue.invalidTag,
          venueId: venueId,
          parameter: 'tag',
          value: tagValue,
        );
      }
    }

    return ValidVenueLink(
      venue: venue,
      selection: VenueSelection(floor: floor, tag: tag),
    );
  }

  Uri encode(Venue venue, VenueSelection selection) {
    final query = <String, String>{};
    if (selection.floor != venue.floors.first) {
      query['floor'] = selection.floor.toString();
    }
    if (selection.tag != null) {
      query['tag'] = selection.tag!.id;
    }
    return Uri(
      path: '/venues/${venue.id}',
      queryParameters: query.isEmpty ? null : query,
    );
  }
}
// #endregion venue-url-codec

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull {
    final iterator = this.iterator;
    return iterator.moveNext() ? iterator.current : null;
  }
}
