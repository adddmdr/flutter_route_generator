import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';
import 'route_generator_builder.dart';

Builder routeGeneratorFactory(BuilderOptions options) =>
    SharedPartBuilder([RouteGeneratorBuilder()], 'route_generator');
