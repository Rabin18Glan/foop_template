import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      primarySwatch: Colors.blue,
      brightness: Brightness.light,
      appBarTheme: const AppBarTheme(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      scaffoldBackgroundColor: Colors.white,
      cardTheme: const CardTheme(
        elevation: 2,
        margin: EdgeInsets.all(8),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      primarySwatch: Colors.blue,
      brightness: Brightness.dark,
      appBarTheme: AppBarTheme(
        elevation: 0,
        backgroundColor: Colors.grey[900],
      ),
      scaffoldBackgroundColor: Colors.grey[900],
      cardTheme: const CardTheme(
        elevation: 2,
        margin: EdgeInsets.all(8),
      ),
    );
  }
}
