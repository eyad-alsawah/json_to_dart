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
