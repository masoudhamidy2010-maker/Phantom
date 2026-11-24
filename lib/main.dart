
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'screens.dart';
import 'state.dart';

void main() => runApp(const KashanEnergyApp());

class KashanEnergyApp extends StatefulWidget {
  const KashanEnergyApp({super.key});

  @override
  State<KashanEnergyApp> createState() =>
      _KashanEnergyAppState();
}

class _KashanEnergyAppState extends State<KashanEnergyApp> {
  final s = AppState();

  ThemeData _theme(Color seed, Brightness b) => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: seed,
          brightness: b,
        ).copyWith(
          secondary: const Color(0xFFF5C84C),
          error: const Color(0xFFE5484D),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          scrolledUnderElevation: 0,
          elevation: 0,
        ),
        scaffoldBackgroundColor: Colors.transparent,
      );

  @override
  Widget build(BuildContext context) {
    return Scope(
      notifier: s,
      child: Builder(
        builder: (c) {
          final a = Scope.of(c);

          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'انرژی کاشان',
            locale: const Locale('fa', 'IR'),
            supportedLocales: const [
              Locale('fa', 'IR'),
            ],
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            theme: _theme(a.seed, Brightness.light),
            darkTheme: _theme(a.seed, Brightness.dark),
            themeMode:
                a.dark ? ThemeMode.dark : ThemeMode.light,
            builder: (ctx, child) => MediaQuery(
              data: MediaQuery.of(ctx).copyWith(
                textScaler: TextScaler.linear(a.scale),
              ),  
              child: child!,
            ),
            home: !a.onboarded
                ? const Onboarding()
                : a.signedIn
                    ? const Shell()
                    : const AuthPage(),
          );
        },
      ),
    );
  }
}
