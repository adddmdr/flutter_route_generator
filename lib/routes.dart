import 'package:flutter/material.dart';
import 'src/models/route_config.dart';
import 'src/models/screen_config.dart';
import 'src/router/routes_map.dart';

/// Main routes class for the application
class Routes {
  /// Initialize the routes with screen configurations
  static Future<void> initialize(
    List<ScreenConfig> screenConfigs, {
    FallbackRouteConfig? fallbackRouteConfig,
  }) async {
    RoutesRegistry.initialize(
      screenConfigs,
      fallbackRouteConfig: fallbackRouteConfig,
    );
  }

  /// Create a fallback route for unknown routes
  static Route<dynamic> createFallbackRoute(RouteSettings settings) {
    return RoutesRegistry.instance.createFallbackRoute(settings);
  }

  /// Get the route configuration
  static RoutesRegistry get routeConfig => RoutesRegistry.instance;
}

/// Extension methods for navigation
extension NavigationExtension on BuildContext {
  /// Navigate to a screen
  Future<T?> push<T>(Type screenType, {dynamic args}) {
    final config = RoutesRegistry.instance.getScreenConfigByType(screenType);
    if (config == null) {
      throw ArgumentError('No screen configuration found for $screenType');
    }

    final routeName = config.path ??
        '/${screenType.toString().substring(0, 1).toLowerCase()}${screenType.toString().substring(1)}';

    return Navigator.of(this).pushNamed(routeName, arguments: args);
  }

  /// Replace the current screen
  Future<T?> pushReplacement<T, TO>(Type screenType, {dynamic args}) {
    final config = RoutesRegistry.instance.getScreenConfigByType(screenType);
    if (config == null) {
      throw ArgumentError('No screen configuration found for $screenType');
    }

    final routeName = config.path ??
        '/${screenType.toString().substring(0, 1).toLowerCase()}${screenType.toString().substring(1)}';

    return Navigator.of(this).pushReplacementNamed(routeName, arguments: args);
  }

  /// Clear the stack and navigate
  Future<T?> pushAndRemoveUntil<T>(Type screenType, {dynamic args}) {
    final config = RoutesRegistry.instance.getScreenConfigByType(screenType);
    if (config == null) {
      throw ArgumentError('No screen configuration found for $screenType');
    }

    final routeName = config.path ??
        '/${screenType.toString().substring(0, 1).toLowerCase()}${screenType.toString().substring(1)}';

    return Navigator.of(this).pushNamedAndRemoveUntil(
      routeName,
      (route) => false,
      arguments: args,
    );
  }

  /// Navigate to a nested route
  Future<T?> pushNested<T>(Type screenType, String nestedRoute,
      {dynamic args}) {
    final config = RoutesRegistry.instance.getScreenConfigByType(screenType);
    if (config == null) {
      throw ArgumentError('No screen configuration found for $screenType');
    }

    final routeName = config.path ??
        '/${screenType.toString().substring(0, 1).toLowerCase()}${screenType.toString().substring(1)}';

    // Ensure nestedRoute starts with a slash
    final formattedNestedRoute =
        nestedRoute.startsWith('/') ? nestedRoute : '/$nestedRoute';

    return Navigator.of(this).pushNamed(
      '$routeName$formattedNestedRoute',
      arguments: args,
    );
  }

  /// Go back
  void pop<T>([T? result]) {
    Navigator.of(this).pop(result);
  }
}
