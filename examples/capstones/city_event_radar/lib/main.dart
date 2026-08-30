import 'package:flutter/material.dart';

import 'src/city_event_radar_app.dart';
import 'src/event_database.dart';
import 'src/event_preferences.dart';
import 'src/event_service.dart';

void main() {
  final fixtureClient = FixtureEventClient();
  runApp(
    CityEventRadarApp(
      service: HttpEventService(client: fixtureClient),
      preferences: SharedPreferencesEventStore(),
      localStore: EventDatabase.defaults(),
      networkControl: fixtureClient,
      ownsSavedStore: true,
    ),
  );
}
