import 'dart:io';

import 'classes_to_json.dart';

void formatDartFile(String filePath) {
  Process.run('dart', ['format', filePath]).then((result) {
    if (result.exitCode == 0) {
      print('Formatted the Dart code successfully.');
    } else {
      print('Failed to format the Dart code. Error: ${result.stderr}');
    }
  });
}

void runBuildRunner() {
  Process.run('dart', ['run', 'build_runner', 'build']).then((result) {
    if (result.exitCode == 0) {
      print('build_runner build completed successfully.');
    } else {
      print('build_runner build failed. Error: ${result.stderr}');
    }
  });
}
