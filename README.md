# Flutter Route Generator

A powerful and type-safe navigation package for Flutter applications that automatically generates route handling code based on annotations.

## Features

- **Type-safety**: Navigate to screens with compile-time type checking
- **Code generation**: Minimizes boilerplate routing code
- **Argument handling**: Type-safe passing and validation of screen arguments
- **Transition animations**: Built-in support for custom transition animations
- **Nested navigation**: Support for subroutes and nested navigators
- **Build-time validation**: Catches configuration errors during build rather than at runtime

## Installation

Add the following to your `pubspec.yaml`:

```yaml
dependencies:
  flutter_route_generator: ^1.0.0

dev_dependencies:
  build_runner: ^2.4.0
```

## Basic Usage

### 1. Define Your Routes

Create a class with the `@routeConfig` annotation to define your app's routes:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_route_generator/flutter_route_generator.dart';
import 'package:flutter_route_generator/route_config_annotation.dart';

// Import your screens
import 'screens/home_screen.dart';
import 'screens/profile_screen.dart';
import 'models/profile_args.dart';

@routeConfig
class AppRoutes {
  static const List<ScreenConfig> screenConfigs = [
    // Home screen - initial screen with fade transition
    ScreenConfig(
      screenType: HomeScreen,
      isInitial: true,
      transition: CommonTransitions.fade,
    ),
    
    // Profile screen - with required args and slide up transition
    ScreenConfig(
      screenType: ProfileScreen,
      argsType: ProfileArgs,
      requiresArgs: true,
      transition: CommonTransitions.slideUp,
    ),
  ];
}
```

### 2. Create Screen Classes

Regular screen:
```dart
class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            // Navigate to profile with arguments
            context.push(
              ProfileScreen, 
              args: ProfileArgs(userId: '123', name: 'John Doe')
            );
          },
          child: const Text('Go to Profile'),
        ),
      ),
    );
  }
}
```

Screen with arguments:
```dart
class ProfileScreen extends StatelessWidget {
  final ProfileArgs args;
  
  const ProfileScreen({Key? key, required this.args}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(args.name)),
      body: Center(
        child: Text('User ID: ${args.userId}'),
      ),
    );
  }
}

// Arguments class
class ProfileArgs {
  final String userId;
  final String name;
  
  ProfileArgs({required this.userId, required this.name});
}
```

### 3. Initialize the Router

In your `main.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_route_generator/routes.dart';
import 'routes/app_routes.dart';

void main() {
  // Initialize routes
  Routes.initialize(AppRoutes.screenConfigs);
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Route Generator Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      // Use the generated route function
      onGenerateRoute: appRouteGenerator,
      initialRoute: '/',
    );
  }
}
```

### 4. Generate Routes

Run the build_runner command to generate route code:

```
flutter pub run build_runner build
```

## Advanced Features

### Animations and Transitions

Use built-in transitions or create custom ones:

```dart
// Using built-in transitions
ScreenConfig(
  screenType: DetailsScreen,
  transition: CommonTransitions.fade,
)

// Initialize custom transitions
void main() {
  // Register a custom transition
  TransitionsRegistry.register(
    'myCustomTransition',
    (context, animation, secondAnimation, child) {
      return ScaleTransition(
        scale: CurvedAnimation(
          parent: animation,
          curve: Curves.elasticOut,
        ),
        child: child,
      );
    }
  );
  
  Routes.initialize(AppRoutes.screenConfigs);
  runApp(const MyApp());
}
```

### Nested Navigation with Subroutes

Define screens with subroutes for nested navigation:

```dart
ScreenConfig(
  screenType: DashboardScreen,
  argsType: DashboardArgs,
  transition: CommonTransitions.slideRight,
  subroutes: [
    ScreenConfig(screenType: OverviewTab),
    ScreenConfig(screenType: AnalyticsTab),
    ScreenConfig(screenType: SettingsTab),
  ],
)
```

Implement the screen with subroutes:

```dart
class DashboardScreen extends StatefulWidget {
  final DashboardArgs args;
  final String? initialSubRoute;
  
