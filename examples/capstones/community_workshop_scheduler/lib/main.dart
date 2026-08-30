import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'src/state/schedule_providers.dart';
import 'src/ui/community_workshop_scheduler_app.dart';

void main() {
  runApp(
    ProviderScope(
      retry: noProviderRetry,
      child: CommunityWorkshopSchedulerApp(
        router: createWorkshopSchedulerRouter(),
      ),
    ),
  );
}
