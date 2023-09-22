class ClassFromJson {
  List<ClassFieldFromJson> classFieldsFromJson;
  String className;
  ClassFromJson({
    required this.className,
    required this.classFieldsFromJson,
  });
}

class ClassFieldFromJson {
  String type;
  String name;
  ClassFieldFromJson({
    required this.type,
    required this.name,
  });
}
