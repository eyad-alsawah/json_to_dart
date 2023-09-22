import 'dart:io';

import 'package:json_to_dart/src/json_to_dart/helper_methods.dart';
import 'json_to_dart/classes_to_json.dart';
import 'json_to_dart/json_to_class.dart';
import 'json_to_dart/json_to_dart.dart';

void convertJsonToDart({ConverterOptions? converterOptions}) async {
  print('Enter the path to your JSON file: ');
  final String jsonFilePath = stdin.readLineSync() ?? '';

  print('Enter the path for the output Dart file: ');
  final String outputPath = stdin.readLineSync() ?? '';

  final File jsonFile = File(jsonFilePath);
  final File outputFile = File(outputPath);

  if (!jsonFile.existsSync()) {
    print('JSON file not found at the specified path.');
    return;
  }

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
