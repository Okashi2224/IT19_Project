import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/discovery_feed.dart';
import 'screens/item_detail.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/inbox_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/chat_screen.dart';
import 'screens/skills_screen.dart';
import 'screens/help_center_screen.dart';
import 'screens/notifications_screen.dart';
import 'screens/marketplace_screen.dart';
import 'screens/premium_screen.dart';
import 'screens/organizations_screen.dart';
import 'providers/app_state.dart';

void main() {
  runApp(const CampusXchangeApp());
}

// Organic Elegance Design System
class AppColors {
  // Primary Palette (Organic Elegance) - as specified
  static const Color warmBone = Color(0xFFFAF7F2);        // Scaffold Background
  static const Color espresso = Color(0xFF2C1B0E);        // Text Color
  static const Color darkWalnut = Color(0xFF5D4037);      // Primary Color
  static const Color oak = Color(0xFFD2B48C);             // Secondary Color
  
  // Extended Palette
  static const Color softOak = Color(0xFFBC9B78);
  static const Color beigeBadge = Color(0xFFF5E6D3);
  static const Color cardBorder = Color(0xFFE8DDD4);
  static const Color glassBg = Color(0xFFFFFFFB);
  
  // Legacy compatibility aliases
  static const Color creamWhite = warmBone;
  static const Color campusCream = warmBone;
  static const Color campusWood = darkWalnut;
  static const Color campusOak = oak;
  static const Color campusText = espresso;
  static const Color deepEspresso = espresso;
  static const Color woodDark = darkWalnut;
  static const Color woodLight = softOak;
  static const Color warmCream = warmBone;
  
  // Status Colors
  static const Color success = Color(0xFF4A7C59);
  static const Color error = Color(0xFFB74C4C);
  static const Color warning = Color(0xFFD4A574);
  static const Color info = Color(0xFF6B8E9B);
  static const Color accent = Color(0xFFD4A574);     // Accent/Featured color
  
  // AI Feature Colors
  static const Color aiPurple = Color(0xFF7C6B9B);
  static const Color aiGlow = Color(0xFFE8E0F0);
}

/// Global AppState instance for simple state access
/// For more complex apps, consider using Provider/Riverpod
class AppStateManager {
  static final AppState instance = AppState();
}

class CampusXchangeApp extends StatelessWidget {
  const CampusXchangeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CampusXchange',
      debugShowCheckedModeBanner: false,
      theme: _buildOrganicEleganceTheme(),
      initialRoute: '/login',
      routes: {
        '/': (context) => const DiscoveryFeedScreen(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/item-detail': (context) => const ItemDetailScreen(),
        '/inbox': (context) => const InboxScreen(),
        '/profile': (context) => const ProfileScreen(),
        '/chat': (context) => const ChatScreen(),
        '/skills': (context) => const SkillsScreen(),
        '/help': (context) => const HelpCenterScreen(),
        '/notifications': (context) => const NotificationsScreen(),
        '/marketplace': (context) => const MarketplaceScreen(),
        '/premium': (context) => const PremiumScreen(),
        '/organizations': (context) => const OrganizationsScreen(),
      },
    );
  }

  /// Build the Organic Elegance theme with Playfair Display and Inter fonts
  ThemeData _buildOrganicEleganceTheme() {
    return ThemeData(
      // Scaffold background: Warm Bone (#FAF7F2)
      scaffoldBackgroundColor: AppColors.warmBone,
      // Primary: Walnut (#5D4037)
      primaryColor: AppColors.darkWalnut,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.darkWalnut,
        primary: AppColors.darkWalnut,
        secondary: AppColors.oak,
        surface: AppColors.warmBone,
        onPrimary: Colors.white,
        onSecondary: AppColors.espresso,
        onSurface: AppColors.espresso,
      ),
      // Typography: Playfair Display for Display/Headings, Inter for body
      textTheme: TextTheme(
        // Display styles - Playfair Display
        displayLarge: GoogleFonts.playfairDisplay(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: AppColors.espresso,
        ),
        displayMedium: GoogleFonts.playfairDisplay(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: AppColors.espresso,
        ),
        displaySmall: GoogleFonts.playfairDisplay(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: AppColors.espresso,
        ),
        // Headline styles - Playfair Display
        headlineLarge: GoogleFonts.playfairDisplay(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: AppColors.espresso,
        ),
        headlineMedium: GoogleFonts.playfairDisplay(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: AppColors.espresso,
        ),
        headlineSmall: GoogleFonts.playfairDisplay(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.espresso,
        ),
        // Title styles - Playfair Display
        titleLarge: GoogleFonts.playfairDisplay(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.espresso,
        ),
        titleMedium: GoogleFonts.playfairDisplay(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: AppColors.espresso,
        ),
        titleSmall: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: AppColors.espresso,
        ),
        // Body styles - Inter
        bodyLarge: GoogleFonts.inter(
          fontSize: 16,
          color: AppColors.espresso,
        ),
        bodyMedium: GoogleFonts.inter(
          fontSize: 14,
          color: AppColors.espresso,
        ),
        bodySmall: GoogleFonts.inter(
          fontSize: 12,
          color: AppColors.espresso,
        ),
        // Label styles - Inter
        labelLarge: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        labelMedium: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: AppColors.espresso,
        ),
        labelSmall: GoogleFonts.inter(
          fontSize: 10,
          fontWeight: FontWeight.w500,
          color: AppColors.espresso,
        ),
      ),
      // AppBar Theme
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.warmBone,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.darkWalnut),
        titleTextStyle: GoogleFonts.playfairDisplay(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: AppColors.espresso,
        ),
      ),
      // Elevated Button with 24px border radius
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.darkWalnut,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          elevation: 0,
        ),
      ),
      // Outlined Button with 24px border radius
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.darkWalnut,
          side: const BorderSide(color: AppColors.darkWalnut, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
        ),
      ),
      // Input decoration
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.cardBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.cardBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.darkWalnut, width: 2),
        ),
      ),
      // Card theme with 24px border radius and custom shadow
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(color: AppColors.cardBorder),
        ),
        color: Colors.white,
      ),
    );
  }
}
