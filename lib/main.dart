import 'package:flutter/material.dart';
import 'package:unzip/config/routes.dart';
import 'package:unzip/config/themes.dart';
import 'package:unzip/core/services/theme_service.dart';
import 'package:unzip/features/home/screens/home_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    // En utilisant un seul ChangeNotifierProvider au lieu de MultiProvider
    ChangeNotifierProvider<ThemeService>(
      create: (_) => ThemeService(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeService = Provider.of<ThemeService>(context);

    return MaterialApp(
      title: 'Dev Toolbox',
      theme: ThemeData.light(useMaterial3: true),
      darkTheme: ThemeData.dark(useMaterial3: true),
      themeMode: themeService.themeMode,
      home: const HomeScreen(),
    );
  }
}