# Flutter Route Generator

A smart, flexible route generation package for Flutter applications that eliminates boilerplate code and makes navigation type-safe and clean.

## Features

- ✅ Automatic route generation from configuration
- ✅ Type-safe navigation with compile-time checking
- ✅ Intelligent parameter name detection - use any naming convention
- ✅ Required parameter detection and warnings
- ✅ Auto-discovery of route configurations anywhere in your project
- ✅ Customizable fallback route for unmatched routes
- ✅ Extension methods for cleaner navigation code
- ✅ No manual configuration required

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
      
      # Configure the route generator
      flutter_route_generator|route_generator:
        enabled: true
        generate_for:
          include:
            - lib/**.dart
```

### 2. Define Your Routes

Create a routes configuration class using the `@routeConfig` annotation anywhere in your project:

```dart
import 'package:flutter_route_generator/route_config_annotation.dart';
import 'package:flutter/material.dart';
import 'screens/home.dart';
import 'screens/product_details.dart';
import 'models/product_args.dart';

@routeConfig
class AppRoutes {
  static const List<ScreenConfig> screenConfigs = [
    ScreenConfig(
      screenType: Home,
      isInitial: true,
    ),
    ScreenConfig(
      screenType: ProductDetails,
      argsType: ProductArgs,
      requiresArgs: true,
    ),
    ScreenConfig(
      screenType: UserProfile,
      // Custom path instead of using the class name
      path: '/user/profile',
    )
  ];
}
```

### 3. Create Your Screen Widgets

Create your screen widgets using any naming convention for arguments parameters:

```dart
// Screen with a required argument parameter named 'product'
class ProductDetails extends StatelessWidget {
  final ProductArgs product;
  
  const ProductDetails({Key? key, required this.product}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    // Your UI code
  }
}

// Screen with a required argument parameter named 'arguments'
class Auth extends StatelessWidget {
  final AuthScreenArguments arguments;
  
  const Auth({Key? key, required this.arguments}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    // Your UI code
  }
}

// Screen with a parameter named 'args'
class DetailScreen extends StatelessWidget {
  final DetailScreenArgs args;
  
  const DetailScreen({Key? key, required this.args}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    // Your UI code
  }
}
```

### 4. Generate Routes

Run the build_runner to generate the route code:

```bash
flutter pub run build_runner build
```

This will:
1. Find all classes with the `@routeConfig` annotation
2. Generate a corresponding `.routes.dart` file next to each annotated class
3. Create a central registry file at `lib/routes_registry.g.dart`
4. Check for any mismatches between your route configurations and widget parameters

### 5. Initialize Your App

Set up your Flutter app to use the generated route system:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_route_generator/routes.dart';
import 'routes/app_routes.dart';
import 'routes/app_routes.routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize routes with your screen configurations with optional fallbackRoute
  await Routes.initialize(
    AppRoutes.screenConfigs,
    fallbackRouteConfig: FallbackRouteConfig(
      builder: (context, routeName) => Scaffold(
        appBar: AppBar(title: const Text('Not Found')),
        body: Center(
          child: Text('The route "$routeName" was not found.'),
        ),
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
      title: 'Route Generator Example',
      theme: ThemeData(primarySwatch: Colors.blue),
      initialRoute: initialScreen?.path,
      onGenerateRoute: appRouteGenerator,
    );
  }
}
```

## Navigation

Use the extension methods to navigate between screens:

```dart
// Navigate to a screen without arguments
context.push(Home);

// Navigate to a screen with arguments
context.push(
  ProductDetails, 
  args: ProductArgs(id: 123, name: 'Smartphone')
);

// Replace current screen
context.pushReplacement(
  DetailScreen, 
  args: DetailScreenArgs(title: 'New Details', content: 'Some content')
);

// Clear stack and navigate
context.pushAndRemoveUntil(Home);

// Go back
context.pop();
```

## Smart Features

### 1. Automatic Parameter Name Detection

The package automatically detects the parameter name in your widget constructor that matches the arguments type:

```dart
// The package will detect 'product' as the parameter name
class ProductDetails extends StatelessWidget {
  final ProductArgs product;
  
  const ProductDetails({Key? key, required this.product}) : super(key: key);
  // ...
}
```

### 2. Required Parameter Warning

During build time, the package will warn you if you forgot to set `requiresArgs: true` for a screen with a required parameter:

```
ROUTE CONFIG WARNING: ProductDetails has a required parameter for ProductArgs but requiresArgs is not set to true in the ScreenConfig. This may cause runtime errors if arguments are not provided.
```

### 3. Auto-Discovery

Define route configurations anywhere in your project - the package will find and process them automatically.

### 4. Fallback Route

Customize how your app handles unknown routes with the fallback route configuration.

## Configuration Options

### ScreenConfig Options

The `ScreenConfig` class supports the following options:

- `screenType`: The type of the screen widget (required)
- `argsType`: The type of the arguments class (optional)
- `path`: Custom route path (optional, defaults to lowercased class name)
- `isInitial`: Whether this is the initial screen (optional, defaults to false)
- `requiresArgs`: Whether arguments are required (optional, defaults to false)

### FallbackRouteConfig Options

- `builder`: Function that builds the screen widget (required)
- `transitionsBuilder`: Custom transition animation (optional)
- `maintainState`: Whether to maintain state when navigating away (optional, defaults to true)

## Best Practices

1. **Set `requiresArgs: true` for screens with required arguments**:
   ```dart
   ScreenConfig(
     screenType: ProductDetails,
     argsType: ProductArgs,
     requiresArgs: true,  // Important for runtime safety
   )
   ```

2. **Use consistent naming for argument classes**:
   While any naming convention is supported, using consistent names like `HomeArgs` or `ProfileArguments` makes your code more maintainable.

3. **Organize routes by feature**:
   Take advantage of auto-discovery to define routes close to their related features.

## How It Works

Under the hood, the package:

1. Scans your project for `@routeConfig` annotations
2. Analyzes your widget constructors to find parameter names matching argument types
3. Generates type-safe route code
4. Checks for configuration/implementation mismatches
5. Creates a central route registry

## Troubleshooting

### Error: Parameter Not Found

If you see a warning about a parameter not being found, ensure:
- Your widget has a constructor parameter with the correct type
- The argument type is imported properly
- Your code compiles successfully

### Performance Issues

If the build process is slow:
- Use more specific include paths in your `build.yaml`
- Consider splitting large route configurations into smaller ones

## License

MIT
