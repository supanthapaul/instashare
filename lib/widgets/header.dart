import 'package:flutter/material.dart';

header(context,
    {bool isAppTitle = false,
    String titleText,
    bool removeBackButton = false}) {
  return AppBar(
    automaticallyImplyLeading: !removeBackButton,
    title: Text(
      isAppTitle ? "InstaShare" : titleText,
      style: TextStyle(
        color: Colors.white,
        fontFamily: isAppTitle ? "Signatra" : "",
        fontSize: isAppTitle ? 50.0 : 22.0,
      ),
    ),
    centerTitle: true,
    backgroundColor: Theme.of(context).accentColor,
  );
}
