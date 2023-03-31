// binarypropertylistwriter_test.dart
// PropertyListSerialization Copyright © 2021; Electric Bolt Limited.

import 'dart:typed_data';

import 'package:convert/convert.dart';
import 'package:propertylistserialization/propertylistserialization.dart';
import 'package:propertylistserialization/src/binarypropertylistreader.dart';
import 'package:propertylistserialization/src/binarypropertylistwriter.dart';
import 'package:test/test.dart';

import 'binarypropertylistreader_test.dart';

void main() {
  test('ByteDataWrapper', () {
    // Test that the internal ByteDataWrapper class performs equality and
    // hashCode across the entire array of bytes contained within. (Unlike
    // ByteData which simply compares for equivalent object references).
    final b1 = bytes('62706c6973');
    final b2 = bytes('62706c6973');
    final b3 = bytes('62757cd3fa');
    final bw1 = ByteDataWrapper(b1);
    final bw2 = ByteDataWrapper(b2);
    final bw3 = ByteDataWrapper(b3);

    if (bw1 != bw2) {
      fail('bw1 should equal bw2');
    }
    if (bw1 == bw3) {
      fail('bw1 should not equal bw3');
    }

    final map = <ByteDataWrapper, ByteDataWrapper>{};
    map[bw1] = bw1;
    map[bw2] = bw2;
    expect(map.length, equals(1));
    expect(
      hex.encoder.convert(Uint8List.sublistView(map[bw1]!.value)),
      equals('62706c6973'),
    );

    map[bw3] = bw3;
    expect(map.length, equals(2));
    expect(
      hex.encoder.convert(Uint8List.sublistView(map[bw3]!.value)),
      equals('62757cd3fa'),
    );
  });

  group('array', () {
    test('emptyArray', () {
      const xcodeTemplate =
          '62706c6973743030a00800000000000001010000000000000001'
          '00000000000000000000000000000009';

      final p = BinaryPropertyListWriter(<String>[]);
      final g = p.write();
      expectByteData(g, bytes(xcodeTemplate));
    });

    test('filledArray', () {
      const xcodeTemplate =
          '62706c6973743030aa0102030405060708090a1000223fc00000'
          '23400400000000000009084500010203044f1014000102030405060708090a0b0c0d'
          '0e0f1011121333c1e9fc3af0e000005f101b54686520636f77206a756d706564206f'
          '7665722074686520646f676f101f0100010100540068006500200063006f00770020'
          '006a0075006d0070006500640020006f007600650072002000740068006500200064'
          '006f0067010201030813151a2324252b424b69000000000000010100000000000000'
          '0b000000000000000000000000000000aa';

      final list = [];
      list.add(0);
      list.add(Float32(1.5));
      list.add(2.5);
      list.add(true);
      list.add(false);
      list.add(makeData(5));
      list.add(makeData(20));
      list.add(DateTime.utc(1890, DateTime.june, 25, 06, 45, 13));
      list.add('The cow jumped over the dog');
      list.add('\u0100\u0101The cow jumped over the dog\u0102\u0103');

      final p = BinaryPropertyListWriter(list);
      final g = p.write();
      expectByteData(g, bytes(xcodeTemplate));
    });
  });

  group('dict', () {
    test('emptyDict', () {
      const xcodeTemplate =
          '62706c6973743030d00800000000000001010000000000000001'
          '00000000000000000000000000000009';

      final p = BinaryPropertyListWriter(<String, Object>{});
      final g = p.write();
      expectByteData(g, bytes(xcodeTemplate));
    });

    // Dict

    test('dictInteger25', () {
      const xcodeTemplate =
          '62706c6973743030d1010253696e741019080b0f000000000000'
          '0101000000000000000300000000000000000000000000000011';

      final dict = <String, int>{};
      dict['int'] = 25;

      final p = BinaryPropertyListWriter(dict);
      final g = p.write();
      expectByteData(g, bytes(xcodeTemplate));
    });

    test('filledDict', () {
      var dict = <String, Object>{};
      dict['int'] = 0;
      dict['float'] = Float32(1.5);
      dict['double'] = 2.5;
      dict['true'] = true;
      dict['false'] = false;
      dict['data5'] = makeData(5);
      dict['data20'] = makeData(20);
      dict['date'] = DateTime.utc(1890, DateTime.june, 25, 06, 45, 13);
      dict['ascii'] = 'The cow jumped over the dog';
      dict['utf16'] = '\u0100\u0101The cow jumped over the dog\u0102\u0103';

      final p = BinaryPropertyListWriter(dict);
      final g = p.write();

      // Can't test against the string template, since the order of the
      // dictionaries is undefined in binary plists (as opposed to xml plists
      // which are sorted in ascending order).
      // var xcodeTemplate = '62706c6973743030da0102030405060708090a0b0c0d0e0f1'
      //     '0111213145664617461323056646f75626c6553696e745566616c736555757466'
      //     '31365464617465547472756555666c6f61745564617461355561736369694f101'
      //     '4000102030405060708090a0b0c0d0e0f10111213234004000000000000100008'
      //     '6f101f0100010100540068006500200063006f00770020006a0075006d0070006'
      //     '500640020006f007600650072002000740068006500200064006f006701020103'
      //     '33c1e9fc3af0e0000009223fc000004500010203045f101b54686520636f77206'
      //     'a756d706564206f7665722074686520646f67081d242b2f353b40454b51576e77'
      //     '797abbc4c5cad0000000000000010100000000000000150000000000000000000'
      //     '00000000000ee';

      expect(
        g.lengthInBytes,
        291,
      ); // the length will be identical to the xcodeTemplate above.

      final q = BinaryPropertyListReader(g, keyedArchive: false);
      final o = q.parse();
      expect(o.runtimeType, <String, Object>{}.runtimeType);
      dict = o as Map<String, Object>;
      expect(dict.length, equals(10));
      expect(dict['int'], equals(0));
      expect(dict['float'], equals(1.5));
      expect(dict['double'], equals(2.5));
      expect(dict['true'], equals(true));
      expect(dict['false'], equals(false));
      expectByteData(dict['data5'] as ByteData, makeData(5));
      expectByteData(dict['data20'] as ByteData, makeData(20));
      expect(
        dict['date'],
        equals(DateTime.utc(1890, DateTime.june, 25, 06, 45, 13)),
      );
      expect(dict['ascii'], equals('The cow jumped over the dog'));
      expect(
        dict['utf16'],
        equals('\u0100\u0101The cow jumped over the dog\u0102'
            '\u0103'),
      );
    });
  });

  group('string', () {
    test('asciiString', () {
      testString(
          '',
          '62706c69737430305008000000000000010100000000000000010000000000000000'
              '0000000000000009');
      testString(
          ' ',
          '62706c697374303051200800000000000001010000000000000001000000000'
              '0000000000000000000000a');
      testString(
          'The dog jumped over the moon',
          '62706c69737430305f101c54686520646f67'
              '206a756d706564206f76657220746865206d6f6f6e08000000000000010100000000'
              '0000000100000000000000000000000000000027');
    });

    test('unicodeString', () {
      testString(
          'Ā',
          '62706c697374303061010008000000000000010100000000000000010000000'
              '000000000000000000000000b');
      testString(
          'Āā',
          '62706c69737430306201000101080000000000000101000000000000000100'
              '00000000000000000000000000000d');
      testString(
          'ĀāThe cow jumped over the dogĂă',
          '62706c69737430306f101f01000101005'
              '40068006500200063006f00770020006a0075006d0070006500640020006f0076006'
              '50072002000740068006500200064006f00670102010308000000000000010100000'
              '0000000000100000000000000000000000000000049');
    });
  });

  // Integer

  test('integer', () {
    testInteger(
        0,
        '62706c69737430301000080000000000000101000000000000000100000'
        '00000000000000000000000000a');
    testInteger(
        1,
        '62706c69737430301001080000000000000101000000000000000100000'
        '00000000000000000000000000a');
    testInteger(
        126,
        '62706c6973743030107e0800000000000001010000000000000001000'
        '0000000000000000000000000000a');
    testInteger(
        127,
        '62706c6973743030107f0800000000000001010000000000000001000'
        '0000000000000000000000000000a');
    testInteger(
        128,
        '62706c697374303010800800000000000001010000000000000001000'
        '0000000000000000000000000000a');
    testInteger(
        254,
        '62706c697374303010fe0800000000000001010000000000000001000'
        '0000000000000000000000000000a');
    testInteger(
        255,
        '62706c697374303010ff0800000000000001010000000000000001000'
        '0000000000000000000000000000a');
    testInteger(
        256,
        '62706c697374303011010008000000000000010100000000000000010'
        '000000000000000000000000000000b');
    testInteger(
        32766,
        '62706c6973743030117ffe080000000000000101000000000000000'
        '10000000000000000000000000000000b');
    testInteger(
        32767,
        '62706c6973743030117fff080000000000000101000000000000000'
        '10000000000000000000000000000000b');
    testInteger(
        32768,
        '62706c6973743030118000080000000000000101000000000000000'
        '10000000000000000000000000000000b');
    testInteger(
        65534,
        '62706c697374303011fffe080000000000000101000000000000000'
        '10000000000000000000000000000000b');
    testInteger(
        65535,
        '62706c697374303011ffff080000000000000101000000000000000'
        '10000000000000000000000000000000b');
    testInteger(
        65536,
        '62706c6973743030120001000008000000000000010100000000000'
        '000010000000000000000000000000000000d');
    testInteger(
        2147483646,
        '62706c6973743030127ffffffe080000000000000101000000'
        '00000000010000000000000000000000000000000d');
    testInteger(
        2147483647,
        '62706c6973743030127fffffff080000000000000101000000'
        '00000000010000000000000000000000000000000d');
    testInteger(
        2147483648,
        '62706c69737430301280000000080000000000000101000000'
        '00000000010000000000000000000000000000000d');
    testInteger(
        9223372036854775806,
        '62706c6973743030137ffffffffffffffe0800000'
        '00000000101000000000000000100000000000000000000000000000011');
    testInteger(
        9223372036854775807,
        '62706c6973743030137fffffffffffffff0800000'
        '00000000101000000000000000100000000000000000000000000000011');

    // negative
    testInteger(
        -1,
        '62706c697374303013ffffffffffffffff080000000000000101000000'
        '000000000100000000000000000000000000000011');
    testInteger(
        -127,
        '62706c697374303013ffffffffffffff810800000000000001010000'
        '00000000000100000000000000000000000000000011');
    testInteger(
        -128,
        '62706c697374303013ffffffffffffff800800000000000001010000'
        '00000000000100000000000000000000000000000011');
    testInteger(
        -129,
        '62706c697374303013ffffffffffffff7f0800000000000001010000'
        '00000000000100000000000000000000000000000011');
    testInteger(
        -255,
        '62706c697374303013ffffffffffffff010800000000000001010000'
        '00000000000100000000000000000000000000000011');
    testInteger(
        -256,
        '62706c697374303013ffffffffffffff000800000000000001010000'
        '00000000000100000000000000000000000000000011');
    testInteger(
        -257,
        '62706c697374303013fffffffffffffeff0800000000000001010000'
        '00000000000100000000000000000000000000000011');
    testInteger(
        -32767,
        '62706c697374303013ffffffffffff800108000000000000010100'
        '0000000000000100000000000000000000000000000011');
    testInteger(
        -32768,
        '62706c697374303013ffffffffffff800008000000000000010100'
        '0000000000000100000000000000000000000000000011');
    testInteger(
        -32769,
        '62706c697374303013ffffffffffff7fff08000000000000010100'
        '0000000000000100000000000000000000000000000011');
    testInteger(
        -65534,
        '62706c697374303013ffffffffffff000208000000000000010100'
        '0000000000000100000000000000000000000000000011');
    testInteger(
        -65535,
        '62706c697374303013ffffffffffff000108000000000000010100'
        '0000000000000100000000000000000000000000000011');
    testInteger(
        -65536,
        '62706c697374303013ffffffffffff000008000000000000010100'
        '0000000000000100000000000000000000000000000011');
    testInteger(
        -2147483647,
        '62706c697374303013ffffffff80000001080000000000000'
        '101000000000000000100000000000000000000000000000011');
    testInteger(
        -2147483648,
        '62706c697374303013ffffffff80000000080000000000000'
        '101000000000000000100000000000000000000000000000011');
    testInteger(
        -2147483649,
        '62706c697374303013ffffffff7fffffff080000000000000'
        '101000000000000000100000000000000000000000000000011');
    testInteger(
        -9223372036854775807,
        '62706c6973743030138000000000000001080000'
        '000000000101000000000000000100000000000000000000000000000011');
    testInteger(
        -9223372036854775808,
        '62706c6973743030138000000000000000080000'
        '000000000101000000000000000100000000000000000000000000000011');
  });

  test('real', () {
    testFloat(
        0.0,
        '62706c69737430302200000000080000000000000101000000000000000'
        '10000000000000000000000000000000d');
    testFloat(
        1.0,
        '62706c6973743030223f800000080000000000000101000000000000000'
        '10000000000000000000000000000000d');
    testFloat(
        2.5,
        '62706c69737430302240200000080000000000000101000000000000000'
        '10000000000000000000000000000000d');
    testFloat(
        987654321.12345,
        '62706c6973743030224e6b79a3080000000000000101000'
        '00000000000010000000000000000000000000000000d');
    testFloat(
        -1.0,
        '62706c697374303022bf80000008000000000000010100000000000000'
        '010000000000000000000000000000000d');
    testFloat(
        -2.5,
        '62706c697374303022c020000008000000000000010100000000000000'
        '010000000000000000000000000000000d');
    testFloat(
        -987654321.12345,
        '62706c697374303022ce6b79a308000000000000010100'
        '000000000000010000000000000000000000000000000d');

    testDouble(
        0.0,
        '62706c6973743030230000000000000000080000000000000101000000'
        '000000000100000000000000000000000000000011');
    testDouble(
        1.0,
        '62706c6973743030233ff0000000000000080000000000000101000000'
        '000000000100000000000000000000000000000011');
    testDouble(
        2.5,
        '62706c6973743030234004000000000000080000000000000101000000'
        '000000000100000000000000000000000000000011');
    testDouble(
        987654321.12345,
        '62706c69737430302341cd6f34588fcd36080000000000'
        '000101000000000000000100000000000000000000000000000011');
    testDouble(
        -1.0,
        '62706c697374303023bff000000000000008000000000000010100000'
        '0000000000100000000000000000000000000000011');
    testDouble(
        -2.5,
        '62706c697374303023c00400000000000008000000000000010100000'
        '0000000000100000000000000000000000000000011');
    testDouble(
        -987654321.12345,
        '62706c697374303023c1cd6f34588fcd3608000000000'
        '0000101000000000000000100000000000000000000000000000011');
  });

  group('boolean', () {
    test('true', () {
      const xcodeTemplate =
          '62706c6973743030090800000000000001010000000000000001'
          '00000000000000000000000000000009';
      final p = BinaryPropertyListWriter(true);
      final g = p.write();
      expectByteData(bytes(xcodeTemplate), g);
    });

    test('false', () {
      const xcodeTemplate =
          '62706c6973743030080800000000000001010000000000000001'
          '00000000000000000000000000000009';
      final p = BinaryPropertyListWriter(false);
      final g = p.write();
      expectByteData(bytes(xcodeTemplate), g);
    });
  });

  test('date', () {
    testDate(
        DateTime.utc(1970, DateTime.january, 1, 12, 0, 0),
        '62706c697374303033c1cd278fe0000000080000000000000101000000000000000100'
        '000000000000000000000000000011');
    testDate(
        DateTime.utc(1890, DateTime.june, 25, 6, 45, 13),
        '62706c697374303033c1e9fc3af0e00000080000000000000101000000000000000100'
        '000000000000000000000000000011');
    testDate(
        DateTime.utc(2019, DateTime.november, 4, 14, 22, 59),
        '62706c69737430303341c1b835e1800000080000000000000101000000000000000100'
        '000000000000000000000000000011');
  });

  test('data', () {
    testData(
        0,
        '62706c69737430304008000000000000010100000000000000010000000000'
        '0000000000000000000009');
    testData(
        1,
        '62706c69737430304100080000000000000101000000000000000100000000'
        '00000000000000000000000a');
    testData(
        2,
        '62706c69737430304200010800000000000001010000000000000001000000'
        '0000000000000000000000000b');
    testData(
        14,
        '62706c69737430304e000102030405060708090a0b0c0d080000000000000'
        '101000000000000000100000000000000000000000000000017');
    testData(
        15,
        '62706c69737430304f100f000102030405060708090a0b0c0d0e080000000'
        '00000010100000000000000010000000000000000000000000000001a');
    testData(
        16,
        '62706c69737430304f1010000102030405060708090a0b0c0d0e0f0800000'
        '0000000010100000000000000010000000000000000000000000000001b');
    testData(
        100,
        '62706c69737430304f1064000102030405060708090a0b0c0d0e0f101112'
        '131415161718191a1b1c1d1e1f202122232425262728292a2b2c2d2e2f303132333435'
        '363738393a3b3c3d3e3f404142434445464748494a4b4c4d4e4f505152535455565758'
        '595a5b5c5d5e5f60616263080000000000000101000000000000000100000000000000'
        '00000000000000006f');
    testData(
        1000,
        '62706c69737430304f1103e8000102030405060708090a0b0c0d0e0f101'
        '112131415161718191a1b1c1d1e1f202122232425262728292a2b2c2d2e2f303132333'
        '435363738393a3b3c3d3e3f404142434445464748494a4b4c4d4e4f505152535455565'
        '758595a5b5c5d5e5f606162636465666768696a6b6c6d6e6f707172737475767778797'
        'a7b7c7d7e7f808182838485868788898a8b8c8d8e8f909192939495969798999a9b9c9'
        'd9e9fa0a1a2a3a4a5a6a7a8a9aaabacadaeafb0b1b2b3b4b5b6b7b8b9babbbcbdbebfc'
        '0c1c2c3c4c5c6c7c8c9cacbcccdcecfd0d1d2d3d4d5d6d7d8d9dadbdcdddedfe0e1e2e'
        '3e4e5e6e7e8e9eaebecedeeeff0f1f2f3f4f5f6f7f8f9fafbfcfdfeff0001020304050'
        '60708090a0b0c0d0e0f101112131415161718191a1b1c1d1e1f2021222324252627282'
        '92a2b2c2d2e2f303132333435363738393a3b3c3d3e3f404142434445464748494a4b4'
        'c4d4e4f505152535455565758595a5b5c5d5e5f606162636465666768696a6b6c6d6e6'
        'f707172737475767778797a7b7c7d7e7f808182838485868788898a8b8c8d8e8f90919'
        '2939495969798999a9b9c9d9e9fa0a1a2a3a4a5a6a7a8a9aaabacadaeafb0b1b2b3b4b'
        '5b6b7b8b9babbbcbdbebfc0c1c2c3c4c5c6c7c8c9cacbcccdcecfd0d1d2d3d4d5d6d7d'
        '8d9dadbdcdddedfe0e1e2e3e4e5e6e7e8e9eaebecedeeeff0f1f2f3f4f5f6f7f8f9faf'
        'bfcfdfeff000102030405060708090a0b0c0d0e0f101112131415161718191a1b1c1d1'
        'e1f202122232425262728292a2b2c2d2e2f303132333435363738393a3b3c3d3e3f404'
        '142434445464748494a4b4c4d4e4f505152535455565758595a5b5c5d5e5f606162636'
        '465666768696a6b6c6d6e6f707172737475767778797a7b7c7d7e7f808182838485868'
        '788898a8b8c8d8e8f909192939495969798999a9b9c9d9e9fa0a1a2a3a4a5a6a7a8a9a'
        'aabacadaeafb0b1b2b3b4b5b6b7b8b9babbbcbdbebfc0c1c2c3c4c5c6c7c8c9cacbccc'
        'dcecfd0d1d2d3d4d5d6d7d8d9dadbdcdddedfe0e1e2e3e4e5e6e7e8e9eaebecedeeeff'
        '0f1f2f3f4f5f6f7f8f9fafbfcfdfeff000102030405060708090a0b0c0d0e0f1011121'
        '31415161718191a1b1c1d1e1f202122232425262728292a2b2c2d2e2f3031323334353'
        '63738393a3b3c3d3e3f404142434445464748494a4b4c4d4e4f5051525354555657585'
        '95a5b5c5d5e5f606162636465666768696a6b6c6d6e6f707172737475767778797a7b7'
        'c7d7e7f808182838485868788898a8b8c8d8e8f909192939495969798999a9b9c9d9e9'
        'fa0a1a2a3a4a5a6a7a8a9aaabacadaeafb0b1b2b3b4b5b6b7b8b9babbbcbdbebfc0c1c'
        '2c3c4c5c6c7c8c9cacbcccdcecfd0d1d2d3d4d5d6d7d8d9dadbdcdddedfe0e1e2e3e4e'
        '5e6e700080000000000000201000000000000000100000000000000000000000000000'
        '3f4');
  });
}

void testData(int len, String xcodeTemplate) {
  final p = BinaryPropertyListWriter(makeData(len));
  final g = p.write();
  expectByteData(bytes(xcodeTemplate), g);
}

void testDate(DateTime value, String xcodeTemplate) {
  final p = BinaryPropertyListWriter(value);
  final g = p.write();
  expectByteData(bytes(xcodeTemplate), g);
}

void testInteger(int value, String xcodeTemplate) {
  final p = BinaryPropertyListWriter(value);
  final g = p.write();
  expectByteData(bytes(xcodeTemplate), g);
}

void testFloat(double value, String xcodeTemplate) {
  final p = BinaryPropertyListWriter(Float32(value));
  final g = p.write();
  expectByteData(bytes(xcodeTemplate), g);
}

void testDouble(double value, String xcodeTemplate) {
  final p = BinaryPropertyListWriter(value);
  final g = p.write();
  expectByteData(bytes(xcodeTemplate), g);
}

void testString(String actual, String xcodeTemplate) {
  final p = BinaryPropertyListWriter(actual);
  final g = p.write();
  expectByteData(bytes(xcodeTemplate), g);
}
