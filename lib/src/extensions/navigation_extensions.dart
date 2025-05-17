import 'package:flutter/material.dart';
import 'package:flutter_route_generator/flutter_route_generator.dart';

extension NavigationExtension on BuildContext {
  void push(Type screenType, {dynamic args}) {
    RouteBuilder.push(this, screenType, args: args);
  }

  void pushReplacement(Type screenType, {dynamic args}) {
    RouteBuilder.pushReplacement(this, screenType, args: args);
  }

  void pushAndRemoveUntil(Type screenType, {dynamic args}) {
    RouteBuilder.pushAndRemoveUntil(this, screenType, args: args);
  }

  void pop<T>([T? result]) {
    RouteBuilder.pop<T>(this, result);
  }
}
