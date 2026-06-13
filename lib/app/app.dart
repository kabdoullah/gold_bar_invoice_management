import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import '../core/theme/app_theme.dart';
import 'di.dart';
import 'router.dart';

/// Root widget: DI tree + themed MaterialApp on GoRouter.
class GoldBarApp extends StatelessWidget {
  const GoldBarApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: buildProviders(),
      child: MaterialApp.router(
        title: 'Gestion Factures Or',
        theme: AppTheme.dark,
        routerConfig: appRouter,
        locale: const Locale('fr'),
        supportedLocales: const [Locale('fr')],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
