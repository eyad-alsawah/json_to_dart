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
    bool runFormatterWhenDone = false,
    bool runBuildRunnerWhenDone = false}) async {
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
  String libraryImports = '';
  String partsImports = '';
  if (converterOptions != null && converterOptions.compatibleLibrary != null) {
    libraryImports =
        converterOptions.compatibleLibrary == CompatibleLibrary.freezed
            ? "import 'package:freezed_annotation/freezed_annotation.dart';"
            : "import 'package:json_annotation/json_annotation.dart';";

    partsImports =
        converterOptions.compatibleLibrary == CompatibleLibrary.freezed
            ? '''
        part '${outputFileName.replaceAll('.dart', '.freezed.dart')}';
        part '${outputFileName.replaceAll('.dart', '.g.dart')}';
          '''
            : "part '${outputFileName.replaceAll('.dart', '.g.dart')}';";
  }
  List<ClassFromJson> classesList = [];
  convertJsonObjectToClass(
    jsonString: jsonString,
    classesList: classesList,
    className: baseClassName,
  );

  classesList =
      removeDuplicateClasses(classesList: classesList).reversed.toList();

  fileToGenerate += libraryImports;
  fileToGenerate += partsImports;

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
  runBuildRunnerWhenDone ? runBuildRunner() : null;
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
  String classAnnotation = '';
  String fromJson = '';
  String toJson = '';
  String classMixin = '';
  String equatableProps = '';
  for (var field in classFromJson.classFieldsFromJson) {
    String fieldPrefix = getFieldPrefix(
        field: field, library: converterOptions.compatibleLibrary);
    fields =
        '$fields$fieldPrefix ${converterOptions.finalFields ? 'final ' : ''}${field.type}${converterOptions.nullableParams ? '?' : ''} ${field.name};\n';
    String paramPrefix = getParamPrefix(
        field: field, library: converterOptions.compatibleLibrary);

    if (converterOptions.compatibleLibrary != null) {
      fields = converterOptions.compatibleLibrary == CompatibleLibrary.freezed
          ? ''
          : fields;
      params = converterOptions.compatibleLibrary == CompatibleLibrary.freezed
          ? '$params $paramPrefix ${field.type} ${field.name},\n'
          : '$params$paramPrefix ${converterOptions.requiredParams ? 'required ' : ''}this.${field.name},\n';

      if (converterOptions.equatable) {
        equatableProps += '${field.name},';
      }
    } else {
      params =
          '$params$paramPrefix ${converterOptions.requiredParams ? 'required ' : ''}this.${field.name},\n';
    }
  }
  equatableProps = '''
  @override
  List<Object?> get props => [$equatableProps];''';
  //----------------------------

  constructor = '''
${converterOptions.constConstructor ? 'const' : ''} ${converterOptions.factoryConstructor ? 'factory' : ''} ${classFromJson.className}(${(converterOptions.requiredParams || (converterOptions.compatibleLibrary != null && converterOptions.compatibleLibrary == CompatibleLibrary.freezed)) ? '{ ' : ''}
                             $params
                          ${(converterOptions.requiredParams || (converterOptions.compatibleLibrary != null && converterOptions.compatibleLibrary == CompatibleLibrary.freezed)) ? '}' : ''}) ${converterOptions.compatibleLibrary == CompatibleLibrary.freezed ? '= _${classFromJson.className}' : ''};
''';
//----------------------------
  if (converterOptions.compatibleLibrary != null) {
    fields = converterOptions.compatibleLibrary == CompatibleLibrary.freezed
        ? ''
        : fields;
    classAnnotation =
        converterOptions.compatibleLibrary == CompatibleLibrary.jsonSerializable
            ? '@JsonSerializable()'
            : ' @freezed';

    fromJson =
        '''factory ${classFromJson.className}.fromJson(Map<String, dynamic> json) =>
      _\$${classFromJson.className}FromJson(json);''';

    toJson =
        converterOptions.compatibleLibrary == CompatibleLibrary.jsonSerializable
            ? '''
Map<String, dynamic> toJson() => _\$${classFromJson.className}ToJson(this);
'''
            : '';

    classMixin = converterOptions.compatibleLibrary == CompatibleLibrary.freezed
        ? 'with _\$${classFromJson.className}'
        : '';
  }

  String stringClass = ''' 
    $classAnnotation
    ${converterOptions.isAbstract ? 'abstract' : ''} class ${classFromJson.className} ${converterOptions.superClass.isNotEmpty ? 'extends ${converterOptions.superClass}' : ''} ${converterOptions.mixins.isNotEmpty ? converterOptions.mixins : classMixin.isNotEmpty ? classMixin : ''}{
                                          $fields
                                          $constructor
                                          
                                          $fromJson

                                          $toJson

                                          $equatableProps
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

//-----------------------
String getFieldPrefix(
    {required CompatibleLibrary? library, required ClassFieldFromJson field}) {
  String fieldPrefix = '';
  switch (library) {
    case CompatibleLibrary.jsonSerializable:
      fieldPrefix = "@JsonKey(name:'${field.jsonKey}')";
    case CompatibleLibrary.freezed:
      fieldPrefix = '';
      break;
    default:
      fieldPrefix = '';
  }
  return fieldPrefix;
}

String getParamPrefix(
    {required ClassFieldFromJson field, CompatibleLibrary? library}) {
  getDefaultValueFromType(fieldType: field.type);
  String paramPrefix = '';
  switch (library) {
    case CompatibleLibrary.jsonSerializable:
      paramPrefix = '';
    case CompatibleLibrary.freezed:
      paramPrefix =
          '@Default(${getDefaultValueFromType(fieldType: field.type)})';
      break;
    default:
      paramPrefix = '';
  }
  return paramPrefix;
}

String getDefaultValueFromType({required String fieldType}) {
  String defaultFieldValue = '';

  switch (fieldType) {
    case 'int':
      defaultFieldValue = '0';
      break;
    case 'double':
      defaultFieldValue = '0.0';
      break;
    case 'String':
      defaultFieldValue = "''";
      break;
    default:
      // todo: see if there is a better way to handle default values for objects
      defaultFieldValue = fieldType.contains('List') ? '[]' : 'null';
  }
  return defaultFieldValue;
}
