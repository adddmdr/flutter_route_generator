import 'dart:async';
import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:flutter_route_generator/route_config_annotation.dart';
import 'package:source_gen/source_gen.dart';

class RouteGeneratorBuilder extends GeneratorForAnnotation<RouteConfig> {
  RouteGeneratorBuilder() : super();

  @override
  FutureOr<String> generateForAnnotatedElement(
    Element element,
    ConstantReader annotation,
    BuildStep buildStep,
  ) async {
    print('RouteGeneratorBuilder running for ${element.name}');

    if (element is! ClassElement) return '';

    final configField = element.fields.firstWhere(
      (f) =>
          f.isStatic &&
          f.type
              .getDisplayString(withNullability: false)
              .contains('List<ScreenConfig>'),
      orElse: () => throw Exception(
          'No static field of type List<ScreenConfig> found in ${element.name}.'),
    );

    final configValue = configField.computeConstantValue();
    final list = configValue?.toListValue();
    if (list == null) return '';

    final configs = <_ScreenConfigData>[];

    for (final item in list) {
      final screenType = item.getField('screenType')?.toTypeValue();
      final argsType = item.getField('argsType')?.toTypeValue();
      final pathValue = item.getField('path')?.toStringValue();
      final routeName = pathValue ??
          '/${screenType?.getDisplayString(withNullability: false).toLowerCase()}';

      if (screenType != null) {
        configs.add(_ScreenConfigData(
          screenTypeName: screenType.getDisplayString(withNullability: false),
          argsTypeName: argsType?.getDisplayString(withNullability: false),
          routeName: routeName,
        ));
      }
    }

    return _generateCode(configs);
  }

  String _generateCode(List<_ScreenConfigData> configs) {
    final buffer = StringBuffer();

    buffer.writeln('// GENERATED CODE - DO NOT MODIFY BY HAND');
    buffer.writeln(
        '// **************************************************************************');
    buffer.writeln('// Generator: RouteGeneratorBuilder');
    buffer.writeln(
        '// **************************************************************************\n');

    buffer.writeln("import 'package:flutter/material.dart';");

    // TODO: Add dynamic imports for screens and args here if needed

    buffer.writeln('''
class RouteBuilderImpl {
  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    final routeName = settings.name;
    final arguments = settings.arguments;

    switch (routeName) {''');

    for (final config in configs) {
      buffer.writeln("      case '${config.routeName}':");
      if (config.argsTypeName != null) {
        buffer.writeln(
          "        if (arguments is ${config.argsTypeName}) { return MaterialPageRoute(builder: (_) => ${config.screenTypeName}(args: arguments), settings: settings); }",
        );
        buffer.writeln(
            "        throw ArgumentError('Expected ${config.argsTypeName} for route ${config.routeName}');");
      } else {
        buffer.writeln(
            "        return MaterialPageRoute(builder: (_) => ${config.screenTypeName}(), settings: settings);");
      }
    }

    buffer.writeln('''
      default:
        return null;
    }
  }

  static void push(BuildContext context, ScreenConfig config, dynamic args) {
    Navigator.of(context).pushNamed(config.routeName, arguments: args);
  }

  static void pushReplacement(BuildContext context, ScreenConfig config, dynamic args) {
    Navigator.of(context).pushReplacementNamed(config.routeName, arguments: args);
  }

  static void pushAndRemoveUntil(BuildContext context, ScreenConfig config, dynamic args) {
    Navigator.of(context).pushNamedAndRemoveUntil(config.routeName, (route) => false, arguments: args);
  }

  static void pop<T>(BuildContext context, [T? result]) {
    Navigator.of(context).pop(result);
  }
}
''');

    return buffer.toString();
  }
}

class _ScreenConfigData {
  final String screenTypeName;
  final String? argsTypeName;
  final String routeName;

  _ScreenConfigData({
    required this.screenTypeName,
    required this.routeName,
    this.argsTypeName,
  });
}
