// binarypropertylistwriter.dart
// PropertyListSerialization Copyright © 2021; Electric Bolt Limited.

import 'dart:convert';
import 'dart:ffi';
import 'dart:typed_data';
import '../propertylistserialization.dart';
import 'dateutil.dart';
import 'package:PropertyListSerialization/src/bytedatawriter.dart';

/// Property list elements are written as follows:
///
/// Dart String ->  string (NSString)
/// Dart int -> integer (NSInteger)
/// Float32 -> real (float)
/// Dart double -> real (double)
/// Dart Map<String, Object> -> dict (NSDictionary)
/// Dart List<Object> -> array (NSArray)
/// Dart DateTime -> date (NSDate)
/// Dart true -> true (BOOL)
/// Dart false -> false (BOOL)
/// ByteData -> data (NSData)

/// Represents a 32-bit 'float' type.

class BinaryPropertyListWriter {

  final Object _rootObj;
  final Map<Object, int> _objectIdMap;
  late int _objectRefSize;
  final ByteDataWriter _os;

  BinaryPropertyListWriter(Object rootObj)
      : _rootObj = rootObj, _objectIdMap = <Object, int>{}, _os = ByteDataWriter();

  ByteData write() {
    // CFBinaryPlistHeader
    _os.writeByteData(ascii.encoder.convert('bplist00').buffer.asByteData());

    // Assign objects unique id
    _mapObject(_rootObj);

    if (_objectIdMap.length < 256) {
      _objectRefSize = 1;
    } else if (_objectIdMap.length < 65536) {
      _objectRefSize = 2;
    } else {
      _objectRefSize = 4;
    }

    var offsetTable = List<int>.filled(_objectIdMap.length, 0);

    // Write objects and save each byte offset into offsetTable
    for (var entry in _objectIdMap.entries) {
      offsetTable[entry.value] = _os.length;
      var obj = entry.key;

      if (obj is Map) {
        _writeLength(0xD, obj.length);
        for (var entry in obj.entries) {
          _writeLong(_objectIdMap[entry.key]!, _objectRefSize);
        }
        for (var entry in obj.entries) {
          _writeLong(_objectIdMap[entry.value]!, _objectRefSize);
        }
      } else if (obj is List) {
        _writeLength(0xA, obj.length);
        for (var value in obj) {
          _writeLong(_objectIdMap[value]!, _objectRefSize);
        }
      } else if (obj is String) {
        var byteBuf;
        var intType;
        if (_isValidAscii(obj)) {
          // ascii
          byteBuf = ascii.encoder.convert(obj).buffer.asByteData();
          intType = 0x5;
        } else {
          // utf16
          // Convert string to array of code units. Each code unit will 16-bit
          // integer.
          var list = Uint16List.fromList(obj.codeUnits);
          // Convert 16-bit integer to two 8-bit bytes, this will be in
          // little-endian order.
          var byteList = list.buffer.asUint8List();
          // Swap byte order from little-endian to big-endian.
          for (var i = 0; i < byteList.length; i+=2) {
            var temp = byteList[i+1];
            byteList[i+1] = byteList[i];
            byteList[i] = temp;
          }
          byteBuf = byteList.buffer.asByteData();
          intType = 0x6;
        }
        _writeLength(intType, obj.length);
        _os.writeByteData(byteBuf);
      } else if (obj is Float32) {
        _os.writeUint8(0x22);
        _os.writeFloat32(obj.value);
      } else if (obj is double) {
        _os.writeUint8(0x23);
        _os.writeFloat64(obj);
      } else if (obj is int) {
        if (obj < 0) {
          // All negative integers are stored as a long
          _os.writeUint8(0x13);
          _os.writeInt64(obj);
        } else if (obj < 256) {
          // byte
          _os.writeUint8(0x10);
          _os.writeInt8(obj);
        } else if (obj < 65536) {
          // short
          _os.writeUint8(0x11);
          _os.writeInt16(obj);
        } else if (obj < 4294967296) {
          // int
          _os.writeUint8(0x12);
          _os.writeInt32(obj);
        } else {
          // long
          _os.writeUint8(0x13);
          _os.writeInt64(obj);
        }
      } else if (obj is DateTime) {
        _os.writeUint8(0x33);
        _os.writeFloat64(formatBinary(obj));
      } else if (obj is bool) {
        if (obj == false) {
          _os.writeUint8(0x08);
        } else {
          _os.writeUint8(0x09);
        }
      } else if (obj is ByteData) {
        _writeLength(0x4, obj.lengthInBytes);
        _os.writeByteData(obj);
      }
    }

    // Write offsetTable
    var offsetTableOffset = _os.length;
    var offsetIntSize = 4;
    if (_os.length < 256) {
      offsetIntSize = 1;
    } else if (_os.length < 65536) {
      offsetIntSize = 2;
    }
    for (var offset in offsetTable) {
      _writeLong(offset, offsetIntSize);
    }

    // CFBinaryPlistTrailer
    _writeLong(0, 6);
    _os.writeUint8(offsetIntSize);
    _os.writeUint8(_objectRefSize);
    _os.writeUint64(_objectIdMap.length);
    _os.writeUint64(_objectIdMap[_rootObj]!);
    _os.writeUint64(offsetTableOffset);

    return _os.toByteData();
  }

  /// Returns [true] if the string [value] is made up only of ascii
  /// characters. Returns [false] if the string [value] is unicode.

  bool _isValidAscii(String value) {
    for (var i = 0; i < value.length; i++) {
      var codeUnit = value.codeUnitAt(i);
      if ((codeUnit & ~0x7F) != 0) {
        return false;
      }
    }
    return true;
  }

  /// For each unique object, assigns an object id.

  void _mapObject(Object obj) {
    if (!_objectIdMap.containsKey(obj)) {
      _objectIdMap[obj] = _objectIdMap.length;
    }
    if (obj is Map) {
      for (var entry in obj.entries) {
        _mapObject(entry.key);
      }
      for (var entry in obj.entries) {
        _mapObject(entry.value);
      }
    } else if (obj is List) {
      for (var entry in obj) {
        _mapObject(entry);
      }
    } else if (obj is String || obj is int || obj is Float32 || obj is double
        || obj is ByteData || obj is DateTime || obj is bool) {
      // do nothing.
    } else {
      throw StateError('Incompatible object $obj found');
    }
  }

  void _writeLong(int value, int length) {
    for (var i = length - 1; i >= 0; i--) {
      _os.writeUint8(value >> (8 * i));
    }
  }
  void _writeLength(int intType, int length) {
    if (length < 15) {
      _os.writeUint8((intType << 4) + length);
    } else if (length < 256) {
      _os.writeUint8((intType << 4) + 0xF);
      _os.writeUint8(0x10);
      _writeLong(length, 1);
    } else if (length < 65536) {
      _os.writeUint8((intType << 4) + 0xF);
      _os.writeUint8(0x11);
      _writeLong(length, 2);
    } else {
      _os.writeUint8((intType << 4) + 0xF);
      _os.writeUint8(0x12);
      _writeLong(length, 4);
    }
  }

}