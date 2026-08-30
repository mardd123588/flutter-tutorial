import 'package:flutter/widgets.dart';

import 'src/venue_guide_controller.dart';
import 'src/venue_guidebook_app.dart';

void main() {
  final controller = VenueGuideController();
  final router = createVenueGuideRouter(controller: controller);
  runApp(VenueGuidebookApp(controller: controller, router: router));
}
