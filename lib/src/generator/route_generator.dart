// import 'package:analyzer/dart/element/element.dart';
// import 'package:build/build.dart';
// import 'package:source_gen/source_gen.dart';

// /// Generator for automatically registering route builders
// class RouteBuilderGenerator extends Generator {
//   @override
//   String generate(LibraryReader library, BuildStep buildStep) {
//     final screenClasses = _findScreenClasses(library);
//     final buffer = StringBuffer();

//     buffer.writeln('// Generated code - do not modify');
//     buffer.writeln('// ignore_for_file: implementation_imports');
//     buffer.writeln(
//         'import \'package:flutter_route_generator/flutter_route_generator.dart\';');

//     // Import all the screen classes
//     for (final screenClass in screenClasses) {
//       buffer.writeln('import \'${screenClass.source.uri}\';');
//     }

//     buffer.writeln('\n// Generated builder map');
//     buffer.writeln('Map<Type, WidgetBuilder> getGeneratedBuilders() {');
//     buffer.writeln('  return {');

//     // Generate builder for each screen class
//     for (final screenClass in screenClasses) {
//       final className = screenClass.name;
//       final hasArgsConstructor = _hasArgsConstructor(screenClass);

//       if (hasArgsConstructor) {
//         buffer.writeln('    $className: (args) => $className(args: args),');
//       } else {
//         buffer.writeln('    $className: (args) => const $className(),');
//       }
//     }

//     buffer.writeln('  };');
//     buffer.writeln('}');

//     return buffer.toString();
//   }

//   List<ClassElement> _findScreenClasses(LibraryReader library) {
//     return library.classes.where((classElement) {
//       // Typically screens end with 'Screen' suffix
//       return classElement.name.endsWith('Screen');
//     }).toList();
//   }

//   bool _hasArgsConstructor(ClassElement classElement) {
//     return classElement.constructors.any((constructor) {
//       return constructor.parameters
//           .any((parameter) => parameter.name == 'args');
//     });
//   }
// }
