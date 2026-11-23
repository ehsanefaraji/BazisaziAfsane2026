/// پالت رنگ و تم بصری نسخهٔ ۵ — ارتقایافته با ۵ محیط و گرادیان‌های پیشرفته
import 'package:flutter/material.dart';

class AppPalette {
  AppPalette._();

  // رنگ‌های اصلی برند
  static const Color primary        = Color(0xFF8E44FF);
  static const Color primaryDark    = Color(0xFF5E35B1);
  static const Color primaryLight   = Color(0xFFB388FF);
  static const Color accent         = Color(0xFFFFD54F);
  static const Color success        = Color(0xFF66BB6A);
  static const Color danger         = Color(0xFFEF5350);

  // پالت محیط‌ها
  static const Color forestCanopy   = Color(0xFF2E7D32);
  static const Color forestGlow     = Color(0xFFA5D6A7);
  static const Color skyTop         = Color(0xFF5E6BB8);
  static const Color skySunset      = Color(0xFFFF8A65);
  static const Color underwater     = Color(0xFF00ACC1);
  static const Color coral          = Color(0xFFFF6F61);
  static const Color caveCrystal    = Color(0xFF7E57C2);
  static const Color caveDeep       = Color(0xFF1A237E);
  static const Color castleGold     = Color(0xFFFFD700);
  static const Color castleTwilight = Color(0xFF6A1B9A);

  // رنگ‌های آیتم
  static const Color coin           = Color(0xFFFFD54F);
  static const Color coinGlow       = Color(0xFFFFF59D);
  static const Color enemy          = Color(0xFFEF5350);
  static const Color exit           = Color(0xFF66BB6A);
  static const Color decoration     = Color(0xFFCE93D8);
  // پاورآپ‌های جدید
  static const Color shield         = Color(0xFF42A5F5);
  static const Color magnet         = Color(0xFFFF7043);
  static const Color speedBoost     = Color(0xFFAB47BC);
  static const Color extraLife      = Color(0xFFEC407A);

  // رابط
  static const Color surface        = Color(0xFFFFF8E7);
  static const Color surfaceDeep    = Color(0xFFFFE4B5);
  static const Color textPrimary    = Color(0xFF2E1840);
  static const Color textSecondary  = Color(0xFF6A4F7C);

  // گرادیان‌های هر محیط
  static const LinearGradient heroGradient = LinearGradient(
    begin: Alignment.topCenter, end: Alignment.bottomCenter,
    colors: [Color(0xFF0D1457), Color(0xFF4527A0), Color(0xFF8E44FF), Color(0xFFFF8A65)],
    stops: [0.0, 0.3, 0.7, 1.0],
  );

  static const LinearGradient buttonGradient = LinearGradient(
    begin: Alignment.topLeft, end: Alignment.bottomRight,
    colors: [Color(0xFFB388FF), Color(0xFF7E57C2), Color(0xFF5E35B1)],
  );

  static const LinearGradient forestGradient = LinearGradient(
    begin: Alignment.topCenter, end: Alignment.bottomCenter,
    colors: [Color(0xFF0D1457), Color(0xFF1A237E), Color(0xFF2E7D32), Color(0xFF558B2F)],
  );

  static const LinearGradient skyGradient = LinearGradient(
    begin: Alignment.topCenter, end: Alignment.bottomCenter,
    colors: [Color(0xFF1A237E), Color(0xFF5E6BB8), Color(0xFFFF8A65), Color(0xFFFFD180)],
  );

  static const LinearGradient underwaterGradient = LinearGradient(
    begin: Alignment.topCenter, end: Alignment.bottomCenter,
    colors: [Color(0xFF00ACC1), Color(0xFF00838F), Color(0xFF006064)],
  );

  static const LinearGradient caveGradient = LinearGradient(
    begin: Alignment.topCenter, end: Alignment.bottomCenter,
    colors: [Color(0xFF1A237E), Color(0xFF311B92), Color(0xFF4527A0)],
  );

  static const LinearGradient castleGradient = LinearGradient(
    begin: Alignment.topCenter, end: Alignment.bottomCenter,
    colors: [Color(0xFF6A1B9A), Color(0xFF4527A0), Color(0xFF1A237E)],
  );
}

class AppShadows {
  AppShadows._();

  static List<BoxShadow> card = [
    BoxShadow(
      color: const Color(0xFF5E35B1).withValues(alpha: 0.25),
      offset: const Offset(0, 8),
      blurRadius: 16,
    ),
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.08),
      offset: const Offset(0, 2),
      blurRadius: 4,
    ),
  ];

  static List<BoxShadow> button = [
    BoxShadow(
      color: const Color(0xFF5E35B1).withValues(alpha: 0.45),
      offset: const Offset(0, 8),
      blurRadius: 14,
    ),
  ];

  static List<BoxShadow> glow = [
    BoxShadow(
      color: const Color(0xFFFFD54F).withValues(alpha: 0.7),
      offset: Offset.zero,
      blurRadius: 20,
    ),
  ];

  static List<BoxShadow> glowColor(Color c) => [
    BoxShadow(color: c.withValues(alpha: 0.6), offset: Offset.zero, blurRadius: 16),
  ];
}

/// ۵ محیط بصری، هر کدام برای یک سبک بازی
enum Environment { forest, sky, underwater, cave, castle }

extension EnvironmentX on Environment {
  String get name {
    switch (this) {
      case Environment.forest:     return 'جنگل';
      case Environment.sky:        return 'آسمان';
      case Environment.underwater: return 'زیر آب';
      case Environment.cave:       return 'غار';
      case Environment.castle:     return 'قلعه';
    }
  }

  String get assetPath {
    switch (this) {
      case Environment.forest:     return 'assets/images/bg-forest.png';
      case Environment.sky:        return 'assets/images/bg-sky.png';
      case Environment.underwater: return 'assets/images/bg-underwater.png';
      case Environment.cave:       return 'assets/images/bg-cave.png';
      case Environment.castle:     return 'assets/images/bg-castle.png';
    }
  }

  LinearGradient get gradient {
    switch (this) {
      case Environment.forest:     return AppPalette.forestGradient;
      case Environment.sky:        return AppPalette.skyGradient;
      case Environment.underwater: return AppPalette.underwaterGradient;
      case Environment.cave:       return AppPalette.caveGradient;
      case Environment.castle:     return AppPalette.castleGradient;
    }
  }
}
