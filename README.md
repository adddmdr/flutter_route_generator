# Flutter Route Generator

A smart, flexible route generation package for Flutter applications that makes navigation type-safe and effortless.

## Features

- ✅ **Zero Configuration**: Just add the package and use the annotation
- ✅ **Type-Safe Navigation**: Compiler-verified navigation with proper typing
- ✅ **Smart Parameter Detection**: Automatically detects argument parameter names in your widgets
- ✅ **Required Parameter Warnings**: Build-time alerts for configuration mismatches
- ✅ **Auto-Discovery**: Finds route configurations anywhere in your project
- ✅ **Customizable Fallback Routes**: Handle unknown routes gracefully
- ✅ **Modular Architecture Support**: Define routes close to related features

## Installation

Add the package to your `pubspec.yaml`:

```yaml
dependencies:
  flutter_route_generator: ^1.0.0

dev_dependencies:
  build_runner: ^2.3.0
```

That's it! No additional configuration needed.

## Quick Start

### 1. Define Your Routes

Create a routes configuration class using the `@routeConfig` annotation:

```dart
import 'package:flutter_route_generator/route_config_annotation.dart';
import 'screens/home_screen.dart';
import 'screens/detail_screen.dart';
import 'models/detail_args.dart';

@routeConfig
class AppRoutes {
  static const List<ScreenConfig> screenConfigs = [
    ScreenConfig(
      screenType: HomeScreen,
      isInitial: true,
    ),
    ScreenConfig(
      screenType: DetailScreen,
      argsType: DetailArgs,
      requiresArgs: true,
    ),
  ];
}
```

### 2. Create Your Screens

Create your screen widgets with any parameter naming:

```dart
// Screen with no arguments
class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      body: Center(
        child: ElevatedButton(
          onPressed: () => context.push(
            DetailScreen, 
            args: DetailArgs(id: 123, title: 'Item Details'),
          ),
          child: const Text('View Details'),
        ),
      ),
    );
  }
}

// Screen with arguments - parameter name is automatically detected
class DetailScreen extends StatelessWidget {
  // Parameter name can be anything - the package will detect it
  final DetailArgs details;
  
  const DetailScreen({Key? key, required this.details}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(details.title)),
      body: Center(
        child: Text('ID: ${details.id}'),
      ),
    );
  }
}
```

### 3. Generate Routes

Run the build_runner to generate route code:

```bash
flutter pub run build_runner build
```

### 4. Initialize Routes in Your App

```dart
import 'package:flutter/material.dart';
import 'package:flutter_route_generator/routes.dart';
import 'routes/app_routes.dart';
import 'routes/app_routes.routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize routes
  await Routes.initialize(
    AppRoutes.screenConfigs,
    fallbackRouteConfig: FallbackRouteConfig(
      builder: (context, routeName) => Scaffold(
        appBar: AppBar(title: const Text('Not Found')),
        body: Center(child: Text('Route "$routeName" not found')),
      ),
    ),
  );
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final initialScreen = Routes.routeConfig.getInitialScreenConfig();
    
    return MaterialApp(
      title: 'My App',
      theme: ThemeData(primarySwatch: Colors.blue),
      initialRoute: initialScreen?.path,
      onGenerateRoute: appRouteGenerator,
    );
  }
}
```

### 5. Navigate!

Use the extension methods to navigate between screens:

```dart
// Navigate to a screen without arguments
context.push(HomeScreen);

// Navigate to a screen with arguments
context.push(
  DetailScreen, 
  args: DetailArgs(id: 123, title: 'Item Details')
);

// Replace current screen
context.pushReplacement(ProfileScreen);

// Clear stack and navigate
context.pushAndRemoveUntil(HomeScreen);

// Go back
context.pop();
```

## Smart Features

### Automatic Parameter Detection

The package automatically detects the parameter name in your widget constructor that matches the arguments type:

```dart
// The package detects 'details' as the parameter name
class DetailScreen extends StatelessWidget {
  final DetailArgs details;
  
  const DetailScreen({Key? key, required this.details}) : super(key: key);
  // ...
}
```

### Required Parameter Warning

During build time, the package warns you if you forgot to set `requiresArgs: true` for a screen with a required parameter:

```
ROUTE CONFIG WARNING: DetailScreen has a required parameter for DetailArgs but requiresArgs 
is not set to true in the ScreenConfig. This may cause runtime errors if arguments are not provided.
```

## Multiple Route Configurations

You can organize your routes by feature:

```dart
// In lib/features/auth/auth_routes.dart
@routeConfig
class AuthRoutes {
  static const List<ScreenConfig> screenConfigs = [
    ScreenConfig(screenType: LoginScreen),
    ScreenConfig(screenType: SignupScreen),
  ];
}

// In lib/features/products/product_routes.dart
@routeConfig
class ProductRoutes {
  static const List<ScreenConfig> screenConfigs = [
    ScreenConfig(screenType: ProductListScreen),
    ScreenConfig(screenType: ProductDetailScreen, argsType: ProductDetailArgs, requiresArgs: true),
  ];
}
```

Then combine them when initializing:

```dart
await Routes.initialize([
  ...AppRoutes.screenConfigs,
  ...AuthRoutes.screenConfigs, 
  ...ProductRoutes.screenConfigs,
]);
```

## Configuration Options

### ScreenConfig

| Parameter | Type | Description |
|-----------|------|-------------|
| screenType | Type | The widget class type (required) |
| argsType | Type? | The arguments class type (optional) |
| path | String? | Custom route path (default: lowercase screen name) |
| isInitial | bool | Whether this is the initial screen (default: false) |
| requiresArgs | bool | Whether arguments are required (default: false) |

### FallbackRouteConfig

| Parameter | Type | Description |
|-----------|------|-------------|
| builder | Function | Builds the fallback screen (required) |
| transitionsBuilder | Function? | Custom transition animation (optional) |
| maintainState | bool | Maintain state when navigating away (default: true) |

## Best Practices

1. **Use `requiresArgs: true` for required parameters**:
   ```dart
   ScreenConfig(
     screenType: DetailScreen,
     argsType: DetailArgs,
     requiresArgs: true,  // Important!
   )
   ```

2. **Define routes close to their features**:
   Organize routes in the same directories as their related screens.

3. **Use consistent parameter naming**:
   While any naming convention works, consistency improves maintainability.

## Troubleshooting

### Warning: Could not detect parameter

If you see this warning, check:
- Your widget has a constructor parameter with the specified type
- Import statements are correct
- Your code compiles successfully

### Build Errors

If the build process fails:
1. Clean your build: `flutter pub run build_runner clean`
2. Run with verbose output: `flutter pub run build_runner build --verbose`

## License

MIT License
