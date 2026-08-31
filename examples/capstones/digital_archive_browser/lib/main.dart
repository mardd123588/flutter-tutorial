import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'src/ui/archive_app.dart';

void main() {
  runArchiveApp();
}

void runArchiveApp() {
  final router = createArchiveRouter();
  runApp(ProviderScope(child: DigitalArchiveBrowserApp(router: router)));
}
