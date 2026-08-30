import 'package:flutter/material.dart';

import 'src/book_search_service.dart';
import 'src/instant_book_search_app.dart';

void main() {
  runApp(
    InstantBookSearchApp(
      service: HttpBookSearchService(client: FixtureBookClient()),
    ),
  );
}
