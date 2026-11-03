import 'package:blocparty/flutter_backend/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'package:blocparty/view/navigation/routs.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:blocparty/model/theme_provider.dart';

import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:shared_preferences/shared_preferences.dart';

const clientId = '';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Load the saved theme BEFORE the first frame. Rendering even one frame
  // with a provisional `ThemeData()` is fatal: MaterialApp's internal
  // AnimatedTheme then lerps from default typography (inherit: false) to
  // our custom textTheme (inherit: true), which crashes TextStyle.lerp and
  // cascades into broken frames during every material rebuild.
  ThemeData initialThemeData;
  try {
    final prefs = await SharedPreferences.getInstance();
    final isDark = prefs.getBool('isDarkMode') ?? false;
    initialThemeData = await loadThemeFromJson(
      isDark ? 'dark_blue_appainter_theme.json' : 'blue_appainter_theme.json',
    );
  } catch (_) {
    initialThemeData = ThemeData(); // Degraded fallback only.
  }

  runApp(MyApp(
    clientId: clientId,
    initialThemeData: initialThemeData,
  ));
}

class MyApp extends StatelessWidget {
  final String clientId;
  final ThemeData initialThemeData;

  const MyApp({
    super.key,
    required this.clientId,
    required this.initialThemeData,
  });

  @override
  Widget build(BuildContext context) {
    GoRouter router = goRouts();

    return ChangeNotifierProvider<ThemeProvider>(
      create: (context) => ThemeProvider(initialThemeData: initialThemeData),
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

  // Defensively fetch an optional color; returns null when absent or malformed.
  Color? color(String key) {
    final raw = colorSchemeMap[key];
    if (raw is String && raw.isNotEmpty) {
      try {
        return parseColor(raw);
      } catch (_) {
        return null;
      }
    }
    return null;
  }

  final isDark = colorSchemeMap['brightness'] == 'dark' ||
      jsonMap['brightness'] == 'dark';

  final colorScheme = ColorScheme(
    brightness: isDark ? Brightness.dark : Brightness.light,
    primary: parseColor(colorSchemeMap['primary']),
    onPrimary: parseColor(colorSchemeMap['onPrimary']),
    secondary: parseColor(colorSchemeMap['secondary']),
    onSecondary: parseColor(colorSchemeMap['onSecondary']),
    error: parseColor(colorSchemeMap['error']),
    onError: parseColor(colorSchemeMap['onError']),
    surface: parseColor(colorSchemeMap['surface']),
    onSurface: parseColor(colorSchemeMap['onSurface']),
    // Optional roles — fall back to sensible defaults when missing.
    onSurfaceVariant: color('onSurfaceVariant') ??
        parseColor(colorSchemeMap['onSurface']).withOpacity(0.7),
    outline:
        color('outline') ?? parseColor(colorSchemeMap['onSurface']).withOpacity(0.45),
    outlineVariant:
        color('outlineVariant') ?? parseColor(colorSchemeMap['surface']).withOpacity(0.6),
    primaryContainer: color('primaryContainer') ??
        parseColor(colorSchemeMap['primary']).withOpacity(0.15),
    onPrimaryContainer: color('onPrimaryContainer') ??
        parseColor(colorSchemeMap['onPrimary']),
    secondaryContainer: color('secondaryContainer') ??
        parseColor(colorSchemeMap['secondary']).withOpacity(0.15),
    onSecondaryContainer: color('onSecondaryContainer') ??
        parseColor(colorSchemeMap['onSecondary']),
    surfaceContainer: color('surfaceContainer') ??
        parseColor(colorSchemeMap['surface']),
    surfaceContainerHigh: color('surfaceContainerHigh') ??
        parseColor(colorSchemeMap['surface']),
    surfaceContainerHighest: color('surfaceContainerHighest') ??
        parseColor(colorSchemeMap['surface']),
    inverseSurface:
        color('inverseSurface') ?? parseColor(colorSchemeMap['onSurface']),
    onInverseSurface:
        color('onInverseSurface') ?? parseColor(colorSchemeMap['surface']),
  );

  // ---- Typography: Bricolage Grotesque displays, Gabarito does the work ----
  const display = 'BricolageGrotesque';
  const body = 'Gabarito';

  final onSurface = colorScheme.onSurface;
  final onSurfaceVariant = colorScheme.onSurfaceVariant;

  TextTheme textTheme = TextTheme(
    displayLarge: TextStyle(
        fontFamily: display, fontSize: 36, fontWeight: FontWeight.w800,
        color: onSurface, height: 1.15, letterSpacing: -0.5),
    displayMedium: TextStyle(
        fontFamily: display, fontSize: 30, fontWeight: FontWeight.w800,
        color: onSurface, height: 1.15, letterSpacing: -0.5),
    displaySmall: TextStyle(
        fontFamily: display, fontSize: 26, fontWeight: FontWeight.w800,
        color: onSurface, height: 1.2, letterSpacing: -0.4),
    headlineLarge: TextStyle(
        fontFamily: display, fontSize: 27, fontWeight: FontWeight.w700,
        color: onSurface, height: 1.2, letterSpacing: -0.4),
    headlineMedium: TextStyle(
        fontFamily: display, fontSize: 22.5, fontWeight: FontWeight.w700,
        color: onSurface, height: 1.25, letterSpacing: -0.3),
    headlineSmall: TextStyle(
        fontFamily: display, fontSize: 19, fontWeight: FontWeight.w700,
        color: onSurface, height: 1.3),
    titleLarge: TextStyle(
        fontFamily: body, fontSize: 17.5, fontWeight: FontWeight.w600,
        color: onSurface, height: 1.35),
    titleMedium: TextStyle(
        fontFamily: body, fontSize: 15.5, fontWeight: FontWeight.w600,
        color: onSurface, height: 1.4),
    titleSmall: TextStyle(
        fontFamily: body, fontSize: 14, fontWeight: FontWeight.w600,
        color: onSurface, height: 1.4),
    bodyLarge: TextStyle(
        fontFamily: body, fontSize: 16, fontWeight: FontWeight.w400,
        color: onSurface, height: 1.5),
    bodyMedium: TextStyle(
        fontFamily: body, fontSize: 15, fontWeight: FontWeight.w400,
        color: onSurface, height: 1.5),
    bodySmall: TextStyle(
        fontFamily: body, fontSize: 13, fontWeight: FontWeight.w400,
        color: onSurfaceVariant, height: 1.4),
    labelLarge: TextStyle(
        fontFamily: body, fontSize: 14.5, fontWeight: FontWeight.w600,
        color: onSurface, height: 1.35),
    labelMedium: TextStyle(
        fontFamily: body, fontSize: 12.5, fontWeight: FontWeight.w600,
        color: onSurface, height: 1.35),
    labelSmall: TextStyle(
        fontFamily: body, fontSize: 11, fontWeight: FontWeight.w600,
        color: onSurfaceVariant, height: 1.4, letterSpacing: 0.2),
  ).apply(bodyColor: onSurface, displayColor: onSurface);

  // ---- Component themes ----
  final ThemeData theme = ThemeData(
    useMaterial3: jsonMap['useMaterial3'] ?? true,
    brightness: isDark ? Brightness.dark : Brightness.light,
    scaffoldBackgroundColor: parseColor(jsonMap['scaffoldBackgroundColor']),
    colorScheme: colorScheme,
    textTheme: textTheme,
    splashFactory: InkSparkle.splashFactory,
    visualDensity: VisualDensity.standard,

    // App bar sits on the warm paper background with no hard edge.
    appBarTheme: AppBarTheme(
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      backgroundColor: Colors.transparent,
      foregroundColor: colorScheme.onSurface,
      titleTextStyle: TextStyle(
        fontFamily: display,
        fontSize: 19,
        fontWeight: FontWeight.w700,
        color: colorScheme.onSurface,
      ),
    ),

    // Cards are photo frames, not boxes: hairline border, low elevation.
    cardTheme: CardThemeData(
      elevation: 0,
      margin: EdgeInsets.zero,
      color: colorScheme.surface,
      surfaceTintColor: Colors.transparent,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: const BorderRadius.all(Radius.circular(16)),
        side: BorderSide(color: colorScheme.outlineVariant, width: 1),
      ),
    ),

    // Inputs feel soft and filled, outlined only when focused.
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: colorScheme.surfaceContainerHigh,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: const BorderRadius.all(Radius.circular(14)),
        borderSide: BorderSide(color: colorScheme.outlineVariant),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: const BorderRadius.all(Radius.circular(14)),
        borderSide: BorderSide(color: colorScheme.outlineVariant),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: const BorderRadius.all(Radius.circular(14)),
        borderSide: BorderSide(color: colorScheme.primary, width: 1.6),
      ),
      labelStyle: TextStyle(
          fontFamily: body, fontSize: 15, color: onSurfaceVariant),
      hintStyle: TextStyle(
          fontFamily: body, fontSize: 15, color: onSurfaceVariant),
    ),

