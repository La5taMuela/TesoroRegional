import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tesoro_regional/core/router/app_router.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:tesoro_regional/core/providers/locale_provider.dart';
import 'package:tesoro_regional/core/services/i18n/app_localizations.dart';

class TesoroRegionalApp extends ConsumerWidget {
  const TesoroRegionalApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final locale = ref.watch(localeProvider);

    return MaterialApp.router(
      title: 'Tesoro Regional',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFFFD700),
          primary: const Color(0xFF8B4513),
          secondary: const Color(0xFF228B22),
          surface: Colors.white,
          background: Colors.grey.shade50,
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.grey.shade50,
        appBarTheme: const AppBarTheme(
          elevation: 0,
          scrolledUnderElevation: 0,
        ),
      ),
      routerConfig: router,
      debugShowCheckedModeBanner: false,
      locale: locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('es', 'CL'),
        Locale('en', 'US'),
      ],
    );
  }
}
