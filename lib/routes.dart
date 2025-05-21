import 'package:flutter/material.dart';
import 'package:flutter_route_generator/flutter_route_generator.dart';

class Routes {
  static RouteConfig? _routeConfig;

  static RouteConfig get routeConfig {
    if (_routeConfig == null) {
      throw StateError(
          'Routes not initialized. Call Routes.initialize() first.');
    }
    return _routeConfig!;
  }

  static void initialize(
    List<ScreenConfig> screenConfigs, {
    FallbackRouteConfig? fallbackRouteConfig,
  }) {
    _routeConfig = RouteConfig(
      screenConfigs: screenConfigs,
      fallbackRouteConfig: fallbackRouteConfig,
    );
  }

  static Route<dynamic> createFallbackRoute(RouteSettings settings) {
    if (_routeConfig?.fallbackRouteConfig != null) {
      return PageRouteBuilder(
        settings: settings,
        pageBuilder: (context, animation, secondaryAnimation) {
          return _routeConfig!.fallbackRouteConfig!
              .builder(context, settings.name);
        },
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
