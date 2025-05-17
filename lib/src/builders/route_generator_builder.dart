// Simplified route_generator_builder.dart with updated API calls
import 'dart:async';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:build/build.dart';
import 'package:path/path.dart' as p;
import 'package:flutter_route_generator/route_config_annotation.dart';
import 'package:source_gen/source_gen.dart';

/// A builder that generates route code for classes annotated with @routeConfig
class RouteGeneratorBuilder implements Builder {
  @override
  Map<String, List<String>> get buildExtensions => {
        '.dart': ['.routes.dart']
      };

  @override
  FutureOr<void> build(BuildStep buildStep) async {
    // Get the input and output assets
    final inputId = buildStep.inputId;
    final outputId = inputId.changeExtension('.routes.dart');

    // Quick check if the file might contain our annotation
    final content = await buildStep.readAsString(inputId);
    if (!content.contains('@routeConfig') &&
        !content.contains('@RouteConfig')) {
      return; // Skip if annotation is not found
    }

    try {
      // Parse the library
      final library = await buildStep.resolver.libraryFor(inputId);
      final libraryReader = LibraryReader(library);

      // Find classes with the RouteConfig annotation
      final annotatedElements = libraryReader.annotatedWith(
        TypeChecker.fromRuntime(RouteConfig),
      );

      if (annotatedElements.isEmpty) {
        return; // No annotated elements found
      }

      // Generate code for the annotated elements
      final generatedCode = StringBuffer();

      generatedCode.writeln('// GENERATED CODE - DO NOT MODIFY BY HAND');
      generatedCode.writeln(
          '// **************************************************************************');
      generatedCode.writeln('// RouteGenerator');
      generatedCode.writeln(
          '// **************************************************************************');
      generatedCode.writeln();

      // Add imports
      generatedCode.writeln("import 'package:flutter/material.dart';");
      generatedCode.writeln(
          "import 'package:flutter_route_generator/flutter_route_generator.dart';");

      // Extract and add all imports from the original file to ensure screens are available
      // We don't need to import the original file itself anymore
      final imports = <String>{};
      for (final import in library.libraryImports) {
        final uri = import.importedLibrary?.source.uri.toString();
        if (uri != null &&
            !uri.startsWith('dart:') &&
            !uri.contains('flutter_route_generator') &&
            uri != 'package:flutter/material.dart') {
          imports.add(uri);
        }
      }

      // Add all the imports to the generated file
      for (final import in imports) {
        generatedCode.writeln("import '$import';");
      }

      generatedCode.writeln();

      // Process each annotated element
      for (final annotatedElement in annotatedElements) {
        final element = annotatedElement.element;
        if (element is! ClassElement) continue;

        // Find the screenConfigs field
        FieldElement? configField;
        for (final field in element.fields) {
          if (field.isStatic && field.name == 'screenConfigs') {
            configField = field;
            break;
          }
        }

        if (configField == null) continue;

        // Get the screenConfigs list
        final constantValue = configField.computeConstantValue();
        if (constantValue == null) continue;

        final list = constantValue.toListValue();
        if (list == null || list.isEmpty) continue;

        // Process each screen config
        final screens = <_ScreenConfig>[];
        for (final item in list) {
          final screenType = item.getField('screenType')?.toTypeValue();
          if (screenType == null) continue;

          final screenTypeName = screenType.getDisplayString();
          final argsType = item.getField('argsType')?.toTypeValue();
          final argsTypeName = argsType?.getDisplayString();
          final pathValue = item.getField('path')?.toStringValue();
          final isInitial = item.getField('isInitial')?.toBoolValue() ?? false;

          final routeName = pathValue ?? '/${screenTypeName.toLowerCase()}';

          screens.add(_ScreenConfig(
            typeName: screenTypeName,
            argsTypeName: argsTypeName,
            routeName: routeName,
            isInitial: isInitial,
          ));
        }

        // Generate route builder code
        if (screens.isNotEmpty) {
          generatedCode.writeln(_generateRouteBuilder(screens, element.name));
        }
      }

      // Write the generated code to the output file
      await buildStep.writeAsString(outputId, generatedCode.toString());
    } catch (e) {
      print('Error generating routes: $e');
    }
  }

  String _generateRouteBuilder(List<_ScreenConfig> screens, String className) {
    final buffer = StringBuffer();

    buffer.writeln('''
// Routes generated from $className
class GeneratedRouteBuilder {
  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    final routeName = settings.name;
    final arguments = settings.arguments;

    switch (routeName) {''');

    for (final screen in screens) {
      buffer.writeln("      case '${screen.routeName}':");
      if (screen.argsTypeName != null) {
        buffer.writeln(
          "        return MaterialPageRoute(builder: (context) => ${screen.typeName}(args: arguments as ${screen.argsTypeName}?), settings: settings);",
        );
      } else {
        buffer.writeln(
            "        return MaterialPageRoute(builder: (context) => const ${screen.typeName}(), settings: settings);");
      }
    }

    buffer.writeln('''
      default:
        return null; // Route not found
    }
  }
}

// Extensions for navigation
extension RouteBuilderExtensions on RouteBuilder {
  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    return GeneratedRouteBuilder.onGenerateRoute(settings);
  }
  
  static void push(BuildContext context, Type screenTypeParam, {dynamic args}) {
    final screenConfig = _findScreenConfig(screenTypeParam);
    Navigator.of(context).pushNamed(
      screenConfig.routeName,
      arguments: args,
    );
  }

  static void pushReplacement(BuildContext context, Type screenTypeParam, {dynamic args}) {
    final screenConfig = _findScreenConfig(screenTypeParam);
    Navigator.of(context).pushReplacementNamed(
      screenConfig.routeName,
      arguments: args,
    );
  }

  static void pushAndRemoveUntil(BuildContext context, Type screenTypeParam, {dynamic args}) {
    final screenConfig = _findScreenConfig(screenTypeParam);
    Navigator.of(context).pushNamedAndRemoveUntil(
      screenConfig.routeName,
      (route) => false,
      arguments: args,
    );
  }

  static void pop<T>(BuildContext context, [T? result]) {
    Navigator.of(context).pop(result);
  }
  
  static ScreenConfig _findScreenConfig(Type screenTypeParam) {
    try {
      return Routes.routeConfig.screenConfigs.firstWhere(
        (config) => config.screenType == screenTypeParam
      );
    } catch (e) {
      throw Exception('Screen \$screenTypeParam not found in route configurations');
    }
  }
}

// Extension for context-based navigation
extension NavigationExtension on BuildContext {
  void push(Type screenType, {dynamic args}) {
    RouteBuilder.push(this, screenType, args: args);
  }
  
  void pushReplacement(Type screenType, {dynamic args}) {
    RouteBuilder.pushReplacement(this, screenType, args: args);
  }
  
  void pushAndRemoveUntil(Type screenType, {dynamic args}) {
    RouteBuilder.pushAndRemoveUntil(this, screenType, args: args);
  }
  
  void pop<T>([T? result]) {
    RouteBuilder.pop<T>(this, result);
  }
}
''');

    return buffer.toString();
  }
}

class _ScreenConfig {
  final String typeName;
  final String? argsTypeName;
  final String routeName;
  final bool isInitial;

  _ScreenConfig({
    required this.typeName,
    required this.routeName,
    this.argsTypeName,
    this.isInitial = false,
  });
}
