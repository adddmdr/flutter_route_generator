import 'package:flutter/material.dart';
import 'src/models/route_config.dart';
import 'src/models/screen_config.dart';

/// Configure the route generator with screens
class RouteManager {
  static RouteConfig? _config;

  /// Configure the route generator with the given screens
  static void configure(List<ScreenConfig> screens) {
    _config = RouteConfig(screens: screens);
  }

  /// Get the route configuration
  static RouteConfig get config {
    if (_config == null) {
      throw StateError(
          'RouteManager not configured. Call RouteManager.configure() first.');
    }
    return _config!;
  }
}

/// Get generated route based on settings
Route<dynamic>? getRoute(RouteSettings settings) {
  // This will be overridden by the generated code
  throw UnimplementedError(
      'Route generation not implemented. Run build_runner first.');
}

/// Route wrapper for arguments
class RouteArguments<T> {
  final T arguments;

  const RouteArguments(this.arguments);
}
