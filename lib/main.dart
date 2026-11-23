/// بازی‌سازی افسانه — نسخهٔ ۶ با رندر سه‌بعدی واقعی (Zflutter)
import 'package:flutter/material.dart';
import 'src/theme.dart';
import 'src/audio/audio_manager.dart';
import 'src/screens/home_screen.dart';
import 'src/screens/editor_screen.dart';
import 'src/screens/play_screen.dart';
import 'src/game_store.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  AudioManager.instance.musicEnabled = false;
  runApp(const BazisaziAfsaneApp());
}

class BazisaziAfsaneApp extends StatelessWidget {
  const BazisaziAfsaneApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'بازی\u200cسازی افسانه ۳بعدی',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: AppPalette.primary, brightness: Brightness.light),
        fontFamily: 'Vazirmatn',
        scaffoldBackgroundColor: AppPalette.surface,
        appBarTheme: const AppBarTheme(
          backgroundColor: AppPalette.primaryDark,
          foregroundColor: Colors.white,
          centerTitle: true,
          elevation: 0,
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            minimumSize: const Size(72, 56),
            textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          ),
        ),
        cardTheme: CardThemeData(
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        ),
      ),
      builder: (context, child) => Directionality(textDirection: TextDirection.rtl, child: child!),
      home: const HomeScreen(),
    );
  }
}
