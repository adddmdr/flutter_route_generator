import 'package:flutter/material.dart';
import 'package:flutter_route_generator/routes.dart';

extension NavigationExtension on BuildContext {
  Future<T?> push<T>(Type screenType, {dynamic args}) {
    final config = Routes.routeConfig.getScreenConfigByType(screenType);
    if (config == null) {
      throw ArgumentError('No screen configuration found for $screenType');
    }

    // Get the correct path based on the config
    String routeName;
    if (config.isInitial) {
      routeName = '/'; // Handle initial screen specially - always '/'
    } else {
      routeName = config.path ??
          '/${screenType.toString().substring(0, 1).toLowerCase()}${screenType.toString().substring(1)}';
    }

    return Navigator.of(this).pushNamed(routeName, arguments: args);
  }

  Future<T?> pushReplacement<T, TO>(Type screenType, {dynamic args}) {
    final config = Routes.routeConfig.getScreenConfigByType(screenType);
    if (config == null) {
      throw ArgumentError('No screen configuration found for $screenType');
    }

    // Get the correct path based on the config
    String routeName;
    if (config.isInitial) {
      routeName = '/'; // Handle initial screen specially - always '/'
    } else {
      routeName = config.path ??
          '/${screenType.toString().substring(0, 1).toLowerCase()}${screenType.toString().substring(1)}';
    }

    return Navigator.of(this).pushReplacementNamed(routeName, arguments: args);
  }

  Future<T?> pushAndRemoveUntil<T>(Type screenType, {dynamic args}) {
    final config = Routes.routeConfig.getScreenConfigByType(screenType);
    if (config == null) {
      throw ArgumentError('No screen configuration found for $screenType');
    }

    // Get the correct path based on the config
    String routeName;
    if (config.isInitial) {
      routeName = '/'; // Handle initial screen specially - always '/'
    } else {
      routeName = config.path ??
          '/${screenType.toString().substring(0, 1).toLowerCase()}${screenType.toString().substring(1)}';
    }

    return Navigator.of(this).pushNamedAndRemoveUntil(
      routeName,
      (route) => false,
      arguments: args,
    );
  }

  void pop<T>([T? result]) {
    Navigator.of(this).pop(result);
  }
}
