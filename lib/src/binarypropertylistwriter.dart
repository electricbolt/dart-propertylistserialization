// binarypropertylistwriter.dart
// PropertyListSerialization Copyright © 2021; Electric Bolt Limited.

import 'dart:convert';
import 'dart:typed_data';
import '../propertylistserialization.dart';
import 'dateutil.dart';
import 'bytedatawriter.dart';
import 'package:convert/convert.dart';

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
///

class BinaryPropertyListWriter {

  final Object _rootObj;
  final Map<Object, int> _objectIdMap;
  late int _objectRefSize;
  final ByteDataWriter _os;
  final Map<int, IntegerWrapper> _integerWrapperMap;
  final Map<double, DoubleWrapper> _doubleWrapperMap;
  final Map<ByteDataWrapper, ByteDataWrapper> _byteDataWrapperMap;

  BinaryPropertyListWriter(Object rootObj)
      : _rootObj = rootObj, _objectIdMap = <Object, int>{},
        _os = ByteDataWriter(), _integerWrapperMap = <int, IntegerWrapper>{},
        _doubleWrapperMap = <double, DoubleWrapper>{}, _byteDataWrapperMap =
        <ByteDataWrapper, ByteDataWrapper>{};

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
      var obj = _readMap(entry.key);

      if (obj is Map) {
        _writeLength(0xD, obj.length);
        for (var entry in obj.entries) {
          var key = _readMap(entry.key);
          _writeLong(_objectIdMap[key]!, _objectRefSize);
        }
        for (var entry in obj.entries) {
          var value = _readMap(entry.value);
          _writeLong(_objectIdMap[value]!, _objectRefSize);
        }
      } else if (obj is List) {
        _writeLength(0xA, obj.length);
        for (var i = 0; i < obj.length; i++) {
          var value = _readMap(obj[i]);
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
      } else if (obj is DoubleWrapper) {
        _os.writeUint8(0x23);
        _os.writeFloat64(obj.value);
      } else if (obj is IntegerWrapper) {
        if (obj.value < 0) {
          // All negative integers are stored as a long
          _os.writeUint8(0x13);
          _os.writeInt64(obj.value);
        } else if (obj.value < 256) {
          // byte
          _os.writeUint8(0x10);
          _os.writeInt8(obj.value);
        } else if (obj.value < 65536) {
          // short
          _os.writeUint8(0x11);
          _os.writeInt16(obj.value);
        } else if (obj.value < 4294967296) {
          // int
          _os.writeUint8(0x12);
          _os.writeInt32(obj.value);
        } else {
          // long
          _os.writeUint8(0x13);
          _os.writeInt64(obj.value);
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
      } else if (obj is ByteDataWrapper) {
        _writeLength(0x4, obj.value.lengthInBytes);
        _os.writeByteData(obj.value);
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
    _os.writeUint64(_objectIdMap[_readMap(_rootObj)]!);
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
    obj = _wrapMap(obj);
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
    } else if (obj is String || obj is IntegerWrapper || obj is Float32 ||
        obj is DoubleWrapper || obj is ByteDataWrapper || obj is DateTime ||
        obj is bool) {
      // do nothing.
    } else {
      throw StateError('Incompatible object $obj found');
    }
  }

  /// If the [obj]ect provided is a num of type int, then returns an
  /// IntegerWrapper. If the [obj]ect provided is a num of type double, then
  /// returns a DoubleWrapper. If the [obj]ect provided is a ByteData, then
  /// returns a ByteDataWrapper. Otherwise just returns the [obj]ect unchanged.
  ///
  /// We need to wrap integers and doubles because dart equality means that
  /// 1 == 1.0. When storing in a map, checking for an object whose value is a
  /// an integer of '1' might incorrectly get the result of an object whose
  /// value is a double of '1.0'.
  ///
  /// ByteData's must also be wrapped as dart equality doesn't compare the
  /// contents of ByteData, which we need to aggressively deduplicate storage.

  Object _wrapMap(Object obj) {
    if (obj is int) {
      var result = _integerWrapperMap[obj];
      if (result == null) {
        result = IntegerWrapper(obj);
        _integerWrapperMap[obj] = result;
      }
      return result;
    } else if (obj is double) {
      var result = _doubleWrapperMap[obj];
      if (result == null) {
        result = DoubleWrapper(obj);
        _doubleWrapperMap[obj] = result;
      }
      return result;
    } else if (obj is ByteData) {
      // Always wrap the ByteData into a ByteDataWrapper. The lookup in the
      // _byteDataWrapperMap will use the hashCode and equality methods to
      // properly compare contents. The result will be any identical
      // ByteDataWrapper object.
      var wrapper = ByteDataWrapper(obj);
      var result = _byteDataWrapperMap[wrapper];
      if (result == null) {
        _byteDataWrapperMap[wrapper] = wrapper;
        return wrapper;
      } else {
        return result;
      }
    } else {
      return obj;
    }
  }

  Object _readMap(Object obj) {
    if (obj is int) {
      return _integerWrapperMap[obj]!;
    } else if (obj is double) {
      return _doubleWrapperMap[obj]!;
    } else if (obj is ByteData) {
      var wrapper = ByteDataWrapper(obj);
      return _byteDataWrapperMap[wrapper]!;
    } else {
      return obj;
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

/// Wrapper to force writing a double value as a 64-bit floating point number,
/// which is useful when storing num[bers] in a Map.

class DoubleWrapper {
  final double value;

  DoubleWrapper(this.value);

  @override
  bool operator ==(Object other) {
    if (!(other is DoubleWrapper)) {
      return false;
    }
    return value == other.value;
  }

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() {
    return value.toString();
  }

}

/// Wrapper to force writing an integer value as integer which is useful when
/// storing num[bers] in a Map.

class IntegerWrapper {
  final int value;

  IntegerWrapper(this.value);

  @override
  bool operator ==(Object other) {
    if (!(other is IntegerWrapper)) {
      return false;
    }
    return value == other.value;
  }

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() {
    return value.toString();
  }

}

/// Wrapper to force comparison of ByteData's for storage in a Map.

class ByteDataWrapper {
  final ByteData value;

  ByteDataWrapper(this.value);

  @override
  bool operator ==(Object other) {
    if (!(other is ByteDataWrapper)) {
      return false;
    }
    if (value.lengthInBytes != other.value.lengthInBytes) {
      return false;
    }
    for (var i = 0; i < value.lengthInBytes; i++) {
      if (value.getUint8(i) != other.value.getUint8(i)) {
        return false;
      }
    }
    return true;
  }

  @override
  int get hashCode {
    var result = 1;
    for (var i = 0; i < value.lengthInBytes; ++i) {
      result = 31 * result + value.getUint8(i);
    }
    return result;
  }

  @override
  String toString() {
    final len = 64;
    var sb = StringBuffer();
    sb.write('len=${value.lengthInBytes}');
    var list = Uint8List.sublistView(value);
    var str = hex.encoder.convert(list.sublist(0, list.length > len ? len :
      list.length));
    sb.write(' $str');
    if (list.length > len) {
      sb.write('...');
    }
    return sb.toString();
  }
}
