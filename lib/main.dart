import 'package:flutter/material.dart';
import 'package:cargoclick/theme.dart';
import 'package:cargoclick/screens/login_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cargoclick/firebase_options.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize Firebase only if not already initialized (avoids web assertion on duplicate init).
  if (Firebase.apps.isEmpty) {
    // Use generated options for all platforms, including web, to avoid web assertion.
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CargoClick',
      debugShowCheckedModeBanner: false,
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: ThemeMode.light,
      home: const LoginPage(),
    );
  }
}
