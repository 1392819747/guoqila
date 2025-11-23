import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'l10n/generated/app_localizations.dart';
import 'src/providers/item_provider.dart';
import 'src/providers/locale_provider.dart';
import 'src/providers/settings_provider.dart';
import 'src/services/notification_service.dart';
import 'src/services/storage_service.dart';
import 'src/ui/screens/home_screen.dart';
import 'src/ui/theme/app_colors.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Services
  final storageService = StorageService();
  await storageService.init();

  final notificationService = NotificationService();
  await notificationService.init();
  await notificationService.requestPermissions();
  
  final settingsProvider = SettingsProvider();
  await settingsProvider.init();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LocaleProvider()),
        ChangeNotifierProvider.value(value: settingsProvider),
        ChangeNotifierProvider(
          create: (_) => ItemProvider(storageService, notificationService),
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
    return Consumer<LocaleProvider>(
      builder: (context, localeProvider, child) {
        return MaterialApp(
          title: 'Expiry Tracker',
          debugShowCheckedModeBanner: false,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: localeProvider.locale,
          themeMode: ThemeMode.system,
          theme: ThemeData(
            useMaterial3: true,
            brightness: Brightness.light,
            colorScheme: ColorScheme.fromSeed(
              seedColor: AppColors.primary,
              primary: AppColors.primary,
              secondary: AppColors.secondary,
              surface: AppColors.surface,
              error: AppColors.error,
              brightness: Brightness.light,
            ),
            textTheme: TextTheme(
              displayLarge: const TextStyle(fontFamily: 'Inter', color: AppColors.textPrimary),
              displayMedium: const TextStyle(fontFamily: 'Inter', color: AppColors.textPrimary),
              titleLarge: const TextStyle(fontFamily: 'Inter', color: AppColors.textPrimary),
              bodyLarge: const TextStyle(fontFamily: 'Inter', color: AppColors.textPrimary),
              bodyMedium: const TextStyle(fontFamily: 'Inter', color: AppColors.textPrimary),
            ),
            scaffoldBackgroundColor: AppColors.background,
            datePickerTheme: DatePickerThemeData(
              backgroundColor: Colors.white,
              headerBackgroundColor: AppColors.primary,
              headerForegroundColor: Colors.black,
              dayStyle: const TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.bold),
              yearStyle: const TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.bold),
              todayBorder: const BorderSide(color: Colors.black, width: 2),
              todayForegroundColor: MaterialStateProperty.all(Colors.black),
              dayOverlayColor: MaterialStateProperty.all(AppColors.primary.withOpacity(0.2)),
              confirmButtonStyle: ButtonStyle(
                foregroundColor: MaterialStateProperty.all(Colors.black),
                textStyle: MaterialStateProperty.all(const TextStyle(fontWeight: FontWeight.bold)),
              ),
              cancelButtonStyle: ButtonStyle(
                foregroundColor: MaterialStateProperty.all(Colors.black),
                textStyle: MaterialStateProperty.all(const TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ),
          darkTheme: ThemeData(
            useMaterial3: true,
            brightness: Brightness.dark,
            colorScheme: ColorScheme.fromSeed(
              seedColor: AppColors.primary,
              primary: AppColors.primary,
              secondary: AppColors.secondary,
              surface: AppColors.surfaceDark,
              error: AppColors.error,
              brightness: Brightness.dark,
              background: AppColors.backgroundDark,
            ),
            textTheme: TextTheme(
              displayLarge: const TextStyle(fontFamily: 'Inter', color: AppColors.textPrimaryDark),
              displayMedium: const TextStyle(fontFamily: 'Inter', color: AppColors.textPrimaryDark),
              titleLarge: const TextStyle(fontFamily: 'Inter', color: AppColors.textPrimaryDark),
              bodyLarge: const TextStyle(fontFamily: 'Inter', color: AppColors.textPrimaryDark),
              bodyMedium: const TextStyle(fontFamily: 'Inter', color: AppColors.textPrimaryDark),
            ),
            scaffoldBackgroundColor: AppColors.backgroundDark,
            datePickerTheme: DatePickerThemeData(
              backgroundColor: AppColors.surfaceDark,
              headerBackgroundColor: AppColors.primary,
              headerForegroundColor: Colors.black,
              dayStyle: const TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.bold),
              yearStyle: const TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.bold),
              todayBorder: const BorderSide(color: AppColors.primary, width: 2),
              todayForegroundColor: MaterialStateProperty.all(AppColors.primary),
              dayOverlayColor: MaterialStateProperty.all(AppColors.primary.withOpacity(0.2)),
              confirmButtonStyle: ButtonStyle(
                foregroundColor: MaterialStateProperty.all(AppColors.primary),
                textStyle: MaterialStateProperty.all(const TextStyle(fontWeight: FontWeight.bold)),
              ),
              cancelButtonStyle: ButtonStyle(
                foregroundColor: MaterialStateProperty.all(Colors.white),
                textStyle: MaterialStateProperty.all(const TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ),
          home: const HomeScreen(),
        );
      },
    );
  }
}
