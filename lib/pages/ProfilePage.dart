import 'package:flutter/material.dart';
import 'package:instargram_clone_by_kyungsnim/widgets/HeaderWidget.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: header(context, isAppTitle: false, title: 'Profile',),
    );
  }
}
