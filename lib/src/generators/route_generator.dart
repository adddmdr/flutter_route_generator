import 'package:flutter_route_generator/flutter_route_generator.dart';

class RouteGenerator {
  // This class will be extended by the build_runner generated code to handle
  // the route generation, it will include the dynamic loading of screens based on
  // route names and handle passing arguments to screens
  static final RouteGenerator _instance = RouteGenerator._internal();

  factory RouteGenerator() {
    return _instance;
  }

  RouteGenerator._internal();

  // Placeholder method that will be implemented by the generated code
  static String generateRoutes(List<ScreenConfig> screenConfigs) {
    throw UnimplementedError(
        'RouteGenerator.generateRoutes is not implemented - run build_runner to generate implementation');
  }
}
