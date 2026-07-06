import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'palette.dart';
import 'tokens.dart';

/// Surface temperature — spec §3.1 "playful shelf, trustworthy till".
/// Browse surfaces run warm with illustration; cart→checkout→account drop to
/// white/ink, denser type, no bounce.
enum SurfaceMode { playful, trusted }

abstract final class AppTheme {
  /// Type scale (1.25 ratio): 32/28/22/18 headings, 16 body, 14 secondary,
  /// 12 caption. Arabic gets +8% line height.
  static TextTheme _textTheme(String languageCode) {
    final isAr = languageCode == 'ar';
    final bodyHeight = isAr ? 1.62 : 1.5;
    final headingHeight = isAr ? 1.3 : 1.2;

    TextStyle display(double size, FontWeight weight) => GoogleFonts.balooBhaijaan2(
          fontSize: size,
          fontWeight: weight,
          height: headingHeight,
          color: AppPalette.ink,
        );
    TextStyle body(double size, FontWeight weight) => GoogleFonts.ibmPlexSansArabic(
          fontSize: size,
          fontWeight: weight,
          height: bodyHeight,
          color: AppPalette.ink,
        );

    return TextTheme(
      displayLarge: display(32, FontWeight.w700),
      displayMedium: display(28, FontWeight.w700),
      headlineMedium: display(22, FontWeight.w600),
      titleLarge: display(18, FontWeight.w600),
      titleMedium: body(16, FontWeight.w600),
      titleSmall: body(14, FontWeight.w600),
      bodyLarge: body(16, FontWeight.w400),
      bodyMedium: body(14, FontWeight.w400),
      bodySmall: body(12, FontWeight.w400),
      labelLarge: body(16, FontWeight.w600),
      labelMedium: body(14, FontWeight.w500),
      labelSmall: body(12, FontWeight.w500),
    );
  }

  static ThemeData light(String languageCode) {
    final textTheme = _textTheme(languageCode);
    const scheme = ColorScheme(
      brightness: Brightness.light,
      primary: AppPalette.coral,
      onPrimary: AppPalette.white,
      secondary: AppPalette.teal,
      onSecondary: AppPalette.white,
      tertiary: AppPalette.sunshine,
      onTertiary: AppPalette.ink,
      error: AppPalette.error,
      onError: AppPalette.white,
      surface: AppPalette.white,
      onSurface: AppPalette.ink,
      surfaceContainerLowest: AppPalette.cream,
      surfaceContainerLow: AppPalette.sky,
      outline: AppPalette.hairline,
      onSurfaceVariant: AppPalette.inkMuted,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: AppPalette.cream,
      textTheme: textTheme,
      splashFactory: InkRipple.splashFactory,
      appBarTheme: AppBarTheme(
        backgroundColor: AppPalette.cream,
        foregroundColor: AppPalette.ink,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: textTheme.headlineMedium,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppPalette.coral,
          foregroundColor: AppPalette.white,
          minimumSize: const Size(48, 48),
          textStyle: textTheme.labelLarge,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: Corners.buttonRadius),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppPalette.teal,
          minimumSize: const Size(48, 48),
          textStyle: textTheme.labelLarge,
          side: const BorderSide(color: AppPalette.teal, width: 1.5),
          shape: RoundedRectangleBorder(borderRadius: Corners.buttonRadius),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppPalette.teal,
          minimumSize: const Size(48, 48),
          textStyle: textTheme.labelLarge,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppPalette.white,
        contentPadding: const EdgeInsetsDirectional.symmetric(
            horizontal: Gap.lg, vertical: Gap.md),
        border: OutlineInputBorder(
          borderRadius: Corners.chipRadius,
          borderSide: const BorderSide(color: AppPalette.hairline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: Corners.chipRadius,
          borderSide: const BorderSide(color: AppPalette.hairline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: Corners.chipRadius,
          borderSide: const BorderSide(color: AppPalette.teal, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: Corners.chipRadius,
          borderSide: const BorderSide(color: AppPalette.error),
        ),
        hintStyle: textTheme.bodyMedium?.copyWith(color: AppPalette.inkMuted),
        labelStyle: textTheme.bodyMedium?.copyWith(color: AppPalette.inkMuted),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppPalette.white,
        selectedColor: AppPalette.teal,
        labelStyle: textTheme.labelMedium,
        shape: RoundedRectangleBorder(
          borderRadius: Corners.chipRadius,
          side: const BorderSide(color: AppPalette.hairline),
        ),
      ),
      dividerTheme: const DividerThemeData(color: AppPalette.hairline, thickness: 1),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppPalette.ink,
        contentTextStyle: textTheme.bodyMedium?.copyWith(color: AppPalette.white),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: Corners.buttonRadius),
      ),
      cardTheme: CardThemeData(
        color: AppPalette.white,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: Corners.cardRadius),
        margin: EdgeInsets.zero,
      ),
    );
  }
}
