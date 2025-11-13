import 'package:blocparty/flutter_backend/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'package:blocparty/view/navigation/routs.dart';
import 'package:go_router/go_router.dart';

import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

const clientId = '';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Change file name here to change themes
  final themeData = await loadThemeFromJson('blue_appainter_theme.json');

  runApp(MyApp(clientId: clientId, theme: themeData));
}

class MyApp extends StatelessWidget {
  final String clientId;
  final ThemeData theme;

  const MyApp({super.key, required this.clientId, required this.theme});

  @override
  Widget build(BuildContext context) {
    GoRouter router = goRouts();

    return MaterialApp.router(
      title: 'BlocParty',
      theme: theme,

      routerConfig: router,
    );
  }
}

Future<ThemeData> loadThemeFromJson(String themeName) async {
  final jsonString = await rootBundle.loadString('assets/themes/$themeName');
  final Map<String, dynamic> jsonMap = jsonDecode(jsonString);

  final colorSchemeMap = jsonMap['colorScheme'] as Map<String, dynamic>;

  Color parseColor(String hex) =>
      Color(int.parse(hex.replaceFirst('#', '0xFF')));

  final colorScheme = ColorScheme(
    brightness: colorSchemeMap['brightness'] == 'dark'
        ? Brightness.dark
        : Brightness.light,

    primary: parseColor(colorSchemeMap['primary']),
    onPrimary: parseColor(colorSchemeMap['onPrimary']),
    secondary: parseColor(colorSchemeMap['secondary']),
    onSecondary: parseColor(colorSchemeMap['onSecondary']),
    error: parseColor(colorSchemeMap['error']),
    onError: parseColor(colorSchemeMap['onError']),
    surface: parseColor(colorSchemeMap['surface']),
    onSurface: parseColor(colorSchemeMap['onSurface']),
  );

  //Build ThemeData from the JSON

  return ThemeData(
    useMaterial3: jsonMap['useMaterial3'] ?? true,
    brightness: jsonMap['brightness'] == 'dark'
        ? Brightness.dark
        : Brightness.light,
    scaffoldBackgroundColor: parseColor(jsonMap['scaffoldBackgroundColor']),
    colorScheme: colorScheme,
  );
}
