import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:instant_book_search/src/book_search_service.dart';
import 'package:instant_book_search/src/instant_book_search_app.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('a newer fast query wins over an older slow response', (
    tester,
  ) async {
    await tester.pumpWidget(
      InstantBookSearchApp(
        service: HttpBookSearchService(client: FixtureBookClient()),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('race-demo')));
    await _pumpUntilFound(
      tester,
      find.text('河流档案的十二种读法'),
    );

    expect(find.text('河流档案的十二种读法'), findsOneWidget);
    expect(find.text('星图修复手册'), findsNothing);

    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('河流档案的十二种读法'), findsOneWidget);
    expect(find.text('1'), findsOneWidget);
  });
}

Future<void> _pumpUntilFound(
  WidgetTester tester,
  Finder finder, {
  Duration timeout = const Duration(seconds: 5),
}) async {
  const step = Duration(milliseconds: 50);
  var elapsed = Duration.zero;
  while (finder.evaluate().isEmpty && elapsed < timeout) {
    await tester.pump(step);
    elapsed += step;
  }
}
