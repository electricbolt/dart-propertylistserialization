import 'package:test/test.dart';
import 'package:propertylistserialization/src/bytedatawriter.dart';

void main() {

  // unsigned integer

  test('Uint8', () {
    var bdw = ByteDataWriter(10);
    for (var i = 0; i < 28; i++) {
      bdw.writeUint8(i);
    }
    var bd = bdw.toByteData();
    expect(bd.lengthInBytes, 28);
    for (var i = 0; i < 28; i++) {
      expect(bd.getUint8(i), i);
    }
  });
  test('uint16', () {
    var bdw = ByteDataWriter(10);
    for (var i = 0; i < 28; i++) {
      bdw.writeUint16(i);
    }
    var bd = bdw.toByteData();
    expect(bd.lengthInBytes, 28*2);
    for (var i = 0; i < 28; i++) {
      expect(bd.getUint16(i*2), i);
    }
  });
  test('uint32', () {
    var bdw = ByteDataWriter(10);
    for (var i = 0; i < 28; i++) {
      bdw.writeUint32(i);
    }
    var bd = bdw.toByteData();
    expect(bd.lengthInBytes, 28*4);
    for (var i = 0; i < 28; i++) {
      expect(bd.getUint32(i*4), i);
    }
  });
  test('uint64', () {
    var bdw = ByteDataWriter(10);
    for (var i = 0; i < 28; i++) {
      bdw.writeUint64(i);
    }
    var bd = bdw.toByteData();
    expect(bd.lengthInBytes, 28*8);
    for (var i = 0; i < 28; i++) {
      expect(bd.getUint64(i*8), i);
    }
  });

  // float

  test('Float32', () {
    var bdw = ByteDataWriter(10);
    for (var i = 0; i < 28; i++) {
      bdw.writeFloat32(i.toDouble());
    }
    var bd = bdw.toByteData();
    expect(bd.lengthInBytes, 28*4);
    for (var i = 0; i < 28; i++) {
      expect(bd.getFloat32(i*4), i.toDouble());
    }
  });
  test('Float64', () {
    var bdw = ByteDataWriter(10);
    for (var i = 0; i < 28; i++) {
      bdw.writeFloat64(i.toDouble());
    }
    var bd = bdw.toByteData();
    expect(bd.lengthInBytes, 28*8);
    for (var i = 0; i < 28; i++) {
      expect(bd.getFloat64(i*8), i.toDouble());
    }
  });

  // signed integer

  test('Int8', () {
    var bdw = ByteDataWriter(10);
    for (var i = 0; i < 28; i++) {
      bdw.writeInt8(i);
    }
    var bd = bdw.toByteData();
    expect(bd.lengthInBytes, 28);
    for (var i = 0; i < 28; i++) {
      expect(bd.getInt8(i), i);
    }
  });
  test('Int16', () {
    var bdw = ByteDataWriter(10);
    for (var i = 0; i < 28; i++) {
      bdw.writeInt16(i);
    }
    var bd = bdw.toByteData();
    expect(bd.lengthInBytes, 28*2);
    for (var i = 0; i < 28; i++) {
      expect(bd.getInt16(i*2), i);
    }
  });
  test('Int32', () {
    var bdw = ByteDataWriter(10);
    for (var i = 0; i < 28; i++) {
      bdw.writeInt32(i);
    }
    var bd = bdw.toByteData();
    expect(bd.lengthInBytes, 28*4);
    for (var i = 0; i < 28; i++) {
      expect(bd.getInt32(i*4), i);
    }
  });
  test('Int64', () {
    var bdw = ByteDataWriter(10);
    for (var i = 0; i < 28; i++) {
      bdw.writeInt64(i);
    }
    var bd = bdw.toByteData();
    expect(bd.lengthInBytes, 28*8);
    for (var i = 0; i < 28; i++) {
      expect(bd.getInt64(i*8), i);
    }
  });
}