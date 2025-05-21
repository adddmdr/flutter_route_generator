// lib/route_config_annotation.dart
class RouteConfig {
  const RouteConfig();
}

/// This annotation will mark the class that contains route configurations
const routeConfig = RouteConfig();

/// Annotation for specifying a transition by name
class TransitionName {
  final String name;
  const TransitionName(this.name);
}

/// Common transitions that can be used by name
class CommonTransitions {
  /// Fade transition
  static const fade = TransitionName('fade');

  /// Slide from right transition
  static const slideRight = TransitionName('slideRight');

  /// Slide from bottom transition
  static const slideUp = TransitionName('slideUp');

  /// Scale transition
  static const scale = TransitionName('scale');
}
