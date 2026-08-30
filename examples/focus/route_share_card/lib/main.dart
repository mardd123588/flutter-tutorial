import 'package:flutter/widgets.dart';
import 'package:route_share_card/src/route_share_card_app.dart';

void main() {
  final router = createRouteShareRouter();
  runApp(RouteShareCardApp(router: router));
}
