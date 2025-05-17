// import 'package:flutter/material.dart';
// import '../models/screen_config.dart';
// import '../generators/route_generator.dart';

// /// Central router class for the application.
// class AppRouter {
//   static RouteGenerator? _instance;
//   static Map<Type, ScreenConfig> _routes = {};

//   /// Configure the router with screen configurations.
//   ///
//   /// [screenConfigs] - List of screen configurations.
//   ///
//   /// Returns the configured RouteGenerator instance.
//   static RouteGenerator configure(List<ScreenConfig> screenConfigs) {
//     final routeGenerator = RouteGenerator.fromScreenConfigs(
//       screenConfigs: screenConfigs,
//     );

//     _instance = routeGenerator;

//     // Create a map for quick access to screen configs by type
//     _routes = {};
//     for (final config in screenConfigs) {
//       _routes[config.screenType] = config;
//     }

//     return routeGenerator;
//   }

//   /// Get the path for a screen type.
//   ///
//   /// [screenType] - The type of the screen to get the path for.
//   ///
//   /// Returns the path for the screen type.
//   static String pathFor(Type screenType) {
//     final config = _routes[screenType];
//     if (config == null) {
//       throw Exception('No route found for screen type: $screenType');
//     }

//     return config.getPath();
//   }

//   /// Get the instance of the route generator.
//   static RouteGenerator get instance {
//     if (_instance == null) {
//       throw Exception(
//           'AppRouter has not been initialized. Call AppRouter.configure() first.');
//     }

//     return _instance!;
//   }

//   /// Generate a route for MaterialApp's onGenerateRoute.
//   ///
//   /// [settings] - The route settings.
//   ///
//   /// Returns a route.
//   static Route<dynamic> onGenerateRoute(RouteSettings settings) {
//     if (_instance == null) {
//       throw Exception(
//           'AppRouter has not been initialized. Call AppRouter.configure() first.');
//     }

//     try {
//       return MaterialPageRoute(
//         settings: settings,
//         builder: (context) => _instance!.buildScreenForPath(
//           settings.name!,
//           args: settings.arguments,
//         ),
//       );
//     } catch (e) {
//       // Return a default "not found" route
//       return MaterialPageRoute(
//         settings: settings,
//         builder: (context) => Scaffold(
//           appBar: AppBar(title: const Text('Not Found')),
//           body: Center(child: Text('Route not found: ${settings.name}')),
//         ),
//       );
//     }
//   }
// }
