import 'package:flutter/material.dart';
import '../models/screen_config.dart';
import '../router/routes_map.dart';
import '../transitions/transitions.dart'; // Add this import

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

    // Check if this screen has a named transition
    if (config.transition != null) {
      // Get transition from registry
      final transitionBuilder =
          TransitionsRegistry.get(config.transition!.name);
      if (transitionBuilder != null) {
        return PageRouteBuilder(
          settings: settings,
          pageBuilder: (context, animation, secondaryAnimation) {
            return _buildScreenWidget(config, arguments, subRoute);
          },
          transitionsBuilder: transitionBuilder,
        );
      }
    }

    // Fall back to MaterialPageRoute if no transition specified or found
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

    // Check if this is a screen with subroutes
    if (subRoute != null &&
        config.subroutes != null &&
        config.subroutes!.isNotEmpty) {
      // Try to create a widget with initialSubRoute parameter
      try {
        // This is a simplified approach - in a real implementation,
        // you would use code generation to create the widget
        final widget =
            _createWidgetWithSubroute(screenType, arguments, subRoute);
        if (widget != null) {
          return widget;
        }
      } catch (_) {
        // Fall back to regular widget creation if subroute handling fails
      }
    }

    // Create a regular widget with arguments
    return _createWidget(screenType, arguments);
  }

  /// Create a widget with arguments
  static Widget _createWidget(Type type, dynamic arguments) {
    // This is a simplified version - in a real implementation,
    // you would use code generation
    return Scaffold(
      appBar: AppBar(title: Text(type.toString())),
      body: Center(
        child: Text('Screen: ${type.toString()}\nArguments: $arguments'),
      ),
    );
  }

  /// Create a widget with subroute
  static Widget? _createWidgetWithSubroute(
      Type type, dynamic arguments, String subRoute) {
    // This is a simplified version - in a real implementation,
    // you would use code generation
    return Scaffold(
      appBar: AppBar(title: Text(type.toString())),
      body: Center(
        child: Text(
            'Screen: ${type.toString()}\nArguments: $arguments\nSubroute: $subRoute'),
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

    String routeName;
    if (config.isInitial) {
      routeName = '/'; // Initial screen is always root path
    } else {
      routeName = config.path ??
          '/${screenType.toString().substring(0, 1).toLowerCase()}${screenType.toString().substring(1)}';
    }

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

    String routeName;
    if (config.isInitial) {
      routeName = '/'; // Initial screen is always root path
    } else {
      routeName = config.path ??
          '/${screenType.toString().substring(0, 1).toLowerCase()}${screenType.toString().substring(1)}';
    }

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

    String routeName;
    if (config.isInitial) {
      routeName = '/'; // Initial screen is always root path
    } else {
      routeName = config.path ??
          '/${screenType.toString().substring(0, 1).toLowerCase()}${screenType.toString().substring(1)}';
    }

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
