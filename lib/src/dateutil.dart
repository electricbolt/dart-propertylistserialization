// dateutil.dart
// PropertyListSerialization Copyright © 2021; Electric Bolt Limited.

/// Binary plist dates have an epoch of 01 January 2001. Parameter [d] date in
/// milliseconds from epoch. Returns a [DateTime].

DateTime parseBinary(double d) {
  var binaryPlistEpoch = DateTime.utc(2001, DateTime.january, 1);
  return binaryPlistEpoch.add(Duration(seconds: d.toInt()));
}

double formatBinary(DateTime d) {
  var binaryPlistEpoch = DateTime.utc(2001, DateTime.january, 1);
  return (d.millisecondsSinceEpoch - binaryPlistEpoch.millisecondsSinceEpoch) / 1000.0;
}
