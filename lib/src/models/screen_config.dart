import 'package:flutter_route_generator/route_config_annotation.dart';

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

  /// Custom transition for this route
  final TransitionName? transition;

  // Removed transitionsBuilder since it's not const-compatible

  /// Create a screen configuration
  const ScreenConfig({
    required this.screenType,
    this.argsType,
    this.path,
    this.isInitial = false,
    this.requiresArgs = false,
    this.subroutes,
    this.transition,
  });
}
