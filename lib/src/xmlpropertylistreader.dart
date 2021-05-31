// xmlpropertylistwriter.dart
// PropertyListSerialization Copyright © 2021; Electric Bolt Limited.

import 'dart:convert';
import 'dart:typed_data';

import 'package:propertylistserialization/propertylistserialization.dart';
import 'package:propertylistserialization/src/dateutil.dart';
import 'package:xml/xml_events.dart';

class XMLPropertyListReader {

  final String _plist;
  late Iterator<XmlEvent> _events;
  XmlEvent? _pushbackEvent;
  late int _logIndent = 0;
  final bool _logging = false;

  XMLPropertyListReader(String plist) : _plist = plist, _pushbackEvent = null;

  Object parse() {
    _events = parseEvents(_plist).iterator;
    return _readPlist();
  }

  Object _readPlist() {
    _requireXmlDeclaration();
    _requireDoctype();
    _requireStartElement('plist');
    _logStart('<plist>');
    var event = _nextEventSkipOptionalText();
    if (!(event is XmlStartElementEvent)) {
      throw _expected(event, 'XmlStartElementEvent (array,dict,string,data,'
          'date,integer,real,true,false)');
    }
    var result = _readObject(event);
    _requireEndElement('plist');
    _logEnd('</plist>');
    return result;
  }

  Object _readObject(XmlStartElementEvent event) {
    switch(event.name) {
      case 'array':
        return _readArray(event.isSelfClosing);
      case 'dict':
        return _readDict(event.isSelfClosing);
      case 'string':
        return _readString('string', event.isSelfClosing);
      case 'data':
        return _readData(event.isSelfClosing);
      case 'date':
        return parseXML(_readString('date', event.isSelfClosing));
      case 'integer':
        return int.parse(_readString('integer', event.isSelfClosing));
      case 'real':
        return double.parse(_readString('real', event.isSelfClosing));
      case 'true':
        return _readBoolean(event.name, event.isSelfClosing);
      case 'false':
        return _readBoolean(event.name, event.isSelfClosing);
      default:
        throw _expected(event, 'XmlStartElementEvent');
    }
  }

  bool _readBoolean(String tagName, bool isSelfClosing) {
    if (!isSelfClosing) {
      _requireEndElement(tagName);
      _log('<$tagName></$tagName>');
    } else {
      _log('</$tagName>');
    }
    return tagName == 'true';
  }

  /// Ensures the next element from the xml stream is the contents of an `array`
  /// with zero or more elements, otherwise throws a
  /// [PropertyListReadStreamException]:
  ///
  /// <array>                <-- this element read before entering _readArray().
  ///   <integer>2</integer> <-- contents from this line onwards.
  ///   <string>abc</string>
  /// </array>               <-- to the end of the array.

  List _readArray(bool isSelfClosing) {
    var list = <Object>[];
    if (isSelfClosing) {
      _log('</array>');
      return list;
    }
    _logStart('<array>');
    var event = _nextEventSkipOptionalText();
    while (!(event is XmlEndElementEvent)) {
      if (!(event is XmlStartElementEvent)) {
        throw _expected(event, 'XmlStartElementEvent (array,dict,string,data,'
            'date,integer,real,true,false)');
      }
      list.add(_readObject(event));
      event = _nextEventSkipOptionalText();
    }
    _logEnd('</array>');
    return list;
  }

  /// Ensures the next element from the xml stream is the contents of a `dict`
  /// with zero or more key/value pairs, otherwise throws a
  /// [PropertyListReadStreamException]:
  ///
  /// <dict>                <-- this element read before entering _readDict().
  ///   <key>DictKey1</key> <-- contents from this line onwards.
  ///   <string>String3</string>
  /// </dict>               <-- to the end of the dict.

  Map _readDict(bool isSelfClosing) {
    var dict = <String, Object>{};
    if (isSelfClosing) {
      _log('<dict/>');
      return dict;
    }
    _logStart('<dict>');
    var event = _nextEventSkipOptionalText();
    while (!(event is XmlEndElementEvent)) {
      // Read key
      if (!(event is XmlStartElementEvent) || (event is XmlStartElementEvent &&
          event.name != 'key')) {
        throw _expected(event, 'XmlStartElementEvent (key)');
      }
      event = _nextEvent();
      if (!(event is XmlTextEvent)) {
        throw _expected(event, 'XmlTextEvent');
      }
      var key = event.text; // key: always a string
      _requireEndElement('key');
      _log('<key>$key</key>');
      // Read value
      event = _nextEvent();
      if (!(event is XmlStartElementEvent)) {
        throw _expected(event, 'XmlStartElementEvent (array,dict,string,data,'
            'date,integer,real,true,false)');
      }
      dict[key] = _readObject(event);
      event = _nextEventSkipOptionalText();
    }
    _logEnd('</dict>');
    return dict;
  }

  ByteData _readData(bool isSelfClosing) {
    if (isSelfClosing) {
      _log('<data/>');
      _skipOptionalText();
      return ByteData(0);
    }

    var sb = StringBuffer();

    var event = _nextEvent();
    if ((event is XmlEndElementEvent) && event.name == 'data') {
      // Handle empty data. e.g. <data></data>
      _log('<data></data>');
      return ByteData(0);
    }

    while (!(event is XmlEndElementEvent)) {
      if (!(event is XmlTextEvent)) {
        throw _expected(event, 'XmlTextEvent');
      }

      // Remove any whitespace from the entire string (including interior
      // characters). The result should be a single line Base64 string.
      sb.write(event.text.replaceAll(RegExp(r'\s+'), ''));
      event = _nextEvent();
    }

    var result = sb.toString();
    _log('<data>$result</data>');

    return Base64Decoder().convert(result).buffer.asByteData();
  }

