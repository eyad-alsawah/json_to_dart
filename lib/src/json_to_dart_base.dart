// TODO: Put public facing types in this file.

import 'dart:io';

import 'package:json_to_dart/src/json_to_dart/helper_methods.dart';

import 'json_to_dart/classes_to_json.dart';
import 'json_to_dart/json_to_class.dart';
import 'json_to_dart/json_to_dart.dart';

void convertJsonToDart(
    {required String jsonFilePath,
    required String outputPath,
    ConverterOptions? converterOptions}) async {
  final File jsonFile = File('input_json.json');
  final File outputFile = File('output.dart');
  final jsonString = await jsonFile.readAsString();

  String fileToGenerate = '';

  List<ClassFromJson> classesList = [];
  convertJsonObjectToClass(
    jsonString: jsonString,
    classesList: classesList,
    className: 'BaseClass',
  );

  classesList = removeDuplicateClasses(classesList: classesList);

  for (var item in classesList) {
    fileToGenerate += stringClassToDart(
      classFromJson: item,
      converterOptions: converterOptions ??
          ConverterOptions(
              constConstructor: true, finalFields: true, requiredParams: true),
    );
  }
  outputFile.writeAsString('');
  outputFile.writeAsString(fileToGenerate);
  formatDartFile('output.dart');
}