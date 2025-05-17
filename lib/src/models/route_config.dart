import 'package:flutter_route_generator/flutter_route_generator.dart';
import 'package:flutter_route_generator/src/models/screen_config.dart';

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

  void push(dynamic context, Type screenType, {dynamic args}) {
    final screenConfig = getScreenConfigByType(screenType);
    if (screenConfig != null) {
      RouteBuilder.push(context, screenConfig, args);
    }
  }

  void pushReplacement(dynamic context, Type screenType, {dynamic args}) {
    final screenConfig = getScreenConfigByType(screenType);
    if (screenConfig != null) {
      RouteBuilder.pushReplacement(context, screenConfig, args);
    }
  }

  void pushAndRemoveUntil(dynamic context, Type screenType, {dynamic args}) {
    final screenConfig = getScreenConfigByType(screenType);
    if (screenConfig != null) {
      RouteBuilder.pushAndRemoveUntil(context, screenConfig, args);
    }
  }

  void pop<T>(dynamic context, [T? result]) {
    RouteBuilder.pop(context, result);
  }
}
