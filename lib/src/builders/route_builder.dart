import 'package:flutter/material.dart';
import '../models/screen_config.dart';

class RouteBuilder {
  // This method will be implemented by the generated code
  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    throw UnimplementedError(
        'RouteBuilder.onGenerateRoute is not implemented - run build_runner to generate implementation');
  }

  // All navigation methods now consistently use Type instead of ScreenConfig
  static void push(BuildContext context, Type screenType, {dynamic args}) {
    throw UnimplementedError(
        'RouteBuilder.push is not implemented - run build_runner to generate implementation');
  }

  static void pushReplacement(BuildContext context, Type screenType,
      {dynamic args}) {
    throw UnimplementedError(
        'RouteBuilder.pushReplacement is not implemented - run build_runner to generate implementation');
  }

  static void pushAndRemoveUntil(BuildContext context, Type screenType,
      {dynamic args}) {
    throw UnimplementedError(
        'RouteBuilder.pushAndRemoveUntil is not implemented - run build_runner to generate implementation');
  }

  static void pop<T>(BuildContext context, [T? result]) {
    throw UnimplementedError(
        'RouteBuilder.pop is not implemented - run build_runner to generate implementation');
  }
}
