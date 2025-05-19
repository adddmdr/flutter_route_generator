import 'package:build/build.dart';
import 'package:flutter_route_generator/src/builders/registry_generator_builder.dart';
import 'package:flutter_route_generator/src/builders/route_generator_builder.dart';

/// Route generator builder factory
Builder routeGeneratorFactory(BuilderOptions options) {
  return RouteGeneratorBuilder();
}

/// Registry generator builder factory
Builder registryGeneratorFactory(BuilderOptions options) {
  return RegistryGeneratorBuilder();
}
