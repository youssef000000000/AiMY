import 'package:flutter/material.dart';

/// AiMY dark futuristic palette: neon blue/purple on dark gradient base.
class AppColors {
  AppColors._();

  // Backgrounds
  static const Color background = Color(0xFF0D1117);
  static const Color backgroundGradientStart = Color(0xFF0D1117);
  static const Color backgroundGradientEnd = Color(0xFF161B22);
  static const Color surface = Color(0xFF161B22);
  static const Color sidebarBackground = Color(0xFF0D1117);
  static const Color cardBackground = Color(0x1A21262D);
  static const Color inputBackground = Color(0xFF21262D);

  // Accents - neon blue / purple
  static const Color primary = Color(0xFF58A6FF);
  static const Color primaryGlow = Color(0x3358A6FF);
  static const Color secondary = Color(0xFFA371F7);
  static const Color secondaryGlow = Color(0x33A371F7);
  static const Color accentBlue = Color(0xFF58A6FF);
  static const Color accentPurple = Color(0xFFA371F7);

  // Text
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color onSecondary = Color(0xFFE6EDF3);
  static const Color onSurface = Color(0xFFE6EDF3);
  static const Color textMuted = Color(0xFF8B949E);
  static const Color textSecondary = Color(0xFFB1BAC4);

  // UI
  static const Color border = Color(0xFF30363D);
  static const Color borderGlow = Color(0x4D58A6FF);
  static const Color selectedBackground = Color(0x1A58A6FF);
  static const Color error = Color(0xFFF85149);
  static const Color onError = Color(0xFFFFFFFF);

  /// Linear gradient for main background.
  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [backgroundGradientStart, backgroundGradientEnd],
  );

  /// Gradient for titles and active states.
  static const LinearGradient accentGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [accentBlue, accentPurple],
  );
}
