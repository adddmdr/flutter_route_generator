import 'package:flutter/material.dart';
import 'screen_config.dart';

/// Configuration for fallback routes (404 pages)
class FallbackRouteConfig {
  /// Builder function for the fallback route
  final Widget Function(BuildContext, String?) builder;

  /// Custom transition builder
  final Widget Function(
          BuildContext, Animation<double>, Animation<double>, Widget)?
      transitionsBuilder;

  /// Whether to maintain state when navigating away
  final bool maintainState;

  /// Create a fallback route configuration
  const FallbackRouteConfig({
    required this.builder,
    this.transitionsBuilder,
    this.maintainState = true,
  });
}

/// Main route configuration class
class RouteConfig {
  /// List of all screen configurations
  final List<ScreenConfig> screenConfigs;

  /// Fallback route configuration
  final FallbackRouteConfig? fallbackRouteConfig;

  /// Create a route configuration
  RouteConfig({
    required this.screenConfigs,
    this.fallbackRouteConfig,
  });

  /// Get the initial screen configuration
  ScreenConfig? getInitialScreenConfig() {
    for (final config in screenConfigs) {
      if (config.isInitial) {
        return config;
      }
    }
    return null;
  }

  /// Get a screen configuration by type
  ScreenConfig? getScreenConfigByType(Type type) {
    for (final config in screenConfigs) {
      if (config.screenType == type) {
        return config;
      }
    }
    return null;
  }

  /// Get a screen configuration by path
  ScreenConfig? getScreenConfigByPath(String path) {
    // Extract the parent path (everything before the second slash)
    String parentPath = path;
    if (path.startsWith('/') && path.substring(1).contains('/')) {
      final secondSlashIndex = path.indexOf('/', 1);
      if (secondSlashIndex != -1) {
        parentPath = path.substring(0, secondSlashIndex);
      }
    }

    for (final config in screenConfigs) {
      final configPath = config.path ??
          '/${config.screenType.toString().substring(0, 1).toLowerCase()}${config.screenType.toString().substring(1)}';

      if (configPath == parentPath) {
        return config;
      }
    }
    return null;
  }
}
