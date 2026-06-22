import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'app/app.dart';
import 'core/constants/app_config.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Required by google_sign_in v7 before any Drive call. Web uses the OAuth
  // web client as clientId; Android requires serverClientId instead.
  await GoogleSignIn.instance.initialize(
    clientId: kIsWeb ? AppConfig.googleWebClientId : null,
    serverClientId: kIsWeb ? null : AppConfig.googleServerClientId,
  );
  runApp(const GoldBarApp());
}
