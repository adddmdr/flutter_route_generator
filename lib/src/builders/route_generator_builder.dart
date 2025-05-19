import 'dart:async';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:build/build.dart';
import 'package:flutter_route_generator/route_config_annotation.dart';
import 'package:source_gen/source_gen.dart';
import 'package:glob/glob.dart';

/// A builder that generates route code for classes annotated with @routeConfig
class RouteGeneratorBuilder implements Builder {
  @override
  Map<String, List<String>> get buildExtensions => {
        r'$lib$': ['routes_registry.g.dart'],
        '.dart': ['.routes.dart'],
      };

  @override
  FutureOr<void> build(BuildStep buildStep) async {
    // Check if this is the special root build input
    if (buildStep.inputId.path == r'$lib$') {
      await _buildRegistry(buildStep);
      return;
    }

    // Regular file processing for individual route configs
    final inputId = buildStep.inputId;
    final outputId = inputId.changeExtension('.routes.dart');

    // Quick check if the file might contain our annotation
    final content = await buildStep.readAsString(inputId);
    if (!content.contains('@routeConfig') &&
        !content.contains('@RouteConfig')) {
      return; // Skip if annotation is not found
    }

    // Proceed with normal route generation for this file
    await _generateRoutes(buildStep, inputId, outputId);
  }

  /// Builds a central registry of all route configurations
  Future<void> _buildRegistry(BuildStep buildStep) async {
    // Find all Dart files in the project
    final dartFiles = Glob('**/*.dart');

    // Store all the route config classes we find
    final routeConfigClasses = <String>[];

    // Check each file for route configs
    await for (final input in buildStep.findAssets(dartFiles)) {
      // Skip generated files
      if (input.path.endsWith('.g.dart') ||
          input.path.endsWith('.routes.dart')) {
        continue;
      }

      try {
        final library = await buildStep.resolver.libraryFor(input);
        final libraryReader = LibraryReader(library);

        // Find classes with the RouteConfig annotation
        final annotatedElements = libraryReader.annotatedWith(
          TypeChecker.fromRuntime(RouteConfig),
        );

        for (final element in annotatedElements) {
          if (element.element is ClassElement) {
            final className = (element.element as ClassElement).name;
            final libraryUri = library.source.uri.toString();

            // Add this route config class to our list
            routeConfigClasses.add('$className from $libraryUri');
          }
        }
      } catch (e) {
        // Skip files that can't be parsed
        continue;
      }
    }

    // Create a registry file listing all route configs
    final registry = StringBuffer();
    registry
        .writeln('// GENERATED CODE - AUTO-DISCOVERED ROUTE CONFIGURATIONS');
    registry.writeln(
        '// **************************************************************************');
    registry
        .writeln('// Found ${routeConfigClasses.length} @routeConfig classes:');

    for (final configClass in routeConfigClasses) {
      registry.writeln('// - $configClass');
    }

    registry.writeln(
        '// **************************************************************************');

    // Write the registry file
    final outputId =
        AssetId(buildStep.inputId.package, 'lib/routes_registry.g.dart');
    await buildStep.writeAsString(outputId, registry.toString());
  }

  Future<void> _generateRoutes(
      BuildStep buildStep, AssetId inputId, AssetId outputId) async {
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

      // Add imports - only the essential ones
      generatedCode.writeln("import 'package:flutter/material.dart';");
      generatedCode
          .writeln("import 'package:flutter_route_generator/routes.dart';");

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

          // If there's an args type, find the parameter name in the screen class constructor
          String? argsParamName = null;
          bool isArgRequired = false;

          if (argsType != null) {
            try {
              // Get the parameter info from the constructor
              final paramInfo =
                  _findConstructorParamForType(screenType, argsType);
              argsParamName = paramInfo.name;
              isArgRequired = paramInfo.isRequired;

              // Alert if the parameter is required but requiresArgs is not set
              if (isArgRequired && !requiresArgs) {
                log.warning(
                    'ROUTE CONFIG WARNING: ${screenTypeName} has a required parameter for ${argsTypeName} '
                    'but requiresArgs is not set to true in the ScreenConfig. '
                    'This may cause runtime errors if arguments are not provided.');
              }
            } catch (e) {
              print(
                  'Warning: Could not detect parameter info for $argsTypeName in $screenTypeName: $e');
              // If we can't find a parameter, fall back to "args"
              argsParamName = 'args';
            }
          }

          // Format the route name with proper casing: HomeScreen -> /homeScreen
          final routeName = pathValue ??
              '/${screenTypeName.substring(0, 1).toLowerCase()}${screenTypeName.substring(1)}';

          screens.add(_ScreenConfig(
            typeName: screenTypeName,
            argsTypeName: argsTypeName,
            routeName: routeName,
            isInitial: isInitial,
            requiresArgs: requiresArgs,
            argsParamName: argsParamName,
          ));
        }

