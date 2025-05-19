import 'dart:async';
import 'package:build/build.dart';
import 'package:glob/glob.dart';
import 'package:flutter_route_generator/route_config_annotation.dart';
import 'package:source_gen/source_gen.dart';
import 'package:analyzer/dart/element/element.dart';

/// A builder that creates a registry of all route configurations in the project
class RegistryGeneratorBuilder implements Builder {
  @override
  Map<String, List<String>> get buildExtensions => {
        'lib/\$lib\$': ['lib/routes_registry.g.dart'],
      };

  @override
  FutureOr<void> build(BuildStep buildStep) async {
    // Find all Dart files in the project
    final dartFiles = Glob('lib/**.dart');

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
}
