import 'package:flutter/material.dart';
import '../models/screen_config.dart';
import '../models/route_config.dart';

/// Class for type-safe access to routes.
class RoutesRegistry {
  static RoutesRegistry? _instance;

  /// Get the singleton instance
  static RoutesRegistry get instance {
    if (_instance == null) {
      throw StateError(
          'RoutesRegistry not initialized. Call RoutesRegistry.initialize() first.');
    }
    return _instance!;
  }

  final Map<Type, ScreenConfig> _routes;
  final FallbackRouteConfig? _fallbackRouteConfig;

  /// Private constructor for RoutesRegistry.
  RoutesRegistry._(this._routes, this._fallbackRouteConfig);

  /// Initialize the routes registry with screen configurations.
  ///
  /// [screenConfigs] - List of screen configurations.
  /// [fallbackRouteConfig] - Optional configuration for fallback routes.
  ///
  /// Returns the initialized RoutesRegistry instance.
  static RoutesRegistry initialize(
    List<ScreenConfig> screenConfigs, {
    FallbackRouteConfig? fallbackRouteConfig,
  }) {
    final routes = <Type, ScreenConfig>{};
    for (final config in screenConfigs) {
      routes[config.screenType] = config;
    }

    _instance = RoutesRegistry._(routes, fallbackRouteConfig);
    return _instance!;
  }

  /// Get the screen configuration for a screen type.
  ///
  /// [screenType] - The type of the screen to get the configuration for.
  ///
  /// Returns the screen configuration for the screen type, or null if not found.
  ScreenConfig? getScreenConfigByType(Type screenType) {
    return _routes[screenType];
  }

  /// Get the initial screen configuration.
  ///
  /// Returns the initial screen configuration, or null if not found.
  ScreenConfig? getInitialScreenConfig() {
    for (final config in _routes.values) {
      if (config.isInitial) {
        return config;
      }
    }
    return null;
  }

  /// Get all registered screen types.
  ///
  /// Returns a list of all registered screen types.
  List<Type> getAllScreenTypes() {
    return _routes.keys.toList();
  }

  /// Get the path for a screen type.
  ///
  /// [screenType] - The type of the screen to get the path for.
  ///
  /// Returns the path for the screen type, or null if not found.
  String? getPathForScreenType(Type screenType) {
    final config = _routes[screenType];
    if (config == null) {
      return null;
    }

    return config.path ??
        '/${screenType.toString().substring(0, 1).toLowerCase()}${screenType.toString().substring(1)}';
  }

  /// Create a fallback route for unknown routes
  Route<dynamic> createFallbackRoute(RouteSettings settings) {
    if (_fallbackRouteConfig == null) {
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

    // Use the provided fallback configuration
    if (_fallbackRouteConfig!.transitionsBuilder != null) {
      return PageRouteBuilder(
        settings: settings,
        pageBuilder: (context, animation, secondaryAnimation) {
          return _fallbackRouteConfig!.builder(context, settings.name);
        },
        transitionsBuilder: _fallbackRouteConfig!.transitionsBuilder!,
        maintainState: _fallbackRouteConfig!.maintainState,
      );
    }

    return MaterialPageRoute(
      settings: settings,
      builder: (context) =>
          _fallbackRouteConfig!.builder(context, settings.name),
      maintainState: _fallbackRouteConfig!.maintainState,
    );
  }
}
