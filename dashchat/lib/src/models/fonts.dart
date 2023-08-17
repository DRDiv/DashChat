import 'package:flutter/material.dart';

class AppFonts {
  final String primaryFont;
  final String secondaryFont;
  final String accentFont;
  final String headingFont;
  final String bodyFont;

  AppFonts(
      {required this.primaryFont,
      required this.accentFont,
      required this.headingFont,
      required this.bodyFont,
      required this.secondaryFont});

  factory AppFonts.defaultFonts() {
    return AppFonts(
      primaryFont: 'Gloria', // Default primary font
      accentFont: 'PermanentMarker', // Default accent font
      headingFont: 'Pacifico', // Default heading font
      bodyFont: 'Caveat', // Default body font
      secondaryFont: 'RockSalt', // Default secondary font
    );
  }
}
