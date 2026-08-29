import 'package:daily_rhythm_board/src/rhythm_board.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('reader can inspect an afternoon rhythm', (tester) async {
    await tester.pumpWidget(const DailyRhythmApp());
    await tester.pumpAndSettle();

    final afternoonButton = find.widgetWithText(OutlinedButton, '午后专注');
    await tester.ensureVisible(afternoonButton);
    await tester.tap(afternoonButton);
    await tester.pumpAndSettle();

    expect(find.text('14:00 · 午后专注'), findsOneWidget);
  });
}
