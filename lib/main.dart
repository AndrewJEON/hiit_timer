import 'package:flutter/material.dart';

import 'home.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Interval Timer',
      theme: theme(),
      home: Home(),
      debugShowCheckedModeBanner: false,
    );
  }

  ThemeData theme() {
    return ThemeData(
      primarySwatch: Colors.blue,
      inputDecorationTheme: InputDecorationTheme(
        border: InputBorder.none,
      ),
      visualDensity: VisualDensity.adaptivePlatformDensity,
    );
  }
}
