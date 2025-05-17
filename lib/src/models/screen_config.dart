class ScreenConfig {
  final Type screenType;
  final Type? argsType;
  final bool isInitial;
  final String? path;

  const ScreenConfig({
    required this.screenType,
    this.argsType,
    this.isInitial = false,
    this.path,
  });

  String get routeName => path ?? '/${screenType.toString().toLowerCase()}';
}
