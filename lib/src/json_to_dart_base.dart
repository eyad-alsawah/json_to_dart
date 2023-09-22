import 'dart:io';

import 'json_to_dart/data_classes.dart';
import 'json_to_dart/helper_methods.dart';

void main() {
  convertJsonToDart(
    baseClassName: 'EyadModel',
    inputFileName: 'input_json.json',
    outputFileName: 'output.dart',
    runFormatterWhenDone: true,
  );
}

void convertJsonToDart(
    {required String inputFileName,
    required String outputFileName,
    required String baseClassName,
    ConverterOptions? converterOptions,
    bool runFormatterWhenDone = false}) async {
  final Stopwatch stopwatch = Stopwatch()..start();

  // the base directory of the dart/flutter project the package is imported in
  final String baseDirectory = Directory.current.path;

  print("Enter input file name: ");
  final String inputFileName = stdin.readLineSync() ?? 'input.json';

  print("Enter output file name: ");
  final String outputFileName = stdin.readLineSync() ?? 'output.dart';

  print("Enter base class name: ");
  final String baseClassName = stdin.readLineSync() ?? 'BaseClass';

  final File jsonFile = File('$baseDirectory/$inputFileName');
  final File outputFile = File('$baseDirectory$outputFileName');

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
  outputFile.writeAsString(fileToGenerate);
  ColoredPrinter.printColored(
      'Generating dart classes from json completed, took ${stopwatch.elapsed.inMilliseconds}ms',
      AnsiColor.green);
  runFormatterWhenDone ? formatDartFile('output.dart') : null;
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
