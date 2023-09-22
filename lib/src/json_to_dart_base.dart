import 'dart:io';

import 'json_to_dart/data_classes.dart';
import 'json_to_dart/helper_methods.dart';

void main() {
  convertJsonToDart(
    runFormatterWhenDone: true,
  );
}

/// ## Usage:
///
/// 1. **Add a JSON File**
///
///    Place the JSON file you want to convert into the same directory as the file where you are using this method.
///
/// 2. **Run the Conversion Script**
///
///    In your terminal or command prompt, run the following command to execute
///    the `file_where_this_method_is_called.dart` program:
///
///    ```
///    dart run replace_with_path_to_file_where_this_method_is_called.dart
///    ```
///
void convertJsonToDart(
    {ConverterOptions? converterOptions,
    bool runFormatterWhenDone = false}) async {
  // the base directory of the dart/flutter project the package is imported in
  final String baseDirectory = Directory.current.path;

  print(baseDirectory);
  print("Enter input file name: ");
  final String inputFileName = stdin.readLineSync() ?? 'input.json';

  print("Enter output file name: ");
  final String outputFileName = stdin.readLineSync() ?? 'output.dart';

  print("Enter base class name: ");
  final String baseClassName = stdin.readLineSync() ?? 'BaseClass';

  final Stopwatch stopwatch = Stopwatch()..start();
  if (!baseClassName.startsWith(RegExp(r'[A-Z]'))) {
    throw "base class name isn't an UpperCamelCase identifier.";
  }

  final File jsonFile = File('$baseDirectory/$inputFileName');
  final File outputFile = File(outputFileName);

  if (!jsonFile.existsSync()) {
    ColoredPrinter.printColored(
        'JSON file not found at the specified path.', AnsiColor.red);
    return;
  }

  final jsonString = await jsonFile.readAsString();

  String fileToGenerate = '';

  List<ClassFromJson> classesList = [];
  convertJsonObjectToClass(
    jsonString: jsonString,
    classesList: classesList,
    className: baseClassName,
  );

  classesList =
      removeDuplicateClasses(classesList: classesList).reversed.toList();

  for (var item in classesList) {
    fileToGenerate += stringClassToDart(
      classFromJson: item,
      converterOptions: converterOptions ??
          ConverterOptions(
              constConstructor: true, finalFields: true, requiredParams: true),
    );
  }
  outputFile.writeAsString('');
  outputFile
      .writeAsString(fileToGenerate)
      .whenComplete(() => outputFile.rename(outputFileName));

  ColoredPrinter.printColored(
      'Generating dart classes from json completed, took ${stopwatch.elapsed.inMilliseconds}ms',
      AnsiColor.green);
  runFormatterWhenDone ? formatDartFile(outputFileName) : null;
}

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
  constructor =
      '''
${converterOptions.constConstructor ? 'const' : ''} ${converterOptions.factoryConstructor ? 'factory' : ''} ${classFromJson.className}(${converterOptions.requiredParams ? '{ ' : ''}
                             $params
                          ${converterOptions.requiredParams ? '}' : ''});
''';
//----------------------------
  String stringClass =
      ''' 
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
