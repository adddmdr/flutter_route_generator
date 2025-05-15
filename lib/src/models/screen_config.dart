/// Configuration for a screen to be used in route generation
class ScreenConfig {
  /// The screen class name (e.g. 'HomeScreen')
  final String screenName;

  /// The arguments class name (e.g. 'HomeScreenArgs')
  final String? argumentsClassName;

  /// Optional path parameter, defaults to screen name in camelCase
  final String? path;

  /// Create a screen configuration
  const ScreenConfig({
    required this.screenName,
    this.argumentsClassName,
    this.path,
  });

  /// The route name derived from the screen name
  String get routeName => '/${getRouteName()}';

  /// Get the route name in kebab-case (e.g. 'home-screen')
  String getRouteName() {
    if (path != null) return path!;

    // Convert from PascalCase to kebab-case
    final name = screenName
        .replaceAllMapped(
            RegExp(r'([A-Z])'), (match) => '-${match.group(1)!.toLowerCase()}')
        .substring(1);

    // Remove 'Screen' suffix and keep kebab case
    return name.endsWith('-screen') ? name.substring(0, name.length - 7) : name;
  }
}
