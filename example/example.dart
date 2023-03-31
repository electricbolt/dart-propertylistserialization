// example.dart
// PropertyListSerialization Copyright © 2021; Electric Bolt Limited.

import 'dart:typed_data';

import 'package:convert/convert.dart';
import 'package:propertylistserialization/propertylistserialization.dart';

void main() {
  // xml - serialize

  final list1 = [];
  final dict1 = <String, Object>{};
  dict1['Selected'] = true;
  dict1['IconName'] = 'largeIcon.png';
  dict1['IconSize'] = 32;
  list1.add(dict1);

  final xml = PropertyListSerialization.stringWithPropertyList(list1);
  print('**xml**\n$xml');

  // xml - deserialize

  final list2 = PropertyListSerialization.propertyListWithString(xml) as List;
  final dict2 = list2[0] as Map<String, Object>;
  final selected2 = dict2['Selected'];
  final iconName2 = dict2['IconName'];
  final iconSize2 = dict2['IconSize'];
  print('$selected2 $iconName2 $iconSize2');

  // binary - serialize

  final bin = PropertyListSerialization.dataWithPropertyList(list2);
  print('**binary**\n${hex.encoder.convert(Uint8List.sublistView(bin))}');

  // binary - deserialize

  final list3 = PropertyListSerialization.propertyListWithData(bin) as List;
  final dict3 = list3[0] as Map<String, Object>;
  final selected3 = dict3['Selected'];
  final iconName3 = dict3['IconName'];
  final iconSize3 = dict3['IconSize'];
  print('$selected3 $iconName3 $iconSize3');
}
