import 'dart:convert';
import 'dart:io';

import 'package:json_to_dart/src/json_to_dart/string_extensions.dart';

import 'data_classes.dart';

import 'package:path/path.dart' as path;

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
        fieldFromJson = ClassFieldFromJson(
            type: listItemType, name: key.toCamelCase(), jsonKey: key);
        break;
      case '_Map<String, dynamic>':
        String innerJsonObject = json.encode(value);
        fieldFromJson = ClassFieldFromJson(
            type: key.toPascalCase(), name: key.toCamelCase(), jsonKey: key);
        convertJsonObjectToClass(
          jsonString: innerJsonObject,
          classesList: classesList,
          className: key.toPascalCase(),
        );
        break;

      default:
        fieldFromJson = ClassFieldFromJson(
            type: valueType, name: key.toCamelCase(), jsonKey: key);
    }
    classFields.add(fieldFromJson);
  });
  classesList.add(
      ClassFromJson(className: className, classFieldsFromJson: classFields));
}

void formatDartFile(String filePath) {
  Process.run('dart', ['format', filePath]).then((result) {
    if (result.exitCode == 0) {
      ColoredPrinter.printColored(
          'Formatted the Dart code successfully.', AnsiColor.blue);
    } else {
      ColoredPrinter.printColored(
          'Failed to format the Dart code. Error: ${result.stderr}',
          AnsiColor.red);
    }
  });
}

void runBuildRunner() {
  final String? rootDirectory = getRootProjectDirectory();
  print(rootDirectory);

  if (rootDirectory != null) {
    final stopwatch = Stopwatch()..start();

    Process.run('dart', ['run', 'build_runner', 'build'],
            workingDirectory: rootDirectory)
        .then((ProcessResult result) {
      print(result.stdout); // Print the standard output from the process.
      print(result.stderr); // Print the standard error from the process.

      stopwatch.stop();
      if (result.exitCode == 0) {
        ColoredPrinter.printColored(
            'build_runner build completed successfully, took ${stopwatch.elapsed.inMilliseconds}ms',
            AnsiColor.green);
      } else {
        ColoredPrinter.printColored(
            'build_runner build failed. Error: ${stopwatch.elapsed}',
            AnsiColor.red);
      }
    });
  } else {
    ColoredPrinter.printColored(
        'Unable to find the root project directory.', AnsiColor.red);
  }
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
  } else if (listItemType == 'int') {
    return 'List<int>';
  } else {
    return 'List<${listItemType.toPascalCase()}>';
  }
}

//--------------------
enum AnsiColor {
  black,
  red,
  green,
  yellow,
  blue,
  magenta,
  cyan,
  white,
  reset,
}

class ColoredPrinter {
  static const Map<AnsiColor, String> _colorCodes = {
    AnsiColor.black: '\x1B[30m',
    AnsiColor.red: '\x1B[31m',
    AnsiColor.green: '\x1B[32m',
    AnsiColor.yellow: '\x1B[33m',
    AnsiColor.blue: '\x1B[34m',
    AnsiColor.magenta: '\x1B[35m',
    AnsiColor.cyan: '\x1B[36m',
    AnsiColor.white: '\x1B[37m',
    AnsiColor.reset: '\x1B[0m',
  };

  static void printLine(
      [String pre = '', String suf = '╝', AnsiColor color = AnsiColor.blue]) {
    ColoredPrinter.printColored('$pre${'═' * 100}$suf', color);
  }

  static void printColored(String text, AnsiColor color) {
    final ansiCode = _colorCodes[color];
    if (ansiCode != null) {
      print('$ansiCode$text${_colorCodes[AnsiColor.reset]}');
    } else {
      print('Unknown color: $color');
    }
  }
}

String? getRootProjectDirectory() {
  final currentDirectory = Directory.current;
  final rootDirectory = findRootDirectory(currentDirectory);

  if (rootDirectory != null) {
    print('Root Project Directory: $rootDirectory');
  } else {
    print('Unable to find the root project directory.');
  }
  return rootDirectory;
}

String? findRootDirectory(Directory directory) {
  final separator = path.separator;
  final parts = path.split(directory.path);

  for (int i = parts.length - 1; i >= 0; i--) {
    if (parts[i] == 'lib') {
      // When 'lib' directory is found, stop and return the parent directory
      return path.joinAll(parts.sublist(0, i));
    }
  }

  // If 'lib' directory is not found in the path, return null
  return null;
}
