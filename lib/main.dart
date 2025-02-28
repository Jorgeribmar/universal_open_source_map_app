import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:universal_open_source_map_app/providers/map_provider.dart';
import 'package:universal_open_source_map_app/screens/map_screen.dart';
import 'package:universal_open_source_map_app/services/location_service.dart';
import 'package:universal_open_source_map_app/services/map_service.dart';

void main() async {
// Initialize services
final mapService = MapService();
final locationService = LocationService();

runApp(
    MultiProvider(
    providers: [
        ChangeNotifierProvider(
        create: (_) => MapProvider(
            mapService: mapService,
            locationService: locationService,
        ),
        ),
    ],
    child: const MyApp(),
    ),
);
}

class MyApp extends StatelessWidget {
const MyApp({super.key});

@override
Widget build(BuildContext context) {
    return MaterialApp(
    title: 'Universal Map App',
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.teal,
        primary: Colors.teal,
        secondary: Colors.blueAccent,
        brightness: Brightness.light,
        ),
        appBarTheme: const AppBarTheme(
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        elevation: 2,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
            backgroundColor: Colors.teal,
            foregroundColor: Colors.white,
        ),
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        ),
    ),
    darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.teal,
        primary: Colors.teal,
        secondary: Colors.lightBlueAccent,
        brightness: Brightness.dark,
        ),
    ),
    themeMode: ThemeMode.system,
    home: const MapScreen(),
    );
}
}

