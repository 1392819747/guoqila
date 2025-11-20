import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'l10n/generated/app_localizations.dart';
import 'src/providers/item_provider.dart';
import 'src/providers/locale_provider.dart';
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

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LocaleProvider()),
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
          theme: ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(
              seedColor: AppColors.primary,
              primary: AppColors.primary,
              secondary: AppColors.secondary,
              surface: AppColors.surface,
              error: AppColors.error,
            ),
            textTheme: TextTheme(
              displayLarge: const TextStyle(fontFamily: 'Inter'),
              displayMedium: const TextStyle(fontFamily: 'Inter'),
              titleLarge: const TextStyle(fontFamily: 'Inter'),
              bodyLarge: const TextStyle(fontFamily: 'Inter'),
              bodyMedium: const TextStyle(fontFamily: 'Inter'),
            ),
            scaffoldBackgroundColor: AppColors.background,
          ),
          locale: localeProvider.locale,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('en'), // English
            Locale('zh'), // Chinese
            Locale('ja'), // Japanese
            Locale('ko'), // Korean
          ],
          home: const HomeScreen(),
        );
      },
    );
  }
}
