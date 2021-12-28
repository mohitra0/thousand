import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';

class AppTheme {
  get darkTheme => ThemeData(
        primarySwatch: Colors.grey,
        appBarTheme:
            AppBarTheme(brightness: Brightness.dark, color: Colors.white),
        inputDecorationTheme: InputDecorationTheme(
          hintStyle: TextStyle(color: Colors.grey),
          labelStyle: TextStyle(color: Colors.white),
        ),
        brightness: Brightness.dark,
        canvasColor: Colors.grey[800],
        accentColor: Colors.pink,
        accentIconTheme: IconThemeData(color: Colors.white),
        bottomAppBarColor: Colors.white,
      );

  get lightTheme => ThemeData(
        primarySwatch: Colors.grey,
        appBarTheme: AppBarTheme(
          // brightness: Brightness.light,
          color: Colors.black,
        ),
        inputDecorationTheme: InputDecorationTheme(
          hintStyle: TextStyle(color: Colors.grey),
          labelStyle: TextStyle(color: Colors.white),
        ),
        canvasColor: Colors.white.withOpacity(0.8),
        brightness: Brightness.light,
        accentColor: HexColor('#6200EE'),
        backgroundColor: Colors.white,
        textSelectionColor: Colors.white.withOpacity(1),
        bottomAppBarColor: HexColor('#6200EE'),
        buttonColor: Colors.black87,
        dividerColor: HexColor('#6200EE'),
        accentIconTheme: IconThemeData(color: Colors.white),
      );
}
