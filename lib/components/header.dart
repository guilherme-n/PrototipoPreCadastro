import 'package:flutter/material.dart';

AppBar header({bool isAppTitle = false, String texto}) {
  return AppBar(
    title: Text(
      isAppTitle ? "Pre cadastro" : texto,
      style: TextStyle(
        fontSize: isAppTitle ? 50.0 : 22.0,
      ),
    ),
  );
}
