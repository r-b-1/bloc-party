import 'package:blocparty/flutter_backend/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'package:blocparty/view/navigation/routs.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:blocparty/model/theme_provider.dart';

import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

const clientId = '';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(MyApp(clientId: clientId));
}

class MyApp extends StatelessWidget {
  final String clientId;

  const MyApp({super.key, required this.clientId});

  @override
  Widget build(BuildContext context) {
    GoRouter router = goRouts();

    return ChangeNotifierProvider<ThemeProvider>(
      create: (context) => ThemeProvider(),
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp.router(
            title: 'BlocParty',
            theme: themeProvider.themeData,
            routerConfig: router,
          );
        },
      ),
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

