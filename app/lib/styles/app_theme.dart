import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Modern Material 3 color palette
  // Civic Tech Color Palette - Consolidated
  static const Color primaryColor =
      Color(0xFF1565C0); // Deep Govt Blue (Blue 800)
  static const Color primaryDark = Color(0xFF0D47A1); // Blue 900
  static const Color primaryLight = Color(0xFFE3F2FD); // Blue 50

  static const Color secondaryColor = Color(0xFF2E7D32); // Success Green
  static const Color secondaryLight = Color(0xFFE8F5E9);

  static const Color accentColor =
      Color(0xFFE65100); // Deep Orange (Orange 900) - Urgent Actions
  static const Color accentLight = Color(0xFFFFF3E0);

  static const Color errorColor = Color(0xFFD32F2F);
  static const Color warningColor = Color(0xFFFFA000);
  static const Color infoColor = Color(0xFF0288D1);
  static const Color successColor = Color(0xFF2E7D32);

  // Neutral colors with better contrast
  static const Color neutral100 = Color(0xFFFFFFFF);
  static const Color neutral200 =
      Color(0xFFF1F5F9); // Slate-50 - Better off-white
  static const Color neutral300 = Color(0xFFE2E8F0);
  static const Color neutral400 = Color(0xFFCBD5E1);
  static const Color neutral500 = Color(0xFF94A3B8);
  static const Color neutral600 = Color(0xFF64748B);
  static const Color neutral700 = Color(0xFF334155);
  static const Color neutral800 = Color(0xFF1E293B);
  static const Color neutral900 = Color(0xFF0F172A);

  // Status Tints (Backgrounds)
  static const Color warningLight = Color(0xFFFFF7ED); // Orange-50
  static const Color infoLight = Color(0xFFEFF6FF); // Blue-50
  static const Color successLight = Color(0xFFF0FDF4); // Green-50

  // Surface colors for Material 3
  static const Color surfaceVariant =
      Color(0xFFF8FAFC); // Slate-50 for cards/sections
  static const Color onSurfaceVariant = Color(0xFF64748B);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor:
          const Color(0xFFF8FAFC), // Set global off-white background
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        brightness: Brightness.light,
        primary: primaryColor,
        secondary: secondaryColor,
        tertiary: accentColor, // Use Orange as tertiary
        surface: const Color(0xFFFFFFFF), // Cards stay white

        surfaceContainerHighest: surfaceVariant,
        onSurface: neutral800,
        onSurfaceVariant: onSurfaceVariant,
        error: errorColor,
      ),
      textTheme: GoogleFonts.interTextTheme(
        // Switched to Inter as requested usage of "system-friendly"
        const TextTheme(
          displayLarge: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: neutral800,
            letterSpacing: -0.5,
          ),
          displayMedium: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: neutral800,
            letterSpacing: -0.5,
          ),
          displaySmall: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: neutral800,
          ),
          headlineLarge: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: neutral800,
          ),
          headlineMedium: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: neutral800,
          ),
          headlineSmall: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: neutral800,
          ),
          bodyLarge: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.normal,
            color: neutral800,
          ),
          bodyMedium: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.normal,
            color: neutral800,
          ),
          bodySmall: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.normal,
            color: neutral600,
          ),
          labelLarge: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: neutral800,
          ),
          labelMedium: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: neutral600,
          ),
          labelSmall: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w500,
            color: neutral600,
          ),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor:
            neutral100, // White header as requested in Drawer/Nav section (consistency)
        foregroundColor: neutral800,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.inter(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: neutral800,
        ),
        shape: const Border(
            bottom: BorderSide(color: neutral200, width: 1)), // Divider style
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor, // Primary Blue for actions
          foregroundColor: neutral100,
          elevation: 0, // Flat/Modern
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8)), // Less rounded
          textStyle: GoogleFonts.inter(
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: accentColor, // Orange for Urgent FAB
        foregroundColor: neutral100,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: neutral100,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: neutral300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: neutral300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: errorColor),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        labelStyle: GoogleFonts.inter(
          color: neutral600,
          fontWeight: FontWeight.w500,
        ),
        hintStyle: GoogleFonts.inter(
          color: neutral500,
        ),
      ),
      cardTheme: CardThemeData(
        color: neutral100,
        elevation: 1, // Subtle
        shadowColor: Colors.black.withValues(alpha: 0.05),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 0),
      ),
      drawerTheme: const DrawerThemeData(
        backgroundColor: neutral100,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.horizontal(
            right: Radius.circular(0), // Standard drawer
          ),
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: neutral100,
        selectedItemColor: primaryColor,
        unselectedItemColor: neutral500,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        selectedLabelStyle: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      // Keep dark theme simple for now, mirroring structure
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        brightness: Brightness.dark,
        primary: primaryColor,
        secondary: secondaryColor,
        surface: neutral900,
        onSurface: neutral100,
      ),
      // ... (Rest of dark theme can be simplified or kept similar)
    );
  }

  // Animation curves
  static const Duration animationDuration = Duration(milliseconds: 300);
  static const Curve animationCurve = Curves.easeInOut;

  // Modern gradient definitions - REFINED (Subtle/Monotonic only)
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryColor, primaryDark], // Monotonic Blue
  );

  // REMOVED mixed accent gradient. Use solid accentColor.
  static const LinearGradient accentGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [accentColor, accentColor], // Solid fallback
  );

  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [neutral100, neutral200],
  );
}
