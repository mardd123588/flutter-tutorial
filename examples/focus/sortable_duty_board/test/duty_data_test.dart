import 'package:flutter_test/flutter_test.dart';
import 'package:sortable_duty_board/src/duty_data.dart';

void main() {
  test('reorder uses the adjusted destination from onReorderItem', () {
    final reordered = reorderDutyMembers(seedDutyMembers, 0, 2);

    expect(reordered.map((member) => member.id), ['b07', 'c12', 'a01', 'd19']);
  });

  test('reorder does not mutate the source list', () {
    reorderDutyMembers(seedDutyMembers, 0, 2);

    expect(seedDutyMembers.first.id, 'a01');
  });

  test('move clamps at the beginning and end', () {
    final beforeStart = moveDutyMember(seedDutyMembers, 'a01', -1);
    final afterEnd = moveDutyMember(seedDutyMembers, 'd19', 1);

    expect(
      beforeStart.map((member) => member.id),
      seedDutyMembers.map((member) => member.id),
    );
    expect(
      afterEnd.map((member) => member.id),
      seedDutyMembers.map((member) => member.id),
    );
  });
}
