# iOS compatible plist serialization and deserialization library for Dart

This library is open source (BSD) and well tested. Development occurs on [GitHub](https://github.com/electricbolt/dart-propertylistserialization).
Package is hosted on dart [packages](https://pub.dev/packages/propertylistserialization).

## Features

### Binary plist

* Supports version `bplist00` constructs only.
* Byte by byte accurate output ***1** from method `PropertyListSerialization.dataFromPropertyList()` with iOS method `
  [NSPropertyListSerialization dataFromPropertyList:format:options:error:]`

***1** byte by byte accuracy excludes `<dict>` dictionaries with more than one `key/value` pair - unlike XML plists, 
they are not sorted by `key`, and therefore the ordering of the `key/value` pairs will differ.

### XML plist

XML format is not currently implemented and a UnimplementedError will be thrown.

## Distribution

* Minimum Dart version 2.12 (null safety)

## Data type conversions

#### Serialization (Dart -> plist)

Input Dart type | Equivalent ObjC type | Output plist type
----------------|----------------------|------------------
String | NSString | &lt;string&gt;
int | NSNumber (integerValue) | &lt;integer&gt;
Float32 | NSNumber (floatValue) | &lt;real&gt; ***2**
double | NSNumber (doubleValue) | &lt;real&gt;
Map<String, Object> | NSDictionary| &lt;dict&gt;
List | NSArray | &lt;array&gt;
DateTime | NSDate | &lt;date&gt;
true | NSNumber (boolValue) YES | &lt;true&gt;
false | NSNumber (boolValue) NO | &lt;false&gt;
ByteData | NSData | &lt;data&gt;

***2** Serialization only, deserialization will always output double.

#### Deserialization (plist -> Dart)

Input plist type | Equivalent ObjC type | Output Dart type
-----------------|----------------------|-----------------
&lt;string&gt; | NSString | String
&lt;integer&gt; | NSNumber (longValue) | int
&lt;real&gt; | NSNumber (doubleValue) | double
&lt;dict&gt; | NSDictionary | Map<String, Object>
&lt;array&gt; | NSArray | List
&lt;date&gt; | NSDate | DateTime
&lt;true&gt; | NSNumber (boolValue) YES | true
&lt;false&gt; | NSNumber (boolValue) NO | false
&lt;data&gt; | NSData | ByteData

## Class PropertyListSerialization

#### ByteData dataWithPropertyList(Object, Format)

```java
static ByteData dataWithPropertyList(Object obj, Format format);
```

For the object graph provided, returns a property list as ByteData.

Equivalent to iOS method `[NSPropertyList dataWithPropertyList:format:options:error]`

Notes: XML format is not currently implemented and an UnimplementedError will be thrown.

For the object graph provided, returns a property list as byte\[\] (encoded using utf8 for Format.XML)

Equivalent to iOS method `[NSPropertyList dataWithPropertyList:format:options:error]`

**params** *obj* - The object graph to write out as a property list. The object graph may only contain the following types: String, int, Float32, double, Map<String, Object>, List, DateTime, bool or ByteData.

**params** *format* - Must be Format.Binary

**returns** *ByteData* of the property list.

**throws** *PropertyListWriteStreamException* if the object graph is incompatible.

---

#### Object propertyListWithData(ByteData, Format)

```java
static Object propertyListWithData(ByteData data, Format format);
```

Creates and returns a property list from the specified ByteData. 

Equivalent to iOS method `[NSPropertyList propertyListWithData:options:format:error]`

Notes: XML format is not currently implemented and an UnimplementedError will be thrown.

**params** *data* - ByteData of binary plist.

**params** *format* - Must be Format.Binary

**returns** Returns one of String, int, double, Map<String, Object>, List, DateTime, bool, ByteData.

**throws** *PropertyListReadStreamException* if the plist is corrupt, values could not be converted or the input stream is EOF.
