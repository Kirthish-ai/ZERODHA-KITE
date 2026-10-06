import 'package:flutter/material.dart';

class KiteTheme {
  // Dark Palette
  static const Color darkBg = Color(0xFF121418);
  static const Color panelBg = Color(0xFF1E222D);
  static const Color headerBg = Color(0xFF181B20);
  static const Color sidebarBg = Color(0xFF14171D);
  static const Color hoverBg = Color(0xFF262B38);
  static const Color border = Color(0xFF2A2E39);

  // Status Colors
  static const Color green = Color(0xFF00D09C);
  static const Color greenBg = Color(0x1F00D09C);
  static const Color red = Color(0xFFFF4D4F);
  static const Color redBg = Color(0x1FFF4D4F);
  static const Color orange = Color(0xFFFF9800);
  static const Color kiteBlue = Color(0xFF387ED1);
  static const Color zerodhaOrange = Color(0xFFFF5722);

  // Text Colors
  static const Color textPrimary = Color(0xFFE0E3EB);
  static const Color textSecondary = Color(0xFF8E94A5);
  static const Color textMuted = Color(0xFF5E6577);

  static ThemeData get darkTheme {
    return ThemeData.dark().copyWith(
      scaffoldBackgroundColor: darkBg,
      primaryColor: kiteBlue,
      cardColor: panelBg,
      dividerColor: border,
      dialogBackgroundColor: panelBg,
      colorScheme: const ColorScheme.dark(
        primary: kiteBlue,
        secondary: zerodhaOrange,
        surface: panelBg,
        background: darkBg,
        error: red,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: headerBg,
        elevation: 0,
        titleTextStyle: TextStyle(color: textPrimary, fontSize: 16, fontWeight: FontWeight.w600),
      ),
      tabBarTheme: const TabBarThemeData(
        labelColor: kiteBlue,
        unselectedLabelColor: textSecondary,
        indicatorSize: TabBarIndicatorSize.tab,
      ),
      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: textPrimary, fontSize: 14),
        bodyMedium: TextStyle(color: textPrimary, fontSize: 13),
        bodySmall: TextStyle(color: textSecondary, fontSize: 12),
        titleLarge: TextStyle(color: textPrimary, fontSize: 18, fontWeight: FontWeight.bold),
        titleMedium: TextStyle(color: textPrimary, fontSize: 15, fontWeight: FontWeight.w600),
      ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: const Color(0xFF333846),
          borderRadius: BorderRadius.circular(4),
        ),
        textStyle: const TextStyle(color: Colors.white, fontSize: 11),
      ),
    );
  }
}
