import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:omni/core/router/app_router.dart';
import 'package:omni/core/theme/app_theme.dart';
import 'package:omni/core/theme/theme_cubit.dart';
import 'bootstrap.dart' as app;

void main() {
  app.bootstrap();
}

class OmniApp extends StatelessWidget {
  const OmniApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ThemeCubit(),
      child: BlocBuilder<ThemeCubit, ThemeMode>(
        builder: (context, mode) {
          return FutureBuilder(
            future: Firebase.initializeApp(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return MaterialApp(
                  home: Scaffold(
                    body: Center(child: CircularProgressIndicator()),
                  ),
                );
              }

              final router = createRouter();
              return MaterialApp.router(
                title: 'OMNI',
                routerConfig: router,
                theme: AppTheme.light(),
                darkTheme: AppTheme.dark(),
                themeMode: mode,
                debugShowCheckedModeBanner: false,
                supportedLocales: const [Locale('en')],
                localizationsDelegates: const [
                  GlobalMaterialLocalizations.delegate,
                  GlobalWidgetsLocalizations.delegate,
                  GlobalCupertinoLocalizations.delegate,
                ],
              );
            },
          );
        },
      ),
    );
  }
}
