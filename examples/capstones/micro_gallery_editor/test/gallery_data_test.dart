import 'package:flutter_test/flutter_test.dart';
import 'package:micro_gallery_editor/src/gallery_data.dart';

void main() {
  test('required fields reject blank text', () {
    expect(validateRequired('  ', fieldName: '标题'), '标题不能为空');
    expect(validateRequired('潮汐练习', fieldName: '标题'), isNull);
  });

  group('validateYear', () {
    test('accepts a four digit year in range', () {
      expect(validateYear('2026'), isNull);
    });

    test('rejects text and out of range years', () {
      expect(validateYear('二〇二六'), '年份需为 1000—2099 的四位数字');
      expect(validateYear('2100'), '年份需为 1000—2099 的四位数字');
    });
  });
}