    // Buttons: generous 48px targets, soft 14px corners.
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size(64, 48),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        textStyle: const TextStyle(
            fontFamily: body, fontSize: 15.5, fontWeight: FontWeight.w600),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(64, 48),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        elevation: 0,
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        textStyle: const TextStyle(
            fontFamily: body, fontSize: 15.5, fontWeight: FontWeight.w600),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        minimumSize: const Size(48, 44),
        textStyle: const TextStyle(
            fontFamily: body, fontSize: 15, fontWeight: FontWeight.w600),
      ),
    ),

    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(64, 48),
        side: BorderSide(color: colorScheme.outlineVariant),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        textStyle: const TextStyle(
            fontFamily: body, fontSize: 15.5, fontWeight: FontWeight.w600),
      ),
    ),

    // Chips read as small tags, not buttons.
    chipTheme: ChipThemeData(
      backgroundColor: colorScheme.surfaceContainerHigh,
      side: BorderSide(color: colorScheme.outlineVariant),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      labelStyle: TextStyle(
          fontFamily: body, fontSize: 13.5, fontWeight: FontWeight.w500,
          color: onSurface),
    ),

    dialogTheme: DialogThemeData(
      backgroundColor: colorScheme.surface,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      titleTextStyle: TextStyle(
        fontFamily: display,
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: colorScheme.onSurface,
      ),
      contentTextStyle: TextStyle(
        fontFamily: body,
        fontSize: 15,
        height: 1.5,
        color: colorScheme.onSurfaceVariant,
      ),
    ),

    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: colorScheme.inverseSurface,
      contentTextStyle: TextStyle(
        fontFamily: body,
        fontSize: 14.5,
        fontWeight: FontWeight.w500,
        color: colorScheme.onInverseSurface,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),

    navigationBarTheme: NavigationBarThemeData(
      height: 68,
      elevation: 0,
      backgroundColor: colorScheme.surface,
      surfaceTintColor: Colors.transparent,
      indicatorColor: colorScheme.primaryContainer,
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        final selected = states.contains(WidgetState.selected);
        return TextStyle(
          fontFamily: body,
          fontSize: 12.5,
          fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
          color: selected ? colorScheme.onSurface : onSurfaceVariant,
        );
      }),
    ),

    dividerTheme: DividerThemeData(
      color: colorScheme.outlineVariant,
      thickness: 1,
      space: 1,
    ),
  );

  return theme;
}
