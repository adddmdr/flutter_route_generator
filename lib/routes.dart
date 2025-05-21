import 'package:flutter/material.dart';
import 'package:flutter_route_generator/flutter_route_generator.dart';

/// Central routing class for the application
class Routes {
  static RouteConfig? _routeConfig;

  static RouteConfig get routeConfig {
    if (_routeConfig == null) {
      throw StateError(
          'Routes not initialized. Call Routes.initialize() first.');
    }
    return _routeConfig!;
  }

  /// Initialize the routing system with the given screen configurations
  ///
  /// This also initializes the TransitionsRegistry automatically
  static void initialize(
    List<ScreenConfig> screenConfigs, {
    FallbackRouteConfig? fallbackRouteConfig,
  }) {
    // Initialize the transitions registry automatically
    TransitionsRegistry.initialize();

    // Set up the route configuration
    _routeConfig = RouteConfig(
      screenConfigs: screenConfigs,
      fallbackRouteConfig: fallbackRouteConfig,
    );
  }

  /// Create a fallback route for when no matching route is found
  static Route<dynamic> createFallbackRoute(RouteSettings settings) {
    if (_routeConfig?.fallbackRouteConfig != null) {
      // Use the custom fallback if provided
      final fallbackConfig = _routeConfig!.fallbackRouteConfig!;

      if (fallbackConfig.transitionsBuilder != null) {
        return PageRouteBuilder(
          settings: settings,
          pageBuilder: (context, animation, secondaryAnimation) {
            return fallbackConfig.builder(context, settings.name);
          },
          transitionsBuilder: fallbackConfig.transitionsBuilder!,
          maintainState: fallbackConfig.maintainState,
        );
      }

      return MaterialPageRoute(
        settings: settings,
        builder: (context) => fallbackConfig.builder(context, settings.name),
        maintainState: fallbackConfig.maintainState,
      );
    }

    // Default fallback if none provided
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
}
