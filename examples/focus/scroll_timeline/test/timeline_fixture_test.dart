import 'package:flutter_test/flutter_test.dart';
import 'package:scroll_timeline/src/timeline_data.dart';

void main() {
  test('provides six eras and 72 events in a stable order', () {
    expect(timelineEras, hasLength(6));
    expect(timelineEvents, hasLength(72));

    final sorted = [...timelineEvents]
      ..sort((left, right) {
        final year = left.year.compareTo(right.year);
        if (year != 0) return year;
        final sequence = left.sequence.compareTo(right.sequence);
        if (sequence != 0) return sequence;
        return left.id.compareTo(right.id);
      });

    expect(timelineEvents, orderedEquals(sorted));
  });
}
