import 'package:flutter/material.dart';

import 'homeScreen/screens/homeScreen.dart';

void main() async {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Foodly',
        initialRoute: "/",
        routes: {
          "/": (context) => HomeScreen(),
          // "home": (context) => HomeScreen(),
        });
  }
}
