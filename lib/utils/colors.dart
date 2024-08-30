import 'package:flutter/material.dart';

class AppColors {

  static const MaterialColor mainColor = MaterialColor(
    0XFF90D26D,
    <int, Color>{
      50: Color(0XFF90D26D), //10%
      100: Color(0XFF90D26D), //20%
      200: Color(0XFF90D26D), //30%
      300: Color(0XFF90D26D), //40%
      400: Color(0XFF90D26D), //50%
      500: Color(0XFF90D26D), //60%
      600: Color(0XFF90D26D), //70%
      700: Color(0XFF90D26D), //80%
      800: Color(0XFF90D26D), //90%
      900: Color(0XFF90D26D), //100%
    },
  );

  static final lightDeepPurple = mainColor.withOpacity(0.5);
  static const sidebarColor = Color(0XFF262432);
  static const scaffoldColor = Color(0XFFf8f9fa);
}
