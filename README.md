# Flutter Route Generator

A simple and flexible route generation package for Flutter applications that eliminates boilerplate code when handling navigation.

## Features

- ✅ Automatic route generation from configuration
- ✅ Type-safe navigation with compile-time checking
- ✅ Support for arguments passing with type safety
- ✅ Extension methods for cleaner navigation code
- ✅ Supports initial routes and required arguments
- ✅ Centralized navigation system with no conflicts
- ✅ Auto-discovery of route configurations anywhere in your project

## Installation

Add the package to your `pubspec.yaml`:

```yaml
dependencies:
  flutter_route_generator: ^1.0.0

dev_dependencies:
  build_runner: ^2.3.0
```

## Setup

### 1. Configure build.yaml

Create or update your `build.yaml` file in the root of your project:

```yaml
targets:
  $default:
    builders:
      # Disable source_gen's combining_builder for generated files
      source_gen|combining_builder:
        generate_for:
          exclude:
            - "**.routes.dart"
            - "**.g.dart"
      
      # Configure the auto-discovery route generator
      flutter_route_generator|route_generator:
        enabled: true
        generate_for:
          include:
            - lib/**.dart
            - example/**.dart
            # Add any other directories you want to scan
            # - modules/**.dart
```

### 2. Define Your Routes

Create a routes configuration class using the `@routeConfig` annotation anywhere in your project:

```dart
import 'package:flutter_route_generator/route_config_annotation.dart';
import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/detail_screen.dart';
import 'models/home_screen_args.dart';
import 'models/detail_screen_args.dart';

@routeConfig
class AppRoutes {
  static const List<ScreenConfig> screenConfigs = [
    ScreenConfig(
      screenType: HomeScreen,
      argsType: HomeScreenArgs,
      isInitial: true,
    ),
    ScreenConfig(
      screenType: DetailScreen,
      argsType: DetailScreenArgs,
      requiresArgs: true,
    ),
    ScreenConfig(
      screenType: ProfileScreen,
    )
  ];
}
```

You can define route configurations in any location - for example, you might have:
- `lib/routes/app_routes.dart` for main app routes
- `lib/features/auth/auth_routes.dart` for authentication routes
- `lib/dashboard/dashboard_routes.dart` for dashboard module routes

### 3. Generate Routes

Run the build_runner to generate the route code for all annotated route classes:

```bash
flutter pub run build_runner build
```

This will:
1. Find all classes with the `@routeConfig` annotation
2. Generate a corresponding `.routes.dart` file next to each annotated class
3. Create a central registry file at `lib/routes_registry.g.dart` listing all discovered route configurations

### 4. Initialize Your App

Set up your Flutter app to use the generated route system:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_route_generator/routes.dart';
import 'routes/app_routes.dart';
import 'routes/app_routes.routes.dart';
import 'features/auth/auth_routes.routes.dart';
import 'dashboard/dashboard_routes.routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize routes with all your screen configurations
  await Routes.initialize([
    ...AppRoutes.screenConfigs,
    ...AuthRoutes.screenConfigs,
    ...DashboardRoutes.screenConfigs,
  ]);
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final initialScreen = Routes.routeConfig.getInitialScreenConfig();
    
    return MaterialApp(
      title: 'Route Generator Example',
      theme: ThemeData(primarySwatch: Colors.blue),
      initialRoute: initialScreen?.path,
      onGenerateRoute: (settings) {
        // Try each route generator in order
        Route? route;
        
        // First try app routes
        route = appRouteGenerator(settings);
        if (route != null) return route;
        
        // Then try auth routes
        route = generateAuthRoutesRoutes(settings);
        if (route != null) return route;
        
        // Then try dashboard routes
        route = generateDashboardRoutesRoutes(settings);
        if (route != null) return route;
        
        // Fallback route
        return MaterialPageRoute(
          settings: settings,
          builder: (context) => Scaffold(
            appBar: AppBar(title: const Text('Page Not Found')),
            body: Center(child: Text('Route "${settings.name}" not found')),
          ),
        );
      },
    );
  }
}
```

## Usage

### Screen Creation

Create your screen widgets with the appropriate constructor for arguments:

```dart
// Without arguments
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: Center(
        child: Text('Profile screen'),
      ),
    );
  }
}

// With arguments
class DetailScreen extends StatelessWidget {
  final DetailScreenArgs args;
  
  const DetailScreen({Key? key, required this.args}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(args.title)),
      body: Center(
        child: Text('ID: ${args.id}'),
      ),
    );
  }
}

// Arguments class
class DetailScreenArgs {
  final String title;
  final int id;
  
  const DetailScreenArgs({required this.title, required this.id});
}
```

### Navigation

Use the extension methods from the Routes class to navigate:

```dart
// Import the routes package
import 'package:flutter_route_generator/routes.dart';

// Inside your widget:
// Navigate to a screen without arguments
context.push(ProfileScreen);

// Navigate to a screen with arguments
context.push(
  DetailScreen, 
  args: DetailScreenArgs(title: 'Item Details', id: 123)
);

// Replace current screen
context.pushReplacement(
  DetailScreen, 
  args: DetailScreenArgs(title: 'New Details', id: 456)
);

// Clear stack and navigate
context.pushAndRemoveUntil(HomeScreen);

// Go back
context.pop();
```

## Configuration Options

The `ScreenConfig` class supports the following options:

- `screenType`: The type of the screen widget (required)
- `argsType`: The type of the arguments class (optional)
- `path`: Custom route path (optional, defaults to lowercased screen name)
- `isInitial`: Whether this is the initial screen (optional, defaults to false)
- `requiresArgs`: Whether arguments are required (optional, defaults to false)

## Auto-Discovery Details

The auto-discovery feature automatically:

1. **Finds all @routeConfig classes** in your project
2. **Generates route implementations** for each configuration
3. **Creates a registry** of all discovered configurations

Benefits:
- Define routes close to the features they belong to
- No need to manually register routes or update build.yaml when adding new routes
- Supports modular architecture with routes in feature folders

## How It Works

The package scans your entire project for classes annotated with `@routeConfig`, then generates the necessary route implementation files. The navigation system uses the Routes class and context extensions to provide a clean, type-safe API for navigation.

## Architecture

The package consists of:

1. **route_config_annotation.dart** - Contains the annotation and configuration classes
2. **routes.dart** - The central navigation system with extension methods
3. **Generated .routes.dart files** - Contains route generator functions for each configuration
4. **routes_registry.g.dart** - A central registry of all route configurations

## Limitations

- The package requires that screens with arguments have an `args` parameter in their constructor
- All screens must be statically defined in the route configuration
- Route names must be unique across all route configurations

## License

MIT