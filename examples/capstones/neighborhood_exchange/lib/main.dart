import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'src/ui/exchange_app.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    ProviderScope(
      child: NeighborhoodExchangeApp(router: createExchangeRouter()),
    ),
  );
}
