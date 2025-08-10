import 'package:flutter/material.dart';

class ErrorHandler {
  static void init() {
    FlutterError.onError = (FlutterErrorDetails details) {
      // Log the error
      // print(details.exception);
      // Show a dialog to the user
      // This is a basic example, you can customize it as you wish
      runApp(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: Text(
                'An unexpected error occurred. Please restart the app.',
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      );
    };
  }
}
