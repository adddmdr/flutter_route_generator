import 'package:flutter/material.dart';
import 'package:flutter_route_generator/flutter_route_generator.dart';

/// Configuration for a fallback route
class FallbackRouteConfig {
  /// The builder function for creating the fallback screen
  final Widget Function(BuildContext context, String? routeName) builder;

  /// Optional transition builder for custom animations
  final RouteTransitionsBuilder? transitionsBuilder;

  /// Whether to maintain the state of the fallback screen when navigating away
  final bool maintainState;

  /// Constructor for fallback route configuration
  const FallbackRouteConfig({
    required this.builder,
    this.transitionsBuilder,
    this.maintainState = true,
  });
}

/// A central class for route management
class Routes {
  static RouteConfig routeConfig = RouteConfig([]);
  static FallbackRouteConfig? _fallbackRouteConfig;

  /// Initialize routes with screen configurations and an optional fallback route
  static Future<void> initialize(
    List<ScreenConfig> screenConfigs, {
    FallbackRouteConfig? fallbackRouteConfig,
  }) async {
    routeConfig = RouteConfig(screenConfigs);
    _fallbackRouteConfig = fallbackRouteConfig;
  }

  /// Get the fallback route configuration
  static FallbackRouteConfig? get fallbackRouteConfig => _fallbackRouteConfig;

  /// Create a fallback route for unknown routes
  static Route<dynamic> createFallbackRoute(RouteSettings settings) {
    if (_fallbackRouteConfig?.transitionsBuilder != null) {
      return PageRouteBuilder(
        settings: settings,
        maintainState: _fallbackRouteConfig!.maintainState,
        pageBuilder: (context, _, __) => _fallbackRouteConfig!.builder(
          context,
          settings.name,
        ),
        transitionsBuilder: _fallbackRouteConfig!.transitionsBuilder!,
      );
    }

    return MaterialPageRoute(
      settings: settings,
      maintainState: _fallbackRouteConfig?.maintainState ?? true,
      builder: (context) =>
          _fallbackRouteConfig?.builder(
            context,
            settings.name,
          ) ??
          _defaultNotFoundScreen(context, settings.name),
    );
  }

  /// Default not found screen if no fallback is provided
  static Widget _defaultNotFoundScreen(
      BuildContext context, String? routeName) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Page Not Found'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              'Route "$routeName" not found',
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Go Back'),
            ),
          ],
        ),
      ),
    );
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
