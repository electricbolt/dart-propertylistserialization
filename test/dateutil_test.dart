import 'package:test/test.dart';
import 'package:PropertyListSerialization/src/dateutil.dart';

void main() {
  test('parseBinary', () {
    var date = parseBinary(5.43196727E8);
    var expected = DateTime.utc(2018, DateTime.march, 19, 23, 58, 47);
    expect(date, expected);

    date = parseBinary(-9.783072E8);
    expected = DateTime.utc(1970, DateTime.january, 1, 0, 0, 0);
    expect(date, expected);
  });

  test('formatBinary', () {
    var date = DateTime.utc(2018, DateTime.march, 19, 23,
        58, 47);
    var val = formatBinary(date);
    expect(val, 5.43196727E8);

    date = DateTime.utc(1970, DateTime.january, 1, 0, 0, 0);
    val = formatBinary(date);
    expect(val, -9.783072E8);
  });
}