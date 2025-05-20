import 'package:flutter/material.dart';
import '../models/screen_config.dart';
import '../models/route_config.dart';
import '../generators/route_generator.dart';
import 'routes_map.dart';

/// Central router class for the application.
class AppRouter {
  static RouteGenerator? _instance;

  /// Configure the router with screen configurations.
  ///
  /// [screenConfigs] - List of screen configurations.
  ///
  /// Returns the configured RouteGenerator instance.
  static RouteGenerator configure(List<ScreenConfig> screenConfigs,
      {FallbackRouteConfig? fallbackRouteConfig}) {
    final routeGenerator = RouteGenerator();
    _instance = routeGenerator;

    // Initialize the routes registry
    RoutesRegistry.initialize(
      screenConfigs,
      fallbackRouteConfig: fallbackRouteConfig,
    );

    return routeGenerator;
  }

  /// Get the path for a screen type.
  ///
  /// [screenType] - The type of the screen to get the path for.
  ///
  /// Returns the path for the screen type.
  static String pathFor(Type screenType) {
    final config = RoutesRegistry.instance.getScreenConfigByType(screenType);
    if (config == null) {
      throw Exception('No route found for screen type: $screenType');
    }

    return config.path ??
        '/${screenType.toString().substring(0, 1).toLowerCase()}${screenType.toString().substring(1)}';
  }

  /// Generate a route for the given route settings.
  ///
  /// [settings] - The route settings.
  ///
  /// Returns a route for the given settings.
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    if (_instance == null) {
      throw Exception(
          'AppRouter not configured. Call AppRouter.configure() first.');
    }

    try {
      // Try to find a matching route in the registered screen configs
      final routesRegistry = RoutesRegistry.instance;

      // Get all registered screen types
      final screenTypes = routesRegistry.getAllScreenTypes();

      for (final screenType in screenTypes) {
        final config = routesRegistry.getScreenConfigByType(screenType);
        if (config == null) continue;

        final routePath = config.path ??
            '/${screenType.toString().substring(0, 1).toLowerCase()}${screenType.toString().substring(1)}';

        if (settings.name == routePath ||
            (settings.name != null &&
                settings.name!.startsWith('$routePath/'))) {
          // Use custom transition if provided
          if (config.transitionsBuilder != null) {
            return PageRouteBuilder(
              settings: settings,
              pageBuilder: (context, animation, secondaryAnimation) {
                // Handle potential subroute
                String? subRoute;
                if (settings.name != null &&
                    settings.name != routePath &&
                    settings.name!.startsWith('$routePath/')) {
                  subRoute = settings.name!.substring(routePath.length);
                }

                // Create the screen with appropriate arguments
                if (subRoute != null && config.subroutes != null) {
                  // Screen with subroute
                  return _createWidgetWithSubroute(
                      config.screenType, settings.arguments, subRoute);
                } else {
                  // Regular screen
                  return _createWidget(config.screenType, settings.arguments);
                }
              },
              transitionsBuilder: config.transitionsBuilder!,
            );
          }

          return MaterialPageRoute(
            settings: settings,
            builder: (context) {
              // Handle potential subroute
              String? subRoute;
              if (settings.name != null &&
                  settings.name != routePath &&
                  settings.name!.startsWith('$routePath/')) {
                subRoute = settings.name!.substring(routePath.length);
              }

              // Create the screen with appropriate arguments
              if (subRoute != null && config.subroutes != null) {
                // Screen with subroute
                return _createWidgetWithSubroute(
                    config.screenType, settings.arguments, subRoute);
              } else {
                // Regular screen
                return _createWidget(config.screenType, settings.arguments);
              }
            },
          );
        }
      }

      // No matching route found, use fallback
      return routesRegistry.createFallbackRoute(settings);
    } catch (e) {
      // Return a default "not found" route
      return MaterialPageRoute(
        settings: settings,
        builder: (context) => Scaffold(
          appBar: AppBar(title: const Text('Not Found')),
          body: Center(child: Text('Route error: ${e.toString()}')),
        ),
      );
    }
  }

  // Helper method to create a widget with arguments
  static Widget _createWidget(Type type, dynamic arguments) {
    // This is a simplified version - in a real implementation,
    // you would use reflection or code generation
    return Scaffold(
      appBar: AppBar(title: Text(type.toString())),
      body: Center(
        child: Text('Screen: ${type.toString()}\nArguments: $arguments'),
      ),
    );
  }

  // Helper method to create a widget with subroute
  static Widget _createWidgetWithSubroute(
      Type type, dynamic arguments, String subRoute) {
    // This is a simplified version - in a real implementation,
    // you would use reflection or code generation
    return Scaffold(
      appBar: AppBar(title: Text(type.toString())),
      body: Center(
        child: Text(
            'Screen: ${type.toString()}\nArguments: $arguments\nSubroute: $subRoute'),
      ),
    );
  }
}
