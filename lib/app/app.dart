import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import '../core/theme/app_theme.dart';
import '../domain/services/backup_service.dart';
import 'di.dart';
import 'router.dart';

/// Root widget: DI tree + themed MaterialApp on GoRouter.
class GoldBarApp extends StatelessWidget {
  const GoldBarApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: buildProviders(),
      child: _StartupController(
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
      ),
    );
  }
}

/// Thin lifecycle widget inside the Provider tree. Fires the startup
/// auto-backup once per app launch, after the first frame (so all
/// providers are ready). Gate: must have backed up before AND > 24 h ago.
class _StartupController extends StatefulWidget {
  const _StartupController({required this.child});
  final Widget child;

  @override
  State<_StartupController> createState() => _StartupControllerState();
}

class _StartupControllerState extends State<_StartupController> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _autoBackupOnStartupIfNeeded(context);
    });
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

Future<void> _autoBackupOnStartupIfNeeded(BuildContext context) async {
  final service = context.read<BackupService>();
  final last    = await service.getLastBackupDate();
  if (last == null) return; // never backed up — skip to avoid surprise uploads
  if (DateTime.now().difference(last).inHours < 24) return;
  // ignore: unawaited_futures
  service.autoBackupIfConnected();
}
