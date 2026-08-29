import 'package:daily_rhythm_board/src/rhythm_data.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('sundial positions stay ordered and normalized', () {
    final positions = dailyRhythm.map(sundialPositionFor).toList();

    expect(positions, orderedEquals([...positions]..sort()));
    expect(positions.first, inInclusiveRange(0, 1));
    expect(positions.last, inInclusiveRange(0, 1));
  });
}
