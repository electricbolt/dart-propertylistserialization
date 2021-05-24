// bytedatawriter.dart
// PropertyListSerialization Copyright © 2021; Electric Bolt Limited.

import 'dart:typed_data';

/// This class implements an automatically resizing buffer into which data can
/// be written to it as int8, int16, int32, int64, uint8, uint16, uint32,
/// uint64, float32 and float64 data types.

class ByteDataWriter {

  late int _bufferLength;
  late List<ByteData> _bufList;
  late List<int> _bufListSize;
  late ByteData _buf;
  late int _bufSize;
  late int _totalSize;

  int get length => _totalSize;

  /// Initializes a ByteDataWriter instance. Internally the class keeps
  /// multiple byte arrays of [bufferLength] size.

  ByteDataWriter([int bufferLength = 1024]) {
    assert (bufferLength >= Uint64List.bytesPerElement);

    _bufferLength = bufferLength;
    _bufList = <ByteData>[];
    _bufListSize = <int>[];
    _buf = ByteData(_bufferLength);
    _bufSize = 0;
    _totalSize = 0;
  }

  /// Writes a 8-bit signed integer [value] to the buffer.

  void writeInt8(int value) {
    _buf.setInt8(_bufSize, value);
    _bufSize++;
    _totalSize++;
    if (_bufSize == _bufferLength) {
      _nextBuf();
    }
  }

  /// Writes a 16-bit signed integer [value] to the buffer.

  void writeInt16(int value, [Endian endian = Endian.big]) {
    if (_bufSize + Int16List.bytesPerElement >= _bufferLength) {
      _nextBuf();
    }
    _buf.setInt16(_bufSize, value, endian);
    _bufSize += Int16List.bytesPerElement;
    _totalSize += Int16List.bytesPerElement;
    if (_bufSize == _bufferLength) {
      _nextBuf();
    }
  }

  /// Writes a 32-bit signed integer [value] to the buffer.

  void writeInt32(int value, [Endian endian = Endian.big]) {
    if (_bufSize + Int32List.bytesPerElement >= _bufferLength) {
      _nextBuf();
    }
    _buf.setInt32(_bufSize, value, endian);
    _bufSize += Int32List.bytesPerElement;
    _totalSize += Int32List.bytesPerElement;
    if (_bufSize == _bufferLength) {
      _nextBuf();
    }
  }

  /// Writes a 64-bit signed integer [value] to the buffer.

  void writeInt64(int value, [Endian endian = Endian.big]) {
    if (_bufSize + Int64List.bytesPerElement >= _bufferLength) {
      _nextBuf();
    }
    _buf.setInt64(_bufSize, value, endian);
    _bufSize += Int64List.bytesPerElement;
    _totalSize += Int64List.bytesPerElement;
    if (_bufSize == _bufferLength) {
      _nextBuf();
    }
  }

  /// Writes a 32-bit float [value] to the buffer.

  void writeFloat32(double value, [Endian endian = Endian.big]) {
    if (_bufSize + Float32List.bytesPerElement >= _bufferLength) {
      _nextBuf();
    }
    _buf.setFloat32(_bufSize, value, endian);
    _bufSize += Float32List.bytesPerElement;
    _totalSize += Float32List.bytesPerElement;
    if (_bufSize == _bufferLength) {
      _nextBuf();
    }
  }

  /// Writes a 64-bit double [value] to the buffer.

  void writeFloat64(double value, [Endian endian = Endian.big]) {
    if (_bufSize + Float64List.bytesPerElement >= _bufferLength) {
      _nextBuf();
    }
    _buf.setFloat64(_bufSize, value, endian);
    _bufSize += Float64List.bytesPerElement;
    _totalSize += Float64List.bytesPerElement;
    if (_bufSize == _bufferLength) {
      _nextBuf();
    }
  }

  /// Writes a 8-bit unsigned integer [value] to the buffer.

  void writeUint8(int value) {
    _buf.setUint8(_bufSize, value);
    _bufSize++;
    _totalSize++;
    if (_bufSize == _bufferLength) {
      _nextBuf();
    }
  }

  /// Writes a 16-bit unsigned integer [value] to the buffer.

  void writeUint16(int value, [Endian endian = Endian.big]) {
    if (_bufSize + Uint16List.bytesPerElement >= _bufferLength) {
      _nextBuf();
    }
    _buf.setUint16(_bufSize, value, endian);
    _bufSize += Uint16List.bytesPerElement;
    _totalSize += Uint16List.bytesPerElement;
    if (_bufSize == _bufferLength) {
      _nextBuf();
    }
  }

  /// Writes a 32-bit unsigned integer [value] to the buffer.

  void writeUint32(int value, [Endian endian = Endian.big]) {
    if (_bufSize + Uint32List.bytesPerElement >= _bufferLength) {
      _nextBuf();
    }
    _buf.setUint32(_bufSize, value, endian);
    _bufSize += Uint32List.bytesPerElement;
    _totalSize += Uint32List.bytesPerElement;
    if (_bufSize == _bufferLength) {
      _nextBuf();
    }
  }

  /// Writes a 64-bit unsigned integer [value] to the buffer.

  void writeUint64(int value, [Endian endian = Endian.big]) {
    if (_bufSize + Uint64List.bytesPerElement >= _bufferLength) {
      _nextBuf();
    }
    _buf.setUint64(_bufSize, value, endian);
    _bufSize += Uint64List.bytesPerElement;
    _totalSize += Uint64List.bytesPerElement;
    if (_bufSize == _bufferLength) {
      _nextBuf();
    }
  }

  /// Writes a [byteData] to the buffer.

  void writeByteData(ByteData byteData) {
    _bufList.add(_buf);
    _bufListSize.add(_bufSize);
    _bufList.add(byteData);
    _bufListSize.add(byteData.lengthInBytes);
    _totalSize += byteData.lengthInBytes;
    _buf = ByteData(_bufferLength);
    _bufSize = 0;
  }

  /// Returns a contiguous [ByteData] object with the contents of all the data
  /// written to the buffer.

  ByteData toByteData() {
    var result = Uint8List(_totalSize);
    var resultSize = 0;
    for (var i = 0; i < _bufListSize.length; i++) {
      var buf = _bufList[i].buffer.asUint8List(0, _bufListSize[i]);
      result.setAll(resultSize, buf);
      resultSize += _bufListSize[i];
    }
    if (_bufSize > 0) {
      result.setAll(resultSize, _buf.buffer.asUint8List(0, _bufSize));
    }
    return result.buffer.asByteData();
  }

  void _nextBuf() {
    _bufList.add(_buf);
    _bufListSize.add(_bufSize);
    _buf = ByteData(_bufferLength);
    _bufSize = 0;
  }

}