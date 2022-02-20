// binarypropertylistreader_test.dart
// PropertyListSerialization Copyright © 2021; Electric Bolt Limited.

import 'dart:typed_data';

import 'package:propertylistserialization/propertylistserialization.dart';
import 'package:propertylistserialization/src/binarypropertylistreader.dart';
import 'package:convert/convert.dart';
import 'package:test/test.dart';

void main() {
  group('array', () {
    test('emptyArray', () {
      var template = '62706c6973743030a0080000000000000101000000000000000100000'
          '000000000000000000000000009';
      var p = BinaryPropertyListReader(bytes(template), false);
      var o = p.parse();
      expect(o.runtimeType, <Object>[].runtimeType);
      var list = o as List<Object>;
      expect(list.length, equals(0));
    });

    test('filledArray', () {
      var template = '62706c6973743030aa0102030405060708090a1000223fc0000023400'
          '400000000000009084500010203044f1014000102030405060708090a0b0c0d0e0f1'
          '011121333c1e9fc3af0e000005f101b54686520636f77206a756d706564206f76657'
          '22074686520646f676f101f0100010100540068006500200063006f00770020006a0'
          '075006d0070006500640020006f007600650072002000740068006500200064006f0'
          '067010201030813151a2324252b424b690000000000000101000000000000000b000'
          '000000000000000000000000000aa';
      var p = BinaryPropertyListReader(bytes(template), false);
      var o = p.parse();
      expect(o.runtimeType, <Object>[].runtimeType);
      var list = o as List<Object>;
      expect(list.length, equals(10));
      expect(list[0], equals(0));
      expect(list[1], equals(1.5));
      expect(list[2], equals(2.5));
      expect(list[3], equals(true));
      expect(list[4], equals(false));
      expectByteData(list[5] as ByteData, makeData(5));
      expectByteData(list[6] as ByteData, makeData(20));
      expect(
          list[7], equals(DateTime.utc(1890, DateTime.june, 25, 06, 45, 13)));
      expect(list[8], equals('The cow jumped over the dog'));
      expect(list[9], equals('\u0100\u0101The cow jumped over the dog\u0102'
          '\u0103'));
    });
  });

  group('dict', () {
    test('emptyDict', () {
      var template = '62706c6973743030d0080000000000000101000000000000000100000'
          '000000000000000000000000009';
      var p = BinaryPropertyListReader(bytes(template), false);
      var o = p.parse();
      expect(o.runtimeType, <String, Object>{}.runtimeType);
      var dict = o as Map<String, Object>;
      expect(dict.length, equals(0));
    });

    test('filledDict', () {
      var template = '62706c6973743030da0102030405060708090a0b0c0d0e0f101112131'
          '45664617461323056646f75626c6553696e745566616c73655575746631365464617'
          '465547472756555666c6f61745564617461355561736369694f10140001020304050'
          '60708090a0b0c0d0e0f101112132340040000000000001000086f101f01000101005'
          '40068006500200063006f00770020006a0075006d0070006500640020006f0076006'
          '50072002000740068006500200064006f00670102010333c1e9fc3af0e0000009223'
          'fc000004500010203045f101b54686520636f77206a756d706564206f76657220746'
          '86520646f67081d242b2f353b40454b51576e77797abbc4c5cad0000000000000010'
          '10000000000000015000000000000000000000000000000ee';
      var p = BinaryPropertyListReader(bytes(template), false);
      var o = p.parse();
      expect(o.runtimeType, <String, Object>{}.runtimeType);
      var dict = o as Map<String, Object>;
      expect(dict.length, equals(10));
      expect(dict['int'], equals(0));
      expect(dict['float'], equals(1.5));
      expect(dict['double'], equals(2.5));
      expect(dict['true'], equals(true));
      expect(dict['false'], equals(false));
      expectByteData(dict['data5'] as ByteData, makeData(5));
      expectByteData(dict['data20'] as ByteData, makeData(20));
      expect(dict['date'], equals(DateTime.utc(1890, DateTime.june, 25, 06, 45,
          13)));
      expect(dict['ascii'], equals('The cow jumped over the dog'));
      expect(
          dict['utf16'], equals('\u0100\u0101The cow jumped over the dog\u0102'
          '\u0103'));
    });
  });

  group('issues', () {
    // Binary plist converted to XML plist:

    // <?xml version="1.0" encoding="UTF-8"?>
    // <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
    // <plist version="1.0">
    // <dict>
    // 	<key>$archiver</key>
    // 	<string>NSKeyedArchiver</string>
    // 	<key>$objects</key>
    // 	<array>
    // 		<string>$null</string>
    // 		<dict>
    // 			<key>$class</key>
    // 			<dict>
    // 				<key>CF$UID</key>
    // 				<integer>4</integer>
    // 			</dict>
    // 			<key>NS.objects</key>
    // 			<array>
    // 				<dict>
    // 					<key>CF$UID</key>
    // 					<integer>2</integer>
    // 				</dict>
    // 				<dict>
    // 					<key>CF$UID</key>
    // 					<integer>3</integer>
    // 				</dict>
    // 			</array>
    // 		</dict>
    // 		<real>15</real>
    // 		<real>16</real>
    // 		<dict>
    // 			<key>$classes</key>
    // 			<array>
    // 				<string>NSArray</string>
    // 				<string>NSObject</string>
    // 			</array>
    // 			<key>$classname</key>
    // 			<string>NSArray</string>
    // 		</dict>
    // 	</array>
    // 	<key>$top</key>
    // 	<dict>
    // 		<key>root</key>
    // 		<dict>
    // 			<key>CF$UID</key>
    // 			<integer>1</integer>
    // 		</dict>
    // 	</dict>
    // 	<key>$version</key>
    // 	<integer>100000</integer>
    // </dict>
    // </plist>

    test('issue#2', () {
      var template = '62706c6973743030d4010203040506070a582476657273696f6e59246'
          '1726368697665725424746f7058246f626a6563747312000186a05f100f4e534b657'
          '965644172636869766572d1080954726f6f748001a50b0c13141555246e756c6cd20'
          'd0e0f125a4e532e6f626a656374735624636c617373a2101180028003800423402e0'
          '00000000000234030000000000000d2161718195a24636c6173736e616d655824636'
          'c6173736573574e534172726179a2181a584e534f626a65637408111a24293237494'
          'c5153595f646f76797b7d7f889196a1aab2b50000000000000101000000000000001'
          'b000000000000000000000000000000be';
      // Test that when keyedArchive = false throws an UnsupportedError when
      // CF$UID construct is read.
      var p = BinaryPropertyListReader(bytes(template), false);
      try {
        p.parse();
        throw new Exception('Expected UnsupportedError');
      } on UnsupportedError {
      }

      p = BinaryPropertyListReader(bytes(template), true);
      var o = p.parse();
      expect(o.runtimeType, <String, Object>{}.runtimeType);
      var dict = o as Map<String, Object>;

      expect(dict.length, equals(4));
      expect(dict[r'$version'], equals(100000));
      expect(dict[r'$archiver'], equals('NSKeyedArchiver'));

      var topDict = dict[r'$top'] as Map<String, Object>;
      expect(topDict['root'], equals(UID(1)));

      var objectsList = dict[r'$objects'] as List<Object>;
      expect(objectsList[0], equals(r'$null'));
      var dict1 = objectsList[1] as Map<String, Object>;
      var NSObjectsList = dict1['NS.objects'] as List;
      expect(NSObjectsList[0], equals(UID(2)));
      expect(NSObjectsList[1], equals(UID(3)));
      expect(dict1[r'$class'], equals(UID(4)));
      expect(objectsList[2], equals(15.0));
      expect(objectsList[3], equals(16.0));
      var dict4 = objectsList[4] as Map<String, Object>;
      expect(dict4[r'$classname'], equals('NSArray'));
      var classesList = dict4[r'$classes'] as List;
      expect(classesList[0], equals('NSArray'));
      expect(classesList[1], equals('NSObject'));
    });
  });

  group('string', () {
    test('asciiString', () {
      expectString(
          '', '62706c6973743030500800000000000001010000000000000001000000000000'
          '00000000000000000009');
      expectString(
          ' ', '62706c697374303051200800000000000001010000000000000001000000000'
          '0000000000000000000000a');
      expectString(
          'The dog jumped over the moon', '62706c69737430305f101c54686520646f67'
          '206a756d706564206f76657220746865206d6f6f6e08000000000000010100000000'
          '0000000100000000000000000000000000000027');
    });

    test('unicodeString', () {
      expectString(
          'Ā', '62706c697374303061010008000000000000010100000000000000010000000'
          '000000000000000000000000b');
      expectString(
          'Āā', '62706c69737430306201000101080000000000000101000000000000000100'
          '00000000000000000000000000000d');
      expectString(
          'ĀāThe cow jumped over the dogĂă', '62706c69737430306f101f01000101005'
          '40068006500200063006f00770020006a0075006d0070006500640020006f0076006'
          '50072002000740068006500200064006f00670102010308000000000000010100000'
          '0000000000100000000000000000000000000000049');
    });
  });

  test('integer', () {
    // positive
    expectInteger(0, '62706c697374303010000800000000000001010000000000000001000'
        '0000000000000000000000000000a');
    expectInteger(1, '62706c697374303010010800000000000001010000000000000001000'
        '0000000000000000000000000000a');
    expectInteger(126, '62706c6973743030107e08000000000000010100000000000000010'
        '000000000000000000000000000000a');
    expectInteger(127, '62706c6973743030107f08000000000000010100000000000000010'
        '000000000000000000000000000000a');
    expectInteger(128, '62706c6973743030108008000000000000010100000000000000010'
        '000000000000000000000000000000a');
    expectInteger(254, '62706c697374303010fe08000000000000010100000000000000010'
        '000000000000000000000000000000a');
    expectInteger(255, '62706c697374303010ff08000000000000010100000000000000010'
        '000000000000000000000000000000a');
    expectInteger(256, '62706c6973743030110100080000000000000101000000000000000'
        '10000000000000000000000000000000b');
    expectInteger(32766, '62706c6973743030117ffe0800000000000001010000000000000'
        '0010000000000000000000000000000000b');
    expectInteger(32767, '62706c6973743030117fff0800000000000001010000000000000'
        '0010000000000000000000000000000000b');
    expectInteger(32768, '62706c69737430301180000800000000000001010000000000000'
        '0010000000000000000000000000000000b');
    expectInteger(65534, '62706c697374303011fffe0800000000000001010000000000000'
        '0010000000000000000000000000000000b');
    expectInteger(65535, '62706c697374303011ffff0800000000000001010000000000000'
        '0010000000000000000000000000000000b');
    expectInteger(65536, '62706c69737430301200010000080000000000000101000000000'
        '00000010000000000000000000000000000000d');
    expectInteger(2147483646, '62706c6973743030127ffffffe0800000000000001010000'
        '0000000000010000000000000000000000000000000d');
    expectInteger(2147483647, '62706c6973743030127fffffff0800000000000001010000'
        '0000000000010000000000000000000000000000000d');
    expectInteger(2147483648, '62706c697374303012800000000800000000000001010000'
        '0000000000010000000000000000000000000000000d');
    expectInteger(9223372036854775806, '62706c6973743030137ffffffffffffffe08000'
        '0000000000101000000000000000100000000000000000000000000000011');
    expectInteger(9223372036854775807, '62706c6973743030137fffffffffffffff08000'
        '0000000000101000000000000000100000000000000000000000000000011');

    // negative
    expectInteger(-1, '62706c697374303013ffffffffffffffff0800000000000001010000'
        '00000000000100000000000000000000000000000011');
    expectInteger(-127, '62706c697374303013ffffffffffffff8108000000000000010100'
        '0000000000000100000000000000000000000000000011');
    expectInteger(-128, '62706c697374303013ffffffffffffff8008000000000000010100'
        '0000000000000100000000000000000000000000000011');
    expectInteger(-129, '62706c697374303013ffffffffffffff7f08000000000000010100'
        '0000000000000100000000000000000000000000000011');
    expectInteger(-255, '62706c697374303013ffffffffffffff0108000000000000010100'
        '0000000000000100000000000000000000000000000011');
    expectInteger(-256, '62706c697374303013ffffffffffffff0008000000000000010100'
        '0000000000000100000000000000000000000000000011');
    expectInteger(-257, '62706c697374303013fffffffffffffeff08000000000000010100'
        '0000000000000100000000000000000000000000000011');
    expectInteger(-32767, '62706c697374303013ffffffffffff8001080000000000000101'
        '000000000000000100000000000000000000000000000011');
    expectInteger(-32768, '62706c697374303013ffffffffffff8000080000000000000101'
        '000000000000000100000000000000000000000000000011');
    expectInteger(-32769, '62706c697374303013ffffffffffff7fff080000000000000101'
        '000000000000000100000000000000000000000000000011');
    expectInteger(-65534, '62706c697374303013ffffffffffff0002080000000000000101'
        '000000000000000100000000000000000000000000000011');
    expectInteger(-65535, '62706c697374303013ffffffffffff0001080000000000000101'
        '000000000000000100000000000000000000000000000011');
    expectInteger(-65536, '62706c697374303013ffffffffffff0000080000000000000101'
        '000000000000000100000000000000000000000000000011');
    expectInteger(-2147483647, '62706c697374303013ffffffff800000010800000000000'
        '00101000000000000000100000000000000000000000000000011');
    expectInteger(-2147483648, '62706c697374303013ffffffff800000000800000000000'
        '00101000000000000000100000000000000000000000000000011');
    expectInteger(-2147483649, '62706c697374303013ffffffff7fffffff0800000000000'
        '00101000000000000000100000000000000000000000000000011');
    expectInteger(-9223372036854775807, '62706c69737430301380000000000000010800'
        '00000000000101000000000000000100000000000000000000000000000011');
    expectInteger(-9223372036854775808, '62706c69737430301380000000000000000800'
        '00000000000101000000000000000100000000000000000000000000000011');
  });

  test('float', () {
    expectDouble(0.0, '62706c69737430302200000000080000000000000101000000000000'
        '00010000000000000000000000000000000d');
    expectDouble(1.0, '62706c6973743030223f800000080000000000000101000000000000'
        '00010000000000000000000000000000000d');
    expectDouble(2.5, '62706c69737430302240200000080000000000000101000000000000'
        '00010000000000000000000000000000000d');
    // Input was 987654321.12345, but due to lack of precision, output will
    // be 987654336.0
    expectDouble(987654336.0, '62706c6973743030224e6b79a3080000000000000101'
        '00000000000000010000000000000000000000000000000d');
    expectDouble(-1.0, '62706c697374303022bf80000008000000000000010100000000000'
        '000010000000000000000000000000000000d');
    expectDouble(-2.5, '62706c697374303022c020000008000000000000010100000000000'
        '000010000000000000000000000000000000d');
    // Input was -987654321.12345, but due to lack of precision, output will
    // be 987654336.0
    expectDouble(-987654336.0, '62706c697374303022ce6b79a308000000000000010'
        '100000000000000010000000000000000000000000000000d');

    expectDouble(0.0, '62706c69737430302300000000000000000800000000000001010000'
        '00000000000100000000000000000000000000000011');
    expectDouble(1.0, '62706c6973743030233ff00000000000000800000000000001010000'
        '00000000000100000000000000000000000000000011');
    expectDouble(2.5, '62706c69737430302340040000000000000800000000000001010000'
        '00000000000100000000000000000000000000000011');
    expectDouble(987654321.12345, '62706c69737430302341cd6f34588fcd360800000000'
        '00000101000000000000000100000000000000000000000000000011');
    expectDouble(-1.0, '62706c697374303023bff0000000000000080000000000000101000'
        '000000000000100000000000000000000000000000011');
    expectDouble(-2.5, '62706c697374303023c004000000000000080000000000000101000'
        '000000000000100000000000000000000000000000011');
    expectDouble(-987654321.12345, '62706c697374303023c1cd6f34588fcd36080000000'
        '000000101000000000000000100000000000000000000000000000011');
  });

  group('boolean', () {
    test('true', () {
      expectBoolean(true, '62706c6973743030090800000000000001010000000000000001'
          '00000000000000000000000000000009');
    });

    test('false', () {
      expectBoolean(
          false, '62706c6973743030080800000000000001010000000000000001000000000'
          '00000000000000000000009');
    });
  });

  // Date

  test('date', () {
    expectDate(DateTime.utc(1970, DateTime.january, 1, 12, 0, 0), '62706c697374'
        '303033c1cd278fe0000000080000000000000101000000000000000100000000000000'
        '000000000000000011');
    expectDate(DateTime.utc(1890, DateTime.june, 25, 06, 45, 13), '62706c697374'
        '303033c1e9fc3af0e00000080000000000000101000000000000000100000000000000'
        '000000000000000011');
    expectDate(DateTime.utc(2019, DateTime.november, 4, 14, 22, 59), '62706c697'
        '37430303341c1b835e1800000080000000000000101000000000000000100000000000'
        '000000000000000000011');
  });

  // Data

  test('data', () {
    expectData(0, '62706c697374303040080000000000000101000000000000000100000000'
        '000000000000000000000009');
    expectData(1, '62706c697374303041000800000000000001010000000000000001000000'
        '0000000000000000000000000a');
    expectData(2, '62706c697374303042000108000000000000010100000000000000010000'
        '000000000000000000000000000b');
    expectData(14, '62706c69737430304e000102030405060708090a0b0c0d0800000000000'
        '00101000000000000000100000000000000000000000000000017');
    expectData(15, '62706c69737430304f100f000102030405060708090a0b0c0d0e0800000'
        '0000000010100000000000000010000000000000000000000000000001a');
    expectData(16, '62706c69737430304f1010000102030405060708090a0b0c0d0e0f08000'
        '000000000010100000000000000010000000000000000000000000000001b');
    expectData(100, '62706c69737430304f1064000102030405060708090a0b0c0d0e0f1011'
        '12131415161718191a1b1c1d1e1f202122232425262728292a2b2c2d2e2f3031323334'
        '35363738393a3b3c3d3e3f404142434445464748494a4b4c4d4e4f5051525354555657'
        '58595a5b5c5d5e5f606162630800000000000001010000000000000001000000000000'
        '0000000000000000006f');
    expectData(1000, '62706c69737430304f1103e8000102030405060708090a0b0c0d0e0f1'
        '01112131415161718191a1b1c1d1e1f202122232425262728292a2b2c2d2e2f3031323'
        '33435363738393a3b3c3d3e3f404142434445464748494a4b4c4d4e4f5051525354555'
        '65758595a5b5c5d5e5f606162636465666768696a6b6c6d6e6f7071727374757677787'
        '97a7b7c7d7e7f808182838485868788898a8b8c8d8e8f909192939495969798999a9b9'
        'c9d9e9fa0a1a2a3a4a5a6a7a8a9aaabacadaeafb0b1b2b3b4b5b6b7b8b9babbbcbdbeb'
        'fc0c1c2c3c4c5c6c7c8c9cacbcccdcecfd0d1d2d3d4d5d6d7d8d9dadbdcdddedfe0e1e'
        '2e3e4e5e6e7e8e9eaebecedeeeff0f1f2f3f4f5f6f7f8f9fafbfcfdfeff00010203040'
        '5060708090a0b0c0d0e0f101112131415161718191a1b1c1d1e1f20212223242526272'
        '8292a2b2c2d2e2f303132333435363738393a3b3c3d3e3f404142434445464748494a4'
        'b4c4d4e4f505152535455565758595a5b5c5d5e5f606162636465666768696a6b6c6d6'
        'e6f707172737475767778797a7b7c7d7e7f808182838485868788898a8b8c8d8e8f909'
        '192939495969798999a9b9c9d9e9fa0a1a2a3a4a5a6a7a8a9aaabacadaeafb0b1b2b3b'
        '4b5b6b7b8b9babbbcbdbebfc0c1c2c3c4c5c6c7c8c9cacbcccdcecfd0d1d2d3d4d5d6d'
        '7d8d9dadbdcdddedfe0e1e2e3e4e5e6e7e8e9eaebecedeeeff0f1f2f3f4f5f6f7f8f9f'
        'afbfcfdfeff000102030405060708090a0b0c0d0e0f101112131415161718191a1b1c1'
        'd1e1f202122232425262728292a2b2c2d2e2f303132333435363738393a3b3c3d3e3f4'
        '04142434445464748494a4b4c4d4e4f505152535455565758595a5b5c5d5e5f6061626'
        '36465666768696a6b6c6d6e6f707172737475767778797a7b7c7d7e7f8081828384858'
        '68788898a8b8c8d8e8f909192939495969798999a9b9c9d9e9fa0a1a2a3a4a5a6a7a8a'
        '9aaabacadaeafb0b1b2b3b4b5b6b7b8b9babbbcbdbebfc0c1c2c3c4c5c6c7c8c9cacbc'
        'ccdcecfd0d1d2d3d4d5d6d7d8d9dadbdcdddedfe0e1e2e3e4e5e6e7e8e9eaebecedeee'
        'ff0f1f2f3f4f5f6f7f8f9fafbfcfdfeff000102030405060708090a0b0c0d0e0f10111'
        '2131415161718191a1b1c1d1e1f202122232425262728292a2b2c2d2e2f30313233343'
        '5363738393a3b3c3d3e3f404142434445464748494a4b4c4d4e4f50515253545556575'
        '8595a5b5c5d5e5f606162636465666768696a6b6c6d6e6f707172737475767778797a7'
        'b7c7d7e7f808182838485868788898a8b8c8d8e8f909192939495969798999a9b9c9d9'
        'e9fa0a1a2a3a4a5a6a7a8a9aaabacadaeafb0b1b2b3b4b5b6b7b8b9babbbcbdbebfc0c'
        '1c2c3c4c5c6c7c8c9cacbcccdcecfd0d1d2d3d4d5d6d7d8d9dadbdcdddedfe0e1e2e3e'
        '4e5e6e7000800000000000002010000000000000001000000000000000000000000000'
        '003f4');
  });
}

