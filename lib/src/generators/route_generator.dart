/// Generator for route file
class RouteGenerator {
  /// Generate routes code based on screen names and their arguments
  static String generateRoutes(Map<String, String?> screenToArgs) {
    final buffer = StringBuffer();

    // Imports
    buffer.writeln("// GENERATED CODE - DO NOT MODIFY BY HAND");
    buffer.writeln();
    buffer.writeln("import 'package:flutter/material.dart';");
    buffer.writeln("import 'package:flutter_route_generator/routes.dart';");
    buffer.writeln();

    // Import screens
    for (final screenName in screenToArgs.keys) {
      buffer.writeln("import 'screens/${_getFileName(screenName)}.dart';");
    }
    buffer.writeln();

    // Import arguments
    final argsClasses = screenToArgs.values.where((arg) => arg != null).toSet();
    for (final argsClass in argsClasses) {
      buffer.writeln("import 'arguments/${_getFileName(argsClass)}.dart';");
    }
    buffer.writeln();

    // Generate route names
    buffer.writeln("/// Generated route names");
    buffer.writeln("class Routes {");
    buffer.writeln("  Routes._();");
    buffer.writeln();

    for (final screenName in screenToArgs.keys) {
      final routeName = _getRouteName(screenName);
      buffer.writeln("  /// Route for $screenName");
      buffer.writeln(
          "  static const String ${_getRouteConstName(screenName)} = '/$routeName';");
    }

    buffer.writeln("}");
    buffer.writeln();

    // Generate route handler
    buffer.writeln("/// Get route based on settings");
    buffer.writeln("Route<dynamic>? getRoute(RouteSettings settings) {");
    buffer.writeln("  switch (settings.name) {");

    for (final entry in screenToArgs.entries) {
      final screenName = entry.key;
      final argsClass = entry.value;
      // final routeName = _getRouteName(screenName);

      buffer.writeln("    case Routes.${_getRouteConstName(screenName)}:");

      if (argsClass != null) {
        buffer.writeln(
            "      final args = settings.arguments as RouteArguments<$argsClass>?;");
        buffer.writeln("      return MaterialPageRoute(");
        buffer.writeln(
            "        builder: (context) => $screenName(args: args?.arguments),");
        buffer.writeln("        settings: settings,");
        buffer.writeln("      );");
      } else {
        buffer.writeln("      return MaterialPageRoute(");
        buffer.writeln("        builder: (context) => const $screenName(),");
        buffer.writeln("        settings: settings,");
        buffer.writeln("      );");
      }
    }

    buffer.writeln("    default:");
    buffer.writeln("      return null;");
    buffer.writeln("  }");
    buffer.writeln("}");
    buffer.writeln();

    // Generate extension methods for Navigator
    buffer.writeln("/// Extension methods for Navigator");
    buffer.writeln("extension NavigatorExtension on NavigatorState {");

    for (final entry in screenToArgs.entries) {
      final screenName = entry.key;
      final argsClass = entry.value;
      final routeConstName = _getRouteConstName(screenName);

      // Push method
      buffer.write("  /// Push $screenName");
      buffer.writeln();

      if (argsClass != null) {
        buffer.writeln(
            "  Future<T?> push$screenName<T extends Object?>($argsClass args) {");
        buffer.writeln(
            "    return pushNamed<T>(Routes.$routeConstName, arguments: RouteArguments(args));");
        buffer.writeln("  }");
      } else {
        buffer.writeln("  Future<T?> push$screenName<T extends Object?>() {");
        buffer.writeln("    return pushNamed<T>(Routes.$routeConstName);");
        buffer.writeln("  }");
      }
      buffer.writeln();

      // Push replacement method
      buffer.write("  /// Push replacement $screenName");
      buffer.writeln();

      if (argsClass != null) {
        buffer.writeln(
            "  Future<T?> pushReplacement$screenName<T extends Object?, TO extends Object?>($argsClass args, {TO? result}) {");
        buffer.writeln(
            "    return pushReplacementNamed<T, TO>(Routes.$routeConstName, arguments: RouteArguments(args), result: result);");
        buffer.writeln("  }");
      } else {
        buffer.writeln(
            "  Future<T?> pushReplacement$screenName<T extends Object?, TO extends Object?>({TO? result}) {");
        buffer.writeln(
            "    return pushReplacementNamed<T, TO>(Routes.$routeConstName, result: result);");
        buffer.writeln("  }");
      }
      buffer.writeln();
    }

    buffer.writeln("}");
    buffer.writeln();

    // Generate extension methods for BuildContext
    buffer.writeln("/// Extension methods for BuildContext");
    buffer.writeln("extension BuildContextRouteExtension on BuildContext {");

    for (final entry in screenToArgs.entries) {
      final screenName = entry.key;
      final argsClass = entry.value;

      // Push method
      buffer.write("  /// Push $screenName");
      buffer.writeln();

      if (argsClass != null) {
        buffer.writeln(
            "  Future<T?> push$screenName<T extends Object?>($argsClass args) {");
        buffer
            .writeln("    return Navigator.of(this).push$screenName<T>(args);");
        buffer.writeln("  }");
      } else {
        buffer.writeln("  Future<T?> push$screenName<T extends Object?>() {");
        buffer.writeln("    return Navigator.of(this).push$screenName<T>();");
        buffer.writeln("  }");
      }
      buffer.writeln();

      // Push replacement method
      buffer.write("  /// Push replacement $screenName");
      buffer.writeln();

      if (argsClass != null) {
        buffer.writeln(
            "  Future<T?> pushReplacement$screenName<T extends Object?, TO extends Object?>($argsClass args, {TO? result}) {");
        buffer.writeln(
            "    return Navigator.of(this).pushReplacement$screenName<T, TO>(args, result: result);");
        buffer.writeln("  }");
      } else {
        buffer.writeln(
            "  Future<T?> pushReplacement$screenName<T extends Object?, TO extends Object?>({TO? result}) {");
        buffer.writeln(
            "    return Navigator.of(this).pushReplacement$screenName<T, TO>(result: result);");
        buffer.writeln("  }");
      }
      buffer.writeln();
    }

    buffer.writeln("}");

    return buffer.toString();
  }

  /// Convert PascalCase to kebab-case and remove 'Screen' suffix
  static String _getRouteName(String screenName) {
    // Convert from PascalCase to kebab-case
    final name = screenName
        .replaceAllMapped(
            RegExp(r'([A-Z])'), (match) => '-${match.group(1)!.toLowerCase()}')
        .substring(1);

    // Remove 'Screen' suffix
    return name.endsWith('-screen') ? name.substring(0, name.length - 7) : name;
  }

  /// Get the filename for a class (convert PascalCase to snake_case)
  static String _getFileName(String? className) {
    if (className == null) return '';

    return className
        .replaceAllMapped(
            RegExp(r'([A-Z])'), (match) => '_${match.group(1)!.toLowerCase()}')
        .substring(1);
  }

  /// Convert screen name to route constant name (PascalCase to SCREAMING_SNAKE_CASE)
  static String _getRouteConstName(String screenName) {
    // Remove 'Screen' suffix
    final baseName = screenName.endsWith('Screen')
        ? screenName.substring(0, screenName.length - 6)
        : screenName;

    // Convert from PascalCase to SCREAMING_SNAKE_CASE
    return baseName
        .replaceAllMapped(RegExp(r'([A-Z])'), (match) => '_${match.group(1)}')
        .substring(1)
        .toUpperCase();
  }
}
