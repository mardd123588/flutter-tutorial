import 'route_data.dart';

const maxStartLength = 24;

class RoutePreference {
  const RoutePreference({required this.mode, required this.start});

  final RouteMode mode;
  final String start;

  @override
  bool operator ==(Object other) =>
      other is RoutePreference && other.mode == mode && other.start == start;

  @override
  int get hashCode => Object.hash(mode, start);
}

sealed class RouteLinkResult {
  const RouteLinkResult();
}

class ValidRouteLink extends RouteLinkResult {
  const ValidRouteLink({required this.route, required this.preference});

  final TourRoute route;
  final RoutePreference preference;
}

enum RouteLinkIssue {
  unmatchedPath,
  unknownRoute,
  duplicateParameter,
  unsupportedParameter,
  invalidMode,
  emptyStart,
  startTooLong,
}

class InvalidRouteLink extends RouteLinkResult {
  const InvalidRouteLink(
    this.issue, {
    this.routeId,
    this.parameter,
    this.value,
  });

  final RouteLinkIssue issue;
  final String? routeId;
  final String? parameter;
  final String? value;
}

// #region route-url-codec
class RouteUrlCodec {
  const RouteUrlCodec();

  static const supportedParameters = {'mode', 'start'};

  RouteLinkResult parse(Uri uri) {
    final segments = uri.pathSegments;
    if (segments.length != 2 || segments.first != 'routes') {
      return const InvalidRouteLink(RouteLinkIssue.unmatchedPath);
    }

    final routeId = segments[1];
    final route = routeById(routeId);
    if (route == null) {
      return InvalidRouteLink(RouteLinkIssue.unknownRoute, routeId: routeId);
    }

    for (final parameter in uri.queryParametersAll.keys) {
      if (!supportedParameters.contains(parameter)) {
        return InvalidRouteLink(
          RouteLinkIssue.unsupportedParameter,
          routeId: routeId,
          parameter: parameter,
        );
      }
    }

    for (final entry in uri.queryParametersAll.entries) {
      if (entry.value.length != 1) {
        return InvalidRouteLink(
          RouteLinkIssue.duplicateParameter,
          routeId: routeId,
          parameter: entry.key,
        );
      }
    }

    final modeValue = uri.queryParameters['mode'];
    final mode = modeValue == null
        ? RouteMode.balanced
        : RouteMode.values
              .where((candidate) => candidate.id == modeValue)
              .firstOrNull;
    if (mode == null) {
      return InvalidRouteLink(
        RouteLinkIssue.invalidMode,
        routeId: routeId,
        parameter: 'mode',
        value: modeValue,
      );
    }

    final startValue = uri.queryParameters['start'];
    if (startValue != null && startValue.trim().isEmpty) {
      return InvalidRouteLink(
        RouteLinkIssue.emptyStart,
        routeId: routeId,
        parameter: 'start',
      );
    }
    if (startValue != null && startValue.runes.length > maxStartLength) {
      return InvalidRouteLink(
        RouteLinkIssue.startTooLong,
        routeId: routeId,
        parameter: 'start',
        value: startValue,
      );
    }

    return ValidRouteLink(
      route: route,
      preference: RoutePreference(
        mode: mode,
        start: startValue ?? route.stops.first,
      ),
    );
  }

  Uri encode(TourRoute route, RoutePreference preference) {
    final query = <String, String>{};
    if (preference.mode != RouteMode.balanced) {
      query['mode'] = preference.mode.id;
    }
    if (preference.start != route.stops.first) {
      query['start'] = preference.start;
    }
    return Uri(
      path: '/routes/${route.id}',
      queryParameters: query.isEmpty ? null : query,
    );
  }
}
// #endregion route-url-codec

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull {
    final iterator = this.iterator;
    return iterator.moveNext() ? iterator.current : null;
  }
}
