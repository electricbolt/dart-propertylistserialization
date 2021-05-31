// propertylistserialization.dart
// PropertyListSerialization Copyright © 2021; Electric Bolt Limited.

import 'dart:typed_data';

import 'package:propertylistserialization/src/xmlpropertylistreader.dart';
import 'package:propertylistserialization/src/xmlpropertylistwriter.dart';

import 'src/binarypropertylistreader.dart';
import 'src/binarypropertylistwriter.dart';

abstract class PropertyListException implements Exception {
  final Object? _nested;
  final String? _message;

  PropertyListException(String message) : _nested = null, _message = message;
  PropertyListException.nested(Object nested) : _nested = nested, _message =
    null;

  @override
  String toString() {
    if (_nested != null) {
      return '$_nested';
    } else {
      return '$_message';
    }
  }
}

/// Analogous to NSPropertyListReadStreamError - an stream error was
/// encountered while reading the property list.

class PropertyListReadStreamException extends PropertyListException {

  PropertyListReadStreamException(String message) : super(message);
  PropertyListReadStreamException.nested(Object nested) : super.nested(nested);

  @override
  String toString() {
    return 'PropertyListReadStreamException: ' + super.toString();
  }

}

/// Analogous to NSPropertyListWriteStreamError - an stream error was
/// encountered while writing the property list.

class PropertyListWriteStreamException extends PropertyListException {
  PropertyListWriteStreamException(String message) : super(message);
  PropertyListWriteStreamException.nested(Object nested) : super.nested(nested);

  @override
  String toString() {
    return 'PropertyListWriteStreamException: ' + super.toString();
  }

}

/// Wrapper to force writing a double value as a 32-bit floating point number.

class Float32 {
  final double value;

  Float32(this.value);

  @override
  bool operator ==(Object other) {
    if (!(other is Float32)) {
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

class PropertyListSerialization {

  /// For the object graph provided, returns a property list as binary ByteData.
  /// Equivalent to iOS method
  /// `[NSPropertyList dataWithPropertyList:format:options:error]`
  ///
  /// The [obj] parameter is the object graph to write out as a binary property
  /// list. The object graph may only contain the following types: String, int,
  /// Float32, double, Map<String, Object>, List, DateTime, bool or ByteData.
  ///
  /// Returns a [ByteData] of the binary plist.
  ///
  /// Throws [PropertyListWriteStreamException] if the object graph is
  /// incompatible.

  static ByteData dataWithPropertyList(Object obj) {
    try {
      var p = BinaryPropertyListWriter(obj);
      return p.write();
    } catch(e, s) {
      print(s);
      throw PropertyListWriteStreamException.nested(e);
    }
  }

  /// For the object graph provided, returns a property list as an xml String.
  /// Equivalent to iOS method
  /// `[NSPropertyList dataWithPropertyList:format:options:error]`
  ///
  /// The [obj] parameter is object graph to write out as a xml property list.
  /// The object graph may only contain the following types: String, int,
  /// Float32, double, Map<String, Object>, List, DateTime, bool or ByteData.
  ///
  /// Returns a [String] of the xml plist.
  ///
  /// Throws [PropertyListWriteStreamException] if the object graph is
  /// incompatible.

  static String stringWithPropertyList(Object obj) {
    try {
      var p = XMLPropertyListWriter(obj);
      return p.write();
    } catch(e, s) {
      print(s);
      throw PropertyListWriteStreamException.nested(e);
    }
  }

  /// Creates and returns a object graph from the specified property list
  /// binary ByteData. Equivalent to iOS method
  /// `[NSPropertyList propertyListWithData:options:format:error]`
  ///
  /// The [data] parameter must be a ByteData of binary plist.
  ///
  /// Returns one of String, int, double, Map<String, Object>,
  /// List, DateTime, bool or ByteData.
  ///
  /// Throws [PropertyListReadStreamException] if the plist is corrupt, values
  /// could not be converted or the input stream is EOF.

  static Object propertyListWithData(ByteData data) {
    try {
      var p = BinaryPropertyListReader(data);
      return p.parse();
    } catch(e, s) {
      if (e is PropertyListReadStreamException) {
        rethrow;
      } else {
        print(s);
        throw PropertyListReadStreamException.nested(e);
      }
    }
  }

  /// Creates and returns a property list from the specified xml String.
  /// Equivalent to iOS method
  /// `[NSPropertyList propertyListWithData:options:format:error]`
  ///
  /// The [string] parameter must be a String of xml plist.
  ///
  /// Returns one of String, int, double, Map<String, Object>,
  /// List, DateTime, bool or ByteData.
  ///
  /// Throws [PropertyListReadStreamException] if the plist is corrupt, values
  /// could not be converted or the input stream is EOF.

  static Object propertyListWithString(String string) {
    try {
      var p = XMLPropertyListReader(string);
      return p.parse();
    } catch(e, s) {
      print(s);
      throw PropertyListReadStreamException.nested(e);
    }
  }

}