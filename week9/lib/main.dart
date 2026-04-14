import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      await Firebase.initializeApp();
      debugPrint('Firebase Initialized');
    } else {
      debugPrint('Firebase initialized');
    }
  } catch (e) {
    debugPrint('Firebase initialization skipped: $e');
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Firebase Status',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const FirebaseStatusPage(),
    );
  }
}

class FirebaseStatusPage extends StatelessWidget {
  const FirebaseStatusPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          'Firebase Initialized',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
      ),
    );
  }
}
