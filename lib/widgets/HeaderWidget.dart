import 'package:flutter/material.dart';

AppBar header(BuildContext context, {bool isAppTitle = false, String title, disappearedBackButton = false}) {
  return AppBar(
    iconTheme: IconThemeData(
      color: Colors.white,
    ),
    automaticallyImplyLeading: disappearedBackButton ? false : true,
    title: Text(
      isAppTitle ? 'Instargram by kyungsnim' : title,
      style: TextStyle(
        color: Colors.white,
        fontFamily: isAppTitle ? 'Signatra' : '',
        fontSize: isAppTitle ? 45 : 22,
      ),
      overflow: TextOverflow.ellipsis,
    ),
    centerTitle: true,
    backgroundColor: Colors.black,
  );
}
