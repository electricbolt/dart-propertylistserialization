## iOS compatible plist serialization and deserialization library for Dart

This library is open source (BSD-2). Development occurs on [GitHub](https://github.com/electricbolt/dart-propertylistserialization).
Package is hosted on dart [packages](https://pub.dev/packages/propertylistserialization).

Looking for an Android (Java) [implementation](https://github.com/electricbolt/propertylistserialization)?.

### Features

#### XML plist (xml1)

* Character by character accurate output*1 from method `PropertyListSerialization.dataFromPropertyList()` with iOS method `[NSPropertyListSerialization dataFromPropertyList:format:options:error:]`
* `dict` dictionaries are sorted by key (as per CFPropertyList.c)
* key (dictionary) and string values are escaped for `<` `>` and `&` characters to `\&lt;` `\&gt;` and `\&amp;` (as per CFPropertyList.c)

***1** character by character accuracy excludes `<real>` numbers - the floating point representation output with Dart will have on average 6 decimal places, compared to 12 decimal places for iOS).

#### Binary plist (binary1)

* Supports version `bplist00` constructs only (all data type conversions as per XML - if you can serialize/deserialize an object tree into XML, then you can serialize/deserialize the same object tree into Binary).
* Byte by byte accurate output ***2** from method `PropertyListSerialization.dataFromPropertyList()` with iOS method `
  [NSPropertyListSerialization dataFromPropertyList:format:options:error:]`

***2** byte by byte accuracy excludes `<dict>` dictionaries with more than one `key/value` pair - unlike XML plists, they are not sorted by `key`, and therefore the ordering of the `key/value` pairs will differ. `<data>` elements are deduplicated more aggressively than Apple's implementation generally resulting in smaller output size, but still remaining compatible.

### Distribution

* Minimum Dart version 2.12 (null safety)
* Friendly BSD-2 license

### Installation

Import the library into your Dart code using:

```dart
import 'package:propertylistserialization/propertylistserialization.dart';
```

### XML example (xml1 format)

#### Writing/Serialization

```dart
var list = [];
var dict = <String, Object>{};
dict['Selected'] = true;
dict['IconName'] = 'largeIcon.png';
dict['IconSize'] = 32;
list.add(dict);

try {
  var result = PropertyListSerialization.stringWithPropertyList(list); // result == String
} on PropertyListWriteStreamException catch (e) {
  // handle error.
}
```

#### Result

```
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<array>
  <dict>
    <key>IconName</key>
    <string>largeIcon.png</string>
    <key>IconSize</key>
    <integer>32</integer>
    <key>Selected</key>
    <true/>
  </dict>
</array>
</plist>
```

#### Reading/Deserialization

```dart
try {
  var list = PropertyListSerialization.propertyListWithString(result) as List;
  
  var dict = list[0];
  var selected = dict['Selected']; // true
  var iconName = dict['IconName']; // largeIcon.png
  var iconSize = dict['IconSize']; // 32
} on PropertyListReadStreamException catch (e) {
  // handle error.
}
```

### Binary example (binary1 format)

#### Writing/Serialization

```dart
var list = [];
var dict = <String, Object>{};
dict['Selected'] = true;
dict['IconName'] = 'largeIcon.png';
dict['IconSize'] = 32;
list.add(dict);

try {
  var result = PropertyListSerialization.dataWithPropertyList(list); // result == ByteData
} on PropertyListWriteStreamException catch (e) {
  // handle error.
}
```

#### Result

```
62 70 6c 69 73 74 30 30 a1 01 d3 02 03 04 05 06
07 58 49 63 6f 6e 4e 61 6d 65 58 49 63 6f 6e 53
69 7a 65 58 53 65 6c 65 63 74 65 64 5d 6c 61 72
67 65 49 63 6f 6e 2e 70 6e 67 10 20 09 08 0a 11
1a 23 2c 3a 3c 00 00 00 00 00 00 01 01 00 00 00
00 00 00 00 08 00 00 00 00 00 00 00 00 00 00 00
00 00 00 00 3d
```

#### Reading/Deserialization

```dart
try {
  var list = PropertyListSerialization.propertyListWithData(result) as List;
  var dict = list[0];
  var selected = dict['Selected'];
  var iconName = dict['IconName'];
  var iconSize = dict['IconSize'];
} on PropertyListReadStreamException catch (e) {
  // handle error.
}
```

### Data type conversions

#### Serialization (Dart -> plist)

Input Dart type | Equivalent Obj-C type | Output plist type
---|---|---
String | NSString | &lt;string&gt;
int | NSNumber (integerValue) | &lt;integer&gt;
Float32 | NSNumber (floatValue) | &lt;real&gt; ***3**
double | NSNumber (doubleValue) | &lt;real&gt;
Map&lt;String, Object&gt; | NSDictionary| &lt;dict&gt;
List | NSArray | &lt;array&gt;
DateTime | NSDate | &lt;date&gt;
true | NSNumber (boolValue) YES | &lt;true&gt;
false | NSNumber (boolValue) NO | &lt;false&gt;
ByteData | NSData | &lt;data&gt;

***3** Serialization only, deserialization will always output double.

#### Deserialization (plist -> Dart)

Input plist type | Equivalent Obj-C type | Output Dart type
---|---|---
&lt;string&gt; | NSString | String
&lt;integer&gt; | NSNumber (longValue) | int
&lt;real&gt; | NSNumber (doubleValue) | double
&lt;dict&gt; | NSDictionary | Map&lt;String, Object&gt;
&lt;array&gt; | NSArray | List
&lt;date&gt; | NSDate | DateTime
&lt;true&gt; | NSNumber (boolValue) YES | true
&lt;false&gt; | NSNumber (boolValue) NO | false
&lt;data&gt; | NSData | ByteData

## Class PropertyListSerialization

#### String stringWithPropertyList(Object)

```dart
static String stringWithPropertyList(Object obj);
```

For the object graph provided, returns a property list as a xml String. Equivalent to iOS method `[NSPropertyList dataWithPropertyList:format:options:error]`

**params** *obj* - The object graph to write out as a xml property list. The object graph may only contain the following types: String, int, Float32, double, Map&lt;String, Object&gt;, List, DateTime, bool or ByteData.
  
**returns** *String* of the xml plist.

**throws** *PropertyListWriteStreamException* if the object graph is incompatible.

---

#### Object propertyListWithString(String)

```dart
static Object propertyListWithString(String string);
```

Creates and returns an object graph from the specified property list xml String. Equivalent to iOS method `[NSPropertyList propertyListWithData:options:format:error]`

**params** *string* - String of xml plist.

**returns** Returns one of String, int, double, Map&lt;String, Object&gt;, List, DateTime, bool or ByteData.

**throws** *PropertyListReadStreamException* if the plist is corrupt, values could not be converted or the input stream is EOF.

---

#### ByteData dataWithPropertyList(Object)

```dart
static ByteData dataWithPropertyList(Object obj);
```

For the object graph provided, returns a property list as a binary ByteData. Equivalent to iOS method `[NSPropertyList dataWithPropertyList:format:options:error]`

**params** *obj* - The object graph to write out as a binary property list. The object graph may only contain the following types: String, int, Float32, double, Map&lt;String, Object&gt;, List, DateTime, bool or ByteData.

**returns** *ByteData* of the binary plist.

**throws** *PropertyListWriteStreamException* if the object graph is incompatible.

---

#### Object propertyListWithData(ByteData)

```dart
static Object propertyListWithData(ByteData data);
```

Creates and returns an object graph from the specified property list binary ByteData. Equivalent to iOS method `[NSPropertyList propertyListWithData:options:format:error]`

**params** *data* - ByteData of binary plist.

**returns** Returns one of String, int, double, Map&lt;String, Object&gt;, List, DateTime, bool or ByteData.

**throws** *PropertyListReadStreamException* if the plist is corrupt, values could not be converted or the input stream is EOF.
