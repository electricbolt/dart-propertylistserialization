// bytedatawriter_test.dart
// PropertyListSerialization Copyright © 2021; Electric Bolt Limited.

import 'dart:typed_data';

import 'package:test/test.dart';
import 'package:propertylistserialization/src/bytedatawriter.dart';

void main() {
  group('unsignedInteger', () {
    test('uint8', () {
      var bdw = ByteDataWriter(10);
      for (var i = 0; i < 28; i++) {
        bdw.writeUint8(i);
      }
      var bd = bdw.toByteData();
      expect(bd.lengthInBytes, equals(28));
      for (var i = 0; i < 28; i++) {
        expect(bd.getUint8(i), equals(i));
      }
    });
    test('uint16', () {
      var bdw = ByteDataWriter(10);
      for (var i = 0; i < 28; i++) {
        bdw.writeUint16(i);
      }
      var bd = bdw.toByteData();
      expect(bd.lengthInBytes, equals(28 * 2));
      for (var i = 0; i < 28; i++) {
        expect(bd.getUint16(i * 2), equals(i));
      }
    });
    test('uint32', () {
      var bdw = ByteDataWriter(10);
      for (var i = 0; i < 28; i++) {
        bdw.writeUint32(i);
      }
      var bd = bdw.toByteData();
      expect(bd.lengthInBytes, equals(28 * 4));
      for (var i = 0; i < 28; i++) {
        expect(bd.getUint32(i * 4), equals(i));
      }
    });
    test('uint64', () {
      var bdw = ByteDataWriter(10);
      for (var i = 0; i < 28; i++) {
        bdw.writeUint64(i);
      }
      var bd = bdw.toByteData();
      expect(bd.lengthInBytes, equals(28 * 8));
      for (var i = 0; i < 28; i++) {
        expect(bd.getUint64(i * 8), equals(i));
      }
    });
  });

  group('float', () {
    test('Float32', () {
      var bdw = ByteDataWriter(10);
      for (var i = 0; i < 28; i++) {
        bdw.writeFloat32(i.toDouble());
      }
      var bd = bdw.toByteData();
      expect(bd.lengthInBytes, equals(28 * 4));
      for (var i = 0; i < 28; i++) {
        expect(bd.getFloat32(i * 4), i.toDouble());
      }
    });
    test('Float64', () {
      var bdw = ByteDataWriter(10);
      for (var i = 0; i < 28; i++) {
        bdw.writeFloat64(i.toDouble());
      }
      var bd = bdw.toByteData();
      expect(bd.lengthInBytes, equals(28 * 8));
      for (var i = 0; i < 28; i++) {
        expect(bd.getFloat64(i * 8), equals(i.toDouble()));
      }
    });
  });

  group('signedInteger', ()
  {
    test('Int8', () {
      var bdw = ByteDataWriter(10);
      for (var i = 0; i < 28; i++) {
        bdw.writeInt8(i);
      }
      var bd = bdw.toByteData();
      expect(bd.lengthInBytes, equals(28));
      for (var i = 0; i < 28; i++) {
        expect(bd.getInt8(i), equals(i));
      }
    });
    test('Int16', () {
      var bdw = ByteDataWriter(10);
      for (var i = 0; i < 28; i++) {
        bdw.writeInt16(i);
      }
      var bd = bdw.toByteData();
      expect(bd.lengthInBytes, equals(28 * 2));
      for (var i = 0; i < 28; i++) {
        expect(bd.getInt16(i * 2), equals(i));
      }
    });
    test('Int32', () {
      var bdw = ByteDataWriter(10);
      for (var i = 0; i < 28; i++) {
        bdw.writeInt32(i);
      }
      var bd = bdw.toByteData();
      expect(bd.lengthInBytes, equals(28 * 4));
      for (var i = 0; i < 28; i++) {
        expect(bd.getInt32(i * 4), equals(i));
      }
    });
    test('Int64', () {
      var bdw = ByteDataWriter(10);
      for (var i = 0; i < 28; i++) {
        bdw.writeInt64(i);
      }
      var bd = bdw.toByteData();
      expect(bd.lengthInBytes, equals(28 * 8));
      for (var i = 0; i < 28; i++) {
        expect(bd.getInt64(i * 8), equals(i));
      }
    });
  });

  test('bytedata', ()
  {
    var rounds=28;
    var bdw = ByteDataWriter(10);
    var v = 0x10;
    for (var i = 1; i <= rounds; i++) {
      var b = List.filled(i, 0x00);
      for (var j = 0; j < i; j++) {
        b[j] = v;
        v++;
        if (v == 0xF0) {
          v = 0x10;
        }
      }
      bdw.writeByteData(Uint8List.fromList(b).buffer.asByteData());
    }

    var bd = bdw.toByteData();
    var len = bd.lengthInBytes;
    expect(len, equals(((rounds*rounds)+rounds)/2)); // triangle number

    var offset = 0;
    v = 0x10;
    for (var i = 1; i <= rounds; i++) {
      for (var j = 0; j < i; j++) {
        expect(bd.getUint8(offset), v);
        offset++;
        v++;
        if (v == 0xF0) {
          v = 0x10;
        }
      }
    }
  });
}