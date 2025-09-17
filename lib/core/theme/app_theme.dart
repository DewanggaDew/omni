import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Apple-inspired spacing system with refined hierarchy
  static const double space2 = 2.0;
  static const double space4 = 4.0;
  static const double space6 = 6.0;
  static const double space8 = 8.0;
  static const double space12 = 12.0;
  static const double space16 = 16.0;
  static const double space20 = 20.0;
  static const double space24 = 24.0;
  static const double space28 = 28.0;
  static const double space32 = 32.0;
  static const double space40 = 40.0;
  static const double space48 = 48.0;
  static const double space64 = 64.0;
  static const double space80 = 80.0;

  // Border radius with Apple-like smoothness
  static const double radiusXS = 6.0;
  static const double radiusS = 10.0;
  static const double radiusM = 14.0;
  static const double radiusL = 18.0;
  static const double radiusXL = 24.0;
  static const double radiusXXL = 32.0;

  // Elegant color palette
  static const Color deepBlack = Color(0xFF000000);
  static const Color richBlack = Color(0xFF0A0A0A);
  static const Color charcoalBlack = Color(0xFF0F0F0F);
  static const Color darkGrey = Color(0xFF1A1A1A);
  static const Color mediumGrey = Color(0xFF2A2A2A);
  static const Color lightGrey = Color(0xFF3A3A3A);
  static const Color softGrey = Color(0xFF6A6A6A);
  static const Color pureWhite = Color(0xFFFFFFFF);
  static const Color offWhite = Color(0xFFF8F8F8);
  static const Color lightTone = Color(0xFFF2F2F7);

  // Accent colors (use minimally in the new monochrome system)
  static const Color vibrantBlue = Color(0xFF007AFF); // legacy, avoid
  static const Color emeraldGreen = Color(0xFF30D158); // legacy, avoid
  static const Color warmRed = Color(0xFFD93D3D); // error only
  static const Color goldenYellow = Color(0xFFFFCC02); // legacy
  static const Color richPurple = Color(0xFF5856D6); // legacy

  static ThemeData light() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: deepBlack,
        brightness: Brightness.light,
        surface: pureWhite,
        onSurface: charcoalBlack,
        primary: deepBlack,
        onPrimary: pureWhite,
        error: warmRed,
        outline: softGrey,
      ),
      visualDensity: VisualDensity.adaptivePlatformDensity,
      textTheme: _buildTextTheme(Brightness.light),
      scaffoldBackgroundColor: pureWhite,
      splashColor: charcoalBlack.withValues(alpha: 0.06),
      highlightColor: charcoalBlack.withValues(alpha: 0.03),
      cardTheme: CardThemeData(
        elevation: 0,
        shadowColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        color: pureWhite,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusM),
          side: BorderSide(color: Colors.black.withOpacity(0.06)),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: deepBlack,
          foregroundColor: pureWhite,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(
            horizontal: space24,
            vertical: space16,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusM),
          ),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: deepBlack,
          foregroundColor: pureWhite,
          padding: const EdgeInsets.symmetric(
            horizontal: space24,
            vertical: space16,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusM),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: charcoalBlack,
          side: BorderSide(color: Colors.black.withOpacity(0.12)),
          padding: const EdgeInsets.symmetric(
            horizontal: space24,
            vertical: space16,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusM),
          ),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: pureWhite,
        elevation: 0,
        indicatorColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final isSelected = states.contains(WidgetState.selected);
          return IconThemeData(
            color: isSelected
                ? charcoalBlack
                : charcoalBlack.withValues(alpha: 0.5),
            size: 24,
          );
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final isSelected = states.contains(WidgetState.selected);
          return TextStyle(
            color: isSelected
                ? charcoalBlack
                : charcoalBlack.withValues(alpha: 0.5),
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            fontSize: 12,
          );
        }),
      ),
      dividerTheme: DividerThemeData(
        color: softGrey.withValues(alpha: 0.2),
        thickness: 0.5,
        space: space16,
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: pureWhite,
        surfaceTintColor: Colors.transparent,
        elevation: 8,
        shadowColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(radiusXL)),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: pureWhite,
        surfaceTintColor: Colors.transparent,
        elevation: 8,
        shadowColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusL),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.black.withOpacity(0.03),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusM),
          borderSide: BorderSide(color: Colors.black.withOpacity(0.12)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusM),
          borderSide: BorderSide(color: charcoalBlack, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: space16,
          vertical: space16,
        ),
        hintStyle: TextStyle(color: softGrey.withValues(alpha: 0.9)),
        labelStyle: TextStyle(color: Colors.black.withOpacity(0.7)),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        foregroundColor: charcoalBlack,
        titleTextStyle: TextStyle(
          color: charcoalBlack,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        iconTheme: IconThemeData(color: charcoalBlack, size: 24),
      ),
    );
  }

  static ThemeData dark() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: pureWhite,
        brightness: Brightness.dark,
        surface: richBlack,
        onSurface: lightTone,
        primary: pureWhite,
        onPrimary: deepBlack,
        error: warmRed,
        outline: softGrey,
        surfaceContainerHighest: darkGrey,
        onSurfaceVariant: lightTone.withValues(alpha: 0.8),
      ),
      visualDensity: VisualDensity.adaptivePlatformDensity,
      textTheme: _buildTextTheme(Brightness.dark),
      scaffoldBackgroundColor: deepBlack,
      splashColor: pureWhite.withValues(alpha: 0.06),
      highlightColor: pureWhite.withValues(alpha: 0.03),
      cardTheme: CardThemeData(
        elevation: 0,
        shadowColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        color: charcoalBlack,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusM),
          side: BorderSide(color: darkGrey),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: pureWhite,
          foregroundColor: deepBlack,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(
            horizontal: space24,
            vertical: space16,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusM),
          ),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: pureWhite,
          foregroundColor: deepBlack,
          padding: const EdgeInsets.symmetric(
            horizontal: space24,
            vertical: space16,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusM),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: lightTone,
          side: BorderSide(color: darkGrey),
          padding: const EdgeInsets.symmetric(
            horizontal: space24,
            vertical: space16,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusM),
          ),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: richBlack,
        elevation: 0,
        indicatorColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final isSelected = states.contains(WidgetState.selected);
          return IconThemeData(
            color: isSelected ? lightTone : lightTone.withValues(alpha: 0.6),
            size: 24,
          );
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final isSelected = states.contains(WidgetState.selected);
          return TextStyle(
            color: isSelected ? lightTone : lightTone.withValues(alpha: 0.6),
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            fontSize: 12,
          );
        }),
      ),
      dividerTheme: DividerThemeData(
        color: darkGrey,
        thickness: 0.5,
        space: space16,
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: richBlack,
        surfaceTintColor: Colors.transparent,
        elevation: 8,
        shadowColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(radiusXL)),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: richBlack,
        surfaceTintColor: Colors.transparent,
        elevation: 8,
        shadowColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusL),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: darkGrey,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusM),
          borderSide: BorderSide(color: darkGrey),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusM),
          borderSide: BorderSide(color: pureWhite, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: space16,
          vertical: space16,
        ),
        hintStyle: TextStyle(color: lightTone.withValues(alpha: 0.5)),
        labelStyle: TextStyle(color: lightTone.withValues(alpha: 0.7)),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        foregroundColor: lightTone,
        titleTextStyle: TextStyle(
          color: lightTone,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        iconTheme: IconThemeData(color: lightTone, size: 24),
      ),
    );
  }

  static TextTheme _buildTextTheme(Brightness brightness) {
    final baseColor = brightness == Brightness.light
        ? charcoalBlack
        : lightTone;

    final subtleColor = brightness == Brightness.light
        ? charcoalBlack.withValues(alpha: 0.8)
        : lightTone.withValues(alpha: 0.8);

    final secondaryColor = brightness == Brightness.light
        ? charcoalBlack.withValues(alpha: 0.6)
        : lightTone.withValues(alpha: 0.6);

    final base = GoogleFonts.interTextTheme();

    return base.copyWith(
      // Large display text - for major headings
      displayLarge: base.displayLarge?.copyWith(
        fontSize: 36,
        fontWeight: FontWeight.w700,
        color: baseColor,
        height: 1.1,
        letterSpacing: -0.5,
      ),
      displayMedium: base.displayMedium?.copyWith(
        fontSize: 30,
        fontWeight: FontWeight.w600,
        color: baseColor,
        height: 1.15,
        letterSpacing: -0.3,
      ),
      displaySmall: base.displaySmall?.copyWith(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: baseColor,
        height: 1.2,
        letterSpacing: -0.2,
      ),

      // Headlines - for section headers
      headlineLarge: base.headlineLarge?.copyWith(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: baseColor,
        height: 1.25,
        letterSpacing: -0.1,
      ),
      headlineMedium: base.headlineMedium?.copyWith(
        fontSize: 20,
        fontWeight: FontWeight.w500,
        color: baseColor,
        height: 1.3,
        letterSpacing: 0,
      ),

      // Body text - for content
      bodyLarge: base.bodyLarge?.copyWith(
        fontSize: 17,
        fontWeight: FontWeight.w400,
        color: baseColor,
        height: 1.5,
        letterSpacing: 0,
      ),
      bodyMedium: base.bodyMedium?.copyWith(
        fontSize: 15,
        fontWeight: FontWeight.w400,
        color: subtleColor,
        height: 1.45,
        letterSpacing: 0,
      ),
      bodySmall: base.bodySmall?.copyWith(
        fontSize: 13,
        fontWeight: FontWeight.w400,
        color: secondaryColor,
        height: 1.4,
        letterSpacing: 0.1,
      ),

      // Labels - for UI elements
      labelLarge: base.labelLarge?.copyWith(
        fontSize: 15,
        fontWeight: FontWeight.w500,
        color: baseColor,
        height: 1.3,
        letterSpacing: 0.1,
      ),
    );
  }
}
