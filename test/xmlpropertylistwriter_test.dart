// xmlpropertylistwriter_test.dart
// PropertyListSerialization Copyright © 2021; Electric Bolt Limited.

import 'dart:convert';
import 'dart:typed_data';

import 'package:propertylistserialization/propertylistserialization.dart';
import 'package:propertylistserialization/src/xmlpropertylistwriter.dart';
import 'package:test/test.dart';

void main() {
  test('safeSubstring', () {
    expect(safeSubstring('', 0, 10), equals(''));
    expect(safeSubstring('', 1, 10), equals(''));
    expect(safeSubstring('a', 0, 10), equals('a'));
    expect(safeSubstring('ab', 0, 1), equals('a'));
    expect(safeSubstring('ab', 0, 2), equals('ab'));
    expect(safeSubstring('ab', 0, 3), equals('ab'));
    expect(safeSubstring('ab', 1, 1), equals('b'));
    expect(safeSubstring('ab', 1, 2), equals('b'));
    expect(safeSubstring('ab', 1, 3), equals('b'));
    expect(safeSubstring('abcdefghijklmnopqrstuvwxyz', 0, 13),
        equals('abcdefghijklm'));
    expect(safeSubstring('abcdefghijklmnopqrstuvwxyz', 1, 13),
        equals('bcdefghijklmn'));
    expect(safeSubstring('abcdefghijklmnopqrstuvwxyz', 0, 26),
        equals('abcdefghijklmnopqrstuvwxyz'));
    expect(safeSubstring('abcdefghijklmnopqrstuvwxyz', 0, 27),
        equals('abcdefghijklmnopqrstuvwxyz'));
    expect(safeSubstring('abcdefghijklmnopqrstuvwxyz', 0, 28),
        equals('abcdefghijklmnopqrstuvwxyz'));
    expect(safeSubstring('abcdefghijklmnopqrstuvwxyz', 1, 26),
        equals('bcdefghijklmnopqrstuvwxyz'));
    expect(safeSubstring('abcdefghijklmnopqrstuvwxyz', 1, 25),
        equals('bcdefghijklmnopqrstuvwxyz'));
    expect(safeSubstring('abcdefghijklmnopqrstuvwxyz', 1, 26),
        equals('bcdefghijklmnopqrstuvwxyz'));
    expect(safeSubstring('abcdefghijklmnopqrstuvwxyz', 1, 27),
        equals('bcdefghijklmnopqrstuvwxyz'));
    expect(safeSubstring('abcdefghijklmnopqrstuvwxyz', 13, 10),
        equals('nopqrstuvw'));
    expect(safeSubstring('abcdefghijklmnopqrstuvwxyz', 13, 12),
        equals('nopqrstuvwxy'));
    expect(safeSubstring('abcdefghijklmnopqrstuvwxyz', 13, 13),
        equals('nopqrstuvwxyz'));
    expect(safeSubstring('abcdefghijklmnopqrstuvwxyz', 13, 14),
        equals('nopqrstuvwxyz'));
    expect(safeSubstring('abcdefghijklmnopqrstuvwxyz', 13, 15),
        equals('nopqrstuvwxyz'));
    expect(safeSubstring('abcdefghijklmnopqrstuvwxyz', 14, 20),
        equals('opqrstuvwxyz'));
  });

  group('string', () {
    test('string', () {
      var template =
          '<?xml version="1.0" encoding="UTF-8"?>\n<!DOCTYPE plist PUBLIC "-//A'
          'pple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList'
          '-1.0.dtd">\n'
          '<plist version="1.0">\n'
          '<string>String1</string>\n'
          '</plist>\n';
      var p = XMLPropertyListWriter('String1');
      var result = p.write();
      expect(result, equals(template));
    });

    test('emptyString', () {
      var template =
          '<?xml version="1.0" encoding="UTF-8"?>\n<!DOCTYPE plist PUBLIC "-//A'
          'pple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList'
          '-1.0.dtd">\n'
          '<plist version="1.0">\n'
          '<string></string>\n'
          '</plist>\n';
      var p = XMLPropertyListWriter('');
      var result = p.write();
      expect(result, equals(template));
    });
  });

  test('integer', () {
    var template =
        '<?xml version="1.0" encoding="UTF-8"?>\n<!DOCTYPE plist PUBLIC "-//App'
        'le//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd'
        '">\n'
        '<plist version="1.0">\n'
        '<integer>42</integer>\n'
        '</plist>\n';
    var p = XMLPropertyListWriter(42);
    var result = p.write();
    expect(result, equals(template));
  });

  test('real', () {
    var template =
        '<?xml version="1.0" encoding="UTF-8"?>\n<!DOCTYPE plist PUBLIC "-//App'
        'le//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd'
        '">\n'
        '<plist version="1.0">\n'
        '<real>42.5</real>\n'
        '</plist>\n';
    var p = XMLPropertyListWriter(Float32(42.5));
    var result = p.write();
    expect(result, equals(template));

    p = XMLPropertyListWriter(42.5);
    result = p.write();
    expect(result, equals(template));
  });

  test('date', () {
    var template =
        '<?xml version="1.0" encoding="UTF-8"?>\n<!DOCTYPE plist PUBLIC "-//App'
        'le//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd'
        '">\n'
        '<plist version="1.0">\n'
        '<date>2018-03-17T15:53:00Z</date>\n'
        '</plist>\n';
    var p = XMLPropertyListWriter(DateTime.utc(2018, DateTime.march, 17, 15,
        53, 0));
    var result = p.write();
    expect(result, equals(template));
  });

  group('boolean', () {
    test('true', () {
      var template =
          '<?xml version="1.0" encoding="UTF-8"?>\n<!DOCTYPE plist PUBLIC "-//A'
          'pple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList'
          '-1.0.dtd">\n'
          '<plist version="1.0">\n'
          '<true/>\n'
          '</plist>\n';
      var p = XMLPropertyListWriter(true);
      var result = p.write();
      expect(result, equals(template));
    });

    test('false', () {
      var template =
          '<?xml version="1.0" encoding="UTF-8"?>\n<!DOCTYPE plist PUBLIC "-//A'
          'pple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList'
          '-1.0.dtd">\n'
          '<plist version="1.0">\n'
          '<false/>\n'
          '</plist>\n';
      var p = XMLPropertyListWriter(false);
      var result = p.write();
      expect(result, equals(template));
    });
  });

  test('array', () {
    var template =
        '<?xml version="1.0" encoding="UTF-8"?>\n<!DOCTYPE plist PUBLIC "-//App'
        'le//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd'
        '">\n'
        '<plist version="1.0">\n'
        '<array>\n'
        '\t<array>\n'
        '\t\t<string>String1</string>\n'
        '\t\t<string>String2</string>\n'
        '\t\t<string></string>\n'
        '\t</array>\n'
        '\t<dict>\n'
        '\t\t<key>Key</key>\n'
        '\t\t<string>Value</string>\n'
        '\t</dict>\n'
        '\t<integer>5</integer>\n'
        '\t<real>42.5</real>\n'
        '\t<true/>\n'
        '\t<false/>\n'
        '</array>\n'
        '</plist>\n';

    var graph1 = [];
    var graph2 = [];
    graph2.add('String1');
    graph2.add('String2');
    graph2.add('');
    graph1.add(graph2);
    var dict = <String, Object>{};
    dict['Key'] = 'Value';
    graph1.add(dict);
    graph1.add(5);
    graph1.add(42.5);
    graph1.add(true);
    graph1.add(false);

    var p = XMLPropertyListWriter(graph1);
    var result = p.write();
    expect(result, equals(template));
  });

  test('dict', () {
    var template =
        '<?xml version="1.0" encoding="UTF-8"?>\n<!DOCTYPE plist PUBLIC "-//App'
        'le//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd'
        '">\n'
        '<plist version="1.0">\n'
        '<dict>\n'
        '\t<key>Array</key>\n'
        '\t<array>\n'
        '\t\t<string>String1</string>\n'
        '\t\t<string>String2</string>\n'
        '\t\t<string></string>\n'
        '\t</array>\n'
        '\t<key>Dict</key>\n'
        '\t<dict>\n'
        '\t\t<key>Key</key>\n'
        '\t\t<string>Value</string>\n'
        '\t</dict>\n'
        '\t<key>False</key>\n'
        '\t<false/>\n'
        '\t<key>Integer</key>\n'
        '\t<integer>5</integer>\n'
        '\t<key>Real</key>\n'
        '\t<real>42.5</real>\n'
        '\t<key>True</key>\n'
        '\t<true/>\n'
        '</dict>\n'
        '</plist>\n';

    var graph1 = <String, Object>{};
    graph1['True'] = true;
    var dict = <String, Object>{};
    dict['Key'] = 'Value';
    graph1['Dict'] = dict;
    graph1['Integer'] = 5;
    graph1['Real'] = 42.5;
    var graph2 = [];
    graph2.add('String1');
    graph2.add('String2');
    graph2.add('');
    graph1['Array'] = graph2;
    graph1['False'] = false;

    var p = XMLPropertyListWriter(graph1);
    var result = p.write();
    expect(result, equals(template));
  });

  group('data', ()
  {
    test('dataNoIndent', () {
      var template =
          '<?xml version="1.0" encoding="UTF-8"?>\n<!DOCTYPE plist PUBLIC "-//A'
          'pple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0'
          '.dtd">\n'
          '<plist version="1.0">\n'
          '<data>\n'
          'U3RyaW5nNQ==\n'
          '</data>\n'
          '</plist>\n';

      var p = XMLPropertyListWriter(_string('String5'));
      var result = p.write();
      expect(result, equals(template));
    });

    test('dataOneIndent', () {
      var template =
          '<?xml version="1.0" encoding="UTF-8"?>\n<!DOCTYPE plist PUBLIC "-//A'
          'pple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0'
          '.dtd">\n'
          '<plist version="1.0">\n'
          '<dict>\n'
          '\t<key>Data</key>\n'
          '\t<data>\n'
          '\tU3RyaW5nNQ==\n'
          '\t</data>\n'
          '</dict>\n'
          '</plist>\n';

      var dict = <String, Object>{};
      dict['Data'] = _string('String5');
      var p = XMLPropertyListWriter(dict);
      var result = p.write();
      expect(result, equals(template));
    });

    test('dataTwoIndent', () {
      var template =
          '<?xml version="1.0" encoding="UTF-8"?>\n<!DOCTYPE plist PUBLIC "-//A'
          'pple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0'
          '.dtd">\n'
          '<plist version="1.0">\n'
          '<dict>\n'
          '\t<key>Data</key>\n'
          '\t<dict>\n'
          '\t\t<key>Data2</key>\n'
          '\t\t<data>\n'
          '\t\tU3RyaW5nNQ==\n'
          '\t\t</data>\n'
          '\t</dict>\n'
          '</dict>\n'
          '</plist>\n';

      var dict1 = <String, Object>{};
      var dict2 = <String, Object>{};
      dict1['Data'] = dict2;
      dict2['Data2'] = _string('String5');
      var p = XMLPropertyListWriter(dict1);
      var result = p.write();
      expect(result, equals(template));
    });

    test('dataEightIndent', () {
      var template =
          '<?xml version="1.0" encoding="UTF-8"?>\n<!DOCTYPE plist PUBLIC "-//A'
          'pple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0'
          '.dtd">\n'
          '<plist version="1.0">\n'
          '<dict>\n'
          '\t<key>Data</key>\n'
          '\t<dict>\n'
          '\t\t<key>Data2</key>\n'
          '\t\t<dict>\n'
          '\t\t\t<key>Data3</key>\n'
          '\t\t\t<dict>\n'
          '\t\t\t\t<key>Data4</key>\n'
          '\t\t\t\t<dict>\n'
          '\t\t\t\t\t<key>Data5</key>\n'
          '\t\t\t\t\t<dict>\n'
          '\t\t\t\t\t\t<key>Data6</key>\n'
          '\t\t\t\t\t\t<dict>\n'
          '\t\t\t\t\t\t\t<key>Data7</key>\n'
          '\t\t\t\t\t\t\t<dict>\n'
          '\t\t\t\t\t\t\t\t<key>Data8</key>\n'
          '\t\t\t\t\t\t\t\t<data>\n'
          '\t\t\t\t\t\t\t\tU3RyaW5nNQ==\n'
          '\t\t\t\t\t\t\t\t</data>\n'
          '\t\t\t\t\t\t\t</dict>\n'
          '\t\t\t\t\t\t</dict>\n'
          '\t\t\t\t\t</dict>\n'
          '\t\t\t\t</dict>\n'
          '\t\t\t</dict>\n'
          '\t\t</dict>\n'
          '\t</dict>\n'
          '</dict>\n'
          '</plist>\n';

      var dict1 = <String, Object>{};
      var dict2 = <String, Object>{};
      var dict3 = <String, Object>{};
      var dict4 = <String, Object>{};
      var dict5 = <String, Object>{};
      var dict6 = <String, Object>{};
      var dict7 = <String, Object>{};
      var dict8 = <String, Object>{};

      dict1['Data'] = dict2;
      dict2['Data2'] = dict3;
      dict3['Data3'] = dict4;
      dict4['Data4'] = dict5;
      dict5['Data5'] = dict6;
      dict6['Data6'] = dict7;
      dict7['Data7'] = dict8;
      dict8['Data8'] = _string('String5');

      var p = XMLPropertyListWriter(dict1);
      var result = p.write();
      expect(result, equals(template));
    });

    test('dataNineIndentLimitedToEightIndent', ()
    {
      var template =
          '<?xml version="1.0" encoding="UTF-8"?>\n<!DOCTYPE plist PUBLIC "-//A'
          'pple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0'
          '.dtd">\n'
          '<plist version="1.0">\n'
          '<dict>\n'
          '\t<key>Data</key>\n'
          '\t<dict>\n'
          '\t\t<key>Data2</key>\n'
          '\t\t<dict>\n'
          '\t\t\t<key>Data3</key>\n'
          '\t\t\t<dict>\n'
          '\t\t\t\t<key>Data4</key>\n'
          '\t\t\t\t<dict>\n'
          '\t\t\t\t\t<key>Data5</key>\n'
          '\t\t\t\t\t<dict>\n'
          '\t\t\t\t\t\t<key>Data6</key>\n'
          '\t\t\t\t\t\t<dict>\n'
          '\t\t\t\t\t\t\t<key>Data7</key>\n'
          '\t\t\t\t\t\t\t<dict>\n'
          '\t\t\t\t\t\t\t\t<key>Data8</key>\n'
          '\t\t\t\t\t\t\t\t<dict>\n'
          '\t\t\t\t\t\t\t\t<key>Data9</key>\n'
          '\t\t\t\t\t\t\t\t<data>\n'
          '\t\t\t\t\t\t\t\tU3RyaW5nNQ==\n'
          '\t\t\t\t\t\t\t\t</data>\n'
          '\t\t\t\t\t\t\t\t</dict>\n'
          '\t\t\t\t\t\t\t</dict>\n'
          '\t\t\t\t\t\t</dict>\n'
          '\t\t\t\t\t</dict>\n'
          '\t\t\t\t</dict>\n'
          '\t\t\t</dict>\n'
          '\t\t</dict>\n'
          '\t</dict>\n'
          '</dict>\n'
          '</plist>\n';

      var dict1 = <String, Object>{};
      var dict2 = <String, Object>{};
      var dict3 = <String, Object>{};
      var dict4 = <String, Object>{};
      var dict5 = <String, Object>{};
      var dict6 = <String, Object>{};
      var dict7 = <String, Object>{};
      var dict8 = <String, Object>{};
      var dict9 = <String, Object>{};

      dict1['Data'] = dict2;
      dict2['Data2'] = dict3;
      dict3['Data3'] = dict4;
      dict4['Data4'] = dict5;
      dict5['Data5'] = dict6;
      dict6['Data6'] = dict7;
      dict7['Data7'] = dict8;
      dict8['Data8'] = dict9;
      dict9['Data9'] = _string('String5');

      var p = XMLPropertyListWriter(dict1);
      var result = p.write();
      expect(result, equals(template));
    });

    test('largeDataTwoIndentSpanning3Lines', () {
      var template =
          '<?xml version="1.0" encoding="UTF-8"?>\n<!DOCTYPE plist PUBLIC "-//A'
          'pple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0'
          '.dtd">\n'
          '<plist version="1.0">\n'
          '<dict>\n'
          '\t<key>Data</key>\n'
          '\t<dict>\n'
          '\t\t<key>Data2</key>\n'
          '\t\t<data>\n'
          '\t\tVGhlIHF1aWNrIGJyb3duIGZveCBqdW1wcyBvdmVyIHRoZSBsYXp5IGRvZy4g\n'
          '\t\tRWxlcGhhbnRzIGFuZCBzaGVlcCBhcmUgdmlzdWFsbHkgcXVpdGUgZGlmZmVy\n'
          '\t\tZW50Lg==\n'
          '\t\t</data>\n'
          '\t</dict>\n'
          '</dict>\n'
          '</plist>\n';

      var dict1 = <String, Object>{};
      var dict2 = <String, Object>{};
      dict1['Data'] = dict2;
      dict2['Data2'] = _string('The quick brown fox jumps over the lazy dog. '
          'Elephants and sheep are visually quite different.');

      var p = XMLPropertyListWriter(dict1);
      var result = p.write();
      expect(result, equals(template));
    });

    test('largeDataNineIndentSpanning5Lines', () {
      var template =
          '<?xml version="1.0" encoding="UTF-8"?>\n<!DOCTYPE plist PUBLIC "-//A'
          'pple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0'
          '.dtd">\n'
          '<plist version="1.0">\n'
          '<dict>\n'
          '\t<key>Data</key>\n'
          '\t<dict>\n'
          '\t\t<key>Data2</key>\n'
          '\t\t<dict>\n'
          '\t\t\t<key>Data3</key>\n'
          '\t\t\t<dict>\n'
          '\t\t\t\t<key>Data4</key>\n'
          '\t\t\t\t<dict>\n'
          '\t\t\t\t\t<key>Data5</key>\n'
          '\t\t\t\t\t<dict>\n'
          '\t\t\t\t\t\t<key>Data6</key>\n'
          '\t\t\t\t\t\t<dict>\n'
          '\t\t\t\t\t\t\t<key>Data7</key>\n'
          '\t\t\t\t\t\t\t<dict>\n'
          '\t\t\t\t\t\t\t\t<key>Data8</key>\n'
          '\t\t\t\t\t\t\t\t<dict>\n'
          '\t\t\t\t\t\t\t\t<key>Data9</key>\n'
          '\t\t\t\t\t\t\t\t<data>\n'
          '\t\t\t\t\t\t\t\tVkdobElIRjFh\n'
          '\t\t\t\t\t\t\t\tV05ySUdKeWIz\n'
          '\t\t\t\t\t\t\t\tZHVJR1p2ZUNC\n'
          '\t\t\t\t\t\t\t\tcWRXMXdjeUJ2\n'
          '\t\t\t\t\t\t\t\tZG1WeUlIUm9a\n'
          '\t\t\t\t\t\t\t\tU0JzWVhwNUlH\n'
          '\t\t\t\t\t\t\t\tUnZaeTRnUld4\n'
          '\t\t\t\t\t\t\t\tbGNHaGhiblJ6\n'
          '\t\t\t\t\t\t\t\tSUdGdVpDQnph\n'
          '\t\t\t\t\t\t\t\tR1ZsY0NCaGNt\n'
          '\t\t\t\t\t\t\t\tVWdkbWx6ZFdG\n'
          '\t\t\t\t\t\t\t\tc2JIa2djWFZw\n'
          '\t\t\t\t\t\t\t\tZEdVZ1pHbG1a\n'
          '\t\t\t\t\t\t\t\tbVZ5Wlc1MExn\n'
          '\t\t\t\t\t\t\t\tPT0=\n'
          '\t\t\t\t\t\t\t\t</data>\n'
          '\t\t\t\t\t\t\t\t</dict>\n'
          '\t\t\t\t\t\t\t</dict>\n'
          '\t\t\t\t\t\t</dict>\n'
          '\t\t\t\t\t</dict>\n'
          '\t\t\t\t</dict>\n'
          '\t\t\t</dict>\n'
          '\t\t</dict>\n'
          '\t</dict>\n'
          '</dict>\n'
          '</plist>\n';

      var dict1 = <String, Object>{};
      var dict2 = <String, Object>{};
      var dict3 = <String, Object>{};
      var dict4 = <String, Object>{};
      var dict5 = <String, Object>{};
      var dict6 = <String, Object>{};
      var dict7 = <String, Object>{};
      var dict8 = <String, Object>{};
      var dict9 = <String, Object>{};

      dict1['Data'] = dict2;
      dict2['Data2'] = dict3;
      dict3['Data3'] = dict4;
      dict4['Data4'] = dict5;
      dict5['Data5'] = dict6;
      dict6['Data6'] = dict7;
      dict7['Data7'] = dict8;
      dict8['Data8'] = dict9;

      var b = _string('The quick brown fox jumps over the lazy dog. '
          'Elephants and sheep are visually quite different.');
      var s = Base64Encoder().convert(b.buffer.asUint8List());
      dict9['Data9'] = _string(s);

      var p = XMLPropertyListWriter(dict1);
      var result = p.write();
      expect(result, equals(template));
    });
  });
}

ByteData _string(String text) {
  var list = text.codeUnits;
  var ulist = Uint8List.fromList(list);
  var buffer = ulist.buffer;
  return ByteData.view(buffer);
}
