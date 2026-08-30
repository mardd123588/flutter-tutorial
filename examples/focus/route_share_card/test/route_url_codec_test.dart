import 'package:flutter_test/flutter_test.dart';
import 'package:route_share_card/src/route_data.dart';
import 'package:route_share_card/src/route_url_codec.dart';

void main() {
  const codec = RouteUrlCodec();

  test('parses defaults from a stable route id', () {
    final result = codec.parse(Uri.parse('/routes/museum-loop'));

    expect(result, isA<ValidRouteLink>());
    final link = result as ValidRouteLink;
    expect(link.route.id, 'museum-loop');
    expect(link.preference.mode, RouteMode.balanced);
    expect(link.preference.start, '旧仓库入口');
  });

  // #region unicode-url-round-trip
  test('round-trips Unicode and spaces through Uri encoding', () {
    final route = routeById('museum-loop')!;
    const preference = RoutePreference(mode: RouteMode.quiet, start: '北门 服务台');

    final encoded = codec.encode(route, preference);
    final reparsed =
        codec.parse(Uri.parse(encoded.toString())) as ValidRouteLink;

    expect(encoded.toString(), contains('mode=quiet'));
    expect(encoded.toString(), contains('start='));
    expect(reparsed.preference, preference);
  });
  // #endregion unicode-url-round-trip

  test('omits default values from the canonical URL', () {
    final route = routeById('museum-loop')!;

    final encoded = codec.encode(
      route,
      RoutePreference(mode: RouteMode.balanced, start: route.stops.first),
    );

    expect(encoded.toString(), '/routes/museum-loop');
  });

  // #region illegal-url-classes
  test('rejects every illegal URL class separately', () {
    final cases = <String, RouteLinkIssue>{
      '/other/museum-loop': RouteLinkIssue.unmatchedPath,
      '/routes/missing': RouteLinkIssue.unknownRoute,
      '/routes/museum-loop?mode=quiet&mode=fast':
          RouteLinkIssue.duplicateParameter,
      '/routes/museum-loop?view=map': RouteLinkIssue.unsupportedParameter,
      '/routes/museum-loop?mode=slow': RouteLinkIssue.invalidMode,
      '/routes/museum-loop?start=': RouteLinkIssue.emptyStart,
      '/routes/museum-loop?start=${List.filled(maxStartLength + 1, '站').join()}':
          RouteLinkIssue.startTooLong,
    };

    for (final entry in cases.entries) {
      final result = codec.parse(Uri.parse(entry.key));
      expect(result, isA<InvalidRouteLink>(), reason: entry.key);
      expect(
        (result as InvalidRouteLink).issue,
        entry.value,
        reason: entry.key,
      );
    }
  });
  // #endregion illegal-url-classes
}