  const DashboardScreen({
    Key? key, 
    required this.args,
    this.initialSubRoute,
  }) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;
  
  @override
  void initState() {
    super.initState();
    // Process initialSubRoute if provided
    if (widget.initialSubRoute != null) {
      // Parse subroute to select the right tab
    }
  }

  @override
  Widget build(BuildContext context) {
    final tabs = [
      const OverviewTab(),
      const AnalyticsTab(),
      const SettingsTab(),
    ];

    return Scaffold(
      appBar: AppBar(title: Text(widget.args.title)),
      body: tabs[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Overview'),
          BottomNavigationBarItem(icon: Icon(Icons.analytics), label: 'Analytics'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
        ],
      ),
    );
  }
}
```

### Navigation Extensions

The package provides extension methods on `BuildContext` for cleaner navigation:

```dart
// Navigate to a screen
context.push(HomeScreen);

// Navigate with arguments
context.push(ProfileScreen, args: ProfileArgs(userId: '123', name: 'John'));

// Replace current screen
context.pushReplacement(SettingsScreen);

// Clear stack and navigate
context.pushAndRemoveUntil(HomeScreen);

// Go back
context.pop();
```

## Configuration Options

### ScreenConfig Properties

| Property | Type | Description |
|----------|------|-------------|
| `screenType` | `Type` | The type of the screen widget (required) |
| `argsType` | `Type?` | The type of arguments this screen accepts |
| `path` | `String?` | Custom route path (defaults to lowercase screen name) |
| `isInitial` | `bool` | Whether this is the initial screen of the app |
| `requiresArgs` | `bool` | Whether arguments are required for this screen |
| `subroutes` | `List<ScreenConfig>?` | List of subroutes for nested navigation |
| `transition` | `TransitionName?` | Custom transition for this route |

### FallbackRouteConfig

Configure a custom 404 screen:

```dart
Routes.initialize(
  AppRoutes.screenConfigs,
  fallbackRouteConfig: FallbackRouteConfig(
    builder: (context, routeName) => NotFoundScreen(routeName: routeName),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(opacity: animation, child: child);
    },
  ),
);
```

## Error Handling and Validation

Flutter Route Generator performs build-time validation to catch configuration errors early:

- **Critical Errors** (stops the build):
  - `requiresArgs=true` but no constructor parameter exists for the args type
  - `requiresArgs=true` but no `argsType` is specified

- **Warnings** (added as comments in generated code):
  - `hasSubroutes=true` but no `initialSubRoute` parameter exists
  - `argsType` is specified but no matching constructor parameter exists

## Example App

```dart
import 'package:flutter/material.dart';
import 'package:flutter_route_generator/flutter_route_generator.dart';
import 'package:flutter_route_generator/route_config_annotation.dart';

// This would typically be the main.dart file
void main() {
  // Initialize routes
  Routes.initialize(AppRoutes.screenConfigs);
  
  runApp(const MyApp());
}

// Main App Widget
class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Route Generator Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      // Use the generated route function
      onGenerateRoute: appRouteGenerator,
      initialRoute: '/',
    );
  }
}

// ROUTE CONFIGURATION
@routeConfig
class AppRoutes {
  static const List<ScreenConfig> screenConfigs = [
    // Home screen - initial route with fade transition
    ScreenConfig(
      screenType: HomeScreen,
      isInitial: true,
      transition: CommonTransitions.fade,
    ),
    
    // Dashboard screen - with subroutes and slide transition
    ScreenConfig(
      screenType: DashboardScreen,
      argsType: DashboardArgs,
      transition: CommonTransitions.slideRight,
      subroutes: [
        ScreenConfig(screenType: OverviewTab),
        ScreenConfig(screenType: AnalyticsTab),
        ScreenConfig(screenType: SettingsTab),
      ],
    ),
    
    // Profile screen - with required args and slide up transition
    ScreenConfig(
      screenType: ProfileScreen,
      argsType: ProfileArgs,
      requiresArgs: true,
      transition: CommonTransitions.slideUp,
    ),
    
    // Settings screen - scale transition
    ScreenConfig(
      screenType: SettingsScreen,
      transition: CommonTransitions.scale,
    ),
  ];
}