  /// Ensures the next element from the xml stream is `text`. Then ensures an
  /// `end tag` with name [tagName] follows, otherwise throws a
  /// [PropertyListReadStreamException]. e.g. `abc</string>` where `abc` is
  /// the `text` and `string` is the [tagName] value.

  String _readString(String tagName, bool isSelfClosing) {
    if (isSelfClosing) {
      _log('<$tagName/>');
      _skipOptionalText();
      return '';
    } else {
      var event = _nextEvent();
      if ((event is XmlEndElementEvent) && event.name == tagName) {
        // Handle empty string. e.g. <string></string>
        _log('<$tagName></$tagName>');
        return '';
      }
      if (!(event is XmlTextEvent)) {
        throw _expected(event, 'XmlTextEvent');
      }
      var result = event.text.trim();
      _requireEndElement(tagName);
      _log('<$tagName>$result</$tagName>');
      return result;
    }
  }

  /// Returns a PropertyListReadStreamException with the message in the format:
  /// 'Expected $tagName, found $nodeType `$event`'.

  PropertyListReadStreamException _expected(XmlEvent event, String tagName) {
    var nodeType = event.nodeType;
    return PropertyListReadStreamException('Expected $tagName, found $nodeType '
        '`$event`');
  }

  /// Ensures the next element from the xml stream is a `start tag` with the
  /// name [tagName], otherwise throws a [PropertyListReadStreamException].
  /// e.g. `<string>` where `string` is the [tagName] value.

  void _requireStartElement(String tagName) {
    var event = _nextEventSkipOptionalText();
    if (!(event is XmlStartElementEvent) || event.name != tagName) {
      throw _expected(event, tagName);
    }
    _skipOptionalText();
  }

  /// Ensures the next element from the xml stream is an `end tag` with the
  /// name [tagName], otherwise throws a [PropertyListReadStreamException].
  /// e.g. </string> where `string` is the [tagName] value.

  void _requireEndElement(String tagName) {
    var event = _nextEventSkipOptionalText();
    if (!(event is XmlEndElementEvent) || event.name != tagName) {
      throw _expected(event, tagName);
    }
    _skipOptionalText();
  }

  /// Ensures the next element from the xml stream is a DOCTYPE, otherwise
  /// throws a [PropertyListReadStreamException].

  void _requireDoctype() {
    var event = _nextEvent();
    if (!(event is XmlDoctypeEvent)) {
      throw _expected(event, '<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//'
          'EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">');
    }
    _skipOptionalText();
  }

  /// Ensures the next element from the xml stream is a <?xml?>
  /// otherwise throws a [PropertyListReadStreamException].

  void _requireXmlDeclaration() {
    var event = _nextEvent();
    if (!(event is XmlDeclarationEvent)) {
      throw _expected(event, '<?xml version="1.0" encoding="UTF-8"?>');
    }
    _skipOptionalText();
  }

  /// Consumes the next element from the xml stream if it indicates whitespace.
  /// Throws a [PropertyListReadStreamException] if the end of the xml stream is
  /// encountered.

  void _skipOptionalText() {
    var event = _nextEvent();
    if (!(event is XmlTextEvent)) {
      _pushEvent(event);
    }
  }

  /// Returns the next element from the xml stream, skipping any whitespace.
  /// Throws a [PropertyListReadStreamException] if the end of the xml stream is
  /// encountered.

  XmlEvent _nextEventSkipOptionalText() {
    var event = _nextEvent();
    if (event is XmlTextEvent) {
      event = _nextEvent();
    }
    return event;
  }

  /// Consumes and returns the next element from the xml stream. Automatically
  /// skips over comments but not whitespace. Throws a
  /// [PropertyListReadStreamException] if the end of the xml stream is
  /// encountered.

  XmlEvent _nextEvent() {
    if (_pushbackEvent != null) {
      var e = _pushbackEvent!;
      _pushbackEvent = null;
      return e;
    }
    while (true) {
      if (_events.moveNext() == false) {
        throw PropertyListReadStreamException('Unexpected end of plist');
      }
      var event = _events.current;
      if (event is XmlCommentEvent) {
        continue;
      }
      return event;
    }
  }

  /// If we've consumed too many elements from the xml stream, we can push the
  /// [event] back into a push back buffer. This will be consumed as the next
  /// event inside the _nextEvent method before consuming from the xml stream.
  ///
  void _pushEvent(XmlEvent event) {
    if (_pushbackEvent != null) {
      throw PropertyListReadStreamException('Internal error');
    }
    _pushbackEvent = event;
  }

  /// When debug logging is enabled, the [text] will be output to the console
  /// with the current indentation increased.

  @pragma('vm:prefer-inline')
  void _logStart(String text) {
    if (_logging) {
      _log(text);
      _logIndent++;
    }
  }

  /// When debug logging is enabled the [text] will be output to the console
  /// with the current indentation decreased.

  @pragma('vm:prefer-inline')
  void _logEnd(String text) {
    if (_logging) {
      _logIndent--;
      _log(text);
    }
  }

  /// When debug logging is enabled the [text] will be output the the console
  /// at the current indentation level.

  @pragma('vm:prefer-inline')
  void _log(String text) {
    if (_logging) {
      print(''.padLeft(_logIndent) + text);
    }
  }

}
