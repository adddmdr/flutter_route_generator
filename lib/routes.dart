import 'package:flutter_route_generator/flutter_route_generator.dart';

class Routes {
  static RouteConfig routeConfig = RouteConfig([]);

  static Future<void> initialize(List<ScreenConfig> screenConfigs) async {
    routeConfig = RouteConfig(screenConfigs);
  }

  static T? getArgs<T>(dynamic arguments) {
    if (arguments != null && arguments is T) {
      return arguments as T;
    }
    return null;
  }

  static Never navigatorError() {
    throw Exception('Navigator extension called with no navigator available');
  }
}

// Extension methods for navigation
extension NavigationExtension on dynamic {
  push(Type screenType, {dynamic args}) {
    if (this == null) Routes.navigatorError();
    Routes.routeConfig.push(this, screenType, args: args);
  }

  pushReplacement(Type screenType, {dynamic args}) {
    if (this == null) Routes.navigatorError();
    Routes.routeConfig.pushReplacement(this, screenType, args: args);
  }

  pushAndRemoveUntil(Type screenType, {dynamic args}) {
    if (this == null) Routes.navigatorError();
    Routes.routeConfig.pushAndRemoveUntil(this, screenType, args: args);
  }

  pop<T>([T? result]) {
    if (this == null) Routes.navigatorError();
    Routes.routeConfig.pop(this, result);
  }
}
