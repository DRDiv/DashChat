import 'package:flutter/material.dart';

class AppColorScheme {
  final Color primaryColor;
  final Color accentColor;
  final Color backgroundColor;
  final Color chatBubbleUserBackground;
  final Color chatBubbleOtherUserBackground;
  final Color textColorPrimary;
  final Color textColorSecondary;
  final Color textColorAccent;
  final Color textColorLight;
  final Color buttonColor;
  final Color buttonText;
  final Color errorColor;
  final Color warningColor;
  final Color successColor;
  final Color infoColor;
  final Color dividerColor;
  final Color primaryColorVariant1;
  final Color primaryColorVariant2;
  final Color primaryColorVariant3;
  final Color primaryColorVariant4;
  AppColorScheme({
    required this.primaryColor,
    required this.accentColor,
    required this.backgroundColor,
    required this.chatBubbleUserBackground,
    required this.chatBubbleOtherUserBackground,
    required this.textColorPrimary,
    required this.textColorSecondary,
    required this.textColorAccent,
    required this.textColorLight,
    required this.buttonColor,
    required this.buttonText,
    required this.errorColor,
    required this.warningColor,
    required this.successColor,
    required this.infoColor,
    required this.dividerColor,
    required this.primaryColorVariant1,
    required this.primaryColorVariant2,
    required this.primaryColorVariant3,
    required this.primaryColorVariant4,
  });

  factory AppColorScheme.defaultScheme() {
    return AppColorScheme(
      primaryColor: const Color(0xFF1976D2), // Deep Blue
      accentColor: const Color(0xFF00ACC1), // Cyan
      backgroundColor: const Color(0xFFE0E0E0), // Light Gray
      chatBubbleUserBackground: const Color(0xFFB3E5FC), // Light Blue
      chatBubbleOtherUserBackground: const Color(0xFFFFFFFF), // White
      textColorPrimary: const Color(0xFF333333), // Dark Gray
      textColorSecondary: const Color(0xFF666666), // Mid Gray
      textColorAccent: const Color(0xFF00ACC1), // Cyan
      textColorLight: const Color(0xFFFFFFFF), // White
      buttonColor: const Color(0xFF00ACC1), // Cyan
      buttonText: const Color(0xFFFFFFFF), // White
      errorColor: const Color(0xFFF44336), // Red
      warningColor: const Color(0xFFFFC107), // Amber
      successColor: const Color(0xFF4CAF50), // Green
      infoColor: const Color(0xFF2196F3), // Blue
      dividerColor: const Color(0xFFBDBDBD), // Light Gray
      primaryColorVariant1: const Color(0xFF9C27B0), // Purple
      primaryColorVariant2: const Color(0xFFE91E63), // Pink
      primaryColorVariant3: const Color(0xFF2196F3), // Blue
      primaryColorVariant4: const Color(0xFFFF5722), // Deep Orange
    );
  }
}
