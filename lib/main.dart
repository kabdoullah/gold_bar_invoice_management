import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'app/app.dart';
import 'core/constants/app_config.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Required by google_sign_in v7 before any Drive call.
  await GoogleSignIn.instance.initialize(
    serverClientId: AppConfig.googleServerClientId,
  );
  runApp(const GoldBarApp());
}
