import 'package:flutter/material.dart';
import '../models/route_config.dart';
import '../models/screen_config.dart';
import '../router/routes_map.dart';

/// Utility class for building routes
class RouteBuilder {
  /// Create a route for a screen configuration
  static Route<dynamic> buildRoute(
    ScreenConfig config,
    RouteSettings settings,
    dynamic arguments,
  ) {
    // Extract parent route and potential subroute
    String? subRoute;
    final routeName = settings.name!;

    // Check if this is a subroute (contains more than one slash after the first)
    if (routeName.startsWith('/') && routeName.substring(1).contains('/')) {
      final secondSlashIndex = routeName.indexOf('/', 1);
      if (secondSlashIndex != -1) {
        subRoute = routeName.substring(secondSlashIndex);
      }
    }

    // Use custom transition if provided, otherwise use MaterialPageRoute
    if (config.transitionsBuilder != null) {
      return PageRouteBuilder(
        settings: settings,
        pageBuilder: (context, animation, secondaryAnimation) {
          return _buildScreenWidget(config, arguments, subRoute);
        },
        transitionsBuilder: config.transitionsBuilder!,
      );
    }

    return MaterialPageRoute(
      settings: settings,
      builder: (context) => _buildScreenWidget(config, arguments, subRoute),
    );
  }

  /// Build the screen widget with the correct arguments
  static Widget _buildScreenWidget(
    ScreenConfig config,
    dynamic arguments,
    String? subRoute,
  ) {
    final screenType = config.screenType;

    // This implementation will be replaced by code generation
    // For now, return a placeholder widget
    return Scaffold(
      appBar: AppBar(title: Text(screenType.toString())),
      body: Center(
        child: Text(
            'Screen: ${screenType.toString()}\nArguments: $arguments\nSubroute: $subRoute'),
      ),
    );
  }

  /// Navigate to a screen
  static Future<T?> push<T>(BuildContext context, Type screenType,
      {dynamic args}) {
    final routesInstance = RoutesRegistry.instance;
    final config = routesInstance.getScreenConfigByType(screenType);
    if (config == null) {
      throw ArgumentError('No screen configuration found for $screenType');
    }

    final routeName = config.path ??
        '/${screenType.toString().substring(0, 1).toLowerCase()}${screenType.toString().substring(1)}';

    return Navigator.of(context).pushNamed(routeName, arguments: args);
  }

  /// Replace the current screen
  static Future<T?> pushReplacement<T, TO>(
      BuildContext context, Type screenType,
      {dynamic args}) {
    final routesInstance = RoutesRegistry.instance;
    final config = routesInstance.getScreenConfigByType(screenType);
    if (config == null) {
      throw ArgumentError('No screen configuration found for $screenType');
    }

    final routeName = config.path ??
        '/${screenType.toString().substring(0, 1).toLowerCase()}${screenType.toString().substring(1)}';

    return Navigator.of(context)
        .pushReplacementNamed(routeName, arguments: args);
  }

  /// Clear the stack and navigate
  static Future<T?> pushAndRemoveUntil<T>(BuildContext context, Type screenType,
      {dynamic args}) {
    final routesInstance = RoutesRegistry.instance;
    final config = routesInstance.getScreenConfigByType(screenType);
    if (config == null) {
      throw ArgumentError('No screen configuration found for $screenType');
    }

    final routeName = config.path ??
        '/${screenType.toString().substring(0, 1).toLowerCase()}${screenType.toString().substring(1)}';

    return Navigator.of(context).pushNamedAndRemoveUntil(
      routeName,
      (route) => false,
      arguments: args,
    );
  }

  /// Go back
  static void pop<T>(BuildContext context, [T? result]) {
    Navigator.of(context).pop(result);
  }
}
