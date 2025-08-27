import 'package:flutter/material.dart';
// import 'package:homepage/login.dart';
import 'package:provider/provider.dart';
// import 'homepage.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:firebase_core/firebase_core.dart';
import 'theme_provider.dart';
import 'login.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase
      .initializeApp(); // Initialize Firebase (before running the app)

  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(), // Initialize the ThemeProvider
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Phoenix(
          child: const Start(),
        ),
      ),
    ),
  );
}

