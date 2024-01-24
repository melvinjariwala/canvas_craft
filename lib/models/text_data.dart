import 'package:flutter/material.dart';

class TextData {
  String text;
  Offset position;
  Color textColor;
  double fontSize;
  double boxSize;

  TextData(
      {required this.text,
      required this.position,
      required this.textColor,
      required this.fontSize,
      required this.boxSize});

  TextData snapshot() {
    return TextData(
        text: text,
        position: position,
        textColor: textColor,
        fontSize: fontSize,
        boxSize: boxSize);
  }
}
