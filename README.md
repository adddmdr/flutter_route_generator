# Flutter Route Generator

A simple and flexible route generation package for Flutter applications that eliminates boilerplate code when handling navigation.

## Features

- ✅ Automatic route generation from configuration
- ✅ Type-safe navigation with compile-time checking
- ✅ Support for arguments passing with type safety
- ✅ Extension methods for cleaner navigation code
- ✅ Supports initial routes and required arguments
- ✅ Standalone generated code with no runtime dependencies

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
      # Disable source_gen's combining_builder for .routes.dart files
      source_gen|combining_builder:
        generate_for:
          exclude:
            - "**.routes.dart"
      # Configure your route_generator
      flutter_route_generator|route_generator:
        enabled: true
        generate_for:
          include:
            - lib/app_routes.dart
```

### 2. Define Your Routes

Create a routes configuration class using the `@routeConfig` annotation:

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

### 3. Generate Routes

Run the build_runner to generate the route code:

```bash
flutter pub run build_runner build
```

This will generate an `app_routes.routes.dart` file with all the necessary navigation code.

### 4. Initialize Your App

Set up your Flutter app to use the generated route system:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_route_generator/routes.dart';
import 'app_routes.dart';
import 'app_routes.routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize routes
  await Routes.initialize(AppRoutes.screenConfigs);
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final initialScreen = AppRoutes.screenConfigs.firstWhere(
      (config) => config.isInitial,
      orElse: () => AppRoutes.screenConfigs.first
    );
    
    return MaterialApp(
      title: 'Route Generator Example',
      theme: ThemeData(primarySwatch: Colors.blue),
      initialRoute: initialScreen.routeName,
      onGenerateRoute: appRouteGenerator,
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

Use the extension methods from the generated code to navigate:

```dart
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

## Error Handling

The package provides helpful error messages:

- If you try to navigate to a screen that requires arguments without providing them
- If you try to navigate to a screen that's not registered in your route configuration
- If no initial screen is defined when one is needed

## How It Works

The package uses Dart's build system to generate type-safe route code. It scans your route configuration class and creates the necessary code for navigation, including a route generator function and extension methods for the BuildContext.

## Limitations

- The package requires that screens with arguments have an `args` parameter in their constructor
- All screens must be statically defined in the route configuration

## License

MIT