// Updated route_generator_builder.dart with standalone implementation that doesn't use RouteBuilder

import 'dart:async';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:build/build.dart';
import 'package:flutter_route_generator/route_config_annotation.dart';
import 'package:source_gen/source_gen.dart';

/// A builder that generates standalone route code for classes annotated with @routeConfig
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
      final imports = <String>{};
      try {
        for (final import in library.libraryImports) {
          final uri = import.importedLibrary?.source.uri.toString();
          if (uri != null &&
              !uri.startsWith('dart:') &&
              !uri.contains('flutter_route_generator') &&
              uri != 'package:flutter/material.dart') {
            imports.add(uri);
          }
        }
      } catch (e) {
        print('Error extracting imports: $e');
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

          final screenTypeName = _getTypeName(screenType);
          final argsType = item.getField('argsType')?.toTypeValue();
          final argsTypeName = argsType != null ? _getTypeName(argsType) : null;
          final pathValue = item.getField('path')?.toStringValue();
          final isInitial = item.getField('isInitial')?.toBoolValue() ?? false;
          final requiresArgs =
              item.getField('requiresArgs')?.toBoolValue() ?? false;

          // Format the route name with proper casing: HomeScreen -> /homeScreen
          final routeName = pathValue ??
              '/${screenTypeName.substring(0, 1).toLowerCase()}${screenTypeName.substring(1)}';

          screens.add(_ScreenConfig(
            typeName: screenTypeName,
            argsTypeName: argsTypeName,
            routeName: routeName,
            isInitial: isInitial,
            requiresArgs: requiresArgs,
          ));
        }

        // Generate completely standalone route code
        if (screens.isNotEmpty) {
          generatedCode
              .writeln(_generateStandaloneRouteCode(screens, element.name));
        }
      }

      // Write the generated code to the output file
      await buildStep.writeAsString(outputId, generatedCode.toString());
    } catch (e) {
      print('Error generating routes: $e');
    }
  }

  String _getTypeName(DartType type) {
    try {
      if (type is InterfaceType) {
        return type.element.name;
      }
      return type.toString().replaceAll('*', '');
    } catch (e) {
      return 'Unknown';
    }
  }

  String _generateStandaloneRouteCode(
      List<_ScreenConfig> screens, String className) {
    final buffer = StringBuffer();

    buffer.writeln('''
// Routes generated from $className
Route<dynamic>? appRouteGenerator(RouteSettings settings) {
  final routeName = settings.name;
  final arguments = settings.arguments;

  switch (routeName) {''');

    for (final screen in screens) {
      buffer.writeln("    case '${screen.routeName}':");

      if (screen.argsTypeName != null) {
        if (screen.requiresArgs) {
          // For screens that require arguments, add a null check with an error
          buffer.writeln('''
      if (arguments == null) {
        throw ArgumentError('${screen.typeName} requires ${screen.argsTypeName} but no arguments were provided');
      }
      return MaterialPageRoute(
        builder: (context) => ${screen.typeName}(args: arguments as ${screen.argsTypeName}), 
        settings: settings
      );''');
        } else {
          // For screens with optional arguments
          buffer.writeln(
            "      return MaterialPageRoute(builder: (context) => ${screen.typeName}(args: arguments as ${screen.argsTypeName}?), settings: settings);",
          );
        }
      } else {
        // For screens without arguments
        buffer.writeln(
            "      return MaterialPageRoute(builder: (context) => const ${screen.typeName}(), settings: settings);");
      }
    }

    buffer.writeln('''
    default:
      // Fallback route - you can customize this to show a not found page
      return MaterialPageRoute(
        settings: settings,
        builder: (context) => Scaffold(
          appBar: AppBar(title: const Text('Page Not Found')),
          body: Center(
            child: Text('The page "\${settings.name}" could not be found.'),
          ),
        ),
      );
  }
}

// Navigation extension - completely standalone implementation
extension NavigationExtension on BuildContext {
  void push(Type screenType, {dynamic args}) {
    final screenConfig = _findScreenConfig(screenType);
    
    // Check if args are required but not provided
    if (screenConfig.requiresArgs && args == null) {
      throw ArgumentError('Screen \${screenType} requires arguments but none were provided');
    }
    
    Navigator.of(this).pushNamed(
      screenConfig.routeName,
      arguments: args,
    );
  }

  void pushReplacement(Type screenType, {dynamic args}) {
    final screenConfig = _findScreenConfig(screenType);
    
    // Check if args are required but not provided
    if (screenConfig.requiresArgs && args == null) {
      throw ArgumentError('Screen \${screenType} requires arguments but none were provided');
    }
    
    Navigator.of(this).pushReplacementNamed(
      screenConfig.routeName,
      arguments: args,
    );
  }

  void pushAndRemoveUntil(Type screenType, {dynamic args}) {
    final screenConfig = _findScreenConfig(screenType);
    
    // Check if args are required but not provided
    if (screenConfig.requiresArgs && args == null) {
      throw ArgumentError('Screen \${screenType} requires arguments but none were provided');
    }
    
    Navigator.of(this).pushNamedAndRemoveUntil(
      screenConfig.routeName,
      (route) => false,
      arguments: args,
    );
  }

  void pop<T>([T? result]) {
    Navigator.of(this).pop(result);
  }
  
  ScreenConfig _findScreenConfig(Type screenType) {
    try {
      return Routes.routeConfig.screenConfigs.firstWhere(
        (config) => config.screenType == screenType
      );
    } catch (e) {
      throw Exception('Screen \${screenType} not found in route configurations');
    }
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
  final bool requiresArgs;

  _ScreenConfig({
    required this.typeName,
    required this.routeName,
    this.argsTypeName,
    this.isInitial = false,
    this.requiresArgs = false,
  });
}
