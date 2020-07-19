import 'package:flutter/material.dart';

import 'core/service_locator.dart';
import 'home.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initServiceLocator();
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
