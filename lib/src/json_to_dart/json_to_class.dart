import 'dart:convert';
import 'dart:io';

import 'package:json_to_dart/src/json_to_dart/string_extensions.dart';

import 'classes_to_json.dart';

void main() async {
  final jsonFile = File('input_json.json');
  final jsonString = await jsonFile.readAsString();

  List<ClassFromJson> classesList = [];
  convertJsonObjectToClass(
    jsonString: jsonString,
    classesList: classesList,
    className: 'BaseClass',
  );
  for (var clas in classesList) {
    print("class: ${clas.className}");
    for (var field in clas.classFieldsFromJson) {
      print("   ${field.type} ${field.name}");
    }
    print("-------------------------");
  }
}

void convertJsonObjectToClass({
  required String jsonString,
  required List<ClassFromJson> classesList,
  required String className,
}) {
  if (jsonString.isEmpty) {
    throw 'jsonString cannot be empty';
  }

  if (json.decode(jsonString).runtimeType.toString() == 'List<dynamic>') {
    throw 'converter does not support json arrays that are not inside objects';
  }

  Map<String, dynamic> jsonMap = json.decode(jsonString);

  // todo handle class Fields being empty
  List<ClassFieldFromJson> classFields = [];

  jsonMap.forEach((key, value) {
    String valueType = value.runtimeType.toString();
    ClassFieldFromJson? fieldFromJson;
    switch (valueType) {
      case 'List<dynamic>':
        // here get the first element type --> List<int>
        String listItemType =
            getListItemType(list: value, key: key, classesList: classesList);
        fieldFromJson =
            ClassFieldFromJson(type: listItemType, name: key.toCamelCase());
        break;
      case '_Map<String, dynamic>':
        String innerJsonObject = json.encode(value);
        fieldFromJson = ClassFieldFromJson(
            type: key.toPascalCase(), name: key.toCamelCase());
        convertJsonObjectToClass(
          jsonString: innerJsonObject,
          classesList: classesList,
          className: key.toPascalCase(),
        );
        break;

      default:
        fieldFromJson =
            ClassFieldFromJson(type: valueType, name: key.toCamelCase());
    }
    classFields.add(fieldFromJson);
  });
  classesList.add(
      ClassFromJson(className: className, classFieldsFromJson: classFields));
}

String getListItemType(
    {required List<dynamic> list,
    required String key,
    required List<ClassFromJson> classesList}) {
  if (list.isEmpty) {
    throw 'getListItemType cannot be called on an empty list...';
  }
  String listItemType = list.first.runtimeType.toString();
  if (listItemType == '_Map<String, dynamic>') {
    String innerJsonObject = json.encode(list.first);
    convertJsonObjectToClass(
      jsonString: innerJsonObject,
      classesList: classesList,
      className: "${key.toPascalCase()}Item",
    );
    return 'List<${key.toPascalCase()}Item>';
  } else if (listItemType == 'List<dynamic>') {
    throw 'Nested lists are not supported';
  } else if (listItemType == 'Null') {
    // todo consider throwing an error on lists of type List<null>
    return 'List<dynamic>';
  } else {
    return 'List<${listItemType.toPascalCase()}>';
  }
}
