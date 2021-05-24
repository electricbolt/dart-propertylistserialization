// exceptions.dart
// PropertyListSerialization Copyright © 2021; Electric Bolt Limited.

abstract class PropertyListException implements Exception {
  final Object _nested;
  PropertyListException(Object nested) : _nested = nested;

  @override
  String toString() {
    return '$_nested';
  }
}

/// Analogous to NSPropertyListReadStreamError - an stream error was
/// encountered while reading the property list.

class PropertyListReadStreamException extends PropertyListException {
  PropertyListReadStreamException(Object nested) : super(nested);

  @override
  String toString() {
    return 'PropertyListReadStreamException: ' + super.toString();
  }

}

/// Analogous to NSPropertyListWriteStreamError - an stream error was
/// encountered while writing the property list.

class PropertyListWriteStreamException extends PropertyListException {
  PropertyListWriteStreamException(Object nested) : super(nested);

  @override
  String toString() {
    return 'PropertyListWriteStreamException: ' + super.toString();
  }

}
