import 'package:flutter/material.dart';
import 'package:flutter_route_generator/src/transitions/transitions.dart';
import 'src/models/route_config.dart';
import 'src/models/screen_config.dart';
import 'src/router/routes_map.dart';

/// Main routes class for the application
class Routes {
  static bool _initialized = false;

  /// Initialize the routes with screen configurations
  static Future<void> initialize(
    List<ScreenConfig> screenConfigs, {
    FallbackRouteConfig? fallbackRouteConfig,
    Map<
            String,
            Widget Function(
                BuildContext, Animation<double>, Animation<double>, Widget)>?
        customTransitions,
  }) async {
    if (!_initialized) {
      // Initialize predefined transitions
      initializePredefinedTransitions();

      // Register any custom transitions
      if (customTransitions != null) {
        for (final entry in customTransitions.entries) {
          TransitionsRegistry.register(entry.key, entry.value);
        }
      }

      _initialized = true;
    }

    RoutesRegistry.initialize(
      screenConfigs,
      fallbackRouteConfig: fallbackRouteConfig,
    );
  }

  /// Initialize predefined transitions
  static void initializePredefinedTransitions() {
    // Initialize the transitions registry with predefined transitions
    TransitionsRegistry.initialize();
  }

  /// Create a fallback route for unknown routes
  static Route<dynamic> createFallbackRoute(RouteSettings settings) {
    return MaterialPageRoute(
      settings: settings,
      builder: (context) => Scaffold(
        appBar: AppBar(title: const Text('Not Found')),
        body: Center(
          child: Text('Route "${settings.name}" not found'),
        ),
      ),
    );
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

  /// Go back
  void pop<T>([T? result]) {
    Navigator.of(this).pop(result);
  }
}
