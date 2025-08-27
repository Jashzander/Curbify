import 'package:flutter/material.dart';
// Square Reader SDK removed. Show a simple placeholder.

class Payment extends StatelessWidget {
  const Payment({super.key, required this.company});
  final String? company;

  @override
  Widget build(BuildContext context) => MaterialApp(
        theme: _buildTheme(),
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          appBar: AppBar(title: const Text('Payment')),
          body: Center(
            child: Text(
              'Payments are not configured. Company: ' + (company ?? 'Unknown'),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
}

// override default theme
ThemeData _buildTheme() {
  var base = ThemeData.light();
  return base.copyWith(
    canvasColor: Colors.transparent,
    scaffoldBackgroundColor: const Color.fromRGBO(64, 135, 225, 1.0),
    buttonTheme: const ButtonThemeData(
      height: 64.0,
    ),
    hintColor: Colors.transparent,
    inputDecorationTheme: const InputDecorationTheme(
      labelStyle: TextStyle(
        color: Colors.white,
      ),
    ),
    textTheme: const TextTheme(
        labelLarge: TextStyle(
          fontSize: 20.0,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        bodyLarge: TextStyle(
          fontSize: 24.0,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        )),
    colorScheme: const ColorScheme(
      brightness: Brightness.light,
      primary: Color.fromRGBO(64, 135, 225, 1.0),
      onPrimary: Colors.white,
      secondary: Colors.grey,
      onSecondary: Colors.white,
      error: Colors.red,
      onError: Colors.white,
      surface: Colors.white,
      onSurface: Colors.black,
    ),
  );
}
