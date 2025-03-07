import 'package:flutter/material.dart';

Widget textWidget(
    {required String text,
    double fontSize = 12,
    
    FontWeight fontWeight = FontWeight.normal}) {
  return Text(
    text,
    style: TextStyle(fontSize: fontSize, fontWeight: fontWeight),
  );
}
