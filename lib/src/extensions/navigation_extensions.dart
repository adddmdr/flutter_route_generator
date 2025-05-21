import 'package:flutter/material.dart';
import 'package:flutter_route_generator/flutter_route_generator.dart';
import 'package:flutter_route_generator/routes.dart';

extension NavigationExtension on BuildContext {
  Future<T?> push<T>(Type screenType, {dynamic args}) {
    final config = Routes.routeConfig.getScreenConfigByType(screenType);
    if (config == null) {
      throw ArgumentError('No screen configuration found for $screenType');
    }

    // Get the correct path for this screen type
    // For initial screens, use '/' instead of the derived path
    final routeName = _getRouteName(config);

    return Navigator.of(this).pushNamed(routeName, arguments: args);
  }

  Future<T?> pushReplacement<T, TO>(Type screenType, {dynamic args}) {
    final config = Routes.routeConfig.getScreenConfigByType(screenType);
    if (config == null) {
      throw ArgumentError('No screen configuration found for $screenType');
    }

    // Get the correct path for this screen type
    // For initial screens, use '/' instead of the derived path
    final routeName = _getRouteName(config);

    return Navigator.of(this).pushReplacementNamed(routeName, arguments: args);
  }

  Future<T?> pushAndRemoveUntil<T>(Type screenType, {dynamic args}) {
    final config = Routes.routeConfig.getScreenConfigByType(screenType);
    if (config == null) {
      throw ArgumentError('No screen configuration found for $screenType');
    }

    // Get the correct path for this screen type
    // For initial screens, use '/' instead of the derived path
    final routeName = _getRouteName(config);

    return Navigator.of(this).pushNamedAndRemoveUntil(
      routeName,
      (route) => false,
      arguments: args,
    );
  }

  void pop<T>([T? result]) {
    Navigator.of(this).pop(result);
  }

  // Helper method to get the route name for a screen config
  String _getRouteName(ScreenConfig config) {
    if (config.isInitial) {
      return '/'; // Initial screen always gets the root path
    } else {
      return config.path ??
          '/${config.screenType.toString().substring(0, 1).toLowerCase()}${config.screenType.toString().substring(1)}';
    }
  }
}
