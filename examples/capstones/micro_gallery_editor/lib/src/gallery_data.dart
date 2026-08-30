class Exhibit {
  const Exhibit({
    required this.id,
    required this.title,
    required this.artist,
    required this.year,
    required this.medium,
    required this.note,
  });

  final String id;
  final String title;
  final String artist;
  final int year;
  final String medium;
  final String note;
}

const seedExhibits = [
  Exhibit(
    id: 'work-01',
    title: '潮汐练习',
    artist: '林岚',
    year: 2024,
    medium: '纸本与矿物颜料',
    note: '画面从每日潮位记录中抽取线条，再按月相重新排序。',
  ),
  Exhibit(
    id: 'work-02',
    title: '低声部',
    artist: '周序',
    year: 2022,
    medium: '木材与铜',
    note: '三件可轻微摆动的构件，把观众走动带来的气流变成细小碰撞声。',
  ),
  Exhibit(
    id: 'work-03',
    title: '未寄出的地图',
    artist: '叶澄',
    year: 2025,
    medium: '织物、线与铅笔',
    note: '作品把五次迁居路线缝在同一块布面上，保留了反复拆线的痕迹。',
  ),
];

// #region validation
String? validateRequired(String? value, {required String fieldName}) {
  if (value == null || value.trim().isEmpty) return '$fieldName不能为空';
  return null;
}

String? validateYear(String? value) {
  final requiredError = validateRequired(value, fieldName: '年份');
  if (requiredError != null) return requiredError;

  final year = int.tryParse(value!.trim());
  if (year == null || year < 1000 || year > 2099) {
    return '年份需为 1000—2099 的四位数字';
  }
  return null;
}
// #endregion validation
