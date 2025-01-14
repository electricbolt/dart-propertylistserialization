// xmlpropertylistreader_test.dart
// PropertyListSerialization Copyright © 2021; Electric Bolt Limited.

import 'dart:convert';
import 'dart:typed_data';

import 'package:propertylistserialization/propertylistserialization.dart';
import 'package:propertylistserialization/src/xmlpropertylistreader.dart';
import 'package:test/test.dart';

void main() {
  group('plist', () {
    test('emptyPlist', () {
      const template = '<?xml version="1.0" encoding="UTF-8"?>\n'
          '<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">\n'
          '<plist version="1.0">\n'
          '</plist>\n';

      final p = XMLPropertyListReader(template);
      try {
        p.parse();
        fail(
          'Should have thrown an exception - plist requires array,data,date,dict,real,integer,string,true,false',
        );
      } on PropertyListReadStreamException catch (e) {
        e.toString(); // swallow
      }
    });
  });

  group('array', () {
    test('emptyArrayNoFinalWhitespace', () {
      const template = '<?xml version="1.0" encoding="UTF-8"?>\n'
          '<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">\n'
          '<plist version="1.0">\n'
          '\t<array>\n'
          '\t</array>\n'
          '</plist>';

      final p = XMLPropertyListReader(template);
      final o = p.parse() as List<Object>;
      expect(o.length, equals(0));
    });

    test('emptyArray', () {
      const template = '<?xml version="1.0" encoding="UTF-8"?>\n'
          '<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">\n'
          '<plist version="1.0">\n'
          '\t<array>\n'
          '\t</array>\n'
          '</plist>\n';

      final p = XMLPropertyListReader(template);
      final o = p.parse() as List<Object>;
      expect(o.length, equals(0));
    });

    test('emptyArrayElement', () {
      const template = '<?xml version="1.0" encoding="UTF-8"?>\n'
          '<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">\n'
          '<plist version="1.0">\n'
          '\t<array/>\n'
          '</plist>\n';

      final p = XMLPropertyListReader(template);
      final o = p.parse() as List<Object>;
      expect(o.length, equals(0));
    });

    test('array', () {
      const template = '<?xml version="1.0" encoding="UTF-8"?>\n'
          '<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">\n'
          '<plist version="1.0">\n'
          '\t<array>\n'
          '\t\t<string>abc</string>\n'
          '\t\t<string></string>\n'
          '\t\t<string/>\n'
          '\t\t<integer>1</integer>\n'
          '\t\t<real>1.0</real>\n'
          '\t\t<true></true>\n'
          '\t\t<true/>\n'
          '\t\t<false></false>\n'
          '\t\t<false/>\n'
          '\t</array>\n'
          '</plist>\n';

      final p = XMLPropertyListReader(template);
      final o = p.parse() as List<Object>;
      expect(o.length, equals(9));
      expect(o[0], equals('abc'));
      expect(o[1], equals(''));
      expect(o[2], equals(''));
      expect(o[3], equals(1));
      expect(o[4], equals(1.0));
      expect(o[5], equals(true));
      expect(o[6], equals(true));
      expect(o[7], equals(false));
      expect(o[8], equals(false));
    });

    test('invalidArray', () {
      const template = '<?xml version="1.0" encoding="UTF-8"?>\n'
          '<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">\n'
          '<plist version="1.0">\n'
          '\t<array>\n'
          '\t\t<key>fail</key>\n' // will fail - key is not valid.
          '\t</array>\n'
          '</plist>\n';

      final p = XMLPropertyListReader(template);
      try {
        p.parse();
        fail('Should have thrown an exception - key is not valid for an array');
      } on PropertyListReadStreamException catch (e) {
        e.toString(); // swallow
      }
    });
  });

  group('dict', () {
    test('emptyDict', () {
      const template = '<?xml version="1.0" encoding="UTF-8"?>\n'
          '<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">\n'
          '<plist version="1.0">\n'
          '\t<dict>\n'
          '\t</dict>\n'
          '</plist>\n';

      final p = XMLPropertyListReader(template);
      final o = p.parse() as Map<String, Object>;
      expect(o.length, equals(0));
    });

    test('emptyDictElement', () {
      const template = '<?xml version="1.0" encoding="UTF-8"?>\n'
          '<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">\n'
          '<plist version="1.0">\n'
          '\t<dict/>\n'
          '</plist>\n';

      final p = XMLPropertyListReader(template);
      final o = p.parse() as Map<String, Object>;
      expect(o.length, equals(0));
    });

    test('emptyDictElement', () {
      const template = '<?xml version="1.0" encoding="UTF-8"?>\n'
          '<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">\n'
          '<plist version="1.0">\n'
          '<dict>\n'
          '\t<key>Array</key>\n'
          '\t<array>\n'
          '\t\t<string>String1</string>\n'
          '\t\t<string>String2</string>\n'
          '\t</array>\n'
          '\t<key>Dict</key>\n'
          '\t<dict>\n'
          '\t\t<key>DictKey1</key>\n'
          '\t\t<string>String3</string>\n'
          '\t</dict>\n'
          '\t<key>String</key>\n'
          '\t<string>String4</string>\n'
          '\t<key>Data</key>\n'
          '\t<data>U3RyaW5nNQ==</data>\n' // String5
          '\t<key>Date</key>\n'
          '\t<date>2018-03-17T15:53:00Z</date>\n'
          '\t<key>Integer</key>\n'
          '\t<integer>1</integer>\n'
          '\t<key>Real</key>\n'
          '\t<real>1.0</real>\n'
          '\t<key>True</key>\n'
          '\t<true/>\n'
          '\t<key>False</key>\n'
          '\t<false/>\n'
          '</dict>\n'
          '</plist>\n';

      final p = XMLPropertyListReader(template);
      final d = p.parse() as Map<String, Object>;
      expect(d.length, equals(9));

      final l = d['Array'] as List<Object>;
      expect(l.length, equals(2));
      expect(l[0], equals('String1'));
      expect(l[1], equals('String2'));

      final d2 = d['Dict'] as Map<String, Object>;
      expect(d2.length, equals(1));
      expect(d2['DictKey1'], equals('String3'));

      expect(d['String'], equals('String4'));

      final b = d['Data'] as ByteData;
      expect(utf8.decode(b.buffer.asUint8List()), equals('String5'));

      expect(d['Integer'], equals(1));

      expect(d['Real'], equals(1.0));

      expect(d['True'], equals(true));
      expect(d['False'], equals(false));
    });

    test('invalidDict', () {
      const template = '<?xml version="1.0" encoding="UTF-8"?>\n'
          '<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">\n'
          '<plist version="1.0">\n'
          '\t<dict/>\n'
          '\t\t<integer>1</integer>\n'
          '\t</dict>\n'
          '</plist>\n';

      final p = XMLPropertyListReader(template);
      try {
        p.parse();
        fail(
          'Should have thrown an exception - integer is not valid expecting key.',
        );
      } on PropertyListReadStreamException catch (e) {
        e.toString(); // swallow
      }
    });
  });

  group('String', () {
    test('emptyString', () {
      const template = '<?xml version="1.0" encoding="UTF-8"?>\n'
          '<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">\n'
          '<plist version="1.0">\n'
          '\t<string>\n'
          '\t</string>\n'
          '</plist>\n';

      final p = XMLPropertyListReader(template);
      final o = p.parse() as String;
      expect(o.length, equals(0));
    });

    test('emptyStringElement', () {
      const template = '<?xml version="1.0" encoding="UTF-8"?>\n'
          '<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">\n'
          '<plist version="1.0">\n'
          '\t<string/>\n'
          '</plist>\n';

      final p = XMLPropertyListReader(template);
      final o = p.parse() as String;
      expect(o.length, equals(0));
    });

    test('string', () {
      const template = '<?xml version="1.0" encoding="UTF-8"?>\n'
          '<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">\n'
          '<plist version="1.0">\n'
          '\t<string>Some text in this string</string>\n'
          '</plist>\n';

      final p = XMLPropertyListReader(template);
      final o = p.parse() as String;
      expect(o, equals('Some text in this string'));
    });
  });

  group('Integer', () {
    test('integer', () {
      const template = '<?xml version="1.0" encoding="UTF-8"?>\n'
          '<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">\n'
          '<plist version="1.0">\n'
          '\t<integer>1</integer>\n'
          '</plist>\n';

      final p = XMLPropertyListReader(template);
      final o = p.parse() as int;
      expect(o, equals(1));
    });
  });

  group('Real', () {
    test('real', () {
      const template = '<?xml version="1.0" encoding="UTF-8"?>\n'
          '<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">\n'
          '<plist version="1.0">\n'
          '\t<real>1.0</real>\n'
          '</plist>\n';

      final p = XMLPropertyListReader(template);
      final o = p.parse() as double;
      expect(o, equals(1.0));
    });
  });

  group('True', () {
    test('true', () {
      const template = '<?xml version="1.0" encoding="UTF-8"?>\n'
          '<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">\n'
          '<plist version="1.0">\n'
          '\t<true></true>\n'
          '</plist>\n';

      final p = XMLPropertyListReader(template);
      final o = p.parse() as bool;
      expect(o, equals(true));
    });

    test('trueElement', () {
      const template = '<?xml version="1.0" encoding="UTF-8"?>\n'
          '<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">\n'
          '<plist version="1.0">\n'
          '\t<true/>\n'
          '</plist>\n';

      final p = XMLPropertyListReader(template);
      final o = p.parse() as bool;
      expect(o, equals(true));
    });
  });

  group('False', () {
    test('false', () {
      const template = '<?xml version="1.0" encoding="UTF-8"?>\n'
          '<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">\n'
          '<plist version="1.0">\n'
          '\t<false></false>\n'
          '</plist>\n';

      final p = XMLPropertyListReader(template);
      final o = p.parse() as bool;
      expect(o, equals(false));
    });

    test('falseElement', () {
      const template = '<?xml version="1.0" encoding="UTF-8"?>\n'
          '<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">\n'
          '<plist version="1.0">\n'
          '\t<false/>\n'
          '</plist>\n';

      final p = XMLPropertyListReader(template);
      final o = p.parse() as bool;
      expect(o, equals(false));
    });
  });

  group('Date', () {
    test('date', () {
      const template = '<?xml version="1.0" encoding="UTF-8"?>\n'
          '<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">\n'
          '<plist version="1.0">\n'
          '\t<date>2018-03-17T15:53:00Z</date>\n'
          '</plist>\n';

      final p = XMLPropertyListReader(template);
      final o = p.parse() as DateTime;
      expect(o, equals(DateTime.utc(2018, DateTime.march, 17, 15, 53, 0)));
    });
  });

  group('Data', () {
    test('data', () {
      const template = '<?xml version="1.0" encoding="UTF-8"?>\n'
          '<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">\n'
          '<plist version="1.0">\n'
          '\t<data>U3RyaW5nNQ==</data>\n'
          '</plist>\n';

      final p = XMLPropertyListReader(template);
      final o = p.parse() as ByteData;
      expect(utf8.decode(o.buffer.asUint8List()), equals('String5'));
    });
  });

  group('CommentsAndWhitespace', () {
    test('whitespace', () {
      const template = '<?xml version="1.0" encoding="UTF-8"?>\n'
          '<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">\n'
          '\n\n\t\t\n\n\n<plist version="1.0">\n\n\n     \n'
          '\t   <!-- A comment -->'
          '<string><!-- Another comment -->My string\twith a tab</string>\n\t\t   \n'
          '\t'
          '<!-- A multiline\n'
          '  comment -->\n'
          '</plist>\n';

      final p = XMLPropertyListReader(template);
      final o = p.parse() as String;
      expect(o, equals('My string\twith a tab'));
    });

    test('comments', () {
      const plistXml = '''
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<!-- test -->
	<key>com.apple.security.app-sandbox</key>
  <!-- Hello! -->
  <!-- And another comment -->
	<true/>
  <!-- 
    A multiline comment
    Here's another line
  -->
	<key>com.apple.security.network.server</key>
	<true/>
</dict>
</plist>''';
      final plist = XMLPropertyListReader(plistXml);
      final map = plist.parse() as Map<String, Object>;
      expect(map, hasLength(2));
      expect(map['com.apple.security.app-sandbox'], equals(true));
      expect(map['com.apple.security.network.server'], equals(true));
    });
  });
}
