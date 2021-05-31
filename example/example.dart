// example.dart
// PropertyListSerialization Copyright © 2021; Electric Bolt Limited.

import 'dart:typed_data';

import 'package:propertylistserialization/propertylistserialization.dart';
import 'package:convert/convert.dart';

void main() {
  // xml - serialize

  var list1 = [];
  var dict1 = <String, Object>{};
  dict1['Selected'] = true;
  dict1['IconName'] = 'largeIcon.png';
  dict1['IconSize'] = 32;
  list1.add(dict1);

  var xml = PropertyListSerialization.stringWithPropertyList(list1);
  print('**xml**\n$xml');

  // xml - deserialize

  var list2 = PropertyListSerialization.propertyListWithString(xml) as List;
  var dict2 = list2[0];
  var selected2 = dict2['Selected'];
  var iconName2 = dict2['IconName'];
  var iconSize2 = dict2['IconSize'];
  print('$selected2 $iconName2 $iconSize2');

  // binary - serialize

  var bin = PropertyListSerialization.dataWithPropertyList(list2);
  print('**binary**\n${hex.encoder.convert(Uint8List.sublistView(bin))}');

  // binary - deserialize

  var list3 = PropertyListSerialization.propertyListWithData(bin) as List;
  var dict3 = list3[0];
  var selected3 = dict3['Selected'];
  var iconName3 = dict3['IconName'];
  var iconSize3 = dict3['IconSize'];
  print('$selected3 $iconName3 $iconSize3');
}