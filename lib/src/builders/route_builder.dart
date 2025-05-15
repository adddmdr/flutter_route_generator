import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:flutter_route_generator/src/generators/route_generator.dart';
import 'package:glob/glob.dart';
import 'package:source_gen/source_gen.dart';

/// Builder for generating routes
Builder routeBuilder(BuilderOptions options) => RouteBuilder();

/// Route builder implementation
class RouteBuilder implements Builder {
  @override
  Map<String, List<String>> get buildExtensions => {
        r'$lib$': ['routes.g.dart']
      };

  @override
  Future<void> build(BuildStep buildStep) async {
    // Find all Dart files in the 'screens' directory
    final screenFiles =
        await buildStep.findAssets(Glob('lib/screens/**.dart')).toList();

    // Find all argument files
    final argFiles =
        await buildStep.findAssets(Glob('lib/arguments/**.dart')).toList();

    // Map of screen names to their argument class names
    final Map<String, String?> screenToArgs = {};

    // Extract screen class names
    for (final screenFile in screenFiles) {
      final library = await buildStep.resolver.libraryFor(screenFile);
      final classes = LibraryReader(library).classes;

      for (final classElement in classes) {
        // Find classes that are likely screens (end with 'Screen' and extend StatelessWidget/StatefulWidget)
        if (classElement.name.endsWith('Screen') &&
            _isWidgetClass(classElement)) {
          // Check if there's a matching arguments class
          final String screenName = classElement.name;
          String? argsClass;

          // Look for matching arguments class
          for (final argFile in argFiles) {
            final argLibrary = await buildStep.resolver.libraryFor(argFile);
            final argClasses = LibraryReader(argLibrary).classes;

            // Fix: Use a null-safe approach to find matching arg class
            ClassElement? matchingArg;
            for (final argElement in argClasses) {
              if (argElement.name == '${screenName}Args') {
                matchingArg = argElement;
                break;
              }
            }

            if (matchingArg != null) {
              argsClass = matchingArg.name;
              break;
            }
          }

          screenToArgs[screenName] = argsClass;
        }
      }
    }

    // Generate route file
    final outputContent = RouteGenerator.generateRoutes(screenToArgs);

    // Write output file
    await buildStep.writeAsString(
        AssetId(buildStep.inputId.package, 'lib/routes.g.dart'), outputContent);
  }

  /// Check if a class is a Widget class
  bool _isWidgetClass(ClassElement element) {
    ClassElement currentElement = element;

    while (currentElement.supertype != null) {
      final superElement = currentElement.supertype!.element;
      if (superElement.name == 'StatelessWidget' ||
          superElement.name == 'StatefulWidget') {
        return true;
      }

      if (superElement is! ClassElement) break;
      currentElement = superElement;
    }

    return false;
  }
}