// ARGUMENT CLASSES
class DashboardArgs {
  final String title;
  
  DashboardArgs({required this.title});
}

class ProfileArgs {
  final String userId;
  final String name;
  
  ProfileArgs({required this.userId, required this.name});
}

// SCREEN DEFINITIONS
// Home Screen - Initial screen
class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Home Screen', style: TextStyle(fontSize: 24)),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Navigate to Dashboard with arguments
                context.push(
                  DashboardScreen,
                  args: DashboardArgs(title: 'My Dashboard'),
                );
              },
              child: const Text('Go to Dashboard'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                // Navigate to Profile with required arguments
                context.push(
                  ProfileScreen,
                  args: ProfileArgs(userId: '123', name: 'John Doe'),
                );
              },
              child: const Text('Go to Profile'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                // Navigate to Settings
                context.push(SettingsScreen);
              },
              child: const Text('Go to Settings'),
            ),
          ],
        ),
      ),
    );
  }
}

// Dashboard Screen - With subroutes
class DashboardScreen extends StatefulWidget {
  final DashboardArgs? args;
  final String? initialSubRoute;

  const DashboardScreen({
    Key? key,
    this.args,
    this.initialSubRoute,
  }) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;
  
  @override
  void initState() {
    super.initState();
    if (widget.initialSubRoute != null) {
      if (widget.initialSubRoute == '/analytics') {
        _selectedIndex = 1;
      } else if (widget.initialSubRoute == '/settings') {
        _selectedIndex = 2;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final tabs = [
      const OverviewTab(),
      const AnalyticsTab(),
      const SettingsTab(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.args?.title ?? 'Dashboard'),
        leading: BackButton(
          onPressed: () => context.pop(),
        ),
      ),
      body: tabs[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Overview',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.analytics),
            label: 'Analytics',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}

// Tab Screens
class OverviewTab extends StatelessWidget {
  const OverviewTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Overview Tab'));
  }
}

class AnalyticsTab extends StatelessWidget {
  const AnalyticsTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Analytics Tab'));
  }
}

class SettingsTab extends StatelessWidget {
  const SettingsTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Settings Tab'));
  }
}

// Profile Screen - With required args
class ProfileScreen extends StatelessWidget {
  final ProfileArgs args;
  
  const ProfileScreen({Key? key, required this.args}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(args.name),
        leading: BackButton(
          onPressed: () => context.pop(),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircleAvatar(
              radius: 50,
              child: Icon(Icons.person, size: 50),
            ),
            const SizedBox(height: 20),
            Text(args.name, style: const TextStyle(fontSize: 24)),
            Text('User ID: ${args.userId}'),
          ],
        ),
      ),
    );
  }
}

// Settings Screen
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        leading: BackButton(
          onPressed: () => context.pop(),
        ),
      ),
      body: ListView(
        children: [
          ListTile(
            title: const Text('Dark Mode'),
            trailing: Switch(value: false, onChanged: (_) {}),
          ),
          ListTile(
            title: const Text('Notifications'),
            trailing: Switch(value: true, onChanged: (_) {}),
          ),
          ListTile(
            title: const Text('Language'),
            trailing: const Text('English'),
            onTap: () {},
          ),
          ListTile(
            title: const Text('About'),
            onTap: () {},
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: () => context.pushReplacement(HomeScreen),
              child: const Text('Back to Home'),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.blue,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
```

## License

This package is available under the MIT License.