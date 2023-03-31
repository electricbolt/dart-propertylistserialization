// binarypropertylistreader.dart
// PropertyListSerialization Copyright © 2021; Electric Bolt Limited.

import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:propertylistserialization/propertylistserialization.dart';
import 'package:propertylistserialization/src/dateutil.dart';

/// Implements a subset of Apple property list (plist) parser - binary format
/// version "bplist00" only.
///
/// Property list elements are parsed as follows:
/// string (NSString) -> Dart String
/// integer (NSInteger) -> Dart int
/// real (double) -> Dart double
/// dict (NSDictionary) -> Dart Map<String, Object>
/// array (NSArray) -> Dart List<Object>
/// date (NSDate) -> Dart DateTime (utc)
/// true (BOOL) -> Dart true
/// false (BOOL) -> Dart false
/// data (NSData) -> Dart ByteData
///
/// NSKeyedArchiver elements are parsed as follows:
/// CF$UID -> Dart UID

class BinaryPropertyListReader {
  late int _objectRefSize;
  late List<int> _offsetTable;
  final ByteData _buf;
  final bool _keyedArchive;

  BinaryPropertyListReader(ByteData buf, {required bool keyedArchive})
      : _buf = buf,
        _keyedArchive = keyedArchive;

  Object parse() {
    // CFBinaryPlistHeader
    if (ascii.decoder.convert(_buf.buffer.asUint8List(0, 8)) != 'bplist00') {
      throw UnsupportedError('File is not binary plist or supported version');
    }

    // CFBinaryPlistTrailer
    final offsetIntSize = _buf.getUint8(_buf.lengthInBytes - 32 + 6);
    _objectRefSize = _buf.getUint8(_buf.lengthInBytes - 32 + 7);
    final numObjects = _buf.getUint64(_buf.lengthInBytes - 32 + 8);
    final rootObjectId = _buf.getUint64(_buf.lengthInBytes - 32 + 16);
    final offsetTableOffset = _buf.getUint64(_buf.lengthInBytes - 32 + 24);

    // Offset table
    _offsetTable = List.filled(numObjects, 0);
    for (var i = 0; i < numObjects; i++) {
      _offsetTable[i] =
          _readLong((offsetIntSize * i) + offsetTableOffset, offsetIntSize);
    }

    return readObject(rootObjectId);
  }

  Object readObject(int objectId) {
    final offset = _offsetTable[objectId];
    final value = _buf.getUint8(offset);
    final objectType = (value & 0xF0) >> 4; // high nibble
    final objectInfo = value & 0x0F; // low nibble
    switch (objectType) {
      case 0x0:
        switch (objectInfo) {
          case 0x8: // boolean false
            return false;
          case 0x9: // boolean true
            return true;
        }
        throw UnsupportedError('Unsupported objectInfo $objectInfo');
      case 0x1:
        // integer
        return _readLong(offset + 1, pow(2, objectInfo) as int);
      case 0x2:
        // real
        final size = pow(2, objectInfo) as int;
        if (size == 4) {
          return _buf.getFloat32(offset + 1);
        } else if (size == 8) {
          return _buf.getFloat64(offset + 1);
        }
        throw UnsupportedError('Unsupported real size');
      case 0x3:
        // date
        if (objectInfo != 0x3) {
          throw UnsupportedError('Unsupported date format $objectInfo');
        }
        final secondsSinceEpoch = _buf.getFloat64(offset + 1);
        return parseBinary(secondsSinceEpoch);
      case 0x4:
        {
          // data
          final lo = _readLengthOffset(offset, objectInfo);
          return _buf.buffer.asByteData(lo.offset, lo.length);
        }
      case 0x5:
        {
          // ascii string
          final lo = _readLengthOffset(offset, objectInfo);
          return ascii.decoder
              .convert(_buf.buffer.asUint8List(lo.offset, lo.length));
        }
      case 0x6:
        {
          // utf16 string
          final lo = _readLengthOffset(offset, objectInfo);
          final sb = StringBuffer();
          for (var i = 0; i < lo.length; i++) {
            final charCode = _buf.getUint16(lo.offset + (i * 2), Endian.big);
            sb.writeCharCode(charCode);
          }
          return sb.toString();
        }
      case 0x8:
        {
          if (_keyedArchive == false) {
            throw UnsupportedError('Unsupported plist objectType $objectType');
          }
          // NSKeyedArchiver CF$UID
          return UID(_readLong(offset + 1, objectInfo + 1));
        }
      case 0xA:
        {
          // array
          final lo = _readLengthOffset(offset, objectInfo);
          final array = <Object>[];
          for (var i = 0; i < lo.length; i++) {
            final arrayObjectId =
                _readLong(lo.offset + (i * _objectRefSize), _objectRefSize);
            array.add(readObject(arrayObjectId));
          }
          return array;
        }
      case 0xD:
        {
          // dict
          final lo = _readLengthOffset(offset, objectInfo);
          final dict = <String, Object>{};
          for (var i = 0; i < lo.length; i++) {
            final keyObjectId =
                _readLong(lo.offset + (i * _objectRefSize), _objectRefSize);
            final valueObjectId = _readLong(
              lo.offset + (i * _objectRefSize) + (lo.length * _objectRefSize),
              _objectRefSize,
            );
            dict[readObject(keyObjectId) as String] = readObject(valueObjectId);
          }
          return dict;
        }
    }
    throw UnsupportedError('Unsupported plist objectType $objectType');
  }

  /// Reads [length] bytes in host order from the buf at [offset] and converts
  /// to a long.
  int _readLong(int offset, int length) {
    var value = 0;
    for (var i = 0; i < length; i++) {
      value <<= 8;
      value |= _buf.getUint8(offset + i) & 0xFF;
    }
    return value;
  }

  _LengthOffset _readLengthOffset(int offset, int objectInfo) {
    final result = _LengthOffset();
    if (objectInfo == 0xF) {
      // Length values >= 15 are stored in the bytes following.
      final intInfo = _buf.getUint8(offset + 1) & 0x0F; // low nibble
      final size = pow(2, intInfo) as int;
      result.offset = offset + 2 + size;
      result.length = _readLong(offset + 2, size);
    } else {
      // Length values 0..14 are stored directly in the low nibble.
      result.offset = offset + 1;
      result.length = objectInfo;
    }
    return result;
  }
}

class _LengthOffset {
  late int length;
  late int offset;
}
