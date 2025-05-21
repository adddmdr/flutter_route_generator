import 'package:flutter/material.dart';

/// Registry of transitions that can be referenced by name
class TransitionsRegistry {
  static final Map<
          String,
          Widget Function(
              BuildContext, Animation<double>, Animation<double>, Widget)>
      _transitions = {};

  /// Register a transition with a name
  static void register(
      String name,
      Widget Function(
              BuildContext, Animation<double>, Animation<double>, Widget)
          transition) {
    _transitions[name] = transition;
  }

  /// Get a transition by name
  static Widget Function(
          BuildContext, Animation<double>, Animation<double>, Widget)?
      get(String name) {
    return _transitions[name];
  }

  /// Initialize predefined transitions
  static void initialize() {
    // Fade transition
    register('fade', (context, animation, secondaryAnimation, child) {
      return FadeTransition(opacity: animation, child: child);
    });

    // Slide from right transition
    register('slideRight', (context, animation, secondaryAnimation, child) {
      return SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(1.0, 0.0),
          end: Offset.zero,
        ).animate(animation),
        child: child,
      );
    });

    // Slide from bottom transition
    register('slideUp', (context, animation, secondaryAnimation, child) {
      return SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0.0, 1.0),
          end: Offset.zero,
        ).animate(animation),
        child: child,
      );
    });

    // Scale transition
    register('scale', (context, animation, secondaryAnimation, child) {
      return ScaleTransition(scale: animation, child: child);
    });
  }
}
