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
  String jsonKey;
  ClassFieldFromJson({
    required this.type,
    required this.name,
    required this.jsonKey,
  });
}

class ConverterOptions {
  final bool requiredParams;
  final bool nullableParams;
  final bool isAbstract;
  final bool finalFields;
  final bool factoryConstructor;
  final bool constConstructor;
  final bool equatable;
  final bool generateFields;
  final bool callSuperNotThis;
  final bool extendSameClassWithPostFix;
  final String mixins;
  final String superClass;
  final String classNamePostfix;
  final String superClassNamePostfix;
  final CompatibleLibrary? compatibleLibrary;

  ConverterOptions({
    this.requiredParams = false,
    this.nullableParams = false,
    this.isAbstract = false,
    this.finalFields = false,
    this.factoryConstructor = false,
    this.constConstructor = false,
    this.equatable = false,
    this.generateFields = false,
    this.callSuperNotThis = false,
    this.extendSameClassWithPostFix = false,
    this.mixins = '',
    this.superClass = '',
    this.classNamePostfix = '',
    this.superClassNamePostfix = '',
    this.compatibleLibrary,
  }) : assert(constConstructor && !finalFields,
            "Can't define a const constructor for a class with non-final fields.");
}

enum CompatibleLibrary {
  jsonSerializable,
  freezed,
}
