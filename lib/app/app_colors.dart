import 'package:flutter/material.dart';

abstract final class AppColors {
  // Brand
  static const Color brandPrimary = Color(0xFF6347D1);
  static const Color brandSecondary = Color(0xFF755CE0);
  static const Color brandSoftSurface = Color(0xFFF6F4FD);
  static const Color brandPrimaryLight = Color(0xFFEDE9FE);

  // Status / Accent
  static const Color secondaryColor = Color(0xFF059669);
  static const Color secondaryLight = Color(0xFFECFDF5);
  static const Color accentColor = Color(0xFFD97706);
  static const Color accentLight = Color(0xFFFFFBEB);

  // Canvas & Surfaces
  static const Color backgroundColor = Color(0xFFF8FAFC);
  static const Color surfaceColor = Colors.white;
  static const Color borderColor = Color(0xFFE2E8F0);
  static const Color neutralD2 = Color(0xFFD2D2D2);

  // Figma Text Tokens
  static const Color textPrimary = Color(0xFF282828);
  static const Color textDark = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textMuted = Color(0xFF94A3B8);
  static const Color textTertiary = Color(0xFF94A3B8);

  // Spending Breakdown Categories
  static const Color categoryBills = Color(0xFF5162B8);
  static const Color categoryGrocery = Color(0xFF73B851);
  static const Color categoryShopping = Color(0xFFB89951);
  static const Color categoryOther = Color(0xFFA0A0A0);
  // Modal Background Gradient
  static const Color modalGradientStart = Color(0xFFFFFFFF);
  static const Color modalGradientEnd = Color(0xFFC8B7FF);

  // Figma Modal Sheet Gradient (0% #FFFFFF -> 100% #C8B7FF)
  static const LinearGradient modalSheetGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    stops: [0.0, 1.0],
    colors: [Color(0xFFFFFFFF), Color(0xFFC8B7FF)],
  );
  // Screen Gradients
  static const List<Color> insightsGradient = [
    Color(0xFF6347D1),
    Color(0xFF755CE0),
    Color(0xFFCDC8EB),
    Color(0xFFE8E5F4),
  ];
}
