// core/theme/app_theme.dart
import 'package:flutter/material.dart';

class AppTheme {
  static final ThemeData lightTheme = ThemeData(
    primaryColor: Colors.blueGrey[900], // 主要颜色，深色调的蓝灰色
    colorScheme: ColorScheme(
      primary: Colors.blueGrey[900]!, // 主颜色
      onPrimary: Colors.white, // 主颜色上的文本颜色
      secondary: Colors.amber, // 辅助颜色
      onSecondary: Colors.black, // 辅助颜色上的文本颜色
      surface: Colors.white, // 表面颜色
      onSurface: Colors.black, // 表面上的文本颜色
      background: Colors.grey[100]!, // 背景颜色
      onBackground: Colors.black, // 背景上的文本颜色
      error: Colors.red[700]!, // 错误颜色
      onError: Colors.white, // 错误颜色上的文本颜色
      brightness: Brightness.light, // 明亮模式
    ),
    scaffoldBackgroundColor: Colors.grey[100], // 背景颜色，浅灰色
    fontFamily: 'Arial', // 更经典的字体选择

    // 文本主题
    textTheme: const TextTheme(
      headlineLarge: TextStyle(color: Colors.black, fontSize: 24, fontWeight: FontWeight.bold),
      bodyMedium: TextStyle(color: Colors.black, fontSize: 16),
    ),

    // AppBar主题
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.blueGrey[900],
      titleTextStyle: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
      iconTheme: const IconThemeData(color: Colors.white),
      elevation: 0,
    ),

    // 底部导航栏主题
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      // backgroundColor: Colors.white,
      selectedItemColor: Colors.amber[800],
      unselectedItemColor: Colors.blueGrey[600],
      selectedLabelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
      unselectedLabelStyle: const TextStyle(fontSize: 12),
    ),

    // 按钮主题
    buttonTheme: const ButtonThemeData(
      buttonColor: Colors.amber,
      textTheme: ButtonTextTheme.primary,
    ),

    // 输入框主题
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.grey[200],
      contentPadding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30.0),
        borderSide: BorderSide.none,
      ),
    ),
  );
}
