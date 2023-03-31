// dateutil.dart
// PropertyListSerialization Copyright © 2021; Electric Bolt Limited.

/// Binary plist dates have an epoch of 01 January 2001. Parameter [d] date in
/// milliseconds from epoch. Returns a [DateTime].

DateTime parseBinary(double d) {
  final binaryPlistEpoch = DateTime.utc(2001, DateTime.january, 1);
  return binaryPlistEpoch.add(Duration(seconds: d.toInt()));
}

double formatBinary(DateTime d) {
  final binaryPlistEpoch = DateTime.utc(2001, DateTime.january, 1);
  return (d.millisecondsSinceEpoch - binaryPlistEpoch.millisecondsSinceEpoch) /
      1000.0;
}

String _formatSixDigits(int n) {
  final absN = n.abs();
  final sign = n < 0 ? '-' : '+';
  if (absN >= 100000) {
    return '$sign$absN';
  } else {
    return '${sign}0$absN';
  }
}

String _formatFourDigits(int n) {
  final absN = n.abs();
  final sign = n < 0 ? '-' : '';
  if (absN >= 1000) {
    return '$n';
  } else if (absN >= 100) {
    return '${sign}0$absN';
  } else if (absN >= 10) {
    return '${sign}00$absN';
  } else {
    return '${sign}000$absN';
  }
}

String _formatTwoDigits(int n) {
  if (n >= 10) {
    return '$n';
  } else {
    return '0$n';
  }
}

String formatXML(DateTime d) {
  final year = (d.year >= -9999 && d.year <= 9999) ? _formatFourDigits(d.year) :
    _formatSixDigits(d.year);
  final month = _formatTwoDigits(d.month);
  final day = _formatTwoDigits(d.day);
  final hour = _formatTwoDigits(d.hour);
  final minute = _formatTwoDigits(d.minute);
  final second = _formatTwoDigits(d.second);
  return '$year-$month-${day}T$hour:$minute:${second}Z';
}

/// Parses a ISO8601 string [d] in format 2018-03-19T23:58:47Z into a DateTime.
/// Returns [DateTime] or throws a [FormatException] if the input string cannot
/// be parsed.

DateTime parseXML(String d) {
  return DateTime.parse(d);
}
