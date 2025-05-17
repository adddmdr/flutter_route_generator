import 'package:flutter/material.dart';
import 'package:flutter_route_generator/flutter_route_generator.dart';

/// A central class for route management
class Routes {
  static RouteConfig routeConfig = RouteConfig([]);

  /// Initialize routes with screen configurations
  static Future<void> initialize(List<ScreenConfig> screenConfigs) async {
    routeConfig = RouteConfig(screenConfigs);
  }

  /// Helper method to extract typed arguments
  static T? getArgs<T>(dynamic arguments) {
    if (arguments != null && arguments is T) {
      return arguments;
    }
    return null;
  }
}

/// Extension methods for navigation using BuildContext
extension NavigationExtension on BuildContext {
  void push(Type screenType, {dynamic args}) {
    final screenConfig = _findScreenConfig(screenType);
    if (screenConfig == null) {
      throw Exception('Screen $screenType not found in route configurations');
    }

    // Check if args are required but not provided
    if (screenConfig.requiresArgs && args == null) {
      throw ArgumentError(
          'Screen $screenType requires arguments but none were provided');
    }

    Navigator.of(this).pushNamed(
      screenConfig.path ?? '/${_getRouteName(screenType)}',
      arguments: args,
    );
  }

  void pushReplacement(Type screenType, {dynamic args}) {
    final screenConfig = _findScreenConfig(screenType);
    if (screenConfig == null) {
      throw Exception('Screen $screenType not found in route configurations');
    }

    // Check if args are required but not provided
    if (screenConfig.requiresArgs && args == null) {
      throw ArgumentError(
          'Screen $screenType requires arguments but none were provided');
    }

    Navigator.of(this).pushReplacementNamed(
      screenConfig.path ?? '/${_getRouteName(screenType)}',
      arguments: args,
    );
  }

  void pushAndRemoveUntil(Type screenType, {dynamic args}) {
    final screenConfig = _findScreenConfig(screenType);
    if (screenConfig == null) {
      throw Exception('Screen $screenType not found in route configurations');
    }

    // Check if args are required but not provided
    if (screenConfig.requiresArgs && args == null) {
      throw ArgumentError(
          'Screen $screenType requires arguments but none were provided');
    }

    Navigator.of(this).pushNamedAndRemoveUntil(
      screenConfig.path ?? '/${_getRouteName(screenType)}',
      (route) => false,
      arguments: args,
    );
  }

  void pop<T>([T? result]) {
    Navigator.of(this).pop(result);
  }

  /// Find a screen configuration by its type
  ScreenConfig? _findScreenConfig(Type screenType) {
    try {
      return Routes.routeConfig.getScreenConfigByType(screenType);
    } catch (e) {
      return null;
    }
  }

  /// Convert screen type to route name (first letter lowercase)
  String _getRouteName(Type screenType) {
    final typeName = screenType.toString();
    return typeName.substring(0, 1).toLowerCase() + typeName.substring(1);
  }
}
