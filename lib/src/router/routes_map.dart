// import '../models/screen_config.dart';

// /// Class for type-safe access to routes.
// class Routes {
//   final Map<Type, ScreenConfig> _routes;

//   /// Constructor for Routes.
//   const Routes._(this._routes);

//   /// Creates a routes instance from screen configurations.
//   ///
//   /// [screenConfigs] - List of screen configurations.
//   ///
//   /// Returns a Routes instance.
//   factory Routes.from(List<ScreenConfig> screenConfigs) {
//     final routes = <Type, ScreenConfig>{};
//     for (final config in screenConfigs) {
//       routes[config.screenType] = config;
//     }

//     return Routes._(routes);
//   }

//   /// Gets a route by screen type.
//   ScreenConfig operator [](Type type) {
//     final route = _routes[type];
//     if (route == null) {
//       throw Exception('No route found for screen type: $type');
//     }

//     return route;
//   }

//   /// Gets the path for a screen type.
//   String pathFor(Type type) {
//     return this[type].getPath();
//   }

//   /// Gets all routes.
//   Map<Type, ScreenConfig> get all => Map.unmodifiable(_routes);
// }
