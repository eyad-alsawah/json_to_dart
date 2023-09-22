import 'dart:io';

import 'classes_to_json.dart';
import 'helper_methods.dart';
import 'json_to_class.dart';

String stringClassToDart({
  required ClassFromJson classFromJson,
  required ConverterOptions converterOptions,
}) {
  if (converterOptions.constConstructor && !converterOptions.finalFields) {
    throw "Can't define a const constructor for a class with non-final fields.";
  }
  String fields = '';
  String constructor = '';
  String params = '';

  for (var field in classFromJson.classFieldsFromJson) {
    fields =
        '$fields${converterOptions.finalFields ? 'final ' : ''}${field.type}${converterOptions.nullableParams ? '?' : ''} ${field.name};\n';
    params =
        '$params${converterOptions.requiredParams ? 'required ' : ''}this.${field.name},\n';
  }
  //----------------------------
  constructor = '''
${converterOptions.constConstructor ? 'const' : ''} ${converterOptions.factoryConstructor ? 'factory' : ''} ${classFromJson.className}(${converterOptions.requiredParams ? '{ ' : ''}
                             $params
                          ${converterOptions.requiredParams ? '}' : ''});
''';
//----------------------------
  String stringClass = ''' 
    ${converterOptions.isAbstract ? 'abstract' : ''} class ${classFromJson.className} ${converterOptions.superClass.isNotEmpty ? 'extends ${converterOptions.superClass}' : ''} ${converterOptions.mixins.isNotEmpty ? converterOptions.mixins : ''}{
                                          $fields
                                          $constructor
                                     }
''';

  return stringClass;
}

List<ClassFromJson> removeDuplicateClasses({
  required List<ClassFromJson> classesList,
}) {
  Map<String, ClassFromJson> nonDuplicatedClassesMap = {};
  List<ClassFromJson> nonDuplicatedClassesList = [];

  classesList.asMap().forEach(
    (index, value) {
      nonDuplicatedClassesMap.putIfAbsent(value.className, () => value);
    },
  );

  nonDuplicatedClassesMap.forEach((key, value) {
    nonDuplicatedClassesList.add(value);
  });
  return nonDuplicatedClassesList;
}

class ConverterOptions {
  final bool requiredParams;
  final bool nullableParams;
  final bool isAbstract;
  final bool finalFields;
  final bool factoryConstructor;
  final bool constConstructor;
  final String mixins;
  final String superClass;

  ConverterOptions({
    this.requiredParams = false,
    this.nullableParams = false,
    this.isAbstract = false,
    this.finalFields = false,
    this.factoryConstructor = false,
    this.constConstructor = false,
    this.mixins = '',
    this.superClass = '',
  }) : assert(constConstructor && !finalFields,
            "Can't define a const constructor for a class with non-final fields.");
}