/// Converts a hex encoded string [template] and returns it as ByteData.

ByteData bytes(String template) {
  var list = hex.decoder.convert(template);
  var ulist = Uint8List.fromList(list);
  var buffer = ulist.buffer;
  return ByteData.view(buffer);
}

/// Generates a ByteData of [len] length, whose values increment from 0..length.
/// The values wrap at 255 back to 0.

ByteData makeData(int len) {
  var gen = ByteData(len);
  var v = 0;
  for (var i = 0; i < len; i++) {
    gen.setUint8(i, v);
    v++;
    if (v == 256) {
      v = 0;
    }
  }
  return gen;
}

/// Compares [actual] and [matcher] ByteData's for exact size and contents.

void expectByteData(ByteData actual, ByteData matcher) {
  expect(actual.lengthInBytes, equals(matcher.lengthInBytes));
  for (var i = 0; i < actual.lengthInBytes; i++) {
    expect(actual.getUint8(i), equals(matcher.getUint8(i)));
  }
}

/// Decodes the plist hex encoded string [template] and compares the resulting
/// object as String [matcher].

void expectString(String matcher, String template) {
  var p = BinaryPropertyListReader(bytes(template), false);
  var o = p.parse();
  expect(true, o.runtimeType == String);
  var s = o as String;
  expect(s, equals(matcher));
}

