import 'package:flutter/material.dart';
import 'package:instargram_clone_by_kyungsnim/pages/HomePage.dart';

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
        scaffoldBackgroundColor: Colors.black,
        dialogBackgroundColor: Colors.deepPurple,
        primaryColor: Colors.grey,
        cardColor: Colors.black,
        accentColor: Colors.purpleAccent,
      ),
      home: HomePage(),
    );
  }
}
