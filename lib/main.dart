import 'package:flutter/material.dart';

import './mainpage/home.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "My Schedule",
      theme: ThemeData(
        primaryTextTheme: TextTheme(
          title: TextStyle(color: Colors.white, fontSize: 25),
        ),
        primarySwatch: Colors.blue,
      ),
      home: Home(),
    );
  }
}