        // Generate route code
        if (screens.isNotEmpty) {
          generatedCode.writeln(_generateRouteOnlyCode(screens, element.name));
        }
      }

      // Write the generated code to the output file
      await buildStep.writeAsString(outputId, generatedCode.toString());
    } catch (e) {
      print('Error generating routes for ${inputId.path}: $e');
    }
  }

  /// Find the parameter name and required status in the class constructor
  _ConstructorParamInfo _findConstructorParamForType(
      DartType classType, DartType argsType) {
    if (classType is! InterfaceType)
      return _ConstructorParamInfo(name: 'args', isRequired: false);

    final classElement = classType.element;
    if (classElement is! ClassElement)
      return _ConstructorParamInfo(name: 'args', isRequired: false);

    // Find a constructor - try default constructor first, then any others
    ConstructorElement? constructor;

    // Look for the unnamed constructor
    for (final ctor in classElement.constructors) {
      if (ctor.name.isEmpty) {
        constructor = ctor;
        break;
      }
    }

    // If we didn't find an unnamed constructor, use the first one available
    if (constructor == null && classElement.constructors.isNotEmpty) {
      constructor = classElement.constructors.first;
    }

    // If we still don't have a constructor, return default
    if (constructor == null)
      return _ConstructorParamInfo(name: 'args', isRequired: false);

    // Look for a parameter with the matching type
    for (final param in constructor.parameters) {
      final paramType = param.type.getDisplayString(withNullability: false);
      final argsTypeStr = argsType.getDisplayString(withNullability: false);

      if (paramType == argsTypeStr) {
        return _ConstructorParamInfo(
          name: param.name,
          isRequired: param.isRequired,
        );
      }
    }

    // If we can't find a matching parameter, return default
    return _ConstructorParamInfo(name: 'args', isRequired: false);
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

  String _generateRouteOnlyCode(List<_ScreenConfig> screens, String className) {
    final buffer = StringBuffer();

    // Create unique function name based on class name to avoid conflicts
    final functionName = 'generate${className}Routes';

    buffer.writeln('''
// Route generator function for $className
Route<dynamic>? $functionName(RouteSettings settings) {
  final routeName = settings.name;
  final arguments = settings.arguments;

  switch (routeName) {''');

    for (final screen in screens) {
      buffer.writeln("    case '${screen.routeName}':");

      if (screen.argsTypeName != null) {
        final paramName = screen.argsParamName ?? 'args';

        if (screen.requiresArgs) {
          // For screens that require arguments, add a null check with an error
          buffer.writeln('''
      if (arguments == null) {
        throw ArgumentError('${screen.typeName} requires ${screen.argsTypeName} but no arguments were provided');
      }
      return MaterialPageRoute(
        builder: (context) => ${screen.typeName}($paramName: arguments as ${screen.argsTypeName}), 
        settings: settings
      );''');
        } else {
          // For screens with optional arguments
          buffer.writeln(
            "      return MaterialPageRoute(builder: (context) => ${screen.typeName}($paramName: arguments as ${screen.argsTypeName}?), settings: settings);",
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
      // Return null to let the parent handler or fallback route handle it
      return null;
  }
}

// Main route generator function that includes fallback handling
Route<dynamic> appRouteGenerator(RouteSettings settings) {
  // Try the specific route generator first
  final route = $functionName(settings);
  if (route != null) {
    return route;
  }
  
  // If no route found, use the fallback route
  return Routes.createFallbackRoute(settings);
}''');

    return buffer.toString();
  }
}

/// Holds information about a constructor parameter
class _ConstructorParamInfo {
  final String name;
  final bool isRequired;

  _ConstructorParamInfo({
    required this.name,
    required this.isRequired,
  });
}

class _ScreenConfig {
  final String typeName;
  final String? argsTypeName;
  final String routeName;
  final bool isInitial;
  final bool requiresArgs;
  final String? argsParamName; // Added parameter name field

  _ScreenConfig({
    required this.typeName,
    required this.routeName,
    this.argsTypeName,
    this.isInitial = false,
    this.requiresArgs = false,
    this.argsParamName,
  });
}
