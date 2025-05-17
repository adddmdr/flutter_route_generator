// lib/src/models/route_config.dart
import 'package:flutter/material.dart';
import 'screen_config.dart';
import '../builders/route_builder.dart';

class RouteConfig {
  final List<ScreenConfig> screenConfigs;

  RouteConfig(this.screenConfigs);

  ScreenConfig? getScreenConfigByType(Type screenType) {
    try {
      return screenConfigs
          .firstWhere((config) => config.screenType == screenType);
    } catch (e) {
      throw Exception('Screen $screenType not found in route configurations');
    }
  }

  ScreenConfig? getInitialScreenConfig() {
    try {
      return screenConfigs.firstWhere((config) => config.isInitial);
    } catch (e) {
      if (screenConfigs.isNotEmpty) {
        return screenConfigs.first;
      }
      throw Exception('No initial screen defined in route configurations');
    }
  }

  void push(BuildContext context, Type screenType, {dynamic args}) {
    final screenConfig = getScreenConfigByType(screenType);
    if (screenConfig != null) {
      // Fixed: Pass Type (screenType) instead of ScreenConfig
      RouteBuilder.push(context, screenType, args: args);
    }
  }

  void pushReplacement(BuildContext context, Type screenType, {dynamic args}) {
    final screenConfig = getScreenConfigByType(screenType);
    if (screenConfig != null) {
      // Fixed: Pass Type (screenType) instead of ScreenConfig
      RouteBuilder.pushReplacement(context, screenType, args: args);
    }
  }

  void pushAndRemoveUntil(BuildContext context, Type screenType,
      {dynamic args}) {
    final screenConfig = getScreenConfigByType(screenType);
    if (screenConfig != null) {
      // Fixed: Pass Type (screenType) instead of ScreenConfig
      RouteBuilder.pushAndRemoveUntil(context, screenType, args: args);
    }
  }

  void pop<T>(BuildContext context, [T? result]) {
    RouteBuilder.pop(context, result);
  }
}
