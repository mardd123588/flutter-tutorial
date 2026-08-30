class DutyMember {
  const DutyMember({
    required this.id,
    required this.name,
    required this.callSign,
    required this.window,
  });

  final String id;
  final String name;
  final String callSign;
  final String window;
}

const seedDutyMembers = <DutyMember>[
  DutyMember(id: 'a01', name: '安岚', callSign: '主值班', window: '08:00—10:00'),
  DutyMember(id: 'b07', name: '白砚', callSign: '巡查', window: '10:00—12:00'),
  DutyMember(id: 'c12', name: '陈榆', callSign: '联络', window: '12:00—14:00'),
  DutyMember(id: 'd19', name: '杜衡', callSign: '备勤', window: '14:00—16:00'),
];

// #region reorder-data
List<DutyMember> reorderDutyMembers(
  List<DutyMember> members,
  int oldIndex,
  int newIndex,
) {
  final reordered = List<DutyMember>.of(members);
  final member = reordered.removeAt(oldIndex);
  reordered.insert(newIndex, member);
  return List<DutyMember>.unmodifiable(reordered);
}
// #endregion reorder-data

List<DutyMember> moveDutyMember(
  List<DutyMember> members,
  String memberId,
  int offset,
) {
  final oldIndex = members.indexWhere((member) => member.id == memberId);
  if (oldIndex == -1) {
    return List<DutyMember>.unmodifiable(members);
  }

  final targetIndex = (oldIndex + offset).clamp(0, members.length - 1);
  if (targetIndex == oldIndex) {
    return List<DutyMember>.unmodifiable(members);
  }

  final reordered = List<DutyMember>.of(members);
  final member = reordered.removeAt(oldIndex);
  reordered.insert(targetIndex, member);
  return List<DutyMember>.unmodifiable(reordered);
}
