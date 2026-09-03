import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get dark {
    final base = ThemeData.dark(useMaterial3: true);
    final display = GoogleFonts.orbitronTextTheme(base.textTheme);
    final body = GoogleFonts.manropeTextTheme(base.textTheme);

    return base.copyWith(
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.gps,
        secondary: AppColors.fusion,
        surface: AppColors.surface,
        error: AppColors.danger,
      ),
      textTheme: body.copyWith(
        displayLarge: display.displayLarge?.copyWith(color: AppColors.textPrimary),
        displayMedium: display.displayMedium?.copyWith(color: AppColors.textPrimary),
        headlineLarge: display.headlineLarge?.copyWith(
          color: AppColors.textPrimary,
          letterSpacing: 1.2,
        ),
        headlineMedium: display.headlineMedium?.copyWith(
          color: AppColors.textPrimary,
          letterSpacing: 1.0,
        ),
        headlineSmall: display.headlineSmall?.copyWith(
          color: AppColors.textPrimary,
          letterSpacing: 0.8,
        ),
        titleLarge: body.titleLarge?.copyWith(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w700,
        ),
        titleMedium: body.titleMedium?.copyWith(color: AppColors.textPrimary),
        bodyLarge: body.bodyLarge?.copyWith(color: AppColors.textPrimary),
        bodyMedium: body.bodyMedium?.copyWith(color: AppColors.textSecondary),
        labelLarge: body.labelLarge?.copyWith(
          color: AppColors.textPrimary,
          letterSpacing: 0.6,
        ),
      ),
      iconTheme: const IconThemeData(color: AppColors.textPrimary),
      dividerColor: AppColors.hairline,
      splashFactory: InkSparkle.splashFactory,
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.gps,
          foregroundColor: AppColors.background,
          textStyle: body.labelLarge?.copyWith(fontWeight: FontWeight.w700),
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: AppColors.textSecondary),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.textPrimary,
          side: const BorderSide(color: AppColors.hairline),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
    );
  }
}
