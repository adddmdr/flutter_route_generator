import 'dart:async';
import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';
import 'package:glob/glob.dart';
import 'package:path/path.dart' as path;

class RouteGeneratorBuilder extends Generator {
  @override
  FutureOr<String> generate(LibraryReader library, BuildStep buildStep) async {
    // First, collect all Dart files in the project
    final projectFiles = await _findAllProjectFiles(buildStep);

    // Now find screen classes across all these files
    final screenClasses = await _findScreenClasses(projectFiles, buildStep);

    // Then find all screen configurations
    final screenConfigs =
        await _findScreenConfigs(library, buildStep, screenClasses);

    if (screenConfigs.isEmpty) {
      return '';
    }

    // Generate the route implementation
    return _generateRouteImplementation(screenConfigs, screenClasses);
  }

  Future<List<AssetId>> _findAllProjectFiles(BuildStep buildStep) async {
    final dartFiles = Glob("lib/**.dart");
    final assetIds = <AssetId>[];

    await for (final id in buildStep.findAssets(dartFiles)) {
      // Filter out generated files and this builder's own files
      if (!id.path.contains('.g.dart') &&
          !id.path.contains('route_generator')) {
        assetIds.add(id);
      }
    }

    return assetIds;
  }

  Future<Map<String, ClassElement>> _findScreenClasses(
      List<AssetId> assetIds, BuildStep buildStep) async {
    final screenClasses = <String, ClassElement>{};

    for (final assetId in assetIds) {
      if (await buildStep.canRead(assetId)) {
        final library = await buildStep.resolver.libraryFor(assetId);
        final libraryReader = LibraryReader(library);

        for (final classElement in libraryReader.classes) {
          // Look for classes that might be screens (StatelessWidget, StatefulWidget)
          // This would need to check inheritance in a full implementation
          screenClasses[classElement.name] = classElement;
        }
      }
    }

    return screenClasses;
  }

  Future<List<Map<String, dynamic>>> _findScreenConfigs(LibraryReader library,
      BuildStep buildStep, Map<String, ClassElement> screenClasses) async {
    final configs = <Map<String, dynamic>>[];

    // Look through variable declarations for ScreenConfig instances
    for (final classElement in library.classes) {
      for (final field in classElement.fields) {
        // Look for lists of ScreenConfig objects
        if (field.type.toString().contains('List<ScreenConfig>')) {
          // In a full implementation, this would parse the actual initializer
          // to extract screen types and args types

          // For now, we just record that we found a list
          configs.add({
            'containingClass': classElement.name,
            'field': field.name,
          });
        }
      }
    }

    return configs;
  }

  String _generateRouteImplementation(List<Map<String, dynamic>> screenConfigs,
      Map<String, ClassElement> screenClasses) {
    final buffer = StringBuffer();

    // Import necessary packages
    buffer.writeln("import 'package:flutter/material.dart';");

    // Generate stub implementations for the RouteBuilder methods
    buffer.writeln('''
// Generated route builder implementation
class RouteBuilderImpl {
  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    final routeName = settings.name;
    final arguments = settings.arguments;
    
    // Get route configuration from initialized routes
    for (final config in Routes.routeConfig.screenConfigs) {
      if (config.routeName == routeName) {
        return MaterialPageRoute(
          builder: (context) => _buildScreen(config.screenType, arguments),
          settings: settings,
        );
      }
    }
    
    return null; // Route not found
  }
  
  static Widget _buildScreen(Type screenType, dynamic arguments) {
    // In practice, this would map the Type to actual constructors
    // For demonstration purposes, we're using a placeholder
    throw UnimplementedError(
      'Screen builder not fully implemented. This would be replaced by generated code that maps types to actual widgets.'
    );
  }
}

// Extension implementation for RouteBuilder methods
extension RouteBuilderImplExtension on RouteBuilder {
  static void push(BuildContext context, ScreenConfig screenConfig, dynamic args) {
    Navigator.of(context).pushNamed(
      screenConfig.routeName,
      arguments: args,
    );
  }

  static void pushReplacement(BuildContext context, ScreenConfig screenConfig, dynamic args) {
    Navigator.of(context).pushReplacementNamed(
      screenConfig.routeName,
      arguments: args,
    );
  }

  static void pushAndRemoveUntil(BuildContext context, ScreenConfig screenConfig, dynamic args) {
    Navigator.of(context).pushNamedAndRemoveUntil(
      screenConfig.routeName,
      (route) => false,
      arguments: args,
    );
  }

  static void pop<T>(BuildContext context, [T? result]) {
    Navigator.of(context).pop(result);
  }
}
''');

    return buffer.toString();
  }
}
