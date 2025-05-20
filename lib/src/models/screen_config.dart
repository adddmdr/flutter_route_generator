import 'package:flutter/material.dart';

/// Configuration for a screen in the application
class ScreenConfig {
  /// The type of the screen widget
  final Type screenType;

  /// The type of arguments this screen accepts (optional)
  final Type? argsType;

  /// Custom route path (defaults to lowercase screen name)
  final String? path;

  /// Whether this is the initial screen of the app
  final bool isInitial;

  /// Whether arguments are required for this screen
  final bool requiresArgs;

  /// List of subroutes for this screen (for nested navigation)
  final List<ScreenConfig>? subroutes;

  /// Custom transition builder for this route
  final Widget Function(
          BuildContext, Animation<double>, Animation<double>, Widget)?
      transitionsBuilder;

  /// Create a screen configuration
  const ScreenConfig({
    required this.screenType,
    this.argsType,
    this.path,
    this.isInitial = false,
    this.requiresArgs = false,
    this.subroutes,
    this.transitionsBuilder,
  });
}
