import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'app/app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Required by google_sign_in v7 before any Drive call.
  await GoogleSignIn.instance.initialize(
    serverClientId:
        '833854972385-n4p30ffkidfgnhut5de9nm63u0a5n01o.apps.googleusercontent.com',
  );
  runApp(const GoldBarApp());
}
