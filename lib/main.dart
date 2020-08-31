import 'package:flutter/material.dart';
import 'package:instargram_clone_by_kyungsnim/pages/home_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.deepPurpleAccent,
        dialogBackgroundColor: Colors.deepPurple,
        primaryColor: Colors.grey,
        cardColor: Colors.white70,
        accentColor: Colors.purpleAccent,
      ),
      home: HomePage(),
    );
  }
}