/// Decodes the plist hex encoded string [template] and compares the resulting
/// object as an int [matcher].

void expectInteger(int matcher, String template) {
  var p = BinaryPropertyListReader(bytes(template), false);
  var o = p.parse();
  expect(true, o.runtimeType == int);
  var i = o as int;
  expect(i, equals(matcher));
}

/// Decodes the plist hex encoded string [template] and compares the resulting
/// object as a double [matcher].

void expectDouble(double matcher, String template) {
  var p = BinaryPropertyListReader(bytes(template), false);
  var o = p.parse();
  expect(true, o.runtimeType == double);
  var d = o as double;
  expect(d, equals(matcher));
}

/// Decodes the plist hex encoded string [template] and compares the resulting
/// object as a boolean [matcher].

void expectBoolean(bool matcher, String template) {
  var p = BinaryPropertyListReader(bytes(template), false);
  var o = p.parse();
  expect(true, o.runtimeType == bool);
  var d = o as bool;
  expect(d, matcher);
}

/// Decodes the plist hex encoded string [template] and compares the resulting
/// object as a DateTime [matcher].

void expectDate(DateTime matcher, String template) {
  var p = BinaryPropertyListReader(bytes(template), false);
  var o = p.parse();
  expect(true, o.runtimeType == DateTime);
  var d = o as DateTime;
  expect(d, matcher);
}

/// Decodes the plist hex encoded string [template] and compares the resulting
/// object as a ByteData [matcher].

void expectData(int length, String template) {
  var p = BinaryPropertyListReader(bytes(template), false);
  var o = p.parse();
  var d = o as ByteData;
  var b = makeData(length);
  expectByteData(d, b);
}