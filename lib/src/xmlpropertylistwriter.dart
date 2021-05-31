// xmlpropertylistwriter.dart
// PropertyListSerialization Copyright © 2021; Electric Bolt Limited.

import 'dart:collection';
import 'dart:convert';
import 'dart:typed_data';
import 'dateutil.dart';
import 'package:propertylistserialization/propertylistserialization.dart';

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

class XMLPropertyListWriter {

  final Object _rootObj;
  final StringBuffer _os;

  XMLPropertyListWriter(Object rootObj)
      : _rootObj = rootObj, _os = StringBuffer();

  String write() {
    _write('<?xml version="1.0" encoding="UTF-8"?>\n<!DOCTYPE plist PUBLIC "-//'
        'Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.'
        'dtd">\n<plist version="1.0">\n', 0);
    _writeObject(_rootObj, 0);
    _write('</plist>\n', 0);
    return _os.toString();
  }

  void _writeObject(Object obj, int indent) {
    if (obj is Map) {
      if (obj.isEmpty) {
        _write('<dict/>\n', indent);
      } else {
        _write('<dict>\n', indent);
        // CFPropertyList.c sorts by key before outputting dictionaries
        var sorted = SplayTreeMap.from(obj);
        for (var key in sorted.keys) {
          _write('<key>' + _escape(key) + '</key>\n', indent + 1);
          var value = sorted[key];
          _writeObject(value, indent + 1);
        }
        _write('</dict>\n', indent);
      }
    } else if (obj is List) {
      if (obj.isEmpty) {
        _write('<array/>\n', indent);
      } else {
        _write('<array>\n', indent);
        for (var i = 0; i < obj.length; i++) {
          var value = obj[i];
          _writeObject(value, indent + 1);
        }
        _write('</array>\n', indent);
      }
    } else if (obj is String) {
      obj = _escape(obj);
      _write('<string>$obj</string>\n', indent);
    } else if (obj is Float32) {
      var s = obj.value.toString();
      // Remove .0 at end of string to match output of CFPropertylist.c
      if (s.endsWith('.0')) {
        s = s.substring(0, s.length - 2);
      }
      _write('<real>$s</real>\n', indent);
    } else if (obj is double) {
      var s = obj.toString();
      // Remove .0 at end of string to match output of CFPropertylist.c
      if (s.endsWith('.0')) {
        s = s.substring(0, s.length - 2);
      }
      _write('<real>$s</real>\n', indent);
    } else if (obj is int) {
      _write('<integer>$obj</integer>\n', indent);
    } else if (obj is ByteData) {
      _writeData(obj, indent);
    } else if (obj is DateTime) {
      _write('<date>' + formatXML(obj) + '</date>\n', indent);
    } else if (obj is bool) {
      if (obj == true) {
        _write('<true/>\n', indent);
      } else {
        _write('<false/>\n', indent);
      }
    } else {
      throw StateError('Incompatible object $obj found');
    }
  }

  void _write(String s, int indent) {
    _os.write(_tab(indent > 8 ? 8 : indent));
    _os.write(s);
  }

  void _writeData(ByteData value, int indent) {
    if (indent > 8) {
      indent = 8;
    }
    var lineLength = 76 - (indent * 8); // assume tab is 8 characters.
    var tabBuf = _tab(indent);
    var list = Uint8List.sublistView(value);
    var encodedBuf = Base64Encoder().convert(list);

    _os.write(tabBuf);
    _os.write('<data>\n');

    var offset = 0;
    var chunks = (encodedBuf.length ~/ lineLength);
    for (var chunk = 0; chunk < chunks; chunk++) {
      _os.write(tabBuf);
      _os.write(safeSubstring(encodedBuf, offset, lineLength));
      _os.write('\n');
      offset += lineLength;
    }
    if (offset < encodedBuf.length) {
      _os.write(tabBuf);
      _os.write(encodedBuf.substring(offset));
      _os.write('\n');
    }

    _os.write(tabBuf);
    _os.write('</data>\n');
  }

  String _tab(int indent) {
    return ''.padLeft(indent, '\t');
  }

  String _escape(String s) {
    var sb = StringBuffer();
    for (var i = 0; i < s.length; i++) {
      var c = s[i];
      switch (c) {
        case '<':
          sb.write('&lt;');
          break;
        case '>':
          sb.write('&gt;');
          break;
        case '&':
          sb.write('&amp;');
          break;
        default:
          sb.write(c);
      }
    }
    return sb.toString();
  }
}

String safeSubstring(String value, int offset, int length) {
  if (offset >= value.length) {
    return '';
  } else if (offset + length >= value.length) {
    return value.substring(offset);
  } else {
    return value.substring(offset, offset + length);
  }
}