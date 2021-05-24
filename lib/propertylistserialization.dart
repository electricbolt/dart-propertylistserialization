// propertylistserialization.dart
// PropertyListSerialization Copyright © 2021; Electric Bolt Limited.

import 'dart:typed_data';

import 'package:PropertyListSerialization/src/binarypropertylistreader.dart';
import 'package:PropertyListSerialization/src/binarypropertylistwriter.dart';

import 'exceptions.dart';

/// Wrapper to force writing a double value as a 32-bit real (float)

class Float32 {
  final double value;
  Float32(this.value);
}

enum Format {
  xml,
  binary
}

class PropertyListSerialization {

  /// For the object graph provided, returns a property list as ByteData.
  /// Equivalent to iOS method
  /// `[NSPropertyList dataWithPropertyList:format:options:error]`
  ///
  /// The [obj] parameter is object graph to write out as a property list. The
  /// object graph may only contain the following types: String, int,
  /// Float32, double, Map<String, Object>, List, DateTime, bool or ByteData.
  /// The [format] parameter must be Binary.
  ///
  /// Returns the [ByteData] of the property list.
  /// Throws [PropertyListWriteStreamException] if the object graph is
  /// incompatible.
  ///
  /// Notes: XML format is not currently implemented and a UnimplementedError
  /// will be thrown.

  static ByteData dataWithPropertyList(Object obj, Format format) {
    if (format == Format.binary) {
      try {
        var p = BinaryPropertyListWriter(obj);
        return p.write();
      } catch(e) {
        throw PropertyListWriteStreamException(e);
      }
    } else {
      // Format.xml
      throw UnimplementedError();
    }
  }

  /// Creates and returns a property list from the specified ByteData.
  /// Equivalent to iOS method
  /// `[NSPropertyList propertyListWithData:options:format:error]`
  ///
  /// The [data] parameter is a ByteArray of plist.
  /// The [format] parameter must be Binary.
  ///
  /// Returns one of String, int, double, Map<String, Object>,
  /// List, DateTime, bool, ByteData.
  /// Throws [PropertyListReadStreamException] if the plist is corrupt, values
  /// could not be converted or the input stream is EOF.

  static Object propertyListWithData(ByteData data, Format format) {
    if (format == Format.binary) {
      try {
        var p = BinaryPropertyListReader(data);
        return p.parse();
      } catch(e) {
        throw PropertyListReadStreamException(e);
      }
    } else {
      // Format.xml
      throw UnimplementedError();
    }
  }
  
}