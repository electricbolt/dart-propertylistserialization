// dateutil_test.dart
// PropertyListSerialization Copyright © 2021; Electric Bolt Limited.

import 'package:test/test.dart';
import 'package:propertylistserialization/src/dateutil.dart';

void main() {
  test('parseBinary', () {
    var date = parseBinary(5.43196727E8);
    var expected = DateTime.utc(2018, DateTime.march, 19, 23, 58, 47);
    expect(date, equals(expected));

    date = parseBinary(-9.783072E8);
    expected = DateTime.utc(1970, DateTime.january, 1, 0, 0, 0);
    expect(date, equals(expected));
  });

  test('formatBinary', () {
    var date = DateTime.utc(2018, DateTime.march, 19, 23,
        58, 47);
    var val = formatBinary(date);
    expect(val, equals(5.43196727E8));

    date = DateTime.utc(1970, DateTime.january, 1, 0, 0, 0);
    val = formatBinary(date);
    expect(val, equals(-9.783072E8));
  });

  test('parseXML', () {
    var date = parseXML('2018-03-19T23:58:47Z');
    expect(date, equals(DateTime.utc(2018, DateTime.march, 19, 23, 58,47)));

    date = parseXML('1970-01-01T00:00:00Z');
    expect(date, equals(DateTime.utc(1970, DateTime.january, 1, 0, 0, 0)));
  });

  test('formatXML', () {
    var date = formatXML(DateTime.utc(1970, DateTime.january, 1, 0, 0, 0));
    expect(date, equals('1970-01-01T00:00:00Z'));

    date = formatXML(DateTime.utc(2018, DateTime.march, 19, 23, 58, 47));
    expect(date, equals('2018-03-19T23:58:47Z'));
  });
}