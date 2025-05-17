class ScreenConfig {
  final Type screenType;
  final Type? argsType;
  final bool isInitial;
  final String? path;
  final bool requiresArgs;

  const ScreenConfig({
    required this.screenType,
    this.argsType,
    this.isInitial = false,
    this.path,
    this.requiresArgs = false,
  });

  String get routeName =>
      path ??
      '/${screenType.toString().substring(0, 1).toLowerCase()}${screenType.toString().substring(1)}';
}
