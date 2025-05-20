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
- ✅ **Nested Navigation**: Support for subroutes and nested navigators

## Installation

Add the package to your `pubspec.yaml`:

```yaml
dependencies:
  flutter_route_generator: ^1.0.0

dev_dependencies:
  build_runner: ^2.3.0
```

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

## Advanced Features

### Nested Navigation with Subroutes

Define subroutes for screens that need their own internal navigation:

```dart
@routeConfig
class AppRoutes {
  static const List<ScreenConfig> screenConfigs = [
    ScreenConfig(
      screenType: HomeScreen,
      isInitial: true,
    ),
    ScreenConfig(
      screenType: ProductScreen,
      argsType: ProductArgs,
      requiresArgs: true,
      subroutes: [
        ScreenConfig(screenType: ProductDetailsScreen),
        ScreenConfig(screenType: ProductReviewsScreen),
      ],
    ),
  ];
}
```

Create a screen that handles subroutes:

```dart
class ProductScreen extends StatelessWidget {
  final ProductArgs product;
  final String? initialSubRoute;
  
  const ProductScreen({
    Key? key, 
    required this.product,
    this.initialSubRoute,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(product.name)),
      body: initialSubRoute != null
          ? _buildSubRoute(context, initialSubRoute!)
          : _buildMainContent(context),
    );
  }
  
  Widget _buildSubRoute(BuildContext context, String subRoute) {
    if (subRoute.startsWith('/details')) {
      return ProductDetailsScreen(product: product);
    } else if (subRoute.startsWith('/reviews')) {
      return ProductReviewsScreen(product: product);
    } else {
      return Center(child: Text('Unknown subroute: $subRoute'));
    }
  }
  
  Widget _buildMainContent(BuildContext context) {
    // Main product screen content
  }
}
```

Navigate to subroutes:

```dart
// Navigate to main product screen
context.push(
  ProductScreen, 
  args: ProductArgs(id: 101, name: 'Smartphone')
);

// Navigate directly to a subroute
context.pushNested(
  ProductScreen,
  '/details',
  args: ProductArgs(id: 101, name: 'Smartphone')
);
```

### Custom Transitions

Add custom transitions to your routes:

```dart
ScreenConfig(
  screenType: DetailScreen,
  argsType: DetailArgs,
  requiresArgs: true,
  transitionsBuilder: (context, animation, secondaryAnimation, child) {
    return FadeTransition(
      opacity: animation,
      child: child,
    );
  },
),
```

### Multiple Route Configurations

Organize your routes by feature:

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
| path | String? | Custom route path (default: '/' for initial screens, lowercase screen name for others) |
| isInitial | bool | Whether this is the initial screen (default: false) |
| requiresArgs | bool | Whether arguments are required (default: false) |
| subroutes | List<ScreenConfig>? | Nested routes for this screen (optional) |
| transitionsBuilder | Function? | Custom transition animation (optional) |

### FallbackRouteConfig

| Parameter | Type | Description |
|-----------|------|-------------|
| builder | Function | Builds the fallback screen (required) |
| transitionsBuilder | Function? | Custom transition animation (optional) |
| maintainState | bool | Maintain state when navigating away (default: true) |

## How It Works

### Route Generation Process

1. **Annotation Processing**: The package scans your codebase for classes annotated with `@routeConfig`.

2. **Parameter Detection**: For screens with arguments, it automatically detects the parameter name in your widget constructor that matches the arguments type.

3. **Code Generation**: It generates type-safe route handling code for each screen configuration.

4. **Route Registration**: At runtime, all routes are registered with the navigation system.

### Path Generation

- For screens marked as `isInitial: true`, the default path is `/` (unless overridden).
- For other screens, the default path is the screen name with the first letter lowercase (e.g., `DetailScreen` becomes `/detailScreen`).
- You can override any path with the `path` parameter.

### Argument Handling

The package automatically:
1. Detects the parameter name in your widget constructor
2. Generates code to pass arguments correctly
3. Performs type checking to ensure arguments match
4. Warns during build if a required parameter isn't marked as required in the route config

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

4. **Handle subroutes properly**:
   For screens with nested navigation, implement the `initialSubRoute` parameter.

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

### Route Not Found

If you get a "route not found" error:
1. Check that you've run the build_runner
2. Verify that the route name matches the generated path
3. Ensure you're using the correct initialRoute in MaterialApp

## License

MIT License