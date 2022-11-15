import 'package:flutter/material.dart';

const defaultBoardSize = 5;
const goblinOneFontFamily = "Goblin One";
const appTitle = "Lights Out!";

const buttonStyle = ButtonStyle(
  backgroundColor: MaterialStatePropertyAll(Color(0xFF455A64)),
  padding: MaterialStatePropertyAll(
      EdgeInsets.symmetric(horizontal: 8.0, vertical: 16.0)),
  textStyle: MaterialStatePropertyAll(buttonTextStyle),
);

const splashTextStyle = TextStyle(
  fontFamily: goblinOneFontFamily,
  fontSize: 60.0,
  color: Colors.white,
);

const headerTextStyle = TextStyle(
  fontFamily: goblinOneFontFamily,
  fontSize: 20.0,
  color: Colors.white,
);

const bodyTextStyle = TextStyle(
  fontFamily: goblinOneFontFamily,
  fontSize: 15.0,
  color: Colors.white,
);

const buttonTextStyle = TextStyle(
  fontFamily: goblinOneFontFamily,
  color: Colors.white,
);
