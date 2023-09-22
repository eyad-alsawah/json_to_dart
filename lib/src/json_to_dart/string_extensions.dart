extension ToPascalCase on String {
  String toPascalCase() {
    List<String> parts = this.split('_');
    String result = '';

    for (String part in parts) {
      if (part.isNotEmpty) {
        result += part[0].toUpperCase() + part.substring(1);
      }
    }

    return result;
  }
}

extension ToCamelCase on String {
  String toCamelCase() {
    List<String> parts = this.split('_');
    String result = '';

    for (int i = 0; i < parts.length; i++) {
      String part = parts[i];
      if (part.isNotEmpty) {
        if (i == 0) {
          result += part;
        } else {
          result += part[0].toUpperCase() + part.substring(1);
        }
      }
    }

    return result;
  }
}

String camelCaseToSnakeCase(String input) {
  if (input.isEmpty) {
    return input; // Return input if it's empty
  }

  String snakeCaseString =
      input[0].toLowerCase(); // Start with the first character in lowercase

  for (int i = 1; i < input.length; i++) {
    if (input[i].toUpperCase() == input[i]) {
      // If the character is uppercase, insert an underscore followed by the lowercase character
      snakeCaseString += '_${input[i].toLowerCase()}';
    } else {
      // Otherwise, keep the character as is
      snakeCaseString += input[i];
    }
  }

  return snakeCaseString;
}
